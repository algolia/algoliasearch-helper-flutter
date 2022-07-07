import 'package:algolia/algolia.dart';

class AlgoliaHelper {
  /// Inner Algolia API client
  final Algolia client;

  const AlgoliaHelper(this.client);

  factory AlgoliaHelper.of(String applicationID, final String apiKey) {
    final client = Algolia.init(applicationId: applicationID, apiKey: apiKey);
    return AlgoliaHelper(client);
  }
}
