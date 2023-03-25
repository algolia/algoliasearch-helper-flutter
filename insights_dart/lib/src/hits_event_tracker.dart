abstract class HitsEventTracker {
  /// Flag that blocks the sending of event packets when set to false
  bool get isEnabled;

  /// Track a hits click event.
  /// Optional custom [timestamp] can be provided.
  void clickedObjects({
    required String eventName,
    required Iterable<String> objectIDs,
    DateTime? timestamp,
  });

  /// Track a hits click after search event.
  /// Optional custom [timestamp] can be provided.
  void clickedObjectsAfterSearch({
    required String eventName,
    required String queryID,
    required Iterable<String> objectIDs,
    required Iterable<int> positions,
    DateTime? timestamp,
  });

  /// Send a hits view event
  /// Optional custom [timestamp] can be provided.
  void viewedObjects({
    required String eventName,
    required List<String> objectIDs,
    DateTime? timestamp,
  });

  /// Send a hits conversion event
  /// Optional custom [timestamp] can be provided.
  void convertedObjects({
    required String eventName,
    required Iterable<String> objectIDs,
    DateTime? timestamp,
  });

  /// Track a hits conversion after search event.
  /// Optional custom [timestamp] can be provided.
  void convertedObjectsAfterSearch({
    required String eventName,
    required String queryID,
    required Iterable<String> objectIDs,
    DateTime? timestamp,
  });
}
