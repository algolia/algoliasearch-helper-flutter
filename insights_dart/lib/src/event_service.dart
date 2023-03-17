import 'package:algolia/algolia.dart';

import 'event.dart';

abstract class EventService {
  void send(List<Event> events);
}
