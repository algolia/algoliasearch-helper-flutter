import 'package:rxdart/rxdart.dart';

import 'filter.dart';
import 'filter_group.dart';
import 'utils.dart';

class FilterState {
  Stream<Filters> get filters => _filters.stream.distinct();

  final BehaviorSubject<ImmutableFilters> _filters =
      BehaviorSubject.seeded(ImmutableFilters._());

  void add(FilterGroupID groupID, Iterable<Filter> filters) {
    _apply((it) => it.add(groupID, filters));
  }

  void set(Map<FilterGroupID, Set<Filter>> map) {
    _apply((it) => it.set(map));
  }

  void remove(FilterGroupID groupID, Iterable<Filter> filters) {
    _apply((it) => it.remove(groupID, filters));
  }

  void toggle(FilterGroupID groupID, Filter filter) {
    return contains(groupID, filter)
        ? remove(groupID, [filter])
        : add(groupID, [filter]);
  }

  bool contains(FilterGroupID groupID, Filter filter) {
    return _filters.value.contains(groupID, filter);
  }

  void addHierarchical(
      String attribute, HierarchicalFilter hierarchicalFilter) {
    _apply((it) => it.addHierarchical(attribute, hierarchicalFilter));
  }

  void removeHierarchical(String attribute) {
    _apply((it) => it.removeHierarchical(attribute));
  }

  void clear(Iterable<FilterGroupID> groupIDs) {
    _apply((it) => it.clear(groupIDs));
  }

  void clearExcept(Iterable<FilterGroupID> groupIDs) {
    _apply((it) => it.clearExcept(groupIDs));
  }

  void _apply(ImmutableFilters Function(ImmutableFilters filters) action) {
    final current = _filters.value;
    final updated = action(current);
    _filters.sink.add(updated);
  }
}

class ImmutableFilters extends Filters {
  ImmutableFilters._(
      {Map<FilterGroupID, Set<FilterFacet>> facetGroups = const {},
      Map<FilterGroupID, Set<FilterTag>> tagGroups = const {},
      Map<FilterGroupID, Set<FilterNumeric>> numericGroups = const {},
      Map<String, HierarchicalFilter> hierarchicalGroups = const {}})
      : super._(facetGroups, tagGroups, numericGroups, hierarchicalGroups);

  ImmutableFilters add(FilterGroupID groupID, Iterable<Filter> filters) {
    for (final filter in filters) {
      switch (filter.runtimeType) {
        case FilterFacet:
          return copyWith(
              facetGroups: facetGroups.add(groupID, filter as FilterFacet));
        case FilterTag:
          return copyWith(
              tagGroups: tagGroups.add(groupID, filter as FilterTag));
        case FilterNumeric:
          return copyWith(
              numericGroups:
                  numericGroups.add(groupID, filter as FilterNumeric));
      }
    }
    return this;
  }

  ImmutableFilters set(Map<FilterGroupID, Set<Filter>> map) {
    var filters = ImmutableFilters._();
    for (final entry in map.entries) {
      filters = filters.add(entry.key, entry.value);
    }
    return filters;
  }

  ImmutableFilters toggle(FilterGroupID groupID, Filter filter) {
    return contains(groupID, filter)
        ? remove(groupID, [filter])
        : add(groupID, [filter]);
  }

  ImmutableFilters remove(FilterGroupID groupID, Iterable<Filter> filters) {
    for (final filter in filters) {
      switch (filter.runtimeType) {
        case FilterFacet:
          return copyWith(
              facetGroups: facetGroups.delete(groupID, filter as FilterFacet));
        case FilterTag:
          return copyWith(
              tagGroups: tagGroups.delete(groupID, filter as FilterTag));
        case FilterNumeric:
          return copyWith(
              numericGroups:
                  numericGroups.delete(groupID, filter as FilterNumeric));
      }
    }
    return this;
  }

