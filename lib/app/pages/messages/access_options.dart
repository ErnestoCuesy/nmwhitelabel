import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nearbymenus/app/common_widgets/platform_progress_indicator.dart';
import 'package:nearbymenus/app/models/authorizations.dart';
import 'package:nearbymenus/app/models/restaurant.dart';
import 'package:nearbymenus/app/models/session.dart';
import 'package:nearbymenus/app/models/user_message.dart';
import 'package:nearbymenus/app/services/database.dart';
import 'package:provider/provider.dart';

import 'authorized_dates.dart';

class AccessOptions extends StatefulWidget {
  final UserMessage? message;

  const AccessOptions({Key? key, this.message}) : super(key: key);

  @override
  _AccessOptionsState createState() => _AccessOptionsState();
}

class _AccessOptionsState extends State<AccessOptions> {
  late Session session;
  late Database database;
  Authorizations authorizations = Authorizations(
      authorizedRoles: {}, authorizedNames: {}, authorizedDates: {});
  Restaurant? get restaurant => session.currentRestaurant;
  UserMessage? get message => widget.message;
  double buttonSize = 180.0;
  bool get hasPermAuth =>
      authorizations.authorizedRoles!.containsKey(message!.fromUid) &&
      authorizations.authorizedRoles![message!.fromUid] == ROLE_STAFF;
  bool get hasVenueAuth =>
      authorizations.authorizedRoles!.containsKey(message!.fromUid) &&
      authorizations.authorizedRoles![message!.fromUid] == ROLE_VENUE;

  void _changeVenueAuthorization() async {
    List<dynamic> authorizedIntDates =
        authorizations.authorizedDates![message!.fromUid] ?? [];
    final authorizedDates = await Navigator.of(context).push(
      MaterialPageRoute<List<DateTime>>(
        fullscreenDialog: false,
        builder: (context) => AuthorizedDates(
          authorizedIntDates: authorizedIntDates,
        ),
      ),
    );
    if (authorizedDates != null && authorizedDates.length > 0) {
      authorizedIntDates.clear();
      authorizedDates.forEach((date) {
        authorizedIntDates.add(date.millisecondsSinceEpoch);
      });
      if (hasPermAuth) {
        authorizations.authorizedRoles!
            .update(message!.fromUid, (value) => ROLE_VENUE);
      } else {
        authorizations.authorizedRoles!
            .putIfAbsent(message!.fromUid, () => ROLE_VENUE);
      }
      authorizations.authorizedNames!
          .putIfAbsent(message!.fromUid, () => message!.fromName);
      if (authorizations.authorizedDates!.containsKey(message!.fromUid)) {
        authorizations.authorizedDates!
            .update(message!.fromUid, (value) => authorizedIntDates);
      } else {
        authorizations.authorizedDates!
            .putIfAbsent(message!.fromUid, () => authorizedIntDates);
      }
      setState(() {
        message!.authFlag = true;
      });
    } else {
      authorizations.authorizedRoles!.remove(message!.fromUid);
      authorizations.authorizedNames!.remove(message!.fromUid);
      authorizations.authorizedDates!.remove(message!.fromUid);
      setState(() {
        message!.authFlag = false;
      });
    }
    _setDatabaseAuthorization();
  }

  void _changePermAuthorization(bool flag) {
    setState(() {
      message!.authFlag = flag;
    });
    if (flag) {
      if (hasVenueAuth) {
        authorizations.authorizedRoles!
            .update(message!.fromUid, (value) => ROLE_STAFF);
      } else {
        authorizations.authorizedRoles!
            .putIfAbsent(message!.fromUid, () => ROLE_STAFF);
      }
      authorizations.authorizedNames!
          .putIfAbsent(message!.fromUid, () => message!.fromName);
    } else {
      authorizations.authorizedRoles!.remove(message!.fromUid);
      authorizations.authorizedNames!.remove(message!.fromUid);
    }
    authorizations.authorizedDates!.remove(message!.fromUid);
    _setDatabaseAuthorization();
  }

  void _setDatabaseAuthorization() {
    database.setAuthorization(message!.restaurantId, authorizations);
    UserMessage readMessage = UserMessage(
        id: message!.id,
        timestamp: message!.timestamp,
        fromUid: message!.fromUid,
        toUid: message!.toUid,
        restaurantId: message!.restaurantId,
        fromRole: message!.fromRole,
        toRole: message!.toRole,
        fromName: message!.fromName,
        type: message!.type,
        authFlag: message!.authFlag,
        delivered: true,
        attendedFlag: true);
    database.setMessageDetails(readMessage);
  }

  List<Widget> _buildContents(BuildContext context) {
    return [
      Text(message!.type!, style: Theme.of(context).textTheme.headlineSmall),
      SizedBox(
        height: 16.0,
      ),
      Text('Requested by ${message!.fromName}',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleLarge),
      SizedBox(
        height: 16.0,
      ),
      Text('Select access type',
          style: Theme.of(context).textTheme.headlineSmall),
      SizedBox(
        height: 32.0,
      ),
      Container(
        height: buttonSize,
        width: buttonSize,
        decoration: BoxDecoration(
          border: Border.all(),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.account_box,
              size: 36.0,
            ),
            SizedBox(
              height: 8.0,
            ),
            Text(
              'Permanent Staff Access',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            CupertinoSwitch(
                value: hasPermAuth,
                onChanged: (flag) {
                  _changePermAuthorization(flag);
                }),
          ],
        ),
      ),
      SizedBox(
        height: 16.0,
      ),
      Container(
        height: buttonSize,
        width: buttonSize,
        decoration: BoxDecoration(
          border: Border.all(),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.calendar_today,
              size: 36.0,
            ),
            SizedBox(
              height: 8.0,
            ),
            Text(
              'Sales Access\n(Selected Dates)',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            CupertinoSwitch(
                value: hasVenueAuth,
                onChanged: (flag) {
                  _changeVenueAuthorization();
                }),
          ],
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    session = Provider.of<Session>(context);
    database = Provider.of<Database>(context);
    return Scaffold(
        appBar: AppBar(
          title: Text(
            'Access Options',
            style:
                TextStyle(color: Theme.of(context).appBarTheme.backgroundColor),
          ),
        ),
        body: FutureBuilder<List<Authorizations>>(
            future: database.authorizationsSnapshot(),
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.waiting &&
                  snapshot.hasData) {
                final authorizationsList = snapshot.data!;
                if (authorizationsList.length > 0) {
                  authorizationsList.forEach((authorization) {
                    if (authorization.id == message!.restaurantId) {
                      authorizations = authorization;
                    }
                  });
                }
                return SingleChildScrollView(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: _buildContents(context),
                      ),
                    ),
                  ),
                );
              } else {
                return Center(
                  child: PlatformProgressIndicator(),
                );
              }
            }));
  }
}
