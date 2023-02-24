import 'package:algolia/algolia.dart';
import 'package:collection/collection.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'algolia_event_service_adapter.dart';
import 'event_service.dart';
import 'event_tracker.dart';

/// Insights is the component responsible for sending events related to
/// the user to personalize his search
class Insights implements EventTracker {
  /// Index name
  String indexName;

  /// A pseudonymous or anonymous user identifier.
  String userToken;

  @override
  bool isEnabled;

  /// Service sending event packets
  EventService service;

  static const _maxObjectIDsPerEvent = 20;
  static const _maxFiltersPerEvent = 10;
  static const _userTokenKey = 'insights-user-token';

  Insights(String applicationID, String apiKey, String indexName)
      : this.custom(
          AlgoliaEventServiceAdapter(applicationID, apiKey),
          indexName,
        );

  Insights.custom(this.service, this.indexName)
      : userToken = _fetchUserToken(),
        isEnabled = true;

  // TODO: user token generation implementation
  static String _generateUserToken() => 'userToken';

  _fetchUserToken() {
    SharedPreferences.getInstance().then((sharedPreferences) {
      final String? storedUserToken = sharedPreferences.getString(_userTokenKey);
      if (storedUserToken != null) {
        userToken = storedUserToken;
      } else {
        userToken = _generateUserToken();
      }
    });
  }

  /// Set custom user token
  void setUserToken(String userToken) {
    this.userToken = userToken;
    SharedPreferences.getInstance().then((sharedPreferences) => {
      sharedPreferences.setString('_userTokenKey', userToken)
    },);
  }
  /*
      final String? action = prefs.getString('insights-usertoken');
    if (action != null) {

    }
   */

  @override
  void trackClick(String eventName, String attribute, String filterValue) {
    trackClicks(eventName, attribute, [filterValue]);
  }

  @override
  void trackClicks(
    String eventName,
    String attribute,
    List<String> filterValues,
  ) {
    final events = filterValues
        .map((value) => '$attribute:$value')
        .toList()
        .slices(_maxFiltersPerEvent)
        .map(
          (filters) => AlgoliaEvent(
            eventType: AlgoliaEventType.view,
            eventName: eventName,
            index: indexName,
            userToken: userToken,
            filters: filters,
          ),
        )
        .toList();
    _send(events);
  }

  @override
  void trackView(String eventName, String objectID) {
    trackViews(eventName, [objectID]);
  }

  @override
  void trackViews(String eventName, List<String> objectIDs) {
    final events = objectIDs
        .slices(_maxObjectIDsPerEvent)
        .map(
          (filters) => AlgoliaEvent(
            eventType: AlgoliaEventType.view,
            eventName: eventName,
            index: indexName,
            userToken: userToken,
            objectIDs: objectIDs,
          ),
        )
        .toList();
    _send(events);
  }

  void _send(List<AlgoliaEvent> events) {
    if (!isEnabled) {
      return;
    }
    service.send(events);
  }
}
