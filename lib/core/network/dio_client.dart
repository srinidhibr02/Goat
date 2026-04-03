import 'package:dio/dio.dart';

import '../constants/app_constants.dart';
import '../errors/exceptions.dart';
import 'package:goat/core/utils/logger.dart';

/// Pre-configured [Dio] HTTP client for the GOAT app.
///
/// Includes timeout configuration, logging interceptor, and
/// automatic error mapping to [ServerException].
class DioClient {
  late final Dio _dio;

  DioClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.apiBaseUrl,
        connectTimeout: const Duration(seconds: AppConstants.connectTimeout),
        receiveTimeout: const Duration(seconds: AppConstants.receiveTimeout),
        sendTimeout: const Duration(seconds: AppConstants.sendTimeout),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.addAll([
      _LoggingInterceptor(),
    ]);
  }

  /// The underlying [Dio] instance for direct use if needed.
  Dio get dio => _dio;

  // ── Convenience Methods ─────────────────────────────────────────────

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _mapDioException(e);
    }
  }

  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _mapDioException(e);
    }
  }

  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Options? options,
  }) async {
    try {
      return await _dio.put<T>(path, data: data, options: options);
    } on DioException catch (e) {
      throw _mapDioException(e);
    }
  }

  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Options? options,
  }) async {
    try {
      return await _dio.delete<T>(path, data: data, options: options);
    } on DioException catch (e) {
      throw _mapDioException(e);
    }
  }

  // ── Helpers ─────────────────────────────────────────────────────────

  ServerException _mapDioException(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ServerException(
          message: 'Connection timed out',
          statusCode: e.response?.statusCode,
        );
      case DioExceptionType.badResponse:
        return ServerException(
          message: e.response?.statusMessage ?? 'Bad response',
          statusCode: e.response?.statusCode,
        );
      case DioExceptionType.connectionError:
        return const ServerException(message: 'No internet connection');
      default:
        return ServerException(
          message: e.message ?? 'Unexpected network error',
        );
    }
  }
}

/// Logs outgoing requests and incoming responses via [AppLogger].
class _LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    AppLogger.info(
      '→ ${options.method} ${options.uri}',
      tag: 'HTTP',
    );
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    AppLogger.info(
      '← ${response.statusCode} ${response.requestOptions.uri}',
      tag: 'HTTP',
    );
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    AppLogger.error(
      '✖ ${err.type} ${err.requestOptions.uri}',
      tag: 'HTTP',
      error: err,
    );
    handler.next(err);
  }
}