  ImmutableFilters addHierarchical(
      String attribute, HierarchicalFilter hierarchicalFilter) {
    if (hierarchicalGroups.containsKey(attribute)) return this;
    final groups = Map<String, HierarchicalFilter>.from(hierarchicalGroups)
      ..[attribute] = hierarchicalFilter;
    return copyWith(hierarchicalGroups: Map.unmodifiable(groups));
  }

  ImmutableFilters removeHierarchical(String attribute) {
    if (!hierarchicalGroups.containsKey(attribute)) return this;
    final groups = Map<String, HierarchicalFilter>.from(hierarchicalGroups)
      ..remove(attribute);
    return copyWith(hierarchicalGroups: Map.unmodifiable(groups));
  }

  ImmutableFilters clear([Iterable<FilterGroupID>? groupIDs]) {
    if (groupIDs == null || groupIDs.isEmpty) return ImmutableFilters._();
    return ImmutableFilters._(
        facetGroups: facetGroups.deleteGroups(groupIDs),
        numericGroups: numericGroups.deleteGroups(groupIDs),
        tagGroups: tagGroups.deleteGroups(groupIDs));
  }

  ImmutableFilters clearExcept(Iterable<FilterGroupID> groupIDs) {
    if (groupIDs.isEmpty) return ImmutableFilters._();
    return ImmutableFilters._(
        facetGroups: facetGroups.deleteGroupsExcept(groupIDs),
        numericGroups: numericGroups.deleteGroupsExcept(groupIDs),
        tagGroups: tagGroups.deleteGroupsExcept(groupIDs));
  }

  @override
  ImmutableFilters copyWith(
      {Map<FilterGroupID, Set<FilterFacet>>? facetGroups,
      Map<FilterGroupID, Set<FilterTag>>? tagGroups,
      Map<FilterGroupID, Set<FilterNumeric>>? numericGroups,
      Map<String, HierarchicalFilter>? hierarchicalGroups}) {
    return ImmutableFilters._(
        facetGroups: facetGroups ?? this.facetGroups,
        tagGroups: tagGroups ?? this.tagGroups,
        numericGroups: numericGroups ?? this.numericGroups,
        hierarchicalGroups: hierarchicalGroups ?? this.hierarchicalGroups);
  }
}

/// Map of filter groups convenience type.
typedef FilterGroupMap<T> = Map<FilterGroupID, Set<T>>;

/// Filter groups: facet, tag, numeric and hierarchical.
class Filters {
  Filters._(this.facetGroups, this.tagGroups, this.numericGroups,
      this.hierarchicalGroups);

  final FilterGroupMap<FilterFacet> facetGroups;
  final FilterGroupMap<FilterTag> tagGroups;
  final FilterGroupMap<FilterNumeric> numericGroups;
  final Map<String, HierarchicalFilter> hierarchicalGroups;

  Set<FilterFacet>? getFacetFilters(FilterGroupID groupID) {
    return facetGroups[groupID];
  }

  Set<FilterTag>? getTagFilters(FilterGroupID groupID) {
    return tagGroups[groupID];
  }

  Set<FilterNumeric>? getNumericFilters(FilterGroupID groupID) {
    return numericGroups[groupID];
  }

  HierarchicalFilter? getHierarchicalFilters(String attribute) {
    return hierarchicalGroups[attribute];
  }

  Map<FilterGroupID, Set<Filter>> getGroups() {
    return {...facetGroups, ...tagGroups, ...numericGroups};
  }

  Set<Filter> getFilters({FilterGroupID? groupID}) {
    return groupID == null ? _getAllFilters() : _getFiltersByGroupID(groupID);
  }

  Set<Filter> _getAllFilters() {
    final facetFilters = facetGroups.values.expand((element) => element);
    final tagFilters = tagGroups.values.expand((element) => element);
    final numericFilters = numericGroups.values.expand((element) => element);
    return {...facetFilters, ...tagFilters, ...numericFilters};
  }

