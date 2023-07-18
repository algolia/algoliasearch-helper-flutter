import 'package:algoliasearch/algoliasearch_lite.dart' as algolia;
import 'package:logging/logging.dart';

import '../logger.dart';
import '../model/search_response.dart';
import '../query_builder.dart';
import '../search_state.dart';
import 'algolia_hits_search_service.dart';
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
  Future<List<SearchResponse>> search(List<SearchState> states) async {
// Map to store SearchState and corresponding QueryBuilder
    final builders = <SearchState, QueryBuilder>{};

// List to hold all SearchForHits instances to be queried
    final allQueries = <algolia.SearchForHits>[];

// For each state, create a builder, build queries, and add them to allQueries
    for (var state in states) {
      final builder = QueryBuilder(state);
      final queries = builder.build();
      builders[queries[0]] =
          builder; // Store builder with reference to the first state
      allQueries.addAll(
        queries.map((s) => s.toRequest()),
      ); // Convert states to queries
    }

// Perform search with all queries
    final responses = await _client.searchMultiIndex(queries: allQueries);

// Transform Algolia search results to SearchResponse instances
    final searchResponses =
        responses.results.map((e) => e.toSearchResponse()).toList();

// Prepare final list of merged responses
    final finalResponses = <SearchResponse>[];

// Iterate over the map, for each state get corresponding responses and
// merge them
    for (var entry in builders.entries) {
// Calculate number of queries for this builder
      final int queriesCount = entry.value._totalQueriesCount;

// Get corresponding responses
      final correspondingResponses = searchResponses.sublist(0, queriesCount);

// Remove processed responses from the list
      searchResponses.removeRange(0, queriesCount);

// Merge responses
      final mergedResponse = entry.value.merge(correspondingResponses);

// Add merged response to the final list
      finalResponses.add(mergedResponse);
    }

    return finalResponses;
  }
}
