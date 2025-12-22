sealed class AppError implements Exception {
  // 네트워크 계층에서 공통으로 사용할 에러 베이스 클래스
  final String message;
  const AppError(this.message);

  @override
  String toString() => '$runtimeType: $message';
}

// 네트워크 타임아웃/연결 실패 등 네트워크 장애
class NetworkError extends AppError {
  const NetworkError(super.message);
}

// 인증 필요(401)
class UnauthorizedError extends AppError {
  const UnauthorizedError([super.message = '인증이 필요합니다.']);
}

// 리소스 없음(404)
class NotFoundError extends AppError {
  const NotFoundError([super.message = '요청한 리소스를 찾을 수 없습니다.']);
}

// 잘못된 요청(400) — 서버 코드가 함께 올 수 있음
class BadRequestError extends AppError {
  final String? code;
  const BadRequestError(super.message, {this.code});
}

// 서버 오류(5xx)
class ServerError extends AppError {
  const ServerError([super.message = '서버 오류가 발생했습니다.']);
}

// 응답 파싱 실패
class ParseError extends AppError {
  const ParseError([super.message = '응답 파싱에 실패했습니다.']);
}

// 분류되지 않은 오류
class UnknownError extends AppError {
  const UnknownError([super.message = '알 수 없는 오류가 발생했습니다.']);
}
