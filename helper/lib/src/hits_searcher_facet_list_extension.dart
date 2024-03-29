import 'package:algolia_insights/algolia_insights.dart';
import 'package:meta/meta.dart';

import 'facet_list.dart';
import 'filter_group.dart';
import 'filter_state.dart';
import 'filter_state_group_accessor.dart';
import 'searcher/hits_searcher.dart';

extension HitsSearcherFacetListExtension on HitsSearcher {
  static FilterEventTracker? _makeEventTracker(
    HitsSearcher searcher,
    String attribute,
  ) {
    if (searcher.eventTracker == null) {
      return null;
    }

    return FilterEventTracker(
      searcher.eventTracker!.tracker,
      searcher,
      attribute,
    );
  }

  @experimental
  FacetList buildFacetList({
    required FilterState filterState,
    required String attribute,
    FilterOperator operator = FilterOperator.or,
    SelectionMode selectionMode = SelectionMode.multiple,
    bool persistent = false,
  }) {
    // Setup search state by adding `attribute` to the search state
    applyState(
      (state) => state.copyWith(
        facets: List.from((state.facets ?? [])..add(attribute)),
        disjunctiveFacets: operator == FilterOperator.or
            ? {...?state.disjunctiveFacets, attribute}
            : state.disjunctiveFacets,
      ),
    );

    // Extract the Stream<List<Facet>> from HitsSearcher
    final facetsStream = responses.map(
      (response) =>
          response.disjunctiveFacets[attribute] ??
          response.facets[attribute] ??
          [],
    );

    // Establish the filter group accessor proxy as selection state
    final state = FiltersGroupAccessor(
      filterState: filterState,
      groupID: FilterGroupID(
        attribute,
        operator,
      ),
      attribute: attribute,
    );

    return FacetList(
      facetsStream: facetsStream,
      state: state,
      selectionMode: selectionMode,
      persistent: persistent,
      eventTracker: _makeEventTracker(this, attribute),
    );
  }
}
