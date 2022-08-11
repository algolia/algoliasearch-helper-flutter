import 'dart:math';

import 'package:algolia_helper_dart/algolia.dart';
import 'package:test/test.dart';

void main() {
  test('QueryBuilder generate disjunctive faceting queries', () {
    final query = SearchState(indexName: 'index', query: 'phone');
    final queryBuilder = QueryBuilder(query, {}, { 'price', 'color' }, [], []);
    final queries = queryBuilder.build();
    final disjunctiveFacetingQueries = queries.skip(1);
    expect(disjunctiveFacetingQueries.length, 2);
    for (final query in disjunctiveFacetingQueries) {
      expect(query.facets?.length, 1);
    }
  });

  test('QueryBuilder generate disjunctive faceting queries with filters', () {

    const query = SearchState(indexName: 'index', query: 'phone');
    final filterGroups = <FilterGroup>{
      FacetFilterGroup(
          FilterGroupID.groupOr('g1'),
          {
            Filter.facet('price', 100),
            Filter.facet('color', 'green'),
            Filter.facet('size', '44'),
          }),
      FacetFilterGroup(
          FilterGroupID.groupOr('g2'),
          {
            Filter.facet ('type', 'phone'),
          }),
      FacetFilterGroup(
          FilterGroupID.and('g3'),
          {
            Filter.facet('brand', 'samsung'),
            Filter.facet('color', 'red'),
            Filter.facet('promo', true),
            Filter.facet('rating', 4.2),
          })
    };
    final disjunctiveFacets = { 'price', 'color', 'brand' };
    final queryBuilder = QueryBuilder(query, filterGroups, disjunctiveFacets, [], []);
    final queries = queryBuilder.build();
    expect(queries.length, 4);
    final disjunctiveFacetingQueries = queries.skip(1);
    for (final query in disjunctiveFacetingQueries) {
      final facet = query.facets!.first;
      final keptFacets = disjunctiveFacets.toSet();
      keptFacets.remove(facet);
      final group1 = query.filterGroups?.firstWhere((g) => g.groupID.name == 'g1') as FacetFilterGroup;
      final group2 = query.filterGroups?.firstWhere((g) => g.groupID.name == 'g2') as FacetFilterGroup;
      final group3 = query.filterGroups?.firstWhere((g) => g.groupID.name == 'g3') as FacetFilterGroup;
      expect(group1.filters.map((f) => f.attribute).contains(facet), false);
      expect(group2.filters.length, 1);
      expect(group3.filters.length, 4);
    }
  });
}
