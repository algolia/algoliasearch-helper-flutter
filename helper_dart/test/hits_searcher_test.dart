import 'package:algolia_helper_dart/algolia.dart';
import 'package:algolia_helper_dart/src/hits_searcher_service.dart';
import 'package:mockito/annotations.dart';
import 'package:test/test.dart';

import 'hits_searcher_test.mocks.dart';

@GenerateMocks([HitsSearchService])
void main() {
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

  test('Should update response', () {
    final searchService = MockHitsSearchService();
    final searcher = HitsSearcher.build(
      searchService,
      const SearchState(indexName: 'myIndex'),
      const Duration(microseconds: 100),
    );
  });
}
