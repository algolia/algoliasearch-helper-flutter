import 'package:algolia_helper_dart/algolia.dart';
import 'package:test/test.dart';

void main() {
  test('QueryBuilder generate disjunctive faceting queries', () {
    final query = SearchState(indexName: "index", query: "phone");
    final queryBuilder = QueryBuilder(query, {}, { 'price', 'color' }, [], []);
    final queries = queryBuilder.build();
    final disjunctiveFacetingQueries = queries.skip(1);
    expect(disjunctiveFacetingQueries.length, 2);
    for (final query in disjunctiveFacetingQueries) {
      expect(query.facets?.length, 1);
    }
    // final p = disjunctiveFacetingQueries.map ((q) => q.facets?.toList()).expand((element) => element);
  });

  test('QueryBuilder generate disjunctive faceting queries with filters', () {

    final query = SearchState(indexName: "index", query: "phone");
    final Set<FilterGroup> filterGroups = {
      FacetFilterGroup(
          FilterGroupID.groupOr('g1'),
          {
            Filter.facet ('price', 100),
            Filter.facet('color', 'green'),
            Filter.facet('size', "44")
          }),
      FacetFilterGroup(
          FilterGroupID.groupOr('g2'),
          {
            Filter.facet ('type', 'phone'),
          }),
      FacetFilterGroup(
          FilterGroupID.and('g3'),
          {
            Filter.facet ('color', 'red'),
            Filter.facet('promo', true),
            Filter.facet('rating', 4.2),
          })
    };
    final queryBuilder = QueryBuilder(query, filterGroups, { 'price', 'color', 'brand' }, [], []);
    final queries = queryBuilder.build();
    expect(queries.length, 4);
    final disjunctiveFacetingQueries = queries.skip(1);
    print(queries.first);
    print(disjunctiveFacetingQueries);
    expect(disjunctiveFacetingQueries.length, 3);
    print(queries.map((e) => e.facets));
    for (final query in queries) {
      print(query.facets);
      for (final filterGroup in query.filterGroups ?? {}) {
        print(filterGroup.groupID);
        for (final filter in filterGroup.filters) {
          print(filter);
        }
      }
    }
  });
}
