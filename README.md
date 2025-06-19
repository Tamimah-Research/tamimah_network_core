<!--
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/tools/pub/writing-package-pages).

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/to/develop-packages).
-->

# Tamimah Core - Flutter Network Plugin

A comprehensive Flutter network plugin for handling HTTP requests, authentication, error handling, and more. Built with Dio and designed for reusability across multiple projects. Uses a standardized `BaseApiResponse` structure for consistent API handling.

## Features

- 🚀 **HTTP Client Wrapper** - Built on top of Dio with comprehensive error handling
- 🔐 **Authentication Support** - Automatic token management and refresh
- 📡 **Network Connectivity** - Real-time connectivity monitoring
- 🔄 **Retry Logic** - Automatic retry for failed requests
- 📝 **Request/Response Logging** - Detailed logging for debugging
- 🎯 **Type Safety** - Generic response handling with type safety
- 📁 **File Upload** - Easy file upload with progress tracking
- 🏗️ **Modular Design** - Easy to extend and customize
- 🧪 **Well Tested** - Comprehensive error handling and edge cases
- 📊 **Standardized Responses** - Uses BaseApiResponse for consistent API handling

## Installation

Add this to your `pubspec.yaml`:

```yaml
dependencies:
  tamimah_core:
    git:
      url: https://github.com/Tamimah-Research/tamimah_network_core.git
      ref: main
```

## Quick Start

### 1. Initialize the Network Plugin

```dart
import 'package:tamimah_core/tamimah_core.dart';

void main() {
  // Initialize with your API configuration
  TamimahCore.initialize(
    baseUrl: 'https://api.yourapp.com',
    authToken: 'your-auth-token', // Optional
    defaultHeaders: {
      'X-API-Key': 'your-api-key',
    },
  );
  
  runApp(MyApp());
}
```

### 2. Make API Requests with BaseApiResponse

```dart
// GET request
final response = await TamimahCore.network.get<Map<String, dynamic>>(
  '/api/users',
  queryParameters: {'page': 1, 'limit': 10},
  fromJson: (json) => json,
);

if (response.isSuccess) {
  final users = response.data;
  print('Users: $users');
} else {
  print('Error: ${response.errorMessage}');
}

// POST request
final createResponse = await TamimahCore.network.post<User>(
  '/api/users',
  data: {
    'name': 'John Doe',
    'email': 'john@example.com',
  },
  fromJson: (json) => User.fromJson(json),
);

if (createResponse.isSuccess) {
  final newUser = createResponse.dataOrThrow;
  print('Created user: ${newUser.name}');
}
```

### 3. Handle Responses with Models

```dart
class User extends BaseModel {
  final int id;
  final String name;
  final String email;

  User({required this.id, required this.name, required this.email});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
    };
  }
}

// Use with type conversion
final response = await TamimahCore.network.get<User>(
  '/api/users/1',
  fromJson: (json) => User.fromJson(json),
);

if (response.isSuccess) {
  final user = response.dataOrThrow;
  print('User: ${user.name}');
}
```

### 4. File Upload

```dart
import 'dart:io';

final file = File('/path/to/image.jpg');
final response = await TamimahCore.network.upload<String>(
  '/api/upload',
  file: file,
  fieldName: 'image',
  extraData: {'description': 'Profile picture'},
  onSendProgress: (sent, total) {
    print('Upload progress: ${(sent / total * 100).toStringAsFixed(0)}%');
  },
  fromJson: (json) => json['url'] ?? '',
);

if (response.isSuccess) {
  final imageUrl = response.dataOrThrow;
  print('Uploaded to: $imageUrl');
}
```

## BaseApiResponse Structure

The plugin uses a standardized `BaseApiResponse` structure for all API responses:

```dart
class BaseApiResponse<T> {
  ResponseStatus? responseStatus;
  int? totalCount;
  int? index;
  int? pageSize;
  T? data;
  
  // Helper methods
  bool get isSuccess => responseStatus?.statusCode == 200;
  bool get hasData => data != null;
  T get dataOrThrow => data ?? throw Exception('Data is null');
  String get errorMessage => responseStatus?.message ?? 'Unknown error';
}
```

### ResponseStatus Structure

```dart
class ResponseStatus {
  int? statusCode;
  String message;
  String? messageAr;  // Arabic message
  String errorCode;
  
  bool get isSuccess => statusCode == 200;
  bool get isError => statusCode != null && statusCode! >= 400;
}
```

## Advanced Usage

### Custom Configuration

```dart
final config = NetworkConfig(
  baseUrl: 'https://api.yourapp.com',
  connectTimeout: 30,
  receiveTimeout: 30,
  sendTimeout: 30,
  maxRetries: 3,
  retryDelay: 1,
  enableLogging: true,
  defaultHeaders: {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  },
);

NetworkManager.instance.initialize(config: config);
```

### Environment-Specific Configurations

```dart
// Development
NetworkManager.instance.setDevelopmentMode();

// Production
NetworkManager.instance.setProductionMode();

// Custom configuration
final customConfig = NetworkConfig.development().copyWith(
  baseUrl: 'https://dev-api.yourapp.com',
  enableLogging: false,
);
NetworkManager.instance.initialize(config: customConfig);
```

