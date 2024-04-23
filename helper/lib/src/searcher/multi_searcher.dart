import 'dart:async';

import 'package:algolia_insights/algolia_insights.dart';
import 'package:logging/logging.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';

import '../client_options.dart';
import '../disposable.dart';
import '../disposable_mixin.dart';
import '../logger.dart';
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
/// The [MultiSearcher] lets you simultaneously search for hits and facet values
/// in different indices of the same Algolia application .
/// It instantiates and manages [HitsSearcher] and [FacetSearcher] instances
/// internally. Once created, these searchers behave like their independently
/// instantiated counterparts.
///
///
/// ## Create MultiSearcher
///
/// Instantiate [MultiSearcher] using the constructor:
///
/// ```dart
/// final multiSearcher = MultiSearcher(
///   applicationID: 'MY_APPLICATION_ID',
///   apiKey: 'MY_API_KEY',
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
///   initialState: const SearchState(indexName: 'MY_INDEX_NAME'),
/// );
/// ```
///
/// - For [FacetSearcher], use `addFacetSearcher`:
///
/// ```dart
/// final facetSearcher = multiSearcher.addFacetSearcher(
///   initialState: const FacetSearchState(
///     facet: 'category',
///     facetQuery: 'shoes',
///     searchState: SearchState(
///       indexName: 'MY_INDEX_NAME',
///     ),
///   )
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
abstract interface class MultiSearcher implements Disposable {
  /// Creates a new instance of [MultiSearcher] using Algolia as the search
  /// service.
  ///
  /// - `applicationID`: The Algolia Application ID for your Algolia account.
  /// - `apiKey`: The Algolia API Key associated with your Algolia account.
  /// - `eventTracker`: (optional) The [EventTracker] to track events during
  /// search operations. If not provided, an [Insights] instance will be used by
  /// default.
  /// - `debounce`: The time duration to wait before sending a search request.
  /// Defaults to 100 milliseconds.
  factory MultiSearcher({
    required String applicationID,
    required String apiKey,
    EventTracker? eventTracker,
    Duration debounce = const Duration(milliseconds: 100),
    ClientOptions? options,
  }) =>
      _MultiSearcher(
        applicationID: applicationID,
        apiKey: apiKey,
        eventTracker: eventTracker,
        debounce: debounce,
        options: options,
      );

  /// Creates [MultiSearcher] using a custom [MultiSearchService] and
  /// [EventTracker].
  ///
  /// - `service`: The [MultiSearchService] to handle multi-search operations.
  /// - `eventTracker`: The [EventTracker] to track events during search
  /// operations.
  /// - `debounce`: The time duration to wait before sending a search request.
  /// Defaults to 100 milliseconds.
  @internal
  factory MultiSearcher.custom(
    MultiSearchService searchService,
    EventTracker eventTracker, [
    Duration debounce = const Duration(milliseconds: 100),
  ]) =>
      _MultiSearcher.create(
        searchService,
        eventTracker,
        debounce,
      );

  /// Adds a new [HitsSearcher] to the multi-searcher.
  ///
  /// Returns the created [HitsSearcher] instance.
  HitsSearcher addHitsSearcher({
    required SearchState initialState,
  });

  /// Adds a new [FacetSearcher] to the multi-searcher.
  ///
  /// Returns the created [FacetSearcher] instance.
  FacetSearcher addFacetSearcher({
    required FacetSearchState initialState,
  });
}

/// `_MultiSearcher` handles the actual operations and business logic behind
/// the interface, ensuring encapsulation and separation of concerns.
class _MultiSearcher with DisposableMixin implements MultiSearcher {
  /// MultiSearcher's factory.
  factory _MultiSearcher({
    required String applicationID,
    required String apiKey,
    EventTracker? eventTracker,
    Duration debounce = const Duration(milliseconds: 100),
    ClientOptions? options,
  }) {
    final service = AlgoliaMultiSearchService(
      applicationID: applicationID,
      apiKey: apiKey,
      options: options,
    );
    final actualEventTracker = eventTracker ??
        Insights(
          applicationID: applicationID,
          apiKey: apiKey,
        );
    return _MultiSearcher.create(
      service,
      actualEventTracker,
      debounce,
    );
  }

