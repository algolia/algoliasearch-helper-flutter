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
    final algoliaHelper = AlgoliaHelper(client, indexName);
    expect(algoliaHelper.client, client);

    final algoliaHelper2 = AlgoliaHelper.create(
        applicationID: applicationID, apiKey: apiKey, indexName: indexName);
    expect(algoliaHelper2.client.applicationId, applicationID);
  });
}
