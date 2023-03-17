enum EventType { click, conversion, view }

class Event {
  EventType type;

  String eventName;

  String indexName;

  String userToken;

  DateTime? timestamp;

  String? queryID;

  Iterable<String>? objectIDs;

  Iterable<int>? positions;

  String? attribute;

  Iterable<String>? filterValues;

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
          objectIDs == other.objectIDs &&
          positions == other.positions &&
          attribute == other.attribute &&
          filterValues == other.filterValues;

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
