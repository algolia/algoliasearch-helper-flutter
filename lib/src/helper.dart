import 'dart:async';

import 'package:algolia/algolia.dart';
import 'package:rxdart/subjects.dart';

import 'algolia_search.dart';
import 'exception.dart';
import 'response.dart';
import 'state.dart';

class AlgoliaHelper {
  AlgoliaHelper(this.client, this.indexName, state) {
    _state = BehaviorSubject<SearchState>.seeded(state);
    responses =
        _state.stream.asyncMap((state) => _search(state)).handleError(_error);
  }

  /// AlgoliaHelper's factory.
  factory AlgoliaHelper.create(
      {required String applicationID,
      required String apiKey,
      required String indexName,
      SearchState state = const SearchState()}) {
    final client = Algolia.init(applicationId: applicationID, apiKey: apiKey);
    return AlgoliaHelper(client, indexName, state);
  }

  /// Inner Algolia API client.
  final Algolia client;

  /// Index name.
  final String indexName;

  /// Search state stream
  late BehaviorSubject _state;

  /// Search results stream
  late Stream<SearchResponse> responses;

  late StreamController<SearchError> errors = StreamController<SearchError>();

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
    _state.sink.add(newState);
  }

  /// Run search query using [state] and get a search .
  Future<SearchResponse> _search(SearchState state) async {
    final objects = await client.index(indexName).queryOf(state).getObjects();
    return objects.toSearchResponse();
  }

  /// Convert [AlgoliaError] to [SearchError].
  void _error(error) {
    if (error is AlgoliaError) throw error.toSearchError();
    throw error;
  }

  /// Dispose of underlying resources.
  void dispose() {
    _state.close();
  }
}
