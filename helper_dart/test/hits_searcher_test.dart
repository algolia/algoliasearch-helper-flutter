import 'package:algolia_helper_dart/helper.dart';
import 'package:test/test.dart';

void main() {
  test('Successful search operation', () async {
    final helper = HitsSearcher.create(
      applicationID: 'latency',
      apiKey: 'afc3dd66dd1293e2e2736a5a51b05c0a',
      state: const SearchState(
          indexName: 'instant_search', query: "apple", hitsPerPage: 1),
    );

    var response = await helper.responses.take(1).first;
    expect(response.hits.length, 1);
    expect(response.query, "apple");
  });

  test('Failing search operation', () async {
    final helper = HitsSearcher(
        applicationID: 'latency',
        apiKey: 'UNKNOWN',
        indexName: 'instant_search');

    helper.query("apple");
    expectLater(helper.responses, emitsError(isA<SearchError>()));
  });
}
