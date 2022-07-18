import 'package:algolia/algolia.dart';

import 'algolia_search.dart';
import 'extensions.dart';
import 'observable.dart';
import 'observer.dart';
import 'search_state.dart';
import 'subscription.dart';

class AlgoliaHelper extends Observable {
  AlgoliaHelper(this.client, this.indexName);

  /// Inner Algolia API client.
  final Algolia client;

  /// Index name.
  final String indexName;

  /// Search internal state
  SearchState _state = const SearchState();

  /// AlgoliaHelper's factory.
  factory AlgoliaHelper.create(
      {required String applicationID,
      required String apiKey,
      required String indexName}) {
    final client = Algolia.init(applicationId: applicationID, apiKey: apiKey);
    return AlgoliaHelper(client, indexName);
  }

  /// Set query string.
  void query(String query) {
    _state = _state.copyWith(query: query);
  }

  /// Set search page.
  void setPage(int page) {
    _state = _state.copyWith(page: page);
  }

  /// Set hits per search page.
  void setHitPerPage(int page) {
    _state = _state.copyWith(page: page);
  }

  /// Set search facets.
  void setFacets(List<String> facets) {
    _state = _state.copyWith(facets: facets);
  }

  /// Add a search operation callback
  Subscription on(
      {Function(AlgoliaQuerySnapshot response)? onResult,
      Function(AlgoliaError error)? onError,
      Function? onComplete}) {
    final obs =
        Observer(onNext: onResult, onError: onError, onComplete: onComplete);
    return observer(obs);
  }

  /// Run search operation.
  /// Listeners will be notified on result/error.
  void search() {
    client.index(indexName).queryOf(_state).getObjects().subscribe(observers);
  }
}
