import 'package:algolia_helper_dart/algolia.dart';
import 'package:algolia_helper_dart/src/filter_group_converter.dart';
import 'package:test/test.dart';

void main() {
  group('Filter Facet SQL', () {
    test('Filter Facet Boolean', () {
      final filterTrue = Filter.facet('attributeA', true);
      final filterFalse = Filter.facet('attributeA', false);
      final filterScore = Filter.facet('attributeA', true, score: 4);

      const converter = FilterConverter();
      expect(converter.toSQL(filterTrue), '\"attributeA\":true');
      expect(converter.toSQL(filterFalse), '\"attributeA\":false');
      expect(converter.toSQL(filterTrue.not()), 'NOT \"attributeA\":true');
      expect(converter.toSQL(filterFalse.not()), 'NOT \"attributeA\":false');
      expect(converter.toSQL(filterScore), '\"attributeA\":true<score=4>');
    });

    test('Filter Facet Number', () {
      final filterInt = Filter.facet('attributeA', 1);
      final filterDouble = Filter.facet('attributeA', 1.0);
      final filterScore = Filter.facet('attributeA', 1, score: 2);

      const converter = FilterConverter();
      expect(converter.toSQL(filterInt), '\"attributeA\":1');
      expect(converter.toSQL(filterDouble), '\"attributeA\":1.0');
      expect(converter.toSQL(filterDouble.not()), 'NOT \"attributeA\":1.0');
      expect(converter.toSQL(filterScore), '\"attributeA\":1<score=2>');
    });
  });
}
