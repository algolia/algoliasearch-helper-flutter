import 'package:algolia_client_insights/algolia_client_insights.dart';
import 'package:logging/logging.dart';

import 'event.dart';
import 'event_service.dart';

/// EventService implementation using community client instance
class AlgoliaEventService implements EventService {
  /// Client instance
  InsightsClient _client;

  /// Logger instance
  final Logger _log;

  AlgoliaEventService(
    String applicationID,
    String apiKey,
  ) : this.create(
          InsightsClient(appId: applicationID, apiKey: apiKey),
        );

  /// Creates [AlgoliaEventService] instance.
  AlgoliaEventService.create(this._client)
      : _log = Logger('Algolia/EventsService');

  @override
  void send(List<Event> events) => _client
      .pushEvents(
          insightsEvents:
              InsightsEvents(events: events.map((e) => e.toAlgoliaEvent())),)
      .then(
        (_) => _log.fine('Events upload: $events'),
        onError: (exception) => _log.severe('Events upload error: $exception'),
      );
}

extension AlgoliaEventConversion on Event {
  dynamic toAlgoliaEvent() {
    switch (type) {
      case EventType.click:
        final objectIDs = this.objectIDs;
        if (objectIDs != null) {
          final queryID = this.queryID;
          final positions = this.positions;
          if (queryID != null && positions != null) {
            return ClickedObjectIDsAfterSearch(
              eventName: eventName,
              eventType: ClickEvent.click,
              index: indexName,
              objectIDs: objectIDs.toList(),
              positions: positions.toList(),
              queryID: queryID,
              userToken: userToken,
              timestamp: timestamp?.millisecondsSinceEpoch,
            );
          } else {
            return ClickedObjectIDs(
              eventName: eventName,
              eventType: ClickEvent.click,
              index: indexName,
              objectIDs: objectIDs.toList(),
              userToken: userToken,
              timestamp: timestamp?.millisecondsSinceEpoch,
            );
          }
        }
        final filterValues = this.filterValues;
        if (filterValues != null) {
          return ClickedFilters(
            eventName: eventName,
            eventType: ClickEvent.click,
            index: indexName,
            filters: filterValues.toList(),
            userToken: userToken,
            timestamp: timestamp?.millisecondsSinceEpoch,
          );
        }
        break;
      case EventType.conversion:
        final objectIDs = this.objectIDs;
        if (objectIDs != null) {
          final queryID = this.queryID;
          if (queryID != null) {
            return ConvertedObjectIDsAfterSearch(
              eventName: eventName,
              eventType: ConversionEvent.conversion,
              index: indexName,
              objectIDs: objectIDs.toList(),
              queryID: queryID,
              userToken: userToken,
              timestamp: timestamp?.millisecondsSinceEpoch,
            );
          } else {
            return ConvertedObjectIDs(
              eventName: eventName,
              eventType: ConversionEvent.conversion,
              index: indexName,
              objectIDs: objectIDs.toList(),
              userToken: userToken,
              timestamp: timestamp?.millisecondsSinceEpoch,
            );
          }
        }
        final filterValues = this.filterValues;
        if (filterValues != null) {
          return ConvertedFilters(
            eventName: eventName,
            eventType: ConversionEvent.conversion,
            index: indexName,
            filters: filterValues.toList(),
            userToken: userToken,
          );
        }
        break;
      case EventType.view:
        final objectIDs = this.objectIDs;
        if (objectIDs != null) {
          return ViewedObjectIDs(
            eventName: eventName,
            eventType: ViewEvent.view,
            index: indexName,
            objectIDs: objectIDs.toList(),
            userToken: userToken,
            timestamp: timestamp?.millisecondsSinceEpoch,
          );
        }
        final filterValues = this.filterValues;
        if (filterValues != null) {
          return ViewedFilters(
            eventName: eventName,
            eventType: ViewEvent.view,
            index: indexName,
            filters: filterValues.toList(),
            userToken: userToken,
            timestamp: timestamp?.millisecondsSinceEpoch,
          );
        }
        break;
    }
    return null;
  }
}
