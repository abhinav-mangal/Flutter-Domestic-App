import 'dart:async';

import 'package:energym/app_config.dart';
import 'package:energym/models/group_model.dart';
import 'package:energym/models/user_model.dart';
import 'package:energym/reusable_component/circular_image.dart';
import 'package:energym/reusable_component/custom_scaffold.dart';
import 'package:energym/reusable_component/custom_textfield.dart';
import 'package:energym/reusable_component/main_app_bar.dart';
import 'package:energym/reusable_component/nodata.dart';
import 'package:energym/screens/followers/add_group.dart';
import 'package:energym/screens/followers/follower_bloc.dart';
import 'package:energym/screens/group/member_invite_remove.dart';
import 'package:energym/utils/common/base_bloc.dart';
import 'package:energym/utils/common/common_widget.dart';
import 'package:energym/utils/common/constants.dart';
import 'package:energym/utils/common/svg_icon.dart';
import 'package:energym/utils/helpers/api_provider.dart';
import 'package:energym/utils/helpers/firebase/firestore_provider.dart';
import 'package:flutter/material.dart';
import '../../utils/helpers/routing/router.dart';

// This is group setting screen user can edit group details
class GroupSettingsArgs extends RoutesArgs {
  GroupSettingsArgs({
    required this.groupModel,
  }) : super(isHeroTransition: true);
  final GroupModel groupModel;
}

class GroupSettings extends StatefulWidget {
  GroupSettings({Key? key, required this.groupModel}) : super(key: key);
  static const String routeName = '/GroupSettings';
  final GroupModel groupModel;

  @override
  _GroupSettingsState createState() => _GroupSettingsState();
}

class _GroupSettingsState extends State<GroupSettings> {
  AppConfig? _appConfig;
  UserModel? _currentUser;
  APIProvider? _api;
  late GroupModel _groupModel;
  FollowersBloc? _blocFollower;
  List<UserModel> usersList = <UserModel>[];
  final TextEditingController _txtFieldSearch = TextEditingController();
  final FocusNode _focusNodeSearch = FocusNode();
  Timer? _searchTimer;
  ValueNotifier<bool> notifierIsSearching = ValueNotifier<bool>(false);
  @override
  void initState() {
    super.initState();
    _blocFollower = FollowersBloc();

    _currentUser = aGeneralBloc.currentUser;
    _api = APIProvider.of(context);
    _groupModel = widget.groupModel;

    _blocFollower!.getAllUsers(context);
  }

  @override
  void dispose() {
    super.dispose();
    _blocFollower!.dispose();
    _txtFieldSearch.dispose();
    _focusNodeSearch.dispose();
    if (_searchTimer != null) {
      _searchTimer!.cancel();
    }
    notifierIsSearching.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _appConfig = AppConfig.of(context);

    return CustomScaffold(
      appBar: _getAppBar(),
      body: SafeArea(
        child: _widgetMainContainer(),
      ),
    );
  }

