import 'package:algolia_helper/algolia_helper.dart';

void main() {
  // Create a hits searcher.
  // The Searcher performs search requests and obtains search result
  final searcher = HitsSearcher(
    applicationID: 'MY_APPLICATION_ID',
    apiKey: 'MY_API_KEY',
    indexName: 'MY_INDEX_NAME',
  );

  // Create the component to handle the filtering logic: FilterState.
  final group = FilterGroupID.and('products');
  final filterState = FilterState()
    ..add(group, {Filter.facet('genre', 'Comedy')})
    ..add(group, {Filter.range('rating', lowerBound: 3, upperBound: 5)});

  // Create a connection between the searcher and the filter state
  searcher.connectFilterState(filterState);

  // Run your search operations and listen the results!
  searcher.responses.listen((response) {
    print("Search query '${response.query}' (${response.nbHits} hits found)");
    for (var hit in response.hits) {
      print("> ${hit['title']}");
    }
  });

  searcher.query('a');
}
