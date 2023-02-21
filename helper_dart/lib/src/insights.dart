import 'package:algolia/algolia.dart';

abstract class EventTracker {
  bool get isOn;

  void trackClick(String eventName, String attribute, String value);

  void trackView(String eventName, String objectID);

  void trackViews(String eventName, List<String> objectIDs);
}

class Insights implements EventTracker {
  String indexName;
  String userToken;
  @override
  bool isOn;

  Insights(this.indexName)
      : userToken = _generateUserToken(),
        isOn = true;

  void setUserToken(String userToken) {
    this.userToken = userToken;
  }

  void send(List<AlgoliaEvent> event) {
    if (isOn) {
      // send event to Algolia
    }
  }

  static String _generateUserToken() => 'userToken';

  @override
  void trackClick(String eventName, String attribute, String value) {
    final event = AlgoliaEvent(
      eventType: AlgoliaEventType.click,
      eventName: eventName,
      index: indexName,
      userToken: userToken,
      filters: ['$attribute:$value'],
    );
    send([event]);
  }

  @override
  void trackView(String eventName, String objectID) {
    final event = AlgoliaEvent(
      eventType: AlgoliaEventType.view,
      eventName: eventName,
      index: indexName,
      userToken: userToken,
      objectIDs: [objectID],
    );
    send([event]);
  }

  @override
  void trackViews(String eventName, List<String> objectID) {
    // if the size of the list is bigger than 20, we should split it into multiple events
    final event = AlgoliaEvent(
      eventType: AlgoliaEventType.view,
      eventName: eventName,
      index: indexName,
      userToken: userToken,
      objectIDs: objectID,
    );
    send([event]);
  }
}
