import 'dart:math';

import 'package:algolia_helper_dart/algolia.dart';
import 'package:logging/logging.dart';
import 'package:test/test.dart';

void main() {
  test('test disjunctive faceting queries generation', () {
    final query = SearchState(indexName: 'index', query: 'phone');
    final queryBuilder = QueryBuilder(query, { 'price', 'color' }, []);
    final queries = queryBuilder.build();
    final disjunctiveFacetingQueries = queries.skip(1);
    expect(disjunctiveFacetingQueries.length, 2);
    for (final query in disjunctiveFacetingQueries) {
      expect(query.facets?.length, 1);
    }
  });

  test('test disjunctive faceting queries generation with filters', () {
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
    final queryBuilder = QueryBuilder(query, disjunctiveFacets, []);
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
  
  test('test hierarchical faceting queries generation', () {
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
    final queryBuilder = QueryBuilder(query,  {}, [hierarchicalFilter]);
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

  test('test disjunctive & hierarchical responses merging', () {

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

    final hierarchicalResponse1 = SearchResponse({});
    hierarchicalResponse1.raw['facets'] = {
      'categoryl.lvl0': {
        'home': 25,
        'electronics': 35,
        'clothes': 45,
      }
    };

    final hierarchicalResponse2 = SearchResponse({});
    hierarchicalResponse2.raw['facets'] = {
      'category.lvl1': {
        'home > kitchen': 10,
        'home > bedroom': 15,
        'electronics > portable': 28,
        'electronics > appliance': 7,
        'clothes > men': 12,
        'clothes > women': 33,
      }
    };

    final hierarchicalResponse3 = SearchResponse({});
    hierarchicalResponse3.raw['facets'] = {
      'category.lvl2': {
        'home > kitchen > accessories': 10,
        'home > bedroom > furniture': 15,
        'electronics > portable > smartphones': 20,
        'electronics > portable > laptops': 8,
        'electronics > appliance > major': 7,
        'clothes > men > shirts': 12,
        'clothes > women > dresses': 10,
        'clothes > women > jeans': 23,
      }
    };

    final hierarchicalResponse4 = SearchResponse({});
    hierarchicalResponse4.raw['facets'] = {
      'category.lvl3': {
        'home > kitchen > accessories > tableware': 10,
        'home > bedroom > furniture > beds': 10,
        'home > bedroom > furniture > others': 5,
        'electronics > portable > smartphones > ios': 8,
        'electronics > portable > smartphones > android': 12,
        'electronics > portable > laptops > gaming': 3,
        'electronics > portable > laptops > office': 5,
        'electronics > appliance > major > fridges': 5,
        'electronics > appliance > major > washing machines': 2,
        'clothes > men > shirts > casual': 6,
        'clothes > men > shirts > formal': 6,
        'clothes > women > dresses > casual': 7,
        'clothes > women > dresses > formal': 3,
        'clothes > women > jeans > regular': 9,
        'clothes > women > jeans > slim': 14,
      }
    };

    final hierarchicalFilter = HierarchicalFilter(
        ['category.lvl0', 'category.lvl1', 'category.lvl2', 'category.lvl3'],
        [
          Filter.facet('category.lvl0', 'a'),
          Filter.facet('category.lvl1', 'a > b'),
          Filter.facet('category.lvl2', 'a > b > c')
        ],
        Filter.facet('category.lvl2', 'a > b > c')
    );

    final queryBuilder = QueryBuilder(query, disjunctiveFacets, [hierarchicalFilter]);

    final aggregatedResponse = queryBuilder.merge([
      mainResponse,
      disjunctiveResponse1,
      disjunctiveResponse2,
      disjunctiveResponse3,
      hierarchicalResponse1,
      hierarchicalResponse2,
      hierarchicalResponse3,
      hierarchicalResponse4,
    ]);

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
    expect(aggregatedResponse.hierarchicalFacets, {
      'categoryl.lvl0': {
        'home': 25,
        'electronics': 35,
        'clothes': 45,
      },
      'category.lvl1': {
        'home > kitchen': 10,
        'home > bedroom': 15,
        'electronics > portable': 28,
        'electronics > appliance': 7,
        'clothes > men': 12,
        'clothes > women': 33,
      },
      'category.lvl2': {
        'home > kitchen > accessories': 10,
        'home > bedroom > furniture': 15,
        'electronics > portable > smartphones': 20,
        'electronics > portable > laptops': 8,
        'electronics > appliance > major': 7,
        'clothes > men > shirts': 12,
        'clothes > women > dresses': 10,
        'clothes > women > jeans': 23,
      },
      'category.lvl3': {
        'home > kitchen > accessories > tableware': 10,
        'home > bedroom > furniture > beds': 10,
        'home > bedroom > furniture > others': 5,
        'electronics > portable > smartphones > ios': 8,
        'electronics > portable > smartphones > android': 12,
        'electronics > portable > laptops > gaming': 3,
        'electronics > portable > laptops > office': 5,
        'electronics > appliance > major > fridges': 5,
        'electronics > appliance > major > washing machines': 2,
        'clothes > men > shirts > casual': 6,
        'clothes > men > shirts > formal': 6,
        'clothes > women > dresses > casual': 7,
        'clothes > women > dresses > formal': 3,
        'clothes > women > jeans > regular': 9,
        'clothes > women > jeans > slim': 14,
      }
    });

  });
}
