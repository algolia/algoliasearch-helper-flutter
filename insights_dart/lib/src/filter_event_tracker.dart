abstract class FilterEventTracker {
  /// Flag that blocks the sending of event packets when set to false
  bool get isEnabled;

  /// Send a click event to capture when users select filters.
  void clickedFilters({
    required String eventName,
    required List<String> values,
    DateTime? timestamp,
  });

  /// Send a view event to capture the active filters for items a user viewed.
  void viewedFilters({
    required String eventName,
    required List<String> values,
    DateTime? timestamp,
  });

  /// Send a conversion event to capture the filters a user selected
  /// when converting.
  void convertedFilters({
    required String eventName,
    required List<String> values,
    DateTime? timestamp,
  });
}
