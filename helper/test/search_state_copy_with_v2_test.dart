import 'package:algolia_helper_flutter/src/model/multi_search_state.dart';
// `search_state.dart` is a part of `multi_search_state.dart`; import the
// containing library instead.
import 'package:test/test.dart';

void main() {
  group('SearchState.copyWithV2', () {
    test('keeps existing values when omitted and changes when provided', () {
      const init = SearchState(indexName: 'index', query: 'q');
      final changed = init.copyWithV2(query: 'q2');
      expect(changed.indexName, 'index');
      expect(changed.query, 'q2');
    });

    test('explicitly sets nullable to null', () {
      final init = SearchState(indexName: 'index', facetFilters: ['a']);
      final updated = init.copyWithV2(facetFilters: null);
      expect(updated.facetFilters, isNull);
      // Other values unchanged
      expect(updated.indexName, 'index');
    });

    test('omitting param preserves old value', () {
      final init = SearchState(indexName: 'index', facetFilters: ['a']);
      final updated = init.copyWithV2();
      expect(updated.facetFilters, ['a']);
      expect(updated.indexName, 'index');
    });
  });
}
