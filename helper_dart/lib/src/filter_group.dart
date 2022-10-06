import 'package:collection/collection.dart';
import 'package:meta/meta.dart';

import 'extensions.dart';
import 'filter.dart';

/// Represents a filter group, it is defined by a [Set] of [Filter]s
/// and a [groupID].
///
/// ## Facet filter group
///
/// Create a filter group of [FilterFacet] filters using [facet]
///
/// ```dart
/// final filterGroup = FilterGroup.facet(
///   name: 'colors',
///   filters: {
///     Filter.facet('color', 'red'),
///     Filter.facet('color', 'blue'),
///   },
///   operator: FilterOperator.and,
/// );
/// ```
///
/// ## Tag filter group
///
/// Create a filter group of [FilterTag] filters using [tag]
///
/// ```dart
/// final filterGroup = FilterGroup.tag(
///   operator: FilterOperator.or,
///   filters: {
///     Filter.tag('fantasy'),
///     Filter.tag('science fiction'),
///   },
/// );
/// ```
///
/// ## Numeric filter group
///
/// Create a filter group of [FilterNumeric] filters using [numeric]
///
/// ```dart
/// final filterGroup = FilterGroup.numeric(
///   name: 'products',
///   operator: FilterOperator.and,
///   filters: {
///     Filter.range('rating', lowerBound: 3, upperBound: 5),
///     Filter.comparison('price', NumericOperator.lessOrEquals, 100),
///   },
/// );
/// ```
///
/// ## Hierarchical filter group
///
/// Create a filter group of hierarchical filters using [hierarchical]
///
/// ```dart
/// final group = FilterGroup.hierarchical(
///   name: 'categories',
///   attributes: [
///     'category.lvl0',
///     'category.lvl1',
///   ],
///   path: [
///     Filter.facet('category.lvl0', 'Shoes'),
///     Filter.facet('category.lvl1', 'Shoes > Running'),
///   ],
///   filters: {Filter.facet('category.lvl1', 'Shoes > Running')},
/// );
/// ```
abstract class FilterGroup<T extends Filter> implements Set<T> {
  /// Create a filter group of [FilterFacet] filters.
  @factory
  static FacetFilterGroup facet({
    required Set<FilterFacet> filters,
    String name = '',
    FilterOperator operator = FilterOperator.and,
  }) =>
      FacetFilterGroup(FilterGroupID(name, operator), filters);

  /// Create a filter group of [FilterTag] filters
  @factory
  static TagFilterGroup tag({
    required Set<FilterTag> filters,
    String name = '',
    FilterOperator operator = FilterOperator.and,
  }) =>
      TagFilterGroup(FilterGroupID(name, operator), filters);

  /// Create a filter group of [FilterNumeric] filters
  @factory
  static NumericFilterGroup numeric({
    required Set<FilterNumeric> filters,
    String name = '',
    FilterOperator operator = FilterOperator.and,
  }) =>
      NumericFilterGroup(FilterGroupID(name, operator), filters);

  /// Create a filter group of hierarchical filters.
  @factory
  static HierarchicalFilterGroup hierarchical({
    required Set<FilterFacet> filters,
    required List<FilterFacet> path,
    required List<String> attributes,
    String name = '',
  }) =>
      HierarchicalFilterGroup(
        FilterGroupID.and(name),
        filters,
        path,
        attributes,
      );

  /// Filter group ID (name and operator)
  FilterGroupID get groupID;

  /// Create a copy with given parameters.
  @factory
  FilterGroup<T> copyWith({FilterGroupID? groupID, Set<T>? filters});
}

/// Identifier of a filter group.
/// The group name is for access purpose only, won't be used for the actual
/// filters generation.
///
/// ## Conjunctive filter group ID
///
/// Used to identify a conjunctive group, (e.g. `(color:red AND color:blue)`).
///
/// ```dart
/// const groupID = FilterGroupID('colors', FilterOperator.and);
/// ```
///
/// ## Disjunctive filter group ID
///
/// Used to identify a disjunctive group (e.g. `(color:red OR color:blue)`).
///
/// ```dart
/// const groupID = FilterGroupID('colors', FilterOperator.or);
/// ```
class FilterGroupID {
  const FilterGroupID([this.name = '', this.operator = FilterOperator.and]);

  /// Create and [FilterGroupID] with operator [FilterOperator.and].
  factory FilterGroupID.and([String name = '']) => FilterGroupID(name);

  /// Create and [FilterGroupID] with operator [FilterOperator.or].
  factory FilterGroupID.or([String name = '']) =>
      FilterGroupID(name, FilterOperator.or);

  /// Filters group name
  final String name;

  /// Operator to combine filters
  final FilterOperator operator;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FilterGroupID &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          operator == other.operator;

  @override
  int get hashCode => name.hashCode ^ operator.hashCode;

  @override
  String toString() => 'FilterGroupID{'
      ' name: $name,'
      ' operator: $operator'
      '}';
}

