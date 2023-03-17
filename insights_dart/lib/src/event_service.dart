import 'event.dart';

abstract class EventService {
  void send(List<Event> events);
}
