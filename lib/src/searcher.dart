import 'dart:async';

import 'package:algolia/algolia.dart';
import 'package:logging/logging.dart';
import 'package:rxdart/rxdart.dart';

import 'algolia_search.dart';
import 'exception.dart';
import 'filter_state.dart';
import 'response.dart';
import 'search_state.dart';
import 'state_builder.dart';

/// Algolia helper main entry point.
///
/// This implementation has the following opinionated behavior:
///
/// 1. There is always an initial [SearchState]
/// 2. Distinct state changes (including initial state) trigger search operation
/// 3. State changes are debounced
class HitsSearcher {
  HitsSearcher._(this.client, SearchState state, Duration debounce) {
    _state = BehaviorSubject<SearchState>.seeded(state);
    responses = _state.stream
        .debounceTime(debounce)
        .distinct()
        .asyncMap((state) => _search(state))
        .handleError(_error);
  }

  /// HitsSearcher's factory.
  factory HitsSearcher(
      {required String applicationID,
      required String apiKey,
      required String indexName,
      Duration debounce = const Duration(milliseconds: 100)}) {
    final client = Algolia.init(applicationId: applicationID, apiKey: apiKey);
    final state = SearchState(indexName: indexName);
    return HitsSearcher._(client, state, debounce);
  }

  /// HitsSearcher's factory.
  factory HitsSearcher.create(
      {required String applicationID,
      required String apiKey,
      required SearchState state,
      Duration debounce = const Duration(milliseconds: 100)}) {
    final client = Algolia.init(applicationId: applicationID, apiKey: apiKey);
    return HitsSearcher._(client, state, debounce);
  }

  /// Inner Algolia API client.
  /// TODO: should be private
  final Algolia client;

  /// Search state stream
  late BehaviorSubject<SearchState> _state;

  /// Search results stream
  late Stream<SearchResponse> responses;

  /// Events logger
  final _logger = Logger('AlgoliaHelper');

  /// Set query string.
  void query(String query) {
    _updateState((state) => state.copyWith(query: query));
  }

  /// Apply search state configuration.
  void applyState(SearchState Function(SearchState state) config) {
    _updateState((state) => config(state));
  }

  /// Apply changes to the current state
  void _updateState(SearchState Function(SearchState state) apply) {
    final current = _state.value;
    final newState = apply(current);
    _logger.config("State updated from $current to $newState");
    _state.sink.add(newState);
  }

  /// Run search query using [state] and get a search .
  Future<SearchResponse> _search(SearchState state) async {
    _logger.info("Start search: $state");
    final objects = await client.queryOf(state).getObjects();
    _logger.info("Response search : $objects");
    return objects.toSearchResponse();
  }

  /// Convert [AlgoliaError] to [SearchError].
  void _error(error) {
    _logger.severe("Search error thrown: $error");
    if (error is AlgoliaError) throw error.toSearchError();
    throw error;
  }

  /// Dispose of underlying resources.
  void dispose() {
    _logger.fine("helper is disposed");
    _state.close();
  }
}

/// Extensions over [HitsSearcher]
extension SearcherExt on HitsSearcher {
  /// Creates a connection between [HitsSearcher] and [FilterState].
  StreamSubscription connectFilterState(FilterState filterState) {
    return filterState.filters
        .listen((filters) => applyState((state) => state.withFilters(filters)));
  }
}
