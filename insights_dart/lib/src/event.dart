import 'package:collection/collection.dart';

enum EventType { click, conversion, view }

/// The `Event` class represents an Algolia Insights event, which is used
/// for collecting user interaction data in order to provide analytics and
/// improve search relevance.
class Event {
  /// The type of the event (click, conversion, or view).
  EventType type;

  /// The name of the event.
  String eventName;

  /// The name of the Algolia index associated with the event.
  String indexName;

  /// The unique identifier for the user who triggered the event.
  String userToken;

  /// The timestamp when the event occurred (optional).
  DateTime? timestamp;

  /// The query ID associated with the event (optional).
  String? queryID;

  /// The list of object IDs associated with the event (optional).
  Iterable<String>? objectIDs;

  /// The positions of clicked or converted items (optional).
  Iterable<int>? positions;

  /// The attribute associated with filter-based events (optional).
  String? attribute;

  /// The list of filter values associated with filter-based events (optional).
  Iterable<String>? filterValues;

  /// A private constructor to create an Event object with the provided
  /// parameters.
  Event._(
    this.type,
    this.eventName,
    this.indexName,
    this.userToken, {
    this.timestamp,
    this.queryID,
    this.objectIDs,
    this.positions,
    this.attribute,
    this.filterValues,
  });

  /// Creates a click event after a search with object IDs and positions.
  Event.clickHitsAfterSearch(
    String eventName,
    String indexName,
    String userToken,
    String queryID,
    Iterable<String> objectIDs,
    Iterable<int> positions, {
    DateTime? timestamp,
  }) : this._(
          EventType.click,
          eventName,
          indexName,
          userToken,
          timestamp: timestamp,
          queryID: queryID,
          positions: positions,
          objectIDs: objectIDs,
        );

  /// Creates a click event with object IDs.
  Event.clickHits(
    String eventName,
    String indexName,
    String userToken,
    Iterable<String> objectIDs, {
    DateTime? timestamp,
  }) : this._(
          EventType.click,
          eventName,
          indexName,
          userToken,
          objectIDs: objectIDs,
          timestamp: timestamp,
        );

  /// Creates a conversion event after a search with object IDs.
  Event.convertHitsAfterSearch(
    String eventName,
    String indexName,
    String userToken,
    String queryID,
    Iterable<String> objectIDs, {
    DateTime? timestamp,
  }) : this._(
          EventType.conversion,
          eventName,
          indexName,
          userToken,
          queryID: queryID,
          objectIDs: objectIDs,
          timestamp: timestamp,
        );

  /// Creates a conversion event with object IDs.
  Event.convertHits(
    String eventName,
    String indexName,
    String userToken,
    Iterable<String> objectIDs, {
    DateTime? timestamp,
  }) : this._(
          EventType.conversion,
          eventName,
          indexName,
          userToken,
          objectIDs: objectIDs,
          timestamp: timestamp,
        );

  /// Creates a view event with object IDs.
  Event.viewHits(
    String eventName,
    String indexName,
    String userToken,
    Iterable<String> objectIDs, {
    DateTime? timestamp,
  }) : this._(
          EventType.view,
          eventName,
          indexName,
          userToken,
          objectIDs: objectIDs,
          timestamp: timestamp,
        );

  /// Creates a click event with filter attribute and values.
  Event.clickFilters(
    String eventName,
    String indexName,
    String userToken,
    String attribute,
    Iterable<String> values, {
    DateTime? timestamp,
  }) : this._(
          EventType.click,
          eventName,
          indexName,
          userToken,
          attribute: attribute,
          filterValues: values,
          timestamp: timestamp,
        );

  /// Creates a view event with filter attribute and values.
  Event.viewFilters(
    String eventName,
    String indexName,
    String userToken,
    String attribute,
    Iterable<String> values, {
    DateTime? timestamp,
  }) : this._(
          EventType.view,
          eventName,
          indexName,
          userToken,
          attribute: attribute,
          filterValues: values,
          timestamp: timestamp,
        );

  /// Creates a conversion event with filter attribute and values.
  Event.convertFilters(
    String eventName,
    String indexName,
    String userToken,
    String attribute,
    Iterable<String> values, {
    DateTime? timestamp,
  }) : this._(
          EventType.conversion,
          eventName,
          indexName,
          userToken,
          attribute: attribute,
          filterValues: values,
          timestamp: timestamp,
        );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Event &&
          runtimeType == other.runtimeType &&
          eventName == other.eventName &&
          indexName == other.indexName &&
          userToken == other.userToken &&
          timestamp == other.timestamp &&
          queryID == other.queryID &&
          const IterableEquality().equals(objectIDs, other.objectIDs) &&
          const IterableEquality().equals(positions, other.positions) &&
          attribute == other.attribute &&
          const IterableEquality().equals(filterValues, other.filterValues);

  // filterValues == other.filterValues;

  @override
  int get hashCode =>
      type.hashCode ^
      eventName.hashCode ^
      indexName.hashCode ^
      userToken.hashCode ^
      timestamp.hashCode ^
      queryID.hashCode ^
      objectIDs.hashCode ^
      positions.hashCode ^
      attribute.hashCode ^
      filterValues.hashCode;

  @override
  String toString() =>
      'Event{type: $type, eventName: $eventName, indexName: $indexName, '
      'userToken: $userToken, timestamp: $timestamp, queryID: $queryID, '
      'objectIDs: $objectIDs, positions: $positions, attribute: $attribute, '
      'filterValues: $filterValues}';
}
