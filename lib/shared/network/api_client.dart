import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../auth/token_storage.dart';
import 'app_error.dart';

class ApiClient {
  final Dio dio;

  // 앱 공통 Dio 클라이언트 설정: 기본 옵션 + 인증/로그/에러 매핑 인터셉터 구성
  ApiClient({required String baseUrl, required TokenStorage tokenStorage})
    : dio = Dio(
        BaseOptions(
          baseUrl: baseUrl,
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 20),
          headers: {'Accept': 'application/json'},
        ),
      ) {
    dio.interceptors.add(_AuthInterceptor(tokenStorage));

    if (kDebugMode) {
      dio.interceptors.add(
        LogInterceptor(
          requestBody: true,
          responseBody: true,
          requestHeader: true,
          responseHeader: false,
        ),
      );
    }

    // 에러를 AppError로 통일해 던지도록 (선택)
    dio.interceptors.add(_ErrorMapInterceptor());
  }
}

// 요청마다 저장된 액세스 토큰을 Authorization 헤더에 붙이는 인터셉터
class _AuthInterceptor extends Interceptor {
  final TokenStorage tokenStorage;
  _AuthInterceptor(this.tokenStorage);

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await tokenStorage.readAccessToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }
}

// DioException을 AppError 계층으로 변환해 에러 핸들링을 단순화
class _ErrorMapInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // 이미 AppError로 감싸졌으면 그대로
    if (err.error is AppError) return handler.next(err);

    final status = err.response?.statusCode;
    final data = err.response?.data;
    final msg = _extractMessage(data) ?? err.message ?? '요청에 실패했습니다.';

    AppError mapped;
    if (err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.sendTimeout) {
      mapped = NetworkError('네트워크 타임아웃: $msg');
    } else if (err.type == DioExceptionType.unknown &&
        err.error is SocketException) {
      mapped = NetworkError('네트워크 연결 실패');
    } else if (status == 401) {
      mapped = const UnauthorizedError();
    } else if (status == 404) {
      mapped = const NotFoundError();
    } else if (status == 400) {
      mapped = BadRequestError(msg, code: _extractCode(data));
    } else if (status != null && status >= 500) {
      mapped = ServerError('서버 오류($status): $msg');
    } else {
      mapped = UnknownError(msg);
    }

    handler.next(err.copyWith(error: mapped));
  }

  String? _extractMessage(dynamic data) {
    if (data is Map<String, dynamic>) {
      final m = data['message'];
      if (m != null) return m.toString();
    }
    return null;
  }

  String? _extractCode(dynamic data) {
    if (data is Map<String, dynamic>) {
      final c = data['code'];
      if (c != null) return c.toString();
    }
    return null;
  }
}
