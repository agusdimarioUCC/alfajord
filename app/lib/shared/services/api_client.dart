import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ApiClient {
  ApiClient()
      : _dio = Dio(
          BaseOptions(
            baseUrl: 'http://localhost:4000/api/',
            connectTimeout: const Duration(seconds: 10),
            receiveTimeout: const Duration(seconds: 10),
          ),
        ) {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        if (_token != null) {
          options.headers['Authorization'] = 'Bearer $_token';
        }
        handler.next(options);
      },
      onError: (error, handler) {
        handler.next(error);
      },
    ));
  }

  final Dio _dio;
  String? _token;

  void updateToken(String? token) {
    _token = token;
  }

  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.get<dynamic>(
        path,
        queryParameters: queryParameters,
      );
      return response.data;
    } on DioException catch (error) {
      throw Exception(_mapError(error));
    }
  }

  Future<dynamic> post(
    String path, {
    dynamic data,
  }) async {
    try {
      final response = await _dio.post<dynamic>(path, data: data);
      return response.data;
    } on DioException catch (error) {
      throw Exception(_mapError(error));
    }
  }

  Future<dynamic> put(
    String path, {
    dynamic data,
  }) async {
    try {
      final response = await _dio.put<dynamic>(path, data: data);
      return response.data;
    } on DioException catch (error) {
      throw Exception(_mapError(error));
    }
  }

  Future<dynamic> delete(String path) async {
    try {
      final response = await _dio.delete<dynamic>(path);
      return response.data;
    } on DioException catch (error) {
      throw Exception(_mapError(error));
    }
  }

  String _mapError(DioException error) {
    if (error.response?.data is Map<String, dynamic>) {
      final data = error.response!.data as Map<String, dynamic>;
      return data['error'] as String? ?? 'Error inesperado';
    }
    return 'Error de red. Intentalo de nuevo.';
  }
}

final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());
