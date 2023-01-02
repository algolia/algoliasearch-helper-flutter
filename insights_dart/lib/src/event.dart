abstract class InsightsEvent {
  String get eventName;

  String get indexName;

  String get userToken;

  DateTime get timestamp;
}

class HitViewEvent implements InsightsEvent {
  HitViewEvent({
    required this.eventName,
    required this.indexName,
    required this.userToken,
    required this.timestamp,
    required this.objectIDs,
  });

  @override
  String eventName;

  @override
  String indexName;

  @override
  String userToken;

  @override
  DateTime timestamp;

  Iterable<String> objectIDs;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HitViewEvent &&
          runtimeType == other.runtimeType &&
          eventName == other.eventName &&
          indexName == other.indexName &&
          userToken == other.userToken &&
          timestamp == other.timestamp &&
          objectIDs == other.objectIDs;

  @override
  int get hashCode =>
      eventName.hashCode ^
      indexName.hashCode ^
      userToken.hashCode ^
      timestamp.hashCode ^
      objectIDs.hashCode;

  @override
  String toString() => 'ViewEvent{eventName: $eventName, indexName: $indexName,'
      ' userToken: $userToken, timestamp: $timestamp, objectIDs: $objectIDs}';
}

class HitClickEvent implements InsightsEvent {
  HitClickEvent({
    required this.eventName,
    required this.indexName,
    required this.userToken,
    required this.timestamp,
    this.objectIDs,
    this.positions,
    this.queryID,
  });

  @override
  String eventName;

  @override
  String indexName;

  @override
  String userToken;

  @override
  DateTime timestamp;

  String? queryID;

  Iterable<String>? objectIDs;

  Iterable<int>? positions;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HitClickEvent &&
          runtimeType == other.runtimeType &&
          eventName == other.eventName &&
          indexName == other.indexName &&
          userToken == other.userToken &&
          timestamp == other.timestamp &&
          queryID == other.queryID &&
          objectIDs == other.objectIDs &&
          positions == other.positions;

  @override
  int get hashCode =>
      eventName.hashCode ^
      indexName.hashCode ^
      userToken.hashCode ^
      timestamp.hashCode ^
      queryID.hashCode ^
      objectIDs.hashCode ^
      positions.hashCode;

  @override
  String toString() =>
      'HitClickEvent{eventName: $eventName, indexName: $indexName, '
      'userToken: $userToken, timestamp: $timestamp, queryID: $queryID, '
      'objectIDs: $objectIDs, positions: $positions}';
}
