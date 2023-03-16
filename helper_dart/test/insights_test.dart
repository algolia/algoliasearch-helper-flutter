import 'package:algolia/algolia.dart';
import 'package:algolia_helper/src/event_service.dart';
import 'package:algolia_helper/src/insights.dart';
import 'package:algolia_helper/src/user_token_storage.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import 'insights_test.mocks.dart';

@GenerateMocks([EventService])
void main() {
  test('fetch Insights instance from pool for the same app id', () {
    final insights1 = Insights('appID1', 'key1');
    final insights2 = Insights('appID2', 'key1');
    final insights3 = Insights('appID1', 'key1');
    expect(insights1, same(insights3));
    expect(insights1, isNot(insights2));
  });

  test(
    'check generated user token format',
    () {
      final eventService = MockEventService();
      final userTokenStorage = UserTokenStorage();

      when(eventService.send(any)).thenAnswer((realInvocation) {
        final event =
            (realInvocation.positionalArguments[0] as List<AlgoliaEvent>).first;
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
    },
  );

  test('send event with custom user token', () {
    final eventService = MockEventService();
    final userTokenStorage = UserTokenStorage();

    when(eventService.send(any)).thenAnswer((realInvocation) {
      final event =
          (realInvocation.positionalArguments[0] as List<AlgoliaEvent>).first;
      expect(event.eventName, 'test_event_name');
      expect(event.index, 'test_index');
      expect(event.filters, ['test_attribute:test_filter_value']);
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
  });

  test('opt-out/opt-in events sending', () {
    final eventService = MockEventService();
    final userTokenStorage = UserTokenStorage();
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
  });
}
