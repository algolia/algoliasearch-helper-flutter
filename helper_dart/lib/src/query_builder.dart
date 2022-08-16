import '../algolia.dart';
import 'package:collection/collection.dart';

import 'utils.dart';

/// Transform single query into multiple requests for disjunctive/hierarchical faceting
/// Merges multiple search responses into a single one
class QueryBuilder {
  final SearchState searchState;
  final Set<String> disjunctiveFacets;
  final HierarchicalFilter? hierarchicalFilter;

  int get resultQueriesCount => 1;
  int get disjunctiveQueriesCount => disjunctiveFacets.length;
  int get hierarchicalQueriesCount {
    if (hierarchicalFilter == null) {
      return 0;
    }
    if (hierarchicalFilter!.attributes.length ==
        hierarchicalFilter!.path.length) {
      return hierarchicalFilter!.attributes.length;
    }
    return hierarchicalFilter!.path.isEmpty
        ? 0
        : hierarchicalFilter!.path.length + 1;
  }

  int get totalQueriesCount =>
      resultQueriesCount + disjunctiveQueriesCount + hierarchicalQueriesCount;

  QueryBuilder(
    this.searchState,
    this.disjunctiveFacets,
    this.hierarchicalFilter,
  );

  List<SearchState> build() => <SearchState>[
        searchState,
        ..._buildDisjunctiveFacetingQueries(searchState, disjunctiveFacets),
        ..._buildHierarchicalFacetingQueries(searchState, hierarchicalFilter)
      ];

  Iterable<SearchState> _buildDisjunctiveFacetingQueries(
          SearchState query, Set<String> disjunctiveFacets) =>
      disjunctiveFacets.map((facet) {
        final filterGroupsCopy =
            query.filterGroups?.map((group) => group.copy()).toSet() ?? {};
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
      });

  List<SearchState> _buildHierarchicalFacetingQueries(
      SearchState query, HierarchicalFilter? hierarchicalFilter) {
    if (hierarchicalFilter == null) {
      return [];
    }

    if (hierarchicalFilter.path.isEmpty) {
      return [];
    }

    final appliedFilter = hierarchicalFilter.path.last;

    final hierarchicalPath = <FilterFacet?>[null, ...hierarchicalFilter.path];

    return IterableZip([hierarchicalFilter.attributes, hierarchicalPath])
        .map((pairs) {
      final attribute = pairs[0] as String;
      final pathFilter = pairs[1] as FilterFacet?;

      final outputFilterGroups = <FilterGroup>{};

      if (query.filterGroups != null) {
        outputFilterGroups
            .addAll(query.filterGroups!.map((g) => g.copy()).toSet()
              ..forEach((filterGroup) {
                if (filterGroup.groupID.operator == FilterOperator.and) {
                  filterGroup.filters
                      .removeWhere((filter) => filter == hierarchicalFilter);
                }
              }));
      }

      if (pathFilter != null) {
        outputFilterGroups.add(
            FacetFilterGroup(FilterGroupID.and('_hierarchical'), {pathFilter}));
      }

      outputFilterGroups.removeWhere((group) => group.filters.isEmpty);

      return query.copyWith(
          facets: [attribute],
          filterGroups: outputFilterGroups,
          attributesToRetrieve: [],
          attributesToHighlight: [],
          hitsPerPage: 0,
          analytics: false);
    }).toList();
  }

  SearchResponse aggregate(List<SearchResponse> responses) {
    if (responses.isEmpty) {
      // error
    }

    if (responses.length != totalQueriesCount) {
      // error
    }

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
}
