import 'package:energym/models/error_message_model.dart';
import 'package:energym/utils/common/constants.dart';
import 'package:energym/utils/common/validation.dart';
import 'package:energym/utils/helpers/firebase/firestore_provider.dart';
import 'package:energym/utils/helpers/validation_helper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:energym/models/error_message_model.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:energym/models/comment_model.dart';

class CommentBloc {
  final BehaviorSubject<bool> _validationCommentForm = BehaviorSubject<bool>();
  ValueStream<bool> get validateCommentForm => _validationCommentForm.stream;

  final BehaviorSubject<String> _messageController = BehaviorSubject<String>();
  final BehaviorSubject<ErrorMessage> _messageErrorMessage =
      BehaviorSubject<ErrorMessage>();
  ValueStream<ErrorMessage> get getMessageErrorMessage =>
      _messageErrorMessage.stream;

  final BehaviorSubject<List<CommentModel>> _feedComment =
      BehaviorSubject<List<CommentModel>>();

  ValueStream<List<CommentModel>> get getFeedComment => _feedComment.stream;

  List<CommentModel> feedList = <CommentModel>[];
  DocumentSnapshot<Map<String, dynamic>?>? lastDocument;
  bool isLoadingComment = false;

  void onChangeMessageValidation({String? value, bool isShowError = false}) {
    _messageController.sink.add(value!);
    validateMessage(isShowError: isShowError);
    validateComment(isShowError: false);
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

  void validateComment({bool isShowError = false}) {
    bool isValid = true;
    if (!validateMessage(isShowError: isShowError)) {
      isValid = false;
    }
    _validationCommentForm.sink.add(isValid);
  }

  Future<void> getComment(BuildContext mainContext, String feedId,
      {bool isReset = false}) async {
    if (!isLoadingComment) {
      isLoadingComment = true;
      if (isReset) {
        lastDocument = null;
        feedList.clear();
        _feedComment.sink.add(feedList);
      }
      final List<DocumentSnapshot<Map<String, dynamic>?>?>? _list =
          await FireStoreProvider.instance.fetchPostComment(mainContext,
              docmentLimit: 50, lastDocument: lastDocument, feedId: feedId);

      if (_list != null && _list.isNotEmpty) {
        lastDocument = _list.first;
        List<CommentModel> _listModel = <CommentModel>[];
        _list.forEach((document) async {
          _listModel.add(CommentModel.fromJson(document!.data()!));
        });
        feedList.addAll(_listModel);
        isLoadingComment = false;
        _feedComment.sink.add(feedList);
      } else {
        isLoadingComment = false;
        _feedComment.sink.add(feedList);
      }
    }
  }

  void updateCommemt(List<CommentModel> list) {
    feedList = list;
    _feedComment.sink.add(feedList);
  }

  void dispose() {
    _feedComment.close();
    _validationCommentForm.close();
    _messageController.close();
    _messageErrorMessage.close();
  }
}
