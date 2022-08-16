import '../algolia.dart';
import 'package:collection/collection.dart';

import 'utils.dart';

/// Transform single query into multiple requests for disjunctive/hierarchical faceting
/// Merges multiple search responses into a single one
class QueryBuilder {
  final SearchState searchState;

  /// Number of search result queries
  int get resultQueriesCount => 1;

  /// Number of generated disjunctive queries for given hierarchical filters list
  int get disjunctiveQueriesCount => searchState.disjunctiveFacets?.length ?? 0;

  /// Number of generated hierarchical queries for given hierarchical filters list
  int get hierarchicalQueriesCount {
    final hierarchicalFilters = searchState.filterGroups
        ?.map((g) => (g as HierarchicalFilterGroup?)?.filters ?? {})
        .expand((filters) => filters) ??
        [];
    if (hierarchicalFilters.isEmpty) {
      return 0;
    }
    return hierarchicalFilters.map((filter) {
      if (filter.attributes.length == filter.path.length) {
        return filter.attributes.length;
      }
      return filter.path.isEmpty ? 0 : filter.path.length + 1;
    }).reduce((value, element) => value + element);
  }

  /// Total number of queries
  int get totalQueriesCount =>
      resultQueriesCount + disjunctiveQueriesCount + hierarchicalQueriesCount;

  QueryBuilder(
    this.searchState,
  );

  /// Build all the required queries for search, disjunctive and hierarchical faceting
  List<SearchState> build() => <SearchState>[
        searchState,
        ..._buildDisjunctiveFacetingQueries(searchState),
        ..._buildHierarchicalFacetingQueries(searchState),
      ];

  /// Merge search responses for generated queries regrouping
  /// the disjunctive and hierarchical facets information into a single response
  SearchResponse merge(List<SearchResponse> responses) {
    assert(responses.length == totalQueriesCount,
        'number of responses (${responses.length}) not matches with number of requests (${totalQueriesCount})');

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

  Set<FilterGroup> _copyFilterGroups() =>
      searchState.filterGroups?.map((group) => group.copy()).toSet() ?? {};

  Iterable<SearchState> _buildDisjunctiveFacetingQueries(SearchState query) =>
      query.disjunctiveFacets?.map((facet) {
        final filterGroupsCopy = _copyFilterGroups();
        for (final filterGroup in filterGroupsCopy) {
          if (filterGroup.groupID.operator != FilterOperator.or) {
            continue;
          }
          filterGroup.filters.removeWhere(
              (element) => (element as FilterFacet).attribute == facet);
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

  List<SearchState> _buildHierarchicalFacetingQueries(SearchState query) {
    final hierarchicalFilters = query.filterGroups
            ?.map((group) {
              if (group is HierarchicalFilterGroup?) {
                return (group as HierarchicalFilterGroup)?.filters.toList() ?? [];
              } else {
                return <HierarchicalFilter>[];
              }
            })
            .expand((filters) => filters) ??
        [];

    final queries = <SearchState>[];

    for (final hierarchicalFilter in hierarchicalFilters) {
      if (hierarchicalFilter.path.isEmpty) {
        return [];
      }

      final hierarchicalPath = <FilterFacet?>[
        null,
        ...hierarchicalFilter.path
      ];

      final queriesForFilter = IterableZip([hierarchicalFilter.attributes, hierarchicalPath])
          .map((pairs) {
        final facet = pairs[0] as String;
        final pathFilter = pairs[1] as FilterFacet?;

        final filterGroupsCopy = _copyFilterGroups()
          ..forEach((filterGroup) {
            if (filterGroup.groupID.operator == FilterOperator.and) {
              filterGroup.filters
                  .removeWhere((filter) => filter == hierarchicalFilter);
            }
          });

        if (pathFilter != null) {
          filterGroupsCopy.add(FacetFilterGroup(
            FilterGroupID.and('_hierarchical'),
            {pathFilter},
          ));
        }

        filterGroupsCopy.removeWhere((group) => group.filters.isEmpty);

        return query.copyWith(
          facets: [facet],
          filterGroups: filterGroupsCopy,
          attributesToRetrieve: [],
          attributesToHighlight: [],
          hitsPerPage: 0,
          analytics: false,
        );
      });
      queries.addAll(queriesForFilter);
    }
    return queries;
  }
}
