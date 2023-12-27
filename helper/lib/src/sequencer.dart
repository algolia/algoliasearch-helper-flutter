import 'dart:async';
import 'dart:collection';

import 'logger.dart';

/// A simple sequencer that ensures that tasks are run in order.
class Sequencer {
  final _operationQueue = Queue<Future<void> Function()>();
  var _isProcessing = false;
  var _isCancelled = false;
  final _log = algoliaLogger('Sequencer');

  /// Adds a task to the queue.
  void addOperation(Future<void> Function() task) {
    if (_isCancelled) return;
    _operationQueue.add(task);
    if (!_isProcessing) {
      _processQueue();
    }
  }

  /// Cancels all pending tasks.
  void cancel() {
    _isCancelled = true;
    _log.finest('cancelling ${_operationQueue.length} pending tasks');
  }

  /// Processes the queue.
  Future<void> _processQueue() async {
    if (_isProcessing) return;
    _isProcessing = true;
    while (_operationQueue.isNotEmpty && !_isCancelled) {
      final operation = _operationQueue.removeFirst();
      await operation();
      if (_isCancelled) {
        _operationQueue.clear();
        break;
      }
    }
    _isProcessing = false;
  }
}
