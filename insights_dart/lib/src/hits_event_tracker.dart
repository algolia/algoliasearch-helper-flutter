import '../algolia_insights.dart';

/// Wrapper for an EventTracker with associated indexName and queryID
class HitsEventTracker {
  /// Underlying EventTracker instance.
  EventTracker tracker;

  /// Name of the index to associate events with.
  String indexName;

  /// Latest query ID value
  String? queryID;

  /// Flag that blocks the sending of event packets when set to false
  bool isEnabled;

  HitsEventTracker(
    this.tracker,
    this.indexName, {
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
    if (queryID == null) {
      tracker.clickedObjects(
        indexName: indexName,
        eventName: eventName,
        objectIDs: objectIDs,
        timestamp: timestamp,
      );
    } else {
      tracker.clickedObjectsAfterSearch(
        indexName: indexName,
        eventName: eventName,
        queryID: queryID!,
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
      indexName: indexName,
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
    if (queryID == null) {
      tracker.convertedObjects(
        indexName: indexName,
        eventName: eventName,
        objectIDs: objectIDs,
        timestamp: timestamp,
      );
    } else {
      tracker.convertedObjectsAfterSearch(
        indexName: indexName,
        eventName: eventName,
        queryID: queryID!,
        objectIDs: objectIDs,
        timestamp: timestamp,
      );
    }
  }
}
