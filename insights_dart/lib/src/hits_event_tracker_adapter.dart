import '../algolia_insights.dart';

/// Wrapper for an EventTracker with associated indexName
/// implementing HitsEventTracker
class HitsEventTrackerAdapter implements HitsEventTracker {
  /// Underlying EventTracker instance.
  EventTracker tracker;

  /// Name of the index to associate events with.
  String indexName;

  @override
  bool isEnabled;

  HitsEventTrackerAdapter(
    this.tracker,
    this.indexName, {
    this.isEnabled = true,
  });

  /// Track a hits click event.
  /// Optional custom [timestamp] can be provided.
  @override
  void clickedObjects({
    required String eventName,
    required Iterable<String> objectIDs,
    DateTime? timestamp,
  }) {
    if (isEnabled) {
      tracker.clickedObjects(
        indexName: indexName,
        eventName: eventName,
        objectIDs: objectIDs,
        timestamp: timestamp,
      );
    }
  }

  /// Track a hits click after search event.
  /// Optional custom [timestamp] can be provided.
  @override
  void clickedObjectsAfterSearch({
    required String eventName,
    required String queryID,
    required Iterable<String> objectIDs,
    required Iterable<int> positions,
    DateTime? timestamp,
  }) {
    if (isEnabled) {
      tracker.clickedObjectsAfterSearch(
        indexName: indexName,
        eventName: eventName,
        queryID: queryID,
        objectIDs: objectIDs,
        positions: positions,
        timestamp: timestamp,
      );
    }
  }

  /// Send a hits view event
  /// Optional custom [timestamp] can be provided.
  @override
  void viewedObjects({
    required String eventName,
    required List<String> objectIDs,
    DateTime? timestamp,
  }) {
    if (isEnabled) {
      tracker.viewedObjects(
        indexName: indexName,
        eventName: eventName,
        objectIDs: objectIDs,
        timestamp: timestamp,
      );
    }
  }

  /// Send a hits conversion event
  /// Optional custom [timestamp] can be provided.
  @override
  void convertedObjects({
    required String eventName,
    required Iterable<String> objectIDs,
    DateTime? timestamp,
  }) {
    if (isEnabled) {
      tracker.convertedObjects(
        indexName: indexName,
        eventName: eventName,
        objectIDs: objectIDs,
        timestamp: timestamp,
      );
    }
  }

  /// Track a hits conversion after search event.
  /// Optional custom [timestamp] can be provided.
  @override
  void convertedObjectsAfterSearch({
    required String eventName,
    required String queryID,
    required Iterable<String> objectIDs,
    DateTime? timestamp,
  }) {
    if (isEnabled) {
      tracker.convertedObjectsAfterSearch(
        indexName: indexName,
        eventName: eventName,
        queryID: queryID,
        objectIDs: objectIDs,
        timestamp: timestamp,
      );
    }
  }
}
