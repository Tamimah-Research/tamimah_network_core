/// Base API response model
class BaseApiResponse<T> {
  ResponseStatus? responseStatus;
  int? totalCount;
  int? index;
  int? pageSize;
  T? data;

  BaseApiResponse({
    required this.responseStatus,
    required this.totalCount,
    required this.index,
    required this.pageSize,
    this.data,
  });

  factory BaseApiResponse.fromJson(
    Map<String, dynamic> json,
    Function(dynamic) create,
  ) {
    var payLoadResponse = json["Data"];
    var isPayLoadNull = payLoadResponse == null;
    if (isPayLoadNull) {
      return BaseApiResponse<T>(
        responseStatus: ResponseStatus.fromJson(json["ResponseStatus"]),
        totalCount: json["TotalCount"] ?? 0,
        index: json["Index"] ?? 0,
        pageSize: json["PageSize"] ?? 0,
      );
    } else {
      return BaseApiResponse<T>(
        responseStatus: ResponseStatus.fromJson(json["ResponseStatus"]),
        totalCount: json["TotalCount"] ?? 0,
        index: json["Index"] ?? 0,
        pageSize: json["PageSize"] ?? 0,
        data: create(json["Data"]),
      );
    }
  }

  factory BaseApiResponse.fromJsonList(
    Map<String, dynamic> json,
    Function(List<dynamic>) create,
  ) {
    var payLoadResponse = json["Data"];
    var isPayLoadNull = payLoadResponse == null;
    if (isPayLoadNull) {
      return BaseApiResponse<T>(
        responseStatus: ResponseStatus.fromJson(json["ResponseStatus"]),
        totalCount: json["TotalCount"] ?? 0,
        index: json["Index"] ?? 0,
        pageSize: json["PageSize"] ?? 0,
      );
    } else {
      return BaseApiResponse<T>(
        responseStatus: ResponseStatus.fromJson(json["ResponseStatus"]),
        totalCount: json["TotalCount"] ?? 0,
        index: json["Index"] ?? 0,
        pageSize: json["PageSize"] ?? 0,
        data: create(json["Data"]),
      );
    }
  }

  factory BaseApiResponse.fromJsonWithoutResult(
    Map<String, dynamic> json,
    Function(Map<String, dynamic>) create,
  ) {
    return BaseApiResponse(
      responseStatus: ResponseStatus.fromJson(json["ResponseStatus"]),
      totalCount: json["TotalCount"],
      index: json["Index"],
      pageSize: json["PageSize"],
    );
  }

  /// Check if response is successful
  bool get isSuccess => responseStatus?.statusCode == 200;

  /// Check if response has data
  bool get hasData => data != null;

  /// Get data or throw exception if null
  T get dataOrThrow {
    if (data == null) {
      throw Exception('Data is null in successful response');
    }
    return data!;
  }

  /// Get data with fallback
  T? get dataOrNull => data;

  /// Get error message
  String get errorMessage => responseStatus?.message ?? 'Unknown error';

  /// Get Arabic error message
  String? get errorMessageAr => responseStatus?.messageAr;
}

/// Response status model
class ResponseStatus {
  int? statusCode;
  String message;
  String? messageAr;
  String errorCode;

  ResponseStatus({
    required this.statusCode,
    required this.message,
    this.messageAr,
    required this.errorCode,
  });

  factory ResponseStatus.fromJson(Map<String, dynamic> json) => ResponseStatus(
    statusCode: json["Statuscode"],
    message: json["Message"],
    messageAr: json["MessageAr"],
    errorCode: json["ErrorCode"],
  );

  Map<String, dynamic> toJson() => {
    "Statuscode": statusCode,
    "Message": message,
    "MessageAr": messageAr,
    "ErrorCode": errorCode,
  };

  /// Check if status is successful
  bool get isSuccess => statusCode == 200;

  /// Check if status is error
  bool get isError => statusCode != null && statusCode! >= 400;
}

/// Serializable interface
abstract class Serializable {
  Map<String, dynamic> toJson();
}

/// Status enum for UI states
enum Status { loading, completed, error }

/// Base model for API responses
abstract class BaseModel implements Serializable {
  @override
  Map<String, dynamic> toJson();

  /// Create from JSON
  static T fromJson<T extends BaseModel>(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    return fromJson(json);
  }
}

/// Pagination model
class PaginationModel {
  final int currentPage;
  final int totalPages;
  final int totalItems;
  final int itemsPerPage;
  final bool hasNextPage;
  final bool hasPreviousPage;

  const PaginationModel({
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
    required this.itemsPerPage,
    required this.hasNextPage,
    required this.hasPreviousPage,
  });

