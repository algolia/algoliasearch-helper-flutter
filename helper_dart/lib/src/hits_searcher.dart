import 'dart:async';

import 'package:algolia/algolia.dart';
import 'package:logging/logging.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';

import 'filter_state.dart';
import 'hits_searcher_service.dart';
import 'logger.dart';
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
/// ## Listen to search results
/// ````dart
/// searcher.responses.listen((response) {
///   print('${response.nbHits} hits found');
///   for (var hit in response.hits) {
///     print("> ${hit['title']}");
///   }
/// });
/// ```
///
/// ## Dispose internal resources
/// ```dart
/// searcher.dispose();
/// ```
///
abstract class HitsSearcher {
  /// HitsSearcher's factory.
  factory HitsSearcher({
    required String applicationID,
    required String apiKey,
    required String indexName,
    bool disjunctiveFacetingEnabled = true,
    Duration debounce = const Duration(milliseconds: 100),
  }) =>
      DefaultHitsSearcher(
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
      DefaultHitsSearcher(
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

  /// Dispose of underlying resources.
  void dispose();
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

/// Algolia helpers main entry point.
///
/// This implementation has the following behavior:
///
/// 1. Distinct state changes (including initial state) trigger search operation
/// 2. State changes are debounced
@visibleForTesting
class DefaultHitsSearcher implements HitsSearcher {
  /// HitsSearcher's factory.
  factory DefaultHitsSearcher({
    required String applicationID,
    required String apiKey,
    required SearchState state,
    bool disjunctiveFacetingEnabled = true,
    Duration debounce = const Duration(milliseconds: 100),
  }) {
    final client = Algolia.init(
      applicationId: applicationID,
      apiKey: apiKey,
      extraUserAgents: ['algolia-helper-dart (0.1.3)'],
    );
    final service = HitsSearchService(client, disjunctiveFacetingEnabled);
    return DefaultHitsSearcher.create(service, state, debounce);
  }

  /// HitSearcher's constructor, for internal and test use only.
  DefaultHitsSearcher.create(
    HitsSearchService searchService,
    SearchState state, [
    Duration debounce = const Duration(milliseconds: 100),
  ]) : this._(searchService, BehaviorSubject.seeded(state), debounce);

  /// HitsSearcher's private constructor
  DefaultHitsSearcher._(this.searchService, this._state, Duration debounce)
      : responses = _state.stream
            .debounceTime(debounce)
            .switchMap(searchService.search),
        _log = algoliaLogger('HitsSearcher');

  /// Search state subject
  final BehaviorSubject<SearchState> _state;

  /// Search state stream
  @override
  Stream<SearchState> get state => _state.stream;

  /// Search results stream
  @override
  final Stream<SearchResponse> responses;

  /// Service handling search requests
  final HitsSearchService searchService;

  /// Events logger
  final Logger _log;

  /// Set query string.
  @override
  void query(String query) {
    _updateState((state) => state.copyWith(query: query));
  }

  /// Get current [SearchState].
  @override
  SearchState snapshot() => _state.value;

  /// Apply search state configuration.
  @override
  void applyState(SearchState Function(SearchState state) config) {
    _updateState((state) => config(state));
  }

  /// Apply changes to the current state
  void _updateState(SearchState Function(SearchState state) apply) {
    final current = _state.value;
    final newState = apply(current);
    _state.sink.add(newState);
  }

  /// Dispose of underlying resources.
  @override
  void dispose() {
    _log.fine('helper is disposed');
    _state.close();
  }
}
