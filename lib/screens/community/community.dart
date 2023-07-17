import 'package:energym/app_config.dart';
import 'package:energym/screens/feed/feed.dart';
import 'package:energym/screens/followers/followers.dart';
import 'package:energym/screens/community/leaderboard.dart';
import 'package:energym/screens/group/maingrouplist.dart';
import 'package:energym/screens/profile_setup/profile_complete.dart';
import 'package:energym/utils/common/common_widget.dart';
import 'package:energym/utils/common/constants.dart';
import 'package:energym/utils/common/main_app_bar.dart';
import 'package:energym/utils/common/svg_picture_customise.dart';
import 'package:flutter/material.dart';
import 'package:energym/reusable_component/custom_scaffold.dart';
import 'package:text_scroll/text_scroll.dart';

class Community extends StatefulWidget {
  @override
  _CommunityState createState() => _CommunityState();
}

class _CommunityState extends State<Community>
    with SingleTickerProviderStateMixin {
  AppConfig? _config;
  TabController? _tabController;
  @override
  void initState() {
    _tabController = TabController(length: 4, vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    _tabController!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _config = AppConfig.of(context);
    return CustomScaffold(
      appBar: _getAppBar(),
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.zero,
          width: double.infinity,
          height: double.infinity,
          child: _mainContainerWidget(context),
        ),
      ),
    );
  }

  PreferredSizeWidget _getAppBar() {
    return getMainAppBar(context, _config!,
        backgoundColor: Colors.transparent,
        textColor: _config!.whiteColor,
        title: AppConstants.tabCommunity,
        elevation: 0,
        isBackEnable: false,
        //gradient: AppColors.gradintBtnSignUp,
        onBack: () {},
        actions: <Widget>[
          btnSweatCointBalance(context, _config!),
        ]);
  }

  Widget _mainContainerWidget(BuildContext context) {
    return Column(
      children: <Widget>[
        _widgetTabBar(),
        _widgetTabBarView(),
      ],
    );
  }

  Widget _widgetTabBar() {
    return Container(
      margin: const EdgeInsetsDirectional.fromSTEB(16, 8, 16, 0),
      width: double.infinity,
      height: 32,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: _config!.borderColor,
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: _config!.whiteColor,
        labelStyle: _config!.abel14FontStyle,
        unselectedLabelColor: _config!.greyColor,
        unselectedLabelStyle: _config!.abel14FontStyle,
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _config!.lightBorderColor,
          ),
          color: _config!.darkGreyColor,
        ),
        tabs: <Tab>[
          Tab(
            text: AppConstants.feed,
          ),
          Tab(
            child: TextScroll(AppConstants.followers),
          ),
          Tab(
            text: AppConstants.group,
          ),
          Tab(
            child: TextScroll(
              AppConstants.leaderboard,
            ),
          ),
        ],
      ),
    );
  }

  Widget _widgetTabBarView() {
    return Expanded(
      child: TabBarView(
        controller: _tabController,
        children: [
          // first tab bar view widget
          Feed(),
          Followers(),
          MainGroupList(),
          Leaderboard()
        ],
      ),
    );
  }
}
