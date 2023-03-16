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

    test('Build FacetList with conjunctive/disjunctive facets', () {
      final searcher = mockHitsSearcher();

      // Create a disjunctive FacetList
      FacetList(
        searcher: searcher,
        filterState: FilterState(),
        attribute: 'color',
      );

      expect(
        searcher.snapshot(),
        const SearchState(
          indexName: 'myIndex',
          facets: ['color'],
          disjunctiveFacets: {'color'},
        ),
      );

      // Create a conjunctive FacetList
      FacetList(
        searcher: searcher,
        filterState: FilterState(),
        attribute: 'type',
        operator: FilterOperator.and,
      );

      expect(
        searcher.snapshot(),
        const SearchState(
          indexName: 'myIndex',
          facets: ['color', 'type'],
          disjunctiveFacets: {'color'},
        ),
      );

      // Create another disjunctive FacetList
      FacetList(
        searcher: searcher,
        filterState: FilterState(),
        attribute: 'brand',
      );

      expect(
        searcher.snapshot(),
        const SearchState(
          indexName: 'myIndex',
          facets: ['color', 'type', 'brand'],
          disjunctiveFacets: {'color', 'brand'},
        ),
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
          StatelessFilters(
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
        emitsThrough(StatelessFilters()),
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
          StatelessFilters(
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

  test('Should pass clicked facet values to event tracker', () async {
    final searchService = MockHitsSearchService();
    final initial = SearchResponse({
      'facets': {
        'color': {'red': 1}
      }
    });
    when(searchService.search(any)).thenAnswer((_) => Future.value(initial));
    final eventTracker = MockEventTracker();

    when(eventTracker.clickedFilter()).thenAnswer((realInvocation) {
      expect(realInvocation.positionalArguments[0], 'Filter Applied');
      expect(realInvocation.positionalArguments[1], 'color');
      expect(realInvocation.positionalArguments[2], 'red');
    });

    final searcher = HitsSearcher.custom(
      searchService,
      eventTracker,
      const SearchState(indexName: 'myIndex'),
    );

    const groupID = FilterGroupID('color', FilterOperator.or);
    final filterState = FilterState()
      ..add(groupID, [
        Filter.facet('color', 'green'),
      ]);

    FacetList.create(
      searcher: searcher,
      filterState: filterState,
      attribute: 'color',
      groupID: groupID,
      persistent: true,
    ).toggle('red');
  });
}

HitsSearcher mockHitsSearcher([Map<String, dynamic> json = const {}]) {
  final searchService = MockHitsSearchService();
  final initial = SearchResponse(json);
  when(searchService.search(any)).thenAnswer((_) => Future.value(initial));
  final eventTracker = MockEventTracker();

  return HitsSearcher.custom(
    searchService,
    eventTracker,
    const SearchState(indexName: 'myIndex'),
  );
}
