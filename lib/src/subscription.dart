import 'observable.dart';
import 'observer.dart';

/// Represents a relation between an Observer and an Observable.
class Subscription {
  final Observable _observable;
  final Observer _observer;
  bool _subscribed;

  Subscription(this._observable, this._observer)
      : _subscribed = _observable.isSubscribed(_observer);

  bool isUnsubscribed() {
    return !_subscribed;
  }

  void unsubscribe() {
    _observable.remove(_observer);
    _subscribed = false;
  }
}
