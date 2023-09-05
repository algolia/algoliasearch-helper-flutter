import 'package:algolia_helper_flutter/algolia_helper_flutter.dart';

void main() {
  // Create a facet searcher.
  // The Searcher performs search for facet values request
  // and obtains search result
  final facetSearcher = FacetSearcher(
    applicationID: 'MY_APPLICATION_ID',
    apiKey: 'MY_API_KEY',
    indexName: 'MY_INDEX_NAME',
    facet: 'MY_FACET_ATTRIBUTE',
  );

  // Run your search operations and listen the results!
  facetSearcher.responses.listen((response) {
    for (var facet in response.facetHits) {
      print("> ${facet.value} (${facet.count})");
    }
  });

  facetSearcher.query('a');
}
