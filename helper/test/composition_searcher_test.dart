import 'dart:async';

import 'package:algolia_helper_flutter/src/exception.dart';
import 'package:algolia_helper_flutter/src/filter.dart';
import 'package:algolia_helper_flutter/src/filter_group.dart';
import 'package:algolia_helper_flutter/src/filter_state.dart';
import 'package:algolia_helper_flutter/src/model/composition_response.dart';
import 'package:algolia_helper_flutter/src/model/composition_state.dart';
import 'package:algolia_helper_flutter/src/searcher/composition_searcher.dart';
import 'package:algolia_helper_flutter/src/service/composition_search_service.dart';
import 'package:algolia_insights/algolia_insights.dart';
import 'package:test/test.dart';

void main() {
  group('Unit tests', () {
    test('Should emit initial response', () async {
      final searchService = _FakeCompositionSearchService(
        (_) async => CompositionResponse(const {}),
      );
      final searcher = CompositionSearcher.custom(
        searchService,
        null,
        const CompositionState(compositionID: 'myComposition'),
      );

      await expectLater(
        searcher.responses,
        emits(isA<CompositionResponse>()),
      );
    });

    test('Should emit response after query', () async {
      final searchService = _FakeCompositionSearchService(_mockResponse);
      final searcher = CompositionSearcher.custom(
        searchService,
        null,
        const CompositionState(compositionID: 'myComposition'),
      );

      searcher.query('cat');

      await expectLater(searcher.responses, emits(matchesQuery('cat')));
    });

    test('Should emit error after failure', () async {
      final searchService = _FakeCompositionSearchService(
        (_) => throw SearchError({}, 500),
      );
      final searcher = CompositionSearcher.custom(
        searchService,
        null,
        const CompositionState(compositionID: 'myComposition'),
      );

      searcher.query('cat');

      await expectLater(searcher.responses, emitsError(isA<SearchError>()));
    });

    test('Should debounce search state', () async {
      final searchService = _FakeCompositionSearchService(_mockResponse);
      final searcher = CompositionSearcher.custom(
        searchService,
        null,
        const CompositionState(compositionID: 'myComposition'),
      );

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

    test("Shouldn't debounce search state", () async {
      final searchService = _FakeCompositionSearchService(_mockResponse);
      final searcher = CompositionSearcher.custom(
        searchService,
        null,
        const CompositionState(compositionID: 'myComposition'),
      );

      unawaited(
        expectLater(
          searcher.responses,
          emitsInOrder([
            emits(matchesQuery('c')),
            emits(matchesQuery('ca')),
            emits(matchesQuery('cat')),
          ]),
        ),
      );

      searcher.query('c');
      await delay();
      searcher.query('ca');
      await delay();
      searcher.query('cat');
      await delay();
      searcher.dispose();
    });

    test('Should discard old requests', () async {
      final searchService = _FakeCompositionSearchService(_mockResponse);
      final searcher = CompositionSearcher.custom(
        searchService,
        null,
        const CompositionState(compositionID: 'myComposition'),
      );

      unawaited(
        expectLater(
          searcher.responses,
          emitsInOrder([emits(matchesQuery('cat'))]),
        ),
      );

      searcher.query('c');
      await delay(50);
      searcher.query('ca');
      await delay(50);
      searcher.query('cat');
      await delay(50);
    });

    test('Should rerun requests', () async {
      final searchService = _FakeCompositionSearchService(_mockResponse);
      final searcher = CompositionSearcher.custom(
        searchService,
        null,
        const CompositionState(compositionID: 'myComposition'),
      );

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

  test('FilterState connect CompositionSearcher', () async {
    final searchService = _FakeCompositionSearchService(_mockResponse);
    const initState = CompositionState(compositionID: 'myComposition');
    final searcher = CompositionSearcher.custom(searchService, null, initState);

    final groupColors = FilterGroupID.and('colors');
    final facetColorRed = Filter.facet('color', 'red');
    final filterState = FilterState()..add(groupColors, {facetColorRed});

    searcher.connectFilterState(filterState);
    await delay();

    final updated = initState.copyWith(
      filterGroups: {
        FacetFilterGroup(groupColors, {facetColorRed}),
      },
    );
    expect(searcher.snapshot(), updated);

    searcher.dispose();
  });

  group('Insights', () {
    test('Passes received hits to event tracker', () async {
      final searchService = _FakeCompositionSearchService(_mockResponse);
      final eventTracker = _RecordingEventTracker();
      final searcher = CompositionSearcher.custom(
        searchService,
        eventTracker,
        const CompositionState(compositionID: 'myComposition'),
      )..query('q');

      await delay();

      expect(eventTracker.viewed, isNotEmpty);
      expect(eventTracker.viewed.last['eventName'], 'Hits Viewed');
      expect(eventTracker.viewed.last['objectIDs'], ['h1', 'h2']);

      searcher.dispose();
    });

    test('Uses response index name and queryID for click events', () async {
      final searchService = _FakeCompositionSearchService(_mockResponse);
      final eventTracker = _RecordingEventTracker();
      final searcher = CompositionSearcher.custom(
        searchService,
        eventTracker,
        const CompositionState(compositionID: 'myComposition'),
      )..query('q');

      await expectLater(searcher.responses, emits(matchesQuery('q')));

      searcher.eventTracker?.clickedObjects(
        eventName: 'Product Clicked',
        objectIDs: const ['h1'],
        positions: const [1],
      );

      expect(eventTracker.clickedAfterSearch, isNotEmpty);
      expect(
        eventTracker.clickedAfterSearch.last['indexName'],
        'products-index',
      );
      expect(eventTracker.clickedAfterSearch.last['queryID'], '123');

      searcher.dispose();
    });
  });
}

Future<CompositionResponse> _mockResponse(CompositionState state) async {
  await delay(100);
  return CompositionResponse({
    'query': state.query,
    'index': 'products-index',
    'hits': [
      {'objectID': 'h1'},
      {'objectID': 'h2'},
    ],
    'queryID': '123',
    'nbHits': 2,
  });
}

/// Return future with a delay
Future delay([int millis = 500]) =>
    Future.delayed(Duration(milliseconds: millis), () {});

/// Matches a [CompositionResponse] with a given [query].
TypeMatcher<CompositionResponse> matchesQuery(String query) =>
    isA<CompositionResponse>().having((res) => res.query, 'query', query);

class _FakeCompositionSearchService implements CompositionSearchService {
  _FakeCompositionSearchService(this._handler);

  final FutureOr<CompositionResponse> Function(CompositionState state) _handler;

  @override
  Future<CompositionResponse> search(CompositionState state) async =>
      _handler(state);
}

class _RecordingEventTracker implements EventTracker {
  final List<Map<String, dynamic>> viewed = [];
  final List<Map<String, dynamic>> clicked = [];
  final List<Map<String, dynamic>> clickedAfterSearch = [];

  @override
  bool get isEnabled => true;

  @override
  void viewedObjects({
    required String indexName,
    required String eventName,
    required List<String> objectIDs,
    DateTime? timestamp,
  }) {
    viewed.add({
      'indexName': indexName,
      'eventName': eventName,
      'objectIDs': objectIDs,
    });
  }

  @override
  void clickedObjects({
    required String indexName,
    required String eventName,
    required Iterable<String> objectIDs,
    DateTime? timestamp,
  }) {
    clicked.add({
      'indexName': indexName,
      'eventName': eventName,
      'objectIDs': objectIDs.toList(),
    });
  }

  @override
  void clickedObjectsAfterSearch({
    required String indexName,
    required String eventName,
    required String queryID,
    required Iterable<String> objectIDs,
    required Iterable<int> positions,
    DateTime? timestamp,
  }) {
    clickedAfterSearch.add({
      'indexName': indexName,
      'eventName': eventName,
      'queryID': queryID,
      'objectIDs': objectIDs.toList(),
      'positions': positions.toList(),
    });
  }

  @override
  void convertedObjects({
    required String indexName,
    required String eventName,
    required Iterable<String> objectIDs,
    DateTime? timestamp,
  }) {}

  @override
  void convertedObjectsAfterSearch({
    required String indexName,
    required String eventName,
    required String queryID,
    required Iterable<String> objectIDs,
    DateTime? timestamp,
  }) {}

  @override
  void clickedFilters({
    required String indexName,
    required String eventName,
    required String attribute,
    required List<String> values,
    DateTime? timestamp,
  }) {}

  @override
  void viewedFilters({
    required String indexName,
    required String eventName,
    required String attribute,
    required List<String> values,
    DateTime? timestamp,
  }) {}

  @override
  void convertedFilters({
    required String indexName,
    required String eventName,
    required String attribute,
    required List<String> values,
    DateTime? timestamp,
  }) {}
}