  PreferredSizeWidget _getAppBar() {
    return getMainAppBar(context, _appConfig!,
        backgoundColor: Colors.transparent,
        textColor: _appConfig!.whiteColor,
        widget: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20.0),
              child: CircularImage(_groupModel.groupProfile!),
            ),
            SizedBox(width: 20),
            Flexible(child: Text('${_groupModel.groupName}'))
          ],
        ),
        elevation: 0, onBack: () {
      aGeneralBloc.updateAPICalling(false);
      Navigator.pop(context);
    }, actions: <Widget>[
      btnSweatCointBalance(context, _appConfig!),
    ]);
  }

  Widget _widgetMainContainer() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: (_currentUser?.documentId == _groupModel.adminId)
                ? MainAxisAlignment.spaceEvenly
                : MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: () {},
                child: Text(
                  '${_groupModel.groupType} group'.toUpperCase(),
                  style:
                      _appConfig!.abel14FontStyle.copyWith(color: Colors.white),
                ),
              ),
              if (_currentUser?.documentId == _groupModel.adminId)
                ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(
                      _appConfig!.btnPrimaryColor,
                    ),
                  ),
                  onPressed: () async {
                    await Navigator.pushNamed(context, AddGroup.routeName,
                            arguments: AddGroupArgs(groupModel: _groupModel))
                        .then((Object? value) {
                      if (value != null) {}
                    });
                  },
                  child: Text(
                    AppConstants.editGroup,
                    style: _appConfig!.abel14FontStyle
                        .copyWith(color: Colors.white),
                  ),
                )
              else
                const SizedBox(
                  width: 0,
                )
            ],
          ),
          const SizedBox(
            height: 5,
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 10, left: 20),
            child: SizedBox(
              width: double.infinity,
              child: Text(
                AppConstants.invitemember,
                textAlign: TextAlign.left,
                style: _appConfig!.abel14FontStyle.apply(
                  color: _appConfig!.whiteColor,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 10, bottom: 10, right: 10),
            child: Row(
              children: [
                Expanded(child: _searchTextField()),
              ],
            ),
          ),
          Expanded(child: _widgetUserList(context)),
        ],
      ),
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
          bgColor: _appConfig!.borderColor,
          lableText: AppConstants.searchBy,
          inputType: TextInputType.text,
          capitalization: TextCapitalization.none,
          inputAction: TextInputAction.done,
          padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
          contentPadding: const EdgeInsetsDirectional.fromSTEB(40, 0, 0, 0),
          maxlength: 50,
          prefixWidget: _widgetSearch(),
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
      usersList.clear();
      _blocFollower?.searchUser(context, searchText: text);
    });
  }

  Widget _widgetSearch() {
    return Container(
      padding: const EdgeInsetsDirectional.fromSTEB(12, 0, 8, 0),
      child: SvgIcon.asset(
        ImgConstants.search,
        size: 20,
        color: _appConfig!.greyColor,
      ),
    );
  }

  Widget _widgetUserList(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (scrollNotification) {
        if (scrollNotification.metrics.axis == Axis.vertical) {
          if (scrollNotification.metrics.pixels ==
              scrollNotification.metrics.maxScrollExtent) {}

          return true;
        }
        return false;
      },
      child: StreamBuilder<List<UserModel>>(
          stream: _blocFollower!.alluser,
          builder: (_, AsyncSnapshot<List<UserModel>> snapshot) {
            final bool isLoading = !snapshot.hasData;

            if (snapshot.hasData && snapshot.data != null) {
              final index = snapshot.data?.indexWhere(
                  (element) => element.documentId == _currentUser?.documentId);
              if (index != null && index != -1) {
                snapshot.data?.removeAt(index);
              }

              usersList.clear();
              usersList.addAll(snapshot.data!);
            }

            if (usersList.isEmpty) {
              return NODataWidget();
            }
            return ListView.builder(
                shrinkWrap: true,
                itemCount: isLoading ? 5 : usersList.length,
                itemBuilder: (_, int index) {
                  UserModel? data = isLoading ? null : usersList[index];

                  return MemberWidget(
                      data: data,
                      index: index,
                      groupAdminId: _groupModel.adminId,
                      currentUser: _currentUser,
                      group: _groupModel,
                      onPressRemoveMember: (group, data) {
                        aGeneralBloc.updateAPICalling(true);
                        // Remove member from group
                        _blocFollower?.groupParticipantUpdate(
                          context,
                          group,
                          data,
                        );
                        setState(() {
                          aGeneralBloc.updateAPICalling(false);
                        });
                      },
                      onPressSentInvite: (group, data) {
                        // Remove member from group
                        aGeneralBloc.updateAPICalling(true);
                        _blocFollower?.groupParticipantUpdate(
                          context,
                          group,
                          data,
                        );
                        setState(() {
                          aGeneralBloc.updateAPICalling(false);
                        });
                      },
                      onPressSendInvite: (group, data, userModel) async {
                        aGeneralBloc.updateAPICalling(true);
                        await _blocFollower?.groupParticipantUpdate(
                          context,
                          group,
                          data,
                        );

                        setState(() {
                          aGeneralBloc.updateAPICalling(false);
                          FireStoreProvider.instance.sendFcmNotification(
                            _currentUser!,
                            userModel.documentId!,
                            NotificationType.inviteGroupMember,
                            _currentUser!.documentId!,
                            group,
                            userModel.fullName,
                          );
                        });
                      });
                });
          }),
    );
  }
}
