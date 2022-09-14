import 'package:algolia_helper/algolia_helper.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import 'hits_searcher_test.dart';
import 'hits_searcher_test.mocks.dart';

void main() {
  group('Build facets list', () {
    test('Get facet items and select', () async {
      final searcher = mockHitsSearcher({
        'facets': {
          'color': {
            'red': 1,
            'green': 1,
            'blue': 1,
          }
        }
      });

      final facetList = FacetList(
        searcher: searcher,
        filterState: FilterState(),
        attribute: 'color',
      )..toggle('blue');

      await expectLater(
        facetList.facets,
        emitsInOrder([
          const [
            SelectableFacet(item: Facet('red', 1), isSelected: false),
            SelectableFacet(item: Facet('green', 1), isSelected: false),
            SelectableFacet(item: Facet('blue', 1), isSelected: false),
          ],
          const [
            SelectableFacet(item: Facet('red', 1), isSelected: false),
            SelectableFacet(item: Facet('green', 1), isSelected: false),
            SelectableFacet(item: Facet('blue', 1), isSelected: true),
          ]
        ]),
      );
    });

    test('Get facet items with persistent selection', () async {
      final searcher = mockHitsSearcher({
        'facets': {
          'color': {
            'red': 1,
            'green': 1,
          }
        }
      });

      final facetList = FacetList(
        searcher: searcher,
        filterState: FilterState(),
        attribute: 'color',
        persistent: true,
      )..toggle('blue');

      await expectLater(
        facetList.facets,
        emitsInOrder([
          const [
            SelectableFacet(item: Facet('red', 1), isSelected: false),
            SelectableFacet(item: Facet('green', 1), isSelected: false),
          ],
          const [
            SelectableFacet(item: Facet('blue', 0), isSelected: true),
            SelectableFacet(item: Facet('red', 1), isSelected: false),
            SelectableFacet(item: Facet('green', 1), isSelected: false),
          ]
        ]),
      );
    });

    test('Get facet items without persistent selection', () async {
      final searcher = mockHitsSearcher({
        'facets': {
          'color': {
            'red': 1,
            'green': 1,
          }
        }
      });

      final facetList = FacetList(
        searcher: searcher,
        filterState: FilterState(),
        attribute: 'color',
      )..toggle('blue');

      await expectLater(
        facetList.facets,
        emits(const [
          SelectableFacet(item: Facet('red', 1), isSelected: false),
          SelectableFacet(item: Facet('green', 1), isSelected: false),
        ]),
      );
    });
  });

  group('Update filter state', () {
    test('Selection should update filter state', () async {
      final searcher = mockHitsSearcher();
      const groupID = FilterGroupID('color', FilterOperator.or);
      final filterState = FilterState();

      FacetList.create(
        searcher: searcher,
        filterState: filterState,
        attribute: 'color',
        groupID: groupID,
      ).toggle('red');

      await expectLater(
        filterState.filters,
        emitsThrough(
          ImmutableFilters(
            facetGroups: {
              groupID: {Filter.facet('color', 'red')},
            },
          ),
        ),
      );
    });

    test('Filter State should update facets list (persistent)', () async {
      final searcher = mockHitsSearcher();

      const groupID = FilterGroupID('color', FilterOperator.or);
      final filterState = FilterState();

      final facetList = FacetList.create(
        searcher: searcher,
        filterState: filterState,
        attribute: 'color',
        groupID: groupID,
        persistent: true,
      );

      filterState.add(groupID, {Filter.facet('color', 'red')});

      await expectLater(
        facetList.facets,
        emitsThrough([
          const SelectableFacet(item: Facet('red', 0), isSelected: true),
        ]),
      );
    });

    test('Single selection should clear filters', () async {
      final searcher = mockHitsSearcher({
        'facets': {
          'color': {'red': 1}
        }
      });

      const groupID = FilterGroupID('color', FilterOperator.or);
      final filterState = FilterState()
        ..add(groupID, [
          Filter.facet('color', 'red'),
          Filter.facet('color', 'green'),
        ]);

      final facetList = FacetList.create(
        searcher: searcher,
        filterState: filterState,
        attribute: 'color',
        groupID: groupID,
        selectionMode: SelectionMode.single,
      );

      await delay();
      facetList.toggle('red');

      await expectLater(
        filterState.filters,
        emitsThrough(const ImmutableFilters()),
      );
    });

    test('Multiple selection should not clear filters', () async {
      final searcher = mockHitsSearcher({
        'facets': {
          'color': {'red': 1}
        }
      });

      const groupID = FilterGroupID('color', FilterOperator.or);
      final filterState = FilterState()
        ..add(groupID, [
          Filter.facet('color', 'red'),
          Filter.facet('color', 'green'),
        ]);

      FacetList.create(
        searcher: searcher,
        filterState: filterState,
        attribute: 'color',
        groupID: groupID,
      ).toggle('red');

      await expectLater(
        filterState.filters,
        emitsThrough(
          ImmutableFilters(
            facetGroups: {
              groupID: {Filter.facet('color', 'green')}
            },
          ),
        ),
      );
    });

    test('Facet persistent selection', () async {
      final searcher = mockHitsSearcher({
        'facets': {
          'color': {'red': 1}
        }
      });

      const groupID = FilterGroupID('color', FilterOperator.or);
      final filterState = FilterState()
        ..add(groupID, [
          Filter.facet('color', 'red'),
          Filter.facet('color', 'green'),
        ]);

      final facetList = FacetList.create(
        searcher: searcher,
        filterState: filterState,
        attribute: 'color',
        groupID: groupID,
        persistent: true,
      );

      // await for first emit, a quick select will make it skip
      await delay();
      facetList.toggle('green');

      await expectLater(
        facetList.facets,
        emitsInOrder([
          [
            const SelectableFacet(item: Facet('green', 0), isSelected: true),
            const SelectableFacet(item: Facet('red', 1), isSelected: true),
          ],
          [
            const SelectableFacet(item: Facet('red', 1), isSelected: true),
          ]
        ]),
      );
    });
  });
}

HitsSearcher mockHitsSearcher([Map<String, dynamic> json = const {}]) {
  final searchService = MockHitsSearchService();
  final initial = SearchResponse(json);
  when(searchService.search(any)).thenAnswer((_) => Stream.value(initial));

  return DefaultHitsSearcher.create(
    searchService,
    const SearchState(indexName: 'myIndex'),
  );
}
