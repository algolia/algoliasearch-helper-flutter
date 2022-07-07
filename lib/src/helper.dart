import 'package:algolia/algolia.dart';

class AlgoliaHelper {
  /// Inner Algolia API client.
  final Algolia client;

  /// Index name.
  final String indexName;

  /// Query parameters
  final Map<String, dynamic>? parameters;

  const AlgoliaHelper(this.client, this.indexName, [this.parameters]);

  factory AlgoliaHelper.of(String applicationID, String apiKey, String indexName, {Map<String, dynamic>? parameters}) {
    final client = Algolia.init(applicationId: applicationID, apiKey: apiKey);
    return AlgoliaHelper(client, indexName, parameters);
  }

}
