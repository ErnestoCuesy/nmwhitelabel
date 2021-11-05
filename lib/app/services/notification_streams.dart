import 'package:nmwhitelabel/app/models/received_notification.dart';
import 'package:rxdart/subjects.dart';

class NotificationStreams {
  final BehaviorSubject<ReceivedNotification>? didReceiveLocalNotificationSubject;
  final BehaviorSubject<String?>? selectNotificationSubject;

  NotificationStreams({this.didReceiveLocalNotificationSubject, this.selectNotificationSubject});

}