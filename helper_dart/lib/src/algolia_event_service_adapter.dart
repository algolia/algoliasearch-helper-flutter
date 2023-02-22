import 'package:algolia/algolia.dart';
import 'event_service.dart';

class AlgoliaEventServiceAdapter implements EventService {
  Algolia algolia;

  AlgoliaEventServiceAdapter(
    String applicationID,
    String apiKey,
  ) : algolia = Algolia.init(applicationId: applicationID, apiKey: apiKey);

  @override
  void send(List<AlgoliaEvent> events) {
    algolia.pushEvents(events);
  }
}
