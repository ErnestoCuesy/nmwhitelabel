import 'package:flutter/material.dart';
import 'package:nmwhitelabel/app/common_widgets/platform_progress_indicator.dart';
import 'package:nmwhitelabel/app/models/session.dart';
import 'package:nmwhitelabel/app/pages/sign_in/sign_in_page.dart';
import 'package:provider/provider.dart';

class CheckConvertedUser extends StatefulWidget {
  final Widget? child;

  const CheckConvertedUser({Key? key, this.child}) : super(key: key);
  @override
  _CheckConvertedUserState createState() => _CheckConvertedUserState();
}

class _CheckConvertedUserState extends State<CheckConvertedUser> {
  late Session session;

  @override
  Widget build(BuildContext context) {
    session = Provider.of<Session>(context);
    return StreamBuilder<bool>(
        stream: session.anonymousUserFlagObservable,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.active) {
            bool userIsAnonymous = snapshot.data!;
            session.isAnonymousUser = userIsAnonymous;
            if (userIsAnonymous) {
              return SignInPage(allowAnonymousSignIn: false, convertAnonymous: true,);
            } else {
              return widget.child!;
            }
          } else {
            return Center(child: PlatformProgressIndicator(),);
          }
        }
    );
  }

}
