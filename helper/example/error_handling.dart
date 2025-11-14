// ignore_for_file: avoid_print

import 'package:algolia_helper_flutter/algolia_helper_flutter.dart';
import 'package:algoliasearch/algoliasearch.dart' as algolia;

/// Example demonstrating how to handle exceptions with the new `cause` field.
///
/// The `SearchError.cause` field preserves the original exception, allowing
/// developers to implement type-specific error handling and access detailed
/// error information.
void main() async {
  // Initialize the search client (use your own credentials)
  final searcher = HitsSearcher(
    applicationID: 'YOUR_APP_ID',
    apiKey: 'YOUR_API_KEY',
    indexName: 'products',
  );

  // Example 1: Catching SearchError and accessing the original cause
  searcher.responses.listen(
    (response) {
      print('Search successful: ${response.hits.length} hits');
    },
    onError: (error) {
      if (error is SearchError) {
        print('Status code: ${error.statusCode}');
        print('Error details: ${error.error}');

        // Access the original exception via the cause field
        if (error.cause != null) {
          print('Original cause: ${error.cause.runtimeType}');

          // Handle specific exception types
          if (error.cause is algolia.AlgoliaApiException) {
            final apiException = error.cause as algolia.AlgoliaApiException;
            print('API Error: ${apiException.error}');
            print('Status code from original: ${apiException.statusCode}');

            // Implement specific handling based on status code
            switch (apiException.statusCode) {
              case 401:
                print('Authentication error - check your API key');
                break;
              case 404:
                print('Index not found - check your index name');
                break;
              case 429:
                print('Rate limit exceeded - slow down requests');
                break;
              default:
                print('Other API error occurred');
            }
          } else if (error.cause is Exception) {
            final exception = error.cause as Exception;
            print('Generic exception: $exception');
          }
        }
      } else {
        print('Unexpected error: $error');
      }
    },
  );

  // Example 2: Try-catch pattern with detailed error handling
  try {
    final response = await searcher.search('query');
    print('Found ${response.hits.length} results');
  } on SearchError catch (error) {
    // Handle SearchError specifically
    print('Search failed with status ${error.statusCode}');

    // Check if it's a network error by examining the cause
    if (error.cause is algolia.AlgoliaApiException) {
      final apiError = error.cause as algolia.AlgoliaApiException;
      if (apiError.statusCode >= 500) {
        print('Server error - retry later');
      } else if (apiError.statusCode >= 400) {
        print('Client error - check request parameters');
      }
    }

    // You can also implement custom retry logic based on the cause
    if (shouldRetry(error)) {
      print('Retrying...');
      // Implement retry logic
    }
  } catch (error) {
    print('Unexpected error: $error');
  }

  searcher.dispose();
}

/// Example function to determine if an error should be retried
/// based on the original cause.
bool shouldRetry(SearchError error) {
  // Don't retry authentication errors
  if (error.statusCode == 401 || error.statusCode == 403) {
    return false;
  }

  // Retry server errors and timeouts
  if (error.statusCode >= 500) {
    return true;
  }

  // Check the original cause for network issues
  if (error.cause != null) {
    final causeString = error.cause.toString().toLowerCase();
    if (causeString.contains('timeout') ||
        causeString.contains('network') ||
        causeString.contains('connection')) {
      return true;
    }
  }

  return false;
}
