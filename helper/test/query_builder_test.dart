import 'package:algolia_helper_flutter/src/filter.dart';
import 'package:algolia_helper_flutter/src/filter_group.dart';
import 'package:algolia_helper_flutter/src/model/facet.dart';
import 'package:algolia_helper_flutter/src/model/multi_search_response.dart';
import 'package:algolia_helper_flutter/src/model/multi_search_state.dart';
import 'package:algolia_helper_flutter/src/query_builder.dart';
import 'package:test/test.dart';

void main() {
  test('test disjunctive faceting queries generation', () {
    const query = SearchState(
      indexName: 'index',
      query: 'phone',
      disjunctiveFacets: {'price', 'color'},
    );
    const queryBuilder = QueryBuilder(query);
    final queries = queryBuilder.build();
    final disjunctiveFacetingQueries = queries.skip(1);
    expect(disjunctiveFacetingQueries.length, 2);
    for (final query in disjunctiveFacetingQueries) {
      expect(query.facets?.length, 1);
    }
  });

  test('test disjunctive faceting queries generation with filters', () {
    final filterGroups = <FilterGroup>{
      FacetFilterGroup(FilterGroupID.or('g1'), {
        Filter.facet('price', 100),
        Filter.facet('color', 'green'),
        Filter.facet('size', '44'),
      }),
      FacetFilterGroup(FilterGroupID.or('g2'), {
        Filter.facet('type', 'phone'),
      }),
      FacetFilterGroup(FilterGroupID.and('g3'), {
        Filter.facet('brand', 'samsung'),
        Filter.facet('color', 'red'),
        Filter.facet('promo', true),
        Filter.facet('rating', 4.2),
      }),
    };
    final query = SearchState(
      indexName: 'index',
      query: 'phone',
      disjunctiveFacets: {'price', 'color', 'brand'},
      filterGroups: filterGroups,
    );
    final queryBuilder = QueryBuilder(query);
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
          expect(
            query.filterGroups!.first
                .whereType<Filter>()
                .map((f) => f.attribute)
                .contains('price'),
            false,
          );
          break;

        case 2:
          expect(query.facets, ['color']);
          expect(
            query.filterGroups!.first
                .whereType<Filter>()
                .map((f) => f.attribute)
                .contains('color'),
            false,
          );
          break;

        case 3:
          expect(query.facets, ['brand']);
          expect(
            query.filterGroups!.first
                .whereType<Filter>()
                .map((f) => f.attribute)
                .contains('brand'),
            false,
          );
          break;

        default:
          break;
      }
    });

    final disjunctiveFacetingQueries = queries.skip(1);
    for (final query in disjunctiveFacetingQueries) {
      final facet = query.facets!.first;
      final group1 = query.filterGroups
          ?.firstWhere((g) => g.groupID.name == 'g1') as FacetFilterGroup;
      final group2 = query.filterGroups
          ?.firstWhere((g) => g.groupID.name == 'g2') as FacetFilterGroup;
      final group3 = query.filterGroups
          ?.firstWhere((g) => g.groupID.name == 'g3') as FacetFilterGroup;
      expect(group1.map((f) => f.attribute).contains(facet), false);
      expect(group2.length, 1);
      expect(group3.length, 4);
    }
  });

  test('test hierarchical faceting queries generation', () {
    const lvl0 = 'category.lvl0';
    const lvl1 = 'category.lvl1';
    const lvl2 = 'category.lvl2';
    const lvl3 = 'category.lvl3';

    final attributes = [lvl0, lvl1, lvl2, lvl3];
    final path = [
      Filter.facet(lvl0, 'a'),
      Filter.facet(lvl1, 'a > b'),
      Filter.facet(lvl2, 'a > b > c'),
    ];

    final colorGroup = FacetFilterGroup(
      const FilterGroupID('color'),
      {Filter.facet('color', 'red')},
    );
    final hierarchicalGroup = FilterGroup.hierarchical(
      name: 'h',
      path: path,
      attributes: attributes,
      filters: {Filter.facet(lvl2, 'a > b > c')},
    );
    final filterGroups = <FilterGroup>{colorGroup, hierarchicalGroup};

    final query = SearchState(
      indexName: 'index',
      query: 'phone',
      filterGroups: filterGroups,
    );
    final queryBuilder = QueryBuilder(query);
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
          expect(
            query.filterGroups!.first.groupID,
            const FilterGroupID('color'),
          );
          expect(
            query.filterGroups!.first,
            {Filter.facet('color', 'red')},
          );
          break;

        case 2:
          expect(query.facets, [lvl1]);
          expect(query.filterGroups!.length, 2);
          expect(
            query.filterGroups!.first.groupID,
            const FilterGroupID('color'),
          );
          expect(
            query.filterGroups!.first,
            {Filter.facet('color', 'red')},
          );
          expect(
            query.filterGroups!.last.groupID,
            const FilterGroupID('_hierarchical'),
          );
          expect(query.filterGroups!.last, {Filter.facet(lvl0, 'a')});
          break;

        case 3:
          expect(query.facets, [lvl2]);
          expect(query.filterGroups!.length, 2);
          expect(
            query.filterGroups!.first.groupID,
            const FilterGroupID('color'),
          );
          expect(
            query.filterGroups!.first,
            {Filter.facet('color', 'red')},
          );
          expect(
            query.filterGroups!.last.groupID,
            const FilterGroupID('_hierarchical'),
          );
          expect(
            query.filterGroups!.last,
            {Filter.facet(lvl1, 'a > b')},
          );
          break;

        case 4:
          expect(query.facets, [lvl3]);
          expect(query.filterGroups!.length, 2);
          expect(
            query.filterGroups!.first.groupID,
            const FilterGroupID('color'),
          );
          expect(
            query.filterGroups!.first,
            {Filter.facet('color', 'red')},
          );
          expect(
            query.filterGroups!.last.groupID,
            const FilterGroupID('_hierarchical'),
          );
          expect(
            query.filterGroups!.last,
            {Filter.facet(lvl2, 'a > b > c')},
          );
          break;

        default:
          break;
      }
    });
  });

  test('test disjunctive & hierarchical responses merging', () {
    final query = SearchState(
      indexName: 'index',
      query: 'phone',
      disjunctiveFacets: {'color', 'brand', 'size'},
      filterGroups: {
        FilterGroup.hierarchical(
          name: 'category',
          filters: {Filter.facet('category.lvl2', 'a > b > c')},
          path: [
            Filter.facet('category.lvl0', 'a'),
            Filter.facet('category.lvl1', 'a > b'),
            Filter.facet('category.lvl2', 'a > b > c'),
          ],
          attributes: [
            'category.lvl0',
            'category.lvl1',
            'category.lvl2',
            'category.lvl3',
          ],
        ),
      },
    );

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
      'brand': {'sony': 10, 'apple': 20, 'samsung': 30},
    };
    final disjunctiveResponse3 = SearchResponse({});
    disjunctiveResponse3.raw['facets'] = {
      'size': {
        's': 15,
        'm': 20,
        'l': 25,
      },
    };

    final hierarchicalResponse1 = SearchResponse({});
    hierarchicalResponse1.raw['facets'] = {
      'categoryl.lvl0': {
        'home': 25,
        'electronics': 35,
        'clothes': 45,
      },
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
      },
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
      },
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
      },
    };

    final queryBuilder = QueryBuilder(query);

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

    expect(aggregatedResponse.disjunctiveFacets, const {
      'color': [
        Facet('red', 1),
        Facet('green', 2),
        Facet('blue', 3),
      ],
      'brand': [
        Facet('sony', 10),
        Facet('apple', 20),
        Facet('samsung', 30),
      ],
      'size': [
        Facet('s', 15),
        Facet('m', 20),
        Facet('l', 25),
      ],
    });

    expect(aggregatedResponse.disjunctiveFacets, const {
      'color': [
        Facet('red', 1),
        Facet('green', 2),
        Facet('blue', 3),
      ],
      'brand': [
        Facet('sony', 10),
        Facet('apple', 20),
        Facet('samsung', 30),
      ],
      'size': [
        Facet('s', 15),
        Facet('m', 20),
        Facet('l', 25),
      ],
    });
    expect(aggregatedResponse.hierarchicalFacets, const {
      'categoryl.lvl0': [
        Facet('home', 25),
        Facet('electronics', 35),
        Facet('clothes', 45),
      ],
      'category.lvl1': [
        Facet('home > kitchen', 10),
        Facet('home > bedroom', 15),
        Facet('electronics > portable', 28),
        Facet('electronics > appliance', 7),
        Facet('clothes > men', 12),
        Facet('clothes > women', 33),
      ],
      'category.lvl2': [
        Facet('home > kitchen > accessories', 10),
        Facet('home > bedroom > furniture', 15),
        Facet('electronics > portable > smartphones', 20),
        Facet('electronics > portable > laptops', 8),
        Facet('electronics > appliance > major', 7),
        Facet('clothes > men > shirts', 12),
        Facet('clothes > women > dresses', 10),
        Facet('clothes > women > jeans', 23),
      ],
      'category.lvl3': [
        Facet('home > kitchen > accessories > tableware', 10),
        Facet('home > bedroom > furniture > beds', 10),
        Facet('home > bedroom > furniture > others', 5),
        Facet('electronics > portable > smartphones > ios', 8),
        Facet('electronics > portable > smartphones > android', 12),
        Facet('electronics > portable > laptops > gaming', 3),
        Facet('electronics > portable > laptops > office', 5),
        Facet('electronics > appliance > major > fridges', 5),
        Facet('electronics > appliance > major > washing machines', 2),
        Facet('clothes > men > shirts > casual', 6),
        Facet('clothes > men > shirts > formal', 6),
        Facet('clothes > women > dresses > casual', 7),
        Facet('clothes > women > dresses > formal', 3),
        Facet('clothes > women > jeans > regular', 9),
        Facet('clothes > women > jeans > slim', 14),
      ],
    });
  });
}
