import 'package:algolia/algolia.dart';

import 'observer.dart';

extension SubscribeExtension on Future<AlgoliaQuerySnapshot> {
  void subscribe(Iterable<Observer> observers) {
    for (var observer in observers) {
      then((value) => observer.onNext?.call(value))
          .catchError((error) => observer.onError?.call(error))
          .whenComplete(() => observer.onComplete?.call());
    }
  }
}
