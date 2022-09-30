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
  void addHierarchical(
    String attribute,
    HierarchicalFilter hierarchicalFilter,
  );

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
  /// Filters groups stream (facet, tag, numeric and hierarchical).
  @override
  Stream<Filters> get filters => _filters.stream.distinct();

  /// Events logger
  final Logger _log = algoliaLogger('FilterState');

  /// Hot stream controller of [StatelessFilters].
  final BehaviorSubject<StatelessFilters> _filters =
      BehaviorSubject.seeded(StatelessFilters());

  /// Adds [filters] to the provided [groupID].
  @override
  void add(FilterGroupID groupID, Iterable<Filter> filters) {
    _modify((it) => it.add(groupID, filters));
  }

  /// Overrides [filters] with the provided [map].
  @override
  void set(Map<FilterGroupID, Set<Filter>> map) {
    _modify((it) => it.set(map));
  }

  /// Removes [filters] from [groupID].
  @override
  void remove(FilterGroupID groupID, Iterable<Filter> filters) {
    _modify((it) => it.remove(groupID, filters));
  }

  /// Toggles [filter] in given [groupID].
  @override
  void toggle(FilterGroupID groupID, Filter filter) =>
      _modify((it) => it.toggle(groupID, filter));

  /// Checks if [filter] exists in [groupID].
  @override
  bool contains(FilterGroupID groupID, Filter filter) =>
      _filters.value.contains(groupID, filter);

  /// Adds [hierarchicalFilter] to given [attribute].
  @override
  void addHierarchical(
    String attribute,
    HierarchicalFilter hierarchicalFilter,
  ) {
    _modify((it) => it.addHierarchical(attribute, hierarchicalFilter));
  }

  /// Removes [HierarchicalFilter] of given [attribute].
  @override
  void removeHierarchical(String attribute) {
    _modify((it) => it.removeHierarchical(attribute));
  }

  /// Clears [groupIDs].
  /// If none provided, all filters will be cleared.
  @override
  void clear([Iterable<FilterGroupID>? groupIDs]) {
    _modify((it) => it.clear(groupIDs));
  }

  /// Clears all except [groupIDs].
  @override
  void clearExcept(Iterable<FilterGroupID> groupIDs) {
    _modify((it) => it.clearExcept(groupIDs));
  }

  /// Get current [filters] value.
  @override
  Filters snapshot() => _filters.value;

  /// Dispose of underlying resources.
  @override
  void doDispose() {
    _log.finest('FilterState disposed');
    _filters.close();
  }

  /// **Asynchronous** updates [filters] by applying [builder] to current
  /// filters value.
  /// Useful to apply multiple consecutive update operations without firing
  /// multiple filters events.
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
