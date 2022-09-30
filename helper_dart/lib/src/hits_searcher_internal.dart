import 'dart:async';

import 'package:algolia/algolia.dart';
import 'package:logging/logging.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';

import 'hits_searcher.dart';
import 'hits_searcher_service.dart';
import 'logger.dart';
import 'search_response.dart';
import 'search_state.dart';

/// Algolia helpers main entry point.
///
/// This implementation has the following behavior:
///
/// 1. Distinct state changes (including initial state) trigger search operation
/// 2. State changes are debounced
@visibleForTesting
class InternalHitsSearcher implements HitsSearcher {
  /// HitsSearcher's factory.
  factory InternalHitsSearcher({
    required String applicationID,
    required String apiKey,
    required SearchState state,
    bool disjunctiveFacetingEnabled = true,
    Duration debounce = const Duration(milliseconds: 100),
  }) {
    final client = Algolia.init(
      applicationId: applicationID,
      apiKey: apiKey,
      extraUserAgents: ['algolia-helper-dart (0.1.5)'],
    );
    final service = HitsSearchService(client, disjunctiveFacetingEnabled);
    return InternalHitsSearcher.create(service, state, debounce);
  }

  /// HitSearcher's constructor, for internal and test use only.
  InternalHitsSearcher.create(
    HitsSearchService searchService,
    SearchState state, [
    Duration debounce = const Duration(milliseconds: 100),
  ]) : this._(searchService, BehaviorSubject.seeded(state), debounce);

  /// HitsSearcher's private constructor
  InternalHitsSearcher._(this.searchService, this._state, this.debounce) {
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
      .switchMap(searchService.search)
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

  /// Dispose of underlying resources.
  @override
  void dispose() {
    _log.fine('HitsSearcher disposed');
    _state.close();
    _subscription.cancel();
  }
}
