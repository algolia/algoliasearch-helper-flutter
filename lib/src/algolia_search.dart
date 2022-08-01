import 'package:algolia/algolia.dart';
import 'package:algolia_helper/src/exception.dart';

import 'search_response.dart';
import 'search_state.dart';
import 'utils.dart';

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
