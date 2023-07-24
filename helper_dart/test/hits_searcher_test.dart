import 'dart:async';

import 'package:algolia_helper/algolia_helper.dart';
import 'package:algolia_helper/src/service/algolia_client_helper.dart';
import 'package:algolia_helper/src/service/hits_search_service.dart';
import 'package:algolia_insights/algolia_insights.dart';
import 'package:algolia_insights/src/event_service.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import 'hits_searcher_test.mocks.dart';

@GenerateMocks([
  HitsSearcher,
  HitsSearchService,
  EventTracker,
  EventService,
])
void main() {
  group('Integration tests', () {
    test('Successful search operation', () async {
      final helper = HitsSearcher.create(
        applicationID: 'latency',
        apiKey: 'af044fb0788d6bb15f807e4420592bc5',
        state: const SearchState(
          indexName: 'instant_search',
          query: 'apple',
          hitsPerPage: 1,
        ),
      );

      final response = await helper.responses.take(1).first;
      expect(response.hits.length, 1);
      expect(response.query, 'apple');
    });

    test('Failing search operation', () async {
      final helper = HitsSearcher(
        applicationID: 'latency',
        apiKey: 'UNKNOWN',
        indexName: 'instant_search',
      );
      await expectLater(helper.responses, emitsError(anything));
    });
  });

  group('Unit tests', () {
    test('Should emit initial response', () async {
      final searchService = MockHitsSearchService();
      final initial = SearchResponse(const {});
      when(searchService.search(any)).thenAnswer((_) => Future.value(initial));
      final eventTracker = MockEventTracker();
      final searcher = HitsSearcher.custom(
        searchService,
        eventTracker,
        const SearchState(indexName: 'myIndex'),
      );

      await expectLater(searcher.responses, emits(initial)); // initial response
    });

    test('Should emit response after query', () async {
      final searchService = MockHitsSearchService();
      final eventTracker = MockEventTracker();
      final searcher = HitsSearcher.custom(
        searchService,
        eventTracker,
        const SearchState(indexName: 'myIndex'),
      );

      when(searchService.search(any)).thenAnswer(mockResponse);
      const query = 'cat';
      searcher.query(query);

      await expectLater(searcher.responses, emits(matchesQuery('cat')));
    });

    test('Should emit error after failure', () async {
      final searchService = MockHitsSearchService();
      when(searchService.search(any))
          .thenAnswer((_) => Future.value(SearchResponse({})));
      final eventTracker = MockEventTracker();
      final searcher = HitsSearcher.custom(
        searchService,
        eventTracker,
        const SearchState(indexName: 'myIndex'),
      );

      when(searchService.search(any))
          .thenAnswer((Invocation inv) => throw SearchError({}, 500));
      searcher.query('cat');

      await expectLater(searcher.responses, emitsError(isA<SearchError>()));
    });

    test('Should debounce search state', () async {
      final searchService = MockHitsSearchService();
      when(searchService.search(any)).thenAnswer(mockResponse);
      final eventTracker = MockEventTracker();

      final searcher = HitsSearcher.custom(
        searchService,
        eventTracker,
        const SearchState(indexName: 'myIndex'),
      );

      unawaited(
        expectLater(
          searcher.responses,
          emitsInOrder([emits(matchesQuery('cat'))]),
        ),
      );

      searcher
        ..query('c')
        ..query('ca')
        ..query('cat');
    });

    test("Shouldn't debounce search state", () async {
      final searchService = MockHitsSearchService();
      when(searchService.search(any)).thenAnswer(mockResponse);
      final eventTracker = MockEventTracker();

      final searcher = HitsSearcher.custom(
        searchService,
        eventTracker,
        const SearchState(indexName: 'myIndex'),
      );

      unawaited(
        expectLater(
          searcher.responses,
          emitsInOrder([
            emits(matchesQuery('c')),
            emits(matchesQuery('ca')),
            emits(matchesQuery('cat'))
          ]),
        ),
      );

      searcher.query('c');
      await delay();
      searcher.query('ca');
      await delay();
      searcher.query('cat');
      await delay();
      searcher.dispose();
    });

    test('Should discard old requests', () async {
      final searchService = MockHitsSearchService();
      when(searchService.search(any)).thenAnswer(mockResponse);
      final eventTracker = MockEventTracker();

      final searcher = HitsSearcher.custom(
        searchService,
        eventTracker,
        const SearchState(indexName: 'myIndex'),
      );

      unawaited(
        expectLater(
          searcher.responses,
          emitsInOrder([emits(matchesQuery('cat'))]),
        ),
      );

      searcher.query('c');
      await delay(50);
      searcher.query('ca');
      await delay(50);
      searcher.query('cat');
      await delay(50);
    });

    test('Should rerun requests', () async {
      final searchService = MockHitsSearchService();
      when(searchService.search(any)).thenAnswer(mockResponse);
      final eventTracker = MockEventTracker();

      final searcher = HitsSearcher.custom(
        searchService,
        eventTracker,
        const SearchState(indexName: 'myIndex'),
      );

      // searcher.responses.listen(print);

      unawaited(
        expectLater(
          searcher.responses,
          emitsInOrder([
            emits(matchesQuery('cat')),
            emits(matchesQuery('cat')),
          ]),
        ),
      );

      searcher.query('cat');
      await delay();
      searcher.query('cat'); // should be ignored
      await delay();
      searcher.rerun();
      await delay();
    });
  });

  test('Should pass received hits to event tracker', () async {
    final searchService = MockHitsSearchService();
    when(searchService.search(any)).thenAnswer(mockResponse);

    final eventTracker = MockEventTracker();
    when(
      eventTracker.viewedObjects(
        indexName: '',
        eventName: '',
        objectIDs: [],
      ),
    ).thenAnswer((realInvocation) {
      expect(realInvocation.positionalArguments[0], 'Hits Viewed');
      expect(realInvocation.positionalArguments[1], ['h1', 'h2']);
    });

    const initSearchState = SearchState(indexName: 'myIndex');
    final searcher = HitsSearcher.custom(
      searchService,
      eventTracker,
      initSearchState,
    )..query('q');

    await delay();
    searcher.dispose();
  });

  test('FilterState connect HitsSearcher', () async {
    final searchService = MockHitsSearchService();
    when(searchService.search(any)).thenAnswer(mockResponse);
    final eventTracker = MockEventTracker();

    const initSearchState = SearchState(indexName: 'myIndex');
    final searcher = HitsSearcher.custom(
      searchService,
      eventTracker,
      initSearchState,
    );

    final groupColors = FilterGroupID.and('colors');
    final facetColorRed = Filter.facet('color', 'red');
    final filterState = FilterState()..add(groupColors, {facetColorRed});

    searcher.connectFilterState(filterState);
    await delay();

    final updated = initSearchState.copyWith(
      filterGroups: {
        FacetFilterGroup(groupColors, {facetColorRed})
      },
    );
    final snapshot = searcher.snapshot();
    expect(snapshot, updated);

    searcher.dispose();
  });

  test('Filter Groups to filters', () {
    final state = SearchState(
      indexName: 'indexName',
      filterGroups: {
        FilterGroup.facet(filters: {Filter.facet('attributeA', 0)}),
        FilterGroup.facet(
          operator: FilterOperator.or,
          filters: {Filter.facet('attributeA', 0)},
        ),
        FilterGroup.tag(
          operator: FilterOperator.or,
          filters: {Filter.tag('unknown')},
        ),
        FilterGroup.numeric(
          operator: FilterOperator.or,
          filters: {Filter.range('attributeA', lowerBound: 0, upperBound: 1)},
        ),
      },
    );

    final query = state.toRequest();
    expect(
      query.filters,
      '("attributeA":0) AND ("attributeA":0) '
      'AND (_tags:"unknown") AND ("attributeA":0 TO 1)',
    );
  });

  group('HitsTracking', () {
    late HitsSearcher hitsSearcher;
    late MockEventTracker eventTracker;

    setUp(() {
      final searchService = MockHitsSearchService();
      when(searchService.search(any)).thenAnswer(mockResponse);
      eventTracker = MockEventTracker();
      const initSearchState = SearchState(indexName: 'indexName');
      hitsSearcher = HitsSearcher.custom(
        searchService,
        eventTracker,
        initSearchState,
      );
    });

    test('event index name change', () {
      final objectIDs = ['1', '2'];

      hitsSearcher
          .applyState((state) => state.copyWith(indexName: 'indexName_asc'));

      hitsSearcher.eventTracker.clickedObjects(
        eventName: 'clickedObjects',
        objectIDs: objectIDs,
      );

      verify(
        eventTracker.clickedObjects(
          indexName: 'indexName_asc',
          eventName: 'clickedObjects',
          objectIDs: objectIDs,
        ),
      ).called(1);

      hitsSearcher
          .applyState((state) => state.copyWith(indexName: 'indexName_desc'));

      hitsSearcher.eventTracker.clickedObjects(
        eventName: 'clickedObjects',
        objectIDs: objectIDs,
      );

      verify(
        eventTracker.clickedObjects(
          indexName: 'indexName_desc',
          eventName: 'clickedObjects',
          objectIDs: objectIDs,
        ),
      ).called(1);
    });

    group('clickedObjects', () {
      test('calls clickedObjects if queryID is null', () {
        final objectIDs = ['1', '2'];
        final positions = [1, 2];

        hitsSearcher.eventTracker.clickedObjects(
          eventName: 'clickedObjects',
          objectIDs: objectIDs,
          positions: positions,
        );

        verify(
          eventTracker.clickedObjects(
            indexName: 'indexName',
            eventName: 'clickedObjects',
            objectIDs: objectIDs,
          ),
        ).called(1);
      });

      test('calls clickedObjectsAfterSearch if queryID is not null', () async {
        final objectIDs = ['1', '3'];
        final positions = [1, 3];
        const queryID = '123';

        hitsSearcher.query('query');
        await expectLater(hitsSearcher.responses, emits(matchesQuery('query')));

        hitsSearcher.eventTracker.clickedObjects(
          eventName: 'clickedObjects',
          objectIDs: objectIDs,
          positions: positions,
        );

        verify(
          eventTracker.clickedObjectsAfterSearch(
            indexName: 'indexName',
            eventName: 'clickedObjects',
            queryID: queryID,
            objectIDs: objectIDs,
            positions: positions,
          ),
        ).called(1);
      });
    });

    group('convertedObjects', () {
      test('calls convertedObjects if queryID is null', () {
        final objectIDs = ['1', '2'];

        hitsSearcher.eventTracker.convertedObjects(
          eventName: 'convertedObjects',
          objectIDs: objectIDs,
        );

        verify(
          eventTracker.convertedObjects(
            indexName: 'indexName',
            eventName: 'convertedObjects',
            objectIDs: objectIDs,
          ),
        ).called(1);
      });

      test('calls convertedObjectsAfterSearch if queryID is not null',
          () async {
        final objectIDs = ['1', '2'];
        const queryID = '123';

        hitsSearcher.query('query');
        await expectLater(hitsSearcher.responses, emits(matchesQuery('query')));

        hitsSearcher.eventTracker.convertedObjects(
          eventName: 'convertedObjects',
          objectIDs: objectIDs,
        );

        verify(
          eventTracker.convertedObjectsAfterSearch(
            indexName: 'indexName',
            eventName: 'convertedObjects',
            queryID: queryID,
            objectIDs: objectIDs,
          ),
        ).called(1);
      });
    });

    group('viewedObjects', () {
      test('calls viewedObjects', () {
        final objectIDs = ['1', '2'];

        hitsSearcher.eventTracker.viewedObjects(
          eventName: 'viewedObjects',
          objectIDs: objectIDs,
        );

        verify(
          eventTracker.viewedObjects(
            indexName: 'indexName',
            eventName: 'viewedObjects',
            objectIDs: objectIDs,
          ),
        ).called(1);
      });
    });
  });
}

Future<SearchResponse> mockResponse(Invocation inv) async {
  final state = inv.positionalArguments[0] as SearchState;
  await delay(100);
  return SearchResponse({
    'query': state.query,
    'hits': [
      {'objectID': 'h1'},
      {'objectID': 'h2'}
    ],
    'queryID': '123',
  });
}

/// Return future with a delay
Future delay([int millis = 500]) =>
    Future.delayed(Duration(milliseconds: millis), () {});

/// Matches a [SearchResponse] with a given [query].
TypeMatcher<SearchResponse> matchesQuery(String query) =>
    isA<SearchResponse>().having((res) => res.query, 'query', matches(query));
