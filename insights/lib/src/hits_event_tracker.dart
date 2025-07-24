import 'package:algolia_client_insights/algolia_client_insights.dart';

import '../algolia_insights.dart';

/// Wrapper for an EventTracker with associated indexName and queryID
class HitsEventTracker {
  /// Underlying EventTracker instance.
  EventTracker tracker;

  /// Delegate providing external events data
  EventDataDelegate delegate;

  /// Flag that blocks the sending of event packets when set to false
  bool isEnabled;

  HitsEventTracker(
    this.tracker,
    this.delegate, {
    this.isEnabled = true,
  });

  /// Track a hits click event.
  /// Optional custom [timestamp] can be provided.
  void clickedObjects({
    required String eventName,
    required Iterable<String> objectIDs,
    Iterable<int>? positions,
    DateTime? timestamp,
  }) {
    if (!isEnabled) {
      return;
    }
    if (delegate.queryID == null) {
      tracker.clickedObjects(
        indexName: delegate.indexName,
        eventName: eventName,
        objectIDs: objectIDs,
        timestamp: timestamp,
      );
    } else {
      tracker.clickedObjectsAfterSearch(
        indexName: delegate.indexName,
        eventName: eventName,
        queryID: delegate.queryID!,
        objectIDs: objectIDs,
        positions: positions!,
        timestamp: timestamp,
      );
    }
  }

  /// Send a hits view event
  /// Optional custom [timestamp] can be provided.
  void viewedObjects({
    required String eventName,
    required List<String> objectIDs,
    DateTime? timestamp,
  }) {
    if (!isEnabled) {
      return;
    }
    tracker.viewedObjects(
      indexName: delegate.indexName,
      eventName: eventName,
      objectIDs: objectIDs,
      timestamp: timestamp,
    );
  }

  /// Send a hits conversion event
  /// Optional custom [timestamp] can be provided.
  void convertedObjects({
    required String eventName,
    required Iterable<String> objectIDs,
    DateTime? timestamp,
  }) {
    if (!isEnabled) {
      return;
    }
    if (delegate.queryID == null) {
      tracker.convertedObjects(
        indexName: delegate.indexName,
        eventName: eventName,
        objectIDs: objectIDs,
        timestamp: timestamp,
      );
    } else {
      tracker.convertedObjectsAfterSearch(
        indexName: delegate.indexName,
        eventName: eventName,
        queryID: delegate.queryID!,
        objectIDs: objectIDs,
        timestamp: timestamp,
      );
    }
  }

  InsightsClient get client => tracker.client;
}
