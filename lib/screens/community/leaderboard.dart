import 'dart:async';

import 'package:energym/app_config.dart';
import 'package:energym/models/user_model.dart';
import 'package:energym/reusable_component/custom_textfield.dart';
import 'package:energym/reusable_component/nodata.dart';
import 'package:energym/screens/community/leaderboard_bloc.dart';
import 'package:energym/screens/community/widget_leaderboard.dart';
import 'package:energym/screens/followers/widget_follower.dart';
import 'package:energym/screens/user_profile/user_pofile.dart';
import 'package:energym/utils/common/base_bloc.dart';
import 'package:energym/utils/common/constants.dart';
import 'package:energym/utils/common/svg_icon.dart';
import 'package:flutter/material.dart';

// This is leaderboard screen contains 2 tabs
//Global and My Country
// There is sorting based onAv. FTP /Total Watts
class Leaderboard extends StatefulWidget {
  @override
  _LeaderboardState createState() => _LeaderboardState();
}

class _LeaderboardState extends State<Leaderboard>
    with SingleTickerProviderStateMixin {
  AppConfig? _config;
  TabController? _tabController;
  TextEditingController? _txtSearchGlobal;
  TextEditingController? _txtSearchUK;
  TextEditingController? _txtSearchRegional;
  LeaderboardBloc? _blocLeaderboard;
  List<UserModel>? _listLeaderboard = <UserModel>[];
  List<UserModel>? _listLeaderboardRegional = <UserModel>[];
  UserModel? _currentUser;
  Timer? _leaderboardSearchTimer;
  ValueNotifier<bool>? notifierIsSearching = ValueNotifier<bool>(false);

  Timer? _leaderboardRegionalSearchTimer;
  ValueNotifier<bool>? notifierRegionalIsSearching = ValueNotifier<bool>(false);

  ValueNotifier<bool>? notifierFTP = ValueNotifier<bool>(false);
  ValueNotifier<bool>? notifierWatts = ValueNotifier<bool>(true);

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 2, vsync: this);

    _blocLeaderboard = LeaderboardBloc();

    _currentUser = aGeneralBloc.currentUser;

    getDataForFilter();
  }

  getDataForFilter() async {
    print(notifierFTP?.value);
    print(notifierWatts?.value);
    await _blocLeaderboard!.getLeaderboardData(context,
        timeZone: '',
        sortedByWatts: notifierWatts?.value,
        sortedByFTP: notifierFTP?.value);

    await _blocLeaderboard!.getLeaderboardRegionalData(context,
        timeZone: DateTime.now().timeZoneName,
        sortedByWatts: notifierWatts?.value,
        sortedByFTP: notifierFTP?.value);
  }

  @override
  void dispose() {
    super.dispose();
    if (_leaderboardSearchTimer != null) {
      _leaderboardSearchTimer!.cancel();
    }
    notifierIsSearching!.dispose();

    if (_leaderboardRegionalSearchTimer != null) {
      _leaderboardRegionalSearchTimer!.cancel();
    }
    notifierRegionalIsSearching!.dispose();

    notifierFTP!.dispose();
    notifierWatts!.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _config = AppConfig.of(context);
    return Container(
      padding: EdgeInsets.zero,
      width: double.infinity,
      height: double.infinity,
      child: _mainContainerWidget(context),
    );
  }

  Widget _mainContainerWidget(BuildContext context) {
    return Column(
      children: <Widget>[
        _widgetTabBar(),
        _widgetSorting(),
        _widgetTabBarView(context),
      ],
    );
  }

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
            text: AppConstants.global,
          ),
          Tab(
            text: AppConstants.localCountry,
          ),
          // Tab(
          //   text: AppConstants.group,
          // ),
        ],
      ),
    );
  }

  Widget _widgetTabBarView(BuildContext mainContext) {
    return Expanded(
      child: TabBarView(
        controller: _tabController,
        children: <Widget>[
          _widgetGlobal(mainContext),
          _widgetLocalCountry(mainContext),
          // _widgetGroup(mainContext),
        ],
      ),
    );
  }

  Widget _widgetGlobal(BuildContext mainContext) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      padding: EdgeInsets.zero,
      child: Column(
        children: <Widget>[
          Expanded(
              child: Container(
            width: double.infinity,
            height: double.infinity,
            child: _widgetLeaderList(mainContext),
          ))
        ],
      ),
    );
  }

  Widget _widgetLocalCountry(BuildContext mainContext) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      padding: EdgeInsets.zero,
      child: Column(
        children: <Widget>[
          Expanded(
              child: Container(
            width: double.infinity,
            height: double.infinity,
            child: _widgetLeaderReginalList(mainContext),
          ))
        ],
      ),
    );
  }

  Widget _widgetGroup(BuildContext mainContext) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      padding: EdgeInsets.zero,
      child: Column(
        children: <Widget>[
          Expanded(
              child: Container(
            width: double.infinity,
            height: double.infinity,
          ))
        ],
      ),
    );
  }

  Widget _widgetSorting() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 0),
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
                      getDataForFilter();
                    },
                    child: Text(
                      AppConstants.avWattsAndFTP,
                      style: _config!.calibriHeading5FontStyle.copyWith(
                          color: status
                              ? _config!.btnPrimaryColor
                              : _config!.whiteColor),
                    ),
                  ),
                  Container(
                    color:
                        status ? _config!.btnPrimaryColor : _config!.whiteColor,
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
                      getDataForFilter();
                    },
                    child: Text(
                      AppConstants.totalWatts,
                      style: _config!.calibriHeading5FontStyle.copyWith(
                          color: status
                              ? _config!.btnPrimaryColor
                              : _config!.whiteColor),
                    ),
                  ),
                  Container(
                    color:
                        status ? _config!.btnPrimaryColor : _config!.whiteColor,
                    height: 2,
                    width: 100,
                  )
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _widgetGlobalSeachBar(BuildContext context) {
    return Container(
      padding: const EdgeInsetsDirectional.fromSTEB(24, 0, 24, 0),
      child: CustomTextField(
        stackAlignment: Alignment.centerLeft,
        context: context,
        controller: _txtSearchGlobal,
        showFlotingHint: true,
        floatingLabelBehavior: FloatingLabelBehavior.never,
        lableText: AppConstants.searchLeaderboard,
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

        onchange: _onSearchGlobal,
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
      ),
    );
  }

  Widget _widgetRegionalSeachBar(BuildContext context) {
    return Container(
      padding: const EdgeInsetsDirectional.fromSTEB(24, 0, 24, 0),
      child: CustomTextField(
        stackAlignment: Alignment.centerLeft,
        context: context,
        controller: _txtSearchRegional,
        showFlotingHint: true,
        floatingLabelBehavior: FloatingLabelBehavior.never,
        lableText: AppConstants.searchLeaderboard,
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

        onchange: _onSearchRegional,
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
      ),
    );
  }

  // _onSearchFollower
  void _onSearchGlobal(String text) {
    if (_leaderboardSearchTimer?.isActive ?? false)
      _leaderboardSearchTimer!.cancel();
    _leaderboardSearchTimer = Timer(const Duration(milliseconds: 500), () {
      notifierIsSearching!.value = true;
      _listLeaderboard!.clear();
      _blocLeaderboard!.searchLeaderboard(context, searchText: text);
    });
  }

  void _onSearchRegional(String text) {
    if (_leaderboardRegionalSearchTimer?.isActive ?? false)
      _leaderboardRegionalSearchTimer!.cancel();
    _leaderboardRegionalSearchTimer =
        Timer(const Duration(milliseconds: 500), () {
      notifierRegionalIsSearching!.value = true;
      _listLeaderboardRegional!.clear();
      _blocLeaderboard!.searchLeaderboardRegional(context, searchText: text);
    });
  }

  Widget _widgetLeaderList(BuildContext context) {
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
          stream: _blocLeaderboard!.userLeaderBoard,
          builder: (_, AsyncSnapshot<List<UserModel>> snapshot) {
            final bool isLoading = !snapshot.hasData;

            if (snapshot.hasData && snapshot.data != null) {
              _listLeaderboard!.clear();
              _listLeaderboard!.addAll(snapshot.data!);
            }

            if (_listLeaderboard!.isEmpty) {
              return NODataWidget();
            }
            return ListView.builder(
                shrinkWrap: true,
                itemCount: isLoading ? 5 : _listLeaderboard!.length,
                itemBuilder: (_, int index) {
                  UserModel? data = isLoading ? null : _listLeaderboard![index];

                  return LeaderboardWidget(
                    data: data,
                    index: index,
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

  Widget _widgetLeaderReginalList(BuildContext context) {
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
          stream: _blocLeaderboard!.userLeaderBoardRegional,
          builder: (_, AsyncSnapshot<List<UserModel>> snapshot) {
            final bool isLoading = !snapshot.hasData;

            if (snapshot.hasData && snapshot.data != null) {
              _listLeaderboardRegional!.clear();
              _listLeaderboardRegional!.addAll(snapshot.data!);
            }

            if (_listLeaderboardRegional!.isEmpty) {
              return NODataWidget();
            }
            return ListView.builder(
                shrinkWrap: true,
                itemCount: isLoading ? 5 : _listLeaderboardRegional!.length,
                itemBuilder: (_, int index) {
                  UserModel? data =
                      isLoading ? null : _listLeaderboardRegional![index];

                  return LeaderboardWidget(
                    data: data,
                    index: index,
                    currentUser: _currentUser,
                    onPress: () {
                      Navigator.pushNamed(context, UserProfile.routeName!,
                          arguments: UserProfileArgs(
                              userId: data?.documentId,
                              isLoggedInUser:
                                  (_currentUser?.documentId == data?.documentId)
                                      ? true
                                      : false,
                              isShowBack: true));
                    },
                  );
                });
          }),
    );
  }
}
