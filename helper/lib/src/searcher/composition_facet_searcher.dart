import 'package:logging/logging.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';

import '../client_options.dart';
import '../disposable.dart';
import '../disposable_mixin.dart';
import '../logger.dart';
import '../model/composition_facet_search_response.dart';
import '../model/composition_facet_search_state.dart';
import '../model/composition_state.dart';
import '../service/algolia_composition_facet_search_service.dart';
import '../service/composition_facet_search_service.dart';

/// Algolia Helpers entry point for composition facet search requests and
/// managing search sessions.
///
/// [CompositionFacetSearcher] facilitates search for facet values operations on
/// a composition's main source index. It debounces distinct state changes,
/// cancels ongoing requests on new ones, and exposes the results as a stream.
///
/// ## Create Composition Facet Searcher
///
/// Instantiate [CompositionFacetSearcher] using the default constructor:
///
/// ```dart
/// final facetSearcher = CompositionFacetSearcher(
///   applicationID: 'MY_APPLICATION_ID',
///   apiKey: 'MY_API_KEY',
///   compositionID: 'MY_COMPOSITION_ID',
///   facet: 'MY_FACET_ATTRIBUTE',
/// );
/// ```
///
/// Or, using the [CompositionFacetSearcher.create] factory:
///
/// ```dart
/// final facetSearcher = CompositionFacetSearcher.create(
///   applicationID: 'MY_APPLICATION_ID',
///   apiKey: 'MY_API_KEY',
///   state: CompositionFacetSearchState(
///     compositionID: 'MY_COMPOSITION_ID',
///     facet: 'MY_FACET_ATTRIBUTE',
///     state: const CompositionState(compositionID: 'MY_COMPOSITION_ID'),
///   ),
/// );
/// ```
///
/// ## Dispose
///
/// Call [dispose] to release underlying resources:
///
/// ```dart
/// facetSearcher.dispose();
/// ```
abstract interface class CompositionFacetSearcher implements Disposable {
  /// CompositionFacetSearcher's factory.
  factory CompositionFacetSearcher({
    required String applicationID,
    required String apiKey,
    required String compositionID,
    required String facet,
    Duration debounce = const Duration(milliseconds: 100),
    ClientOptions? options,
  }) =>
      _CompositionFacetSearcher(
        applicationID: applicationID,
        apiKey: apiKey,
        state: CompositionFacetSearchState(
          compositionID: compositionID,
          facet: facet,
          state: CompositionState(compositionID: compositionID),
        ),
        debounce: debounce,
        options: options,
      );

  /// CompositionFacetSearcher's factory.
  factory CompositionFacetSearcher.create({
    required String applicationID,
    required String apiKey,
    required CompositionFacetSearchState state,
    Duration debounce = const Duration(milliseconds: 100),
    ClientOptions? options,
  }) =>
      _CompositionFacetSearcher(
        applicationID: applicationID,
        apiKey: apiKey,
        state: state,
        debounce: debounce,
        options: options,
      );

  /// Creates [CompositionFacetSearcher] using a custom
  /// [CompositionFacetSearchService].
  @internal
  factory CompositionFacetSearcher.custom(
    CompositionFacetSearchService service,
    CompositionFacetSearchState state, [
    Duration debounce = const Duration(milliseconds: 100),
  ]) =>
      _CompositionFacetSearcher.create(service, state, debounce);

  /// Facet search state stream
  Stream<CompositionFacetSearchState> get state;

  /// Facet search results stream
  Stream<CompositionFacetSearchResponse> get responses;

  /// Set facet query string.
  void query(String query);

  /// Get current [CompositionFacetSearchState].
  CompositionFacetSearchState snapshot();

  /// Get latest [CompositionFacetSearchResponse].
  CompositionFacetSearchResponse? get lastResponse;

  /// Apply facet search state configuration.
  void applyState(
    CompositionFacetSearchState Function(CompositionFacetSearchState state)
        config,
  );

