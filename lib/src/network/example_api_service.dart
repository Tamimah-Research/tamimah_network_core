import 'dart:io';
import 'network_manager.dart';
import 'network_models.dart';

/// Example user model
class User extends BaseModel {
  final int id;
  final String name;
  final String email;
  final String? avatar;
  final DateTime createdAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.avatar,
    required this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      avatar: json['avatar'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'avatar': avatar,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

/// Example API service demonstrating network plugin usage with BaseApiResponse
class ExampleApiService {
  static const String _basePath = '/api';

  /// Get all users with pagination
  static Future<BaseApiResponse<List<User>>> getUsers({
    int page = 1,
    int perPage = 10,
    String? search,
  }) async {
    final queryParams = {
      'page': page,
      'per_page': perPage,
      if (search != null) 'search': search,
    };

    final response = await NetworkManager.instance.get<List<User>>(
      '$_basePath/users',
      queryParameters: queryParams,
      fromJson: (json) {
        final usersList = json as List<dynamic>;
        return usersList.map((userJson) => User.fromJson(userJson)).toList();
      },
    );

    return response;
  }

  /// Get user by ID
  static Future<BaseApiResponse<User>> getUser(int id) async {
    final response = await NetworkManager.instance.get<User>(
      '$_basePath/users/$id',
      fromJson: (json) => User.fromJson(json),
    );

    return response;
  }

  /// Create new user
  static Future<BaseApiResponse<User>> createUser({
    required String name,
    required String email,
    String? avatar,
  }) async {
    final data = {
      'name': name,
      'email': email,
      if (avatar != null) 'avatar': avatar,
    };

    final response = await NetworkManager.instance.post<User>(
      '$_basePath/users',
      data: data,
      fromJson: (json) => User.fromJson(json),
    );

    return response;
  }

  /// Update user
  static Future<BaseApiResponse<User>> updateUser(
    int id, {
    String? name,
    String? email,
    String? avatar,
  }) async {
    final data = <String, dynamic>{};
    if (name != null) data['name'] = name;
    if (email != null) data['email'] = email;
    if (avatar != null) data['avatar'] = avatar;

    final response = await NetworkManager.instance.put<User>(
      '$_basePath/users/$id',
      data: data,
      fromJson: (json) => User.fromJson(json),
    );

    return response;
  }

  /// Delete user
  static Future<BaseApiResponse<bool>> deleteUser(int id) async {
    final response = await NetworkManager.instance.delete<bool>(
      '$_basePath/users/$id',
      fromJson: (json) => json['success'] ?? false,
    );

    return response;
  }

  /// Upload user avatar
  static Future<BaseApiResponse<String>> uploadAvatar(
    int userId,
    String filePath,
  ) async {
    final file = File(filePath);

    final response = await NetworkManager.instance.upload<String>(
      '$_basePath/users/$userId/avatar',
      file: file,
      fieldName: 'avatar',
      fromJson: (json) => json['avatar_url'] ?? '',
    );

    return response;
  }

  /// Search users
  static Future<BaseApiResponse<List<User>>> searchUsers(String query) async {
    final response = await NetworkManager.instance.get<List<User>>(
      '$_basePath/users/search',
      queryParameters: {'q': query},
      fromJson: (json) {
        final usersList = json as List<dynamic>;
        return usersList.map((userJson) => User.fromJson(userJson)).toList();
      },
    );

    return response;
  }

  /// Get user statistics
  static Future<BaseApiResponse<Map<String, dynamic>>> getUserStats(
    int userId,
  ) async {
    final response = await NetworkManager.instance.get<Map<String, dynamic>>(
      '$_basePath/users/$userId/stats',
      fromJson: (json) => json,
    );

    return response;
  }
}

/// Example authentication service
class AuthService {
  static const String _basePath = '/api/auth';

  /// Login user
  static Future<BaseApiResponse<Map<String, dynamic>>> login({
    required String email,
    required String password,
  }) async {
    final data = {'email': email, 'password': password};

    final response = await NetworkManager.instance.post<Map<String, dynamic>>(
      '$_basePath/login',
      data: data,
      fromJson: (json) => json,
    );

    // Update auth token if login successful
    if (response.isSuccess && response.data != null) {
      final token = response.data!['token'];
      if (token != null) {
        NetworkManager.instance.updateAuthToken(token);
      }
    }

    return response;
  }

  /// Register user
  static Future<BaseApiResponse<Map<String, dynamic>>> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    final data = {
      'name': name,
      'email': email,
      'password': password,
      'password_confirmation': passwordConfirmation,
    };

    final response = await NetworkManager.instance.post<Map<String, dynamic>>(
      '$_basePath/register',
      data: data,
      fromJson: (json) => json,
    );

    // Update auth token if registration successful
    if (response.isSuccess && response.data != null) {
      final token = response.data!['token'];
      if (token != null) {
        NetworkManager.instance.updateAuthToken(token);
      }
    }

    return response;
  }

  /// Logout user
  static Future<BaseApiResponse<bool>> logout() async {
    try {
      final response = await NetworkManager.instance.post<bool>(
        '$_basePath/logout',
        fromJson: (json) => json['success'] ?? false,
      );

      // Clear auth token
      NetworkManager.instance.updateAuthToken('');
      return response;
    } catch (e) {
      // Return error response
      return BaseApiResponse<bool>(
        responseStatus: ResponseStatus(
          statusCode: 500,
          message: 'Logout failed',
          errorCode: 'LOGOUT_ERROR',
        ),
        totalCount: 0,
        index: 0,
        pageSize: 0,
        data: false,
      );
    }
  }

  /// Refresh token
  static Future<BaseApiResponse<Map<String, dynamic>>> refreshToken() async {
    final response = await NetworkManager.instance.post<Map<String, dynamic>>(
      '$_basePath/refresh',
      fromJson: (json) => json,
    );

    // Update auth token if refresh successful
    if (response.isSuccess && response.data != null) {
      final token = response.data!['token'];
      if (token != null) {
        NetworkManager.instance.updateAuthToken(token);
      }
    }

    return response;
  }

  /// Get current user profile
  static Future<BaseApiResponse<User>> getProfile() async {
    final response = await NetworkManager.instance.get<User>(
      '$_basePath/profile',
      fromJson: (json) => User.fromJson(json),
    );

    return response;
  }

  /// Update profile
  static Future<BaseApiResponse<User>> updateProfile({
    String? name,
    String? email,
    String? avatar,
  }) async {
    final data = <String, dynamic>{};
    if (name != null) data['name'] = name;
    if (email != null) data['email'] = email;
    if (avatar != null) data['avatar'] = avatar;

    final response = await NetworkManager.instance.put<User>(
      '$_basePath/profile',
      data: data,
      fromJson: (json) => User.fromJson(json),
    );

    return response;
  }
}
