import 'dart:async';

import 'package:nearbymenus/app/models/menu_item.dart';
import 'package:rxdart/rxdart.dart';

class MenuItemObservableStream {
  final Map<String, dynamic>? observable;

  MenuItemObservableStream({this.observable});

  BehaviorSubject<Map<String, dynamic>?> _subject =
      BehaviorSubject<Map<String, dynamic>?>.seeded(null);
  Stream<List<MenuItem>> get stream =>
      _subject.stream.transform(streamTransformer);

  var streamTransformer =
      StreamTransformer<Map<String, dynamic>?, List<MenuItem>>.fromHandlers(
          handleData:
              (Map<String, dynamic>? data, EventSink<List<MenuItem>> sink) {
            List<MenuItem> menuItemList = [];
            data!.forEach((key, value) {
              if (key.length > 20) {
                menuItemList.add(MenuItem.fromMap(value, null) as MenuItem);
              }
            });
            menuItemList.sort((a, b) => a.sequence!.compareTo(b.sequence!));
            sink.add(menuItemList);
          },
          handleDone: (sink) => sink.close(),
          handleError: (error, stack, sink) => print('Error: $error'));

  void init() {
    _subject = BehaviorSubject<Map<String, dynamic>?>.seeded(observable);
  }

  void broadcastEvent(Map<String, dynamic>? event) {
    _subject.add(event);
  }

  void dispose() {
    _subject.close();
  }
}
