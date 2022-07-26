import 'package:rxdart/rxdart.dart';

import 'filter.dart';
import 'filter_group.dart';

class FilterState {
  final filters = BehaviorSubject<MutableFilters>();

  void apply(Function(MutableFilters filters) block) {
    final current = filters.value;
    block(current);
    filters.sink.add(current);
  }
}

class MutableFilters extends Filters {
  MutableFilters._(
      {this.facetGroups = const {},
      this.tagGroups = const {},
      this.numericGroups = const {},
      this.hierarchicalGroups = const {}});

  final Map<FilterGroupID, Set<FilterFacet>> facetGroups;
  final Map<FilterGroupID, Set<FilterTag>> tagGroups;
  final Map<FilterGroupID, Set<FilterNumeric>> numericGroups;
  final Map<String, HierarchicalFilter> hierarchicalGroups;

  add(FilterGroupID groupID, Iterable<Filter> filters) {
    final Iterable<Filter> facets =
        filters.where((filter) => filter.runtimeType == FilterFacet);
    final tags = filters.where((filter) => filter.runtimeType == FilterTag);
    final numerics =
        filters.where((filter) => filter.runtimeType == FilterNumeric);


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

  MutableFilters copyWith({
    Map<FilterGroupID, Set<FilterFacet>>? facetGroups,
    Map<FilterGroupID, Set<FilterTag>>? tagGroups,
    Map<FilterGroupID, Set<FilterNumeric>>? numericGroups,
    Map<String, HierarchicalFilter>? hierarchicalGroups,
  }) {
    return MutableFilters._(
        facetGroups: facetGroups ?? this.facetGroups,
        tagGroups: tagGroups ?? this.tagGroups,
        numericGroups: numericGroups ?? this.numericGroups,
        hierarchicalGroups: hierarchicalGroups ?? this.hierarchicalGroups);
  }
}

abstract class Filters {
  Set<FilterFacet> getFacetFilters(FilterGroupID groupID);

  Set<FilterTag> getTagFilters(FilterGroupID groupID);

  Set<FilterNumeric> getNumericFilters(FilterGroupID groupID);

  HierarchicalFilter getHierarchicalFilters(String attribute);

  Map<FilterGroupID, Set<FilterFacet>> getFacetGroups();

  Map<FilterGroupID, Set<FilterTag>> getTagGroups();

  Map<FilterGroupID, Set<FilterNumeric>> getNumericGroups();

  Map<String, HierarchicalFilter> getHierarchicalGroups();

  Map<FilterGroupID, Set<Filter>> getGroups();

  Set<Filter> getFilters({FilterGroupID? groupID});

  bool contains(FilterGroupID groupID, Filter filter);

  Set<FilterGroup<Filter>> toFilterGroups();
}
