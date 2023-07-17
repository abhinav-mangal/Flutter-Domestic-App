import 'dart:io';

import 'package:energym/models/error_message_model.dart';
import 'package:energym/models/follower_model.dart';
import 'package:energym/utils/common/constants.dart';
import 'package:energym/utils/common/validation.dart';
import 'package:rxdart/rxdart.dart';

class AddGroupBloc {
  final BehaviorSubject<bool> _addGroupFormValid = BehaviorSubject<bool>();
  final BehaviorSubject<ErrorMessage> _groupImageErrorMessage =
      BehaviorSubject<ErrorMessage>();
  final BehaviorSubject<File?> _groupImageController =
      BehaviorSubject<File?>.seeded(null);
  final BehaviorSubject<String> _groupName = BehaviorSubject<String>();
  final BehaviorSubject<ErrorMessage> _groupNameErrorMessage =
      BehaviorSubject<ErrorMessage>();

  ValueStream<bool> get getAddGroupFormValid => _addGroupFormValid.stream;
  ValueStream<ErrorMessage> get getGroupImageErrorMessage =>
      _groupImageErrorMessage.stream;
  ValueStream<File?> get getGroupImage => _groupImageController.stream;
  ValueStream<String> get getGroupName => _groupName.stream;
  ValueStream<ErrorMessage> get getGroupNameErrorMessage =>
      _groupNameErrorMessage.stream;

  final BehaviorSubject<List<FollowerModel>> _groupMember =
      BehaviorSubject<List<FollowerModel>>();
  ValueStream<List<FollowerModel>> get getGroupMamber => _groupMember.stream;

  void onChangeProfilePic({File? value, bool isShowError = false, bool isFromAddGroup = false}) {
    _groupImageController.sink.add(value!);
    validateProfilePic(isShowError: isShowError);
    validateAddGroupForm(isFromAddGroup: isFromAddGroup);
  }

  bool validateProfilePic({bool isShowError = false}) {
    bool isValid = true;
    final File? validPofilePic = _groupImageController.valueWrapper?.value;
    if (validPofilePic == null) {
      if (isShowError) {
        // _groupImageErrorMessage.sink
        //     .add(ErrorMessage(true, MsgConstants.selectProfilePicture));
      }
      isValid = false;
    } else {
      if (isShowError) {
        //_groupImageErrorMessage.sink.add(ErrorMessage(false, ''));
      }

      isValid = true;
    }
    _addGroupFormValid.sink.add(isValid);
    return isValid;
  }

  void onChangeGroupName({String? value, bool isShowError = false}) {
    _groupName.sink.add(value!);
    validateGroupName(isShowError: isShowError);
    validateAddGroupForm();
  }

  bool validateGroupName({bool isShowError = false}) {
    bool isValid = true;
    final String validFullName = _groupName.valueWrapper?.value ?? '';
    if (Validation.instance.validateIsNotEmpty(validFullName) == false) {
      if (isShowError) {
        _groupNameErrorMessage.sink
            .add(ErrorMessage(true, MsgConstants.enterGroupName));
      }

      isValid = false;
    } else {
      if (isShowError) {
        _groupNameErrorMessage.sink.add(ErrorMessage(false, ''));
      }
      isValid = true;
    }
    _addGroupFormValid.sink.add(isValid);
    return isValid;
  }

  void updateFollower(List<FollowerModel> list) {
    _groupMember.sink.add(list);
    validateGroupParticipantes(isShowError: false);
    validateAddGroupForm();
  }

  bool validateGroupParticipantes({bool isShowError = false}) {
    bool isValid = true;
    final List<FollowerModel> list = _groupMember.valueWrapper?.value ?? [];
    if (list == null || list.isEmpty) {
      isValid = false;
    } else {
      
      isValid = true;
    }
    _addGroupFormValid.sink.add(isValid);
    return isValid;
  }

  void validateAddGroupForm({bool isShowError = false, bool isFromAddGroup = false}) {
    bool isValid = true;

    if (isFromAddGroup) {
      if (!validateProfilePic(isShowError: isShowError)) {
        isValid = false;
      }
    }
    if (!validateGroupName(isShowError: isShowError)) {
      isValid = false;
    }
    if (!validateGroupParticipantes(isShowError: isShowError)) {
      isValid = false;
    }
    

    _addGroupFormValid.sink.add(isValid);
  }

  void dispose() {
    _groupImageController.close();
    _addGroupFormValid.close();
    _groupImageErrorMessage.close();
    _groupName.close();
    _groupNameErrorMessage.close();
  }
}
