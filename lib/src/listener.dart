import 'package:algolia/algolia.dart';

/// Algolia Search Listener.
class Listener {
  final Function(AlgoliaQuerySnapshot response)? onResult;
  final Function(AlgoliaError error)? onError;

  Listener({this.onResult, this.onError});
}
