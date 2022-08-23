import 'package:algolia_helper_dart/algolia.dart';
import 'package:algolia_helper_dart/src/filter_group_converter.dart';
import 'package:test/test.dart';

void main() {
  group('Filter Facet SQL', () {
    final filterTrue = Filter.facet('attributeA', true);
    final filterFalse = Filter.facet('attributeA', false);
    final filterScore = Filter.facet('attributeA', true, score: 4);

    test('Filter Facet Boolean', () {
      const converter = FilterConverter();
      expect(converter.toSQL(filterTrue), '\"attributeA\":true');
      expect(converter.toSQL(filterFalse), '\"attributeA\":false');
      expect(converter.toSQL(filterTrue.not()), 'NOT \"attributeA\":true');
      expect(converter.toSQL(filterFalse.not()), 'NOT \"attributeA\":false');
      expect(converter.toSQL(filterScore), '\"attributeA\":true<score=4>');
    });
  });
}
