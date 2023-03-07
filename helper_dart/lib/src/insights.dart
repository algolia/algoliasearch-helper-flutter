import 'package:algolia/algolia.dart';
import 'package:collection/collection.dart';
import 'algolia_event_service_adapter.dart';
import 'event_service.dart';
import 'event_tracker.dart';
import 'user_token_storage.dart';

/// Insights is the component responsible for sending events related to
/// the user to personalize his search
class Insights implements EventTracker {
  @override
  bool isEnabled;

  /// Service sending event packets
  EventService service;

  static const _maxObjectIDsPerEvent = 20;
  static const _maxFiltersPerEvent = 10;

  /// Set custom user token
  static String get userToken => _userTokenController.userToken;

  static set userToken(String userToken) {
    _userTokenController.userToken = userToken;
  }

  /// Determines how long a user token can be stored in the persistent storage.
  /// If set to 0 or a negative value, the user token will not be stored in
  /// persistent storage and will remain in memory.
  static set userTokenLeaseTime(int leaseTime) {
    if (leaseTime <= 0) {
      _userTokenController.allowPersistentUserTokenStorage = false;
    } else {
      _userTokenController.allowPersistentUserTokenStorage = true;
      _userTokenController.leaseTime = leaseTime;
    }
  }

  /// Map storing Insights instances per application ID.
  static final Map<String, Insights> _insightsPool = <String, Insights>{};

  /// Entity managing the user token generation and storage
  static final _userTokenController = UserTokenStorage();

  factory Insights(String applicationID, String apiKey) {
    if (_insightsPool.containsKey(applicationID)) {
      return _insightsPool[applicationID]!;
    }
    final insights = Insights.custom(
      AlgoliaEventServiceAdapter(applicationID, apiKey),
    );
    _insightsPool[applicationID] = insights;
    return insights;
  }

  Insights.custom(this.service) : isEnabled = true;

  @override
  void trackClick(
    String indexName,
    String eventName,
    String attribute,
    String filterValue,
  ) =>
      trackClicks(indexName, eventName, attribute, [filterValue]);

  @override
  void trackClicks(
    String indexName,
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
            userToken: _userTokenController.userToken,
            filters: filters,
          ),
        )
        .toList();
    _send(events);
  }

  @override
  void trackView(String indexName, String eventName, String objectID) =>
      trackViews(indexName, eventName, [objectID]);

  @override
  void trackViews(String indexName, String eventName, List<String> objectIDs) {
    final events = objectIDs
        .slices(_maxObjectIDsPerEvent)
        .map(
          (filters) => AlgoliaEvent(
            eventType: AlgoliaEventType.view,
            eventName: eventName,
            index: indexName,
            userToken: _userTokenController.userToken,
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
