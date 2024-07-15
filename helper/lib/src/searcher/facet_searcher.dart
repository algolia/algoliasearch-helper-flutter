import 'package:logging/logging.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';

import '../client_options.dart';
import '../disposable.dart';
import '../disposable_mixin.dart';
import '../logger.dart';
import '../model/multi_search_response.dart';
import '../model/multi_search_state.dart';
import '../model/search_request.dart';
import '../service/algolia_facet_search_service.dart';
import '../service/facet_search_service.dart';

/// Algolia Helpers main entry point for facet search requests and managing
/// search sessions.
///
/// [FacetSearcher] is a component that facilitates facet search operations on
/// an Algolia index. It handles distinct state changes, including the initial
/// state, to trigger facet search operations. The state changes are debounced
/// to ensure that only the last state change triggers the search operation.
/// Additionally, on new facet search requests, any ongoing search calls for
/// the previous request are cancelled, allowing only the latest facet search
/// results to be processed.
///
/// ## Create Facet Searcher
///
/// Instantiate [FacetSearcher] using the default constructor:
///
/// ```dart
/// final facetSearcher = FacetSearcher(
///   applicationID: 'MY_APPLICATION_ID',
///   apiKey: 'MY_API_KEY',
///   indexName: 'MY_INDEX_NAME',
///   facet: 'MY_FACET_ATTRIBUTE',
/// );
/// ```
///
/// Or, using the [FacetSearcher.create] factory:
///
/// ```dart
/// final facetSearcher = FacetSearcher.create(
///   applicationID: 'MY_APPLICATION_ID',
///   apiKey: 'MY_API_KEY',
///   state: FacetSearchState(
///     searchState: SearchState(indexName: 'MY_INDEX_NAME'),
///     facet: 'MY_FACET_ATTRIBUTE',
///   ),
/// );
/// ```
///
/// ## Run facet search queries
///
/// Execute facet search queries using the [query] method:
///
/// ```dart
/// facetSearcher.query('book');
/// ```
///
/// Or, use the [applyState] method for more parameters:
///
/// ```dart
/// facetSearcher.applyState((state) => state.copyWith(query: 'book'));
/// ```
///
/// ## Get facet search state
///
/// Listen to the [state] stream to get facet search state changes:
///
/// ```dart
/// facetSearcher.state.listen((facetSearchState) =>
/// print(facetSearchState.query));
/// ```
///
/// ## Get facet search results
///
/// Listen to the [responses] stream to get facet search responses:
///
/// ```dart
/// facetSearcher.responses.listen((response) {
///   print('${response.nbHits} hits found');
///   for (var hit in response.hits) {
///     print("> ${hit['objectID']}");
///   }
/// });
/// ```
///
/// Use [snapshot] to get the latest facet search response value submitted
/// by the [responses] stream:
///
/// ```dart
/// var response = facetSearcher.snapshot();
/// ```
///
/// ## Dispose
///
/// Call [dispose] to release underlying resources:
///
/// ```dart
/// facetSearcher.dispose();
/// ```
abstract interface class FacetSearcher implements Disposable {
  /// FacetSearcher's factory.
  factory FacetSearcher({
    required String applicationID,
    required String apiKey,
    required String indexName,
    required String facet,
    Duration debounce = const Duration(milliseconds: 100),
    ClientOptions? options,
  }) =>
      _FacetSearcher(
        applicationID: applicationID,
        apiKey: apiKey,
        state: FacetSearchState(
          searchState: SearchState(indexName: indexName),
          facet: facet,
        ),
        debounce: debounce,
        options: options,
      );

  /// HitsSearcher's factory.
  factory FacetSearcher.create({
    required String applicationID,
    required String apiKey,
    required FacetSearchState state,
    Duration debounce = const Duration(milliseconds: 100),
    ClientOptions? options,
  }) =>
      _FacetSearcher(
        applicationID: applicationID,
        apiKey: apiKey,
        state: state,
        debounce: debounce,
        options: options,
      );

  /// Creates [FacetSearcher] using a custom [FacetSearchService].
  @internal
  factory FacetSearcher.custom(
    FacetSearchService service,
    FacetSearchState state, [
    Duration debounce = const Duration(milliseconds: 100),
  ]) =>
      _FacetSearcher.create(service, state, debounce);

  /// Search state stream
  Stream<FacetSearchState> get state;

  /// Search results stream
  Stream<FacetSearchResponse> get responses;

  /// Set query string.
  void query(String query);

  /// Get current [FacetSearchState].
  FacetSearchState snapshot();

  /// Get latest [FacetSearchResponse].
  FacetSearchResponse? get lastResponse;

  /// Apply search state configuration.
  void applyState(FacetSearchState Function(FacetSearchState state) config);

  /// Re-run the last search query
  void rerun();
}

/// Default implementation of [FacetSearcher].
class _FacetSearcher with DisposableMixin implements FacetSearcher {
  /// FacetSearcher's factory.
  factory _FacetSearcher({
    required String applicationID,
    required String apiKey,
    required FacetSearchState state,
    Duration debounce = const Duration(milliseconds: 100),
    ClientOptions? options,
  }) {
    final service = AlgoliaFacetSearchService(
      applicationID: applicationID,
      apiKey: apiKey,
      options: options,
    );
    return _FacetSearcher.create(
      service,
      state,
      debounce,
    );
  }

  /// FacetSearcher's constructor, for internal and test use only.
  _FacetSearcher.create(
    FacetSearchService searchService,
    FacetSearchState state, [
    Duration debounce = const Duration(milliseconds: 100),
  ]) : this._(
          searchService,
          BehaviorSubject.seeded(SearchRequest(state)),
          debounce,
        );

  /// FacetSearcher's private constructor
  _FacetSearcher._(
    this.searchService,
    this._request,
    this.debounce,
  ) {
    _subscriptions.add(_responses.connect());
  }

  /// Search state stream
  @override
  Stream<FacetSearchState> get state =>
      _request.stream.map((request) => request.state);

  /// Search results stream
  @override
  Stream<FacetSearchResponse> get responses => _responses;

  /// Service handling search requests
  final FacetSearchService searchService;

  /// Search state debounce duration
  final Duration debounce;

  /// Search state subject
  final BehaviorSubject<SearchRequest<FacetSearchState>> _request;

  /// Search responses subject
  late final _responses = _request.stream
      .debounceTime(debounce)
      .distinct()
      .switchMap((req) => Stream.fromFuture(searchService.search(req.state)))
      .doOnData((value) {
    lastResponse = value;
  }).publish();

  /// Events logger
  final Logger _log = algoliaLogger('FacetSearcher');

  /// Streams subscriptions composite.
  final CompositeSubscription _subscriptions = CompositeSubscription();

  @override
  void query(String query) {
    applyState((state) => state.copyWith(facetQuery: query));
  }

  @override
  FacetSearchState snapshot() => _request.value.state;

  /// Get latest search response
  @override
  FacetSearchResponse? lastResponse;

  /// Apply search state configuration.
  @override
  void applyState(FacetSearchState Function(FacetSearchState state) config) {
    _updateState((state) => config(state));
  }

  /// Apply changes to the current state
  void _updateState(FacetSearchState Function(FacetSearchState state) apply) {
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
    _log.fine('FacetSearcher disposed');
    _request.close();
    _subscriptions.dispose();
  }
}
