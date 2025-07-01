import 'package:algolia_client_insights/algolia_client_insights.dart';

import 'event.dart';

/// Interface for the service that sends events
abstract class EventService {
  InsightsClient get client;

  /// Send a list of events
  void send(List<Event> events);
}
