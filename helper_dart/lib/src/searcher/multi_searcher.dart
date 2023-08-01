import 'dart:async';

import 'package:algolia_insights/algolia_insights.dart';
import 'package:rxdart/rxdart.dart';

import '../disposable.dart';
import '../model/multi_search_response.dart';
import '../model/multi_search_state.dart';
import '../service/algolia_multi_search_service.dart';
import '../service/multi_search_service.dart';
import '../service/proxy_facet_search_service.dart';
import '../service/proxy_hits_search_service.dart';
import 'facet_searcher.dart';
import 'hits_searcher.dart';

/// Core component for multi-search requests and managing search sessions in
/// Algolia Helpers.
///
/// The [MultiSearcher] enables you to search for hits and facet values in
/// different indices of the same Algolia application simultaneously. You can
/// add multiple [HitsSearcher] and [FacetSearcher] instances to the
/// [MultiSearcher], each targeting different indices or facets,
///
/// ## Create MultiSearcher
///
/// Instantiate [MultiSearcher] using the constructor:
///
/// ```dart
/// final multiSearcher = MultiSearcher(
///   _service,
///   _eventTracker,
/// );
/// ```
///
/// Or, use the `algolia` named constructor to create a [MultiSearcher] with
/// Algolia as the search service:
///
/// ```dart
/// final multiSearcher = MultiSearcher.algolia(
///   'MY_APPLICATION_ID',
///   'MY_API_KEY',
///   eventTracker: Insights('MY_APPLICATION_ID', 'MY_API_KEY'),
/// );
/// ```
///
/// ## Add Searchers
///
/// You can add [HitsSearcher] or [FacetSearcher] instances to the
/// [MultiSearcher] using the provided methods:
///
/// - For [HitsSearcher], use `addHitsSearcher`:
///
/// ```dart
/// final hitsSearcher = multiSearcher.addHitsSearcher(
///   initialState: SearchState(indexName: 'MY_INDEX_NAME'),
/// );
/// ```
///
/// - For [FacetSearcher], use `addFacetSearcher`:
///
/// ```dart
/// final facetSearcher = multiSearcher.addFacetSearcher(
///   state: SearchState(indexName: 'MY_INDEX_NAME'),
///   facet: 'category',
///   facetQuery: 'shoes',
/// );
/// ```
///
/// ## Dispose
///
/// Call [dispose] to release underlying resources:
///
/// ```dart
/// multiSearcher.dispose();
/// ```
class MultiSearcher implements Disposable {
  final MultiSearchService _service;
  final EventTracker _eventTracker;
  final List<MultiSearcherDelegate> _delegates;
  StreamSubscription<List<MultiSearchResponse>>? _resultsSubscription;
  bool _isDisposed = false;

  /// Creates a new instance of [MultiSearcher].
  ///
  /// - `service`: The [MultiSearchService] to handle multi-search operations.
  /// - `eventTracker`: The [EventTracker] to track events during search
  /// operations.
  MultiSearcher(this._service, this._eventTracker) : _delegates = [];

  /// Creates a new instance of [MultiSearcher] using Algolia as the search
  /// service.
  ///
  /// - `applicationID`: The Algolia Application ID for your Algolia account.
  /// - `apiKey`: The Algolia API Key associated with your Algolia account.
  /// - `eventTracker`: (optional) The [EventTracker] to track events during
  /// search operations. If not provided, an [Insights] instance will be used by
  /// default.
  MultiSearcher.algolia(
    String applicationID,
    String apiKey, {
    EventTracker? eventTracker,
  })  : _service = AlgoliaMultiSearchService(applicationID, apiKey),
        _eventTracker = eventTracker ?? Insights(applicationID, apiKey),
        _delegates = [];

  /// Adds a new [HitsSearcher] to the multi-searcher.
  ///
  /// Returns the created [HitsSearcher] instance.
  HitsSearcher addHitsSearcher({
    required SearchState initialState,
  }) {
    final service = ProxyHitsSearchService();
    final searcher = HitsSearcher.custom(
      service,
      _eventTracker,
      initialState,
    );
    _addDelegate(service);
    _updateSubscriptions();
    return searcher;
  }

  /// Adds a new [FacetSearcher] to the multi-searcher.
  ///
  /// Returns the created [FacetSearcher] instance.
  FacetSearcher addFacetSearcher({
    required SearchState state,
    required String facet,
    String facetQuery = '',
  }) {
    final service = ProxyFacetSearchService();
    final searcher = FacetSearcher.custom(
      service,
      FacetSearchState(
        searchState: state,
        facet: facet,
        facetQuery: facetQuery,
      ),
    );
    _addDelegate(service);
    return searcher;
  }

  void _addDelegate(MultiSearcherDelegate delegate) {
    _delegates.add(delegate);
    _updateSubscriptions();
  }

  void _updateSubscriptions() {
    _resultsSubscription?.cancel();
    _resultsSubscription = Rx.combineLatest(
      _delegates.map((e) => e.multiSearchState),
      (states) => states.cast<MultiSearchState>(),
    )
        .debounceTime(
          const Duration(milliseconds: 100),
        )
        .asyncMap(_service.search)
        .listen((responses) {
      for (var i = 0; i < responses.length; i++) {
        _delegates[i].updateResponse(responses[i]);
      }
    });
  }

  @override
  void dispose() {
    _resultsSubscription?.cancel();
    _isDisposed = true;
    for (var delegate in _delegates) {
      delegate.dispose();
    }
  }

  @override
  bool get isDisposed => _isDisposed;
}

abstract class MultiSearcherDelegate implements Disposable {
  final _stateStream = BehaviorSubject<MultiSearchState>();
  final _responseStream = BehaviorSubject<MultiSearchResponse>();
  bool _isDisposed = false;

  Stream<MultiSearchResponse> get response => _responseStream.stream;

  void updateState(MultiSearchState state) {
    _stateStream.add(state);
  }

  void updateResponse(MultiSearchResponse response) {
    _responseStream.add(response);
  }

  Stream<MultiSearchState> get multiSearchState =>
      _stateStream.map((state) => state);

  @override
  bool get isDisposed => _isDisposed;

  @override
  void dispose() {
    _isDisposed = true;
    _stateStream.close();
    _responseStream.close();
  }
}
