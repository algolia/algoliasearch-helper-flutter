import 'dart:async';

import 'package:algolia/algolia.dart';
import 'package:logging/logging.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';

import 'filter_state.dart';
import 'hits_searcher_service.dart';
import 'search_response.dart';
import 'search_state.dart';

/// Algolia helper main entry point.
///
/// This implementation has the following behavior:
///
/// 1. Distinct state changes (including initial state) trigger search operation
/// 2. State changes are debounced
class HitsSearcher {
  /// HitsSearcher's factory.
  /// TODO: default to true when disjunctive faceting is implemented
  factory HitsSearcher({
    required String applicationID,
    required String apiKey,
    required String indexName,
    bool disjunctiveFacetingEnabled = false,
    Duration debounce = const Duration(milliseconds: 100),
  }) =>
      HitsSearcher.create(
        applicationID: applicationID,
        apiKey: apiKey,
        state: SearchState(indexName: indexName),
        disjunctiveFacetingEnabled: disjunctiveFacetingEnabled,
        debounce: debounce,
      );

  /// HitsSearcher's factory.
  /// TODO: default to true when disjunctive faceting is implemented
  factory HitsSearcher.create({
    required String applicationID,
    required String apiKey,
    required SearchState state,
    bool disjunctiveFacetingEnabled = false,
    Duration debounce = const Duration(milliseconds: 100),
  }) {
    final client = Algolia.init(applicationId: applicationID, apiKey: apiKey);
    final service = HitsSearchService(client, disjunctiveFacetingEnabled);
    return HitsSearcher.build(service, state, debounce);
  }

  @visibleForTesting
  HitsSearcher.build(this.searchService, SearchState state, Duration debounce) {
    _state = BehaviorSubject<SearchState>.seeded(state);
    responses = _state.stream
        .debounceTime(debounce)
        .distinct()
        .asyncMap(searchService.search);
  }

  /// Inner Algolia API client.
  /// TODO: should be private
  Algolia get client => searchService.client;

  /// Search state stream
  late BehaviorSubject<SearchState> _state;

  /// Search results stream
  late Stream<SearchResponse> responses;

  /// Service handling search requests
  final HitsSearchService searchService;

  /// Events logger
  final _logger = Logger('HitsSearcher');

  /// Set query string.
  void query(String query) {
    _updateState((state) => state.copyWith(query: query));
  }

  /// Apply search state configuration.
  void applyState(SearchState Function(SearchState state) config) {
    _updateState((state) => config(state));
  }

  /// Apply changes to the current state
  void _updateState(SearchState Function(SearchState state) apply) {
    final current = _state.value;
    final newState = apply(current);
    _logger.config('State updated from $current to $newState');
    _state.sink.add(newState);
  }

  /// Dispose of underlying resources.
  void dispose() {
    _logger.fine('helper is disposed');
    _state.close();
  }
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
