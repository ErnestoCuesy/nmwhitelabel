import 'package:flutter/material.dart';
import 'package:nmwhitelabel/app/common_widgets/platform_progress_indicator.dart';
import 'package:nmwhitelabel/app/models/authorizations.dart';
import 'package:nmwhitelabel/app/models/session.dart';
import 'package:nmwhitelabel/app/pages/messages/messages_listener.dart';
import 'package:nmwhitelabel/app/pages/restaurant/restaurant_administrator_page.dart';
import 'package:nmwhitelabel/app/pages/restaurant/staff_authorization_page.dart';
import 'package:nmwhitelabel/app/services/database.dart';
import 'package:provider/provider.dart';

class CheckStaffAuthorization extends StatefulWidget {

  @override
  _CheckStaffAuthorizationState createState() => _CheckStaffAuthorizationState();
}

class _CheckStaffAuthorizationState extends State<CheckStaffAuthorization> {
  late Session session;
  late Database database;

  @override
  Widget build(BuildContext context) {
    session = Provider.of<Session>(context);
    database = Provider.of<Database>(context, listen: true);
    return StreamBuilder<Authorizations>(
      stream: database.authorizationsStream(session.currentRestaurant!.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(
              child: PlatformProgressIndicator(),
            ),
          );
        }
        if (snapshot.hasData) {
          final Authorizations authorizations = snapshot.data!;
          if (authorizations.authorizedRoles![database.userId] == ROLE_STAFF ||
              authorizations.authorizedRoles![database.userId] == ROLE_VENUE) {
            session.userDetails!.role = authorizations.authorizedRoles![database.userId];
            return MessagesListener(child: RestaurantAdministratorPage(),);
          }
        }
        return StaffAuthorizationPage();
      }
    );
  }
}
