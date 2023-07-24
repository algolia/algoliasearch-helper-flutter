import 'dart:async';

import 'package:algolia_helper/algolia_helper.dart';
import 'package:algolia_helper/src/service/algolia_client_helper.dart';
import 'package:algolia_helper/src/service/multi_search_service.dart';
import 'package:algoliasearch/algoliasearch.dart' as algolia;
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

    test('basic', () async {
      final states = [
        const SearchState(indexName: 'index1', query: 'q1'),
        const SearchState(indexName: 'index2', query: 'q2'),
        const SearchState(indexName: 'index3', query: 'q3'),
      ];

      final service = MockMultiSearchService();

      when(
        service.search(states),
      ).thenAnswer((_) => Future.value([]));

      await service.search(states);
    });

    test('should invoke MultiSearchService for each HitsSearcher', () async {
      final states = [
        const SearchState(indexName: 'index1', query: 'q1'),
        const SearchState(indexName: 'index2', query: 'q2'),
        const SearchState(indexName: 'index3', query: 'q3'),
      ];

      final searchers = [0, 1, 2]
          .map(
            (i) => multiSearcher.addHitsSearcher(initialState: states[i]),
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

      when(
        mockMultiSearchService.search(states),
      ).thenAnswer((_) => Future.value(responses));

      for (var i = 0; i < searchers.length; i++) {
        searchers[i].applyState((state) => states[i]);
        await untilCalled(mockMultiSearchService.search(states));
        verify(mockMultiSearchService.search(states)).called(1);
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
        searcher
            .applyState((state) => updatedStates[searchers.indexOf(searcher)]);
      }

      await untilCalled(mockMultiSearchService.search(updatedStates));

      verify(mockMultiSearchService.search(updatedStates)).called(1);
    });

    test('should handle adding a HitsSearcher after initial setup', () async {
      final initialStates = [
        const SearchState(indexName: 'index1', query: 'q1'),
        const SearchState(indexName: 'index2', query: 'q2'),
      ];

      final initialSearchers = [0, 1]
          .map(
            (i) => multiSearcher.addHitsSearcher(
              initialState: initialStates[i],
            ),
          )
          .toList();

      final initialSubscriptions = <StreamSubscription<SearchResponse>>[];
      for (final searcher in initialSearchers) {
        initialSubscriptions.add(searcher.responses.listen(print));
      }

      final initialStateResponses = [
        SearchResponse({
          'query': 'q1',
        }),
        SearchResponse({
          'query': 'q2',
        }),
      ];

      when(mockMultiSearchService.search(initialStates))
          .thenAnswer((_) => Future.value(initialStateResponses));

      for (var i = 0; i < initialSearchers.length; i++) {
        initialSearchers[i].applyState((state) => initialStates[i]);
        await untilCalled(mockMultiSearchService.search(initialStates));
        verify(mockMultiSearchService.search(initialStates)).called(1);
        clearInteractions(mockMultiSearchService);
      }

      for (final subscription in initialSubscriptions) {
        await subscription.cancel();
      }

      // Adding a new HitsSearcher after initial setup
      const newState = SearchState(indexName: 'index3', query: 'q3');
      final newSearcher = multiSearcher.addHitsSearcher(initialState: newState);
      final newSubscription = newSearcher.responses.listen(print);

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

      final allStates =
          [...initialStates, newState];
      when(mockMultiSearchService.search(allStates))
          .thenAnswer((_) => Future.value(newResponses));

      newSearcher.applyState((state) => newState);
      await untilCalled(mockMultiSearchService.search(allStates));
      verify(mockMultiSearchService.search(allStates)).called(1);

      await newSubscription.cancel();
    });
  });

  test('should properly call Algolia index', () async {
    final client = algolia.SearchClient(
      appId: 'latency',
      apiKey: '1f6fd3a6fb973cb08419fe7d288fa4db',
    );

    final states = [
      const SearchState(indexName: 'instant_search_demo_query_suggestions'),
      FacetSearchState(
        searchState: const SearchState(indexName: 'instant_search'),
        facet: 'categories',
      ),
    ];

    final responses = await client.multiSearch(states);

    print(responses);
  });

  group('Integration tests', () {
    test('should properly call Algolia multi-index service', () async {
      final multiSearcher = MultiSearcher.algolia(
        'latency',
        '1f6fd3a6fb973cb08419fe7d288fa4db',
        eventTracker: MockEventTracker(),
      );

      final actorsSearcher = multiSearcher.addHitsSearcher(
        initialState: const SearchState(indexName: 'mobile_demo_actors'),
      );

      actorsSearcher.responses.listen(print);

      final moviesSearcher = multiSearcher.addHitsSearcher(
        initialState: const SearchState(indexName: 'mobile_demo_movies'),
      );

      moviesSearcher.responses.listen(print);

      actorsSearcher.query('jack');
      moviesSearcher.query('jack');

      final response = await actorsSearcher.responses.take(1).first;
      // expect(response.hits.length, 1);
      // expect(response.query, 'apple');
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
          ),
        );

        final facetSearcher = multiSearcher.addFacetSearcher(
          state: const SearchState(indexName: 'instant_search'),
          facet: 'categories',
        );

        hitsSearcher.query('lap');
        facetSearcher.query('lap');

        final hitsResponse = await hitsSearcher.responses.take(1).first;
        print(hitsResponse);
        final facetResponse = await facetSearcher.responses.take(1).first;
        print(facetResponse);
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
