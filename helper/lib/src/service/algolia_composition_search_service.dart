import 'package:algolia_client_composition/algolia_client_composition.dart'
    as composition;
import 'package:logging/logging.dart';

import '../client_options.dart';
import '../logger.dart';
import '../model/composition_response.dart';
import '../model/composition_state.dart';
import 'client_options.dart';
import 'composition_client_extensions.dart';
import 'composition_search_service.dart';

/// [CompositionSearchService] implementation backed by the Algolia
/// [composition.CompositionClient].
class AlgoliaCompositionSearchService implements CompositionSearchService {
  /// Creates [AlgoliaCompositionSearchService] instance.
  AlgoliaCompositionSearchService({
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

  /// Creates [AlgoliaCompositionSearchService] instance.
  AlgoliaCompositionSearchService.create(
    this._client,
  ) : _log = algoliaLogger('CompositionSearchService');

  /// Search events logger.
  final Logger _log;

  /// Algolia Composition API client
  final composition.CompositionClient _client;

  @override
  Future<CompositionResponse> search(CompositionState state) async {
    _log.fine('run composition search with state: $state');
    try {
      final response = await _client.search(
        compositionID: state.compositionID,
        requestBody: state.toRequestBody(),
      );
      final result = response.toCompositionResponse();
      _log.fine('received response: $result');
      return result;
    } catch (exception) {
      _log.severe('exception: $exception');
      throw launderCompositionException(exception);
    }
  }
}
