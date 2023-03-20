import 'package:algolia_insights/src/user_token_storage.dart';
import 'package:test/test.dart';

void main() {
  test('should return anonymous user token by default', () {
    final storage = UserTokenStorage();
    expect(storage.userToken.startsWith('anonymous-'), isTrue);
  });

  test('should allow setting a new user token', () {
    final storage = UserTokenStorage();
    const newToken = 'my-new-token';
    storage.userToken = newToken;
    expect(storage.userToken, equals(newToken));
  });

  test('should allow setting a new lease time', () {
    final storage = UserTokenStorage();
    const newLeaseTime = 60;
    storage.leaseTime = newLeaseTime;
    expect(storage.leaseTime, equals(newLeaseTime));
  });

  test('should store user token in memory by default', () {
    final storage = UserTokenStorage()..userToken = 'my-token';
    expect(storage.allowPersistentUserTokenStorage, isFalse);
    expect(storage.read(), completion(equals(null)));
  });

  test('should store user token in persistent storage if enabled', () async {
    final storage = UserTokenStorage()
      ..allowPersistentUserTokenStorage = true
      ..userToken = 'my-token';
    expect(storage.allowPersistentUserTokenStorage, isTrue);
    expect(storage.userToken, 'my-token');
    expect(storage.read(), completion(equals('my-token')));
  });

  test('should remove user token from persistent storage if disabled',
      () async {
    final storage = UserTokenStorage()
      ..allowPersistentUserTokenStorage = true
      ..userToken = 'my-token';
    expect(storage.allowPersistentUserTokenStorage, isTrue);
    storage.allowPersistentUserTokenStorage = false;
    expect(storage.allowPersistentUserTokenStorage, isFalse);
    expect(storage.read(), completion(isNull));
  });


  test('check expired user token nullified', () async {
    final userTokenStorage = UserTokenStorage()
      ..allowPersistentUserTokenStorage = true
      ..userToken = 'my user token'
      ..leaseTime = -1;
    final storedUserToken = await userTokenStorage.read();
    expect(storedUserToken, null);
  });

}
