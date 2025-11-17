import 'package:test/test.dart';
import 'package:algolia_client_insights/algolia_client_insights.dart';
import 'package:algolia_insights/src/algolia_event_service.dart';
import 'package:algolia_insights/src/event.dart';

class TestClient implements PushEvents {
  int pushEventsCallCount = 0;
  @override
  Future<void> pushEvents({required InsightsEvents insightsEvents}) async {
    pushEventsCallCount++;
  }
}

void main() {
  group('AlgoliaEventService', () {
    test('does not call pushEvents when validEvents is empty', () async {
      final testClient = TestClient();
      final service = AlgoliaEventService.withClient(testClient);
      final events = <Event>[];

      service.send(events);

      // No events, so pushEvents should not be called
      expect(testClient.pushEventsCallCount, equals(0));
    });

    test('calls pushEvents when all events are valid', () async {
      final testClient = TestClient();
      final service = AlgoliaEventService.withClient(testClient);
      final events = [
        Event.clickHits(
          'test_event',
          'test_index',
          'test_user_token',
          ['object1', 'object2'],
        ),
        Event.viewHits(
          'test_view_event',
          'test_index',
          'test_user_token',
          ['object3', 'object4'],
        ),
      ];

      service.send(events);

      // All events are valid, so pushEvents should be called once
      expect(testClient.pushEventsCallCount, equals(1));
    });

    test('calls pushEvents when some events are valid', () async {
      final testClient = TestClient();
      final service = AlgoliaEventService.withClient(testClient);
      final events = [
        Event.clickHits(
          'test_event',
          'test_index',
          'test_user_token',
          ['object1', 'object2'],
        ),
        // This event has no objectIDs or filterValues, so it will be invalid
        Event.clickHits(
          'invalid_event',
          'test_index',
          'test_user_token',
          [],
        ),
      ];

      service.send(events);

      // At least one event is valid, so pushEvents should be called once
      expect(testClient.pushEventsCallCount, equals(1));
    });

    test('does not call pushEvents when all events are invalid', () async {
      final testClient = TestClient();
      final service = AlgoliaEventService.withClient(testClient);
      final events = [
        // All these events have no objectIDs or filterValues, so they're invalid
        Event.clickHits(
          'invalid_event_1',
          'test_index',
          'test_user_token',
          [],
        ),
        Event.viewHits(
          'invalid_event_2',
          'test_index',
          'test_user_token',
          [],
        ),
        Event.convertHits(
          'invalid_event_3',
          'test_index',
          'test_user_token',
          [],
        ),
      ];

      service.send(events);

      // All events are invalid, so pushEvents should not be called
      expect(testClient.pushEventsCallCount, equals(0));
    });
  });
}
