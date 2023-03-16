import 'event_tracker.dart';
import 'filter_event_tracker.dart';

/// Wrapper for an EventTracker with associated indexName
class FilterEventTrackerAdapter implements FilterEventTracker {
  /// Underlying EventTracker instance.
  EventTracker tracker;

  /// Name of the index to associate events with.
  String indexName;

  @override
  bool isEnabled;

  FilterEventTrackerAdapter(
    this.tracker,
    this.indexName, {
    this.isEnabled = true,
  });

  @override
  void clickedFilters({
    required String eventName,
    required String attribute,
    required List<String> values,
  }) {
    if (isEnabled) {
      tracker.clickedFilters(
        indexName: indexName,
        eventName: eventName,
        attribute: attribute,
        values: values,
      );
    }
  }

  @override
  void convertedFilters({
    required String eventName,
    required String attribute,
    required List<String> values,
  }) {
    if (isEnabled) {
      tracker.convertedFilters(
        indexName: indexName,
        eventName: eventName,
        attribute: attribute,
        values: values,
      );
    }
  }

  @override
  void viewedFilters({
    required String eventName,
    required String attribute,
    required List<String> values,
  }) {
    if (isEnabled) {
      tracker.viewedFilters(
        indexName: indexName,
        eventName: eventName,
        attribute: attribute,
        values: values,
      );
    }
  }
}
