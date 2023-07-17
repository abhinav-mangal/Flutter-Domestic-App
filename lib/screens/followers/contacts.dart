import 'dart:async';

import 'package:energym/app_config.dart';
import 'package:energym/screens/community/leaderboard_bloc.dart';
import 'package:energym/screens/community/widget_leaderboard.dart';
import 'package:energym/screens/followers/contacts_bloc.dart';
import 'package:energym/screens/followers/widget_user.dart';
import 'package:energym/utils/common/base_bloc.dart';
import 'package:energym/utils/common/constants.dart';
import 'package:energym/utils/common/main_app_bar.dart';
import 'package:energym/utils/common/svg_icon.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:energym/reusable_component/custom_scaffold.dart';
import 'package:energym/reusable_component/custom_textfield.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:energym/models/user_model.dart';

class ContactList extends StatefulWidget {
  static const String routeName = '/ContactList';
  @override
  _ContactListState createState() => _ContactListState();
}

class _ContactListState extends State<ContactList> {
  AppConfig? _aapConfig;
  final TextEditingController _txtFieldSearch = TextEditingController();
  final FocusNode _focusNodeSearch = FocusNode();
  ContactsBloc _blocContacts = ContactsBloc();
  Timer? _searchTimer;
  ValueNotifier<bool> notifierIsSearching = ValueNotifier<bool>(false);
  UserModel? _currentUser;
  final List<UserModel> _listContact = <UserModel>[];
  @override
  void initState() {
    initialSetUp();
    super.initState();
  }

  Future<void> initialSetUp() async {
    _currentUser = aGeneralBloc.currentUser;
    _blocContacts.getSystemUsers(context);
  }

  @override
  void dispose() {
    _txtFieldSearch.dispose();
    _focusNodeSearch.dispose();

    if (_searchTimer != null) {
      _searchTimer!.cancel();
    }
    notifierIsSearching.dispose();
    _blocContacts.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _aapConfig = AppConfig.of(context);
    return CustomScaffold(
      appBar: _getAppBar(),
      body: SafeArea(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          child: _mainContainerWidget(context),
        ),
      ),
    );
  }

  PreferredSizeWidget _getAppBar() {
    return getMainAppBar(
      context,
      _aapConfig!,
      backgoundColor: Colors.transparent,
      textColor: _aapConfig!.whiteColor,
      widget: _searchTextField(),
      elevation: 0,
      isBackEnable: false,
      centerTitle: false,
      onBack: () {},
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            AppConstants.cancel,
            style: _aapConfig!.linkNormalFontStyle.apply(
              color: _aapConfig!.whiteColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _searchTextField() {
    return ValueListenableBuilder<bool>(
      valueListenable: notifierIsSearching,
      builder: (BuildContext? context, bool? isSearching, Widget? child) {
        return CustomTextField(
          stackAlignment: Alignment.centerLeft,
          context: context,
          controller: _txtFieldSearch,
          focussNode: _focusNodeSearch,
          bgColor: _aapConfig!.borderColor,
          lableText: AppConstants.searchBy,
          inputType: TextInputType.text,
          capitalization: TextCapitalization.none,
          inputAction: TextInputAction.done,
          padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
          contentPadding: const EdgeInsetsDirectional.fromSTEB(40, 0, 0, 0),
          maxlength: 12,
          prefixWidget: _widgetSearch(),
          sufixWidget: isSearching!
              ? SpinKitCircle(
                  color: _aapConfig!.btnPrimaryColor,
                  size: 15,
                )
              : null,
          onchange: _onSearchFollowing,
          onSubmit: (String value) {},
        );
      },
    );
  }

  void _onSearchFollowing(String text) {
    if (_searchTimer?.isActive ?? false) _searchTimer!.cancel();
    _searchTimer = Timer(const Duration(milliseconds: 500), () {
      notifierIsSearching.value = true;
      _listContact.clear();
      _blocContacts.onUpdateContactList(_listContact);
      _blocContacts.searchForContact(text);
    });
  }

  Widget _widgetSearch() {
    return Container(
      padding: const EdgeInsetsDirectional.fromSTEB(12, 0, 8, 0),
      child: SvgIcon.asset(
        ImgConstants.search,
        size: 20,
        color: _aapConfig!.greyColor,
      ),
    );
  }

  Widget _mainContainerWidget(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: StreamBuilder<List<UserModel>>(
        stream: _blocContacts.users,
        builder:
            (BuildContext context, AsyncSnapshot<List<UserModel>> snapshot) {
          final bool isLoading = !snapshot.hasData;

          if (snapshot.hasData && snapshot.data != null) {
            _listContact.clear();
            _listContact.addAll(snapshot.data!);
            //notifierIsSearching.value = false;
          }

          return ListView.builder(
            physics: const ClampingScrollPhysics(),
            itemCount: isLoading ? 5 : _listContact.length,
            itemBuilder: (BuildContext listContext, int index) {
              final UserModel? _contact =
                  isLoading ? null : _listContact[index];

              return WidgetUser(
                data: _contact,
                currentUser: _currentUser!,
              );
            },
          );
        },
      ),
    );
  }
}
