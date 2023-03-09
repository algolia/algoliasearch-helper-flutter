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
  String get userToken => _userTokenStorage.userToken;

  set userToken(String userToken) {
    _userTokenStorage.userToken = userToken;
  }

  /// Determines how long (in minutes) a user token can be stored in
  /// the persistent storage. Default value is 1440 minutes (1 day).
  /// If set to 0 or a negative value, the user token will not be stored in
  /// persistent storage and will remain in memory.
  set userTokenLeaseTime(int leaseTime) {
    if (leaseTime <= 0) {
      _userTokenStorage.allowPersistentUserTokenStorage = false;
    } else {
      _userTokenStorage
        ..allowPersistentUserTokenStorage = true
        ..leaseTime = leaseTime;
    }
  }

  /// Map storing Insights instances per application ID.
  static final Map<String, Insights> _insightsPool = <String, Insights>{};

  /// Entity managing the user token generation and storage
  final UserTokenStorage _userTokenStorage;

  factory Insights(String applicationID, String apiKey) {
    if (_insightsPool.containsKey(applicationID)) {
      return _insightsPool[applicationID]!;
    }
    final insights = Insights.custom(
      AlgoliaEventServiceAdapter(applicationID, apiKey),
      UserTokenStorage(),
    );
    _insightsPool[applicationID] = insights;
    return insights;
  }

  Insights.custom(this.service, this._userTokenStorage) : isEnabled = true;

  @override
  void trackClick({
    required String indexName,
    required String eventName,
    required String attribute,
    required String value,
  }) =>
      trackClicks(
        indexName: indexName,
        eventName: eventName,
        attribute: attribute,
        values: [value],
      );

  @override
  void trackClicks({
    required String indexName,
    required String eventName,
    required String attribute,
    required List<String> values,
  }) {
    final events = values
        .map((value) => '$attribute:$value')
        .toList()
        .slices(_maxFiltersPerEvent)
        .map(
          (filters) => AlgoliaEvent(
            eventType: AlgoliaEventType.view,
            eventName: eventName,
            index: indexName,
            userToken: _userTokenStorage.userToken,
            filters: filters,
          ),
        )
        .toList();
    _send(events);
  }

  @override
  void trackView({
    required String indexName,
    required String eventName,
    required String objectID,
  }) =>
      trackViews(
        indexName: indexName,
        eventName: eventName,
        objectIDs: [objectID],
      );

  @override
  void trackViews({
    required String indexName,
    required String eventName,
    required List<String> objectIDs,
  }) {
    final events = objectIDs
        .slices(_maxObjectIDsPerEvent)
        .map(
          (filters) => AlgoliaEvent(
            eventType: AlgoliaEventType.view,
            eventName: eventName,
            index: indexName,
            userToken: _userTokenStorage.userToken,
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
