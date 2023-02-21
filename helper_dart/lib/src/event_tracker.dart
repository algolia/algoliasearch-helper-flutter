abstract class EventTracker {
  bool get isEnabled;

  void trackClick(String eventName, String attribute, String value);

  void trackClicks(String eventName, String attribute, List<String> values);

  void trackView(String eventName, String objectID);

  void trackViews(String eventName, List<String> objectIDs);
}