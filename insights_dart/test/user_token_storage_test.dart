import 'package:algolia_insights/src/user_token_storage.dart';
import 'package:test/test.dart';

void main() {
  test('check user token persistent storage', () async {
    final userTokenStorage = UserTokenStorage()
      ..allowPersistentUserTokenStorage = true
      ..userToken = 'my user token';
    final storedUserToken = await userTokenStorage.read();
    expect(userTokenStorage.userToken, 'my user token');
    expect(storedUserToken, 'my user token');
  });

  test('check user token not stored if persistent storage denied', () async {
    final userTokenStorage = UserTokenStorage()
      ..allowPersistentUserTokenStorage = false
      ..userToken = 'my user token';
    final storedUserToken = await userTokenStorage.read();
    expect(userTokenStorage.userToken, 'my user token');
    expect(storedUserToken, null);
  });

  test('check user token expiration logic', () async {
    final userTokenStorage = UserTokenStorage()
      ..allowPersistentUserTokenStorage = true
      ..userToken = 'my user token'
      ..leaseTime = -1;
    final storedUserToken = await userTokenStorage.read();
    expect(storedUserToken, null);
  });
}
