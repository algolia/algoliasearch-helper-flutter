import 'dart:async';

import 'package:logging/logging.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';

import 'disposable.dart';
import 'disposable_mixin.dart';
import 'filter_state.dart';
import 'hits_searcher_service.dart';
import 'logger.dart';
import 'search_request.dart';
import 'search_response.dart';
import 'search_state.dart';

/// Algolia Helpers main entry point, the component handling search requests
/// and managing search sessions.
///
/// [HitsSearcher] component has the following behavior:
///
/// 1. Distinct state changes (including initial state) trigger search operation
/// 2. State changes are debounced
/// 3. On new search request, previous ongoing search calls are cancelled
///
/// ## Create Hits Searcher
///
/// Instantiate [HitsSearcher] using default constructor:
///
/// ```dart
/// final hitsSearcher = HitsSearcher(
///   applicationID: 'MY_APPLICATION_ID',
///   apiKey: 'MY_API_KEY',
///   indexName: 'MY_INDEX_NAME',
/// );
/// ```
/// Or, using [HitsSearcher.create] factory:
///
/// ```dart
/// final hitsSearcher = HitsSearcher.create(
///   applicationID: 'MY_APPLICATION_ID',
///   apiKey: 'MY_API_KEY',
///   state: const SearchState(indexName: 'MY_INDEX_NAME', query: 'shoes'),
/// );
/// ```
///
/// ## Run search requests
///
/// Execute search queries using [query] method:
///
/// ```dart
/// hitsSearcher.query('book');
/// ```
///
/// Or, using [applyState] for more parameters:
///
/// ```dart
/// hitsSearcher.applyState((state) => state.copyWith(query: 'book', page: 0));
/// ```
///
/// ## Get search state
///
/// Listen to [state] to get search state changes:
///
/// ```dart
/// hitsSearcher.state.listen((searchState) => print(searchState.query));
/// ```
///
/// ## Get search results
///
/// Listen to [responses] to get search responses:
///
/// ```dart
/// hitsSearcher.responses.listen((response) {
///   print('${response.nbHits} hits found');
///   for (var hit in response.hits) {
///     print("> ${hit['objectID']}");
///   }
/// });
/// ```
///
/// Use [snapshot] to get the latest search response value submitted
/// by [responses] stream:
///
/// ```dart
/// var response = hitsSearcher.snapshot();
/// ```
///
/// ## Dispose
///
/// Call [dispose] to release underlying resources:
///
/// ```dart
/// hitsSearcher.dispose();
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

  /// Re-run the last search query
  void rerun();
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

/// Default implementation of [HitsSearcher].
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
      disjunctiveFacetingEnabled: disjunctiveFacetingEnabled,
    );
    return _HitsSearcher.create(service, state, debounce);
  }

  /// HitSearcher's constructor, for internal and test use only.
  _HitsSearcher.create(
    HitsSearchService searchService,
    SearchState state, [
    Duration debounce = const Duration(milliseconds: 100),
  ]) : this._(
          searchService,
          BehaviorSubject.seeded(SearchRequest(state)),
          debounce,
        );

  /// HitsSearcher's private constructor
  _HitsSearcher._(this.searchService, this._request, this.debounce) {
    _subscription = _responses.connect();
  }

  /// Search state stream
  @override
  Stream<SearchState> get state =>
      _request.stream.map((request) => request.state);

  /// Search results stream
  @override
  Stream<SearchResponse> get responses => _responses;

  /// Service handling search requests
  final HitsSearchService searchService;

  /// Search state debounce duration
  final Duration debounce;

  /// Search state subject
  final BehaviorSubject<SearchRequest> _request;

  /// Search responses subject
  late final _responses = _request.stream
      .debounceTime(debounce)
      .distinct()
      .switchMap((req) => Stream.fromFuture(searchService.search(req.state)))
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
  SearchState snapshot() => _request.value.state;

  /// Apply search state configuration.
  @override
  void applyState(SearchState Function(SearchState state) config) {
    _updateState((state) => config(state));
  }

  /// Apply changes to the current state
  void _updateState(SearchState Function(SearchState state) apply) {
    if (_request.isClosed) {
      _log.warning('modifying disposed instance');
      return;
    }
    final current = _request.value;
    final newState = apply(current.state);
    _request.sink.add(SearchRequest(newState));
  }

  @override
  void rerun() {
    final current = _request.value;
    final request = current.copyWith(
      state: current.state,
      attempts: current.attempts + 1,
    );
    _log.fine('Rerun request: $request');
    _request.sink.add(request);
  }

  @override
  void doDispose() {
    _log.fine('HitsSearcher disposed');
    _request.close();
    _subscription.cancel();
  }
}