/// Group filter operator, can either be conjunctive ([and])
/// or disjunctive ([or]).
enum FilterOperator {
  /// Conjunctive operator
  and,

  /// Disjunctive operator
  or,
}

/// Filter group of [FilterFacet] filters.
class FacetFilterGroup extends DelegatingSet<FilterFacet>
    implements FilterGroup<FilterFacet> {
  /// Creates a [FilterGroup] instance.
  const FacetFilterGroup(this.groupID, this._filters) : super(_filters);

  @override
  final FilterGroupID groupID;

  /// Set of facet filters.
  final Set<FilterFacet> _filters;

  /// Make a copy of the facet filters group.
  @override
  FacetFilterGroup copyWith({
    FilterGroupID? groupID,
    Set<FilterFacet>? filters,
  }) =>
      FacetFilterGroup(
        groupID ?? this.groupID,
        filters ?? _filters,
      );

  @override
  String toString() =>
      'FacetFilterGroup{groupID: $groupID, filters: $_filters}';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FacetFilterGroup &&
          runtimeType == other.runtimeType &&
          groupID == other.groupID &&
          _filters.equals(other._filters);

  @override
  int get hashCode => groupID.hashCode ^ _filters.hashing();
}

/// Filter group of [FilterTag] filters.
class TagFilterGroup extends DelegatingSet<FilterTag>
    implements FilterGroup<FilterTag> {
  /// Creates a [TagFilterGroup] instance.
  const TagFilterGroup(this.groupID, this._filters) : super(_filters);

  @override
  final FilterGroupID groupID;

  /// Set of tag filters.
  final Set<FilterTag> _filters;

  /// Make a copy of the tag filters group.
  @override
  TagFilterGroup copyWith({
    FilterGroupID? groupID,
    Set<FilterTag>? filters,
  }) =>
      TagFilterGroup(
        groupID ?? this.groupID,
        filters ?? _filters,
      );

  @override
  String toString() => 'TagFilterGroup{groupID: $groupID, filters: $_filters}';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TagFilterGroup &&
          runtimeType == other.runtimeType &&
          groupID == other.groupID &&
          _filters.equals(other._filters);

  @override
  int get hashCode => groupID.hashCode ^ _filters.hashing();
}

/// Filter group of [FilterNumeric] filters.
class NumericFilterGroup extends DelegatingSet<FilterNumeric>
    implements FilterGroup<FilterNumeric> {
  /// Creates a [NumericFilterGroup] instance.
  const NumericFilterGroup(this.groupID, this._filters) : super(_filters);

  @override
  final FilterGroupID groupID;

  /// Set of numeric filters.
  final Set<FilterNumeric> _filters;

  /// Make a copy of the numeric filters group.
  @override
  NumericFilterGroup copyWith({
    FilterGroupID? groupID,
    Set<FilterNumeric>? filters,
  }) =>
      NumericFilterGroup(
        groupID ?? this.groupID,
        filters ?? _filters,
      );

  @override
  String toString() =>
      'NumericFilterGroup{groupID: $groupID, filters: $_filters}';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NumericFilterGroup &&
          runtimeType == other.runtimeType &&
          groupID == other.groupID &&
          _filters == other._filters;

  @override
  int get hashCode => groupID.hashCode ^ _filters.hashCode;
}

/// Filter group of hierarchical filters
class HierarchicalFilterGroup extends DelegatingSet<FilterFacet>
    implements FilterGroup<FilterFacet> {
  /// Creates an [HierarchicalFilterGroup] instance.
  HierarchicalFilterGroup(
    this.groupID,
    this._filters,
    this.path,
    this.attributes,
  )   : assert(groupID.operator == FilterOperator.and),
        super(_filters);

  @override
  final FilterGroupID groupID;

  /// Set of facet filters.
  final Set<FilterFacet> _filters;

  /// Filter facets path.
  final List<FilterFacet> path;

  /// Attributes names.
  final List<String> attributes;

  /// Make a copy of the hierarchical filters group.
  @override
  HierarchicalFilterGroup copyWith({
    FilterGroupID? groupID,
    Set<FilterFacet>? filters,
    List<FilterFacet>? path,
    List<String>? attributes,
  }) =>
      HierarchicalFilterGroup(
        groupID ?? this.groupID,
        filters ?? _filters,
        path ?? this.path,
        attributes ?? this.attributes,
      );

  @override
  String toString() => 'HierarchicalFilterGroup{'
      'groupID: $groupID, '
      'filters: $_filters, '
      'path: $path, '
      'attributes: $attributes}';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HierarchicalFilterGroup &&
          runtimeType == other.runtimeType &&
          groupID == other.groupID &&
          _filters.equals(other._filters) &&
          path.equals(other.path) &&
          attributes.equals(other.attributes);

  @override
  int get hashCode =>
      groupID.hashCode ^
      _filters.hashing() ^
      path.hashing() ^
      attributes.hashing();
}
