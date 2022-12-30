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
  /// Optional hit [position] and custom [eventName] can be provided.
  void click(String objectID, {int position, String eventName});

  /// Track a hit view event.
  /// Optional custom [eventName] can be provided.
  void view(Iterable<String> objectIDs, String eventName, {DateTime? timestamp});

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
  void click(String objectID, {int? position, String? eventName}) {
    // TODO: implement click
  }

  @override
  void convert(String objectID, {String? eventName}) {
    // TODO: implement convert
  }

  @override
  void view(Iterable<String> objectIDs, String eventName, {DateTime? timestamp}) {
    final event = ViewEvent(
      eventName: eventName,
      indexName: _indexName,
      userToken: _userToken,
      timestamp: timestamp ?? DateTime.now(),
      objectIDs: objectIDs,
    );
    _service.view(event);
  }
}
