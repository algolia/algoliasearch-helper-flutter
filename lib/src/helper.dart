import 'dart:async';

import 'package:algolia/algolia.dart';

import 'listener.dart';

class AlgoliaHelper {
  AlgoliaHelper(this.client, this.indexName) : _query = client.index(indexName);

  /// Inner Algolia API client.
  final Algolia client;

  /// Index name.
  final String indexName;

  /// List of search operation listeners
  final List<Listener> _listeners = [];

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
  Listener on(
      {Function(AlgoliaQuerySnapshot response)? onResult,
      Function(AlgoliaError error)? onError}) {
    final listener = Listener(onResult: onResult, onError: onError);
    return this.listener(listener);
  }

  /// Add search operation listener
  Listener listener(Listener listener) {
    _listeners.add(listener);
    return listener;
  }

  /// Remove a search operation callback
  bool remove(Listener listener) {
    return _listeners.remove(listener);
  }

  /// Remove all search listeners
  void clear() {
    _listeners.clear();
  }

  /// Run search operation.
  /// Listeners will be notified on result/error.
  void search() {
    Future<AlgoliaQuerySnapshot> objects = _query.getObjects();
    _setSearchListeners(objects);
  }

  void _setSearchListeners(Future<AlgoliaQuerySnapshot> call) {
    for (var listener in _listeners) {
      call
          .then((value) => listener.onResult?.call(value))
          .catchError((error) => listener.onError?.call(error));
    }
  }
}
