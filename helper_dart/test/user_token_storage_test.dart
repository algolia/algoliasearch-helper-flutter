import 'package:algolia_helper/src/user_token_storage.dart';
import 'package:test/test.dart';

void main() {
  test('check user token persistent storage', () async {
    final userTokenController = UserTokenStorage()
      ..allowPersistentUserTokenStorage = true
      ..userToken = 'my user token';
    final storedUserToken = await userTokenController.read();
    expect(userTokenController.userToken, 'my user token');
    expect(storedUserToken, 'my user token');
  });

  test('check user token not stored if persistent storage denied', () async {
    final userTokenController = UserTokenStorage()
      ..allowPersistentUserTokenStorage = false
      ..userToken = 'my user token';
    final storedUserToken = await userTokenController.read();
    expect(userTokenController.userToken, 'my user token');
    expect(storedUserToken, null);
  });

  test('check user token expiration logic', () async {
    final userTokenController = UserTokenStorage()
      ..allowPersistentUserTokenStorage = true
      ..userToken = 'my user token'
      ..leaseTime = -1;
    final storedUserToken = await userTokenController.read();
    expect(storedUserToken, null);
  });
}
