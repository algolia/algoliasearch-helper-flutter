abstract class EventTracker {
  /// Flag that blocks the sending of event packets when set to false
  bool get isEnabled;

  /// Send filter click event
  void trackClick(
    String indexName,
    String eventName,
    String attribute,
    String value,
  );

  /// Send filter click events
  void trackClicks(
    String indexName,
    String eventName,
    String attribute,
    List<String> values,
  );

  /// Send hit view event
  void trackView(
    String indexName,
    String eventName,
    String objectID,
  );

  /// Send hit view events
  void trackViews(
    String indexName,
    String eventName,
    List<String> objectIDs,
  );
}
