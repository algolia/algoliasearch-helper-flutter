import 'dart:async';

import 'event.dart';
import 'events_service.dart';

/// Tracker of hits events insights.
abstract class HitsTracker {
  factory HitsTracker({
    required String applicationID,
    required String apiKey,
    required String indexName,
    required String userToken,
  }) =>
      _HitTracker(
        EventsService(
          applicationID: applicationID,
          apiKey: apiKey,
          extraUserAgents: ['algolia-insights-dart (0.0.1)'],
        ),
        indexName,
        userToken,
      );

  /// Track a hit click event.
  /// Optional custom [timestamp] can be provided.
  void click({
    required Iterable<String> objectIDs,
    required String eventName,
    DateTime? timestamp,
  });

  /// Track a hit click event.
  /// Optional custom [timestamp] can be provided.
  void clickAfterQuery({
    required Iterable<String> objectIDs,
    required String eventName,
    required String queryID,
    required Iterable<int> positions,
    DateTime? timestamp,
  });

  /// Track a hit view event.
  /// Optional custom [eventName] and [timestamp] can be provided.
  void view({
    required Iterable<String> objectIDs,
    required String eventName,
    String? queryID,
    DateTime? timestamp,
  });

  /// Track a hit convert event.
  /// Optional custom [eventName] can be provided.
  void convert(String objectID, {String eventName});
}

class _HitTracker implements HitsTracker {
  final EventsService _service;
  final String _indexName;
  final String _userToken;

  _HitTracker(this._service, this._indexName, this._userToken);

  @override
  void clickAfterQuery({
    required Iterable<String> objectIDs,
    required String eventName,
    required String queryID,
    required Iterable<int> positions,
    DateTime? timestamp,
  }) {
    final event = HitClickEvent(
      eventName: eventName,
      indexName: _indexName,
      userToken: _userToken,
      timestamp: timestamp ?? DateTime.now(),
      objectIDs: objectIDs,
      positions: positions,
      queryID: queryID,
    );
    unawaited(_service.click(event));
  }

  @override
  void click({
    required Iterable<String> objectIDs,
    required String eventName,
    DateTime? timestamp,
  }) {
    final event = HitClickEvent(
      eventName: eventName,
      indexName: _indexName,
      userToken: _userToken,
      timestamp: timestamp ?? DateTime.now(),
      objectIDs: objectIDs,
    );
    unawaited(_service.click(event));
  }

  @override
  void convert(String objectID, {String? eventName}) {
    // TODO: implement convert
  }

  @override
  void view({
    required Iterable<String> objectIDs,
    required String eventName,
    String? queryID,
    DateTime? timestamp,
  }) {
    final event = HitViewEvent(
      eventName: eventName,
      indexName: _indexName,
      userToken: _userToken,
      timestamp: timestamp ?? DateTime.now(),
      objectIDs: objectIDs,
    );
    unawaited(_service.view(event));
  }
}
