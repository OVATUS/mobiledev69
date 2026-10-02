import 'package:dio/dio.dart';

/// แปลง Exception ทางเทคนิคให้เป็นข้อความภาษาไทยที่ผู้ใช้อ่านเข้าใจ
String mapErrorToMessage(Object error) {
  if (error is DioException) {
    switch (error.type) {
      case DioExceptionType.connectionError:
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'เชื่อมต่อเซิร์ฟเวอร์ไม่ได้ กรุณาตรวจสอบอินเทอร์เน็ตหรือว่า backend เปิดอยู่';
      case DioExceptionType.badResponse:
        return _messageFromStatus(error.response);
      default:
        break;
    }
  }
  return 'เกิดข้อผิดพลาดที่ไม่คาดคิด กรุณาลองใหม่อีกครั้ง';
}

String _messageFromStatus(Response? response) {
  final status = response?.statusCode ?? 0;
  if (status == 400) {
    // Django REST Framework ส่ง error เป็น {"field": ["message"]}
    final data = response?.data;
    if (data is Map && data.isNotEmpty) {
      final first = data.values.first;
      if (first is List && first.isNotEmpty) return 'ข้อมูลไม่ถูกต้อง: ${first.first}';
    }
    return 'ข้อมูลไม่ถูกต้อง กรุณาตรวจสอบอีกครั้ง';
  }
  if (status == 401) return 'เซสชันหมดอายุ กรุณาเข้าสู่ระบบใหม่';
  if (status == 403) return 'คุณไม่มีสิทธิ์ทำรายการนี้';
  if (status == 404) return 'ไม่พบข้อมูล อาจถูกลบไปแล้ว';
  if (status >= 500) return 'เซิร์ฟเวอร์ขัดข้อง กรุณาลองใหม่ภายหลัง';
  return 'เกิดข้อผิดพลาด (รหัส $status)';
}