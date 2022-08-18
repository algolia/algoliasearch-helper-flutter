import 'package:algolia_helper_dart/algolia.dart';
import 'package:test/test.dart';

void main() {
  const attributeA = 'nameA';
  const attributeB = 'nameB';
  const groupAndA = FilterGroupID(attributeA);
  const groupAndB = FilterGroupID(attributeB);
  const groupOrA = FilterGroupID(attributeA, FilterOperator.or);
  final facetA = Filter.facet(attributeA, 0);
  final facetB = Filter.facet(attributeB, 0);
  final tag = Filter.tag('0');
  final numeric = Filter.range(attributeA, 0, 10);

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
      groupAndA: {facetA, facetB}
    });
  });

  test('Add to different groups', () {
    final filterState = FilterState()
      ..add(groupAndA, [facetA])
      ..add(groupAndB, [facetA]);

    final snapshot = filterState.snapshot();
    expect(snapshot.getGroups(), {
      groupAndA: {facetA},
      groupAndB: {facetA}
    });
  });

  test('Add different types to the same group', () {
    final filterState = FilterState()
      ..add(groupAndA, [facetA])
      ..add(groupAndA, [numeric]);

    final snapshot = filterState.snapshot();
    expect(snapshot.facetGroups, {
      groupAndA: {facetA}
    });
    expect(snapshot.numericGroups, {
      groupAndA: {numeric}
    });
  });

  test('Add different types to different groups', () {
    final filterState = FilterState()
      ..add(groupAndA, [facetA])
      ..add(groupAndB, [numeric]);

    final snapshot = filterState.snapshot();
    expect(snapshot.facetGroups, {
      groupAndA: {facetA}
    });
    expect(snapshot.numericGroups, {
      groupAndB: {numeric}
    });
  });
}
