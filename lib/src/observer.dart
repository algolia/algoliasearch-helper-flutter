import 'package:algolia/algolia.dart';

/// Algolia Search Observer.
class Observer {
  final Function(AlgoliaQuerySnapshot response)? onNext;
  final Function(AlgoliaError error)? onError;
  final Function? onComplete;

  Observer({this.onNext, this.onError, this.onComplete});
}
