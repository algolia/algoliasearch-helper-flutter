import 'dart:async';

import 'package:algolia_helper/src/exception.dart';
import 'package:algolia_helper/src/model/multi_search_response.dart';
import 'package:algolia_helper/src/model/multi_search_state.dart';
import 'package:algolia_helper/src/searcher/facet_searcher.dart';
import 'package:algolia_helper/src/service/facet_search_service.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import 'facet_searcher_test.mocks.dart';

@GenerateMocks([
  FacetSearcher,
  FacetSearchService,
])
void main() {
  group('Integration tests', () {
    test('Successful search operation', () async {
      final helper = FacetSearcher.create(
        applicationID: 'latency',
        apiKey: 'af044fb0788d6bb15f807e4420592bc5',
        state: const FacetSearchState(
          searchState: SearchState(
            indexName: 'instant_search',
            query: 'apple',
            maxFacetHits: 1,
          ),
          facet: 'brand',
          facetQuery: 'sams',
        ),
      );

      final response = await helper.responses.take(1).first;
      expect(response.facetHits.length, 1);
    });

    test('Failing search operation', () async {
      final helper = FacetSearcher(
        applicationID: 'latency',
        apiKey: 'UNKNOWN',
        indexName: 'instant_search',
        facet: 'brand',
      );
      await expectLater(helper.responses, emitsError(anything));
    });
  });

  group('Unit tests', () {
    test('Should emit initial response', () async {
      final searchService = MockFacetSearchService();
      final initial = FacetSearchResponse(const {
        'facetHits': [
          {
            'value': 'v',
            'count': 1,
          },
        ]
      });
      when(searchService.search(any)).thenAnswer((_) => Future.value(initial));
      final searcher = FacetSearcher.custom(
        searchService,
        const FacetSearchState(
          facet: '',
          searchState: SearchState(indexName: 'myIndex'),
        ),
      );

      await expectLater(searcher.responses, emits(initial)); // initial response
    });

    test('Should emit response after query', () async {
      final searchService = MockFacetSearchService();
      when(searchService.search(any)).thenAnswer(mockResponse);

      final searcher = FacetSearcher.custom(
        searchService,
        const FacetSearchState(
          facet: '',
          facetQuery: 'cat',
          searchState: SearchState(indexName: 'myIndex'),
        ),
      );

      const query = 'cat';
      searcher.query(query);

      await expectLater(searcher.responses, emits(matchesQuery('cat')));
    });

    test('Should emit error after failure', () async {
      final searchService = MockFacetSearchService();
      final searcher = FacetSearcher.custom(
        searchService,
        const FacetSearchState(
          facet: '',
          searchState: SearchState(indexName: 'myIndex'),
        ),
      );

      when(searchService.search(any))
          .thenAnswer((Invocation inv) => throw SearchError({}, 500));
      searcher.query('cat');

      await expectLater(searcher.responses, emitsError(isA<SearchError>()));
    });

    test('Should debounce search state', () async {
      final searchService = MockFacetSearchService();
      when(searchService.search(any)).thenAnswer(mockResponse);

      final searcher = FacetSearcher.custom(
        searchService,
        const FacetSearchState(
          facet: '',
          searchState: SearchState(indexName: 'myIndex'),
        ),
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
      final searchService = MockFacetSearchService();
      when(searchService.search(any)).thenAnswer(mockResponse);

      final searcher = FacetSearcher.custom(
        searchService,
        const FacetSearchState(
          facet: '',
          searchState: SearchState(indexName: 'myIndex'),
        ),
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
      final searchService = MockFacetSearchService();
      when(searchService.search(any)).thenAnswer(mockResponse);

      final searcher = FacetSearcher.custom(
        searchService,
        const FacetSearchState(
          facet: '',
          searchState: SearchState(indexName: 'myIndex'),
        ),
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
      final searchService = MockFacetSearchService();
      when(searchService.search(any)).thenAnswer(mockResponse);

      final searcher = FacetSearcher.custom(
        searchService,
        const FacetSearchState(
          facet: '',
          searchState: SearchState(indexName: 'myIndex'),
        ),
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
}

Future<FacetSearchResponse> mockResponse(Invocation inv) async {
  final state = inv.positionalArguments[0] as FacetSearchState;
  await delay(100);
  return FacetSearchResponse({
    'exhaustiveFacetsCount': 'true',
    'processingTimeMS': '0',
    'query': state.facetQuery,
    'facetHits': [
      {'value': 'facet1', 'count': 5},
      {'value': 'facet2', 'count': 10},
    ],
  });
}

/// Return future with a delay
Future delay([int millis = 500]) =>
    Future.delayed(Duration(milliseconds: millis), () {});

/// Matches a [SearchResponse] with a given [query].
TypeMatcher<FacetSearchResponse> matchesQuery(String query) =>
    isA<FacetSearchResponse>().having(
      (res) => res.raw['query'],
      'query',
      matches(query),
    );
