import 'event_tracker.dart';

/// Wrapper for an EventTracker with associated indexName and attribute
class FilterEventTracker {
  /// Underlying EventTracker instance.
  EventTracker tracker;

  /// Name of the index to associate events with.
  String indexName;

  /// Filter attribute to associate events with.
  String attribute;

  /// Flag that blocks the sending of event packets when set to false
  bool isEnabled;

  FilterEventTracker(
    this.tracker,
    this.indexName,
    this.attribute, {
    this.isEnabled = true,
  });

  /// Send a click event to capture when users select filters.
  void clickedFilters({
    required String eventName,
    required List<String> values,
    DateTime? timestamp,
  }) {
    if (isEnabled) {
      tracker.clickedFilters(
        indexName: indexName,
        eventName: eventName,
        attribute: attribute,
        values: values,
        timestamp: timestamp,
      );
    }
  }

  /// Send a conversion event to capture the filters a user selected
  /// when converting.
  void convertedFilters({
    required String eventName,
    required List<String> values,
    DateTime? timestamp,
  }) {
    if (isEnabled) {
      tracker.convertedFilters(
        indexName: indexName,
        eventName: eventName,
        attribute: attribute,
        values: values,
        timestamp: timestamp,
      );
    }
  }

  /// Send a view event to capture the active filters for items a user viewed.
  void viewedFilters({
    required String eventName,
    required List<String> values,
    DateTime? timestamp,
  }) {
    if (isEnabled) {
      tracker.viewedFilters(
        indexName: indexName,
        eventName: eventName,
        attribute: attribute,
        values: values,
        timestamp: timestamp,
      );
    }
  }
}
