import 'package:algolia_helper/algolia_helper.dart';

void main() {
  // Create the component to handle the filtering logic: FilterState.
  final filterState = FilterState();

  // Create a hits searcher.
  // The Searcher performs search requests and obtains search result
  final searcher = HitsSearcher(
    applicationID: 'MY_APPLICATION_ID',
    apiKey: 'MY_API_KEY',
    indexName: 'MY_INDEX_NAME',
  )
    // Create a connection between the searcher and the filter state
    ..connectFilterState(filterState);

  // Create facet list components that displays facets, and lets the user refine
  // their search results by filtering on specific values.
  final facetList = FacetList(
    searcher: searcher,
    filterState: filterState,
    attribute: 'actors',
  );

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
      print("> ${hit['title']}");
    }
  });

  // Run a search query
  searcher.query('a');

  // Apply a facet filter
  facetList.toggle('Samuel L. Jackson');

  facetList.eventTracker.clickedFilters(
    eventName: 'did click filters',
    values: ['Samuel L. Jackson'],
  );

  facetList.eventTracker.viewedFilters(
    eventName: 'viewed filters',
    values: ['Samuel L. Jackson'],
  );

  facetList.eventTracker.convertedFilters(
    eventName: 'converted filters',
    values: ['Samuel L. Jackson'],
  );
}
