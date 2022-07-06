import 'package:algolia/algolia.dart';
import 'package:algolia_helper/algolia_helper.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Initiate Algolia Helper', () {
    const client = Algolia.init(
      applicationId: 'YOUR_APPLICATION_ID',
      apiKey: 'YOUR_API_KEY',
    );

    const algoliaHelper = AlgoliaHelper(client);

    expect(algoliaHelper.client, client);
  });
}