  /// Re-run the last facet search query
  void rerun();
}

/// Internal request wrapper allowing [rerun] to force a distinct emission.
@immutable
class _CompositionFacetRequest {
  const _CompositionFacetRequest(this.state, [this.attempts = 1]);

  final CompositionFacetSearchState state;
  final int attempts;

  _CompositionFacetRequest copyWith({
    CompositionFacetSearchState? state,
    int? attempts,
  }) =>
      _CompositionFacetRequest(
        state ?? this.state,
        attempts ?? this.attempts,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _CompositionFacetRequest &&
          runtimeType == other.runtimeType &&
          state == other.state &&
          attempts == other.attempts;

  @override
  int get hashCode => state.hashCode ^ attempts.hashCode;
}

/// Default implementation of [CompositionFacetSearcher].
class _CompositionFacetSearcher
    with DisposableMixin
    implements CompositionFacetSearcher {
  /// CompositionFacetSearcher's factory.
  factory _CompositionFacetSearcher({
    required String applicationID,
    required String apiKey,
    required CompositionFacetSearchState state,
    Duration debounce = const Duration(milliseconds: 100),
    ClientOptions? options,
  }) {
    final service = AlgoliaCompositionFacetSearchService(
      applicationID: applicationID,
      apiKey: apiKey,
      options: options,
    );
    return _CompositionFacetSearcher.create(
      service,
      state,
      debounce,
    );
  }

  /// CompositionFacetSearcher's constructor, for internal and test use only.
  _CompositionFacetSearcher.create(
    CompositionFacetSearchService searchService,
    CompositionFacetSearchState state, [
    Duration debounce = const Duration(milliseconds: 100),
  ]) : this._(
          searchService,
          BehaviorSubject.seeded(_CompositionFacetRequest(state)),
          debounce,
        );

  /// CompositionFacetSearcher's private constructor
  _CompositionFacetSearcher._(
    this.searchService,
    this._request,
    this.debounce,
  ) {
    _subscriptions.add(_responses.connect());
  }

  /// Facet search state stream
  @override
  Stream<CompositionFacetSearchState> get state =>
      _request.stream.map((request) => request.state);

  /// Facet search results stream
  @override
  Stream<CompositionFacetSearchResponse> get responses => _responses;

  /// Service handling facet search requests
  final CompositionFacetSearchService searchService;

  /// Facet search state debounce duration
  final Duration debounce;

  /// Facet search state subject
  final BehaviorSubject<_CompositionFacetRequest> _request;

  /// Facet search responses subject
  late final _responses = _request.stream
      .debounceTime(debounce)
      .distinct()
      .switchMap((req) => Stream.fromFuture(searchService.search(req.state)))
      .doOnData((value) {
    lastResponse = value;
  }).publish();

  /// Events logger
  final Logger _log = algoliaLogger('CompositionFacetSearcher');

  /// Streams subscriptions composite.
  final CompositeSubscription _subscriptions = CompositeSubscription();

  @override
  void query(String query) {
    applyState((state) => state.copyWith(facetQuery: query));
  }

  @override
  CompositionFacetSearchState snapshot() => _request.value.state;

  /// Get latest facet search response
  @override
  CompositionFacetSearchResponse? lastResponse;

  /// Apply facet search state configuration.
  @override
  void applyState(
    CompositionFacetSearchState Function(CompositionFacetSearchState state)
        config,
  ) {
    _updateState((state) => config(state));
  }

  /// Apply changes to the current state
  void _updateState(
    CompositionFacetSearchState Function(CompositionFacetSearchState state)
        apply,
  ) {
    if (_request.isClosed) {
      _log.warning('modifying disposed instance');
      return;
    }
    final current = _request.value;
    final newState = apply(current.state);
    _request.sink.add(_CompositionFacetRequest(newState));
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
    _log.fine('CompositionFacetSearcher disposed');
    _request.close();
    _subscriptions.dispose();
  }
}