  /// HitSearcher's constructor, for internal and test use only.
  _MultiSearcher.create(
    MultiSearchService searchService,
    EventTracker eventTracker, [
    Duration debounce = const Duration(milliseconds: 100),
  ]) : this._(
          searchService,
          eventTracker,
          debounce,
          [],
          CompositeDisposable(),
        );

  _MultiSearcher._(
    this._service,
    this._eventTracker,
    this.debounce,
    this._delegates,
    this._disposables,
  );

  /// Events logger
  final Logger _log = algoliaLogger('MultiSearcher');

  /// Service handling search requests
  final MultiSearchService _service;

  /// Searchers state update debounce duration
  final Duration debounce;

  final EventTracker _eventTracker;

  final List<MultiSearcherDelegate> _delegates;

  StreamSubscription<List<MultiSearchResponse>>? _resultsSubscription;

  final CompositeDisposable _disposables;

  @override
  HitsSearcher addHitsSearcher({
    required SearchState initialState,
  }) {
    _log.finest('add hits searcher for index ${initialState.indexName}');
    final service = ProxyHitsSearchService();
    final searcher = HitsSearcher.custom(
      service,
      _eventTracker,
      initialState,
    );
    _addDelegate(service);
    return searcher;
  }

  @override
  FacetSearcher addFacetSearcher({
    required FacetSearchState initialState,
  }) {
    _log.finest(
        'add facet searcher for index ${initialState.searchState.indexName}, '
        'attribute: ${initialState.facet}');
    final service = ProxyFacetSearchService();
    final searcher = FacetSearcher.custom(
      service,
      initialState,
    );
    _addDelegate(service);
    return searcher;
  }

  void _addDelegate(MultiSearcherDelegate delegate) {
    _delegates.add(delegate);
    _disposables.add(delegate);
    _updateSubscriptions();
  }

  void _updateSubscriptions() {
    _resultsSubscription?.cancel();
    _resultsSubscription = Rx.combineLatest(
      _delegates.map((e) => e.multiSearchState),
      (states) => states,
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
  void doDispose() {
    _log.fine('MultiSearcher disposed');
    _resultsSubscription?.cancel();
    _disposables.dispose();
  }
}

/// `MultiSearcherDelegate` serves as an abstract unit within the composite
/// `MultiSearcher`. It abstracts the underlying details of individual search
/// units like `HitsSearcher` and `FacetSearcher`, focusing primarily on
/// exposing their states and providing mechanisms to update their responses.
abstract class MultiSearcherDelegate with DisposableMixin {
  /// A private stream to manage the state of the encapsulated search units.
  final _stateStream = BehaviorSubject<MultiSearchState>();

  /// A private stream to manage the responses from the encapsulated search
  /// units.
  final _responseStream = PublishSubject<MultiSearchResponse>();

  /// Provides public access to the stream of search responses.
  ///
  /// Enables subscribers to listen to and react to the search responses of the
  /// encapsulated units.
  Stream<MultiSearchResponse> get response => _responseStream.stream;

  /// Updates the state of the encapsulated search unit.
  ///
  /// - Parameters:
  ///   - `state`: The new [MultiSearchState] to set for the search unit.
  void updateState(MultiSearchState state) {
    _stateStream.add(state);
  }

  /// Updates the response of the encapsulated search unit.
  ///
  /// - Parameters:
  ///   - `response`: The new [MultiSearchResponse] to set for the search unit.
  void updateResponse(MultiSearchResponse response) {
    _responseStream.add(response);
  }

  /// Provides public access to the stream of the encapsulated search units'
  /// states. Enables subscribers to listen to and react to the state changes of
  /// the encapsulated units.
  Stream<MultiSearchState> get multiSearchState => _stateStream;

  @override
  void doDispose() {
    _stateStream.close();
    _responseStream.close();
  }
}
