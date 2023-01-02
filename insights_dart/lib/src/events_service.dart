import 'package:algolia/algolia.dart';
import 'package:logging/logging.dart';

import 'event.dart';

class EventsService {
  EventsService({
    required String applicationID,
    required String apiKey,
    required List<String> extraUserAgents,
  }) : this.create(
          Algolia.init(
            applicationId: applicationID,
            apiKey: apiKey,
            extraUserAgents: extraUserAgents,
          ),
        );

  /// Creates [EventsService] instance.
  EventsService.create(this._client) : _log = Logger('Algolia/EventsService');

  final Algolia _client;
  final Logger _log;

  Future<void> view(HitViewEvent event) {
    final events = [event.toViewEvent()];
    return _sendEvents(events);
  }

  Future<void> click(HitClickEvent event) {
    final events = [event.toClickEvent()];
    return _sendEvents(events);
  }

  Future<void> _sendEvents(List<AlgoliaEvent> events) {
    try {
      _log.fine('Events upload: $events');
      return _client.pushEvents(events);
    } catch (exception) {
      _log.severe('Events upload error: $exception');
      rethrow; // TODO: wrap the error
    }
  }
}

extension HitViewEventExt on HitViewEvent {
  AlgoliaEvent toViewEvent() => AlgoliaEvent(
        eventType: AlgoliaEventType.view,
        eventName: eventName,
        index: indexName,
        userToken: userToken,
        timestamp: timestamp,
        objectIDs: objectIDs.toList(),
      );
}

extension HitClickEventExt on HitClickEvent {
  AlgoliaEvent toClickEvent() => AlgoliaEvent(
        eventType: AlgoliaEventType.click,
        eventName: eventName,
        index: indexName,
        userToken: userToken,
        timestamp: timestamp,
        objectIDs: objectIDs?.toList(),
        queryID: queryID,
        positions: positions?.toList(),
      );
}
