import 'package:algolia_helper/algolia_helper.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Initiate Algolia Helper', () async {
    const applicationID = 'latency';
    const apiKey = 'afc3dd66dd1293e2e2736a5a51b05c0a';
    const indexName = 'instant_search';

    final helper = AlgoliaHelper.create(applicationID: applicationID, apiKey: apiKey, indexName: indexName);
    helper.dispose();
    final list = await helper.responses.toList();
    print(list);
    expect(list.isEmpty, true);
  });
}
