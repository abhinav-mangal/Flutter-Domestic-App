import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:sms_autofill/sms_autofill.dart';
import 'package:energym/models/error_message_model.dart';

class OtpVerificationBloc {
  final BehaviorSubject<bool> _otpSubmitSubject = BehaviorSubject<bool>();

  final BehaviorSubject<String> _otpValidateSubject = BehaviorSubject<String>();

  final BehaviorSubject<ErrorMessage> _otpErrorSubject =
      BehaviorSubject<ErrorMessage>();

  final BehaviorSubject<bool> _resendVisibleSubject = BehaviorSubject<bool>();

  final BehaviorSubject<int> _resendTimerSubject = BehaviorSubject<int>();

  //TextEditingController _otpController;
  String? appSignature;

  Stream<bool>? get otpSubmitStream => _otpSubmitSubject.stream;

  Sink<String>? get otpValidateStream => _otpValidateSubject.sink;

  Stream<ErrorMessage>? get otpErrorStream => _otpErrorSubject.stream;

  Stream<bool>? get resendVisibleStream => _resendVisibleSubject.stream;

  Sink<bool>? get resendVisibleSink => _resendVisibleSubject.sink;

  Stream<int>? get resendTimeStream => _resendTimerSubject.stream;

  Sink<int>? get resendTimerSink => _resendTimerSubject.sink;

  bool? get otpSubmitState => _otpSubmitSubject.value;

  Timer? _timer;

  // ignore: sort_constructors_first
  OtpVerificationBloc() {
    //_otpController = otpController;
    _fetchAppSignature();
    _otpValidateSubject.stream.listen((String otp) {
      _otpErrorSubject.sink.add(ErrorMessage(false, ''));
      _validateOtp(otp);
    });
  }

  void onChangeOtp(String value) {
    _otpValidateSubject.sink.add(value);
  }

  void _validateOtp(String otp) {
    if (otp.isNotEmpty && otp.length >= 6) {
      _otpSubmitSubject.sink.add(true);
    } else {
      _otpSubmitSubject.sink.add(false);
    }
  }

  void showTimer() {
    int start = 59;
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      if (start <= 1) {
        timer.cancel();
        _resendVisibleSubject.sink.add(true);
      } else {
        start = start - 1;
        _resendTimerSubject.sink.add(start);
      }
    });
  }

  Future<void> _fetchAppSignature() async {
    appSignature = await SmsAutoFill().getAppSignature;
  }

  void dispose() {
    _otpSubmitSubject.close();
    _otpValidateSubject.close();
    _otpErrorSubject.close();
    _resendVisibleSubject.close();
    _resendTimerSubject.close();
    if (_timer != null) {
      _timer!.cancel();
    }
  }
}
