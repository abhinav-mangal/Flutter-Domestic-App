import 'package:flutter/material.dart';
import 'package:energym/reusable_component/toast/flushbar.dart';
import 'package:easy_localization/easy_localization.dart';

class MessageBar {
  static Flushbar success(
      {@required String? message,
      Duration duration = const Duration(seconds: 5)}) {
    return Flushbar(
      flushbarPosition: FlushbarPosition.TOP,
      title: 'Success'.tr(),
      message: message,
      borderColor: const Color(0xFF8EDE59),
      borderWidth: 0,
      icon: Icon(
        Icons.check_circle,
        color: const Color(0xFF8EDE59),
      ),
      duration: duration,
    );
  }

  static Flushbar information(
      {@required String? message,
      Duration duration = const Duration(seconds: 5)}) {
    return Flushbar(
      flushbarPosition: FlushbarPosition.TOP,
      title: 'Info'.tr(),
      message: message,
      icon: Icon(
        Icons.info_outline,
        size: 28.0,
        color: const Color(0xFFFFA600),
      ),
      duration: duration,
      borderColor: const Color(0xFFFFA600),
    );
  }

  /// Get a error notification flushbar
  static Flushbar error(
      {@required String? message,
      Duration duration = const Duration(seconds: 5)}) {
    return Flushbar(
      title: 'Error'.tr(),
      flushbarPosition: FlushbarPosition.TOP,
      message: message,
      borderColor: const Color(0xFFDE5959),
      borderWidth: 0,
      icon: Icon(
        Icons.highlight_off,
        size: 28.0,
        color: const Color(0xFFDE5959),
      ),
      duration: duration,
    );
  }

  static Flushbar nonDismisable(
      {@required String? message,
      Duration duration = const Duration(seconds: 5)}) {
    return Flushbar(
        title: 'Error'.tr(),
        flushbarPosition: FlushbarPosition.TOP,
        message: message,
        borderColor: const Color(0xFFDE5959),
        borderWidth: 0,
        icon: Icon(
          Icons.highlight_off,
          size: 28.0,
          color: const Color(0xFFDE5959),
        ),
        duration: duration,
        isDismissible: false);
  }
}
