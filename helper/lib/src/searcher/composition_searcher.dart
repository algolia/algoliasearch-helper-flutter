import 'dart:async';

import 'package:algolia_insights/algolia_insights.dart';
import 'package:logging/logging.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';

import '../client_options.dart';
import '../disposable.dart';
import '../disposable_mixin.dart';
import '../filter_state.dart';
import '../logger.dart';
import '../model/composition_response.dart';
import '../model/composition_state.dart';
import '../service/algolia_composition_search_service.dart';
import '../service/composition_search_service.dart';

/// Algolia Helpers entry point for running an Algolia
/// [Composition](https://www.algolia.com/doc/guides/building-search-ui/going-further/composition/what-is-composition/js/),
/// the component handling composition run requests and managing search
/// sessions.
///
/// [CompositionSearcher] targets a single composition identified by its
/// `compositionID` and has the following behavior:
///
/// 1. Distinct state changes (including initial state) trigger a run operation
/// 2. State changes are debounced
/// 3. On new run request, previous ongoing calls are cancelled
///
/// ## Create Composition Searcher
///
/// Instantiate [CompositionSearcher] using the default constructor:
///
/// ```dart
/// final compositionSearcher = CompositionSearcher(
///   applicationID: 'MY_APPLICATION_ID',
///   apiKey: 'MY_API_KEY',
///   compositionID: 'MY_COMPOSITION_ID',
/// );
/// ```
///
/// Or, using the [CompositionSearcher.create] factory:
///
/// ```dart
/// final compositionSearcher = CompositionSearcher.create(
///   applicationID: 'MY_APPLICATION_ID',
///   apiKey: 'MY_API_KEY',
///   state: const CompositionState(
///     compositionID: 'MY_COMPOSITION_ID',
///     query: 'shoes',
///   ),
/// );
/// ```
///
/// ## Run composition requests
///
/// Execute run queries using the [query] method:
///
/// ```dart
/// compositionSearcher.query('book');
/// ```
///
/// Or, use [applyState] for more parameters:
///
/// ```dart
/// compositionSearcher.applyState((state) =>
///     state.copyWith(query: 'book', page: 0));
/// ```
///
/// ## Get search results
///
/// Listen to [responses] to get composition responses:
///
/// ```dart
/// compositionSearcher.responses.listen((response) {
///   print('${response.nbHits} hits found');
///   for (var hit in response.hits) {
///     print("> ${hit['objectID']}");
///   }
/// });
/// ```
///
/// ## Dispose
///
/// Call [dispose] to release underlying resources:
///
/// ```dart
/// compositionSearcher.dispose();
/// ```
abstract interface class CompositionSearcher
    implements Disposable, EventDataDelegate {
  /// CompositionSearcher's factory.
  factory CompositionSearcher({
    required String applicationID,
    required String apiKey,
    required String compositionID,
    Duration debounce = const Duration(milliseconds: 100),
    bool insights = false,
    ClientOptions? options,
  }) =>
      _CompositionSearcher(
        applicationID: applicationID,
        apiKey: apiKey,
        state: CompositionState(
          compositionID: compositionID,
          clickAnalytics: true,
        ),
        debounce: debounce,
        insights: insights,
        options: options,
      );

  /// CompositionSearcher's factory.
  factory CompositionSearcher.create({
    required String applicationID,
    required String apiKey,
    required CompositionState state,
    Duration debounce = const Duration(milliseconds: 100),
    bool insights = false,
    ClientOptions? options,
  }) =>
      _CompositionSearcher(
        applicationID: applicationID,
        apiKey: apiKey,
        state: state.copyWith(clickAnalytics: true),
        debounce: debounce,
        insights: insights,
        options: options,
      );

  /// Creates [CompositionSearcher] using a custom [CompositionSearchService].
  @internal
  factory CompositionSearcher.custom(
    CompositionSearchService searchService,
    EventTracker? eventTracker,
    CompositionState state, [
    Duration debounce = const Duration(milliseconds: 100),
  ]) =>
      _CompositionSearcher.create(
        searchService,
        eventTracker,
        state,
        debounce,
      );

  /// Composition events tracker.
  HitsEventTracker? get eventTracker;

  /// Composition state stream
  Stream<CompositionState> get state;

  /// Composition results stream
  Stream<CompositionResponse> get responses;

  /// Set query string.
  void query(String query);

  /// Get current [CompositionState].
  CompositionState snapshot();

  /// Get latest [CompositionResponse].
  CompositionResponse? get lastResponse;

  /// Apply composition state configuration.
  void applyState(CompositionState Function(CompositionState state) config);

  /// Re-run the last composition query
  void rerun();
}

