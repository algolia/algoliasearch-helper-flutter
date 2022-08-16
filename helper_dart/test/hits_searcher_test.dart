import 'dart:async';

import 'package:algolia_helper_dart/algolia.dart';
import 'package:algolia_helper_dart/src/hits_searcher_service.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import 'hits_searcher_test.mocks.dart';

@GenerateMocks([HitsSearchService])
void main() {
  group('Integration tests', () {
    test('Successful search operation', () async {
      final helper = HitsSearcher.create(
        applicationID: 'latency',
        apiKey: 'afc3dd66dd1293e2e2736a5a51b05c0a',
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
      )..query('apple');
      await expectLater(helper.responses, emitsError(isA<SearchError>()));
    });
  });

  group('Unit tests', () {
    test('Should emit initial response', () async {
      final searchService = MockHitsSearchService();
      final initial = SearchResponse(const {});
      when(searchService.search(any)).thenAnswer((_) => Stream.value(initial));

      final searcher = HitsSearcher.build(
        searchService,
        const SearchState(indexName: 'myIndex'),
      );

      await expectLater(searcher.responses, emits(initial)); // initial response
    });

    test('Should emit response after query', () async {
      final searchService = MockHitsSearchService();
      final searcher = HitsSearcher.build(
        searchService,
        const SearchState(indexName: 'myIndex'),
      );

      when(searchService.search(any)).thenAnswer(
        (Invocation inv) {
          final state = inv.positionalArguments[0] as SearchState;
          return Stream.value(SearchResponse({'query': state.query}));
        },
      );
      const query = 'cat';
      searcher.query(query);

      await expectLater(searcher.responses, emits(matchesQuery('cat')));
    });

    test('Should emit error after failure', () async {
      final searchService = MockHitsSearchService();
      when(searchService.search(any))
          .thenAnswer((_) => Stream.value(SearchResponse({})));
      final searcher = HitsSearcher.build(
        searchService,
        const SearchState(indexName: 'myIndex'),
      );

      when(searchService.search(any))
          .thenAnswer((Invocation inv) => Stream.error(SearchError({}, 500)));
      searcher.query('cat');

      await expectLater(searcher.responses, emitsError(isA<SearchError>()));
    });

    test('Should debounce search state', () async {
      final searchService = MockHitsSearchService();
      when(searchService.search(any)).thenAnswer(
        (Invocation inv) {
          final state = inv.positionalArguments[0] as SearchState;
          return Stream.value(SearchResponse({'query': state.query}));
        },
      );

      final searcher = HitsSearcher.build(
        searchService,
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
        ..query('cat')
        ..dispose();
    });

    test("Shouldn't debounce search state", () async {
      final searchService = MockHitsSearchService();
      when(searchService.search(any)).thenAnswer(
        (Invocation inv) {
          final state = inv.positionalArguments[0] as SearchState;
          return Stream.value(SearchResponse({'query': state.query}));
        },
      );

      final searcher = HitsSearcher.build(
        searchService,
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
      when(searchService.search(any)).thenAnswer(
        (Invocation inv) async* {
          final state = inv.positionalArguments[0] as SearchState;
          await delay();
          yield SearchResponse({'query': state.query});
        },
      );

      final searcher = HitsSearcher.build(
        searchService,
        const SearchState(indexName: 'myIndex'),
      );

      unawaited(
        expectLater(
          searcher.responses,
          emitsInOrder([
            emits(matchesQuery('cat'))
          ]),
        ),
      );

      searcher.query('c');
      await delay(200);
      searcher.query('ca');
      await delay(200);
      searcher.query('cat');
      await delay(200);
      searcher.dispose();
    });
  });
}

/// Return future with a delay
Future delay([int millis = 500]) =>
    Future.delayed(Duration(milliseconds: millis), () {});

/// Matches a [SearchResponse] with a given [query].
TypeMatcher<SearchResponse> matchesQuery(String query) =>
    isA<SearchResponse>().having((res) => res.query, 'query', matches(query));
