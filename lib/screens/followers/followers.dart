import 'dart:async';
import 'package:energym/app_config.dart';
import 'package:energym/models/group_model.dart';
import 'package:energym/screens/followers/add_followers.dart';
import 'package:energym/screens/followers/add_group.dart';
import 'package:energym/screens/followers/widget_group.dart';

import 'package:energym/screens/followers/follower_bloc.dart';
import 'package:energym/screens/followers/widget_follower.dart';
import 'package:energym/screens/user_profile/user_pofile.dart';
import 'package:energym/utils/common/base_bloc.dart';
import 'package:energym/utils/common/constants.dart';
import 'package:flutter/material.dart';
import 'package:energym/reusable_component/custom_textfield.dart';
import 'package:energym/models/follower_model.dart';
import '../../utils/common/constants.dart';
import '../../utils/common/svg_icon.dart';
import 'package:energym/models/user_model.dart';

class Followers extends StatefulWidget {
  @override
  _FollowersState createState() => _FollowersState();
}

class _FollowersState extends State<Followers>
    with SingleTickerProviderStateMixin {
  AppConfig? _config;
  TabController? _tabController;
  FollowersBloc? _blocFollower;
  TextEditingController? _txtSearchFollower;
  TextEditingController? _txtSearchGroup;
  UserModel? _currentUser;
  ValueNotifier<bool>? notifierIsSearching = ValueNotifier<bool>(false);
  List<FollowerModel>? _listFollower = <FollowerModel>[];
  List<GroupModel>? _listGroups = <GroupModel>[];

  Timer? _followerSearchTimer;
  Timer? _groupSearchTimer;
  @override
  void initState() {
    super.initState();
    _blocFollower = FollowersBloc();
    _currentUser = aGeneralBloc.currentUser;
    _txtSearchFollower = TextEditingController();
    _txtSearchGroup = TextEditingController();
    _tabController = TabController(length: 2, vsync: this);

    _blocFollower!.getFollower(context, userId: _currentUser!.documentId);
  }

  @override
  void dispose() {
    notifierIsSearching!.dispose();
    if (_followerSearchTimer != null) {
      _followerSearchTimer!.cancel();
    }

    if (_groupSearchTimer != null) {
      _groupSearchTimer!.cancel();
    }
    _tabController!.dispose();
    _txtSearchFollower!.dispose();
    _txtSearchGroup!.dispose();
    _blocFollower!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _config = AppConfig.of(context);
    return Container(
        padding: EdgeInsets.zero,
        width: double.infinity,
        height: double.infinity,
        child: _widgetFollowers(context) //_mainContainerWidget(context),
        );
  }

  Widget _mainContainerWidget(BuildContext context) {
    return Column(
      children: <Widget>[
        _widgetFollowers(context),
        // _widgetTabBar(),
        // _widgetTabBarView(context),
      ],
    );
  }

/*
  Widget _widgetTabBar() {
    return Container(
      margin: const EdgeInsetsDirectional.fromSTEB(16, 8, 16, 0),
      width: double.infinity,
      height: 42,
      child: TabBar(
        controller: _tabController,
        labelColor: _config!.whiteColor,
        labelStyle: _config!.calibriHeading5FontStyle,
        unselectedLabelColor: _config!.greyColor,
        unselectedLabelStyle: _config!.calibriHeading5FontStyle,
        tabs: <Tab>[
          Tab(
            text: AppConstants.followers,
          ),
          Tab(
            text: AppConstants.group,
          ),
        ],
      ),
    );
  }

  Widget _widgetTabBarView(BuildContext mainContext) {
    return Expanded(
      child: TabBarView(
        controller: _tabController,
        children: <Widget>[
          _widgetFollowers(mainContext),
          _widgetGroups(mainContext),
        ],
      ),
    );
  }
*/
  Widget _widgetFollowers(BuildContext mainContext) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      padding: EdgeInsets.zero,
      child: Column(
        children: <Widget>[
          _widgetFollowerSeachBar(mainContext),
          Expanded(
              child: Container(
            width: double.infinity,
            height: double.infinity,
            child: _widgetFollowerList(mainContext),
          ))
        ],
      ),
    );
  }

  Widget _widgetFollowerSeachBar(BuildContext context) {
    return Container(
      padding: const EdgeInsetsDirectional.fromSTEB(24, 0, 24, 0),
      child: CustomTextField(
        stackAlignment: Alignment.centerLeft,
        context: context,
        controller: _txtSearchFollower,
        showFlotingHint: true,
        floatingLabelBehavior: FloatingLabelBehavior.never,
        lableText: AppConstants.searchFollowers,
        //hindText: AppConstants.hintFullName,
        inputType: TextInputType.text,
        capitalization: TextCapitalization.words,
        inputAction: TextInputAction.go,
        enableSuggestions: true,
        isAutocorrect: true,
        maxlength: 50,
        maxline: 1,
        contentPadding: const EdgeInsetsDirectional.fromSTEB(25, 0, 110, 15),
        padding: const EdgeInsetsDirectional.fromSTEB(0, 8, 0, 8),

        onchange: _onSearchFollower,
        onSubmit: (String value) {
          FocusScope.of(context).unfocus();
        },
        prefixWidget: Container(
          padding: EdgeInsets.zero,
          child: Center(
            child: SvgIcon.asset(
              ImgConstants.search,
              color: _config!.greyColor,
              size: 20,
            ),
          ),
        ),
        sufixWidget: TextButton(
          onPressed: () {
            Navigator.pushNamed(context, AddFollowers.routeName);
          },
          child: Container(
            padding: EdgeInsets.zero,
            height: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(
                  Icons.add,
                  color: _config!.btnPrimaryColor,
                  size: 20,
                ),
                Text(
                  AppConstants.addFollower,
                  style: _config!.linkSmallFontStyle.apply(
                    color: _config!.btnPrimaryColor,
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onSearchFollower(String text) {
    if (_followerSearchTimer?.isActive ?? false) _followerSearchTimer!.cancel();
    _followerSearchTimer = Timer(const Duration(milliseconds: 500), () {
      notifierIsSearching!.value = true;
      _listFollower!.clear();
      _blocFollower!.searchFollower(context, searchText: text);
      // _blocFollower.updateFollower(_listFollower);
      // _blocFollower.getFollower(context,
      //     userId: _currentUser.documentId,);
    });
  }

  Widget _widgetFollowerList(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (scrollNotification) {
        if (scrollNotification.metrics.axis == Axis.vertical) {
          if (scrollNotification.metrics.pixels ==
              scrollNotification.metrics.maxScrollExtent) {}

          return true;
        }
        return false;
      },
      child: StreamBuilder<List<FollowerModel>>(
          stream: _blocFollower!.getUserFollower,
          builder: (_, AsyncSnapshot<List<FollowerModel>> snapshot) {
            final bool isLoading = !snapshot.hasData;

            if (snapshot.hasData && snapshot.data != null) {
              _listFollower!.clear();
              _listFollower!.addAll(snapshot.data!);
            }

            if (_listFollower!.isEmpty) {
              return const SizedBox();
            }
            return ListView.builder(
                shrinkWrap: true,
                // physics: const NeverScrollableScrollPhysics(),
                itemCount: isLoading ? 5 : _listFollower!.length,
                itemBuilder: (_, int index) {
                  FollowerModel? data =
                      isLoading ? null : _listFollower![index];

                  return FollowerWidget(
                    data: data!,
                    currentUser: _currentUser!,
                    onPress: () {
                      Navigator.pushNamed(context, UserProfile.routeName!,
                          arguments: UserProfileArgs(
                              userId: data.followerId,
                              isLoggedInUser: false,
                              isShowBack: true));
                    },
                  );
                });
          }),
    );
  }
/*
  Widget _widgetGroups(BuildContext mainContext) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      padding: EdgeInsets.zero,
      child: Column(
        children: <Widget>[
          _widgetGroupSeachBar(mainContext),
          Expanded(
              child: Container(
            width: double.infinity,
            height: double.infinity,
            child: _widgetGroupList(mainContext),
          ))
        ],
      ),
    );
  }

  Widget _widgetGroupSeachBar(BuildContext context) {
    return Container(
      padding: const EdgeInsetsDirectional.fromSTEB(24, 0, 24, 0),
      child: CustomTextField(
        stackAlignment: Alignment.centerLeft,
        context: context,
        controller: _txtSearchGroup,
        showFlotingHint: true,
        floatingLabelBehavior: FloatingLabelBehavior.never,
        lableText: AppConstants.searchGroups,
        //hindText: AppConstants.hintFullName,
        inputType: TextInputType.text,
        capitalization: TextCapitalization.words,
        inputAction: TextInputAction.go,
        enableSuggestions: true,
        isAutocorrect: true,
        maxlength: 50,
        maxline: 1,
        contentPadding: const EdgeInsetsDirectional.fromSTEB(25, 0, 110, 15),
        padding: const EdgeInsetsDirectional.fromSTEB(0, 8, 0, 8),

        onchange: _onSearchGroup,
        onSubmit: (String value) {
          FocusScope.of(context).unfocus();
        },
        prefixWidget: Container(
          padding: EdgeInsets.zero,
          child: Center(
            child: SvgIcon.asset(
              ImgConstants.search,
              color: _config!.greyColor,
              size: 20,
            ),
          ),
        ),
        sufixWidget: TextButton(
          onPressed: () async {
            await Navigator.pushNamed(context, AddGroup.routeName)
                .then((Object? value) {
              if (value != null) {
                bool isUpdate = value as bool;
                if (isUpdate) {
                  _listGroups!.clear();
                  _blocFollower!.getUserJoinedGroups(context,
                      userId: _currentUser!.documentId);
                }
              }
            });
          },
          child: Container(
            padding: EdgeInsets.zero,
            height: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(
                  Icons.add,
                  color: _config!.btnPrimaryColor,
                  size: 20,
                ),
                Text(
                  AppConstants.addGroup,
                  style: _config!.linkSmallFontStyle.apply(
                    color: _config!.btnPrimaryColor,
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onSearchGroup(String text) {
    // if (_groupSearchTimer?.isActive ?? false) _groupSearchTimer.cancel();
    // _groupSearchTimer = Timer(const Duration(milliseconds: 500), () {
    //   notifierIsSearching.value = true;
    //   // _listFollower.clear();
    //   // _blocFollower.updateFollower(_listFollower);
    //   // _blocFollower.getFollower(
    //   //   context,
    //   //   userId: _currentUser.documentId,
    //   // );
    // });

    if (_groupSearchTimer?.isActive ?? false) _groupSearchTimer!.cancel();
    _groupSearchTimer = Timer(const Duration(milliseconds: 500), () {
      notifierIsSearching!.value = true;
      _listGroups!.clear();
      _blocFollower!.searchGroup(context, searchText: text);
      // _blocFollower.updateFollower(_listFollower);
      // _blocFollower.getFollower(context,
      //     userId: _currentUser.documentId,);
    });
  }

  Widget _widgetGroupList(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (scrollNotification) {
        if (scrollNotification.metrics.axis == Axis.vertical) {
          if (scrollNotification.metrics.pixels ==
              scrollNotification.metrics.maxScrollExtent) {}

          return true;
        }
        return false;
      },
      child: StreamBuilder<List<GroupModel>>(
          stream: _blocFollower!.getUserGroups,
          builder: (_, AsyncSnapshot<List<GroupModel>> snapshot) {
            final bool isLoading = !snapshot.hasData;

            if (snapshot.hasData && snapshot.data != null) {
              _listGroups!.clear();
              _listGroups!.addAll(snapshot.data!);
            }

            if (_listGroups!.isEmpty) {
              return const SizedBox();
            }
            return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: isLoading ? 5 : _listGroups!.length,
                itemBuilder: (_, int index) {
                  GroupModel? data = isLoading ? null : _listGroups![index];

                  return GroupWidget(
                    data: data!,
                    currentUser: _currentUser!,
                  );
                });
          }),
    );
  }
  */
}
