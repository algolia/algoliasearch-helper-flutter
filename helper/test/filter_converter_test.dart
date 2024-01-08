import 'package:algolia_helper_flutter/algolia_helper_flutter.dart';
import 'package:algolia_helper_flutter/src/filter_group_converter.dart';
import 'package:test/test.dart';

void main() {
  group('Filter facet SQL', () {
    test('Filter facet Boolean', () {
      final filterTrue = Filter.facet('attributeA', true);
      final filterFalse = Filter.facet('attributeA', false);
      final filterScore = Filter.facet('attributeA', true, score: 4);

      const converter = FilterConverter();
      expect(converter.sql(filterTrue), '\"attributeA\":true');
      expect(converter.sql(filterFalse), '\"attributeA\":false');
      expect(converter.sql(filterTrue.not()), 'NOT \"attributeA\":true');
      expect(converter.sql(filterFalse.not()), 'NOT \"attributeA\":false');
      expect(converter.sql(filterScore), '\"attributeA\":true<score=4>');
    });

    test('Filter facet Number', () {
      final filterInt = Filter.facet('attributeA', 1);
      final filterDouble = Filter.facet('attributeA', 1.0);
      final filterScore = Filter.facet('attributeA', 1, score: 2);

      const converter = FilterConverter();
      expect(converter.sql(filterInt), '\"attributeA\":1');
      expect(converter.sql(filterDouble), '\"attributeA\":${1.0}');
      expect(converter.sql(filterDouble.not()), 'NOT \"attributeA\":${1.0}');
      expect(converter.sql(filterScore), '\"attributeA\":1<score=2>');
      expect(converter.sql(filterScore), '\"attributeA\":1<score=2>');
    });

    test('Filter facet String', () {
      final filter = Filter.facet('attributeA', 'valueA');
      final filterNegate = Filter.facet('attributeA', 'valueA').not();
      final filterSpace = Filter.facet('attributeA', 'value with space');
      final filterScore = Filter.facet('attributeA', 'valueA', score: 1);

      const converter = FilterConverter();
      expect(converter.sql(filter), '\"attributeA\":\"valueA\"');
      expect(converter.sql(filterNegate), 'NOT \"attributeA\":\"valueA\"');
      expect(
        converter.sql(filterSpace),
        '\"attributeA\":\"value with space\"',
      );
      expect(
        converter.sql(filterScore),
        '\"attributeA\":\"valueA\"<score=1>',
      );
    });
  });

  group('Filter numeric SQL', () {
    test('Filter numeric comparison', () {
      final less = Filter.comparison('attributeA', NumericOperator.less, 5);
      final lessOrEquals =
          Filter.comparison('attributeA', NumericOperator.lessOrEquals, 5);
      final equals = Filter.comparison('attributeA', NumericOperator.equals, 5);
      final notEquals =
          Filter.comparison('attributeA', NumericOperator.notEquals, 5);
      final greater =
          Filter.comparison('attributeA', NumericOperator.greater, 5);
      final greaterOrEquals =
          Filter.comparison('attributeA', NumericOperator.greaterOrEquals, 5);

      const converter = FilterConverter();
      expect(converter.sql(less), '\"attributeA\" < 5');
      expect(converter.sql(lessOrEquals), '\"attributeA\" <= 5');
      expect(converter.sql(equals), '\"attributeA\" = 5');
      expect(converter.sql(notEquals), '\"attributeA\" != 5');
      expect(converter.sql(greater), '\"attributeA\" > 5');
      expect(converter.sql(greaterOrEquals), '\"attributeA\" >= 5');
      expect(converter.sql(less.not()), 'NOT \"attributeA\" < 5');
    });

    test('Filter numeric range', () {
      final filterInt =
          Filter.range('attributeA', lowerBound: 0, upperBound: 6);
      final filterDouble =
          Filter.range('attributeA', lowerBound: 0.0, upperBound: 6.0);

      const converter = FilterConverter();
      expect(converter.sql(filterInt), '\"attributeA\":0 TO 6');
      expect(converter.sql(filterDouble), '\"attributeA\":${0.0} TO ${6.0}');
      expect(converter.sql(filterInt.not()), 'NOT \"attributeA\":0 TO 6');
    });
  });

  test('Filter tag SQL', () {
    final filter = Filter.tag('valueA');
    const converter = FilterConverter();
    expect(converter.sql(filter), '_tags:\"valueA\"');
    expect(converter.sql(filter.not()), 'NOT _tags:\"valueA\"');
  });

  group('Filter group SQL', () {
    test('Filter group facet AND', () {
      final filterGroups = {
        FilterGroup.facet(
          filters: {
            Filter.facet('attributeA', 0),
            Filter.facet('attributeA', 1),
          },
        ),
      };

      const converter = FilterGroupConverter();
      expect(
        converter.unquoted(filterGroups),
        '(attributeA:0 AND attributeA:1)',
      );
    });

    test('Filter group facet OR', () {
      final filterGroups = {
        FilterGroup.facet(
          operator: FilterOperator.or,
          filters: {
            Filter.facet('attributeA', 0),
            Filter.facet('attributeA', 1),
          },
        ),
      };

      const converter = FilterGroupConverter();
      expect(
        converter.unquoted(filterGroups),
        '(attributeA:0 OR attributeA:1)',
      );
    });

    test('Filter group tag OR', () {
      final filterGroups = {
        FilterGroup.tag(
          operator: FilterOperator.or,
          filters: {
            Filter.tag('a'),
            Filter.tag('b'),
          },
        ),
      };
      const converter = FilterGroupConverter();
      expect(converter.unquoted(filterGroups), '(_tags:a OR _tags:b)');
    });

    test('Filter group numeric OR', () {
      final filterGroups = {
        FilterGroup.numeric(
          operator: FilterOperator.or,
          filters: {
            Filter.range('attributeA', lowerBound: 0, upperBound: 1),
            Filter.comparison('attributeA', NumericOperator.notEquals, 0),
          },
        ),
      };
      const converter = FilterGroupConverter();
      expect(
        converter.unquoted(filterGroups),
        '(attributeA:0 TO 1 OR attributeA != 0)',
      );
    });

    test('Empty groups', () {
      final filterGroups = <FilterGroup<Filter>>{
        FilterGroup.facet(filters: const {}),
        FilterGroup.numeric(filters: const {}),
        FilterGroup.tag(filters: const {}),
      };
      const converter = FilterGroupConverter();
      expect(converter.unquoted(filterGroups), null);
    });

    test('Single filter', () {
      final filterGroups = {
        FilterGroup.facet(filters: {Filter.facet('attributeA', 0)}),
      };
      const converter = FilterGroupConverter();
      expect(converter.unquoted(filterGroups), '(attributeA:0)');
    });

    test('one of every type', () {
      final filterGroups = <FilterGroup<Filter>>{
        FilterGroup.facet(filters: {Filter.facet('attributeA', 0)}),
        FilterGroup.facet(
          operator: FilterOperator.or,
          filters: {Filter.facet('attributeA', 0)},
        ),
        FilterGroup.tag(
          operator: FilterOperator.or,
          filters: {Filter.tag('unknown')},
        ),
        FilterGroup.numeric(
          operator: FilterOperator.or,
          filters: {Filter.range('attributeA', lowerBound: 0, upperBound: 1)},
        ),
      };
      const converter = FilterGroupConverter();
      expect(
        converter.unquoted(filterGroups),
        '(attributeA:0) '
        'AND (attributeA:0) '
        'AND (_tags:unknown) '
        'AND (attributeA:0 TO 1)',
      );
    });

    test('Two of every type', () {
      final filterGroups = <FilterGroup<Filter>>{
        FilterGroup.facet(
          filters: {
            Filter.facet('attributeA', 0),
            Filter.facet('attributeB', 0),
          },
        ),
        FilterGroup.facet(
          operator: FilterOperator.or,
          filters: {
            Filter.facet('attributeA', 0),
            Filter.facet('attributeB', 0),
          },
        ),
        FilterGroup.tag(
          operator: FilterOperator.or,
          filters: {Filter.tag('attributeA'), Filter.tag('attributeB')},
        ),
        FilterGroup.numeric(
          operator: FilterOperator.or,
          filters: {
            Filter.range('attributeA', lowerBound: 0, upperBound: 1),
            Filter.comparison('attributeB', NumericOperator.greater, 0),
          },
        ),
      };
      const converter = FilterGroupConverter();
      expect(
        converter.unquoted(filterGroups),
        '(attributeA:0 AND attributeB:0) AND '
        '(attributeA:0 OR attributeB:0) AND '
        '(_tags:attributeA OR _tags:attributeB) AND '
        '(attributeA:0 TO 1 OR attributeB > 0)',
      );
    });

    test('Two AND balanced groups of the same type', () {
      final filterGroups = {
        FilterGroup.tag(
          operator: FilterOperator.or,
          filters: {
            Filter.tag('attributeA'),
            Filter.tag('attributeB'),
          },
        ),
        FilterGroup.tag(
          operator: FilterOperator.or,
          filters: {
            Filter.tag('attributeA'),
            Filter.tag('attributeB'),
          },
        ),
      };

      const converter = FilterGroupConverter();
      expect(
        converter.unquoted(filterGroups),
        '(_tags:attributeA OR _tags:attributeB)',
      );
    });

    test('Two AND balanced groups of the different types', () {
      final filterGroups = <FilterGroup<Filter>>{
        FilterGroup.tag(
          operator: FilterOperator.or,
          filters: {
            Filter.tag('attributeA'),
            Filter.tag('attributeB'),
          },
        ),
        FilterGroup.numeric(
          operator: FilterOperator.or,
          filters: {
            Filter.range('attributeA', lowerBound: 0, upperBound: 1),
            Filter.range('attributeB', lowerBound: 0, upperBound: 1),
          },
        ),
      };

      const converter = FilterGroupConverter();
      expect(
        converter.unquoted(filterGroups),
        '(_tags:attributeA OR _tags:attributeB)'
        ' AND (attributeA:0 TO 1 OR attributeB:0 TO 1)',
      );
    });

    test('Two AND unbalanced groups of the same type', () {
      final filterGroups = {
        FilterGroup.tag(
          operator: FilterOperator.or,
          filters: {
            Filter.tag('attributeA'),
          },
        ),
        FilterGroup.tag(
          operator: FilterOperator.or,
          filters: {
            Filter.tag('attributeA'),
            Filter.tag('attributeB'),
          },
        ),
      };

      const converter = FilterGroupConverter();
      expect(
        converter.unquoted(filterGroups),
        '(_tags:attributeA) AND (_tags:attributeA OR _tags:attributeB)',
      );
    });

    test('Two AND unbalanced groups of the different types', () {
      final filterGroups = <FilterGroup<Filter>>{
        FilterGroup.tag(
          operator: FilterOperator.or,
          filters: {
            Filter.tag('attributeA'),
            Filter.tag('attributeB'),
          },
        ),
        FilterGroup.numeric(
          operator: FilterOperator.or,
          filters: {
            Filter.range('attributeA', lowerBound: 0, upperBound: 1),
          },
        ),
      };

      const converter = FilterGroupConverter();
      expect(
        converter.unquoted(filterGroups),
        '(_tags:attributeA OR _tags:attributeB) AND (attributeA:0 TO 1)',
      );
    });
  });

  test('Numeric operator symbols', () {
    expect(NumericOperator.less.operator, '<');
    expect(NumericOperator.lessOrEquals.operator, '<=');
    expect(NumericOperator.equals.operator, '=');
    expect(NumericOperator.notEquals.operator, '!=');
    expect(NumericOperator.greaterOrEquals.operator, '>=');
    expect(NumericOperator.greater.operator, '>');
  });
}
