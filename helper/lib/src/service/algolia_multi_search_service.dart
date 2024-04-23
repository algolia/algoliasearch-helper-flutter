import 'package:algoliasearch/algoliasearch.dart' as algolia;
import 'package:logging/logging.dart';

import '../../algolia_helper_flutter.dart';
import '../logger.dart';
import '../multi_search_state_folder.dart';
import 'algolia_client_extensions.dart';
import 'client_options.dart';
import 'multi_search_service.dart';

final class AlgoliaMultiSearchService extends MultiSearchService {
  /// Search events logger.
  final Logger _log;

  /// Algolia API client
  final algolia.SearchClient _client;

  AlgoliaMultiSearchService({
    required String applicationID,
    required String apiKey,
    ClientOptions? options,
  }) : this.create(
          algolia.SearchClient(
            appId: applicationID,
            apiKey: apiKey,
            options: createClientOptions(options),
          ),
        );

  AlgoliaMultiSearchService.create(this._client)
      : _log = algoliaLogger('MultiSearchService');

  @override
  Future<List<MultiSearchResponse>> search(
    List<MultiSearchState> states,
  ) async {
    _log.fine('run search with states: $states');
    final folder = MultiSearchStateFolder();
    final unfoldedRequests = folder.unfoldStates(states);
    final requests = unfoldedRequests.map((state) {
      switch (state) {
        case SearchState():
          return state.toRequest();
        case FacetSearchState():
          return state.toRequest();
      }
    }).toList();
    try {
      final responses = await _client.search(
        searchMethodParams: algolia.SearchMethodParams(requests: requests),
      );
      final unfoldedResponses = responses.results
          .map((result) {
            if (result is Map<String, dynamic>) {
              if (result.containsKey('facetHits')) {
                return algolia.SearchForFacetValuesResponse.fromJson(result)
                    .toSearchResponse();
              } else {
                return algolia.SearchResponse.fromJson(result)
                    .toSearchResponse();
              }
            }
          })
          .where((response) => response != null)
          .map((response) => response!)
          .toList();
      _log.fine('received responses: $unfoldedResponses');
      final foldedResponses = folder.foldResponses(unfoldedResponses);
      return foldedResponses;
    } catch (exception) {
      _log.severe('exception: $exception');
      throw _client.launderException(exception);
    }
  }
}
