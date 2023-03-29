import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:nearbymenus/app/common_widgets/platform_progress_indicator.dart';
import 'package:nearbymenus/app/config/flavour_config.dart';
import 'package:nearbymenus/app/models/session.dart';
import 'package:nearbymenus/app/models/user_message.dart';
import 'package:nearbymenus/app/services/database.dart';
import 'package:provider/provider.dart';

class MessagesListener extends StatefulWidget {
  final Widget? child;

  const MessagesListener({Key? key, this.child}) : super(key: key);

  @override
  _MessagesListenerState createState() => _MessagesListenerState();
}

class _MessagesListenerState extends State<MessagesListener> {
  late Session session;
  late Database database;
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  Future<void> _notifyUser(UserMessage message) async {
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'CH1', 'Role notifications',
        channelDescription: 'Channel used to notify restaurant roles',
        importance: Importance.high,
        priority: Priority.high,
        ticker: 'ticker');
    var iOSPlatformChannelSpecifics = DarwinNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
        0,
        'Nearby Menus',
        'Notification from ${message.fromRole}: ${message.type}',
        platformChannelSpecifics,
        payload: 'item x');
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    session = Provider.of<Session>(context);
    database = Provider.of<Database>(context, listen: true);
    flutterLocalNotificationsPlugin =
        Provider.of<FlutterLocalNotificationsPlugin>(context);
    String role = '';
    Stream<List<UserMessage>> _stream;
    if (FlavourConfig.isManager()) {
      role = ROLE_MANAGER;
      _stream = database.managerMessages(database.userId, role);
    } else if (FlavourConfig.isStaff()) {
      role = session.userDetails!.role ?? ROLE_STAFF;
      _stream = database.staffMessages(session.currentRestaurant!.id, role);
    } else if (FlavourConfig.isPatron()) {
      role = ROLE_PATRON;
      _stream = database.patronMessages(database.userId);
    } else {
      role = ROLE_ADMIN;
      _stream = database.adminMessages();
    }
    return StreamBuilder<List<UserMessage>>(
        stream: _stream,
        builder: (context, snapshot) {
          session.broadcastMessageCounter(0);
          int messageCounter = 0;
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(
              body: Center(
                child: PlatformProgressIndicator(),
              ),
            );
          }
          if (snapshot.hasData) {
            final notificationsList = snapshot.data!;
            notificationsList.forEach((message) {
              if (message.toRole == role && !message.delivered!) {
                _notifyUser(message);
                if (message.toRole == ROLE_PATRON ||
                    message.toRole == ROLE_STAFF ||
                    message.toRole == ROLE_ADMIN) {
                  database.deleteMessage(message.id);
                } else {
                  UserMessage readMessage = UserMessage(
                    id: message.id,
                    timestamp: message.timestamp,
                    fromUid: message.fromUid,
                    toUid: message.toUid,
                    restaurantId: message.restaurantId,
                    fromRole: message.fromRole,
                    toRole: message.toRole,
                    fromName: message.fromName,
                    type: message.type,
                    authFlag: message.authFlag,
                    delivered: true,
                    attendedFlag: message.attendedFlag,
                  );
                  database.setMessageDetails(readMessage);
                }
              }
              if (message.toRole == ROLE_MANAGER) {
                if (!message.attendedFlag!) {
                  messageCounter++;
                } else {
                  messageCounter--;
                }
                session.broadcastMessageCounter(messageCounter);
              }
            });
          }
          return widget.child!;
        });
  }
}
