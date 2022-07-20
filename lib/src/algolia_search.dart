import 'package:algolia/algolia.dart';
import 'package:algolia_helper/src/exception.dart';

import 'response.dart';
import 'state.dart';
import 'utils.dart';

/// Extensions over [AlgoliaQuery].
extension AlgoliaQueryExt on AlgoliaQuery {
  /// Create [AlgoliaQuery] instance based on [state].
  AlgoliaQuery queryOf(SearchState state) {
    AlgoliaQuery query = this;
    state.query?.let((it) => query = query.query(it));
    state.page?.let((it) => query = query.setPage(it));
    state.hitsPerPage?.let((it) => query = query.setHitsPerPage(it));
    state.query?.let((it) => query = query.query(it));
    state.facets?.let((it) => query = query.setFacets(it));
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
