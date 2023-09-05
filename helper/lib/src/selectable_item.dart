/// Represents a value with selection status.
class SelectableItem<T> {
  /// Creates [SelectableItem] instance.
  const SelectableItem({required this.item, required this.isSelected});

  /// Item value.
  final T item;

  /// Selection status.
  final bool isSelected;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SelectableItem &&
          runtimeType == other.runtimeType &&
          item == other.item &&
          isSelected == other.isSelected;

  @override
  int get hashCode => item.hashCode ^ isSelected.hashCode;

  @override
  String toString() => 'SelectableItem{item: $item, isSelected: $isSelected}';
}