  Set<Filter> _getFiltersByGroupID(FilterGroupID groupID) {
    final facetFilters = getFacetFilters(groupID);
    final tagFilters = getTagFilters(groupID);
    final numericFilters = getTagFilters(groupID);
    return {...?facetFilters, ...?tagFilters, ...?numericFilters};
  }

  bool contains(FilterGroupID groupID, Filter filter) {
    switch (filter.runtimeType) {
      case FilterFacet:
        return facetGroups[groupID]?.contains(filter) ?? false;
      case FilterTag:
        return tagGroups[groupID]?.contains(filter) ?? false;
      case FilterNumeric:
        return numericGroups[groupID]?.contains(filter) ?? false;
      default:
        return false;
    }
  }

  Filters copyWith(
      {Map<FilterGroupID, Set<FilterFacet>>? facetGroups,
      Map<FilterGroupID, Set<FilterTag>>? tagGroups,
      Map<FilterGroupID, Set<FilterNumeric>>? numericGroups,
      Map<String, HierarchicalFilter>? hierarchicalGroups}) {
    return Filters._(
        facetGroups ?? this.facetGroups,
        tagGroups ?? this.tagGroups,
        numericGroups ?? this.numericGroups,
        hierarchicalGroups ?? this.hierarchicalGroups);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Filters &&
          runtimeType == other.runtimeType &&
          facetGroups == other.facetGroups &&
          tagGroups == other.tagGroups &&
          numericGroups == other.numericGroups &&
          hierarchicalGroups == other.hierarchicalGroups;

  @override
  int get hashCode =>
      facetGroups.hashCode ^
      tagGroups.hashCode ^
      numericGroups.hashCode ^
      hierarchicalGroups.hashCode;

  @override
  String toString() {
    return 'Filters{facetGroups: $facetGroups, tagGroups: $tagGroups, numericGroups: $numericGroups, hierarchicalGroups: $hierarchicalGroups}';
  }
}

extension FilterGroupMapExt<T extends Filter> on FilterGroupMap<T> {
  /// Returns new filter group instance with updated values.
  FilterGroupMap<T> add(FilterGroupID groupID, T filter) {
    final current = Set<T>.from(this[groupID] ?? const {});
    if (current.contains(filter)) return this; // already exists, fast way out
    final filters = Set.unmodifiable(current..add(filter));
    final updated = Map.from(this)..addEntries([MapEntry(groupID, filters)]);
    return Map<FilterGroupID, Set<T>>.unmodifiable(updated);
  }

  /// Returns new filter group instance with updated values.
  FilterGroupMap<T> delete(FilterGroupID groupID, T filter) {
    final current = Set<T>.from(this[groupID] ?? const {});
    if (!current.contains(filter)) return this; // do not exists, fast way out
    final filters = Set<T>.unmodifiable(current..remove(filter));
    final updated = filters.isEmpty
        ? FilterGroupMap<T>.from(this).apply((it) => it.remove(groupID))
        : FilterGroupMap<T>.from(this)
            .apply((it) => it.addEntries([MapEntry(groupID, filters)]));
    return FilterGroupMap<T>.unmodifiable(updated);
  }

  /// Returns new filter group instance without deleted groups.
  FilterGroupMap<T> deleteGroups(Iterable<FilterGroupID> groupIDs) {
    final current = FilterGroupMap<T>.from(this);
    for (final groupID in groupIDs) {
      current.remove(groupID);
    }
    return current.length != length
        ? FilterGroupMap<T>.unmodifiable(current)
        : this;
  }

  /// Returns new filter group instance without deleted groups.
  FilterGroupMap<T> deleteGroupsExcept(Iterable<FilterGroupID> groupIDs) {
    final deletable = keys.where((groupID) => !groupIDs.contains(groupID));
    return deleteGroups(deletable);
  }
}
