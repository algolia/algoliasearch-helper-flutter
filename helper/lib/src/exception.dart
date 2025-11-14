import 'package:meta/meta.dart';

/// Exception thrown when an error occurs during search operations.
sealed class AlgoliaException implements Exception {}

/// Exception thrown when an error occurs during search requests.
final class SearchError extends AlgoliaException {
  /// Creates [SearchError] instance.
  @internal
  SearchError(this.error, this.statusCode, [this.cause]);

  /// Error details (e.g. message)
  final Map error;

  /// Response status code
  final int statusCode;

  /// Original exception that caused this error, if any.
  /// This allows apps to inspect the underlying exception for detailed error handling.
  final Object? cause;

  @override
  String toString() =>
      'SearchError{error: $error, statusCode: $statusCode, cause: $cause}';
}
