import 'package:algolia_helper_flutter/algolia_helper_flutter.dart';

void main() {
  // Create a composition searcher.
  // The searcher runs a composition and obtains its results.
  final searcher = CompositionSearcher(
    applicationID: 'MY_APPLICATION_ID',
    apiKey: 'MY_API_KEY',
    compositionID: 'MY_COMPOSITION_ID',
  );

  // Run your composition run operations and listen to the results!
  searcher.responses.listen((response) {
    print("Search query '${response.query}' (${response.nbHits} hits found)");
    for (var hit in response.hits) {
      print("> ${hit['name']}");
    }

    // Multifeed compositions expose each feed's results.
    final feeds = response.feeds;
    if (feeds != null) {
      for (var feed in feeds) {
        print("Feed '${feed.feedID}': ${feed.nbHits} hits");
      }
    }
  });

  searcher.query('a');

  searcher.eventTracker?.clickedObjects(
    eventName: 'clicked objects',
    objectIDs: ['object1', 'object2', 'object3'],
    positions: [1, 2, 3],
  );
}
