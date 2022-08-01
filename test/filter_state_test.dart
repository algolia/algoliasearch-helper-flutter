import 'package:algolia_helper/algolia_helper.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('FilterState add facet', () {
    final filterState = FilterState();

    final groupA = groupAnd("GroupA");
    filterState.add(groupA, [Filter.facet("Category", "A")]);
    filterState.add(groupA, [Filter.facet("Category", "A")]);
    filterState.add(groupA, [Filter.facet("Category", "B")]);

    final snapshot = filterState.snapshot();
    expect(snapshot.facetGroups.containsKey(groupA), true);
    expect(snapshot.facetGroups[groupA]!.length, 2);
    expect(snapshot.tagGroups.isEmpty, true);
    expect(snapshot.numericGroups.isEmpty, true);
    expect(snapshot.hierarchicalGroups.isEmpty, true);
  });
}
