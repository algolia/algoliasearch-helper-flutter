import 'package:algolia_helper/src/utils.dart';
import 'package:rxdart/rxdart.dart';

import 'filter.dart';
import 'filter_group.dart';

class FilterState {
  final _filters =
      BehaviorSubject<ImmutableFilters>.seeded(ImmutableFilters._());

  Stream<Filters> get filters => _filters.stream;

  void apply(ImmutableFilters Function(ImmutableFilters filters) block) {
    final current = _filters.value;
    final updated = block(current);
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

  set(Map<FilterGroupID, Set<Filter>> map) {
    // TODO: implement set
    throw UnimplementedError();
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

  ImmutableFilters addHierarchical(String attribute, HierarchicalFilter hierarchicalFilter) {
    // TODO: implement addHierarchical
    throw UnimplementedError();
  }

  ImmutableFilters removeHierarchical(String attribute) {
    // TODO: implement removeHierarchical
    throw UnimplementedError();
  }

  ImmutableFilters clear(Iterator<FilterGroupID> groupIDs) {
    // TODO: implement clear
    throw UnimplementedError();
  }

  ImmutableFilters clearExcept(Iterator<FilterGroupID> groupIDs) {
    // TODO: implement clearExcept
    throw UnimplementedError();
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

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      super == other &&
          other is ImmutableFilters &&
          runtimeType == other.runtimeType;

  @override
  int get hashCode => super.hashCode;
}

class Filters {
  Filters._(this.facetGroups, this.tagGroups, this.numericGroups,
      this.hierarchicalGroups);

  final Map<FilterGroupID, Set<FilterFacet>> facetGroups;
  final Map<FilterGroupID, Set<FilterTag>> tagGroups;
  final Map<FilterGroupID, Set<FilterNumeric>> numericGroups;
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

extension FiltersExt<T extends Filter> on Map<FilterGroupID, Set<T>> {

  /// Returns new filter group instance with updated values.
  Map<FilterGroupID, Set<T>> add(FilterGroupID groupID, T filter) {
    final Set<T> current = Set.from(this[groupID] ?? <T>{});
    final filters = Set.unmodifiable(current..add(filter));
    final updated = Map.from(this)..addEntries([MapEntry(groupID, filters)]);
    return Map.unmodifiable(updated);
  }

  /// Returns new filter group instance with updated values.
  Map<FilterGroupID, Set<T>> remove(FilterGroupID groupID, T filter) {
    final Set<T> current = Set.from(this[groupID] ?? <T>{});
    if (!current.contains(filter)) return this;
    final filters = Set.unmodifiable(current..remove(filter));
    final updated = filters.isEmpty
        ? Map.from(this).apply((it) => it.remove(groupID))
        : Map.from(this).apply((it) => it.addEntries([MapEntry(groupID, filters)]));


    //final updated = Map.from(this)..addEntries([MapEntry(groupID, filters)]);
    return Map.unmodifiable(updated);
  }
}
