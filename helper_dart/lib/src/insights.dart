import 'package:algolia/algolia.dart';
import 'package:collection/collection.dart';

import 'event_tracker.dart';

// package insights-dart
class Insights implements EventTracker {
  String indexName;
  String userToken;
  @override
  bool enabled;

  final _maxObjectIDsPerEvent = 20;
  final _maxFiltersPerEvent = 10;

  Insights(this.indexName)
      : userToken = _generateUserToken(),
        enabled = true;

  void setUserToken(String userToken) {
    this.userToken = userToken;
  }

  void send(List<AlgoliaEvent> event) {
    if (enabled) {
      // send event to Algolia
    }
  }

  static String _generateUserToken() => 'userToken'; // ask how it's done for js

  @override
  void trackClick(String eventName, String attribute, String filterValue) {
    trackClicks(eventName, attribute, [filterValue]);
  }

  @override
  void trackClicks(
    String eventName,
    String attribute,
    List<String> filterValues,
  ) {
    final events = filterValues
        .map((value) => '$attribute:$value')
        .toList()
        .slices(_maxFiltersPerEvent)
        .map((filters) => AlgoliaEvent(
              eventType: AlgoliaEventType.view,
              eventName: eventName,
              index: indexName,
              userToken: userToken,
              filters: filters,
            ))
        .toList();
    send(events);
  }

  @override
  void trackView(String eventName, String objectID) {
    trackViews(eventName, [objectID]);
  }

  @override
  void trackViews(String eventName, List<String> objectIDs) {
    final events = objectIDs
        .slices(_maxObjectIDsPerEvent)
        .map((filters) => AlgoliaEvent(
              eventType: AlgoliaEventType.view,
              eventName: eventName,
              index: indexName,
              userToken: userToken,
              objectIDs: objectIDs,
            ))
        .toList();
    send(events);
  }
}
