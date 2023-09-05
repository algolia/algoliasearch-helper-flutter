import 'package:algolia_helper_flutter/algolia_helper_flutter.dart';

void main() {
  // Create a multi searcher
  final multiSearcher = MultiSearcher(
    applicationID: 'latency',
    apiKey: '1f6fd3a6fb973cb08419fe7d288fa4db',
  );

  // Instantiate a facet searcher from multi searcher
  final hitsSearcher = multiSearcher.addHitsSearcher(
    initialState: const SearchState(
      indexName: 'instant_search',
    ),
  );

  // Instantiate a facet searcher from multi searcher
  final facetSearcher = multiSearcher.addFacetSearcher(
      initialState: const FacetSearchState(
    facet: 'brand',
    searchState: SearchState(
      indexName: 'instant_search',
    ),
  ));

  // Use facet and hits searcher as independent components

  // Run your search operations and listen the results!
  hitsSearcher.responses.listen((response) {
    print("Search query '${response.query}' (${response.nbHits} hits found)");
    for (var hit in response.hits) {
      print("> ${hit['name']}");
    }
  });

  facetSearcher.responses.listen((response) {
    for (var facet in response.facetHits) {
      print("> ${facet.value} (${facet.count})");
    }
  });

  hitsSearcher.query('a');
  facetSearcher.query('a');
}
