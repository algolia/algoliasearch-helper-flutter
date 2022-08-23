import 'package:algolia_helper_dart/algolia.dart';
import 'package:algolia_helper_dart/src/filter_builder.dart';
import 'package:algolia_helper_dart/src/filter_group_converter.dart';
import 'package:test/test.dart';

void main() {
  group('Filter facet SQL', () {
    test('Filter facet Boolean', () {
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

    test('Filter facet Number', () {
      final filterInt = Filter.facet('attributeA', 1);
      final filterDouble = Filter.facet('attributeA', 1.0);
      final filterScore = Filter.facet('attributeA', 1, score: 2);

      const converter = FilterConverter();
      expect(converter.toSQL(filterInt), '\"attributeA\":1');
      expect(converter.toSQL(filterDouble), '\"attributeA\":1.0');
      expect(converter.toSQL(filterDouble.not()), 'NOT \"attributeA\":1.0');
      expect(converter.toSQL(filterScore), '\"attributeA\":1<score=2>');
    });

    test('Filter facet String', () {
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

  test('Filter tag SQL', () {
    final filter = Filter.tag('valueA');
    const converter = FilterConverter();
    expect(converter.toSQL(filter), '_tags:\"valueA\"');
    expect(converter.toSQL(filter.not()), 'NOT _tags:\"valueA\"');
  });

  group('Filter group SQL', () {
    test('Filter group facet AND', () {
      final filterGroups = {
        FilterGroup.facet('groupA', {
          Filter.facet('attributeA', 0),
          Filter.facet('attributeA', 1),
        })
      };
      const converter = FilterGroupConverter();
      expect(
        converter.toSQLUnquoted(filterGroups),
        '(attributeA:0 AND attributeA:1)',
      );
    });

    test('Filter group facet OR', () {
      final filterGroups = {
        FilterGroup.facet(
          'groupA',
          {
            Filter.facet('attributeA', 0),
            Filter.facet('attributeA', 1),
          },
          FilterOperator.or,
        )
      };
      const converter = FilterGroupConverter();
      expect(
        converter.toSQLUnquoted(filterGroups),
        '(attributeA:0 OR attributeA:1)',
      );
    });

    test('Filter group tag OR', () {
      final filterGroups = {
        FilterGroup.tag(
          'groupA',
          {
            Filter.tag('a'),
            Filter.tag('b'),
          },
          FilterOperator.or,
        )
      };
      const converter = FilterGroupConverter();
      expect(converter.toSQLUnquoted(filterGroups), '(_tags:a OR _tags:b)');
    });

    test('Filter group numeric OR', () {
      final filterGroups = {
        FilterGroup.numeric(
          'groupA',
          {
            Filter.range('attributeA', lowerBound: 0, upperBound: 1),
            Filter.comparison('attributeA', NumericOperator.notEquals, 0),
          },
          FilterOperator.or,
        )
      };
      const converter = FilterGroupConverter();
      expect(
        converter.toSQLUnquoted(filterGroups),
        '(attributeA:0 TO 1 OR attributeA != 0)',
      );
    });

    test('Empty groups', () {
      final filterGroups = <FilterGroup<Filter>>{
        FilterGroup.facet(),
        FilterGroup.numeric(),
        FilterGroup.tag(),
      };
      const converter = FilterGroupConverter();
      expect(converter.toSQLUnquoted(filterGroups), null);
    });

    test('Single filter', () {
      final filterGroups = {
        FilterGroup.facet('groupA', {Filter.facet('attributeA', 0)})
      };
      const converter = FilterGroupConverter();
      expect(converter.toSQLUnquoted(filterGroups), '(attributeA:0)');
    });

    test('one of every type', () {
      final filterGroups = <FilterGroup<Filter>>{
        FilterGroup.facet('groupA', {Filter.facet('attributeA', 0)}),
        FilterGroup.facet(
          'groupA',
          {Filter.facet('attributeA', 0)},
          FilterOperator.or,
        ),
        FilterGroup.tag('groupA', {Filter.tag('unknown')}, FilterOperator.or),
        FilterGroup.numeric(
          'groupA',
          {Filter.range('attributeA', lowerBound: 0, upperBound: 1)},
          FilterOperator.or,
        ),
      };
      const converter = FilterGroupConverter();
      expect(
        converter.toSQLUnquoted(filterGroups),
        '(attributeA:0) '
        'AND (attributeA:0) '
        'AND (_tags:unknown) '
        'AND (attributeA:0 TO 1)',
      );
    });

    test('Two of every type', () {
      final filterGroups = <FilterGroup<Filter>>{
        (FacetGroupBuilder()
              ..facet('attributeA', 0)
              ..facet('attributeB', 0))
            .build(),
        (FacetGroupBuilder(operator: FilterOperator.or)
              ..facet('attributeA', 0)
              ..facet('attributeB', 0))
            .build(),
        (TagGroupBuilder(operator: FilterOperator.or)
              ..tag('attributeA')
              ..tag('attributeB'))
            .build(),
        (NumericGroupBuilder(operator: FilterOperator.or)
              ..range('attributeA', lowerBound: 0, upperBound: 1)
              ..comparison('attributeB', NumericOperator.greater, 0))
            .build(),
      };
      const converter = FilterGroupConverter();
      expect(
        converter.toSQLUnquoted(filterGroups),
        '(attributeA:0 AND attributeB:0) AND '
        '(attributeA:0 OR attributeB:0) AND '
        '(_tags:attributeA OR _tags:attributeB) AND '
        '(attributeA:0 TO 1 OR attributeB > 0)',
      );
    });

    test('single And group with different types', () {
      final filterGroups = {
        (MultiFilterGroupBuilder()
              ..facet('attributeA', 0)
              ..tag('unknown'))
            .build()
      };

      const converter = FilterGroupConverter();
      expect(
        converter.toSQLUnquoted(filterGroups),
        '(attributeA:0 AND _tags:unknown)',
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
