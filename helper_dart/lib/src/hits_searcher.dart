import 'dart:async';

import 'package:meta/meta.dart';

import 'disposable.dart';
import 'filter_state.dart';
import 'hits_searcher_internal.dart';
import 'search_response.dart';
import 'search_state.dart';

/// Algolia helpers main entry point.
///
/// The [HitsSearcher] has the following behavior:
///
/// 1. Distinct state changes (including initial state) trigger search operation
/// 2. State changes are debounced
///
/// ## Create Hits Searcher
/// ```dart
/// final searcher = HitsSearcher(
///   applicationID: 'MY_APPLICATION_ID',
///   apiKey: 'MY_API_KEY',
///   indexName: 'MY_INDEX_NAME',
/// );
/// ```
///
/// ## Run search requests
/// ```dart
/// searcher.query('book');
/// ```
/// ```dart
/// searcher.applyState((state) => state.copyWith(query: 'book'));
/// ```
///
/// ## Get search results
/// ```dart
/// searcher.responses.listen((response) {
///   print('${response.nbHits} hits found');
///   for (var hit in response.hits) {
///     print("> ${hit['objectID']}");
///   }
/// });
/// ```
///
/// ## Dispose
/// ```dart
/// searcher.dispose();
/// ```
@sealed
abstract class HitsSearcher implements Disposable {
  /// HitsSearcher's factory.
  factory HitsSearcher({
    required String applicationID,
    required String apiKey,
    required String indexName,
    bool disjunctiveFacetingEnabled = true,
    Duration debounce = const Duration(milliseconds: 100),
  }) =>
      InternalHitsSearcher(
        applicationID: applicationID,
        apiKey: apiKey,
        state: SearchState(indexName: indexName),
        disjunctiveFacetingEnabled: disjunctiveFacetingEnabled,
        debounce: debounce,
      );

  /// HitsSearcher's factory.
  factory HitsSearcher.create({
    required String applicationID,
    required String apiKey,
    required SearchState state,
    bool disjunctiveFacetingEnabled = true,
    Duration debounce = const Duration(milliseconds: 100),
  }) =>
      InternalHitsSearcher(
        applicationID: applicationID,
        apiKey: apiKey,
        state: state,
        disjunctiveFacetingEnabled: disjunctiveFacetingEnabled,
        debounce: debounce,
      );

  /// Search state stream
  Stream<SearchState> get state;

  /// Search results stream
  Stream<SearchResponse> get responses;

  /// Set query string.
  void query(String query);

  /// Get current [SearchState].
  SearchState snapshot();

  /// Apply search state configuration.
  void applyState(SearchState Function(SearchState state) config);
}

/// Extensions over [HitsSearcher]
extension SearcherExt on HitsSearcher {
  /// Creates a connection between [HitsSearcher] and [FilterState].
  StreamSubscription connectFilterState(FilterState filterState) =>
      filterState.filters.listen(
        (filters) => applyState(
          (state) => state.copyWith(filterGroups: filters.toFilterGroups()),
        ),
      );
}
