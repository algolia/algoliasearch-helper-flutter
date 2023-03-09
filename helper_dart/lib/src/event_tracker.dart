abstract class EventTracker {
  /// Flag that blocks the sending of event packets when set to false
  bool get isEnabled;

  /// Send filter click event
  void trackClick({
    required String indexName,
    required String eventName,
    required String attribute,
    required String value,
  });

  /// Send filter click events
  void trackClicks({
    required String indexName,
    required String eventName,
    required String attribute,
    required List<String> values,
  });

  /// Send hit view event
  void trackView({
    required String indexName,
    required String eventName,
    required String objectID,
  });

  /// Send hit view events
  void trackViews({
    required String indexName,
    required String eventName,
    required List<String> objectIDs,
  });
}
