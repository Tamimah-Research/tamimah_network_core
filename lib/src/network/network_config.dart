/// Configuration class for network service
class NetworkConfig {
  final String baseUrl;
  final int connectTimeout;
  final int receiveTimeout;
  final int sendTimeout;
  final Map<String, dynamic> defaultHeaders;
  final String? authToken;
  final int maxRetries;
  final int retryDelay;
  final bool enableLogging;
  final bool enableRetry;

  const NetworkConfig({
    required this.baseUrl,
    this.connectTimeout = 30,
    this.receiveTimeout = 30,
    this.sendTimeout = 30,
    this.defaultHeaders = const {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
    this.authToken,
    this.maxRetries = 3,
    this.retryDelay = 1,
    this.enableLogging = true,
    this.enableRetry = true,
  });

  /// Default configuration
  factory NetworkConfig.defaultConfig() {
    return const NetworkConfig(
      baseUrl: 'https://api.example.com',
      connectTimeout: 30,
      receiveTimeout: 30,
      sendTimeout: 30,
      defaultHeaders: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      maxRetries: 3,
      retryDelay: 1,
      enableLogging: true,
      enableRetry: true,
    );
  }

  /// Development configuration
  factory NetworkConfig.development() {
    return const NetworkConfig(
      baseUrl: 'https://dev-api.example.com',
      connectTimeout: 60,
      receiveTimeout: 60,
      sendTimeout: 60,
      defaultHeaders: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      maxRetries: 3,
      retryDelay: 1,
      enableLogging: true,
      enableRetry: true,
    );
  }

  /// Production configuration
  factory NetworkConfig.production() {
    return const NetworkConfig(
      baseUrl: 'https://api.example.com',
      connectTimeout: 30,
      receiveTimeout: 30,
      sendTimeout: 30,
      defaultHeaders: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      maxRetries: 2,
      retryDelay: 2,
      enableLogging: false,
      enableRetry: true,
    );
  }

  /// Create a copy with updated values
  NetworkConfig copyWith({
    String? baseUrl,
    int? connectTimeout,
    int? receiveTimeout,
    int? sendTimeout,
    Map<String, dynamic>? defaultHeaders,
    String? authToken,
    int? maxRetries,
    int? retryDelay,
    bool? enableLogging,
    bool? enableRetry,
  }) {
    return NetworkConfig(
      baseUrl: baseUrl ?? this.baseUrl,
      connectTimeout: connectTimeout ?? this.connectTimeout,
      receiveTimeout: receiveTimeout ?? this.receiveTimeout,
      sendTimeout: sendTimeout ?? this.sendTimeout,
      defaultHeaders: defaultHeaders ?? this.defaultHeaders,
      authToken: authToken ?? this.authToken,
      maxRetries: maxRetries ?? this.maxRetries,
      retryDelay: retryDelay ?? this.retryDelay,
      enableLogging: enableLogging ?? this.enableLogging,
      enableRetry: enableRetry ?? this.enableRetry,
    );
  }

  /// Update auth token
  NetworkConfig withAuthToken(String token) {
    return copyWith(authToken: token);
  }

  /// Update base URL
  NetworkConfig withBaseUrl(String url) {
    return copyWith(baseUrl: url);
  }

  /// Add custom headers
  NetworkConfig withHeaders(Map<String, dynamic> headers) {
    final updatedHeaders = Map<String, dynamic>.from(defaultHeaders);
    updatedHeaders.addAll(headers);
    return copyWith(defaultHeaders: updatedHeaders);
  }

  @override
  String toString() {
    return 'NetworkConfig{baseUrl: $baseUrl, connectTimeout: $connectTimeout, receiveTimeout: $receiveTimeout, sendTimeout: $sendTimeout, defaultHeaders: $defaultHeaders, authToken: ${authToken != null ? '***' : null}, maxRetries: $maxRetries, retryDelay: $retryDelay, enableLogging: $enableLogging, enableRetry: $enableRetry}';
  }
}
