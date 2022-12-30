abstract class InsightsEvent {
  String get eventName;

  String get indexName;

  String get userToken;

  DateTime get timestamp;

  String? get queryID;
}

class ViewEvent implements InsightsEvent {
  ViewEvent({
    required this.eventName,
    required this.indexName,
    required this.userToken,
    required this.timestamp,
    required this.objectIDs,
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

  @override
  String? queryID;

  Iterable<String> objectIDs;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ViewEvent &&
          runtimeType == other.runtimeType &&
          eventName == other.eventName &&
          indexName == other.indexName &&
          userToken == other.userToken &&
          timestamp == other.timestamp &&
          queryID == other.queryID &&
          objectIDs == other.objectIDs;

  @override
  int get hashCode =>
      eventName.hashCode ^
      indexName.hashCode ^
      userToken.hashCode ^
      timestamp.hashCode ^
      queryID.hashCode ^
      objectIDs.hashCode;

  @override
  String toString() => 'ViewEvent{eventName: $eventName, indexName: $indexName,'
      ' userToken: $userToken, timestamp: $timestamp, queryID: $queryID, '
      'objectIDs: $objectIDs}';
}
