import 'package:meta/meta.dart';

/// Exception thrown when an error occurs during search operations.
@sealed
abstract class AlgoliaException implements Exception {}

/// Exception thrown when an error occurs during search requests.
class SearchError extends AlgoliaException {
  /// Creates [SearchError] instance.
  @internal
  SearchError(this.error, this.statusCode);

  /// Error details (e.g. message)
  final Map error;

  /// Response status code
  final int statusCode;

  @override
  String toString() => 'SearchError{error: $error, statusCode: $statusCode}';
}
