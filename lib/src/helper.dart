import 'package:algolia/algolia.dart';
import 'package:algolia_helper/src/future.dart';
import 'package:algolia_helper/src/subscription.dart';

import 'observable.dart';
import 'observer.dart';

class AlgoliaHelper extends Observable {
  AlgoliaHelper(this.client, this.indexName) : _query = client.index(indexName);

  /// Inner Algolia API client.
  final Algolia client;

  /// Index name.
  final String indexName;

  AlgoliaQuery _query;

  /// AlgoliaHelper's factory.
  factory AlgoliaHelper.create(
      {required String applicationID,
      required String apiKey,
      required String indexName,
      AlgoliaQuery Function(AlgoliaQuery)? config}) {
    final client = Algolia.init(applicationId: applicationID, apiKey: apiKey);
    var algoliaHelper = AlgoliaHelper(client, indexName);
    if (config != null) algoliaHelper.config((query) => config(query));
    return algoliaHelper;
  }

  /// Set query string.
  void query(String query) {
    _query = _query.query(query);
  }

  /// Set query configuration.
  void config(AlgoliaQuery Function(AlgoliaQuery query) config) {
    _query = config(_query);
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
    _query.getObjects().subscribe(observers);
  }
}
