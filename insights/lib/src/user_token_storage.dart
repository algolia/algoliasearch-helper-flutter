import 'package:hive/hive.dart';
import 'package:logging/logging.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import 'platform_web.dart' if (dart.library.io) 'platform_native.dart';

class UserTokenStorage {
  static const _userTokenKey = 'insights-user-token';
  static const _expirationDateKey = 'insights-user-token-expiration-date';

  /// Private value storing the actual value of the user-token
  /// lease time.
  String _userToken = 'anonymous-${const Uuid().v4()}';

  /// A pseudonymous or anonymous user identifier.
  String get userToken => _userToken;

  /// Events logger
  final Logger _log = Logger('Algolia/UserTokenStorage');

  set userToken(String userToken) {
    _userToken = userToken;
    if (allowPersistentUserTokenStorage) {
      _write(userToken);
    }
  }

  /// Private value storing the actual value of the user-token lease time in
  /// the persistent storage.
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

  String? _boxPath;
  String _boxName = 'user-token';

  /// Box value persistently storing the user token and its lease time
  Future<Box> get _box async {
    final String path;
    if (_boxPath != null) {
      path = _boxPath!;
    } else if (isWeb) {
      path = 'algolia';
    } else {
      final docsDir = await getApplicationDocumentsDirectory();
      path = '${docsDir.path}/algolia';
    }
    _log.fine('Open box with path $path');
    return Hive.openBox(_boxName, path: path);
  }

  /// Private value storing the actual value of the persistent storage allowance
  /// flag
  bool _allowPersistentUserTokenStorage = false;

  /// Determines whether the value is stored in memory or persistent storage.
  /// Default value is 'false'
  bool get allowPersistentUserTokenStorage => _allowPersistentUserTokenStorage;

  set allowPersistentUserTokenStorage(bool isAllowed) {
    _allowPersistentUserTokenStorage = isAllowed;
    if (isAllowed) {
      _write(userToken);
    } else {
      remove();
    }
  }

  /// Value storing the unique UserTokenStorage instance
  static final UserTokenStorage _sharedInstance =
      UserTokenStorage.custom(null, 'algolia-user-token');

  /// Factory constructor returning the unique UserTokenStorage instance
  factory UserTokenStorage() => _sharedInstance;

  /// UserTokenStorage's private constructor
  UserTokenStorage.custom(this._boxPath, this._boxName) {
    read().then((storedUserToken) {
      if (storedUserToken != null) {
        _log.fine('Successfully read non-expired user token: $storedUserToken');
        userToken = storedUserToken;
      } else if (allowPersistentUserTokenStorage) {
        _write(userToken);
      }
    });
  }

  /// Write the user token value to the persistent storage
  void _write(String userToken) {
    final expirationDate =
        DateTime.now().millisecondsSinceEpoch + leaseTime * 60 * 1000;
    _log.fine('Write to persistent storage user token $userToken, '
        'expiration date $expirationDate');
    _box.then(
      (box) => box
        ..put(_userTokenKey, userToken)
        ..put(_expirationDateKey, expirationDate),
    );
  }

  /// Remove user token and its expiration date from persistent storage
  void remove() {
    _log.fine('Clear persistent storage');
    _box.then((box) {
      if (box.isOpen) {
        box
          ..delete(_userTokenKey)
          ..delete(_leaseTime);
      }
    });
  }

  /// Read user token value from the persistent storage.
  /// Shouldn't be called directly, use the `userToken` getter method instead.
  Future<String?> read() async {
    final box = await _box;
    final storedUserToken = await box.get(_userTokenKey) as String?;
    final storedUserTokenExpirationDate = await box.get(
      _expirationDateKey,
    ) as int?;
    _log.fine('Read from persistent storage user token: $storedUserToken, '
        'expiration date: $storedUserTokenExpirationDate');
    if (storedUserToken != null &&
        storedUserTokenExpirationDate != null &&
        DateTime.now().millisecondsSinceEpoch < storedUserTokenExpirationDate) {
      return storedUserToken;
    }
    return null;
  }
}
