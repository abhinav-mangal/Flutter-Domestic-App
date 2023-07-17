import 'package:energym/reusable_component/custom_dialog.dart';
import 'package:energym/utils/common/constants.dart';
import 'package:energym/utils/common/validation.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:rxdart/rxdart.dart';
import 'package:energym/models/error_message_model.dart';

// Login bloc, all businesss logi relaetd signin here
class LoginBloc {
  final BehaviorSubject<bool> _validationLoginForm = BehaviorSubject<bool>();
  ValueStream<bool> get validateLoginForm => _validationLoginForm.stream;

  final BehaviorSubject<String> _mobileCodeController =
      BehaviorSubject<String>();

  ValueStream<String> get getMobileCode => _mobileCodeController.stream;

  final BehaviorSubject<String> _mobileNumberController =
      BehaviorSubject<String>();

  final BehaviorSubject<ErrorMessage> _moblieNumberErrorMessage =
      BehaviorSubject<ErrorMessage>();

  ValueStream<ErrorMessage> get getMoblieNumberErrorMessage =>
      _moblieNumberErrorMessage.stream;

  final BehaviorSubject<ErrorMessage> _mobileCodeErrorMessage =
      BehaviorSubject<ErrorMessage>();

  ValueStream<ErrorMessage> get getMobileCodeErrorMessage =>
      _mobileCodeErrorMessage.stream;

  void onChangeCountryCodeValidation(
      {String? value, bool isShowError = false}) {
    _mobileCodeController.sink.add(value!);
    validateCountryCode(isShowError: isShowError);
    validateLogin();
  }

  void onChangeMobileValidation({String? value, bool isShowError = false}) {
    _mobileNumberController.sink.add(value!);
    validateMobileNumber(isShowError: isShowError);
    validateLogin();
  }

  bool validateCountryCode({bool isShowError = false}) {
    bool isValid = true;
    final String code = _mobileCodeController.valueWrapper?.value ?? '';
    if (!Validation.instance.validateIsNotEmpty(code)) {
      if (isShowError) {
        _mobileCodeErrorMessage.sink
            .add(ErrorMessage(true, MsgConstants.enterMobileCode));
      } else {
        _mobileCodeErrorMessage.sink.add(ErrorMessage(false, ''));
      }

      isValid = false;
    } else {
      if (isShowError) {
        _mobileCodeErrorMessage.sink.add(ErrorMessage(false, ''));
      } else {
        _mobileCodeErrorMessage.sink.add(ErrorMessage(false, ''));
      }
      isValid = true;
    }

    return isValid;
  }

  bool validateMobileNumber({bool isShowError = false}) {
    bool isValid = true;

    final String validMobile =
        _mobileNumberController.valueWrapper?.value ?? '';
    if (Validation.instance.validateIsNotEmpty(validMobile) == false) {
      if (isShowError) {
        _moblieNumberErrorMessage.sink
            .add(ErrorMessage(true, MsgConstants.enterMobileNumber));
      } else {
        _moblieNumberErrorMessage.sink.add(ErrorMessage(false, ''));
      }

      isValid = false;
    } else if (Validation.instance.validateMobile(validMobile) != null) {
      isValid = false;
      if (isShowError) {
        _moblieNumberErrorMessage.sink
            .add(ErrorMessage(true, MsgConstants.enterValueMobileNumber));
      } else {
        _moblieNumberErrorMessage.sink.add(ErrorMessage(false, ''));
      }
      isValid = false;
    } else {
      if (isShowError) {
        _moblieNumberErrorMessage.sink.add(ErrorMessage(false, ''));
      } else {
        _moblieNumberErrorMessage.sink.add(ErrorMessage(false, ''));
      }
      isValid = true;
    }

    return isValid;
  }

  void validateLogin({bool isShowError = false}) {
    bool isValid = true;

    if (!validateCountryCode(isShowError: isShowError)) {
      isValid = false;
    }
    if (!validateMobileNumber(isShowError: isShowError)) {
      isValid = false;
    }

    _validationLoginForm.sink.add(isValid);
  }

  void dispose() {
    _validationLoginForm.close();
    _mobileCodeController.close();
    _mobileNumberController.close();

    _mobileCodeErrorMessage.close();
    _moblieNumberErrorMessage.close();
  }

  bool validation(
      {required String email,
      required String password,
      required BuildContext context}) {
    bool isValid = true;
    if (email.trim().isEmpty) {
      isValid = false;
      _displayAlert(context, MsgConstants.enterEmail);
    } else if (Validation.instance.validateEmail(email) != null) {
      isValid = false;
      _displayAlert(context, MsgConstants.enterValidEmail);
    } else if (password.trim().isEmpty) {
      isValid = false;
      _displayAlert(context, MsgConstants.password);
    }
    return isValid;
  }

  _displayAlert(BuildContext context, String message) {
    CustomAlertDialog().showAlert(
        context: context, message: message, title: AppConstants.appName);
  }
}
