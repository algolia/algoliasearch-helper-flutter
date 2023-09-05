import 'package:algolia_insights/algolia_insights.dart';
import 'package:algolia_insights/src/event_service.dart';
import 'package:algolia_insights/src/user_token_storage.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import 'insights_test.mocks.dart';

@GenerateMocks([EventService])
void main() {
  test(
    'check generated user token format',
    () {
      final eventService = MockEventService();
      final userTokenStorage = UserTokenStorage.custom('algolia', 'user-token');

      when(eventService.send(any)).thenAnswer((realInvocation) {
        final event =
            (realInvocation.positionalArguments[0] as List<Event>).first;
        expect(event.userToken.startsWith('anonymous-'), true);
      });

      Insights.custom(
        eventService,
        userTokenStorage,
      )
        ..userTokenLeaseTime = 0
        ..clickedFilters(
          indexName: 'test_index',
          eventName: 'test_event_name',
          attribute: 'test_attribute',
          values: ['test_filter_value'],
        );
      userTokenStorage.remove();
    },
  );

  test('send event with custom user token', () {
    final eventService = MockEventService();
    final userTokenStorage = UserTokenStorage.custom('algolia', 'user-token');

    when(eventService.send(any)).thenAnswer((realInvocation) {
      final event =
          (realInvocation.positionalArguments[0] as List<Event>).first;
      expect(event.eventName, 'test_event_name');
      expect(event.indexName, 'test_index');
      expect(event.attribute, 'test_attribute');
      expect(event.filterValues, ['test_filter_value']);
      expect(event.userToken, 'test_user_token');
    });

    Insights.custom(
      eventService,
      userTokenStorage,
    )
      ..userToken = 'test_user_token'
      ..clickedFilters(
        indexName: 'test_index',
        eventName: 'test_event_name',
        attribute: 'test_attribute',
        values: ['test_filter_value'],
      );
    userTokenStorage.remove();
  });

  test('opt-out/opt-in events sending', () {
    final eventService = MockEventService();
    final userTokenStorage = UserTokenStorage.custom('algolia', 'user-token');
    final insights = Insights.custom(
      eventService,
      userTokenStorage,
    )
      ..isEnabled = false
      ..clickedFilters(
        indexName: 'test_index',
        eventName: 'test_event_name',
        attribute: 'test_attribute',
        values: ['test_filter_value'],
      );
    verifyNever(eventService.send(any));
    insights
      ..isEnabled = true
      ..clickedFilters(
        indexName: 'test_index',
        eventName: 'test_event_name',
        attribute: 'test_attribute',
        values: ['test_filter_value'],
      );
    verify(eventService.send(any)).called(1);
    userTokenStorage.remove();
  });

  group('Events tests', () {
    late Insights insights;
    late MockEventService mockEventService;
    final userTokenStorage = UserTokenStorage.custom('algolia', 'user-token');

    setUp(() {
      mockEventService = MockEventService();
      insights = Insights.custom(
        mockEventService,
        UserTokenStorage.custom('algolia', 'user-token'),
      );
    });

    tearDown(
      () => {userTokenStorage.remove()},
    );

    test('clickedFilters event is sent', () {
      Event? capturedEvent;

      when(mockEventService.send(any)).thenAnswer((realInvocation) {
        capturedEvent =
            (realInvocation.positionalArguments[0] as List<Event>).first;
      });

      insights.clickedFilters(
        indexName: 'test_index',
        eventName: 'test_event',
        attribute: 'test_attribute',
        values: ['value1', 'value2'],
      );

      final expectedEvent = Event.clickFilters(
        'test_event',
        'test_index',
        insights.userToken,
        'test_attribute',
        ['value1', 'value2'],
      );

      expect(capturedEvent, EventMatcher(expectedEvent));
    });

    test('convertedFilters event is sent', () {
      Event? capturedEvent;

      when(mockEventService.send(any)).thenAnswer((realInvocation) {
        capturedEvent =
            (realInvocation.positionalArguments[0] as List<Event>).first;
      });

      insights.convertedFilters(
        indexName: 'test_index',
        eventName: 'test_event',
        attribute: 'test_attribute',
        values: ['value1', 'value2'],
      );

      final expectedEvent = Event.convertFilters(
        'test_event',
        'test_index',
        insights.userToken,
        'test_attribute',
        ['value1', 'value2'],
      );

      expect(capturedEvent, expectedEvent);
    });

    test('viewedFilters event is sent', () {
      Event? capturedEvent;

      when(mockEventService.send(any)).thenAnswer((realInvocation) {
        capturedEvent =
            (realInvocation.positionalArguments[0] as List<Event>).first;
      });

      insights.viewedFilters(
        indexName: 'test_index',
        eventName: 'test_event',
        attribute: 'test_attribute',
        values: ['value1', 'value2'],
      );

      final expectedEvent = Event.viewFilters(
        'test_event',
        'test_index',
        insights.userToken,
        'test_attribute',
        ['value1', 'value2'],
      );

      expect(capturedEvent, expectedEvent);
    });

    test('clickedObjects event is sent', () {
      Event? capturedEvent;

      when(mockEventService.send(any)).thenAnswer((realInvocation) {
        capturedEvent =
            (realInvocation.positionalArguments[0] as List<Event>).first;
      });

      insights.clickedObjects(
        indexName: 'test_index',
        eventName: 'test_event',
        objectIDs: ['object1', 'object2'],
      );

      final expectedEvent = Event.clickHits(
        'test_event',
        'test_index',
        insights.userToken,
        ['object1', 'object2'],
      );

      expect(capturedEvent, expectedEvent);
    });

    test('clickedObjectsAfterSearch event is sent', () {
      Event? capturedEvent;

      when(mockEventService.send(any)).thenAnswer((realInvocation) {
        capturedEvent =
            (realInvocation.positionalArguments[0] as List<Event>).first;
      });

      insights.clickedObjectsAfterSearch(
        indexName: 'test_index',
        eventName: 'test_event',
        objectIDs: ['object1', 'object2'],
        queryID: 'test_query_id',
        positions: [1, 2],
      );

      final expectedEvent = Event.clickHitsAfterSearch(
        'test_event',
        'test_index',
        insights.userToken,
        'test_query_id',
        ['object1', 'object2'],
        [1, 2],
      );

      expect(capturedEvent, expectedEvent);
    });

    test('viewedObjects event is sent', () {
      Event? capturedEvent;

      when(mockEventService.send(any)).thenAnswer((realInvocation) {
        capturedEvent =
            (realInvocation.positionalArguments[0] as List<Event>).first;
      });

      insights.viewedObjects(
        indexName: 'test_index',
        eventName: 'test_event',
        objectIDs: ['object1', 'object2'],
      );

      final expectedEvent = Event.viewHits(
        'test_event',
        'test_index',
        insights.userToken,
        ['object1', 'object2'],
      );

      expect(capturedEvent, expectedEvent);
    });

    test('convertedObjects event is sent', () {
      Event? capturedEvent;

      when(mockEventService.send(any)).thenAnswer((realInvocation) {
        capturedEvent =
            (realInvocation.positionalArguments[0] as List<Event>).first;
      });

      insights.convertedObjects(
        indexName: 'test_index',
        eventName: 'test_event',
        objectIDs: ['object1', 'object2'],
      );

      final expectedEvent = Event.convertHits(
        'test_event',
        'test_index',
        insights.userToken,
        ['object1', 'object2'],
      );

      expect(capturedEvent, expectedEvent);
    });

    test('convertedObjectsAfterSearch event is sent', () {
      Event? capturedEvent;

      when(mockEventService.send(any)).thenAnswer((realInvocation) {
        capturedEvent =
            (realInvocation.positionalArguments[0] as List<Event>).first;
      });

      insights.convertedObjectsAfterSearch(
        indexName: 'test_index',
        eventName: 'test_event',
        queryID: 'test_query_id',
        objectIDs: ['object1', 'object2'],
      );

      final expectedEvent = Event.convertHitsAfterSearch(
        'test_event',
        'test_index',
        insights.userToken,
        'test_query_id',
        ['object1', 'object2'],
      );

      expect(capturedEvent, expectedEvent);
    });
  });
}

class EventMatcher extends Matcher {
  final Event _expectedEvent;

  EventMatcher(this._expectedEvent);

  @override
  bool matches(dynamic item, Map matchState) {
    if (item is Event) {
      return _expectedEvent == item;
    }
    return false;
  }

  @override
  Description describe(Description description) =>
      description.add('Event does not match expected');
}
