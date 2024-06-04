import 'package:algoliasearch/algoliasearch.dart' as algolia;

import '../client_options.dart';
import '../lib_version.dart';

/// Create [algolia.ClientOptions] instance.
algolia.ClientOptions createClientOptions(ClientOptions? options) {
  return algolia.ClientOptions(
    connectTimeout: options?.connectTimeout ?? const Duration(seconds: 2),
    writeTimeout: options?.writeTimeout ?? const Duration(seconds: 30),
    readTimeout: options?.readTimeout ?? const Duration(seconds: 5),
    headers: options?.headers,
    logger: options?.logger,
    agentSegments: [
      algolia.AgentSegment(
        value: 'algolia-helper-flutter',
        version: libVersion,
      ),
    ],
  );
}
