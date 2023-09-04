import 'dart:io';

import 'package:algolia_insights/src/lib_version.dart';
import 'package:test/test.dart';

void main() {
  if (Directory.current.path.endsWith('/test')) {
    Directory.current = Directory.current.parent;
  }
  test('package version matches pubspec', () {
    final pubspecPath = '${Directory.current.path}/pubspec.yaml';
    final pubspec = File(pubspecPath).readAsStringSync();
    final regex = RegExp('version:s*(.*)');
    final match = regex.firstMatch(pubspec);
    expect(match, isNotNull);
    expect(libVersion, match?.group(1)?.trim());
  });
}