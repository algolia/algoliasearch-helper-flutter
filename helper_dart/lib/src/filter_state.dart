import 'dart:async';

import 'package:logging/logging.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';

import 'disposable.dart';
import 'disposable_mixin.dart';
import 'filter.dart';
import 'filter_group.dart';
import 'filters.dart';
import 'logger.dart';

/// [FilterState] holds one or several filters, organized in groups.
/// [filters] streams filters changes of added or removed filters,
/// which will be applied to searches performed by the connected Searcher.
///
/// ## Create
///
/// The following is an example of creating and setting up a [FilterState]
/// with different filters (facets, tags and numerical):
///
/// ```dart
/// const authors = FilterGroupID('author', FilterOperator.or);
/// const genres = FilterGroupID('genres');
/// const numbers = FilterGroupID('numbers');
///
/// final filterState = FilterState()
///   ..add(authors, [Filter.facet('author', 'Shakespeare')])
///   ..add(genres, [Filter.tag('drama')])
///   ..add(numbers, [Filter.range('rating', lowerBound: 3, upperBound: 5)])
///   ..add(numbers, [Filter.comparison('price', NumericOperator.less, 50)]);
/// ```
///
/// The code snippet above corresponds to the following SQL-like expression:
/// `(author:Shakespeare) AND (_tags:drama) AND (rating:3 TO 5 AND price < 50)`
///
/// ## Update
///
/// [FilterState] can be updated using methods such as [add], [set]
/// and [remove], each modification triggers a [filters] submission.
///
/// Running multiple modifications (atomically), and trigger a single [filters]
/// submission can be done using [modify] method:
///
/// ```dart
///   filterState.modify((filters) async =>
///       filters
///           .add(authors, [Filter.facet('author', 'J. K. Rowling')])
///           .remove(authors, [Filter.facet('author', 'Shakespeare')]));
/// ```
///
/// ## Delete
///
/// Remove all or some filter groups using [clear] and [clearExcept]
///
/// ```dart
///   filterState.clear(); // removes all filter groups
///   filterState.clear(authors); // clears filter group 'authors'
///   filterState.clearExcept([authors]); // clears all filter groups except 'authors'
/// ```
@sealed
abstract class FilterState implements Disposable {
  /// FilterState's factory.
  factory FilterState() => _FilterState();

  /// Filters groups stream (facet, tag, numeric and hierarchical).
  Stream<Filters> get filters;

  /// Adds [filters] to the provided [groupID].
  void add(FilterGroupID groupID, Iterable<Filter> filters);

  /// Overrides [filters] with the provided [map].
  void set(Map<FilterGroupID, Set<Filter>> map);

  /// Removes [filters] from [groupID].
  void remove(FilterGroupID groupID, Iterable<Filter> filters);

  /// Toggles [filter] in given [groupID].
  void toggle(FilterGroupID groupID, Filter filter);

  /// Checks if [filter] exists in [groupID].
  bool contains(FilterGroupID groupID, Filter filter);

  /// Adds [hierarchicalFilter] to given [attribute].
  void addHierarchical(String attribute,
      HierarchicalFilter hierarchicalFilter,);

  /// Removes [HierarchicalFilter] of given [attribute].
  void removeHierarchical(String attribute);

  /// Clears [groupIDs].
  /// If none provided, all filters will be cleared.
  void clear([Iterable<FilterGroupID>? groupIDs]);

  /// Clears all except [groupIDs].
  void clearExcept(Iterable<FilterGroupID> groupIDs);

  /// Get current [filters] value.
  Filters snapshot();

  /// **Asynchronous** updates [filters] by applying [builder] to current
  /// filters value.
  /// Useful to apply multiple consecutive update operations without firing
  /// multiple filters events.
  Future<void> modify(AsyncFiltersBuilder builder);
}

/// Asynchronous stateless filters builder.
typedef AsyncFiltersBuilder = Future<StatelessFilters> Function(
    StatelessFilters filters,
    );

/// Default implementation of [FilterState].
class _FilterState with DisposableMixin implements FilterState {
  @override
  Stream<Filters> get filters => _filters.stream.distinct();

  /// Events logger
  final Logger _log = algoliaLogger('FilterState');

  /// Hot stream controller of [StatelessFilters].
  final BehaviorSubject<StatelessFilters> _filters =
  BehaviorSubject.seeded(StatelessFilters());

  @override
  void add(FilterGroupID groupID, Iterable<Filter> filters) {
    _modify((it) => it.add(groupID, filters));
  }

  @override
  void set(Map<FilterGroupID, Set<Filter>> map) {
    _modify((it) => it.set(map));
  }

  @override
  void remove(FilterGroupID groupID, Iterable<Filter> filters) {
    _modify((it) => it.remove(groupID, filters));
  }

  @override
  void toggle(FilterGroupID groupID, Filter filter) =>
      _modify((it) => it.toggle(groupID, filter));

  @override
  bool contains(FilterGroupID groupID, Filter filter) =>
      _filters.value.contains(groupID, filter);

  @override
  void addHierarchical(String attribute,
      HierarchicalFilter hierarchicalFilter,) {
    _modify((it) => it.addHierarchical(attribute, hierarchicalFilter));
  }

  @override
  void removeHierarchical(String attribute) {
    _modify((it) => it.removeHierarchical(attribute));
  }

  @override
  void clear([Iterable<FilterGroupID>? groupIDs]) {
    _modify((it) => it.clear(groupIDs));
  }

  @override
  void clearExcept(Iterable<FilterGroupID> groupIDs) {
    _modify((it) => it.clearExcept(groupIDs));
  }

  @override
  Filters snapshot() => _filters.value;

  @override
  void doDispose() {
    _log.finest('FilterState disposed');
    _filters.close();
  }

  @override
  Future<void> modify(AsyncFiltersBuilder builder) async {
    if (_filters.isClosed) {
      _log.warning('modifying disposed instance');
      return;
    }
    final current = _filters.value;
    final updated = await builder(current);
    _filters.sink.add(updated);
    _log.finest('FilterState updated: $updated');
  }

  /// Updates [filters] by applying [builder] to current filters value.
  /// Useful to apply multiple consecutive update operations without firing
  /// multiple filters events.
  void _modify(StatelessFilters Function(StatelessFilters) builder) {
    if (_filters.isClosed) {
      _log.warning('modifying disposed instance');
      return;
    }
    final current = _filters.value;
    final updated = builder(current);
    _filters.sink.add(updated);
    _log.finest('FilterState updated: $updated');
  }
}
