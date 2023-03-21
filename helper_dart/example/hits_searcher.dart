import 'package:algolia_helper/algolia_helper.dart';

void main() {
  // Create a hits searcher.
  // The Searcher performs search requests and obtains search result
  final searcher = HitsSearcher(
    applicationID: 'MY_APPLICATION_ID',
    apiKey: 'MY_API_KEY',
    indexName: 'MY_INDEX_NAME',
  );

  // Run your search operations and listen the results!
  searcher.responses.listen((response) {
    print("Search query '${response.query}' (${response.nbHits} hits found)");
    for (var hit in response.hits) {
      print("> ${hit['title']}");
    }
  });

  searcher.query('a');

  searcher.clickedObjects(
      eventName: 'clicked objects',
      objectIDs: ['object1', 'object2', 'object3'],
      positions: [1, 2, 3],);

  searcher.viewedObjects(
      eventName: 'viewed objects',
      objectIDs: ['object1', 'object2', 'object3'],);

  searcher.convertedObjects(eventName: 'converted objects',
      objectIDs: ['object1', 'object2', 'object3'],);
}
