import 'event.dart';

/// Interface for the service that sends events
abstract class EventService {
  /// Send a list of events
  void send(List<Event> events);
}
