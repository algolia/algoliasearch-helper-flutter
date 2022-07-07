import 'package:algolia/algolia.dart';
import 'package:algolia_helper/algolia_helper.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Initiate Algolia Helper', () {
    const applicationID = 'YOUR_APPLICATION_ID';
    const apiKey2 = 'YOUR_API_KEY';

    const client = Algolia.init(
      applicationId: applicationID,
      apiKey: apiKey2,
    );
    const algoliaHelper = AlgoliaHelper(client);
    expect(algoliaHelper.client, client);

    var algoliaHelper2 = AlgoliaHelper.of(applicationID, apiKey2);
    expect(algoliaHelper2.client.applicationId, applicationID);
  });
}
