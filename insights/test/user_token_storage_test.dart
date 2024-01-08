import 'dart:io';

import 'package:algolia_insights/src/user_token_storage.dart';
import 'package:test/test.dart';
import 'package:test_api/src/backend/invoker.dart' show Invoker;

void main() {
  late UserTokenStorage storage;

  setUp(
    () => {
      storage = UserTokenStorage.custom(
        'unit_test',
        Invoker.current!.liveTest.test.name,
      ),
    },
  );

  tearDownAll(() => Directory('unit_test').delete(recursive: true));

  test('should return anonymous user token by default', () {
    expect(storage.userToken.startsWith('anonymous-'), isTrue);
  });

  test('should allow setting a new user token', () {
    const newToken = 'my-new-token';
    storage.userToken = newToken;
    expect(storage.userToken, equals(newToken));
  });

  test('should allow setting a new lease time', () {
    const newLeaseTime = 60;
    storage.leaseTime = newLeaseTime;
    expect(storage.leaseTime, equals(newLeaseTime));
  });

  test('should store user token in memory by default', () {
    storage.userToken = 'my-token';
    expect(storage.allowPersistentUserTokenStorage, isFalse);
    expect(storage.read(), completion(equals(null)));
  });

  test('should store user token in persistent storage if enabled', () async {
    storage
      ..allowPersistentUserTokenStorage = true
      ..userToken = 'my-token';
    expect(storage.allowPersistentUserTokenStorage, isTrue);
    expect(storage.userToken, 'my-token');
    expect(storage.read(), completion(equals('my-token')));
  });

  test('should remove user token from persistent storage if disabled',
      () async {
    storage
      ..allowPersistentUserTokenStorage = true
      ..userToken = 'my-token';
    expect(storage.allowPersistentUserTokenStorage, isTrue);
    storage.allowPersistentUserTokenStorage = false;
    expect(storage.allowPersistentUserTokenStorage, isFalse);
    expect(storage.read(), completion(isNull));
  });

  test('check expired user token nullified', () async {
    storage
      ..allowPersistentUserTokenStorage = true
      ..userToken = 'my user token'
      ..leaseTime = -1;
    final storedUserToken = await storage.read();
    expect(storedUserToken, null);
  });
}
