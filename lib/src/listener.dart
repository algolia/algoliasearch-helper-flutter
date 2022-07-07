import 'package:algolia/algolia.dart';

/// Algolia Search Listener.
class Listener {
  final Function(AlgoliaQuerySnapshot)? onResult;
  final Function(AlgoliaError)? onError;

  Listener({this.onResult, this.onError});
}
