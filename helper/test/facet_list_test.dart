import 'package:algolia_helper_flutter/src/facet_list.dart';
import 'package:algolia_helper_flutter/src/filter.dart';
import 'package:algolia_helper_flutter/src/filter_group.dart';
import 'package:algolia_helper_flutter/src/filter_state.dart';
import 'package:algolia_helper_flutter/src/filter_state_group_accessor.dart';
import 'package:algolia_helper_flutter/src/filters.dart';
import 'package:algolia_helper_flutter/src/hits_searcher_facet_list_extension.dart';
import 'package:algolia_helper_flutter/src/model/facet.dart';
import 'package:algolia_helper_flutter/src/model/multi_search_response.dart';
import 'package:algolia_helper_flutter/src/model/multi_search_state.dart';
import 'package:algolia_helper_flutter/src/searcher/hits_searcher.dart';
import 'package:algolia_insights/algolia_insights.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:rxdart/rxdart.dart';
import 'package:test/test.dart';

import 'facet_list_test.mocks.dart';
import 'hits_searcher_test.dart';
import 'hits_searcher_test.mocks.dart';

@GenerateMocks([FacetList, FilterEventTracker])
void main() {
  group('Build facets list', () {
    test('Get facet items and select', () async {
      final facetStream = Stream<List<Facet>>.value(
        [
          const Facet('red', 1),
          const Facet('green', 1),
          const Facet('blue', 1),
        ],
      );

      final facetList = FacetList(
        facetsStream: facetStream,
        state: MockSelectionState(),
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
      final facetStream = Stream<List<Facet>>.value(
        [
          const Facet('red', 1),
          const Facet('green', 1),
        ],
      );

      final facetList = FacetList(
        facetsStream: facetStream,
        state: MockSelectionState(),
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
      final facetStream = Stream<List<Facet>>.value(
        [
          const Facet('red', 1),
          const Facet('green', 1),
        ],
      );

      final facetList = FacetList(
        facetsStream: facetStream,
        state: MockSelectionState(),
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
      final filterState = FilterState();

      // Create a disjunctive FacetList
      searcher.buildFacetList(
        filterState: filterState,
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
      searcher.buildFacetList(
        filterState: filterState,
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
      searcher.buildFacetList(filterState: filterState, attribute: 'brand');

      expect(
        searcher.snapshot(),
        const SearchState(
          indexName: 'myIndex',
          facets: ['color', 'type', 'brand'],
          disjunctiveFacets: {'color', 'brand'},
        ),
      );
    });

    test('Build FacetList without EventTracker', () {
      final searcher = HitsSearcher.custom(
        MockHitsSearchService(),
        null,
        const SearchState(indexName: 'myIndex'),
      );

      final filterState = FilterState();

      // Create a disjunctive FacetList
      searcher.buildFacetList(
        filterState: filterState,
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
    });
  });

  group('Update filter state', () {
    test('Selection should update filter state', () async {
      final facetStream = Stream<List<Facet>>.value(
        [
          const Facet('red', 1),
          const Facet('green', 1),
          const Facet('blue', 1),
        ],
      );

      const groupID = FilterGroupID('color', FilterOperator.or);
      final filterState = FilterState();

      final filterSelectionState = FiltersGroupAccessor(
        filterState: filterState,
        groupID: groupID,
        attribute: 'color',
      );

      FacetList(
        facetsStream: facetStream,
        state: filterSelectionState,
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
      final facetStream = Stream<List<Facet>>.value([]);

      const groupID = FilterGroupID('color', FilterOperator.or);
      final filterState = FilterState();

      final filterSelectionState = FiltersGroupAccessor(
        filterState: filterState,
        groupID: groupID,
        attribute: 'color',
      );

      final facetList = FacetList(
        facetsStream: facetStream,
        state: filterSelectionState,
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
      final facetStream = Stream<List<Facet>>.value(
        [
          const Facet('red', 1),
        ],
      );

      const groupID = FilterGroupID('color', FilterOperator.or);
      final filterState = FilterState()
        ..add(groupID, [
          Filter.facet('color', 'red'),
          Filter.facet('color', 'green'),
        ]);

      final filterSelectionState = FiltersGroupAccessor(
        filterState: filterState,
        groupID: groupID,
        attribute: 'color',
      );

      final facetList = FacetList(
        facetsStream: facetStream,
        state: filterSelectionState,
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
      final facetStream = Stream<List<Facet>>.value(
        [
          const Facet('red', 1),
        ],
      );

      const groupID = FilterGroupID('color', FilterOperator.or);
      final filterState = FilterState()
        ..add(groupID, [
          Filter.facet('color', 'red'),
          Filter.facet('color', 'green'),
        ]);

      final filterSelectionState = FiltersGroupAccessor(
        filterState: filterState,
        groupID: groupID,
        attribute: 'color',
      );

      final facetList = FacetList(
        facetsStream: facetStream,
        state: filterSelectionState,
      );

      await delay();
      facetList.toggle('red');

      await expectLater(
        filterState.filters,
        emitsThrough(
          StatelessFilters(
            facetGroups: {
              groupID: {Filter.facet('color', 'green')},
            },
          ),
        ),
      );
    });

    test('Facet persistent selection', () async {
      final facetStream = Stream<List<Facet>>.value(
        [
          const Facet('red', 1),
        ],
      );

      const groupID = FilterGroupID('color', FilterOperator.or);
      final filterState = FilterState()
        ..add(groupID, [
          Filter.facet('color', 'red'),
          Filter.facet('color', 'green'),
        ]);

      final filterSelectionState = FiltersGroupAccessor(
        filterState: filterState,
        groupID: groupID,
        attribute: 'color',
      );

      final facetList = FacetList(
        facetsStream: facetStream,
        state: filterSelectionState,
        persistent: true,
      );

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
      await delay();
    });
  });

  test('Should pass clicked facet values to event tracker', () async {
    final facetStream = Stream<List<Facet>>.value(
      [
        const Facet('red', 1),
      ],
    );

    final eventTracker = MockEventTracker();

    when(
      eventTracker.clickedFilters(
        indexName: '',
        eventName: '',
        attribute: '',
        values: [],
      ),
    ).thenAnswer((realInvocation) {
      expect(realInvocation.positionalArguments[0], 'Filter Applied');
      expect(realInvocation.positionalArguments[1], 'color');
      expect(realInvocation.positionalArguments[2], 'red');
    });

    FacetList(
      facetsStream: facetStream,
      state: MockSelectionState(),
      persistent: true,
      eventTracker: FilterEventTracker(
        eventTracker,
        MockEventDataDelegate('test-index', 'test-query-id'),
        'color',
      ),
    ).toggle('red');
  });

  group('FilterTracking', () {
    late MockFacetList facetList;
    late MockFilterEventTracker eventTracker;

    setUp(() {
      eventTracker = MockFilterEventTracker();
      facetList = MockFacetList();
      // when(facetList.attribute).thenReturn('color');
      when(facetList.eventTracker).thenReturn(eventTracker);
    });

    test('clickedFilters', () {
      facetList.eventTracker?.clickedFilters(
        eventName: 'Filter Selected',
        values: ['red'],
      );
      verify(
        eventTracker.clickedFilters(
          eventName: 'Filter Selected',
          values: ['red'],
        ),
      ).called(1);
    });

    test('viewedFilters', () {
      facetList.eventTracker?.viewedFilters(
        eventName: 'Product View',
        values: ['green'],
      );
      verify(
        eventTracker.viewedFilters(
          eventName: 'Product View',
          values: ['green'],
        ),
      ).called(1);
    });

    test('convertedFilters', () {
      facetList.eventTracker?.convertedFilters(
        eventName: 'Conversion',
        values: ['blue', 'green'],
      );
      verify(
        eventTracker.convertedFilters(
          eventName: 'Conversion',
          values: ['blue', 'green'],
        ),
      ).called(1);
    });
  });

  test('Toggle two facets', () async {
    final searcher = mockHitsSearcher({
      'facets': {
        'color': {
          'red': 1,
          'green': 1,
          'blue': 1,
        },
      },
    });

    final filterState = FilterState();
    final facetList = searcher.buildFacetList(
      filterState: filterState,
      attribute: 'color',
    );

    final toggleFacets = ['red', 'blue'];
    await delay();

    for (final facet in toggleFacets) {
      facetList.toggle(facet);
    }
    await delay();
    final filters = filterState.snapshot();
    expect(filters.facetGroups, {
      const FilterGroupID('color', FilterOperator.or): {
        Filter.facet('color', 'red'),
        Filter.facet('color', 'blue'),
      },
    });
  });
}

class MockSelectionState implements SelectionState {
  MockSelectionState() {
    _selectionsSubject.add(<String>{});
  }

  @override
  void setSelections(
    Set<String> selections,
  ) =>
      _selectionsSubject.add(selections);

  final BehaviorSubject<Set<String>> _selectionsSubject =
      BehaviorSubject<Set<String>>();

  @override
  Stream<Set<String>> get selectionsStream => _selectionsSubject.stream;

  @override
  Set<String> get selections => _selectionsSubject.value;
}

class MockEventDataDelegate implements EventDataDelegate {
  @override
  String indexName;

  @override
  String? queryID;

  MockEventDataDelegate(this.indexName, this.queryID);
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
