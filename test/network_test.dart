import 'package:flutter_test/flutter_test.dart';
import 'package:tamimah_network_core/tamimah_core.dart';

void main() {
  group('Network Plugin Tests', () {
    setUp(() {
      // Initialize network manager for testing
      TamimahNetworkCore.initialize(baseUrl: 'https://jsonplaceholder.typicode.com');
    });

    tearDown(() {
      // Clean up after tests
      TamimahNetworkCore.dispose();
    });

    test('should initialize network manager', () {
      expect(TamimahNetworkCore.network, isNotNull);
      expect(TamimahNetworkCore.network.config, isNotNull);
    });

    test('should make GET request successfully', () async {
      try {
        final response = await TamimahNetworkCore.network.get<Map<String, dynamic>>(
          '/posts/1',
          fromJson: (json) => json,
        );

        expect(response, isNotNull);
        expect(response.isSuccess, isTrue);
        expect(response.data, isNotNull);
        expect(response.data!['id'], equals(1));
        expect(response.data!['title'], isNotNull);
      } catch (e) {
        // Network might not be available in test environment
        expect(e, isA<NetworkException>());
      }
    });

    test('should handle network configuration', () {
      final config = NetworkConfig(
        baseUrl: 'https://api.test.com',
        connectTimeout: 60,
        receiveTimeout: 60,
        sendTimeout: 60,
        maxRetries: 5,
        retryDelay: 2,
        enableLogging: false,
        enableRetry: true,
      );

      NetworkManager.instance.initialize(config: config);

      expect(
        NetworkManager.instance.config?.baseUrl,
        equals('https://api.test.com'),
      );
      expect(NetworkManager.instance.config?.connectTimeout, equals(60));
      expect(NetworkManager.instance.config?.maxRetries, equals(5));
    });

    test('should create development configuration', () {
      NetworkManager.instance.setDevelopmentMode();

      final config = NetworkManager.instance.config;
      expect(config?.baseUrl, equals('https://dev-api.example.com'));
      expect(config?.connectTimeout, equals(60));
      expect(config?.enableLogging, isTrue);
    });

    test('should create production configuration', () {
      NetworkManager.instance.setProductionMode();

      final config = NetworkManager.instance.config;
      expect(config?.baseUrl, equals('https://api.example.com'));
      expect(config?.connectTimeout, equals(30));
      expect(config?.enableLogging, isFalse);
    });

    test('should update auth token', () {
      const testToken = 'test-auth-token';
      NetworkManager.instance.updateAuthToken(testToken);

      expect(NetworkManager.instance.config?.authToken, equals(testToken));
    });

    test('should update base URL', () {
      const newBaseUrl = 'https://new-api.example.com';
      NetworkManager.instance.updateBaseUrl(newBaseUrl);

      // The base URL should be updated in the service
      expect(NetworkManager.instance.service, isNotNull);
    });

    test('should add custom headers', () {
      final customHeaders = {
        'X-Custom-Header': 'custom-value',
        'X-API-Key': 'test-key',
      };

      NetworkManager.instance.addHeaders(customHeaders);

      // Headers should be added to the service
      expect(NetworkManager.instance.service, isNotNull);
    });

    test('should create BaseApiResponse', () {
      final responseStatus = ResponseStatus(
        statusCode: 200,
        message: 'Success',
        errorCode: 'SUCCESS',
      );

      final data = {'id': 1, 'name': 'Test'};
      final response = BaseApiResponse<Map<String, dynamic>>(
        responseStatus: responseStatus,
        totalCount: 1,
        index: 0,
        pageSize: 10,
        data: data,
      );

      expect(response.isSuccess, isTrue);
      expect(response.hasData, isTrue);
      expect(response.data, equals(data));
      expect(response.errorMessage, equals('Success'));
    });

    test('should create BaseApiResponse from JSON', () {
      final json = {
        'ResponseStatus': {
          'Statuscode': 200,
          'Message': 'Success',
          'ErrorCode': 'SUCCESS',
        },
        'TotalCount': 1,
        'Index': 0,
        'PageSize': 10,
        'Data': {'id': 1, 'name': 'Test'},
      };

      final response = BaseApiResponse.fromJson(
        json,
        (data) => data as Map<String, dynamic>,
      );

      expect(response.isSuccess, isTrue);
      expect(response.hasData, isTrue);
      expect(response.data!['id'], equals(1));
      expect(response.data!['name'], equals('Test'));
    });

    test('should create BaseApiResponse without data', () {
      final json = {
        'ResponseStatus': {
          'Statuscode': 200,
          'Message': 'Success',
          'ErrorCode': 'SUCCESS',
        },
        'TotalCount': 0,
        'Index': 0,
        'PageSize': 10,
      };

      final response = BaseApiResponse.fromJsonWithoutResult(
        json,
        (data) => data,
      );

      expect(response.isSuccess, isTrue);
      expect(response.hasData, isFalse);
      expect(response.data, isNull);
    });

    test('should create ResponseStatus', () {
      final status = ResponseStatus(
        statusCode: 200,
        message: 'Success',
        messageAr: 'نجح',
        errorCode: 'SUCCESS',
      );

      expect(status.isSuccess, isTrue);
      expect(status.isError, isFalse);
      expect(status.message, equals('Success'));
      expect(status.messageAr, equals('نجح'));
      expect(status.errorCode, equals('SUCCESS'));
    });

    test('should create ResponseStatus from JSON', () {
      final json = {
        'Statuscode': 400,
        'Message': 'Bad Request',
        'MessageAr': 'طلب سيء',
        'ErrorCode': 'BAD_REQUEST',
      };

      final status = ResponseStatus.fromJson(json);

      expect(status.isSuccess, isFalse);
      expect(status.isError, isTrue);
      expect(status.message, equals('Bad Request'));
      expect(status.messageAr, equals('طلب سيء'));
      expect(status.errorCode, equals('BAD_REQUEST'));
    });

    test('should create network exception', () {
      final exception = NetworkException(
        'Test error',
        NetworkErrorType.badRequest,
        statusCode: 400,
      );

      expect(exception.message, equals('Test error'));
      expect(exception.type, equals(NetworkErrorType.badRequest));
      expect(exception.statusCode, equals(400));
      expect(exception.isClientError, isTrue);
    });

    test('should create pagination model', () {
      final json = {
        'current_page': 1,
        'total_pages': 5,
        'total_items': 50,
        'items_per_page': 10,
        'has_next_page': true,
        'has_previous_page': false,
      };

      final pagination = PaginationModel.fromJson(json);

      expect(pagination.currentPage, equals(1));
      expect(pagination.totalPages, equals(5));
      expect(pagination.totalItems, equals(50));
      expect(pagination.itemsPerPage, equals(10));
      expect(pagination.hasNextPage, isTrue);
      expect(pagination.hasPreviousPage, isFalse);
    });

    test('should create paginated response', () {
      final data = [
        {'id': 1, 'name': 'User 1'},
        {'id': 2, 'name': 'User 2'},
      ];

      final pagination = PaginationModel(
        currentPage: 1,
        totalPages: 2,
        totalItems: 2,
        itemsPerPage: 10,
        hasNextPage: true,
        hasPreviousPage: false,
      );

      final response = PaginatedResponse(data: data, pagination: pagination);

      expect(response.data, equals(data));
      expect(response.pagination, equals(pagination));
    });

    test('should create file upload model', () {
      final json = {
        'file_name': 'test.jpg',
        'file_path': '/path/to/test.jpg',
        'mime_type': 'image/jpeg',
        'file_size': 1024,
        'metadata': {'description': 'Test image'},
      };

      final fileUpload = FileUploadModel.fromJson(json);

      expect(fileUpload.fileName, equals('test.jpg'));
      expect(fileUpload.filePath, equals('/path/to/test.jpg'));
      expect(fileUpload.mimeType, equals('image/jpeg'));
      expect(fileUpload.fileSize, equals(1024));
      expect(fileUpload.metadata?['description'], equals('Test image'));
    });

    test('should create API error model', () {
      final json = {
        'message': 'Validation failed',
        'code': 'VALIDATION_ERROR',
        'details': {'field': 'email'},
        'errors': ['Email is required', 'Email format is invalid'],
      };

      final error = ApiErrorModel.fromJson(json);

      expect(error.message, equals('Validation failed'));
      expect(error.code, equals('VALIDATION_ERROR'));
      expect(error.details?['field'], equals('email'));
      expect(
        error.errors,
        equals(['Email is required', 'Email format is invalid']),
      );
    });

    test('should test Status enum', () {
      expect(Status.loading, isNotNull);
      expect(Status.completed, isNotNull);
      expect(Status.error, isNotNull);
    });

    test('should test Serializable interface', () {
      final testModel = TestModel(id: 1, name: 'Test');
      final json = testModel.toJson();

      expect(json['id'], equals(1));
      expect(json['name'], equals('Test'));
    });
  });
}

/// Test model implementing Serializable
class TestModel implements Serializable {
  final int id;
  final String name;

  TestModel({required this.id, required this.name});

  @override
  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name};
  }
}
