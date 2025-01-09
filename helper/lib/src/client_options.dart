import 'package:dio/dio.dart';

/// Configuration options for the HTTP client.
final class ClientOptions {
  /// The maximum duration to wait for a connection to establish before timing out.
  final Duration? connectTimeout;

  /// The maximum duration to wait for a write operation to complete before timing out.
  final Duration? writeTimeout;

  /// The maximum duration to wait for a read operation to complete before timing out.
  final Duration? readTimeout;

  /// Default headers to include in each HTTP request.
  final Map<String, dynamic>? headers;

  /// Custom logger for http operations.
  final Function(Object?)? logger;

  /// List of Dio interceptors.
  /// Used only in case of using the default (dio) requester.
  final Iterable<Interceptor>? interceptors;

  const ClientOptions({
    this.connectTimeout,
    this.writeTimeout,
    this.readTimeout,
    this.headers,
    this.logger,
    this.interceptors,
  });

  @override
  String toString() {
    return 'ClientOptions{connectTimeout: $connectTimeout, writeTimeout: $writeTimeout, readTimeout: $readTimeout, headers: $headers, logger: $logger, interceptors: $interceptors}';
  }
}
