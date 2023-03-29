import 'dart:async';

import 'package:nearbymenus/app/models/menu.dart';
import 'package:rxdart/rxdart.dart';

class MenuObservableStream {
  final Map<String?, dynamic>? observable;

  MenuObservableStream({this.observable});

  BehaviorSubject<Map<String?, dynamic>?> _subject =
      BehaviorSubject<Map<String?, dynamic>?>.seeded(null);
  Stream<List<Menu>> get stream => _subject.stream.transform(streamTransformer);

  var streamTransformer =
      StreamTransformer<Map<String?, dynamic>?, List<Menu>>.fromHandlers(
          handleData:
              (Map<String?, dynamic>? data, EventSink<List<Menu>> sink) {
            List<Menu> menuList = [];
            data!.forEach((key, value) {
              menuList.add(Menu.fromMap(value, null) as Menu);
            });
            menuList.sort((a, b) => a.sequence!.compareTo(b.sequence!));
            sink.add(menuList);
          },
          handleDone: (sink) => sink.close(),
          handleError: (error, stack, sink) => print('Error: $error'));

  void init() {
    _subject = BehaviorSubject<Map<String?, dynamic>?>.seeded(observable);
  }

  void broadcastEvent(Map<String?, dynamic>? event) {
    _subject.add(event);
  }

  void dispose() {
    _subject.close();
  }
}
