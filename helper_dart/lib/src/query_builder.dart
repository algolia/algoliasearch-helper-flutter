import 'package:collection/collection.dart';

import 'filter.dart';
import 'filter_group.dart';
import 'search_response.dart';
import 'search_state.dart';

/// Transform single query into multiple requests for disjunctive/hierarchical
/// faceting. Merges multiple search responses into a single one
class QueryBuilder {
  /// Creates [QueryBuilder] instance.
  const QueryBuilder(this._searchState);

  /// Search state instance.
  final SearchState _searchState;

  /// Number of search result queries
  int get _resultQueriesCount => 1;

  /// Number of generated disjunctive queries for given hierarchical
  /// filters list
  int get _disjunctiveQueriesCount =>
      _searchState.disjunctiveFacets?.length ?? 0;

  /// Number of generated hierarchical queries for given hierarchical
  /// filters list
  int get _hierarchicalQueriesCount {
    final hierarchicalFilters = _getHierarchicalFilters();
    if (hierarchicalFilters.isEmpty) return 0;
    return hierarchicalFilters
        .map(_getHierarchicalQueriesCount)
        .reduce((value, element) => value + element);
  }

  /// Get hierarchical filters from the search state's filter groups.
  Iterable<HierarchicalFilterGroup> _getHierarchicalFilters() =>
      _searchState.filterGroups?.whereType<HierarchicalFilterGroup>() ?? [];

  /// Number of generated hierarchical queries for given hierarchical
  /// filter
  int _getHierarchicalQueriesCount(HierarchicalFilterGroup group) {
    if (group.attributes.length == group.path.length) {
      return group.attributes.length;
    }
    return group.path.isEmpty ? 0 : group.path.length + 1;
  }

  /// Total number of queries
  int get _totalQueriesCount =>
      _resultQueriesCount +
      _disjunctiveQueriesCount +
      _hierarchicalQueriesCount;

  /// Build all the required queries for search, disjunctive and hierarchical
  /// faceting
  List<SearchState> build() => <SearchState>[
        _searchState,
        ..._buildDisjunctiveFacetingQueries(_searchState),
        ..._buildHierarchicalFacetingQueries(_searchState),
      ];

  /// Merge search responses for generated queries regrouping
  /// the disjunctive and hierarchical facets information into a single response
  SearchResponse merge(List<SearchResponse> responses) {
    assert(
      responses.length == _totalQueriesCount,
      'number of responses (${responses.length}) not matches with number of '
      'requests ($_totalQueriesCount)',
    );

    final aggregatedResponse = responses.removeAt(0);

    final disjunctiveFacetingResponses =
        responses.sublist(0, _disjunctiveQueriesCount);
    final hierarchicalFacetingResponses =
        responses.sublist(_disjunctiveQueriesCount, _totalQueriesCount - 1);

    for (final response in disjunctiveFacetingResponses) {
      aggregatedResponse.disjunctiveFacets.addAll(response.facets);
      aggregatedResponse.facetsStats.addAll(response.facetsStats);
    }

    for (final response in hierarchicalFacetingResponses) {
      aggregatedResponse.hierarchicalFacets.addAll(response.facets);
    }

    return aggregatedResponse;
  }

  /// Build additional queries to fetch correct facets count values
  /// for disjunctive facets
  Iterable<SearchState> _buildDisjunctiveFacetingQueries(SearchState query) =>
      query.disjunctiveFacets?.map((facet) {
        final filterGroupsCopy = _copyFilterGroups();
        for (final filterGroup in filterGroupsCopy) {
          if (filterGroup.groupID.operator != FilterOperator.or) continue;
          filterGroup.removeWhere(
            (element) => element is FilterFacet && element.attribute == facet,
          );
        }
        return query.copyWith(
          facets: [facet],
          filterGroups: filterGroupsCopy,
          attributesToRetrieve: ['objectID'], // TODO: should be [], workaround
          attributesToHighlight: ['objectID'], // to avoid the client exception
          hitsPerPage: 0,
          analytics: false,
        );
      }) ??
      [];

  /// Create modifiable copy of filter groups.
  Set<FilterGroup> _copyFilterGroups() =>
      Set.from(_searchState.filterGroups ?? {});

  /// Build additional queries to fetch correct facets count values
  /// for hierarchical facets
  List<SearchState> _buildHierarchicalFacetingQueries(SearchState query) {
    final hierarchicalFilters =
        query.filterGroups?.whereType<HierarchicalFilterGroup>().toList() ?? [];

    final queries = <SearchState>[];
    for (final hierarchicalFilter in hierarchicalFilters) {
      if (hierarchicalFilter.path.isEmpty) return [];
      final hierarchicalPath = <FilterFacet?>[null, ...hierarchicalFilter.path];
      final queriesForFilter =
          IterableZip([hierarchicalFilter.attributes, hierarchicalPath]).map(
        (pair) {
          final facet = pair[0] as String;
          final pathFilter = pair[1] as FilterFacet?;
          return _hierarchicalQueryOf(
            facet,
            pathFilter,
            hierarchicalFilter,
            query,
          );
        },
      );
      queries.addAll(queriesForFilter);
    }
    return queries;
  }

  /// Build query to fetch correct facets count values
  /// for hierarchical faceting for a given facet & path filter couple
  SearchState _hierarchicalQueryOf(
    String facet,
    FilterFacet? pathFilter,
    HierarchicalFilterGroup group,
    SearchState state,
  ) {
    final filterGroupsCopy = _copyFilterGroups()
      ..removeWhere((filter) => filter == group);

    if (pathFilter != null) {
      filterGroupsCopy.add(
        FacetFilterGroup(FilterGroupID.and('_hierarchical'), {pathFilter}),
      );
    }

    filterGroupsCopy.removeWhere((group) => group.isEmpty);

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
