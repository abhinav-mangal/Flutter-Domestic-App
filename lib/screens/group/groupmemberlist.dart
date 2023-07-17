import 'package:energym/app_config.dart';
import 'package:energym/models/group_model.dart';
import 'package:energym/models/user_model.dart';
import 'package:energym/reusable_component/circular_image.dart';
import 'package:energym/reusable_component/custom_dialog.dart';
import 'package:energym/reusable_component/custom_scaffold.dart';
import 'package:energym/reusable_component/main_app_bar.dart';
import 'package:energym/reusable_component/nodata.dart';
import 'package:energym/screens/community/widget_leaderboard.dart';
import 'package:energym/screens/followers/follower_bloc.dart';
import 'package:energym/screens/group/invite_member.dart';
import 'package:energym/screens/user_profile/user_pofile.dart';
import 'package:energym/utils/common/base_bloc.dart';
import 'package:energym/utils/common/common_widget.dart';
import 'package:energym/utils/common/constants.dart';
import 'package:energym/utils/helpers/api_provider.dart';
import 'package:energym/utils/helpers/firebase/firestore_provider.dart';
import 'package:flutter/material.dart';
import '../../utils/helpers/routing/router.dart';

// This screen having list of group members
class GroupMembersArgs extends RoutesArgs {
  GroupMembersArgs({
    required this.groupModel,
  }) : super(isHeroTransition: true);
  final GroupModel groupModel;
}

class GroupMembers extends StatefulWidget {
  const GroupMembers({Key? key, required this.groupModel}) : super(key: key);
  static const String routeName = '/GroupMembers';
  final GroupModel groupModel;
  @override
  _GroupMembersState createState() => _GroupMembersState();
}

class _GroupMembersState extends State<GroupMembers> {
  AppConfig? _appConfig;
  UserModel? _currentUser;
  APIProvider? _api;
  late GroupModel _groupModel;
  FollowersBloc? _blocFollower;
  List<UserModel> usersList = <UserModel>[];
  ValueNotifier<bool>? notifierFTP = ValueNotifier<bool>(false);
  ValueNotifier<bool>? notifierWatts = ValueNotifier<bool>(true);

  @override
  void initState() {
    super.initState();
    _blocFollower = FollowersBloc();

    _currentUser = aGeneralBloc.currentUser;
    _api = APIProvider.of(context);
    _groupModel = widget.groupModel;

    _blocFollower!.getGroupMembers(_groupModel.participantId!);
  }