  factory PaginationModel.fromJson(Map<String, dynamic> json) {
    return PaginationModel(
      currentPage: json['current_page'] ?? json['page'] ?? json['Index'] ?? 1,
      totalPages: json['total_pages'] ?? json['last_page'] ?? 1,
      totalItems:
          json['total_items'] ?? json['total'] ?? json['TotalCount'] ?? 0,
      itemsPerPage:
          json['items_per_page'] ?? json['per_page'] ?? json['PageSize'] ?? 10,
      hasNextPage: json['has_next_page'] ?? json['has_next'] ?? false,
      hasPreviousPage: json['has_previous_page'] ?? json['has_prev'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'current_page': currentPage,
      'total_pages': totalPages,
      'total_items': totalItems,
      'items_per_page': itemsPerPage,
      'has_next_page': hasNextPage,
      'has_previous_page': hasPreviousPage,
    };
  }
}

/// Paginated response wrapper
class PaginatedResponse<T> {
  final List<T> data;
  final PaginationModel pagination;

  const PaginatedResponse({required this.data, required this.pagination});

  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    final data =
        (json['data'] as List<dynamic>?)
            ?.map((item) => fromJson(item as Map<String, dynamic>))
            .toList() ??
        <T>[];

    final pagination = PaginationModel.fromJson(
      json['pagination'] ?? json['meta'] ?? {},
    );

    return PaginatedResponse(data: data, pagination: pagination);
  }

  Map<String, dynamic> toJson() {
    return {'data': data, 'pagination': pagination.toJson()};
  }
}

/// File upload model
class FileUploadModel {
  final String fileName;
  final String filePath;
  final String mimeType;
  final int fileSize;
  final Map<String, dynamic>? metadata;

  const FileUploadModel({
    required this.fileName,
    required this.filePath,
    required this.mimeType,
    required this.fileSize,
    this.metadata,
  });

  factory FileUploadModel.fromJson(Map<String, dynamic> json) {
    return FileUploadModel(
      fileName: json['file_name'] ?? json['name'] ?? '',
      filePath: json['file_path'] ?? json['path'] ?? '',
      mimeType: json['mime_type'] ?? json['type'] ?? '',
      fileSize: json['file_size'] ?? json['size'] ?? 0,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'file_name': fileName,
      'file_path': filePath,
      'mime_type': mimeType,
      'file_size': fileSize,
      'metadata': metadata,
    };
  }
}

/// API error model
class ApiErrorModel {
  final String message;
  final String? code;
  final Map<String, dynamic>? details;
  final List<String>? errors;

  const ApiErrorModel({
    required this.message,
    this.code,
    this.details,
    this.errors,
  });

  factory ApiErrorModel.fromJson(Map<String, dynamic> json) {
    return ApiErrorModel(
      message: json['message'] ?? 'Unknown error',
      code: json['code'],
      details: json['details'] as Map<String, dynamic>?,
      errors: (json['errors'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'code': code,
      'details': details,
      'errors': errors,
    };
  }
}

/// Request model for common operations
class RequestModel {
  final Map<String, dynamic> data;
  final Map<String, dynamic>? queryParameters;
  final Map<String, dynamic>? headers;

  const RequestModel({required this.data, this.queryParameters, this.headers});

  Map<String, dynamic> toJson() {
    return {
      'data': data,
      'queryParameters': queryParameters,
      'headers': headers,
    };
  }
}

/// Response model for common operations
class ResponseModel<T> {
  final T? data;
  final bool success;
  final String? message;
  final int? statusCode;
  final ApiErrorModel? error;

  const ResponseModel({
    this.data,
    required this.success,
    this.message,
    this.statusCode,
    this.error,
  });

  factory ResponseModel.success(T data, {String? message, int? statusCode}) {
    return ResponseModel(
      data: data,
      success: true,
      message: message,
      statusCode: statusCode,
    );
  }

  factory ResponseModel.error(
    String message, {
    int? statusCode,
    ApiErrorModel? error,
  }) {
    return ResponseModel(
      success: false,
      message: message,
      statusCode: statusCode,
      error: error,
    );
  }

  factory ResponseModel.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>)? fromJson,
  ) {
    final success = json['success'] ?? json['status'] == 'success';
    final message = json['message'];
    final statusCode = json['status_code'];

    if (success && fromJson != null && json['data'] != null) {
      final data = fromJson(json['data']);
      return ResponseModel.success(
        data,
        message: message,
        statusCode: statusCode,
      );
    } else {
      final error = json['error'] != null
          ? ApiErrorModel.fromJson(json['error'])
          : null;
      return ResponseModel.error(
        message ?? 'Unknown error',
        statusCode: statusCode,
        error: error,
      );
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'data': data,
      'success': success,
      'message': message,
      'status_code': statusCode,
      'error': error?.toJson(),
    };
  }
}
