import 'package:algolia_helper_flutter/src/exception.dart';
import 'package:algoliasearch/algoliasearch.dart' as algolia;
import 'package:algolia_helper_flutter/src/service/algolia_client_extensions.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SearchError', () {
    test('should preserve original exception as cause', () {
      final originalError = Exception('Original error message');
      final searchError = SearchError(
        {'message': 'Search failed'},
        500,
        originalError,
      );

      expect(searchError.error, {'message': 'Search failed'});
      expect(searchError.statusCode, 500);
      expect(searchError.cause, originalError);
      expect(identical(searchError.cause, originalError), true);
    });

    test('should allow null cause', () {
      final searchError = SearchError(
        {'message': 'Search failed'},
        404,
      );

      expect(searchError.error, {'message': 'Search failed'});
      expect(searchError.statusCode, 404);
      expect(searchError.cause, isNull);
    });

    test('toString should include cause', () {
      final originalError = Exception('Network timeout');
      final searchError = SearchError(
        {'message': 'Request failed'},
        503,
        originalError,
      );

      final stringRepresentation = searchError.toString();
      expect(stringRepresentation, contains('error:'));
      expect(stringRepresentation, contains('statusCode:'));
      expect(stringRepresentation, contains('cause:'));
    });
  });

  group('launderException', () {
    // Create a dummy SearchClient instance for testing the extension method
    late algolia.SearchClient client;

    setUp(() {
      // Create a minimal SearchClient instance
      // Note: In real usage, this would be properly configured
      client = algolia.SearchClient(
        appId: 'testAppId',
        apiKey: 'testApiKey',
      );
    });

    test('should preserve non-AlgoliaApiException as cause', () {
      final originalError = Exception('Custom error');
      final launderedError = client.launderException(originalError);

      expect(launderedError, isA<SearchError>());
      final searchError = launderedError as SearchError;
      expect(searchError.cause, originalError);
      expect(identical(searchError.cause, originalError), true);
      expect(searchError.error['message'], contains('Custom error'));
    });

    test('should preserve AlgoliaApiException as cause', () {
      final originalError = algolia.AlgoliaApiException(
        401,
        'Invalid API key',
      );
      final launderedError = client.launderException(originalError);

      expect(launderedError, isA<SearchError>());
      final searchError = launderedError as SearchError;
      expect(searchError.cause, originalError);
      expect(identical(searchError.cause, originalError), true);
      expect(searchError.statusCode, 401);
    });

    test('should preserve any object type as cause', () {
      final originalError = StateError('Invalid state');
      final launderedError = client.launderException(originalError);

      expect(launderedError, isA<SearchError>());
      final searchError = launderedError as SearchError;
      expect(searchError.cause, isA<StateError>());
      expect(identical(searchError.cause, originalError), true);
    });

    test('should preserve string errors as cause', () {
      const originalError = 'Something went wrong';
      final launderedError = client.launderException(originalError);

      expect(launderedError, isA<SearchError>());
      final searchError = launderedError as SearchError;
      expect(searchError.cause, originalError);
      expect(searchError.error['message'], contains(originalError));
    });
  });

  group('AlgoliaExceptionExt', () {
    test('toSearchError should preserve original AlgoliaApiException', () {
      final apiException = algolia.AlgoliaApiException(
        404,
        'IndexNotFound',
      );

      final searchError = apiException.toSearchError();

      expect(searchError.statusCode, 404);
      expect(searchError.cause, apiException);
      expect(identical(searchError.cause, apiException), true);
      expect(searchError.error['message'], contains('IndexNotFound'));
    });
  });
}
