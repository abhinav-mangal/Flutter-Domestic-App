import 'dart:async';

import 'package:energym/app_config.dart';
import 'package:energym/main.dart';
import 'package:energym/models/group_model.dart';
import 'package:energym/models/user_model.dart';
import 'package:energym/reusable_component/custom_textfield.dart';
import 'package:energym/reusable_component/nodata.dart';
import 'package:energym/screens/followers/widget_group.dart';
import 'package:energym/screens/group/groupmemberlist.dart';
import 'package:energym/screens/group/publicgroup.dart';
import 'package:energym/utils/common/base_bloc.dart';
import 'package:energym/utils/common/constants.dart';
import 'package:flutter/material.dart';

import '../../utils/common/svg_icon.dart';
import '../followers/add_group.dart';
import '../followers/follower_bloc.dart';

// Group list which is created by user through app
// All groups will be fetched from firebase
class MainGroupList extends StatefulWidget {
  @override
  _MainGroupListState createState() => _MainGroupListState();
}

class _MainGroupListState extends State<MainGroupList>
    with SingleTickerProviderStateMixin, RouteAware {
  AppConfig? _config;
  TextEditingController? _txtSearchGroup;
  List<GroupModel>? _listGroups = <GroupModel>[];
  FollowersBloc? _blocFollower;
  UserModel? _currentUser;
  Timer? _groupSearchTimer;
  ValueNotifier<bool>? notifierIsSearching = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    _blocFollower = FollowersBloc();
    _currentUser = aGeneralBloc.currentUser;
    _blocFollower!.getUserJoinedGroups(context,
        userId: _currentUser!.documentId,
        loggedInUserId: _currentUser!.documentId);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    Helper.routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void didPopNext() {
    super.didPopNext();
    _blocFollower!.getUserJoinedGroups(context,
        userId: _currentUser!.documentId,
        loggedInUserId: _currentUser!.documentId);
  }

  @override
  void dispose() {
    super.dispose();
    notifierIsSearching!.dispose();
    _txtSearchGroup!.dispose();
    _blocFollower!.dispose();
    Helper.routeObserver.unsubscribe(this);
  }

  @override
  Widget build(BuildContext context) {
    _config = AppConfig.of(context);
    return Container(
      padding: EdgeInsets.zero,
      width: double.infinity,
      height: double.infinity,
      child: _widgetGroups(context),
    );
  }

  Widget _widgetGroups(BuildContext mainContext) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      padding: EdgeInsets.zero,
      child: Column(
        children: <Widget>[
          Container(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: TextButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PublicGroup(),
                      ));
                },
                child: Text(
                  AppConstants.joinpublicgroup.toUpperCase(),
                  style: _config!.abel20FontStyle.apply(
                      color: _config!.btnPrimaryColor, fontWeightDelta: 2),
                ),
              )),
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
            await Navigator.pushNamed(context, AddGroup.routeName,
                arguments: AddGroupArgs(groupModel: null));
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
                  style: _config!.abelNormalFontStyle.apply(
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
    if (_groupSearchTimer?.isActive ?? false) _groupSearchTimer!.cancel();
    _groupSearchTimer = Timer(const Duration(milliseconds: 500), () {
      notifierIsSearching!.value = true;
      _listGroups!.clear();
      _blocFollower!.searchGroup(context, searchText: text);
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
              return NODataWidget();
            }
            return ListView.builder(
                shrinkWrap: true,
                itemCount: isLoading ? 5 : _listGroups!.length,
                itemBuilder: (_, int index) {
                  GroupModel? data = isLoading ? null : _listGroups![index];
                  return GestureDetector(
                    onTapDown: (_) {
                      Navigator.pushNamed(
                        context,
                        GroupMembers.routeName,
                        arguments: GroupMembersArgs(groupModel: data!),
                      );
                    },
                    child: GroupWidget(
                      data: data!,
                      currentUser: _currentUser!,
                      index: index,
                    ),
                  );
                });
          }),
    );
  }
}
