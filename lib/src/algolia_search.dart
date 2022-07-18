import 'package:algolia/algolia.dart';

import 'extensions.dart';
import 'search_state.dart';

extension AlgoliaSearchState on AlgoliaIndexReference {
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
