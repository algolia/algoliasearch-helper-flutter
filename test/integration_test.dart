import 'package:algolia_helper/algolia_helper.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Operation callback', () async {
    final helper = AlgoliaHelper.create(
      applicationID: 'latency',
      apiKey: 'afc3dd66dd1293e2e2736a5a51b05c0a',
      indexName: 'instant_search',
      state: const SearchState(hitsPerPage: 1),
    );

    helper.query("apple");
    var response = await helper.responses.take(1).first;

    expect(response.hits.length, 1);
    expect(response.query, "apple");
  });

  test('Operation failed', () async {
    final helper = AlgoliaHelper.create(
        applicationID: 'latency',
        apiKey: 'UNKNOWN',
        indexName: 'instant_search');

    helper.query("apple");
    expectLater(helper.responses, emitsError(isA<SearchError>()));
  });
}
