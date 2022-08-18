import 'package:rxdart/rxdart.dart';

import 'filter.dart';
import 'filter_group.dart';
import 'utils.dart';

/// [FilterState] holds one or several filters, organized in groups.
/// [filters] streams filters changes of added or removed filters,
/// which will be applied to searches performed by the connected Searcher.
class FilterState {
  /// Filters groups stream (facet, tag, numeric and hierarchical).
  Stream<Filters> get filters => _filters.stream.distinct();

  final BehaviorSubject<_ImmutableFilters> _filters =
      BehaviorSubject.seeded(_ImmutableFilters());

  void add(FilterGroupID groupID, Iterable<Filter> filters) {
    _modify((it) => it.add(groupID, filters));
  }

  void set(Map<FilterGroupID, Set<Filter>> map) {
    _modify((it) => it.set(map));
  }

  void remove(FilterGroupID groupID, Iterable<Filter> filters) {
    _modify((it) => it.remove(groupID, filters));
  }

  void toggle(FilterGroupID groupID, Filter filter) => contains(groupID, filter)
      ? remove(groupID, [filter])
      : add(groupID, [filter]);

  bool contains(FilterGroupID groupID, Filter filter) =>
      _filters.value.contains(groupID, filter);

  void addHierarchical(
    String attribute,
    HierarchicalFilter hierarchicalFilter,
  ) {
    _modify((it) => it.addHierarchical(attribute, hierarchicalFilter));
  }

  void removeHierarchical(String attribute) {
    _modify((it) => it.removeHierarchical(attribute));
  }

  void clear(Iterable<FilterGroupID> groupIDs) {
    _modify((it) => it.clear(groupIDs));
  }

  void clearExcept(Iterable<FilterGroupID> groupIDs) {
    _modify((it) => it.clearExcept(groupIDs));
  }

  Filters snapshot() => _filters.value;

  void _modify(_ImmutableFilters Function(_ImmutableFilters filters) action) {
    final current = _filters.value;
    final updated = action(current);
    _filters.sink.add(updated);
  }
}

/// Filter groups: facet, tag, numeric and hierarchical.
class Filters {
  Filters._(
    this.facetGroups,
    this.tagGroups,
    this.numericGroups,
    this.hierarchicalGroups,
  );

  final FilterGroupMap<FilterFacet> facetGroups;
  final FilterGroupMap<FilterTag> tagGroups;
  final FilterGroupMap<FilterNumeric> numericGroups;
  final Map<String, HierarchicalFilter> hierarchicalGroups;

  Set<FilterFacet>? getFacetFilters(FilterGroupID groupID) =>
      facetGroups[groupID];

  Set<FilterTag>? getTagFilters(FilterGroupID groupID) => tagGroups[groupID];

  Set<FilterNumeric>? getNumericFilters(FilterGroupID groupID) =>
      numericGroups[groupID];

  HierarchicalFilter? getHierarchicalFilters(String attribute) =>
      hierarchicalGroups[attribute];

  Map<FilterGroupID, Set<Filter>> getGroups() =>
      {...facetGroups, ...tagGroups, ...numericGroups};

  Set<Filter> getFilters({FilterGroupID? groupID}) =>
      groupID == null ? _getAllFilters() : _getFiltersByGroupID(groupID);

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

  Set<FilterGroup> toFilterGroups() {
    final facets = facetGroups.toList(FacetFilterGroup.new).unmodifiable();
    final tags = tagGroups.toList(TagFilterGroup.new).unmodifiable();
    final numerics =
        numericGroups.toList(NumericFilterGroup.new).unmodifiable();
    final hierarchical = hierarchicalGroups
        .toList((name, filter) => HierarchicalFilterGroup(name, {filter}))
        .unmodifiable();
    return {...facets, ...tags, ...numerics, ...hierarchical};
  }

  Filters copyWith({
    Map<FilterGroupID, Set<FilterFacet>>? facetGroups,
    Map<FilterGroupID, Set<FilterTag>>? tagGroups,
    Map<FilterGroupID, Set<FilterNumeric>>? numericGroups,
    Map<String, HierarchicalFilter>? hierarchicalGroups,
  }) =>
      Filters._(
        facetGroups ?? this.facetGroups,
        tagGroups ?? this.tagGroups,
        numericGroups ?? this.numericGroups,
        hierarchicalGroups ?? this.hierarchicalGroups,
      );

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
  String toString() => 'Filters{'
      ' facetGroups: $facetGroups,'
      ' tagGroups: $tagGroups,'
      ' numericGroups: $numericGroups,'
      ' hierarchicalGroups: $hierarchicalGroups'
      '}';
}

