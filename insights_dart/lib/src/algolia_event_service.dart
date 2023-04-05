import 'package:algolia/algolia.dart';
import 'package:logging/logging.dart';

import 'event.dart';
import 'event_service.dart';

/// EventService implementation using community client instance
class AlgoliaEventService implements EventService {
  /// Client instance
  Algolia _client;

  /// Logger instance
  final Logger _log;

  AlgoliaEventService(
    String applicationID,
    String apiKey,
  ) : this.create(
          Algolia.init(
            applicationId: applicationID,
            apiKey: apiKey,
            extraUserAgents: ['algolia-insights-dart (0.0.1)'],
          ),
        );

  /// Creates [AlgoliaEventService] instance.
  AlgoliaEventService.create(this._client)
      : _log = Logger('Algolia/EventsService');

  @override
  void send(List<Event> events) => _client
      .pushEvents(events.map((event) => event.toAlgoliaEvent()).toList())
      .then(
        (_) => _log.fine('Events upload: $events'),
        onError: (exception) => _log.severe('Events upload error: $exception'),
      );
}

extension AlgoliaEventTypeConversion on EventType {
  AlgoliaEventType toAlgoliaEventType() {
    switch (this) {
      case EventType.view:
        return AlgoliaEventType.view;
      case EventType.click:
        return AlgoliaEventType.click;
      case EventType.conversion:
        return AlgoliaEventType.conversion;
    }
  }
}

extension AlgoliaEventConversion on Event {
  AlgoliaEvent toAlgoliaEvent() => AlgoliaEvent(
        eventType: type.toAlgoliaEventType(),
        eventName: eventName,
        index: indexName,
        userToken: userToken,
        timestamp: timestamp,
        objectIDs: objectIDs?.toList(),
        positions: positions?.toList(),
        filters: filterValues?.map((value) => '$attribute:$value').toList(),
      );
}
