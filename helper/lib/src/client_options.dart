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

  const ClientOptions({
    this.connectTimeout,
    this.writeTimeout,
    this.readTimeout,
    this.headers,
    this.logger,
  });

  @override
  String toString() {
    return 'ClientOptions{connectTimeout: $connectTimeout, writeTimeout: $writeTimeout, readTimeout: $readTimeout, headers: $headers, logger: $logger}';
  }
}
