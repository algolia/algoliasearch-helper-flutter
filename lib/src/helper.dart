import 'dart:async';

import 'package:algolia/algolia.dart';
import 'package:logging/logging.dart';
import 'package:rxdart/rxdart.dart';

import 'algolia_search.dart';
import 'exception.dart';
import 'response.dart';
import 'state.dart';

class AlgoliaHelper {
  AlgoliaHelper._(
      this.client, this.indexName, SearchState state, Duration debounce) {
    _state = BehaviorSubject<SearchState>.seeded(state);
    responses = _state.stream
        .debounceTime(debounce)
        .distinct()
        .asyncMap((state) => _search(state))
        .handleError(_error);
  }

  /// AlgoliaHelper's factory.
  factory AlgoliaHelper.create(
      {required String applicationID,
      required String apiKey,
      required String indexName,
      SearchState state = const SearchState(),
      Duration debounce = const Duration(milliseconds: 100)}) {
    final client = Algolia.init(applicationId: applicationID, apiKey: apiKey);
    return AlgoliaHelper._(client, indexName, state, debounce);
  }

  /// Inner Algolia API client.
  final Algolia client;

  /// Index name.
  final String indexName;

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

  /// Set search page.
  void setPage(int page) {
    _updateState((state) => state.copyWith(page: page));
  }

  /// Set hits per search page.
  void setHitPerPage(int page) {
    _updateState((state) => state.copyWith(page: page));
  }

  /// Set search facets.
  void setFacets(List<String> facets) {
    _updateState((state) => state.copyWith(facets: facets));
  }

  /// Apply search state configuration.
  void applyState(SearchState Function(SearchState state) config) {
    _updateState((state) => config(state));
  }

  /// Override current state with an empty state.
  void clearState() {
    _updateState((_) => const SearchState());
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
    final objects = await client.index(indexName).queryOf(state).getObjects();
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
