import '../algolia.dart';

/// Transform single query into multiple requests for disjunctive/hierarchical faceting
/// Merges multiple search responses into a single one
class QueryBuilder {

  final SearchState searchState;
  final Set<String> disjunctiveFacets;
  final Set<FilterGroup> filterGroups;
  final List<String> hierarchicalAttributes;
  final List<HierarchicalFilter> hierarchicalFilters;

  int get resultQueriesCount => 1;
  int get disjunctiveQueriesCount => disjunctiveFacets.length;
  int get hierarchicalQueriesCount {
    if (hierarchicalAttributes.length == hierarchicalFilters.length) {
      return hierarchicalAttributes.length;
    }
    return hierarchicalFilters.isEmpty ? 0 : hierarchicalFilters.length + 1;
  }

  QueryBuilder(
      this.searchState,
      this.filterGroups,
      this.disjunctiveFacets,
      this.hierarchicalAttributes,
      this.hierarchicalFilters,);

  List<SearchState> build() {
    final queries = <SearchState>[];
    queries.add(searchState);
    final disjunctiveFacetingQueries = buildDisjunctiveFacetingQueries(searchState, filterGroups, disjunctiveFacets);
    queries.addAll(disjunctiveFacetingQueries);
    final hierarchicalFacetingQueries = buildHierarchicalFacetingQueries(searchState, filterGroups, hierarchicalAttributes, hierarchicalFilters);
    queries.addAll(hierarchicalFacetingQueries);
    return queries;
  }

  Iterable<SearchState> buildDisjunctiveFacetingQueries(SearchState query, Set<FilterGroup> filterGroups, Set<String> disjunctiveFacets) => disjunctiveFacets.map((facet) {
      final filterGroupsCopy = filterGroups.map((group) => group.copy()).toSet();
      return disjunctiveFacetingQuery(query, facet, filterGroupsCopy);
  });

  SearchState disjunctiveFacetingQuery(SearchState query, String attribute, Set<FilterGroup> filterGroups) {
    final updatedFilterGroups = droppingDisjunctiveFiltersForAttribute(filterGroups, attribute);
    return query.copyWith(
        facets: [attribute],
        filterGroups: updatedFilterGroups,
        attributesToRetrieve: [],
        attributesToHighlight: [],
        hitsPerPage: 0,
        analytics: false,
    );
  }

  Set<FilterGroup> droppingDisjunctiveFiltersForAttribute(Set<FilterGroup> filterGroups, String attribute) {
    for (final filterGroup in filterGroups) {
      if (filterGroup.groupID.operator != FilterOperator.or) {
        continue;
      }
      filterGroup.filters.removeWhere((element) => (element as FilterFacet).attribute == attribute);
    }
    return filterGroups;
  }

  List<SearchState> buildHierarchicalFacetingQueries(SearchState query, Set<FilterGroup> filterGroups, List<String> hierarchicalAttributes, List<HierarchicalFilter> hierarchicalFilters) {
    return [];
  }

  SearchResponse aggregate(List<SearchResponse> responses) {
    return responses.first;
  }

}