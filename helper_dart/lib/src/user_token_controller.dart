import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class UserTokenController {
  static const _userTokenKey = 'insights-user-token';
  static const _expirationDateKey = 'insights-user-token-expiration-date';

  /// A pseudonymous or anonymous user identifier.
  String userToken = _generateUserToken();

  /// Token storage lease time in minutes. Ignored in case of in-memory storage.
  /// Default value is 1440 minutes (1 day)
  int leaseTime = 1440;

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

  UserTokenController() {
    _read().then((storedUserToken) {
      if (storedUserToken != null) {
        userToken = storedUserToken;
      }
    });
  }

  void setUserToken(String userToken) {
    this.userToken = userToken;
    if (allowPersistentUserTokenStorage) {
      _write(userToken);
    }
  }

  static String _generateUserToken() => 'anonymous-${const Uuid().v4()}';

  void _write(String userToken) {
    final expirationDate =
        DateTime.now().millisecondsSinceEpoch + leaseTime * 60 * 1000;
    SharedPreferences.getInstance().then(
      (sharedPreferences) => {
        sharedPreferences.setString(_userTokenKey, userToken),
        sharedPreferences.setInt(_expirationDateKey, expirationDate)
      },
    );
  }

  void _remove() {
    SharedPreferences.getInstance().then(
      (sharedPreferences) => {
        sharedPreferences.remove(_userTokenKey),
        sharedPreferences.remove(_expirationDateKey)
      },
    );
  }

  Future<String?> _read() async {
    final preferences = await SharedPreferences.getInstance();
    final storedUserToken = preferences.getString(_userTokenKey);
    final storedUserTokenExpirationDate =
        preferences.getInt(_expirationDateKey);
    if (storedUserToken != null &&
        storedUserTokenExpirationDate != null &&
        DateTime.now().millisecondsSinceEpoch < storedUserTokenExpirationDate) {
      return storedUserToken;
    }
    return null;
  }
}
