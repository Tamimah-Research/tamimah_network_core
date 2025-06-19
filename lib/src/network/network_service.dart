import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'network_config.dart';
import 'network_exception.dart';
import 'network_models.dart';

/// Core network service for handling HTTP requests
class NetworkService {
  late Dio _dio;
  final NetworkConfig _config;
  final Connectivity _connectivity = Connectivity();

  NetworkService({NetworkConfig? config})
    : _config = config ?? NetworkConfig.defaultConfig() {
    _initializeDio();
  }

  /// Initialize Dio with interceptors and configuration
  void _initializeDio() {
    _dio = Dio(
      BaseOptions(
        baseUrl: _config.baseUrl,
        connectTimeout: Duration(seconds: _config.connectTimeout),
        receiveTimeout: Duration(seconds: _config.receiveTimeout),
        sendTimeout: Duration(seconds: _config.sendTimeout),
        headers: _config.defaultHeaders,
      ),
    );

    // Add interceptors
    _dio.interceptors.addAll([
      _LoggingInterceptor(),
      _AuthInterceptor(_config),
      _ErrorInterceptor(),
      _RetryInterceptor(_config),
    ]);
  }

  /// Check network connectivity
  Future<bool> get isConnected async {
    final connectivityResult = await _connectivity.checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  /// GET request with BaseApiResponse
  Future<BaseApiResponse<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    return _executeRequest<T>(
      () => _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      ),
      fromJson: fromJson,
    );
  }

  /// POST request with BaseApiResponse
  Future<BaseApiResponse<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    return _executeRequest<T>(
      () => _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      ),
      fromJson: fromJson,
    );
  }

  /// PUT request with BaseApiResponse
  Future<BaseApiResponse<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    return _executeRequest<T>(
      () => _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      ),
      fromJson: fromJson,
    );
  }

  /// DELETE request with BaseApiResponse
  Future<BaseApiResponse<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    return _executeRequest<T>(
      () => _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      ),
      fromJson: fromJson,
    );
  }

  /// PATCH request with BaseApiResponse
  Future<BaseApiResponse<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    return _executeRequest<T>(
      () => _dio.patch(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      ),
      fromJson: fromJson,
    );
  }

  /// Upload file with BaseApiResponse
  Future<BaseApiResponse<T>> upload<T>(
    String path, {
    required File file,
    String fieldName = 'file',
    Map<String, dynamic>? extraData,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    final formData = FormData.fromMap({
      fieldName: await MultipartFile.fromFile(file.path),
      ...?extraData,
    });

    return _executeRequest<T>(
      () => _dio.post(
        path,
        data: formData,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
      ),
      fromJson: fromJson,
    );
  }

  /// Execute request with error handling and BaseApiResponse conversion
  Future<BaseApiResponse<T>> _executeRequest<T>(
    Future<Response> Function() request, {
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    try {
      // Check connectivity
      if (!await isConnected) {
        throw NetworkException(
          'No internet connection',
          NetworkErrorType.noConnection,
        );
      }

      final response = await request();

      // Convert to BaseApiResponse
      if (fromJson != null) {
        return BaseApiResponse.fromJson(
          response.data,
          (data) => fromJson(data as Map<String, dynamic>),
        );
      } else {
        return BaseApiResponse.fromJsonWithoutResult(
          response.data,
          (data) => data,
        );
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw NetworkException(
        'Unexpected error: ${e.toString()}',
        NetworkErrorType.unknown,
      );
    }
  }

  /// Handle Dio specific errors
  NetworkException _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return NetworkException('Request timeout', NetworkErrorType.timeout);
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final message = error.response?.data?['message'] ?? 'Server error';

        switch (statusCode) {
          case 400:
            return NetworkException(message, NetworkErrorType.badRequest);
          case 401:
            return NetworkException(message, NetworkErrorType.unauthorized);
          case 403:
            return NetworkException(message, NetworkErrorType.forbidden);
          case 404:
            return NetworkException(message, NetworkErrorType.notFound);
          case 422:
            return NetworkException(message, NetworkErrorType.validationError);
          case 500:
            return NetworkException(message, NetworkErrorType.serverError);
          default:
            return NetworkException(message, NetworkErrorType.serverError);
        }
      case DioExceptionType.cancel:
        return NetworkException(
          'Request cancelled',
          NetworkErrorType.cancelled,
        );
      case DioExceptionType.connectionError:
        return NetworkException(
          'Connection error',
          NetworkErrorType.connectionError,
        );
      default:
        return NetworkException('Network error', NetworkErrorType.unknown);
    }
  }

  /// Update base URL
  void updateBaseUrl(String newBaseUrl) {
    _dio.options.baseUrl = newBaseUrl;
  }

  /// Update default headers
  void updateHeaders(Map<String, dynamic> headers) {
    _dio.options.headers.addAll(headers);
  }

  /// Clear all headers
  void clearHeaders() {
    _dio.options.headers.clear();
  }

  /// Dispose resources
  void dispose() {
    _dio.close();
  }
}

/// Logging interceptor for debugging
class _LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (kDebugMode) {
      print('🌐 REQUEST[${options.method}] => PATH: ${options.path}');
      print('Headers: ${options.headers}');
      print('Data: ${options.data}');
    }
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (kDebugMode) {
      print(
        '✅ RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}',
      );
      print('Data: ${response.data}');
    }
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (kDebugMode) {
      print(
        '❌ ERROR[${err.response?.statusCode}] => PATH: ${err.requestOptions.path}',
      );
      print('Message: ${err.message}');
    }
    super.onError(err, handler);
  }
}

/// Authentication interceptor
class _AuthInterceptor extends Interceptor {
  final NetworkConfig _config;

  _AuthInterceptor(this._config);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Add auth token if available
    if (_config.authToken != null) {
      options.headers['Authorization'] = 'Bearer ${_config.authToken}';
    }
    super.onRequest(options, handler);
  }
}

/// Error handling interceptor
class _ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Global error handling logic
    super.onError(err, handler);
  }
}

/// Retry interceptor
class _RetryInterceptor extends Interceptor {
  final NetworkConfig _config;

  _RetryInterceptor(this._config);

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (_config.maxRetries > 0 && _shouldRetry(err)) {
      await Future.delayed(Duration(seconds: _config.retryDelay));
      // Retry logic would go here
    }
    super.onError(err, handler);
  }

  bool _shouldRetry(DioException error) {
    return error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.connectionError;
  }
}
