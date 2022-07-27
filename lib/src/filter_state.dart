import 'package:rxdart/rxdart.dart';

import 'filter.dart';
import 'filter_group.dart';

class FilterState {
  final _filters = BehaviorSubject<MutableFilters>.seeded(MutableFilters._());

  Stream<Filters> get filters => _filters.stream;

  void apply(Function(MutableFilters filters) block) {
    final current = _filters.value;
    block(current);
    _filters.sink.add(current);
  }
}

class MutableFilters extends Filters {
  MutableFilters._() : super._();

  add(FilterGroupID groupID, Iterable<Filter> filters) {
    for (final filter in filters) {
      switch (filter.runtimeType) {
        case FilterFacet:
          return facetGroups.add(groupID, filter as FilterFacet);
        case FilterTag:
          return tagGroups.add(groupID, filter as FilterTag);
        case FilterNumeric:
          return numericGroups.add(groupID, filter as FilterNumeric);
      }
    }
  }

  set(Map<FilterGroupID, Set<Filter>> map) {
    // TODO: implement set
    throw UnimplementedError();
  }

  toggle(FilterGroupID groupID, Filter filter) {
    // TODO: implement toggle
    throw UnimplementedError();
  }

  remove(FilterGroupID groupID, Iterable<Filter> filters) {
    // TODO: implement remove
    throw UnimplementedError();
  }

  addHierarchical(String attribute, HierarchicalFilter hierarchicalFilter) {
    // TODO: implement addHierarchical
    throw UnimplementedError();
  }

  removeHierarchical(String attribute) {
    // TODO: implement removeHierarchical
    throw UnimplementedError();
  }

  clear(Iterator<FilterGroupID> groupIDs) {
    // TODO: implement clear
    throw UnimplementedError();
  }

  clearExcept(Iterator<FilterGroupID> groupIDs) {
    // TODO: implement clearExcept
    throw UnimplementedError();
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      super == other &&
          other is MutableFilters &&
          runtimeType == other.runtimeType;

  @override
  int get hashCode => super.hashCode;
}

class Filters {
  Filters._();

  final Map<FilterGroupID, Set<FilterFacet>> facetGroups = {};
  final Map<FilterGroupID, Set<FilterTag>> tagGroups = {};
  final Map<FilterGroupID, Set<FilterNumeric>> numericGroups = {};
  final Map<String, HierarchicalFilter> hierarchicalGroups = {};

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
  void add(FilterGroupID groupID, T filter) {
    final Set<T> current = this[groupID] ?? <T>{};
    current.add(filter);
    addEntries([MapEntry(groupID, current)]);
  }
}
