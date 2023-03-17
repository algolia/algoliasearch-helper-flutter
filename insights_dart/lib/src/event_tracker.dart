abstract class EventTracker {
  /// Flag that blocks the sending of event packets when set to false
  bool get isEnabled;

  /// Send filter click events
  void clickedFilters({
    required String indexName,
    required String eventName,
    required String attribute,
    required List<String> values,
  });

  /// Send filter conversion events
  void viewedFilters({
    required String indexName,
    required String eventName,
    required String attribute,
    required List<String> values,
  });

  /// Send filter conversion events
  void convertedFilters({
    required String indexName,
    required String eventName,
    required String attribute,
    required List<String> values,
  });

  /// Track a hit click event.
  /// Optional custom [timestamp] can be provided.
  void clickedObjects({
    required String indexName,
    required String eventName,
    required Iterable<String> objectIDs,
    DateTime? timestamp,
  });

  /// Track a hit click event.
  /// Optional custom [timestamp] can be provided.
  void clickedObjectsAfterSearch({
    required String indexName,
    required String eventName,
    required String queryID,
    required Iterable<String> objectIDs,
    required Iterable<int> positions,
    DateTime? timestamp,
  });

  /// Send hit view events
  void viewedObjects({
    required String indexName,
    required String eventName,
    required List<String> objectIDs,
  });

  void convertedObjects({
    required String indexName,
    required String eventName,
    required Iterable<String> objectIDs,
    DateTime? timestamp,
  });

  void convertedObjectsAfterSearch({
    required String indexName,
    required String eventName,
    required String queryID,
    required Iterable<String> objectIDs,
    DateTime? timestamp,
  });
}