  @override
  void dispose() {
    super.dispose();
    _blocFollower!.dispose();
    notifierWatts?.dispose();
    notifierFTP?.dispose();
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
      Padding(
        padding: const EdgeInsets.only(right: 20),
        child: Row(
          children: [
            Image.asset(ImgConstants.logoR, width: 12, height: 12),
            SizedBox(width: 3),
            Text('${_groupModel.totalWatts}W',
                style: _appConfig!.antonio14FontStyle)
          ],
        ),
      ),
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
              ElevatedButton(
                style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all(_appConfig!.btnPrimaryColor)),
                onPressed: () {
                  if (_currentUser?.documentId == _groupModel.adminId) {
                    print('Its Admin');

                    const CustomAlertDialog().confirmationDialog(
                        context: context,
                        message:
                            '"${_groupModel.groupName}" group will be deleted, when you leave.',
                        okButtonTitle: AppConstants.exit,
                        onSuccess: () async {
                          print(AppConstants.exit);
                          await _blocFollower?.deleteGroup(
                            context,
                            _groupModel,
                          );
                        },
                        cancelButtonTitle: AppConstants.cancel);
                  } else {
                    const CustomAlertDialog().confirmationDialog(
                        context: context,
                        message: 'Exit "${_groupModel.groupName}" group?',
                        okButtonTitle: AppConstants.exit,
                        onSuccess: () async {
                          final Map<String, dynamic> _neetToStoreData =
                              <String, dynamic>{};

                          _groupModel.participantId
                              ?.remove(_currentUser?.documentId);
                          _neetToStoreData[GroupCollectionField.participantId] =
                              _groupModel.participantId;
                          _neetToStoreData[GroupCollectionField
                              .participantName] = _groupModel.participantName;

                          await _blocFollower?.groupParticipantUpdate(
                            context,
                            _groupModel,
                            _neetToStoreData,
                          );
                        },
                        cancelButtonTitle: AppConstants.cancel);
                  }
                },
                child: Text(
                  AppConstants.leaveGroup,
                  style:
                      _appConfig!.abel14FontStyle.copyWith(color: Colors.white),
                ),
              ),
              (_currentUser?.documentId == _groupModel.adminId)
                  ? ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(
                          _appConfig!.btnPrimaryColor,
                        ),
                      ),
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          GroupSettings.routeName,
                          arguments: GroupSettingsArgs(groupModel: _groupModel),
                        );
                      },
                      child: Text(
                        AppConstants.groupSettings,
                        style: _appConfig!.abel14FontStyle
                            .copyWith(color: Colors.white),
                      ),
                    )
                  : const SizedBox(
                      width: 0,
                    )
            ],
          ),
          _widgetSorting(),
          SizedBox(
            height: 5,
          ),
          Expanded(child: _widgetMemberList(context)),
        ],
      ),
    );
  }

  Widget _widgetSorting() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          ValueListenableBuilder<bool>(
            valueListenable: notifierFTP!,
            builder: (BuildContext? context, status, child) {
              return Column(
                children: [
                  TextButton(
                    onPressed: () {
                      notifierFTP?.value = true;
                      notifierWatts?.value = false;
                      _blocFollower?.sorting(usersList, true);
                    },
                    child: Text(
                      AppConstants.avWattsAndFTP,
                      style: _appConfig!.calibriHeading5FontStyle.copyWith(
                          color: status
                              ? _appConfig!.btnPrimaryColor
                              : _appConfig!.whiteColor),
                    ),
                  ),
                  Container(
                    color: status
                        ? _appConfig!.btnPrimaryColor
                        : _appConfig!.whiteColor,
                    height: 2,
                    width: 80,
                  )
                ],
              );
            },
          ),
          SizedBox(
            width: 5,
          ),
          ValueListenableBuilder<bool>(
            valueListenable: notifierWatts!,
            builder: (BuildContext? context, status, child) {
              return Column(
                children: [
                  TextButton(
                    onPressed: () {
                      notifierFTP?.value = false;
                      notifierWatts?.value = true;
                      _blocFollower?.sorting(usersList, false);
                    },
                    child: Text(
                      AppConstants.totalWatts,
                      style: _appConfig!.calibriHeading5FontStyle.copyWith(
                          color: status
                              ? _appConfig!.btnPrimaryColor
                              : _appConfig!.whiteColor),
                    ),
                  ),
                  Container(
                    color: status
                        ? _appConfig!.btnPrimaryColor
                        : _appConfig!.whiteColor,
                    height: 2,
                    width: 80,
                  )
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _widgetMemberList(BuildContext context) {
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
          stream: _blocFollower!.getUserGroupsMenbers,
          builder: (_, AsyncSnapshot<List<UserModel>> snapshot) {
            final bool isLoading = !snapshot.hasData;

            if (snapshot.hasData && snapshot.data != null) {
              usersList.clear();
              usersList.addAll(snapshot.data!);
              _blocFollower?.sorting(usersList, notifierWatts!.value);
            }

            if (usersList.isEmpty) {
              return NODataWidget();
            }
            return ListView.builder(
                shrinkWrap: true,
                itemCount: isLoading ? 5 : usersList.length,
                itemBuilder: (_, int index) {
                  UserModel? data = isLoading ? null : usersList[index];

                  return LeaderboardWidget(
                    data: data,
                    index: index,
                    groupAdminId: _groupModel.adminId,
                    currentUser: _currentUser,
                    onPress: () {
                      Navigator.pushNamed(
                        context,
                        UserProfile.routeName!,
                        arguments: UserProfileArgs(
                            userId: data?.documentId,
                            isLoggedInUser:
                                (_currentUser?.documentId == data?.documentId)
                                    ? true
                                    : false,
                            isShowBack: true),
                      );
                    },
                  );
                });
          }),
    );
  }
}
