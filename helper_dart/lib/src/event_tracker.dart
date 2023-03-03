abstract class EventTracker {
  /// Switch that blocks the sending of event packets when set to false
  bool get isEnabled;

  /// Track filter click event
  void trackClick(
    String indexName,
    String eventName,
    String attribute,
    String value,
  );

  /// Track filter click events
  void trackClicks(
    String indexName,
    String eventName,
    String attribute,
    List<String> values,
  );

  /// Track hit view event
  void trackView(
    String indexName,
    String eventName,
    String objectID,
  );

  /// Track hit view events
  void trackViews(
    String indexName,
    String eventName,
    List<String> objectIDs,
  );
}
