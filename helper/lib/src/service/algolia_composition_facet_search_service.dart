import 'package:algolia_client_composition/algolia_client_composition.dart'
    as composition;
import 'package:logging/logging.dart';

import '../client_options.dart';
import '../logger.dart';
import '../model/composition_facet_search_response.dart';
import '../model/composition_facet_search_state.dart';
import 'client_options.dart';
import 'composition_client_extensions.dart';
import 'composition_facet_search_service.dart';

/// [CompositionFacetSearchService] implementation backed by the Algolia
/// [composition.CompositionClient].
class AlgoliaCompositionFacetSearchService
    implements CompositionFacetSearchService {
  /// Creates [AlgoliaCompositionFacetSearchService] instance.
  AlgoliaCompositionFacetSearchService({
    required String applicationID,
    required String apiKey,
    ClientOptions? options,
  }) : this.create(
          composition.CompositionClient(
            appId: applicationID,
            apiKey: apiKey,
            options: createClientOptions(options),
          ),
        );

  /// Creates [AlgoliaCompositionFacetSearchService] instance.
  AlgoliaCompositionFacetSearchService.create(
    this._client,
  ) : _log = algoliaLogger('CompositionFacetSearchService');

  /// Search events logger.
  final Logger _log;

  /// Algolia Composition API client
  final composition.CompositionClient _client;

  @override
  Future<CompositionFacetSearchResponse> search(
    CompositionFacetSearchState state,
  ) async {
    _log.fine('run composition facet search with state: $state');
    try {
      final response = await _client.searchForFacetValues(
        compositionID: state.compositionID,
        facetName: state.facet,
        searchForFacetValuesRequest: state.toRequest(),
      );
      final result = response.toFacetSearchResponse();
      _log.fine('received response: $result');
      return result;
    } catch (exception) {
      _log.severe('exception: $exception');
      throw launderCompositionException(exception);
    }
  }
}
