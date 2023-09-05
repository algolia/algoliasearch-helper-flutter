abstract class EventTracker {
  /// Flag that blocks the sending of event packets when set to false
  bool get isEnabled;

  /// Send a filters click event
  /// Optional custom [timestamp] can be provided.
  void clickedFilters({
    required String indexName,
    required String eventName,
    required String attribute,
    required List<String> values,
    DateTime? timestamp,
  });

  /// Send a filters conversion event
  /// Optional custom [timestamp] can be provided.
  void viewedFilters({
    required String indexName,
    required String eventName,
    required String attribute,
    required List<String> values,
    DateTime? timestamp,
  });

  /// Send a filters conversion event
  /// Optional custom [timestamp] can be provided.
  void convertedFilters({
    required String indexName,
    required String eventName,
    required String attribute,
    required List<String> values,
    DateTime? timestamp,
  });

  /// Track a hits click event.
  /// Optional custom [timestamp] can be provided.
  void clickedObjects({
    required String indexName,
    required String eventName,
    required Iterable<String> objectIDs,
    DateTime? timestamp,
  });

  /// Track a hits click after search event.
  /// Optional custom [timestamp] can be provided.
  void clickedObjectsAfterSearch({
    required String indexName,
    required String eventName,
    required String queryID,
    required Iterable<String> objectIDs,
    required Iterable<int> positions,
    DateTime? timestamp,
  });

  /// Send a hits view event
  /// Optional custom [timestamp] can be provided.
  void viewedObjects({
    required String indexName,
    required String eventName,
    required List<String> objectIDs,
    DateTime? timestamp,
  });

  /// Send a hits conversion event
  /// Optional custom [timestamp] can be provided.
  void convertedObjects({
    required String indexName,
    required String eventName,
    required Iterable<String> objectIDs,
    DateTime? timestamp,
  });

  /// Track a hits conversion after search event.
  /// Optional custom [timestamp] can be provided.
  void convertedObjectsAfterSearch({
    required String indexName,
    required String eventName,
    required String queryID,
    required Iterable<String> objectIDs,
    DateTime? timestamp,
  });
}
