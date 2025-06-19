/// Network error types
enum NetworkErrorType {
  noConnection,
  timeout,
  badRequest,
  unauthorized,
  forbidden,
  notFound,
  validationError,
  serverError,
  connectionError,
  cancelled,
  unknown,
}

/// Custom network exception
class NetworkException implements Exception {
  final String message;
  final NetworkErrorType type;
  final int? statusCode;
  final Map<String, dynamic>? errors;

  const NetworkException(
    this.message,
    this.type, {
    this.statusCode,
    this.errors,
  });

  /// Create from status code
  factory NetworkException.fromStatusCode(
    int statusCode,
    String message, {
    Map<String, dynamic>? errors,
  }) {
    NetworkErrorType type;
    switch (statusCode) {
      case 400:
        type = NetworkErrorType.badRequest;
        break;
      case 401:
        type = NetworkErrorType.unauthorized;
        break;
      case 403:
        type = NetworkErrorType.forbidden;
        break;
      case 404:
        type = NetworkErrorType.notFound;
        break;
      case 422:
        type = NetworkErrorType.validationError;
        break;
      case 500:
      case 502:
      case 503:
      case 504:
        type = NetworkErrorType.serverError;
        break;
      default:
        type = NetworkErrorType.unknown;
    }

    return NetworkException(
      message,
      type,
      statusCode: statusCode,
      errors: errors,
    );
  }

  /// Create timeout exception
  factory NetworkException.timeout(String message) {
    return NetworkException(message, NetworkErrorType.timeout);
  }

  /// Create no connection exception
  factory NetworkException.noConnection() {
    return const NetworkException(
      'No internet connection available',
      NetworkErrorType.noConnection,
    );
  }

  /// Create unauthorized exception
  factory NetworkException.unauthorized(String message) {
    return NetworkException(
      message,
      NetworkErrorType.unauthorized,
      statusCode: 401,
    );
  }

  /// Create server error exception
  factory NetworkException.serverError(String message) {
    return NetworkException(
      message,
      NetworkErrorType.serverError,
      statusCode: 500,
    );
  }

  /// Check if error is retryable
  bool get isRetryable {
    return type == NetworkErrorType.timeout ||
        type == NetworkErrorType.connectionError ||
        type == NetworkErrorType.serverError ||
        type == NetworkErrorType.noConnection;
  }

  /// Check if error is authentication related
  bool get isAuthError {
    return type == NetworkErrorType.unauthorized ||
        type == NetworkErrorType.forbidden;
  }

  /// Check if error is client error (4xx)
  bool get isClientError {
    return statusCode != null && statusCode! >= 400 && statusCode! < 500;
  }

  /// Check if error is server error (5xx)
  bool get isServerError {
    return statusCode != null && statusCode! >= 500;
  }

  /// Get user-friendly error message
  String get userMessage {
    switch (type) {
      case NetworkErrorType.noConnection:
        return 'No internet connection. Please check your network and try again.';
      case NetworkErrorType.timeout:
        return 'Request timed out. Please try again.';
      case NetworkErrorType.unauthorized:
        return 'You are not authorized to perform this action.';
      case NetworkErrorType.forbidden:
        return 'Access forbidden. You don\'t have permission for this action.';
      case NetworkErrorType.notFound:
        return 'The requested resource was not found.';
      case NetworkErrorType.validationError:
        return 'Please check your input and try again.';
      case NetworkErrorType.serverError:
        return 'Server error occurred. Please try again later.';
      case NetworkErrorType.connectionError:
        return 'Connection error. Please check your internet connection.';
      case NetworkErrorType.cancelled:
        return 'Request was cancelled.';
      case NetworkErrorType.badRequest:
        return 'Invalid request. Please check your input.';
      case NetworkErrorType.unknown:
        return 'An unexpected error occurred. Please try again.';
    }
  }

  @override
  String toString() {
    return 'NetworkException{type: $type, message: $message, statusCode: $statusCode, errors: $errors}';
  }
}
