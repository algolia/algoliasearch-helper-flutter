import 'package:algolia_helper/algolia_helper.dart';

void main() {
  // Create a hits searcher.
  // The Searcher performs search requests and obtains search result
  final searcher = HitsSearcher(
    applicationID: 'latency',
    apiKey: '1a23398ec6339348c9a753b22aaed3cb',
    indexName: 'movies',
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
    print('${response.nbHits} hits found');
    print('query: ${response.params}');
    for (var hit in response.hits) {
      print("> ${hit['title']}");
    }
  });

  searcher.query('a');
}
