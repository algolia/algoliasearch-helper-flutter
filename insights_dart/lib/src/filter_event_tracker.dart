import 'event_tracker.dart';
import 'event_data_delegate.dart';

/// Wrapper for an EventTracker with associated indexName and attribute
class FilterEventTracker {
  /// Underlying EventTracker instance.
  EventTracker tracker;

  /// Delegate providing dynamic external events data
  EventDataDelegate delegate;

  /// Filter attribute to associate events with.
  String attribute;

  /// Flag that blocks the sending of event packets when set to false
  bool isEnabled;

  FilterEventTracker(
    this.tracker,
    this.delegate,
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
        indexName: delegate.indexName,
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
        indexName: delegate.indexName,
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
        indexName: delegate.indexName,
        eventName: eventName,
        attribute: attribute,
        values: values,
        timestamp: timestamp,
      );
    }
  }
}
