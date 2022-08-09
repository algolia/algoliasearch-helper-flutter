import 'package:meta/meta.dart';

/// Algolia helper runtime exception
@sealed
abstract class AlgoliaException implements Exception {}

/// Exception thrown when an error occurs during search requests.
class SearchError extends AlgoliaException {
  @internal
  SearchError(this.error, this.statusCode);

  /// Error details (e.g. message)
  final Map error;

  /// Response status code
  final int statusCode;

  @override
  String toString() => 'SearchError{error: $error, statusCode: $statusCode}';
}
