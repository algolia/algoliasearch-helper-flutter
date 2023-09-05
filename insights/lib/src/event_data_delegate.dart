/// Delegate providing dynamic external data for events
abstract class EventDataDelegate {
  /// Latest query ID value to associate events with search
  String? get queryID;

  /// Name of the index to associate events with.
  String get indexName;
}
