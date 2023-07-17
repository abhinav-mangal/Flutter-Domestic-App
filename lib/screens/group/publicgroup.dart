import 'dart:async';

import 'package:energym/app_config.dart';
import 'package:energym/models/group_model.dart';
import 'package:energym/models/user_model.dart';
import 'package:energym/reusable_component/custom_scaffold.dart';
import 'package:energym/reusable_component/custom_textfield.dart';
import 'package:energym/reusable_component/nodata.dart';
import 'package:energym/screens/followers/widget_group.dart';
import 'package:energym/screens/followers/widget_join_group.dart';
import 'package:energym/screens/group/groupmemberlist.dart';
import 'package:energym/utils/common/base_bloc.dart';
import 'package:energym/utils/common/common_widget.dart';
import 'package:energym/utils/common/constants.dart';
import 'package:energym/utils/common/main_app_bar.dart';
import 'package:energym/utils/helpers/firebase/firestore_provider.dart';
import 'package:flutter/material.dart';

import '../../utils/common/svg_icon.dart';
import '../followers/add_group.dart';
import '../followers/follower_bloc.dart';

// This is public group screen, contains only public group
class PublicGroup extends StatefulWidget {
  @override
  _PublicGroupState createState() => _PublicGroupState();
}

class _PublicGroupState extends State<PublicGroup>
    with SingleTickerProviderStateMixin {
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
    _blocFollower!
        .getUserNotJoinedGroups(context, userId: _currentUser!.documentId);
  }

  @override
  void dispose() {
    super.dispose();
    notifierIsSearching!.dispose();
    _txtSearchGroup!.dispose();
    _blocFollower!.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _config = AppConfig.of(context);
    return CustomScaffold(
      appBar: _getAppBar(),
      body: Container(
        padding: EdgeInsets.zero,
        width: double.infinity,
        height: double.infinity,
        child: _widgetGroups(context),
      ),
    );
  }

  PreferredSizeWidget _getAppBar() {
    return getMainAppBar(context, _config!,
        backgoundColor: Colors.transparent,
        textColor: _config!.whiteColor,
        title: AppConstants.publicGroups,
        elevation: 0, onBack: () {
      Navigator.pop(context, true);
    }, actions: <Widget>[
      btnSweatCointBalance(context, _config!),
    ]);
  }

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

                  return GroupJoinWidget(
                    data: data,
                    currentUser: _currentUser,
                    index: index,
                    onJoin: (_groupModel) {
                      print(_groupModel.groupName);
                      final Map<String, dynamic> _neetToStoreData =
                          <String, dynamic>{};

                      _groupModel.participantId
                          ?.add(_currentUser?.documentId ?? '');
                      _groupModel.participantName
                          ?.add(_currentUser?.fullName ?? '');
                      _neetToStoreData[GroupCollectionField.participantId] =
                          _groupModel.participantId;
                      _neetToStoreData[GroupCollectionField.participantName] =
                          _groupModel.participantName;

                      _blocFollower?.groupJoin(
                        context,
                        _groupModel,
                        _neetToStoreData,
                        (_) {
                          _blocFollower!.getUserNotJoinedGroups(context,
                              userId: _currentUser!.documentId);
                        },
                      );
                    },
                  );
                  // );
                });
          }),
    );
  }
}
