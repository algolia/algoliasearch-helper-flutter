import 'dart:async';

import 'package:algolia_helper/src/model/multi_search_response.dart';
import 'package:algolia_helper/src/model/multi_search_state.dart';
import 'package:algolia_helper/src/searcher/multi_searcher.dart';
import 'package:algolia_helper/src/service/multi_search_service.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import 'hits_searcher_test.mocks.dart';
import 'multi_searcher_test.mocks.dart';

@GenerateMocks([
  MultiSearchService,
])
void main() {
  group('MultiSearcher', () {
    late MultiSearcher multiSearcher;
    late MultiSearchService mockMultiSearchService;
    late MockEventTracker mockEventTracker;

    setUp(() {
      mockMultiSearchService = MockMultiSearchService();
      mockEventTracker = MockEventTracker();
      multiSearcher = MultiSearcher(mockMultiSearchService, mockEventTracker);
    });

    tearDown(() {
      multiSearcher.dispose();
    });

    test('should invoke MultiSearchService consecutively for each sub-searcher',
        () async {
      final initialStates = [
        const SearchState(indexName: 'index1', query: 'q0'),
        const SearchState(indexName: 'index2', query: 'q0'),
        const SearchState(indexName: 'index3', query: 'q0'),
      ];

      final searchers = initialStates
          .map(
            (state) => multiSearcher.addHitsSearcher(initialState: state),
          )
          .toList();

      final subscriptions = <StreamSubscription<SearchResponse>>[];
      final completers = <Completer<MultiSearchResponse>>[];

      for (final searcher in searchers) {
        final completer = Completer<MultiSearchResponse>();
        subscriptions.add(
          searcher.responses.listen((response) {
            if (!completer.isCompleted) {
              completer.complete(response);
            }
          }),
        );
        completers.add(completer);
      }

      final responses = [
        SearchResponse({
          'query': 'q1',
        }),
        SearchResponse({
          'query': 'q2',
        }),
        SearchResponse({
          'query': 'q3',
        }),
      ];

      final states = [
        [
          const SearchState(indexName: 'index1', query: 'q1'),
          const SearchState(indexName: 'index2', query: 'q0'),
          const SearchState(indexName: 'index3', query: 'q0'),
        ],
        [
          const SearchState(indexName: 'index1', query: 'q1'),
          const SearchState(indexName: 'index2', query: 'q2'),
          const SearchState(indexName: 'index3', query: 'q0'),
        ],
        [
          const SearchState(indexName: 'index1', query: 'q1'),
          const SearchState(indexName: 'index2', query: 'q2'),
          const SearchState(indexName: 'index3', query: 'q3'),
        ],
      ];

      for (final state in states) {
        when(
          mockMultiSearchService.search(state),
        ).thenAnswer((_) => Future.value(responses));
      }

      for (var i = 0; i < searchers.length; i++) {
        searchers[i].query('q${i + 1}');
        await untilCalled(mockMultiSearchService.search(states[i]));
        verify(mockMultiSearchService.search(states[i])).called(1);
        final receivedResponse = await completers[i].future;
        expect(receivedResponse, responses[i]);
        clearInteractions(mockMultiSearchService);
      }

      for (final subscription in subscriptions) {
        await subscription.cancel();
      }
    });

    test('should invoke MultiSearchService only once', () async {
      final initialStates = [
        const SearchState(indexName: 'index1', query: 'q1'),
        const SearchState(indexName: 'index2', query: 'q2'),
        const SearchState(indexName: 'index3', query: 'q3'),
      ];

      final updatedStates = [
        const SearchState(indexName: 'index1', query: 'new_q1'),
        const SearchState(indexName: 'index2', query: 'new_q2'),
        const SearchState(indexName: 'index3', query: 'new_q3'),
      ];

      final searchers = initialStates
          .map((state) => multiSearcher.addHitsSearcher(initialState: state))
          .toList();

      final responses = [
        SearchResponse({
          'query': 'new_q1',
        }),
        SearchResponse({
          'query': 'new_q2',
        }),
        SearchResponse({
          'query': 'new_q3',
        }),
      ];

      when(mockMultiSearchService.search(updatedStates))
          .thenAnswer((_) => Future.value(responses));

      for (var searcher in searchers) {
        searcher.query('new_q${searchers.indexOf(searcher) + 1}');
      }

      await untilCalled(mockMultiSearchService.search(updatedStates));

      verify(mockMultiSearchService.search(updatedStates)).called(1);
    });

    test('should handle adding a HitsSearcher after initial setup', () async {
      final initialStates = [
        const SearchState(indexName: 'index1', query: 'q0'),
        const SearchState(indexName: 'index2', query: 'q0'),
      ];

      final expectedStates = [
        const SearchState(indexName: 'index1', query: 'q1'),
        const SearchState(indexName: 'index2', query: 'q2'),
      ];

      final initialSearchers = initialStates
          .map(
            (state) => multiSearcher.addHitsSearcher(
              initialState: state,
            ),
          )
          .toList();

      final expectedStateResponses = [
        SearchResponse({
          'query': 'q1',
        }),
        SearchResponse({
          'query': 'q2',
        }),
      ];

      when(mockMultiSearchService.search(expectedStates))
          .thenAnswer((_) => Future.value(expectedStateResponses));

      initialSearchers[0].query('q1');
      initialSearchers[1].query('q2');
      await untilCalled(mockMultiSearchService.search(expectedStates));
      verify(mockMultiSearchService.search(expectedStates)).called(1);
      clearInteractions(mockMultiSearchService);

      // Adding a new HitsSearcher after initial setup
      const newState = SearchState(indexName: 'index3', query: 'q0');
      final newSearcher = multiSearcher.addHitsSearcher(initialState: newState);

      final newResponses = [
        SearchResponse({
          'query': 'q1',
        }),
        SearchResponse({
          'query': 'q2',
        }),
        SearchResponse({
          'query': 'q3',
        }),
      ];

      final allStates = [
        ...initialSearchers.map((e) => e.snapshot()),
        const SearchState(indexName: 'index3', query: 'q3'),
      ];
      when(mockMultiSearchService.search(allStates))
          .thenAnswer((_) => Future.value(newResponses));

      newSearcher.query('q3');
      await untilCalled(mockMultiSearchService.search(allStates));
      verify(mockMultiSearchService.search(allStates)).called(1);
      clearInteractions(mockMultiSearchService);

      // await newSubscription.cancel();
    });
  });

  group('Integration tests', () {
    test('should properly call Algolia multi-index service', () async {
      final multiSearcher = MultiSearcher.algolia(
        'latency',
        '1f6fd3a6fb973cb08419fe7d288fa4db',
        eventTracker: MockEventTracker(),
      );

      final actorsSearcher = multiSearcher.addHitsSearcher(
        initialState: const SearchState(
          indexName: 'mobile_demo_actors',
          hitsPerPage: 1,
        ),
      );

      final moviesSearcher = multiSearcher.addHitsSearcher(
        initialState: const SearchState(
          indexName: 'mobile_demo_movies',
          hitsPerPage: 1,
        ),
      );

      actorsSearcher.query('jack');
      moviesSearcher.query('jack');

      final actorsResponse = await actorsSearcher.responses.take(1).first;
      expect(actorsResponse.hits.length, 1);
      expect(actorsResponse.query, 'jack');

      final moviesResponse = await moviesSearcher.responses.take(1).first;
      expect(moviesResponse.hits.length, 1);
      expect(moviesResponse.query, 'jack');
    });

    test(
      'should properly call Algolia hits and facet multi-index service',
      () async {
        final multiSearcher = MultiSearcher.algolia(
          'latency',
          '1f6fd3a6fb973cb08419fe7d288fa4db',
          eventTracker: MockEventTracker(),
        );

        final hitsSearcher = multiSearcher.addHitsSearcher(
          initialState: const SearchState(
            indexName: 'instant_search_demo_query_suggestions',
            hitsPerPage: 1,
          ),
        );

        final facetSearcher = multiSearcher.addFacetSearcher(
          state: const SearchState(
            indexName: 'instant_search',
            maxFacetHits: 1,
          ),
          facet: 'categories',
        );

        hitsSearcher.query('lap');
        facetSearcher.query('lap');

        final hitsResponse = await hitsSearcher.responses.take(1).first;
        expect(hitsResponse.hits.length, 1);
        expect(hitsResponse.query, 'lap');
        final facetResponse = await facetSearcher.responses.take(1).first;
        expect(facetResponse.facetHits.length, 1);
      },
    );
  });
}

Future<List<SearchResponse>> mockResponse(Invocation inv) async {
  final states = inv.positionalArguments[0] as List<SearchState>;
  return states
      .map(
        (state) => SearchResponse({
          'query': state.query,
        }),
      )
      .toList();
}

/// Return future with a delay
Future delay([int millis = 500]) =>
    Future.delayed(Duration(milliseconds: millis), () {});
