import 'package:energym/models/error_message_model.dart';
import 'package:energym/utils/common/constants.dart';
import 'package:energym/utils/common/validation.dart';
import 'package:energym/utils/helpers/validation_helper.dart';
import 'package:rxdart/rxdart.dart';

class ReportBloc {
  final BehaviorSubject<bool> _validationReportForm = BehaviorSubject<bool>();
  ValueStream<bool> get validateReportForm => _validationReportForm.stream;

  final BehaviorSubject<String> _messageController = BehaviorSubject<String>();
  final BehaviorSubject<ErrorMessage> _messageErrorMessage =
      BehaviorSubject<ErrorMessage>();
  ValueStream<ErrorMessage> get getMessageErrorMessage =>
      _messageErrorMessage.stream;

  void onChangeMessageValidation({String? value, bool isShowError = false}) {
    _messageController.sink.add(value!);
    validateMessage(isShowError: isShowError);
    validateReport(isShowError: false);
  }

  bool validateMessage({bool isShowError = false}) {
    bool isValid = true;
    final String validMessage = _messageController.valueWrapper?.value ?? '';
    if (Validation.instance.validateIsNotEmpty(validMessage) == false) {
      if (isShowError) {
        _messageErrorMessage.sink
            .add(ErrorMessage(true, AppConstants.enterReport));
      }

      isValid = false;
    } else {
      if (isShowError) {
        _messageErrorMessage.sink.add(ErrorMessage(false, ''));
      }
      isValid = true;
    }

    return isValid;
  }

  void validateReport({bool isShowError = false}) {
    bool isValid = true;
    if (!validateMessage(isShowError: isShowError)) {
      isValid = false;
    }
    _validationReportForm.sink.add(isValid);
  }

  void dispose() {
    _validationReportForm.close();
    _messageController.close();
    _messageErrorMessage.close();
  }
}
