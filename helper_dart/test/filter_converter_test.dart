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

    test('Filter Facet String', () {
      final filter = Filter.facet('attributeA', 'valueA');
      final filterNegate = Filter.facet('attributeA', 'valueA').not();
      final filterSpace = Filter.facet('attributeA', 'value with space');
      final filterScore = Filter.facet('attributeA', 'valueA', score: 1);

      const converter = FilterConverter();
      expect(converter.toSQL(filter), '\"attributeA\":\"valueA\"');
      expect(converter.toSQL(filterNegate), 'NOT \"attributeA\":\"valueA\"');
      expect(
        converter.toSQL(filterSpace),
        '\"attributeA\":\"value with space\"',
      );
      expect(
        converter.toSQL(filterScore),
        '\"attributeA\":\"valueA\"<score=1>',
      );
    });
  });

  group('Filter numeric SQL', () {
    test('Filter numeric comparison', () {
      final less = Filter.comparison('attributeA', NumericOperator.less, 5.0);
      final lessOrEquals =
          Filter.comparison('attributeA', NumericOperator.lessOrEquals, 5.0);
      final equals =
          Filter.comparison('attributeA', NumericOperator.equals, 5.0);
      final notEquals =
          Filter.comparison('attributeA', NumericOperator.notEquals, 5.0);
      final greater =
          Filter.comparison('attributeA', NumericOperator.greater, 5.0);
      final greaterOrEquals =
          Filter.comparison('attributeA', NumericOperator.greaterOrEquals, 5.0);

      const converter = FilterConverter();
      expect(converter.toSQL(less), '\"attributeA\" < 5.0');
      expect(converter.toSQL(lessOrEquals), '\"attributeA\" <= 5.0');
      expect(converter.toSQL(equals), '\"attributeA\" = 5.0');
      expect(converter.toSQL(notEquals), '\"attributeA\" != 5.0');
      expect(converter.toSQL(greater), '\"attributeA\" > 5.0');
      expect(converter.toSQL(greaterOrEquals), '\"attributeA\" >= 5.0');
      expect(converter.toSQL(less.not()), 'NOT \"attributeA\" < 5.0');
    });

    test('Filter numeric range', () {
      final filterInt =
          Filter.range('attributeA', lowerBound: 0, upperBound: 6);
      final filterDouble =
          Filter.range('attributeA', lowerBound: 0.0, upperBound: 6.0);

      const converter = FilterConverter();
      expect(converter.toSQL(filterInt), '\"attributeA\":0 TO 6');
      expect(converter.toSQL(filterDouble), '\"attributeA\":0.0 TO 6.0');
      expect(converter.toSQL(filterInt.not()), 'NOT \"attributeA\":0 TO 6');
    });
  });
}
