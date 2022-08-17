import 'package:collection/collection.dart';

import 'filter.dart';
import 'filter_group.dart';
import 'search_response.dart';
import 'search_state.dart';

/// Transform single query into multiple requests for disjunctive/hierarchical
/// faceting. Merges multiple search responses into a single one
class QueryBuilder {
  QueryBuilder(this.searchState);

  final SearchState searchState;

  /// Number of search result queries
  int get resultQueriesCount => 1;

  /// Number of generated disjunctive queries for given hierarchical
  /// filters list
  int get disjunctiveQueriesCount => searchState.disjunctiveFacets?.length ?? 0;

  /// Number of generated hierarchical queries for given hierarchical
  /// filters list
  int get hierarchicalQueriesCount {
    final hierarchicalFilters = _getHierarchicalFilters();
    if (hierarchicalFilters.isEmpty) return 0;
    return hierarchicalFilters
        .map(_getHierarchicalQueriesCount)
        .reduce((value, element) => value + element);
  }

  Iterable<HierarchicalFilter> _getHierarchicalFilters() =>
      searchState.filterGroups
          ?.whereType<HierarchicalFilterGroup>()
          .expand((filterGroup) => filterGroup.filters) ??
      [];

  /// TODO: documentation
  int _getHierarchicalQueriesCount(HierarchicalFilter filter) {
    if (filter.attributes.length == filter.path.length) {
      return filter.attributes.length;
    }
    return filter.path.isEmpty ? 0 : filter.path.length + 1;
  }

  /// Total number of queries
  int get totalQueriesCount =>
      resultQueriesCount + disjunctiveQueriesCount + hierarchicalQueriesCount;

  /// Build all the required queries for search, disjunctive and hierarchical
  /// faceting
  List<SearchState> build() => <SearchState>[
        searchState,
        ..._buildDisjunctiveFacetingQueries(searchState),
        ..._buildHierarchicalFacetingQueries(searchState),
      ];

  /// Merge search responses for generated queries regrouping
  /// the disjunctive and hierarchical facets information into a single response
  SearchResponse merge(List<SearchResponse> responses) {
    assert(
      responses.length == totalQueriesCount,
      'number of responses (${responses.length}) not matches with number of '
      'requests ($totalQueriesCount)',
    );

    final aggregatedResponse = responses.removeAt(0);

    final disjunctiveFacetingResponses =
        responses.sublist(0, disjunctiveQueriesCount);
    final hierarchicalFacetingResponses =
        responses.sublist(disjunctiveQueriesCount, totalQueriesCount - 1);

    for (final response in disjunctiveFacetingResponses) {
      aggregatedResponse.disjunctiveFacets.addAll(response.facets);
      aggregatedResponse.facetsStats.addAll(response.facetsStats);
    }

    for (final response in hierarchicalFacetingResponses) {
      aggregatedResponse.hierarchicalFacets.addAll(response.facets);
    }

    return aggregatedResponse;
  }

  /// TODO: documentation
  Iterable<SearchState> _buildDisjunctiveFacetingQueries(SearchState query) =>
      query.disjunctiveFacets?.map((facet) {
        final filterGroupsCopy = _copyFilterGroups();
        for (final filterGroup in filterGroupsCopy) {
          if (filterGroup.groupID.operator != FilterOperator.or) continue;
          filterGroup.filters.removeWhere(
            (element) => element is FilterFacet && element.attribute == facet,
          );
        }
        return query.copyWith(
          facets: [facet],
          filterGroups: filterGroupsCopy,
          attributesToRetrieve: [],
          attributesToHighlight: [],
          hitsPerPage: 0,
          analytics: false,
        );
      }) ??
      [];

  /// Create modifiable copy of filter groups.
  Set<FilterGroup> _copyFilterGroups() =>
      Set.from(searchState.filterGroups ?? {});

  /// TODO: documentation
  List<SearchState> _buildHierarchicalFacetingQueries(SearchState query) {
    final hierarchicalFilters = query.filterGroups
            ?.whereType<HierarchicalFilterGroup>()
            .map((e) => e.filters)
            .expand((e) => e)
            .toList() ??
        [];

    final queries = <SearchState>[];
    for (final hierarchicalFilter in hierarchicalFilters) {
      if (hierarchicalFilter.path.isEmpty) return [];
      final hierarchicalPath = <FilterFacet?>[null, ...hierarchicalFilter.path];
      final queriesForFilter =
          IterableZip([hierarchicalFilter.attributes, hierarchicalPath]).map(
        (pair) {
          final facet = pair[0] as String;
          final pathFilter = pair[1] as FilterFacet?;
          return _stateFilterOf(facet, pathFilter, hierarchicalFilter, query);
        },
      );
      queries.addAll(queriesForFilter);
    }
    return queries;
  }

  /// TODO: documentation
  SearchState _stateFilterOf(
    String facet,
    FilterFacet? pathFilter,
    HierarchicalFilter hierarchicalFilter,
    SearchState state,
  ) {
    final filterGroupsCopy = _copyFilterGroups()
      ..forEach((filterGroup) {
        if (filterGroup.groupID.operator == FilterOperator.and) {
          filterGroup.filters
              .removeWhere((filter) => filter == hierarchicalFilter);
        }
      });

    if (pathFilter != null) {
      filterGroupsCopy.add(
        FacetFilterGroup(FilterGroupID.and('_hierarchical'), {pathFilter}),
      );
    }

    filterGroupsCopy.removeWhere((group) => group.filters.isEmpty);

    return state.copyWith(
      facets: [facet],
      filterGroups: filterGroupsCopy,
      attributesToRetrieve: [],
      attributesToHighlight: [],
      hitsPerPage: 0,
      analytics: false,
    );
  }
}
