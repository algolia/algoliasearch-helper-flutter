import 'package:algolia_helper/algolia_helper.dart';
import 'package:algolia_helper/src/multi_searcher.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import 'multi_searcher_test.mocks.dart';

@GenerateMocks([SearchService])
void main() {
  late MockSearchService searchService;

  setUp(
    () {
      searchService = MockSearchService();
      when(searchService.performSearch(any)).thenAnswer(mockResponse);
    },
  );

  test(
    'Multi Searcher tests',
    () async {
      final searchService = MockSearchService();
      when(searchService.performSearch(any)).thenAnswer(
        (inv) async {
          await delay(100);
          print(inv.positionalArguments[0]);
          return mockResponse(inv);
        },
      );

      // Create a list of HitsSearcher objects.
      final searchers = <HitsSearcher>[
        HitsSearcher(
          applicationID: 'app',
          apiKey: 'key',
          indexName: 'index1',
        ),
        HitsSearcher(
          applicationID: 'app',
          apiKey: 'key',
          indexName: 'index2',
        ),
        HitsSearcher(
          applicationID: 'app',
          apiKey: 'key',
          indexName: 'index3',
        ),
      ];
      final multiSearcher = MultiSearcher(searchers, searchService);

      searchers[0].applyState((state) => state.copyWith(query: 'q1'));
      searchers[1].applyState((state) => state.copyWith(query: 'q2'));
      searchers[2].applyState((state) => state.copyWith(query: 'q3'));

      await expectLater(
        multiSearcher.results,
        emits([
          SearchResponse({'query': 'q1'}),
          SearchResponse({'query': 'q2'}),
          SearchResponse({'query': 'q3'}),
        ]),
      );
    },
  );
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
