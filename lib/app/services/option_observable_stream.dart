import 'dart:async';

import 'package:nearbymenus/app/models/option.dart';
import 'package:rxdart/rxdart.dart';

class OptionObservableStream {
  final Map<String?, dynamic>? observable;

  OptionObservableStream({this.observable});

  BehaviorSubject<Map<String?, dynamic>?> _subject =
      BehaviorSubject<Map<String, dynamic>?>.seeded(null);
  Stream<List<Option>> get stream =>
      _subject.stream.transform(streamTransformer);

  var streamTransformer =
      StreamTransformer<Map<String?, dynamic>?, List<Option>>.fromHandlers(
          handleData:
              (Map<String?, dynamic>? data, EventSink<List<Option>> sink) {
            List<Option> optionList = [];
            data!.forEach((key, value) {
              optionList.add(Option.fromMap(value, null) as Option);
            });
            sink.add(optionList);
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
