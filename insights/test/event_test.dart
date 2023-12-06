import 'package:algolia_client_insights/algolia_client_insights.dart';
import 'package:algolia_insights/src/algolia_event_service.dart';
import 'package:algolia_insights/src/event.dart';
import 'package:test/test.dart';

void main() {
  group('Event', () {
    const eventName = 'test-event-name';
    const indexName = 'test-index-name';
    const userToken = 'test-user-token';
    final timestamp = DateTime.now();
    const queryID = 'test-query-id';
    const objectIDs = ['test-object-id-1', 'test-object-id-2'];
    const positions = [1, 2];
    const attribute = 'test-attribute';
    const filterValues = ['test-filter-value-1', 'test-filter-value-2'];

    test('should create a clickHitsAfterSearch event', () {
      final event = Event.clickHitsAfterSearch(
        eventName,
        indexName,
        userToken,
        queryID,
        objectIDs,
        positions,
        timestamp: timestamp,
      );
      expect(event.type, equals(EventType.click));
      expect(event.eventName, equals(eventName));
      expect(event.indexName, equals(indexName));
      expect(event.userToken, equals(userToken));
      expect(event.timestamp, equals(timestamp));
      expect(event.queryID, equals(queryID));
      expect(event.objectIDs, equals(objectIDs));
      expect(event.positions, equals(positions));
    });

    test('should create a clickHits event', () {
      final event = Event.clickHits(
        eventName,
        indexName,
        userToken,
        objectIDs,
        timestamp: timestamp,
      );
      expect(event.type, equals(EventType.click));
      expect(event.eventName, equals(eventName));
      expect(event.indexName, equals(indexName));
      expect(event.userToken, equals(userToken));
      expect(event.timestamp, equals(timestamp));
      expect(event.objectIDs, equals(objectIDs));
    });

    test('should create a convertHitsAfterSearch event', () {
      final event = Event.convertHitsAfterSearch(
        eventName,
        indexName,
        userToken,
        queryID,
        objectIDs,
        timestamp: timestamp,
      );
      expect(event.type, equals(EventType.conversion));
      expect(event.eventName, equals(eventName));
      expect(event.indexName, equals(indexName));
      expect(event.userToken, equals(userToken));
      expect(event.timestamp, equals(timestamp));
      expect(event.queryID, equals(queryID));
      expect(event.objectIDs, equals(objectIDs));
    });

    test('should create a convertHits event', () {
      final event = Event.convertHits(
        eventName,
        indexName,
        userToken,
        objectIDs,
        timestamp: timestamp,
      );
      expect(event.type, equals(EventType.conversion));
      expect(event.eventName, equals(eventName));
      expect(event.indexName, equals(indexName));
      expect(event.userToken, equals(userToken));
      expect(event.timestamp, equals(timestamp));
      expect(event.objectIDs, equals(objectIDs));
    });

    test('should create a viewHits event', () {
      final event = Event.viewHits(
        eventName,
        indexName,
        userToken,
        objectIDs,
        timestamp: timestamp,
      );
      expect(event.type, equals(EventType.view));
      expect(event.eventName, equals(eventName));
      expect(event.indexName, equals(indexName));
      expect(event.userToken, equals(userToken));
      expect(event.timestamp, equals(timestamp));
      expect(event.objectIDs, equals(objectIDs));
    });

    test('should create a clickFilters event', () {
      final event = Event.clickFilters(
        eventName,
        indexName,
        userToken,
        attribute,
        filterValues,
        timestamp: timestamp,
      );
      expect(event.type, equals(EventType.click));
      expect(event.eventName, equals(eventName));
      expect(event.indexName, equals(indexName));
      expect(event.userToken, equals(userToken));
      expect(event.timestamp, equals(timestamp));
      expect(event.attribute, equals(attribute));
      expect(event.filterValues, equals(filterValues));
    });

    test('should create a viewFilters event', () {
      final event = Event.viewFilters(
        eventName,
        indexName,
        userToken,
        attribute,
        filterValues,
        timestamp: timestamp,
      );
      expect(event.type, equals(EventType.view));
      expect(event.eventName, equals(eventName));
      expect(event.indexName, equals(indexName));
      expect(event.userToken, equals(userToken));
      expect(event.timestamp, equals(timestamp));
      expect(event.attribute, equals(attribute));
      expect(event.filterValues, equals(filterValues));
    });

    test('should create a convertFilters event', () {
      final event = Event.convertFilters(
        eventName,
        indexName,
        userToken,
        attribute,
        filterValues,
        timestamp: timestamp,
      );
      expect(event.type, equals(EventType.conversion));
      expect(event.eventName, equals(eventName));
      expect(event.indexName, equals(indexName));
      expect(event.userToken, equals(userToken));
      expect(event.timestamp, equals(timestamp));
      expect(event.attribute, equals(attribute));
      expect(event.filterValues, equals(filterValues));
    });

    group('Algolia events conversion', () {
      test('should convert a clickHitsAfterSearch event', () {
        final event = Event.clickHitsAfterSearch(
          eventName,
          indexName,
          userToken,
          queryID,
          objectIDs,
          positions,
          timestamp: timestamp,
        ).toAlgoliaEvent() as ClickedObjectIDsAfterSearch;
        expect(event.eventType, equals(ClickEvent.click));
        expect(event.eventName, equals(eventName));
        expect(event.index, equals(indexName));
        expect(event.userToken, equals(userToken));
        expect(event.timestamp, equals(timestamp.millisecondsSinceEpoch));
        expect(event.queryID, equals(queryID));
        expect(event.objectIDs, equals(objectIDs));
        expect(event.positions, equals(positions));
      });

      test('should convert a clickHits event', () {
        final event = Event.clickHits(
          eventName,
          indexName,
          userToken,
          objectIDs,
          timestamp: timestamp,
        ).toAlgoliaEvent() as ClickedObjectIDs;
        expect(event.eventType, equals(ClickEvent.click));
        expect(event.eventName, equals(eventName));
        expect(event.index, equals(indexName));
        expect(event.userToken, equals(userToken));
        expect(event.timestamp, equals(timestamp.millisecondsSinceEpoch));
        expect(event.objectIDs, equals(objectIDs));
      });

      test('should convert a convertHitsAfterSearch event', () {
        final event = Event.convertHitsAfterSearch(
          eventName,
          indexName,
          userToken,
          queryID,
          objectIDs,
          timestamp: timestamp,
        ).toAlgoliaEvent() as ConvertedObjectIDsAfterSearch;
        expect(event.eventType, equals(ConversionEvent.conversion));
        expect(event.eventName, equals(eventName));
        expect(event.index, equals(indexName));
        expect(event.userToken, equals(userToken));
        expect(event.timestamp, equals(timestamp.millisecondsSinceEpoch));
        expect(event.queryID, equals(queryID));
        expect(event.objectIDs, equals(objectIDs));
      });

      test('should convert a convertHits event', () {
        final event = Event.convertHits(
          eventName,
          indexName,
          userToken,
          objectIDs,
          timestamp: timestamp,
        ).toAlgoliaEvent() as ConvertedObjectIDs;
        expect(event.eventType, equals(ConversionEvent.conversion));
        expect(event.eventName, equals(eventName));
        expect(event.index, equals(indexName));
        expect(event.userToken, equals(userToken));
        expect(event.timestamp, equals(timestamp.millisecondsSinceEpoch));
        expect(event.objectIDs, equals(objectIDs));
      });

      test('should convert a viewHits event', () {
        final event = Event.viewHits(
          eventName,
          indexName,
          userToken,
          objectIDs,
          timestamp: timestamp,
        ).toAlgoliaEvent() as ViewedObjectIDs;
        expect(event.eventType, equals(ViewEvent.view));
        expect(event.eventName, equals(eventName));
        expect(event.index, equals(indexName));
        expect(event.userToken, equals(userToken));
        expect(event.timestamp, equals(timestamp.millisecondsSinceEpoch));
        expect(event.objectIDs, equals(objectIDs));
      });

      test('should convert a clickFilters event', () {
        final event = Event.clickFilters(
          eventName,
          indexName,
          userToken,
          attribute,
          filterValues,
          timestamp: timestamp,
        ).toAlgoliaEvent() as ClickedFilters;
        expect(event.eventType, equals(ClickEvent.click));
        expect(event.eventName, equals(eventName));
        expect(event.index, equals(indexName));
        expect(event.userToken, equals(userToken));
        expect(event.timestamp, equals(timestamp.millisecondsSinceEpoch));
        expect(
          event.filters,
          equals(filterValues.map((v) => Uri.encodeComponent('$attribute:$v'))),
        );
      });

      test('should convert a viewFilters event', () {
        final event = Event.viewFilters(
          eventName,
          indexName,
          userToken,
          attribute,
          filterValues,
          timestamp: timestamp,
        ).toAlgoliaEvent() as ViewedFilters;
        expect(event.eventType, equals(ViewEvent.view));
        expect(event.eventName, equals(eventName));
        expect(event.index, equals(indexName));
        expect(event.userToken, equals(userToken));
        expect(event.timestamp, equals(timestamp.millisecondsSinceEpoch));
        expect(
          event.filters,
          equals(filterValues.map((v) => Uri.encodeComponent('$attribute:$v'))),
        );
      });

      test('should convert a convertFilters event', () {
        final event = Event.convertFilters(
          eventName,
          indexName,
          userToken,
          attribute,
          filterValues,
          timestamp: timestamp,
        ).toAlgoliaEvent() as ConvertedFilters;
        expect(event.eventType, equals(ConversionEvent.conversion));
        expect(event.eventName, equals(eventName));
        expect(event.index, equals(indexName));
        expect(event.userToken, equals(userToken));
        expect(event.timestamp, equals(timestamp.millisecondsSinceEpoch));
        expect(
          event.filters,
          equals(filterValues.map((v) => Uri.encodeComponent('$attribute:$v'))),
        );
      });
    });
  });
}
