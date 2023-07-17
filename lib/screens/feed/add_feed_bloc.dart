import 'dart:io';

import 'package:energym/utils/common/constants.dart';
import 'package:energym/utils/common/validation.dart';
import 'package:rxdart/rxdart.dart';
import 'package:energym/models/error_message_model.dart';

class AddFeedBloc {
  final BehaviorSubject<bool> _validationPostForm = BehaviorSubject<bool>();
  ValueStream<bool> get validatePostForm => _validationPostForm.stream;

  
  
  final BehaviorSubject<String> _whatsInMindController =
      BehaviorSubject<String>();

  final BehaviorSubject<ErrorMessage> _whatsInMindErrorMessage =
      BehaviorSubject<ErrorMessage>();

  ValueStream<ErrorMessage> get getWhatsInMindErrorMessage =>
      _whatsInMindErrorMessage.stream;

  final BehaviorSubject<File?> _postAttachment = BehaviorSubject<File?>();
  ValueStream<File?> get getPostAttachment => _postAttachment.stream;


  void onChangeWhatsInMind({String? value, bool isShowError = false}) {
    _whatsInMindController.sink.add(value!);
    validateWhatsInMind(isShowError: isShowError);
    validatePost();
  }

  void updateAttachement({File? value, bool isShowError = false}) {
    _postAttachment.sink.add(value);
   
  }

  bool validateWhatsInMind({bool isShowError = false}) {
    bool isValid = true;
    final String text = _whatsInMindController.valueWrapper?.value ?? '';
    if (!Validation.instance.validateIsNotEmpty(text)) {
      if (isShowError) {
        _whatsInMindErrorMessage.sink
            .add(ErrorMessage(true, MsgConstants.enterMobileCode));
      } else {
        _whatsInMindErrorMessage.sink.add(ErrorMessage(false, ''));
      }

      isValid = false;
    } else {
      if (isShowError) {
        _whatsInMindErrorMessage.sink.add(ErrorMessage(false, ''));
      } else {
        _whatsInMindErrorMessage.sink.add(ErrorMessage(false, ''));
      }
      isValid = true;
    }

    return isValid;
  }
  

  

  void validatePost({bool isShowError = false}) {
    bool isValid = true;
    
    if (!validateWhatsInMind(isShowError: isShowError)) {
      isValid = false;
    }
    
   
    _validationPostForm.sink.add(isValid);
  }

  void dispose() {
    _validationPostForm.close();
    _whatsInMindController.close();

  }
}
