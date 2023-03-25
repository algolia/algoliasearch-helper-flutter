import 'event_tracker.dart';
import 'filter_event_tracker.dart';

/// Wrapper for an EventTracker with associated indexName and attribute
/// implementing FilterEventTracker
class FilterEventTrackerAdapter implements FilterEventTracker {
  /// Underlying EventTracker instance.
  EventTracker tracker;

  /// Name of the index to associate events with.
  String indexName;

  /// Filter attribute to associate events with.
  String attribute;

  @override
  bool isEnabled;

  FilterEventTrackerAdapter(
    this.tracker,
    this.indexName,
    this.attribute, {
    this.isEnabled = true,
  });

  @override
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

  @override
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

  @override
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
