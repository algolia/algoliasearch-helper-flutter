import 'package:algolia/algolia.dart';
import 'package:logging/logging.dart';

import 'exception.dart';
import 'search_response.dart';
import 'search_state.dart';
import 'utils.dart';

/// Service handling search requests.
class HitsSearchService {
  HitsSearchService(this.client);

  final Algolia client;
  final _logger = Logger("HitsSearchService");

  /// Run search query using [state] and get a search .
  Future<SearchResponse> search(SearchState state) async {
    _logger.info("Start search: $state");
    try {
      final objects = await client.queryOf(state).getObjects();
      _logger.info("Response search : $objects");
      return objects.toSearchResponse();
    } catch (exception) {
      _logger.severe("Search exception thrown: $exception");
      throw launderException(exception);
    }
  }

  Future<SearchResponse> disjunctiveSearch(SearchState state) async {
    /// TODO
    throw UnimplementedError();
  }

  /// Coerce an [AlgoliaError] to a [SearchError].
  Exception launderException(error) =>
      error is AlgoliaError ? error.toSearchError() : error;
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

  List<AlgoliaQuery> advancedQueryOf(SearchState state) {
    /// TODO: Builds multiple search queries based on [state].
    throw UnimplementedError();
  }
}

/// Extensions over [AlgoliaQuery].
extension AlgoliaQuerySnapshotExt on AlgoliaQuerySnapshot {
  SearchResponse toSearchResponse() {
    return SearchResponse((toMap()));
  }
}

extension AlgoliaErrorExt on AlgoliaError {
  SearchError toSearchError() {
    return SearchError(error, statusCode);
  }
}
