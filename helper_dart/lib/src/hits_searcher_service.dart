import 'package:algolia/algolia.dart';
import 'package:logging/logging.dart';

import 'exception.dart';
import 'logger.dart';
import 'query_builder.dart';
import 'search_response.dart';
import 'search_state.dart';
import 'utils.dart';

/// Service handling search requests.
class HitsSearchService {
  HitsSearchService(this.client, this.disjunctiveFacetingEnabled)
      : _log = defaultLogger;

  final Algolia client;
  final bool disjunctiveFacetingEnabled;
  final Logger _log;

  /// Search responses as a stream.
  Stream<SearchResponse> search(SearchState state) =>
      Stream.fromFuture(_search(state));

  /// Run search query using [state] and get a search result.
  Future<SearchResponse> _search(SearchState state) =>
      disjunctiveFacetingEnabled
          ? _disjunctiveSearch(state)
          : _singleQuerySearch(state);

  /// Build a single search request using [state] and get a search result.
  Future<SearchResponse> _singleQuerySearch(SearchState state) async {
    _log.fine('Run search with state: $state');
    try {
      final response = await client.queryOf(state).getObjects();
      _log.fine('Search response: $response');
      return response.toSearchResponse();
    } catch (exception) {
      _log.severe('Search exception: $exception');
      throw _launderException(exception);
    }
  }

  /// Build multiple search requests using [state] and get a search result.
  Future<SearchResponse> _disjunctiveSearch(SearchState state) async {
    _log.fine('Start disjunctive search: $state');
    try {
      final queryBuilder = QueryBuilder(state);
      final queries = queryBuilder.build().map(client.queryOf).toList();
      final responses =
          await client.multipleQueries.addQueries(queries).getObjects();
      _log.fine('Search responses: $responses');
      return queryBuilder
          .merge(responses.map((r) => r.toSearchResponse()).toList());
    } catch (exception) {
      _log.severe('Search exception thrown: $exception');
      throw _launderException(exception);
    }
  }

  /// Coerce an [AlgoliaError] to a [SearchError].
  Exception _launderException(error) =>
      error is AlgoliaError ? error.toSearchError() : Exception(error);
}

/// Extensions over [Algolia] client.
extension AlgoliaExt on Algolia {
  /// Create [AlgoliaQuery] instance based on [state].
  AlgoliaQuery queryOf(SearchState state) {
    AlgoliaQuery query = index(state.indexName);
    state.query?.let((it) => query = query.query(it));
    state.page?.let((it) => query = query.setPage(it));
    state.hitsPerPage?.let((it) => query = query.setHitsPerPage(it));
    state.query?.let((it) => query = query.query(it));
    state.facets?.let((it) => query = query.setFacets(it));
    state.ruleContexts?.let((it) => query = query.setRuleContexts(it));
    return query;
  }

  /// Create multiple queries from search
  AlgoliaMultiIndexesReference multipleQueriesOf(SearchState state) =>
      multipleQueries
        ..addQueries(
          QueryBuilder(state).build().map(queryOf).toList(),
        );
}

/// Extensions over [AlgoliaQuerySnapshot].
extension AlgoliaQuerySnapshotExt on AlgoliaQuerySnapshot {
  SearchResponse toSearchResponse() => SearchResponse(toMap());
}

/// Extensions over a list of [AlgoliaQuerySnapshot].
extension ListAlgoliaQuerySnapshotExt on List<AlgoliaQuerySnapshot> {
  SearchResponse toSearchResponseFor(SearchState state) =>
      QueryBuilder(state).merge(map((e) => e.toSearchResponse()).toList());
}

/// Extensions over [AlgoliaError].
extension AlgoliaErrorExt on AlgoliaError {
  SearchError toSearchError() => SearchError(error, statusCode);
}
