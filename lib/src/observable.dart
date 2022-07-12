import 'observer.dart';
import 'subscription.dart';

/// Represents an observable entity.
abstract class Observable {
  final List<Observer> _observers = [];

  Iterable<Observer> get observers => _observers;

  /// Add search operation listener
  Subscription observer(Observer observer) {
    _observers.add(observer);
    return Subscription(this, observer);
  }

  /// Remove a search operation callback
  bool remove(Observer observer) {
    return _observers.remove(observer);
  }

  /// Return true, if this observable is observed by a given observer.
  bool isSubscribed(Observer observer) {
    return _observers.contains(observer);
  }

  /// Remove all search listeners
  void clear() {
    _observers.clear();
  }
}
