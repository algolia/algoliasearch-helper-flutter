abstract class FilterEventTracker {
  /// Flag that blocks the sending of event packets when set to false
  bool get isEnabled;

  /// Send filter click events
  void clickedFilters({
    required String eventName,
    required String attribute,
    required List<String> values,
  });

  /// Send filter conversion events
  void viewedFilters({
    required String eventName,
    required String attribute,
    required List<String> values,
  });

  /// Send filter conversion events
  void convertedFilters({
    required String eventName,
    required String attribute,
    required List<String> values,
  });
}
