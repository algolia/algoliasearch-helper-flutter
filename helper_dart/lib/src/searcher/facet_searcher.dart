import 'package:logging/logging.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';

import '../disposable.dart';
import '../disposable_mixin.dart';
import '../logger.dart';
import '../model/multi_search_response.dart';
import '../model/multi_search_state.dart';
import '../model/multi_search_state_provider.dart';
import '../model/search_request.dart';
import '../service/algolia_facet_search_service.dart';
import '../service/facet_search_service.dart';

abstract class FacetSearcher implements Disposable, MultiSearchStateProvider {
  /// FacetSearcher's factory.
  factory FacetSearcher({
    required String applicationID,
    required String apiKey,
    required String indexName,
    required String facet,
    Duration debounce = const Duration(milliseconds: 100),
  }) =>
      _FacetSearcher(
        applicationID: applicationID,
        apiKey: apiKey,
        state: FacetSearchState(
          searchState: SearchState(indexName: indexName),
          facet: facet,
        ),
        debounce: debounce,
      );

  /// HitsSearcher's factory.
  factory FacetSearcher.create({
    required String applicationID,
    required String apiKey,
    required FacetSearchState state,
    Duration debounce = const Duration(milliseconds: 100),
  }) =>
      _FacetSearcher(
        applicationID: applicationID,
        apiKey: apiKey,
        state: state,
        debounce: debounce,
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

class _FacetSearcher with DisposableMixin implements FacetSearcher {
  /// FacetSearcher's factory.
  factory _FacetSearcher({
    required String applicationID,
    required String apiKey,
    required FacetSearchState state,
    Duration debounce = const Duration(milliseconds: 100),
  }) {
    final service = AlgoliaFacetSearchService(
      applicationID: applicationID,
      apiKey: apiKey,
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
    _subscriptions.cancel();
  }

  @override
  Stream<MultiSearchState> get multiSearchState => state;
}
