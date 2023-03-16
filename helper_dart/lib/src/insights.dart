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
  void clickedFilters({
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
            eventType: AlgoliaEventType.click,
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
  void convertedFilters({
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
        eventType: AlgoliaEventType.conversion,
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
  void viewedFilters({
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
  void clickedObjects({
    required String indexName,
    required Iterable<String> objectIDs,
    required String eventName,
    DateTime? timestamp,
  }) {
    final events = objectIDs
        .slices(_maxObjectIDsPerEvent)
        .map(
          (objectIDs) => AlgoliaEvent(
            eventType: AlgoliaEventType.click,
            eventName: eventName,
            index: indexName,
            userToken: _userTokenStorage.userToken,
            objectIDs: objectIDs,
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
          (objectIDs) => AlgoliaEvent(
            eventType: AlgoliaEventType.click,
            eventName: eventName,
            queryID: queryID,
            index: indexName,
            userToken: _userTokenStorage.userToken,
            objectIDs: objectIDs,
            positions: positions.toList(),
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
          (objectIDs) => AlgoliaEvent(
            eventType: AlgoliaEventType.conversion,
            eventName: eventName,
            index: indexName,
            userToken: _userTokenStorage.userToken,
            objectIDs: objectIDs,
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
          (objectIDs) => AlgoliaEvent(
            eventType: AlgoliaEventType.conversion,
            eventName: eventName,
            queryID: queryID,
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
