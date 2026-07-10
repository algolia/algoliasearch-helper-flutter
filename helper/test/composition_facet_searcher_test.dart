import 'dart:async';

import 'package:algolia_helper_flutter/src/exception.dart';
import 'package:algolia_helper_flutter/src/model/composition_facet_search_response.dart';
import 'package:algolia_helper_flutter/src/model/composition_facet_search_state.dart';
import 'package:algolia_helper_flutter/src/model/composition_state.dart';
import 'package:algolia_helper_flutter/src/searcher/composition_facet_searcher.dart';
import 'package:algolia_helper_flutter/src/service/composition_facet_search_service.dart';
import 'package:test/test.dart';

void main() {
  group('Unit tests', () {
    test('Should emit initial response', () async {
      final searchService = _FakeService(
        (_) async => CompositionFacetSearchResponse(const {
          'facetHits': [
            {'value': 'v', 'count': 1},
          ],
        }),
      );
      final searcher = CompositionFacetSearcher.custom(
        searchService,
        _state(),
      );

      await expectLater(
        searcher.responses,
        emits(isA<CompositionFacetSearchResponse>()),
      );
    });

    test('Should emit response after query', () async {
      final searchService = _FakeService(_mockResponse);
      final searcher = CompositionFacetSearcher.custom(
        searchService,
        _state(facetQuery: 'cat'),
      );

      searcher.query('cat');

      await expectLater(searcher.responses, emits(matchesQuery('cat')));
    });

    test('Should emit error after failure', () async {
      final searchService = _FakeService((_) => throw SearchError({}, 500));
      final searcher = CompositionFacetSearcher.custom(searchService, _state());

      searcher.query('cat');

      await expectLater(searcher.responses, emitsError(isA<SearchError>()));
    });

    test('Should debounce search state', () async {
      final searchService = _FakeService(_mockResponse);
      final searcher = CompositionFacetSearcher.custom(searchService, _state());

      unawaited(
        expectLater(
          searcher.responses,
          emitsInOrder([emits(matchesQuery('cat'))]),
        ),
      );

      searcher
        ..query('c')
        ..query('ca')
        ..query('cat');
    });

    test('Should rerun requests', () async {
      final searchService = _FakeService(_mockResponse);
      final searcher = CompositionFacetSearcher.custom(searchService, _state());

      unawaited(
        expectLater(
          searcher.responses,
          emitsInOrder([
            emits(matchesQuery('cat')),
            emits(matchesQuery('cat')),
          ]),
        ),
      );

      searcher.query('cat');
      await delay();
      searcher.query('cat'); // should be ignored
      await delay();
      searcher.rerun();
      await delay();
    });
  });
}

CompositionFacetSearchState _state({String facetQuery = ''}) =>
    CompositionFacetSearchState(
      compositionID: 'myComposition',
      facet: 'brand',
      facetQuery: facetQuery,
      state: const CompositionState(compositionID: 'myComposition'),
    );

Future<CompositionFacetSearchResponse> _mockResponse(
  CompositionFacetSearchState state,
) async {
  await delay(100);
  return CompositionFacetSearchResponse({
    'query': state.facetQuery,
    'exhaustiveFacetsCount': true,
    'facetHits': [
      {'value': 'facet1', 'count': 5},
      {'value': 'facet2', 'count': 10},
    ],
  });
}

/// Return future with a delay
Future delay([int millis = 500]) =>
    Future.delayed(Duration(milliseconds: millis), () {});

/// Matches a [CompositionFacetSearchResponse] with a given [query].
TypeMatcher<CompositionFacetSearchResponse> matchesQuery(String query) =>
    isA<CompositionFacetSearchResponse>().having(
      (res) => res.raw['query'],
      'query',
      matches(query),
    );

class _FakeService implements CompositionFacetSearchService {
  _FakeService(this._handler);

  final FutureOr<CompositionFacetSearchResponse> Function(
    CompositionFacetSearchState state,
  ) _handler;

  @override
  Future<CompositionFacetSearchResponse> search(
    CompositionFacetSearchState state,
  ) async =>
      _handler(state);
}
