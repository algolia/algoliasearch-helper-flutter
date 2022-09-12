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

/// Algolia helper main entry point.
///
/// This implementation has the following behavior:
///
/// 1. Distinct state changes (including initial state) trigger search operation
/// 2. State changes are debounced
class HitsSearcher {
  /// HitsSearcher's factory.
  factory HitsSearcher({
    required String applicationID,
    required String apiKey,
    required String indexName,
    bool disjunctiveFacetingEnabled = true,
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
  factory HitsSearcher.create({
    required String applicationID,
    required String apiKey,
    required SearchState state,
    bool disjunctiveFacetingEnabled = true,
    Duration debounce = const Duration(milliseconds: 100),
  }) {
    final client = Algolia.init(
      applicationId: applicationID,
      apiKey: apiKey,
      extraUserAgents: ['algolia-helper-dart (0.1.0)'],
    );
    final service = HitsSearchService(client, disjunctiveFacetingEnabled);
    return HitsSearcher.build(service, state, debounce);
  }

  /// HitSearcher's constructor, for internal and test use only.
  @visibleForTesting
  HitsSearcher.build(
    HitsSearchService searchService,
    SearchState state, [
    Duration debounce = const Duration(milliseconds: 100),
  ]) : this._(searchService, BehaviorSubject.seeded(state), debounce);

  /// HitsSearcher's private constructor
  HitsSearcher._(this.searchService, this._state, Duration debounce)
      : responses = _state.stream
            .debounceTime(debounce)
            .distinct()
            .switchMap(searchService.search),
        _log = algoliaLogger('HitsSearcher');

  /// Search state subject
  final BehaviorSubject<SearchState> _state;

  /// Search state stream
  Stream<SearchState> get state => _state.stream;

  /// Search results stream
  final Stream<SearchResponse> responses;

  /// Service handling search requests
  final HitsSearchService searchService;

  /// Events logger
  final Logger _log;

  /// Set query string.
  void query(String query) {
    _updateState((state) => state.copyWith(query: query));
  }

  /// Get current [SearchState].
  SearchState snapshot() => _state.value;

  /// Apply search state configuration.
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
  void dispose() {
    _log.fine('helper is disposed');
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
