import 'package:algolia_client_insights/algolia_client_insights.dart';
import 'package:logging/logging.dart';
import 'package:meta/meta.dart';

import 'event.dart';
import 'event_service.dart';
import 'lib_version.dart';

/// Abstraction over the Insights client's push API to enable testing.
/// @nodoc - Internal use only, exposed for testing.
@internal
abstract class PushEvents {
  Future<void> pushEvents({required InsightsEvents insightsEvents});
}

class _InsightsClient implements PushEvents {
  final InsightsClient _client;
  _InsightsClient(this._client);

  @override
  Future<void> pushEvents({required InsightsEvents insightsEvents}) {
    return _client.pushEvents(insightsEvents: insightsEvents);
  }
}

/// EventService implementation using community client instance
class AlgoliaEventService implements EventService {
  /// client instance
  final PushEvents _client;

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
                ),
              ],
            ),
          ),
        );

  /// Creates [AlgoliaEventService] instance from an InsightsClient.
  AlgoliaEventService.create(InsightsClient client)
      : this.withClient(_InsightsClient(client));

  /// Creates [AlgoliaEventService] instance with a custom client.
  /// @nodoc - Internal use only, exposed for testing.
  @internal
  AlgoliaEventService.withClient(this._client)
      : _log = Logger('Algolia/EventsService');

  @override
  void send(List<Event> events) {
    final validEvents =
        events.map((e) => e.toAlgoliaEvent()).where((e) => e != null).toList();
    if (validEvents.isEmpty) {
      return;
    }
    _client
        .pushEvents(
          insightsEvents: InsightsEvents(events: validEvents),
        )
        .then(
          (_) => _log.fine('Events upload: $events'),
          onError: (exception) =>
              _log.severe('Events upload error: $exception'),
        );
  }
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
