import 'dart:async';

import 'package:algolia_insights/algolia_insights.dart';
import 'package:rxdart/rxdart.dart';

import '../../algolia_helper.dart';
import '../multi_search_state_provider.dart';
import '../service/algolia_multi_search_service.dart';
import '../service/multi_search_service.dart';
import '../service/proxy_facet_search_service.dart';
import '../service/proxy_hits_search_service.dart';
import '../service/proxy_multi_search_service.dart';

class MultiSearcher implements Disposable {
  final MultiSearchService _service;
  final EventTracker _eventTracker;
  List<MultiSearchStateProvider> stateProviders;
  final List<ProxyMultiSearchService> _services;
  StreamSubscription<List<MultiSearchResponse>>? _resultsSubscription;
  bool _isDisposed = false;

  MultiSearcher(this._service, this._eventTracker)
      : stateProviders = [],
        _services = [];

  MultiSearcher.algolia(
    String applicationID,
    String apiKey, {
    EventTracker? eventTracker,
  })  : _service = AlgoliaMultiSearchService(applicationID, apiKey),
        _eventTracker = eventTracker ?? Insights(applicationID, apiKey),
        stateProviders = [],
        _services = [];

  /// Adds a new [HitsSearcher] to the multi-searcher.
  HitsSearcher addHitsSearcher({
    required SearchState initialState,
    bool disjunctiveFacetingEnabled = true,
  }) {
    final service = ProxyHitsSearchService();
    final searcher = HitsSearcher.custom(service, _eventTracker, initialState);
    stateProviders.add(searcher);
    _services.add(service);
    _updateSubscriptions();
    return searcher;
  }

  /// Adds a new [FacetSearcher] to the multi-searcher.
  FacetSearcher addFacetSearcher({
    required SearchState state,
    required String facet,
    String facetQuery = '',
    int maxFacetHits = 10,
  }) {
    final service = ProxyFacetSearchService();
    final searcher = FacetSearcher.custom(
      service,
      FacetSearchState(
        searchState: state,
        facet: facet,
        facetQuery: facetQuery,
      ),
    );
    stateProviders.add(searcher);
    _services.add(service);
    _updateSubscriptions();
    return searcher;
  }

  void _updateSubscriptions() {
    _resultsSubscription?.cancel();
    _resultsSubscription = Rx.combineLatest(
      stateProviders.map((e) => e.multiSearchState),
      (states) => states.cast<MultiSearchState>(),
    )
        .debounceTime(
          const Duration(milliseconds: 100),
        )
        .asyncMap(_service.search)
        .listen((responses) {
      for (var i = 0; i < responses.length; i++) {
        _services[i].updateMultiResponse(responses[i]);
      }
    });
  }

  @override
  void dispose() {
    _resultsSubscription?.cancel();
    _isDisposed = true;
    for (var service in _services) {
      service.dispose();
    }
  }

  @override
  bool get isDisposed => _isDisposed;
}
