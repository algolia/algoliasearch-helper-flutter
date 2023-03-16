import 'package:algolia/algolia.dart';
import 'event_service.dart';

/// EventService interface adapter for unofficial client instance
class AlgoliaEventServiceAdapter implements EventService {
  /// Client instance
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
