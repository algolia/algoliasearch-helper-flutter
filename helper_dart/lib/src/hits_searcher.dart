import 'dart:async';

import 'package:logging/logging.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';

import 'disposable.dart';
import 'disposable_mixin.dart';
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
      _HitsSearcher(
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
      _HitsSearcher(
        applicationID: applicationID,
        apiKey: apiKey,
        state: state,
        disjunctiveFacetingEnabled: disjunctiveFacetingEnabled,
        debounce: debounce,
      );

  /// Creates [HitsSearcher] using a custom [HitsSearchService].
  @internal
  factory HitsSearcher.custom(
    HitsSearchService searchService,
    SearchState state, [
    Duration debounce = const Duration(milliseconds: 100),
  ]) =>
      _HitsSearcher.create(searchService, state, debounce);

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

/// Algolia helpers main entry point.
///
/// This implementation has the following behavior:
///
/// 1. Distinct state changes (including initial state) trigger search operation
/// 2. State changes are debounced
class _HitsSearcher with DisposableMixin implements HitsSearcher {
  /// HitsSearcher's factory.
  factory _HitsSearcher({
    required String applicationID,
    required String apiKey,
    required SearchState state,
    bool disjunctiveFacetingEnabled = true,
    Duration debounce = const Duration(milliseconds: 100),
  }) {
    final service = AlgoliaSearchService(
      applicationID: applicationID,
      apiKey: apiKey,
      extraUserAgents: ['algolia-helper-dart (0.2.0)'],
      disjunctiveFacetingEnabled: disjunctiveFacetingEnabled,
    );
    return _HitsSearcher.create(service, state, debounce);
  }

  /// HitSearcher's constructor, for internal and test use only.
  _HitsSearcher.create(
    HitsSearchService searchService,
    SearchState state, [
    Duration debounce = const Duration(milliseconds: 100),
  ]) : this._(searchService, BehaviorSubject.seeded(state), debounce);

  /// HitsSearcher's private constructor
  _HitsSearcher._(this.searchService, this._state, this.debounce) {
    _subscription = _responses.connect();
  }

  /// Search state stream
  @override
  Stream<SearchState> get state => _state.stream;

  /// Search results stream
  @override
  Stream<SearchResponse> get responses => _responses;

  /// Service handling search requests
  final HitsSearchService searchService;

  /// Search state debounce duration
  final Duration debounce;

  /// Search state subject
  final BehaviorSubject<SearchState> _state;

  /// Search responses subject
  late final _responses = _state.stream
      .debounceTime(debounce)
      .distinct()
      .switchMap((state) => Stream.fromFuture(searchService.search(state)))
      .publish();

  /// Events logger
  final Logger _log = algoliaLogger('HitsSearcher');

  /// Subscriptions composite
  late final StreamSubscription _subscription;

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
    if (_state.isClosed) {
      _log.warning('modifying disposed instance');
      return;
    }
    final current = _state.value;
    final newState = apply(current);
    _state.sink.add(newState);
  }

  @override
  void doDispose() {
    _log.fine('HitsSearcher disposed');
    _state.close();
    _subscription.cancel();
  }
}
