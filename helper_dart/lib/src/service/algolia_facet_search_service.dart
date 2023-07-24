import 'package:algoliasearch/algoliasearch.dart' as algolia;
import 'package:logging/logging.dart';

import '../lib_version.dart';
import '../logger.dart';
import '../model/multi_search_response.dart';
import '../model/multi_search_state.dart';
import 'algolia_client_helper.dart';
import 'facet_search_service.dart';

class AlgoliaFacetSearchService implements FacetSearchService {
  /// Creates [AlgoliaFacetSearchService] instance.
  AlgoliaFacetSearchService({
    required String applicationID,
    required String apiKey,
  }) : this.create(
          algolia.SearchClient(
            appId: applicationID,
            apiKey: apiKey,
            options: const algolia.ClientOptions(
              agentSegments: [
                algolia.AgentSegment(
                  value: 'algolia-helper-dart',
                  version: libVersion,
                )
              ],
            ),
          ),
        );

  /// Creates [AlgoliaFacetSearchService] instance.
  AlgoliaFacetSearchService.create(
    this._client,
  ) : _log = algoliaLogger('FacetSearchService');

  /// Search events logger.
  final Logger _log;

  /// Algolia API client
  final algolia.SearchClient _client;

  @override
  Future<FacetSearchResponse> search(FacetSearchState state) async {
    _log.fine('Run facet search with state: $state');
    try {
      final response = await _client.facetSearch(state);
      _log.fine('Facet search response: $response');
      return response;
    } catch (exception) {
      _log.severe('Facet search exception: $exception');
      rethrow;
    }
  }
}
