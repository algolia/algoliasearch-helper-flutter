import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

import 'extensions.dart';

class UserTokenStorage {
  static const _boxName = 'userToken';
  static const _userTokenKey = 'insights-user-token';
  static const _expirationDateKey = 'insights-user-token-expiration-date';

  String _userToken = 'anonymous-${const Uuid().v4()}';

  /// A pseudonymous or anonymous user identifier.
  String get userToken => _userToken;

  set userToken(String userToken) {
    _userToken = userToken;
    if (allowPersistentUserTokenStorage) {
      _write(userToken);
    }
  }

  int _leaseTime = 1440;

  /// Token storage lease time in minutes. Ignored in case of in-memory storage.
  /// Default value is 1440 minutes (1 day)
  int get leaseTime => _leaseTime;

  set leaseTime(int leaseTime) {
    _leaseTime = leaseTime;
    if (allowPersistentUserTokenStorage) {
      _write(userToken);
    }
  }

  Future<Box> get _box => Hive.openBox(_boxName, path: './');
  bool _allowPersistentUserTokenStorage = false;

  /// Determines whether the value is stored in memory or persistent storage.
  /// Default value is 'false'
  bool get allowPersistentUserTokenStorage => _allowPersistentUserTokenStorage;

  set allowPersistentUserTokenStorage(bool isAllowed) {
    _allowPersistentUserTokenStorage = isAllowed;
    if (isAllowed) {
      _write(userToken);
    } else {
      _remove();
    }
  }

  UserTokenStorage() {
    read().then((storedUserToken) {
      if (storedUserToken != null) {
        userToken = storedUserToken;
      }
    });
  }

  void _write(String userToken) {
    final expirationDate =
        DateTime.now().millisecondsSinceEpoch + leaseTime * 60 * 1000;
    _box.then((box) => box
      ..put(_userTokenKey, userToken)
      ..put(_expirationDateKey, expirationDate));
  }

  void _remove() {
    _box.then((box) => box
      ..delete(_userTokenKey)
      ..delete(_leaseTime));
  }

  Future<String?> read() async {
    final box = await _box;
    final storedUserToken = await box.get(_userTokenKey) as String?;
    final storedUserTokenExpirationDate = await box.get(
      _expirationDateKey,
    ) as int?;
    if (storedUserToken != null &&
        storedUserTokenExpirationDate != null &&
        DateTime.now().millisecondsSinceEpoch < storedUserTokenExpirationDate) {
      return storedUserToken;
    }
    return null;
  }
}
