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

  Future<void> view(ViewEvent event) {
    try {
      _log.fine('Event upload: $event');
      return _client.pushEvents([event.toAlgoliaEvent()]);
    } catch (exception) {
      _log.severe('Event upload error: $exception');
      rethrow; // TODO: wrap the error
    }
  }
}

extension ViewEventExt on ViewEvent {
  AlgoliaEvent toAlgoliaEvent() => AlgoliaEvent(
        eventType: AlgoliaEventType.view,
        eventName: eventName,
        index: indexName,
        userToken: userToken,
        timestamp: timestamp,
        objectIDs: objectIDs.toList(),
      );
}
