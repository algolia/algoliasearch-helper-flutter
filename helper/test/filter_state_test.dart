import 'package:algolia_helper_flutter/algolia_helper_flutter.dart';
import 'package:test/test.dart';

void main() {
  const attributeA = 'nameA';
  const attributeB = 'nameB';
  final groupAndA = FilterGroupID.and(attributeA);
  final groupAndB = FilterGroupID.and(attributeB);
  final groupOrA = FilterGroupID.or(attributeA);
  final facetA = Filter.facet(attributeA, 0);
  final facetB = Filter.facet(attributeB, 0);
  final tag = Filter.tag('0');
  final numeric = Filter.range(attributeA, lowerBound: 0, upperBound: 10);

  test('FilterState add facet', () {
    final filterState = FilterState();

    final groupA = FilterGroupID.and('GroupA');
    filterState
      ..add(groupA, [Filter.facet('Category', 'A')])
      ..add(groupA, [Filter.facet('Category', 'A')])
      ..add(groupA, [Filter.facet('Category', 'B')]);

    final snapshot = filterState.snapshot();
    expect(snapshot.facetGroups.containsKey(groupA), true);
    expect(snapshot.facetGroups[groupA]!.length, 2);
    expect(snapshot.tagGroups.isEmpty, true);
    expect(snapshot.numericGroups.isEmpty, true);
    expect(snapshot.hierarchicalGroups.isEmpty, true);
  });

  test('FilterState constructor', () {
    final map = {
      groupAndA: {facetA, tag, numeric},
      groupOrA: {facetB, tag, numeric},
    };
    final filterState = FilterState()..set(map);
    final filters = filterState.snapshot();
    expect(filters.getFacetFilters(groupAndA), {facetA});
    expect(filters.getFacetFilters(groupOrA), {facetB});
    expect(filters.getNumericFilters(groupAndA), {numeric});
    expect(filters.getNumericFilters(groupOrA), {numeric});
    expect(filters.getTagFilters(groupAndA), {tag});
    expect(filters.getTagFilters(groupOrA), {tag});
  });

  test('Add to same group', () {
    final filterState = FilterState()
      ..add(groupAndA, [facetA])
      ..add(groupAndA, [facetB]);

    final snapshot = filterState.snapshot();
    expect(snapshot.getGroups(), {
      groupAndA: {facetA, facetB},
    });
  });

  test('Add to different groups', () {
    final filterState = FilterState()
      ..add(groupAndA, [facetA])
      ..add(groupAndB, [facetA]);

    final snapshot = filterState.snapshot();
    expect(snapshot.getGroups(), {
      groupAndA: {facetA},
      groupAndB: {facetA},
    });
  });

  test('Add different types to the same group', () {
    final filterState = FilterState()
      ..add(groupAndA, [facetA])
      ..add(groupAndA, [numeric]);

    final snapshot = filterState.snapshot();
    expect(snapshot.facetGroups, {
      groupAndA: {facetA},
    });
    expect(snapshot.numericGroups, {
      groupAndA: {numeric},
    });
  });

  test('Add different types to different groups', () {
    final filterState = FilterState()
      ..add(groupAndA, [facetA])
      ..add(groupAndB, [numeric]);

    final snapshot = filterState.snapshot();
    expect(snapshot.facetGroups, {
      groupAndA: {facetA},
    });
    expect(snapshot.numericGroups, {
      groupAndB: {numeric},
    });
  });

  test('Remove filters', () {
    final filterState = FilterState()
      ..add(groupAndA, [facetA, facetB])
      ..remove(groupAndA, [facetA]);

    final snapshot = filterState.snapshot();
    expect(snapshot.facetGroups, {
      groupAndA: {facetB},
    });
  });

  test('Remove filter from empty', () {
    final filterState = FilterState()..remove(groupAndA, [facetA]);

    final snapshot = filterState.snapshot();
    expect(snapshot.facetGroups.isEmpty, true);
    expect(snapshot.numericGroups.isEmpty, true);
    expect(snapshot.tagGroups.isEmpty, true);
  });

  test('Remove non-existing filter', () {
    final filterState = FilterState()
      ..add(groupAndA, [facetA])
      ..remove(groupAndA, [facetB]);

    final snapshot = filterState.snapshot();
    expect(snapshot.facetGroups, {
      groupAndA: {facetA},
    });
  });

  test('Clear filter group', () {
    final filterState = FilterState()
      ..add(groupAndA, [facetA])
      ..add(groupAndB, [facetA])
      ..clear([groupAndB]);

    final snapshot = filterState.snapshot();
    expect(snapshot.facetGroups, {
      groupAndA: {facetA},
    });
  });

  test('Clear all filter groups', () {
    final filterState = FilterState()
      ..add(groupAndA, [facetA])
      ..add(groupAndB, [facetB])
      ..add(groupAndA, [numeric])
      ..add(groupAndA, [tag])
      ..clear();

    final snapshot = filterState.snapshot();
    expect(snapshot.facetGroups.isEmpty, true);
    expect(snapshot.numericGroups.isEmpty, true);
    expect(snapshot.tagGroups.isEmpty, true);
  });

  test('Clear one filter group', () {
    final filterState = FilterState()
      ..add(groupAndA, [facetA])
      ..add(groupAndB, [facetB])
      ..add(groupAndA, [numeric])
      ..add(groupAndA, [tag])
      ..clear([groupAndB]);

    final snapshot = filterState.snapshot();
    expect(snapshot.facetGroups, {
      groupAndA: {facetA},
    });
    expect(snapshot.numericGroups, {
      groupAndA: {numeric},
    });
    expect(snapshot.tagGroups, {
      groupAndA: {tag},
    });
  });

  test('Clear all except one filter group', () {
    final filterState = FilterState()
      ..add(groupAndA, [facetA])
      ..add(groupAndB, [facetB])
      ..add(groupAndA, [numeric])
      ..add(groupAndA, [tag])
      ..clearExcept([groupAndB]);

    final snapshot = filterState.snapshot();
    expect(snapshot.facetGroups, {
      groupAndB: {facetB},
    });
    expect(snapshot.numericGroups.isEmpty, true);
    expect(snapshot.tagGroups.isEmpty, true);
  });

  test('Filter state to filter groups', () {
    final filterState = FilterState()
      ..add(groupAndA, [facetA])
      ..add(groupAndB, [facetB]);

    final snapshot = filterState.snapshot();
    final filterGroups = snapshot.toFilterGroups();
    expect(filterGroups, {
      FilterGroup.facet(name: attributeA, filters: {facetA}),
      FilterGroup.facet(name: attributeB, filters: {facetB}),
    });
  });

  test('Filter state check contains', () {
    final filterState = FilterState()..add(groupAndA, [facetA]);

    final snapshot = filterState.snapshot();
    expect(snapshot.contains(groupAndA, facetA), true);
    expect(snapshot.contains(groupAndA, facetB), false);
    expect(snapshot.contains(groupAndB, facetA), false);
  });

  test('Filter toggle', () {
    final filterState = FilterState()..toggle(groupAndA, facetA);
    expect(filterState.snapshot().facetGroups, {
      groupAndA: {facetA},
    });

    filterState.toggle(groupAndA, facetA);
    expect(filterState.snapshot().facetGroups.isEmpty, true);
  });

  test('Get filters', () {
    final filterState = FilterState()
      ..add(groupAndA, [facetA])
      ..add(groupAndB, [facetB])
      ..add(groupAndA, [numeric])
      ..add(groupAndA, [tag]);

    final snapshot = filterState.snapshot();
    expect(snapshot.getFilters(), {facetA, facetB, numeric, tag});
  });
}
