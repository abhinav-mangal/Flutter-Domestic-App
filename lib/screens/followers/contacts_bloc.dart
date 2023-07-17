import 'package:energym/models/user_model.dart';
import 'package:energym/utils/common/constants.dart';
import 'package:energym/utils/helpers/firebase/firestore_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rxdart/rxdart.dart';
import 'package:energym/reusable_component/custom_dialog.dart';

class ContactsBloc {
  final BehaviorSubject<List<UserModel>> _contactStream =
      BehaviorSubject<List<UserModel>>();

  ValueStream<List<UserModel>> get getContactList => _contactStream.stream;

  List<Contact> _listContact = [];
  List<UserModel> _listUser = [];

  final BehaviorSubject<List<UserModel>> _users =
      BehaviorSubject<List<UserModel>>();

  ValueStream<List<UserModel>> get users => _users.stream;

  void onUpdateContactList(List<UserModel> value) {
    _users.sink.add(value);
  }

  // Future<void> getDeviceContact(BuildContext context) async {
  //   final PermissionStatus status = await Permission.contacts.request();
  //   if (status.isGranted || status.isLimited) {
  //     List<Contact> _contacts =
  //         (await ContactsService.getContacts(withThumbnails: false)).toList();

  //     _listContact = _contacts;
  //     onUpdateContactList(_listContact);
  //   } else {
  //     //final size = Size(149, 169);

  //     const CustomAlertDialog().showErrorMessage(
  //         context: context,
  //         tital: AppConstants.contactPermissionTital,
  //         message: AppConstants.contactPermissionTital,
  //         buttonTitle: AppConstants.appSetting,
  //         onPress: () {
  //           openAppSettings();
  //         });
  //   }
  // }

  Future<void> getSystemUsers(BuildContext context) async {
    final List<DocumentSnapshot<Map<String, dynamic>?>?>? _list =
        await FireStoreProvider.instance.getAllUsers(context);

    if (_list != null && _list.isNotEmpty) {
      List<UserModel> _listModel = <UserModel>[];
      _list.forEach((document) async {
        _listModel.add(UserModel.fromJson(document!.data()!));
      });

      _listUser.addAll(_listModel);
      _users.sink.add(_listUser);
    } else {
      _users.sink.add(_listUser);
    }
  }

  void searchForContact(String value) {
    if (value == null || value.isEmpty) {
      onUpdateContactList(_listUser);
    } else {
      List<UserModel> _contacts = _listUser
          .where((UserModel element) =>
              element.username!
                  .toLowerCase()
                  .contains(value.toString().toLowerCase()) ||
              element.email!
                  .toLowerCase()
                  .contains(value.toString().toLowerCase()))
          .map((UserModel e) => e)
          .toList();
      onUpdateContactList(_contacts);
    }
  }

  void dispose() {
    _contactStream.close();
  }
}
