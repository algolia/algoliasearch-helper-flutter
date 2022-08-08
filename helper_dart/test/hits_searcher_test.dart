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
      when(searchService.search(any)).thenAnswer((_) async => initial);

      final searcher = HitsSearcher.build(
        searchService,
        const SearchState(indexName: 'myIndex'),
        const Duration(microseconds: 100),
      );

      await expectLater(searcher.responses, emits(initial)); // initial response
    });

    test('Should emit response after query', () async {
      final searchService = MockHitsSearchService();
      final searcher = HitsSearcher.build(
        searchService,
        const SearchState(indexName: 'myIndex'),
        const Duration(microseconds: 100),
      );

      when(searchService.search(any)).thenAnswer(
        (Invocation inv) async {
          final state = inv.positionalArguments[0] as SearchState;
          return SearchResponse({'query': state.query});
        },
      );
      const query = 'phone';
      searcher.query(query);

      final matcher = isA<SearchResponse>()
          .having((res) => res.query, 'query', matches(query));
      await expectLater(searcher.responses, emits(matcher));
    });

    test('Should emit error after failure', () async {
      final searchService = MockHitsSearchService();
      when(searchService.search(any))
          .thenAnswer((_) async => SearchResponse(const {}));
      final searcher = HitsSearcher.build(
        searchService,
        const SearchState(indexName: 'myIndex'),
        const Duration(microseconds: 100),
      );

      when(searchService.search(any))
          .thenAnswer((Invocation inv) async => throw SearchError({}, 500));
      searcher.query('phone');

      await expectLater(searcher.responses, emitsError(isA<SearchError>()));
    });
  });
}
