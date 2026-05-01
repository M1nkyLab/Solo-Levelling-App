/// api_response.dart
///
/// Standardized response structure for all service-level "endpoints".
/// Follows the API Endpoint Builder guidelines for consistent response formatting.
library api_response;

class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? error;
  final Map<String, dynamic>? details;

  ApiResponse({
    required this.success,
    this.data,
    this.error,
    this.details,
  });

  /// Factory for successful responses
  factory ApiResponse.success(T data) {
    return ApiResponse(
      success: true,
      data: data,
    );
  }

  /// Factory for error responses
  factory ApiResponse.error(String message, {Map<String, dynamic>? details}) {
    return ApiResponse(
      success: false,
      error: message,
      details: details,
    );
  }

  @override
  String toString() {
    if (success) {
      return 'ApiResponse(success: true, data: $data)';
    } else {
      return 'ApiResponse(success: false, error: $error, details: $details)';
    }
  }
}