/// Extensions over [CompositionSearcher]
extension CompositionSearcherExt on CompositionSearcher {
  /// Creates a connection between [CompositionSearcher] and [FilterState].
  StreamSubscription connectFilterState(FilterState filterState) =>
      filterState.filters.listen(
        (filters) => applyState(
          (state) => state.copyWith(filterGroups: filters.toFilterGroups()),
        ),
      );
}

/// Internal request wrapper allowing [rerun] to force a distinct emission.
@immutable
class _CompositionRequest {
  const _CompositionRequest(this.state, [this.attempts = 1]);

  final CompositionState state;
  final int attempts;

  _CompositionRequest copyWith({CompositionState? state, int? attempts}) =>
      _CompositionRequest(state ?? this.state, attempts ?? this.attempts);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _CompositionRequest &&
          runtimeType == other.runtimeType &&
          state == other.state &&
          attempts == other.attempts;

  @override
  int get hashCode => state.hashCode ^ attempts.hashCode;
}

/// Default implementation of [CompositionSearcher].
final class _CompositionSearcher
    with DisposableMixin
    implements CompositionSearcher {
  /// CompositionSearcher's factory.
  factory _CompositionSearcher({
    required String applicationID,
    required String apiKey,
    required CompositionState state,
    Duration debounce = const Duration(milliseconds: 100),
    bool insights = false,
    ClientOptions? options,
  }) {
    final service = AlgoliaCompositionSearchService(
      applicationID: applicationID,
      apiKey: apiKey,
      options: options,
    );

    EventTracker? eventTracker;
    if (insights) {
      eventTracker = Insights(
        applicationID: applicationID,
        apiKey: apiKey,
      );
    }

    return _CompositionSearcher.create(
      service,
      eventTracker,
      state,
      debounce,
    );
  }

  /// CompositionSearcher's constructor, for internal and test use only.
  _CompositionSearcher.create(
    CompositionSearchService searchService,
    EventTracker? eventTracker,
    CompositionState state, [
    Duration debounce = const Duration(milliseconds: 100),
  ]) : this._(
          searchService,
          eventTracker,
          BehaviorSubject.seeded(_CompositionRequest(state)),
          debounce,
        );

  /// CompositionSearcher's private constructor
  _CompositionSearcher._(
    this.searchService,
    EventTracker? eventTracker,
    this._request,
    this.debounce,
  ) {
    if (eventTracker != null) {
      this.eventTracker = HitsEventTracker(eventTracker, this);
    }
    _subscriptions.add(_responses.connect());
  }

  /// Composition state stream
  @override
  Stream<CompositionState> get state =>
      _request.stream.map((request) => request.state);

  /// Composition results stream
  @override
  Stream<CompositionResponse> get responses => _responses;

  /// Service handling composition run requests
  final CompositionSearchService searchService;

  @override
  HitsEventTracker? eventTracker;

  /// Composition state debounce duration
  final Duration debounce;

  /// Composition state subject
  final BehaviorSubject<_CompositionRequest> _request;

  /// Composition responses subject
  late final _responses = _request.stream
      .debounceTime(debounce)
      .distinct()
      .switchMap((req) => Stream.fromFuture(searchService.search(req.state)))
      .doOnData((value) {
    lastResponse = value;
    eventTracker?.viewedObjects(
      eventName: 'Hits Viewed',
      objectIDs: value.hits.map((hit) => hit['objectID'].toString()).toList(),
    );
  }).publish();

  /// Events logger
  final Logger _log = algoliaLogger('CompositionSearcher');

  /// Streams subscriptions composite.
  final CompositeSubscription _subscriptions = CompositeSubscription();

  /// Set query string.
  @override
  void query(String query) {
    _updateState((state) => state.copyWith(query: query));
  }

  /// Get current [CompositionState].
  @override
  CompositionState snapshot() => _request.value.state;

  /// Get latest composition response
  @override
  CompositionResponse? lastResponse;

  /// Apply composition state configuration.
  @override
  void applyState(CompositionState Function(CompositionState state) config) {
    _updateState((state) => config(state));
  }

  /// Apply changes to the current state
  void _updateState(CompositionState Function(CompositionState state) apply) {
    if (_request.isClosed) {
      _log.warning('modifying disposed instance');
      return;
    }
    final current = _request.value;
    final newState = apply(current.state);
    _request.sink.add(_CompositionRequest(newState));
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
    _log.fine('CompositionSearcher disposed');
    _request.close();
    _subscriptions.dispose();
  }

  @override
  String get indexName => lastResponse?.index ?? snapshot().compositionID;

  @override
  String? get queryID => lastResponse?.queryID;
}
