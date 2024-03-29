import 'package:algolia_helper_flutter/algolia_helper_flutter.dart';

void main() {
  // Create a hits searcher.
  // The Searcher performs search requests and obtains search result
  final searcher = HitsSearcher(
    applicationID: 'latency',
    apiKey: '1f6fd3a6fb973cb08419fe7d288fa4db',
    indexName: 'instant_search',
  );

  // Run your search operations and listen the results!
  searcher.responses.listen((response) {
    print("Search query '${response.query}' (${response.nbHits} hits found)");
    for (var hit in response.hits) {
      print("> ${hit['name']}");
    }
  });

  searcher.query('a');

  searcher.eventTracker?.clickedObjects(
    eventName: 'clicked objects',
    objectIDs: ['object1', 'object2', 'object3'],
    positions: [1, 2, 3],
  );

  searcher.eventTracker?.viewedObjects(
    eventName: 'viewed objects',
    objectIDs: ['object1', 'object2', 'object3'],
  );

  searcher.eventTracker?.convertedObjects(
    eventName: 'converted objects',
    objectIDs: ['object1', 'object2', 'object3'],
  );
}
