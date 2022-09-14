import 'dart:async';

import 'package:meta/meta.dart';

import 'facet_list_internal.dart';
import 'filter_group.dart';
import 'filter_state.dart';
import 'hits_searcher.dart';
import 'search_response.dart';
import 'selectable_item.dart';

/// FacetList (refinement list) is a filtering components that displays facets,
/// and lets the user refine their search results by filtering on specific
/// values.
@experimental
@sealed
abstract class FacetList {
  /// Create [FacetList] instance.
  factory FacetList({
    required HitsSearcher searcher,
    required FilterState filterState,
    required String attribute,
    FilterOperator operator = FilterOperator.or,
    SelectionMode selectionMode = SelectionMode.multiple,
    bool persistent = false,
  }) =>
      InternalFacetList(
        searcher: searcher,
        filterState: filterState,
        attribute: attribute,
        groupID: FilterGroupID(attribute, operator),
        selectionMode: selectionMode,
        persistent: persistent,
      );

  /// Create [FacetList] instance.
  factory FacetList.create({
    required HitsSearcher searcher,
    required FilterState filterState,
    required String attribute,
    required FilterGroupID groupID,
    SelectionMode selectionMode = SelectionMode.multiple,
    bool persistent = false,
  }) =>
      InternalFacetList(
        searcher: searcher,
        filterState: filterState,
        attribute: attribute,
        groupID: groupID,
        selectionMode: selectionMode,
        persistent: persistent,
      );

  /// Stream of [Facet] list with selection status.
  Stream<List<SelectableFacet>> get facets;

  /// Snapshot of the latest [facets] value.
  List<SelectableFacet>? snapshot();

  /// Select/deselect the provided facet value depending on the current selection state.
  void toggle(String value);

  /// Dispose the component.
  void dispose();
}

/// Elements selection mode.
enum SelectionMode { single, multiple }

/// [Facet] with selection status.
typedef SelectableFacet = SelectableItem<Facet>;
