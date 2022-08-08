import 'package:algolia/algolia.dart';
import 'package:logging/logging.dart';

import 'exception.dart';
import 'search_response.dart';
import 'search_state.dart';
import 'utils.dart';

/// Service handling search requests.
class HitsSearchService {
  HitsSearchService(this.client, this.disjunctiveFacetingEnabled);

  final Algolia client;
  final bool disjunctiveFacetingEnabled;
  final _logger = Logger('HitsSearchService');

  /// Run search query using [state] and get a search result.
  Future<SearchResponse> search(SearchState state) => disjunctiveFacetingEnabled
      ? disjunctiveSearch(state)
      : singleQuerySearch(state);

  /// Build a single search request using [state] and get a search result.
  Future<SearchResponse> singleQuerySearch(SearchState state) async {
    _logger.fine('Start search: $state');
    try {
      final response = await client.queryOf(state).getObjects();
      _logger.fine('Search response : $response');
      return response.toSearchResponse();
    } catch (exception) {
      _logger.severe('Search exception thrown: $exception');
      throw _launderException(exception);
    }
  }

  /// Build multiple search requests using [state] and get a search result.
  Future<SearchResponse> disjunctiveSearch(SearchState state) async {
    _logger.fine('Start disjunctive search: $state');
    try {
      final responses = await client.multipleQueriesOf(state).getObjects();
      _logger.fine('Search responses: $responses');
      return responses.toSearchResponse();
    } catch (exception) {
      _logger.severe('Search exception thrown: $exception');
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
  AlgoliaMultiIndexesReference multipleQueriesOf(SearchState state) {
    /// TODO: Builds multiple search queries based on state.
    throw UnimplementedError();
  }
}

/// Extensions over [AlgoliaQuerySnapshot].
extension AlgoliaQuerySnapshotExt on AlgoliaQuerySnapshot {
  SearchResponse toSearchResponse() => SearchResponse(toMap());
}

/// Extensions over a list of [AlgoliaQuerySnapshot].
extension ListAlgoliaQuerySnapshotExt on List<AlgoliaQuerySnapshot> {
  SearchResponse toSearchResponse() {
    // TODO: convert list of search response to a single search response
    throw UnimplementedError();
  }
}

/// Extensions over [AlgoliaError].
extension AlgoliaErrorExt on AlgoliaError {
  SearchError toSearchError() => SearchError(error, statusCode);
}
