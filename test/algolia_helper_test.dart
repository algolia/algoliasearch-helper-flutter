import 'package:algolia/algolia.dart';
import 'package:algolia_helper/algolia_helper.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Initiate Algolia Helper', () {
    const applicationID = 'APPLICATION_ID';
    const apiKey = 'API_KEY';
    const indexName = 'INDEX_NAME';

    const client = Algolia.init(
      applicationId: applicationID,
      apiKey: apiKey,
    );
    const algoliaHelper = AlgoliaHelper(client, indexName);
    expect(algoliaHelper.client, client);

    var algoliaHelper2 = AlgoliaHelper.of(applicationID, apiKey, indexName);
    expect(algoliaHelper2.client.applicationId, applicationID);
  });
}
