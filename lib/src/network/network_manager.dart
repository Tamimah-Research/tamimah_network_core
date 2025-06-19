import 'dart:io';
import 'package:dio/dio.dart';
import 'network_service.dart';
import 'network_config.dart';
import 'network_models.dart';

/// Singleton network manager for easy access to network service
class NetworkManager {
  static NetworkManager? _instance;
  static NetworkManager get instance => _instance ??= NetworkManager._();

  late NetworkService _networkService;
  NetworkConfig? _config;

  NetworkManager._();

  /// Initialize the network manager
  void initialize({NetworkConfig? config}) {
    _config = config ?? NetworkConfig.defaultConfig();
    _networkService = NetworkService(config: _config);
  }

  /// Get the network service instance
  NetworkService get service {
    return _networkService;
  }

  /// Get current configuration
  NetworkConfig? get config => _config;

  /// Update configuration
  void updateConfig(NetworkConfig newConfig) {
    _config = newConfig;
    _networkService = NetworkService(config: newConfig);
  }

  /// Update base URL
  void updateBaseUrl(String newBaseUrl) {
    _networkService.updateBaseUrl(newBaseUrl);
  }

  /// Update auth token
  void updateAuthToken(String token) {
    if (_config != null) {
      final newConfig = _config!.withAuthToken(token);
      updateConfig(newConfig);
    }
  }

  /// Add custom headers
  void addHeaders(Map<String, dynamic> headers) {
    _networkService.updateHeaders(headers);
  }

  /// Clear all headers
  void clearHeaders() {
    _networkService.clearHeaders();
  }

  /// Check network connectivity
  Future<bool> get isConnected => _networkService.isConnected;

  /// Dispose resources
  void dispose() {
    _networkService.dispose();
    _instance = null;
  }

  /// Reset to default configuration
  void reset() {
    initialize(config: NetworkConfig.defaultConfig());
  }

  /// Create development configuration
  void setDevelopmentMode() {
    initialize(config: NetworkConfig.development());
  }

  /// Create production configuration
  void setProductionMode() {
    initialize(config: NetworkConfig.production());
  }
}

/// Extension for easy access to network manager
extension NetworkManagerExtension on NetworkManager {
  /// GET request with BaseApiResponse
  Future<BaseApiResponse<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    return service.get<T>(
      path,
      queryParameters: queryParameters,
      fromJson: fromJson,
    );
  }

  /// POST request with BaseApiResponse
  Future<BaseApiResponse<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    return service.post<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      fromJson: fromJson,
    );
  }

  /// PUT request with BaseApiResponse
  Future<BaseApiResponse<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    return service.put<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      fromJson: fromJson,
    );
  }

  /// DELETE request with BaseApiResponse
  Future<BaseApiResponse<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    return service.delete<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      fromJson: fromJson,
    );
  }

  /// PATCH request with BaseApiResponse
  Future<BaseApiResponse<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    return service.patch<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      fromJson: fromJson,
    );
  }

  /// Upload file with BaseApiResponse
  Future<BaseApiResponse<T>> upload<T>(
    String path, {
    required File file,
    String fieldName = 'file',
    Map<String, dynamic>? extraData,
    ProgressCallback? onSendProgress,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    return service.upload<T>(
      path,
      file: file,
      fieldName: fieldName,
      extraData: extraData,
      onSendProgress: onSendProgress,
      fromJson: fromJson,
    );
  }
}
