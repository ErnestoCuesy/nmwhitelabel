import 'dart:async';

import 'package:nearbymenus/app/models/option_item.dart';
import 'package:rxdart/rxdart.dart';

class OptionItemObservableStream {
  final Map<String, dynamic>? observable;

  OptionItemObservableStream({this.observable});

  BehaviorSubject<Map<String, dynamic>?> _subject =
      BehaviorSubject<Map<String, dynamic>?>.seeded(null);
  Stream<List<OptionItem>> get stream =>
      _subject.stream.transform(streamTransformer);

  var streamTransformer =
      StreamTransformer<Map<String, dynamic>?, List<OptionItem>>.fromHandlers(
          handleData:
              (Map<String, dynamic>? data, EventSink<List<OptionItem>> sink) {
            List<OptionItem> optionItemList = [];
            data!.forEach((key, value) {
              if (key.length > 20) {
                optionItemList
                    .add(OptionItem.fromMap(value, null) as OptionItem);
              }
            });
            sink.add(optionItemList);
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