/// Map of filter groups convenience type.
typedef FilterGroupMap<T> = Map<FilterGroupID, Set<T>>;

/// Immutable filters implementation.
class _ImmutableFilters extends Filters {
  _ImmutableFilters({
    Map<FilterGroupID, Set<FilterFacet>> facetGroups = const {},
    Map<FilterGroupID, Set<FilterTag>> tagGroups = const {},
    Map<FilterGroupID, Set<FilterNumeric>> numericGroups = const {},
    Map<String, HierarchicalFilter> hierarchicalGroups = const {},
  }) : super._(facetGroups, tagGroups, numericGroups, hierarchicalGroups);

  _ImmutableFilters add(FilterGroupID groupID, Iterable<Filter> filters) {
    var current = this;
    for (final filter in filters) {
      switch (filter.runtimeType) {
        case FilterFacet:
          current = current.copyWith(
            facetGroups: facetGroups.add(groupID, filter as FilterFacet),
          );
          break;
        case FilterTag:
          current = current.copyWith(
            tagGroups: tagGroups.add(groupID, filter as FilterTag),
          );
          break;
        case FilterNumeric:
          current = current.copyWith(
            numericGroups: numericGroups.add(groupID, filter as FilterNumeric),
          );
          break;
      }
    }
    return current;
  }

  _ImmutableFilters set(Map<FilterGroupID, Set<Filter>> map) {
    var filters = _ImmutableFilters();
    for (final entry in map.entries) {
      filters = filters.add(entry.key, entry.value);
    }
    return filters;
  }

  _ImmutableFilters toggle(FilterGroupID groupID, Filter filter) =>
      contains(groupID, filter)
          ? remove(groupID, [filter])
          : add(groupID, [filter]);

  _ImmutableFilters remove(FilterGroupID groupID, Iterable<Filter> filters) {
    for (final filter in filters) {
      switch (filter.runtimeType) {
        case FilterFacet:
          return copyWith(
            facetGroups: facetGroups.delete(groupID, filter as FilterFacet),
          );
        case FilterTag:
          return copyWith(
            tagGroups: tagGroups.delete(groupID, filter as FilterTag),
          );
        case FilterNumeric:
          return copyWith(
            numericGroups:
                numericGroups.delete(groupID, filter as FilterNumeric),
          );
      }
    }
    return this;
  }

  _ImmutableFilters addHierarchical(
    String attribute,
    HierarchicalFilter hierarchicalFilter,
  ) {
    if (hierarchicalGroups.containsKey(attribute)) return this;
    final groups = Map<String, HierarchicalFilter>.from(hierarchicalGroups)
      ..[attribute] = hierarchicalFilter;
    return copyWith(hierarchicalGroups: Map.unmodifiable(groups));
  }

  _ImmutableFilters removeHierarchical(String attribute) {
    if (!hierarchicalGroups.containsKey(attribute)) return this;
    final groups = Map<String, HierarchicalFilter>.from(hierarchicalGroups)
      ..remove(attribute);
    return copyWith(hierarchicalGroups: Map.unmodifiable(groups));
  }

  _ImmutableFilters clear([Iterable<FilterGroupID>? groupIDs]) {
    if (groupIDs == null || groupIDs.isEmpty) return _ImmutableFilters();
    return _ImmutableFilters(
      facetGroups: facetGroups.deleteGroups(groupIDs),
      numericGroups: numericGroups.deleteGroups(groupIDs),
      tagGroups: tagGroups.deleteGroups(groupIDs),
    );
  }

  _ImmutableFilters clearExcept(Iterable<FilterGroupID> groupIDs) {
    if (groupIDs.isEmpty) return _ImmutableFilters();
    return _ImmutableFilters(
      facetGroups: facetGroups.deleteGroupsExcept(groupIDs),
      numericGroups: numericGroups.deleteGroupsExcept(groupIDs),
      tagGroups: tagGroups.deleteGroupsExcept(groupIDs),
    );
  }

  @override
  _ImmutableFilters copyWith({
    Map<FilterGroupID, Set<FilterFacet>>? facetGroups,
    Map<FilterGroupID, Set<FilterTag>>? tagGroups,
    Map<FilterGroupID, Set<FilterNumeric>>? numericGroups,
    Map<String, HierarchicalFilter>? hierarchicalGroups,
  }) =>
      _ImmutableFilters(
        facetGroups: facetGroups ?? this.facetGroups,
        tagGroups: tagGroups ?? this.tagGroups,
        numericGroups: numericGroups ?? this.numericGroups,
        hierarchicalGroups: hierarchicalGroups ?? this.hierarchicalGroups,
      );
}

extension _FilterGroupMapExt<T extends Filter> on FilterGroupMap<T> {
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
