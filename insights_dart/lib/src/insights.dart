import 'package:collection/collection.dart';
import 'algolia_event_service.dart';
import 'event.dart';
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
      AlgoliaEventService(applicationID, apiKey),
      UserTokenStorage(),
    );
    _insightsPool[applicationID] = insights;
    return insights;
  }

  Insights.custom(this.service, this._userTokenStorage) : isEnabled = true;

  @override
  void clickedFilters({
    required String indexName,
    required String eventName,
    required String attribute,
    required List<String> values,
    DateTime? timestamp,
  }) {
    final events = values
        .map((value) => '$attribute:$value')
        .toList()
        .slices(_maxFiltersPerEvent)
        .map(
          (filters) => Event.clickFilters(
            eventName,
            indexName,
            userToken,
            attribute,
            values,
            timestamp: timestamp,
          ),
        )
        .toList();
    _send(events);
  }

  @override
  void convertedFilters({
    required String indexName,
    required String eventName,
    required String attribute,
    required List<String> values,
    DateTime? timestamp,
  }) {
    final events = values
        .map((value) => '$attribute:$value')
        .toList()
        .slices(_maxFiltersPerEvent)
        .map(
          (filters) => Event.convertFilters(
            eventName,
            indexName,
            userToken,
            attribute,
            values,
            timestamp: timestamp,
          ),
        )
        .toList();
    _send(events);
  }

  @override
  void viewedFilters({
    required String indexName,
    required String eventName,
    required String attribute,
    required List<String> values,
    DateTime? timestamp,
  }) {
    final events = values
        .map((value) => '$attribute:$value')
        .toList()
        .slices(_maxFiltersPerEvent)
        .map(
          (filters) => Event.viewFilters(
            eventName,
            indexName,
            userToken,
            attribute,
            values,
            timestamp: timestamp,
          ),
        )
        .toList();
    _send(events);
  }

  @override
  void clickedObjects({
    required String indexName,
    required Iterable<String> objectIDs,
    required String eventName,
    DateTime? timestamp,
  }) {
    final events = objectIDs
        .slices(_maxObjectIDsPerEvent)
        .map(
          (objectIDs) => Event.clickHits(
            eventName,
            indexName,
            userToken,
            objectIDs,
            timestamp: timestamp,
          ),
        )
        .toList();
    _send(events);
  }

  @override
  void clickedObjectsAfterSearch({
    required String indexName,
    required Iterable<String> objectIDs,
    required String eventName,
    required String queryID,
    required Iterable<int> positions,
    DateTime? timestamp,
  }) {
    final events = objectIDs
        .slices(_maxObjectIDsPerEvent)
        .map(
          (objectIDs) => Event.clickHitsAfterSearch(
            eventName,
            indexName,
            userToken,
            queryID,
            objectIDs,
            positions,
            timestamp: timestamp,
          ),
        )
        .toList();
    _send(events);
  }

  @override
  void viewedObjects({
    required String indexName,
    required String eventName,
    required List<String> objectIDs,
    DateTime? timestamp,
  }) {
    final events = objectIDs
        .slices(_maxObjectIDsPerEvent)
        .map(
          (filters) => Event.viewHits(
            eventName,
            indexName,
            userToken,
            objectIDs,
            timestamp: timestamp,
          ),
        )
        .toList();
    _send(events);
  }

  @override
  void convertedObjects({
    required String indexName,
    required String eventName,
    required Iterable<String> objectIDs,
    DateTime? timestamp,
  }) {
    final events = objectIDs
        .slices(_maxObjectIDsPerEvent)
        .map(
          (objectIDs) => Event.convertHits(
            eventName,
            indexName,
            userToken,
            objectIDs,
            timestamp: timestamp,
          ),
        )
        .toList();
    _send(events);
  }

  @override
  void convertedObjectsAfterSearch({
    required String indexName,
    required String eventName,
    required String queryID,
    required Iterable<String> objectIDs,
    DateTime? timestamp,
  }) {
    final events = objectIDs
        .slices(_maxObjectIDsPerEvent)
        .map(
          (objectIDs) => Event.convertHitsAfterSearch(
            eventName,
            indexName,
            userToken,
            queryID,
            objectIDs,
            timestamp: timestamp,
          ),
        )
        .toList();
    _send(events);
  }

  void _send(List<Event> events) {
    if (!isEnabled) {
      return;
    }
    service.send(events);
  }
}
