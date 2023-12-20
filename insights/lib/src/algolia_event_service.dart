import 'package:algolia_client_insights/algolia_client_insights.dart';
import 'package:collection/collection.dart';
import 'package:logging/logging.dart';

import 'event.dart';
import 'event_service.dart';
import 'lib_version.dart';

/// EventService implementation using community client instance
class AlgoliaEventService implements EventService {
  /// Client instance
  InsightsClient _client;

  /// Logger instance
  final Logger _log;

  AlgoliaEventService({
    required String applicationID,
    required String apiKey,
    String? region,
  }) : this.create(
          InsightsClient(
            appId: applicationID,
            apiKey: apiKey,
            region: region,
            options: const ClientOptions(
              agentSegments: [
                AgentSegment(
                  value: 'algolia-insights-flutter',
                  version: libVersion,
                )
              ],
            ),
          ),
        );

  /// Creates [AlgoliaEventService] instance.
  AlgoliaEventService.create(this._client)
      : _log = Logger('Algolia/EventsService');

  @override
  void send(List<Event> events) => _client
      .pushEvents(
        insightsEvents: InsightsEvents(
          events: events.map((e) => e.toAlgoliaEvent()).whereNotNull(),
        ),
      )
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
        if (objectIDs != null && objectIDs.isNotEmpty) {
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
        if (filterValues != null &&
            filterValues.isNotEmpty &&
            attribute != null) {
          return ClickedFilters(
            eventName: eventName,
            eventType: ClickEvent.click,
            index: indexName,
            filters: filterValues
                .map((val) => Uri.encodeComponent('$attribute:$val'))
                .toList(),
            userToken: userToken,
            timestamp: timestamp?.millisecondsSinceEpoch,
          );
        }
        break;
      case EventType.conversion:
        final objectIDs = this.objectIDs;
        if (objectIDs != null && objectIDs.isNotEmpty) {
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
        if (filterValues != null &&
            filterValues.isNotEmpty &&
            attribute != null) {
          return ConvertedFilters(
            eventName: eventName,
            eventType: ConversionEvent.conversion,
            index: indexName,
            filters: filterValues
                .map((val) => Uri.encodeComponent('$attribute:$val'))
                .toList(),
            userToken: userToken,
            timestamp: timestamp?.millisecondsSinceEpoch,
          );
        }
        break;
      case EventType.view:
        final objectIDs = this.objectIDs;
        if (objectIDs != null && objectIDs.isNotEmpty) {
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
        if (filterValues != null &&
            filterValues.isNotEmpty &&
            attribute != null) {
          return ViewedFilters(
            eventName: eventName,
            eventType: ViewEvent.view,
            index: indexName,
            filters: filterValues
                .map((val) => Uri.encodeComponent('$attribute:$val'))
                .toList(),
            userToken: userToken,
            timestamp: timestamp?.millisecondsSinceEpoch,
          );
        }
        break;
    }
    return null;
  }
}
