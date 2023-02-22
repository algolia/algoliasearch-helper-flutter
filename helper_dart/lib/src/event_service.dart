import 'package:algolia/algolia.dart';

abstract class EventService {
  void send(List<AlgoliaEvent> events);
}
