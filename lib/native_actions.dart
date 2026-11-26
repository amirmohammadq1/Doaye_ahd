import 'package:flutter/services.dart';

/// ارتباط با ایمیل و مایکت (کد بومی در MainActivity.kt)
class NativeActions {
  static const MethodChannel _ch = MethodChannel('ir.doayeahd.app/actions');

  /// باز کردن برنامه‌ی ایمیل با گیرنده و موضوع آماده
  static Future<bool> openMail() async {
    try {
      return (await _ch.invokeMethod<bool>('openMail')) ?? false;
    } catch (_) {
      return false;
    }
  }

  /// باز کردن صفحه‌ی برنامه در مایکت برای امتیاز دادن
  static Future<bool> openMyket() async {
    try {
      return (await _ch.invokeMethod<bool>('openMyket')) ?? false;
    } catch (_) {
      return false;
    }
  }
}
