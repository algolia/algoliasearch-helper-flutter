import 'package:algolia_client_composition/algolia_client_composition.dart'
    as composition;
import 'package:algolia_helper_flutter/src/exception.dart';
import 'package:algolia_helper_flutter/src/filter.dart';
import 'package:algolia_helper_flutter/src/filter_group.dart';
import 'package:algolia_helper_flutter/src/model/composition_facet_search_state.dart';
import 'package:algolia_helper_flutter/src/model/composition_state.dart';
import 'package:algolia_helper_flutter/src/service/composition_client_extensions.dart';
import 'package:test/test.dart';

void main() {
  group('CompositionState.toRequestBody', () {
    test('maps basic params', () {
      const state = CompositionState(
        compositionID: 'my-composition',
        query: 'shoes',
        page: 2,
        hitsPerPage: 20,
        userToken: 'user-1',
        clickAnalytics: true,
        enablePersonalization: true,
        sortBy: 'Price (asc)',
        relevancyStrictness: 90,
      );

      final params = state.toRequestBody().params!;

      expect(params.query, 'shoes');
      expect(params.page, 2);
      expect(params.hitsPerPage, 20);
      expect(params.userToken, 'user-1');
      expect(params.clickAnalytics, true);
      expect(params.enablePersonalization, true);
      expect(params.sortBy, 'Price (asc)');
      expect(params.relevancyStrictness, 90);
    });

    test('converts filter groups to SQL filters string', () {
      final state = CompositionState(
        compositionID: 'my-composition',
        filterGroups: {
          FilterGroup.facet(filters: {Filter.facet('attributeA', 0)}),
          FilterGroup.tag(
            operator: FilterOperator.or,
            filters: {Filter.tag('unknown')},
          ),
        },
      );

      final params = state.toRequestBody().params!;

      expect(
        params.filters,
        '("attributeA":0) AND (_tags:"unknown")',
      );
    });

    test('annotates disjunctive facets only when a value is selected', () {
      final state = CompositionState(
        compositionID: 'my-composition',
        facets: const ['brand'],
        disjunctiveFacets: const {'color', 'size'},
        filterGroups: {
          FilterGroup.facet(
            name: 'color',
            operator: FilterOperator.or,
            filters: {Filter.facet('color', 'red')},
          ),
        },
      );

      final params = state.toRequestBody().params!;

      // `color` is refined -> annotated; `size` has no selection -> plain.
      expect(
        params.facets,
        ['brand', 'disjunctive(color)', 'size'],
      );
    });

    test('collapses to wildcard when `*` is present', () {
      const state = CompositionState(
        compositionID: 'my-composition',
        facets: ['*', 'brand'],
      );

      final params = state.toRequestBody().params!;

      expect(params.facets, ['*']);
    });

    test('facets is null when no facets are set', () {
      const state = CompositionState(compositionID: 'my-composition');
      final params = state.toRequestBody().params!;
      expect(params.facets, isNull);
    });

    test('converts language codes and injected items', () {
      const state = CompositionState(
        compositionID: 'my-composition',
        queryLanguages: ['en', 'fr'],
        naturalLanguages: ['de'],
        injectedItems: {
          'group-a': {
            'items': [
              {'objectID': 'o1', 'position': 1},
            ],
          },
        },
      );

      final params = state.toRequestBody().params!;

      expect(params.queryLanguages, [
        composition.SupportedLanguage.en,
        composition.SupportedLanguage.fr,
      ]);
      expect(params.naturalLanguages, [composition.SupportedLanguage.de]);
      expect(params.injectedItems, isNotNull);
      expect(params.injectedItems!['group-a'], isNotNull);
    });
  });

  group('CompositionFacetSearchState.toRequest', () {
    test('maps facet query and underlying search params', () {
      const state = CompositionFacetSearchState(
        compositionID: 'my-composition',
        facet: 'brand',
        facetQuery: 'sams',
        state: CompositionState(
          compositionID: 'my-composition',
          query: 'phone',
        ),
      );

      final request = state.toRequest();

      expect(request.params?.query, 'sams');
      expect(request.params?.searchQuery?.query, 'phone');
    });
  });

  group('composition response mapping', () {
    test('single result exposes hits and no feeds', () {
      final response = composition.SearchResponse(
        results: [
          const composition.SearchResultsItem(
            compositions: {},
            hits: [composition.Hit(objectID: '1')],
            nbHits: 1,
            query: 'shoes',
          ),
        ],
      ).toCompositionResponse();

      expect(response.hits.length, 1);
      expect(response.hits.first['objectID'], '1');
      expect(response.nbHits, 1);
      expect(response.query, 'shoes');
      expect(response.feeds, isNull);
    });

    test('multifeed results expose ordered feeds', () {
      final response = composition.SearchResponse(
        results: [
          const composition.SearchResultsItem(
            compositions: {},
            hits: [composition.Hit(objectID: '1')],
            nbHits: 100,
            feedID: 'products',
          ),
          const composition.SearchResultsItem(
            compositions: {},
            hits: [composition.Hit(objectID: '2')],
            nbHits: 50,
            feedID: 'articles',
          ),
        ],
      ).toCompositionResponse();

      expect(response.feeds, isNotNull);
      expect(response.feeds!.length, 2);
      expect(response.feeds!.first.feedID, 'products');
      expect(response.feeds!.first.nbHits, 100);
      expect(response.feeds!.last.feedID, 'articles');
      expect(response.feeds!.last.nbHits, 50);
      // Primary response points to the first feed.
      expect(response.feedID, 'products');
      expect(response.nbHits, 100);
    });

    test('empty results produce an empty response', () {
      final response = composition.SearchResponse(results: const [])
          .toCompositionResponse();
      expect(response.hits, isEmpty);
      expect(response.feeds, isNull);
    });
  });

  group('composition facet response mapping', () {
    test('maps facet hits from the first result', () {
      final response = composition.SearchForFacetValuesResponse(
        results: const [
          composition.SearchForFacetValuesResults(
            indexName: 'my-index',
            exhaustiveFacetsCount: true,
            facetHits: [
              composition.FacetHits(
                value: 'samsung',
                highlighted: 'samsung',
                count: 5,
              ),
            ],
          ),
        ],
      ).toFacetSearchResponse();

      expect(response.facetHits.length, 1);
      expect(response.facetHits.first.value, 'samsung');
      expect(response.facetHits.first.count, 5);
    });
  });

  group('launderCompositionException', () {
    test('wraps arbitrary errors into a SearchError', () {
      final error = launderCompositionException('boom');
      expect(error, isA<SearchError>());
      expect((error as SearchError).statusCode, 0);
    });
  });
}
