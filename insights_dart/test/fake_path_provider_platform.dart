import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

const String kTemporaryPath = 'temporaryPath';
const String kApplicationSupportPath = 'applicationSupportPath';
const String kDownloadsPath = 'downloadsPath';
const String kLibraryPath = 'libraryPath';
const String kApplicationDocumentsPath = 'applicationDocumentsPath';
const String kExternalCachePath = 'externalCachePath';
const String kExternalStoragePath = 'externalStoragePath';

class FakePathProviderPlatform extends PathProviderPlatform {
  @override
  Future<String?> getTemporaryPath() async => kTemporaryPath;

  @override
  Future<String?> getApplicationSupportPath() async => kApplicationSupportPath;

  @override
  Future<String?> getLibraryPath() async => kLibraryPath;

  @override
  Future<String?> getApplicationDocumentsPath() async =>
      kApplicationDocumentsPath;

  @override
  Future<String?> getExternalStoragePath() async => kExternalStoragePath;

  @override
  Future<List<String>?> getExternalCachePaths() async =>
      <String>[kExternalCachePath];

  @override
  Future<List<String>?> getExternalStoragePaths({
    StorageDirectory? type,
  }) async =>
      <String>[kExternalStoragePath];

  @override
  Future<String?> getDownloadsPath() async => kDownloadsPath;
}
