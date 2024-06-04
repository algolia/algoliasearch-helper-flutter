import 'package:algolia_helper_flutter/algolia_helper_flutter.dart';

void main() {
  // Create the component to handle the filtering logic: FilterState.
  final filterState = FilterState();

  // Create a hits searcher.
  // The Searcher performs search requests and obtains search result
  final searcher = HitsSearcher(
    applicationID: 'latency',
    apiKey: '1f6fd3a6fb973cb08419fe7d288fa4db',
    indexName: 'instant_search',
  )
    // Create a connection between the searcher and the filter state
    ..connectFilterState(filterState);

  // Create facet list components that displays facets, and lets the user refine
  // their search results by filtering on specific values.
  final facetList =
      searcher.buildFacetList(filterState: filterState, attribute: 'brand');

  // Listen to facet lists with selection status.
  facetList.facets.listen((facets) {
    print('${facets.length} facets found');
    for (var facet in facets) {
      final item = facet.item;
      final selected = facet.isSelected ? 'x' : ' ';
      print('[$selected] ${item.value} (${item.count})');
    }
  });

  // Listen to search results
  searcher.responses.listen((response) {
    print("Search query '${response.query}' '(${response.nbHits} hits found)");
    for (var hit in response.hits) {
      print("> ${hit['name']}");
    }
  });

  // Run a search query
  searcher.query('a');

  // Apply a facet filter
  facetList.toggle('Samsung');

  facetList.eventTracker?.clickedFilters(
    eventName: 'did click filters',
    values: ['Samsung'],
  );

  facetList.eventTracker?.viewedFilters(
    eventName: 'viewed filters',
    values: ['Samsung'],
  );

  facetList.eventTracker?.convertedFilters(
    eventName: 'converted filters',
    values: ['Samsung'],
  );
}
