import 'package:flutter/material.dart';
import 'package:nearbymenus/app/common_widgets/platform_progress_indicator.dart';
import 'package:nearbymenus/app/config/flavour_config.dart';
import 'package:nearbymenus/app/models/user_details.dart';
import 'package:nearbymenus/app/pages/home/home_page.dart';
import 'package:nearbymenus/app/pages/home/home_page_manager.dart';
import 'package:nearbymenus/app/pages/landing/check_purchases.dart';
import 'package:nearbymenus/app/pages/sign_in/sign_in_page.dart';
import 'package:nearbymenus/app/services/auth.dart';
import 'package:nearbymenus/app/services/database.dart';
import 'package:nearbymenus/app/models/session.dart';
import 'package:nearbymenus/app/services/iap_manager.dart';
import 'package:provider/provider.dart';

class LandingPage extends StatelessWidget {
  void _setUser(Database database, Session session, UserAuth user) async {
    database.setUserId(user.uid);
    String role = ROLE_PATRON;
    if (FlavourConfig.isManager()) {
      role = ROLE_MANAGER;
    } else if (FlavourConfig.isStaff()) {
      role = ROLE_STAFF;
    } else if (FlavourConfig.isAdmin()) {
      role = ROLE_ADMIN;
    }
    session.userDetails!.role = role;
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthBase>(context, listen: true);
    final database = Provider.of<Database>(context, listen: true);
    final session = Provider.of<Session>(context, listen: true);
    return StreamBuilder<UserAuth?>(
      stream: auth.onAuthStateChanged,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          UserAuth? user = snapshot.data;
          if (user == null) {
            return SignInPage(
              allowAnonymousSignIn: FlavourConfig.isAdmin() ? false : true,
              convertAnonymous: false,
            );
          } else {
            if (!user.isAnonymous && !user.isEmailVerified) {
              auth.signOut();
            }
          }
          session.isAnonymousUser = user.isAnonymous;
          session.broadcastAnonymousUserStatus(user.isAnonymous);
          _setUser(database, session, user);
          return FutureBuilder<UserDetails>(
            future: database.userDetailsSnapshot(user.uid),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                final userDetails = snapshot.data;
                DateTime deletionTimeStamp =
                    DateTime.fromMillisecondsSinceEpoch(
                        userDetails!.deletionTimeStamp);
                DateTime deletionTimeLimit =
                    deletionTimeStamp.add(Duration(minutes: 5));
                if (deletionTimeLimit.isAfter(DateTime.now())) {
                  session.userDetails!.markedForDeletion = true;
                  try {
                    print('Trying to delete DB user');
                    database.deleteUser(database.userId).then((value) =>
                        Future.delayed(Duration(seconds: 5)).then((value) {
                          try {
                            auth.deleteUser();
                            auth.signOut();
                          } on Exception catch (e) {
                            print(e);
                            rethrow;
                          }
                        }));
                  } catch (e) {
                    print(e);
                  }
                } else {
                  if (!user.isAnonymous) {
                    if (userDetails.email == null ||
                        userDetails.email == '' ||
                        userDetails.role == null ||
                        userDetails.role == '') {
                      database.setUserDetails(session.userDetails);
                    } else {
                      session.userDetails = userDetails;
                    }
                  }
                }
                if (FlavourConfig.isManager() &&
                    !user.isAnonymous &&
                    user.isEmailVerified) {
                  return Provider<IAPManagerBase>(
                    create: (context) => IAPManager(userID: user.email),
                    child: CheckPurchases(),
                  );
                } else {
                  if (FlavourConfig.isManager()) {
                    return HomePageManager();
                  } else {
                    return HomePage();
                  }
                }
              } else {
                return Scaffold(
                  body: Center(
                    child: PlatformProgressIndicator(),
                  ),
                );
              }
            },
          );
        } else {
          return Scaffold(
            body: Center(
              child: PlatformProgressIndicator(),
            ),
          );
        }
      },
    );
  }
}
