import 'package:algoliasearch/algoliasearch.dart' as algolia;
import 'package:logging/logging.dart';

import '../logger.dart';
import '../model/multi_search_response.dart';
import '../model/multi_search_state.dart';
import '../multi_search_state_folder.dart';
import 'algolia_client_helper.dart';
import 'multi_search_service.dart';

final class AlgoliaMultiSearchService extends MultiSearchService {
  /// Search events logger.
  final Logger _log;

  /// Algolia API client
  final algolia.SearchClient _client;

  AlgoliaMultiSearchService(String applicationID, String apiKey)
      : this.create(algolia.SearchClient(appId: applicationID, apiKey: apiKey));

  AlgoliaMultiSearchService.create(this._client)
      : _log = algoliaLogger('MultiSearchService');

  @override
  Future<List<MultiSearchResponse>> search(
    List<MultiSearchState> states,
  ) async {
    _log.fine('Start multi search: $states');
    final folder = MultiSearchStateFolder();
    final unfoldedRequests = folder.unfoldStates(states);
    final unfoldedResponses = await _client.multiSearch(unfoldedRequests);
    _log.fine('Received responses: $unfoldedResponses');
    final foldedResponses = folder.foldResponses(unfoldedResponses);
    return foldedResponses;
  }
}
