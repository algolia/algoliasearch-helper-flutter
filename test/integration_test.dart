import 'package:algolia/algolia.dart';
import 'package:algolia_helper/algolia_helper.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Operation callback', () async {
    final algoliaHelper = AlgoliaHelper.create(
        applicationID: 'latency',
        apiKey: 'afc3dd66dd1293e2e2736a5a51b05c0a',
        indexName: 'instant_search');

    algoliaHelper.setHitPerPage(1);

    AlgoliaQuerySnapshot? res1;
    AlgoliaError? err1;
    algoliaHelper.on(
      onResult: (value) => res1 = value,
      onError: (value) => err1 = value,
    );

    AlgoliaQuerySnapshot? res2;
    AlgoliaError? err2;
    algoliaHelper.on(
      onResult: (value) => res2 = value,
      onError: (value) => err2 = value,
    );

    algoliaHelper.query("apple");
    algoliaHelper.search();

    await Future.delayed(const Duration(seconds: 2), () {});

    expect(res1?.hasHits, true);
    expect(err1, null);
    expect(res2?.hasHits, true);
    expect(err2, null);
    expect(res1?.length == res2?.length, true);
  });

  test('Operation failed', () async {
    final algoliaHelper = AlgoliaHelper.create(
        applicationID: 'latency',
        apiKey: 'UNKNOWN',
        indexName: 'instant_search');

    AlgoliaQuerySnapshot? res1;
    AlgoliaError? err1;
    algoliaHelper.on(
      onResult: (value) => res1 = value,
      onError: (value) => err1 = value,
    );

    AlgoliaQuerySnapshot? res2;
    AlgoliaError? err2;
    algoliaHelper.on(
      onResult: (value) => res2 = value,
      onError: (value) => err2 = value,
    );

    algoliaHelper.search();

    // wait 2 secs
    await Future.delayed(const Duration(seconds: 2), () {});

    expect(res1, null);
    expect(err1 != null, true);
    expect(res2, null);
    expect(err2 != null, true);
  });
}
