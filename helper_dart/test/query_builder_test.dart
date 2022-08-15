import 'dart:math';

import 'package:algolia_helper_dart/algolia.dart';
import 'package:logging/logging.dart';
import 'package:test/test.dart';

void main() {
  test('QueryBuilder generate disjunctive faceting queries', () {
    final query = SearchState(indexName: 'index', query: 'phone');
    final queryBuilder = QueryBuilder(query, {}, { 'price', 'color' }, null);
    final queries = queryBuilder.build();
    final disjunctiveFacetingQueries = queries.skip(1);
    expect(disjunctiveFacetingQueries.length, 2);
    for (final query in disjunctiveFacetingQueries) {
      expect(query.facets?.length, 1);
    }
  });

  test('QueryBuilder generate disjunctive faceting queries with filters', () {
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
    final query = SearchState(indexName: 'index', query: 'phone', filterGroups: filterGroups);
    final disjunctiveFacets = { 'price', 'color', 'brand' };
    final queryBuilder = QueryBuilder(query, filterGroups, disjunctiveFacets, null);
    final queries = queryBuilder.build();
    expect(queries.length, 4);

    queries.asMap().forEach((index, query) {
      switch (index) {
        case 0:
          expect(query.facets, null);
          expect(query.filterGroups!.length, 3);
          expect(query.filterGroups, filterGroups);
          break;

        case 1:
          expect(query.facets, ['price']);
          expect(query.filterGroups!.first.filters.map((f) => f.attribute).contains('price'), false);
          break;

        case 2:
          expect(query.facets, ['color']);
          expect(query.filterGroups!.first.filters.map((f) => f.attribute).contains('color'), false);
          break;

        case 3:
          expect(query.facets, ['brand']);
          expect(query.filterGroups!.first.filters.map((f) => f.attribute).contains('brand'), false);
          break;

        default:
          break;
      }
    });

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
  
  test('generate hierarchical faceting queries', () {
    const lvl0 = 'category.lvl0';
    const lvl1= 'category.lvl1';
    const lvl2 = 'category.lvl2';
    const lvl3 = 'category.lvl3';

    final attributes = [lvl0, lvl1, lvl2, lvl3];
    final path = [Filter.facet(lvl0, 'a'), Filter.facet(lvl1, 'a > b'), Filter.facet(lvl2, 'a > b > c')];
    final hierarchicalFilter = HierarchicalFilter(attributes, path, Filter.facet(lvl2, 'a > b > c'));

    final colorGroup = FacetFilterGroup(FilterGroupID('color', FilterOperator.and), { Filter.facet('color', 'red') });
    final hierarchicalGroup = HierarchicalFilterGroup('h', { hierarchicalFilter });
    final filterGroups = <FilterGroup>{ colorGroup, hierarchicalGroup };

    final query = SearchState(indexName: 'index', query: 'phone', filterGroups: filterGroups);
    final queryBuilder = QueryBuilder(query, filterGroups, {}, hierarchicalFilter);
    final queries = queryBuilder.build();

    queries.asMap().forEach((index, query) {

      switch (index) {
        case 0:
          expect(query.facets, null);
          expect(query.filterGroups!.length, 2);
          expect(query.filterGroups, filterGroups);
          break;

        case 1:
          expect(query.facets, [lvl0]);
          expect(query.filterGroups!.length, 1);
          expect(query.filterGroups!.first.groupID, FilterGroupID('color', FilterOperator.and));
          expect(query.filterGroups!.first.filters, { Filter.facet('color', 'red') });
          break;

        case 2:
          expect(query.facets, [lvl1]);
          expect(query.filterGroups!.length, 2);
          expect(query.filterGroups!.first.groupID, FilterGroupID('color', FilterOperator.and));
          expect(query.filterGroups!.first.filters, { Filter.facet('color', 'red') });
          expect(query.filterGroups!.last.groupID, FilterGroupID('_hierarchical', FilterOperator.and));
          expect(query.filterGroups!.last.filters, { Filter.facet(lvl0, 'a') });
          break;

        case 3:
          expect(query.facets, [lvl2]);
          expect(query.filterGroups!.length, 2);
          expect(query.filterGroups!.first.groupID, FilterGroupID('color', FilterOperator.and));
          expect(query.filterGroups!.first.filters, { Filter.facet('color', 'red') });
          expect(query.filterGroups!.last.groupID, FilterGroupID('_hierarchical', FilterOperator.and));
          expect(query.filterGroups!.last.filters, { Filter.facet(lvl1, 'a > b') });
          break;

        case 4:
          expect(query.facets, [lvl3]);
          expect(query.filterGroups!.length, 2);
          expect(query.filterGroups!.first.groupID, FilterGroupID('color', FilterOperator.and));
          expect(query.filterGroups!.first.filters, { Filter.facet('color', 'red') });
          expect(query.filterGroups!.last.groupID, FilterGroupID('_hierarchical', FilterOperator.and));
          expect(query.filterGroups!.last.filters, { Filter.facet(lvl2, 'a > b > c') });
          break;

        default:
          break;
      }
    });
  });

  test('aggregate disjunctive facets responses', () {

    final query = SearchState(indexName: 'index', query: 'phone');
    final disjunctiveFacets = { 'color', 'brand', 'size' };

    final mainResponse = SearchResponse({});

    final disjunctiveResponse1 = SearchResponse({});
    disjunctiveResponse1.raw['facets'] = {
      'color': {
        'red': 1,
        'green': 2,
        'blue': 3,
      },
    };
    final disjunctiveResponse2 = SearchResponse({});
    disjunctiveResponse2.raw['facets'] = {
      'brand': {
        'sony': 10,
        'apple': 20,
        'samsung': 30
      }
    };
    final disjunctiveResponse3 = SearchResponse({});
    disjunctiveResponse3.raw['facets'] = {
      'size': {
        's': 15,
        'm': 20,
        'l': 25,
      }
    };

    final queryBuilder = QueryBuilder(query, {}, disjunctiveFacets, null);

    final aggregatedResponse = queryBuilder.aggregate([
      mainResponse,
      disjunctiveResponse1,
      disjunctiveResponse2,
      disjunctiveResponse3]);

    expect(aggregatedResponse.disjunctiveFacets, {
      'color': {
        'red': 1,
        'green': 2,
        'blue': 3,
      },
      'brand': {
        'sony': 10,
        'apple': 20,
        'samsung': 30
      },
      'size': {
        's': 15,
        'm': 20,
        'l': 25,
      }
    });

  });
}
