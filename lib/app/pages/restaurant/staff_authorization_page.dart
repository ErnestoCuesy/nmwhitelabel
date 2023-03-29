import 'package:flutter/material.dart';
import 'package:nmwhitelabel/app/common_widgets/custom_raised_button.dart';
import 'package:nmwhitelabel/app/models/restaurant.dart';
import 'package:nmwhitelabel/app/models/user_message.dart';
import 'package:nmwhitelabel/app/pages/sign_in/conversion_process.dart';
import 'package:nmwhitelabel/app/services/auth.dart';
import 'package:nmwhitelabel/app/services/database.dart';
import 'package:nmwhitelabel/app/models/session.dart';
import 'package:nmwhitelabel/app/services/navigation_service.dart';
import 'package:provider/provider.dart';

class StaffAuthorizationPage extends StatefulWidget {
  @override
  _StaffAuthorizationPageState createState() => _StaffAuthorizationPageState();
}

class _StaffAuthorizationPageState extends State<StaffAuthorizationPage> {
  Auth? auth;
  Session? session;
  Database? database;
  NavigationService? navigationService;
  bool staffRequestPending = false;
  Restaurant? get restaurant => session!.currentRestaurant;
  double buttonSize = 180.0;
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  List<Widget> _buildAccessRequestItems(BuildContext context) {
    String staffAccessSubtitle = 'You are not allowed to access orders';
    if (!restaurant!.acceptingStaffRequests!) {
      staffAccessSubtitle = 'Restaurant is not accepting staff requests';
    }
    return [
      Text('${restaurant!.name}',
          style: Theme.of(context).primaryTextTheme.headlineMedium),
      SizedBox(
        height: 16.0,
      ),
      Text(staffAccessSubtitle,
          style: Theme.of(context).primaryTextTheme.titleLarge),
      SizedBox(
        height: 32.0,
      ),
      if (restaurant!.acceptingStaffRequests!)
        CustomRaisedButton(
            height: buttonSize,
            width: buttonSize,
            color: Theme.of(context).buttonTheme.colorScheme!.surface,
            onPressed: () => _convertUser(context, _requestRestaurantAccess),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Request Access',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                SizedBox(
                  height: 16.0,
                ),
                Icon(
                  Icons.error_outline,
                  size: 36.0,
                ),
              ],
            ))
    ];
  }

  void _convertUser(
      BuildContext context, Function(BuildContext) nextAction) async {
    if (!session!.userProcessComplete) {
      final ConversionProcess conversionProcess = ConversionProcess(
        navigationService: navigationService,
        session: session,
        auth: auth,
        database: database,
        captureUserDetails: true,
      );
      if (!await conversionProcess.userCanProceed()) {
        return;
      }
    }
    nextAction(context);
  }

  Future<void> _requestRestaurantAccess(BuildContext context) async {
    final double timestamp = dateFromCurrentDate() / 1.0;
    database!.setMessageDetails(UserMessage(
      id: documentIdFromCurrentDate(),
      timestamp: timestamp,
      fromUid: database!.userId,
      toUid: session!.currentRestaurant!.managerId,
      restaurantId: session!.currentRestaurant!.id,
      fromRole: ROLE_STAFF,
      toRole: ROLE_MANAGER,
      fromName:
          '${session!.userDetails!.name} (${session!.userDetails!.email})',
      delivered: false,
      type: 'Access to ${session!.currentRestaurant!.name}',
      authFlag: false,
      attendedFlag: false,
    ));
    //Navigator.of(context).pop();
    // _scaffoldKey.currentState.showSnackBar(
    //   SnackBar(
    //     content: Text('Access request sent, pending approval... please wait'),
    //   ),
    // );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Access request sent, pending approval... please wait'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    auth = Provider.of<AuthBase>(context) as Auth?;
    session = Provider.of<Session>(context);
    database = Provider.of<Database>(context);
    navigationService = Provider.of<NavigationService>(context);
    var accountText = 'Your access status';
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(
          accountText,
          style: Theme.of(context).primaryTextTheme.titleLarge,
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: _buildAccessRequestItems(context),
        ),
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
    );
  }
}