### Authentication

```dart
// Update auth token
NetworkManager.instance.updateAuthToken('new-token');

// Add custom headers
NetworkManager.instance.addHeaders({
  'Authorization': 'Bearer your-token',
  'X-API-Key': 'your-api-key',
});

// Clear headers
NetworkManager.instance.clearHeaders();
```

### Error Handling

```dart
try {
  final response = await TamimahCore.network.get<User>('/api/users/1');
  
  if (response.isSuccess) {
    final user = response.dataOrThrow;
    // Handle success
  } else {
    // Handle API error
    print('API Error: ${response.errorMessage}');
    print('Error Code: ${response.responseStatus?.errorCode}');
    print('Arabic Message: ${response.responseStatus?.messageAr}');
  }
} on NetworkException catch (e) {
  switch (e.type) {
    case NetworkErrorType.noConnection:
      print('No internet connection');
      break;
    case NetworkErrorType.unauthorized:
      print('User not authorized');
      break;
    case NetworkErrorType.serverError:
      print('Server error: ${e.message}');
      break;
    default:
      print('Network error: ${e.userMessage}');
  }
}
```

### Pagination Support

```dart
// Get paginated users
final response = await TamimahCore.network.get<List<User>>(
  '/api/users',
  queryParameters: {'page': 1, 'per_page': 10},
  fromJson: (json) {
    final usersList = json as List<dynamic>;
    return usersList.map((userJson) => User.fromJson(userJson)).toList();
  },
);

if (response.isSuccess) {
  final users = response.dataOrThrow;
  final totalCount = response.totalCount ?? 0;
  final currentPage = response.index ?? 0;
  final pageSize = response.pageSize ?? 10;
  
  print('Total users: $totalCount');
  print('Current page: $currentPage');
  print('Page size: $pageSize');
  print('Users in this page: ${users.length}');
}
```

## API Reference

### NetworkManager

The main class for managing network operations.

```dart
// Singleton instance
NetworkManager.instance

// Methods
void initialize({NetworkConfig? config})
NetworkService get service
void updateConfig(NetworkConfig newConfig)
void updateBaseUrl(String newBaseUrl)
void updateAuthToken(String token)
void addHeaders(Map<String, dynamic> headers)
void clearHeaders()
Future<bool> get isConnected
void dispose()
void reset()
void setDevelopmentMode()
void setProductionMode()
```

### NetworkConfig

Configuration class for network settings.

```dart
NetworkConfig({
  required String baseUrl,
  int connectTimeout = 30,
  int receiveTimeout = 30,
  int sendTimeout = 30,
  Map<String, dynamic> defaultHeaders = const {...},
  String? authToken,
  int maxRetries = 3,
  int retryDelay = 1,
  bool enableLogging = true,
  bool enableRetry = true,
})
```

### BaseApiResponse

Standardized API response wrapper.

```dart
BaseApiResponse<T>({
  required ResponseStatus? responseStatus,
  required int? totalCount,
  required int? index,
  required int? pageSize,
  T? data,
})

// Factory methods
BaseApiResponse.fromJson(Map<String, dynamic> json, Function(dynamic) create)
BaseApiResponse.fromJsonList(Map<String, dynamic> json, Function(List<dynamic>) create)
BaseApiResponse.fromJsonWithoutResult(Map<String, dynamic> json, Function(Map<String, dynamic>) create)
```

### ResponseStatus

API response status information.

```dart
ResponseStatus({
  required int? statusCode,
  required String message,
  String? messageAr,
  required String errorCode,
})
```

### NetworkException

Custom exception for network errors.

```dart
NetworkException(
  String message,
  NetworkErrorType type, {
  int? statusCode,
  Map<String, dynamic>? errors,
})
```

## Error Types

- `NetworkErrorType.noConnection` - No internet connection
- `NetworkErrorType.timeout` - Request timeout
- `NetworkErrorType.badRequest` - 400 Bad Request
- `NetworkErrorType.unauthorized` - 401 Unauthorized
- `NetworkErrorType.forbidden` - 403 Forbidden
- `NetworkErrorType.notFound` - 404 Not Found
- `NetworkErrorType.validationError` - 422 Validation Error
- `NetworkErrorType.serverError` - 5xx Server Error
- `NetworkErrorType.connectionError` - Connection error
- `NetworkErrorType.cancelled` - Request cancelled
- `NetworkErrorType.unknown` - Unknown error

## Best Practices

1. **Initialize Early**: Initialize the network plugin in your app's main function
2. **Handle Errors**: Always check `response.isSuccess` before accessing data
3. **Use Models**: Create proper model classes implementing `BaseModel`
4. **Environment Configs**: Use different configurations for dev/staging/prod
5. **Token Management**: Implement proper token refresh logic
6. **Loading States**: Show loading indicators during network requests
7. **Offline Handling**: Check connectivity before making requests
8. **Type Safety**: Always provide `fromJson` functions for type conversion

## Example Implementation

See `lib/src/network/example_api_service.dart` for a complete example of how to use the network plugin with real API endpoints.

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.
