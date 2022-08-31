import 'package:algolia_helper/algolia_helper.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import 'hits_searcher_test.mocks.dart';

void main() {
  group('Build facets list', () {
    test('Get facet items', () async {
      final searchService = MockHitsSearchService();
      final initial = SearchResponse(const {
        'facets': {
          'color': {
            'red': 1,
            'green': 1,
            'blue': 1,
          }
        }
      });
      when(searchService.search(any)).thenAnswer((_) => Stream.value(initial));

      final searcher = HitsSearcher.build(
        searchService,
        const SearchState(indexName: 'myIndex'),
      );

      final filterState = FilterState();

      final facetList = FacetList(
        searcher: searcher,
        filterState: filterState,
        attribute: 'color',
      )..select('blue');

      await expectLater(
        facetList.facets,
        emits(const [
          SelectableFacet(item: Facet('red', 1), isSelected: false),
          SelectableFacet(item: Facet('green', 1), isSelected: false),
          SelectableFacet(item: Facet('blue', 1), isSelected: true),
        ]),
      );
    });
    test('Get facet items with persistent selection', () async {
      final searchService = MockHitsSearchService();
      final initial = SearchResponse(const {
        'facets': {
          'color': {
            'red': 1,
            'green': 1,
          }
        }
      });
      when(searchService.search(any)).thenAnswer((_) => Stream.value(initial));

      final searcher = HitsSearcher.build(
        searchService,
        const SearchState(indexName: 'myIndex'),
      );

      final filterState = FilterState();

      final facetList = FacetList(
        searcher: searcher,
        filterState: filterState,
        attribute: 'color',
        persistent: true,
      )..select('blue');

      await expectLater(
        facetList.facets,
        emits(const [
          SelectableFacet(item: Facet('red', 1), isSelected: false),
          SelectableFacet(item: Facet('green', 1), isSelected: false),
          SelectableFacet(item: Facet('blue', 0), isSelected: true),
        ]),
      );
    });
    test('Get facet items without persistent selection', () async {
      final searchService = MockHitsSearchService();
      final initial = SearchResponse(const {
        'facets': {
          'color': {
            'red': 1,
            'green': 1,
          }
        }
      });
      when(searchService.search(any)).thenAnswer((_) => Stream.value(initial));

      final searcher = HitsSearcher.build(
        searchService,
        const SearchState(indexName: 'myIndex'),
      );

      final filterState = FilterState();

      final facetList = FacetList(
          searcher: searcher, filterState: filterState, attribute: 'color')
        ..select('blue');

      await expectLater(
        facetList.facets,
        emits(const [
          SelectableFacet(item: Facet('red', 1), isSelected: false),
          SelectableFacet(item: Facet('green', 1), isSelected: false),
        ]),
      );
    });
  });
}
