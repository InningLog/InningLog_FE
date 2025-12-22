class ApiEnvelope {
  // 공통 API 응답 래퍼: 서버가 내려주는 data/message/code/success를 담는다.
  final dynamic data;
  final String? message;
  final int? code;
  final bool? success;

  ApiEnvelope({required this.data, this.message, this.code, this.success});

  // JSON 맵을 ApiEnvelope 인스턴스로 변환
  factory ApiEnvelope.fromJson(Map<String, dynamic> json) {
    return ApiEnvelope(
      data: json['data'],
      message: json['message'] as String?,
      code: json['code'] is int ? json['code'] as int : null,
      success: json['success'] is bool ? json['success'] as bool : null,
    );
  }
}
