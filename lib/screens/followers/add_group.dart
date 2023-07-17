import 'dart:io';

import 'package:energym/app_config.dart';
import 'package:energym/models/error_message_model.dart';
import 'package:energym/models/follower_model.dart';
import 'package:energym/models/group_model.dart';
import 'package:energym/models/user_model.dart';
import 'package:energym/reusable_component/circular_image.dart';
import 'package:energym/reusable_component/custom_scaffold.dart';
import 'package:energym/reusable_component/custom_textfield.dart';
import 'package:energym/reusable_component/img_picker.dart';
import 'package:energym/reusable_component/main_app_bar.dart';
import 'package:energym/screens/followers/add_group_bloc.dart';
import 'package:energym/screens/followers/follower_bloc.dart';
import 'package:energym/screens/followers/widget_follower.dart';
import 'package:energym/utils/common/base_bloc.dart';
import 'package:energym/utils/common/circle_button.dart';
import 'package:energym/utils/common/config.dart';
import 'package:energym/utils/common/constants.dart';
import 'package:energym/utils/common/svg_icon.dart';
import 'package:energym/utils/helpers/firebase/firestore_provider.dart';
import 'package:energym/utils/helpers/routing/router.dart';
import 'package:energym/utils/theme/colors.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:path_provider/path_provider.dart';

// This screen for add and update group
// Group can be a public and private group
class AddGroupArgs extends RoutesArgs {
  AddGroupArgs({
    this.groupModel,
  }) : super(isHeroTransition: true);
  final GroupModel? groupModel;
}

class AddGroup extends StatefulWidget {
  const AddGroup({Key? key, this.groupModel}) : super(key: key);
  static const String routeName = '/AddGroup';
  final GroupModel? groupModel;

  @override
  _AddGroupState createState() => _AddGroupState();
}

class _AddGroupState extends State<AddGroup> {
  AppConfig? _appConfig;
  File? _selecteImage;
  AddGroupBloc? _blocAddGroup;
  TextEditingController? _txtGroupNameController;
  FocusNode? _focusNodeGroupName;
  FollowersBloc? _blocFollower;
  List<FollowerModel>? _listFollower = <FollowerModel>[];
  List<FollowerModel>? _selectedFollower = <FollowerModel>[];
  UserModel? _currentUser;
  ValueNotifier<bool> _notifierGroupType = ValueNotifier<bool>(true);
  GroupModel? _groupModel;
  int maxParticipents = 10;
  var myFile;
  bool isFirst = false;
  @override
  void initState() {
    _groupModel = widget.groupModel;
    _currentUser = aGeneralBloc.currentUser;
    _txtGroupNameController = TextEditingController();
    _focusNodeGroupName = FocusNode();
    _blocAddGroup = AddGroupBloc();
    _blocFollower = FollowersBloc();
    super.initState();
    _init();
  }

  _init() async {
    await _blocFollower!.getFollower(context, userId: _currentUser!.documentId);

    if (_groupModel != null) {
      // In case of edit

      // Download image
      downloadFile(_groupModel?.groupProfile ?? '', "${DateTime.now()}");

      // Group name
      _txtGroupNameController?.text = _groupModel?.groupName ?? '';
      _blocAddGroup!
          .onChangeGroupName(value: _groupModel?.groupName, isShowError: true);
      // Group types
      if (_groupModel?.groupType == 'Public')
        _notifierGroupType.value = false;
      else
        _notifierGroupType.value = true;
    }
  }

  @override
  void dispose() {
    _focusNodeGroupName!.dispose();
    _txtGroupNameController!.dispose();
    _blocAddGroup!.dispose();
    _notifierGroupType.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _appConfig = AppConfig.of(context);
    return CustomScaffold(
      appBar: _getAppBar(context),
      body: SafeArea(
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: Container(
            padding: EdgeInsets.zero,
            width: double.infinity,
            height: double.infinity,
            child: _mainContainerWidget(),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _getAppBar(BuildContext mainContext) {
    return getMainAppBar(
      mainContext,
      _appConfig!,
      backgoundColor: Colors.transparent,
      textColor: _appConfig!.whiteColor,
      title: (_groupModel == null)
          ? AppConstants.addGroup
          : AppConstants.updateGroup,
      elevation: 0,
      isBackEnable: false,
      onBack: () {},
      leadingWidget: IconButton(
        icon: Icon(
          Icons.close,
          size: 24,
          color: _appConfig!.whiteColor,
        ),
        onPressed: () {
          aGeneralBloc.updateAPICalling(false);
          Navigator.pop(context);
        },
      ),
      actions: <Widget>[
        StreamBuilder<bool>(
          stream: _blocAddGroup!.getAddGroupFormValid,
          builder: (BuildContext snapcontext, AsyncSnapshot<bool> snapshot) {
            bool isValid = false;
            if (snapshot.hasData && snapshot.data != null) {
              isValid = snapshot.data!;
            }

            return StreamBuilder<bool>(
              stream: aGeneralBloc.getIsApiCalling,
              builder: (BuildContext snapcontext,
                  AsyncSnapshot<bool> apiCallingSnapshot) {
                bool isLoading = false;
                if (apiCallingSnapshot.hasData &&
                    apiCallingSnapshot.data != null) {
                  isLoading = apiCallingSnapshot.data!;
                }

                if (isLoading) {
                  return Container(
                    width: 30,
                    height: 20,
                    padding: EdgeInsets.zero,
                    child: Center(
                      child: SpinKitCircle(
                        color: _appConfig!.btnPrimaryColor,
                        size: 20,
                        // size: loaderWidth ,
                      ),
                    ),
                  );
                } else {
                  return IconButton(
                    highlightColor: Colors.transparent,
                    splashColor: Colors.transparent,
                    iconSize: 50,
                    icon: Text(
                      (_groupModel == null)
                          ? AppConstants.create
                          : AppConstants.update,
                      style: _appConfig!.linkNormalFontStyle.apply(
                          color: isValid
                              ? _appConfig!.btnPrimaryColor
                              : _appConfig!.greyColor),
                    ),
                    //color: color,
                    tooltip:
                        MaterialLocalizations.of(context).backButtonTooltip,
                    onPressed: () {
                      if (isValid) {
                        aGeneralBloc.updateAPICalling(true);
                        if (_groupModel != null) {
                          // Update group

                          List<String> participentId = [];

                          participentId = _selectedFollower!
                              .map((FollowerModel follower) =>
                                  follower.followerId!)
                              .toList();
                          participentId.add(_currentUser!.documentId!);

                          List<String> participentName = [];

                          participentName = _selectedFollower!
                              .map((FollowerModel follower) =>
                                  follower.followerFullName!)
                              .toList();
                          participentName.add(_currentUser!.fullName!);
                          FireStoreProvider.instance.updateGroup(
                            context: context,
                            groupId: _groupModel?.documentId,
                            groupImage: _selecteImage,
                            groupName: _txtGroupNameController?.text ?? '',
                            adminId: _groupModel?.adminId,
                            participantesId: participentId,
                            participantesName: participentName,
                            groupType:
                                _notifierGroupType.value ? 'Private' : 'Public',
                            onSuccess: (Map<String, dynamic> success) {
                              aGeneralBloc.updateAPICalling(false);
                              Navigator.of(context).popUntil((route) {
                                print(route.settings.name);
                                if (route.isFirst) {
                                  return true;
                                }
                                return false;
                              });
                            },
                            onError: (Map<String, dynamic> error) {
                              aGeneralBloc.updateAPICalling(false);
                            },
                          );
                        } else {
                          // Create group

                          List<String> participentId = [];

                          participentId = _selectedFollower!
                              .map((FollowerModel follower) =>
                                  follower.followerId!)
                              .toList();
                          participentId.add(_currentUser!.documentId!);

                          List<String> participentName = [];

                          participentName = _selectedFollower!
                              .map((FollowerModel follower) =>
                                  follower.followerFullName!)
                              .toList();
                          participentName.add(_currentUser!.fullName!);

                          FireStoreProvider.instance.createGroup(
                            context: context,
                            adminId: _currentUser!.documentId,
                            groupImage: _selecteImage,
                            groupName: _txtGroupNameController?.text ?? '',
                            participantesId: participentId,
                            participantesName: participentName,
                            groupType:
                                _notifierGroupType.value ? 'Private' : 'Public',
                            onSuccess: (Map<String, dynamic> success) {
                              aGeneralBloc.updateAPICalling(false);
                              Navigator.pop(context, true);
                            },
                            onError: (Map<String, dynamic> error) {
                              aGeneralBloc.updateAPICalling(false);
                            },
                          );
                        }
                      }
                    },
                  );
                }
              },
            );
          },
        )
      ],
    );
  }

  Widget _mainContainerWidget() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        children: [
          Row(
            children: [
              _userProfile(context),
              Expanded(
                child: _widgetGroupName(),
              ),
              Container(
                // color: Colors.red,
                width: 80,
                height: 50,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    SvgIcon.asset(ImgConstants.lock, size: 12),
                    _widgetGroupType()
                  ],
                ),
              )
            ],
          ),
          _selectedParticepent(context),
          const SizedBox(
            height: 10,
          ),
          _widgetFollowerList(context),
        ],
      ),
    );
  }

  Widget _userProfile(BuildContext context) {
    return StreamBuilder<File?>(
        stream: _blocAddGroup!.getGroupImage,
        builder: (BuildContext? context, AsyncSnapshot<File?>? snapshot) {
          if (snapshot!.hasData && snapshot.data != null) {
            _selecteImage = snapshot.data;
          }
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              _widgetPofilePictureHintText(),
              _widgetProfilePickButton(mainContext: context),
            ],
          );
        });
  }

  Widget _widgetPofilePictureHintText() {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
      child: Text(
        AppConstants.hintGroupPicture,
        style: _appConfig!.paragraphExtraSmallFontStyle.apply(
          color: _appConfig!.greyColor,
        ),
      ),
    );
  }

  Widget _widgetProfilePickButton({BuildContext? mainContext}) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 0),
      child: TextButton(
        onPressed: () {
          showModalBottomSheet<void>(
            context: mainContext!,
            builder: (BuildContext context) {
              return ImagePickerHelper(
                title: AppConstants.hintProfilePicture,
                isCropped: true,
                cropStyle: CropStyle.circle,
                size: SizeConfig.kSquare400Size,
                onDone: (File? file) {
                  if (file != null) {
                    _blocAddGroup!
                        .onChangeProfilePic(value: file, isShowError: true);
                  }
                },
              );
            },
          );
        },
        child: Stack(
          children: <Widget>[
            if (_selecteImage != null)
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(80 / 2),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(80 / 2),
                  child: Image.file(
                    _selecteImage!,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              )
            else if (_selecteImage == null)
              CircleButton(
                iconName: ImgConstants.camera,
                backgroundColor: _appConfig!.borderColor,
                buttonSize: 60,
                iconColor: _appConfig!.whiteColor,
                iconSize: 20,
                //onPressed: () {},
              ),
            if (_selecteImage != null || _groupModel != null)
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border:
                          Border.all(width: 2, color: _appConfig!.borderColor),
                      color: _appConfig!.greyColor),
                  child: Center(
                    child: SvgIcon.asset(
                      ImgConstants.camera,
                      color: _appConfig!.whiteColor,
                      size: 15,
                    ),
                  ),
                ),
              )
          ],
        ),
      ),
    );
  }

  Widget _widgetGroupName() {
    return Container(
      padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
      child: StreamBuilder<ErrorMessage>(
        stream: _blocAddGroup!.getGroupNameErrorMessage,
        initialData: ErrorMessage(false, ''),
        builder: (BuildContext context, AsyncSnapshot<ErrorMessage> snapshot) {
          return CustomTextField(
            context: context,
            controller: _txtGroupNameController,
            focussNode: _focusNodeGroupName,
            showFlotingHint: true,
            floatingLabelBehavior: FloatingLabelBehavior.auto,
            lableText: AppConstants.hintGroupName,
            //hindText: AppConstants.hintFullName,
            inputType: TextInputType.text,
            capitalization: TextCapitalization.words,
            inputAction: TextInputAction.done,
            enableSuggestions: true,
            isAutocorrect: true,
            maxlength: 50,
            padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
            onchange: (String value) {
              _blocAddGroup!.onChangeGroupName(value: value, isShowError: true);
            },
            onSubmit: (String value) {
              _focusNodeGroupName!.unfocus();
            },
            errorText: snapshot.data!.errorMessage.isEmpty
                ? null
                : snapshot.data!.errorMessage,
          );
        },
      ),
    );
  }

  Widget _widgetGroupType() {
    return ValueListenableBuilder<bool>(
      valueListenable: _notifierGroupType,
      builder: (BuildContext? context, bool isNotify, Widget? child) {
        return Container(
          padding: EdgeInsets.zero,
          height: 20,
          child: Platform.isAndroid
              ? Switch(
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  value: isNotify,
                  activeColor: AppColors.blueworkout,
                  onChanged: (bool value) async {
                    _notifierGroupType.value = value;
                  })
              : CupertinoSwitch(
                  activeColor: AppColors.blueworkout,
                  value: isNotify,
                  onChanged: (bool value) async {
                    _notifierGroupType.value = value;
                  }),
        );
      },
    );
  }

  Widget _selectedParticepent(BuildContext context) {
    return StreamBuilder<List<FollowerModel>>(
      stream: _blocAddGroup!.getGroupMamber,
      builder: (_, AsyncSnapshot<List<FollowerModel>> snapshot) {
        final bool isLoading = !snapshot.hasData;

        if (snapshot.hasData && snapshot.data != null) {
          _selectedFollower = snapshot.data;
        }

        if (_selectedFollower!.isEmpty) {
          return const SizedBox();
        }

        return Container(
          padding: EdgeInsets.zero,
          width: double.infinity,
          height: 90,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(16, 10, 16, 5),
                child: Text(
                  '${AppConstants.participant} ${_selectedFollower!.length}/$maxParticipents',
                  style: _appConfig!.paragraphExtraSmallFontStyle.apply(
                    color: _appConfig!.greyColor,
                  ),
                ),
              ),
              Container(
                width: double.infinity,
                height: 60,
                child: ListView.builder(
                  padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 0),
                  shrinkWrap: true,
                  physics: const ClampingScrollPhysics(),
                  scrollDirection: Axis.horizontal,
                  itemCount: isLoading ? 5 : _selectedFollower!.length,
                  itemBuilder: (_, int index) {
                    final FollowerModel? data =
                        isLoading ? null : _selectedFollower![index];

                    return Container(
                      width: 60,
                      height: 60,
                      child: Stack(
                        children: [
                          CircularImage(
                            data?.followerProfilePhoto ?? '',
                            width: 60,
                            height: 60,
                          ),
                          _widgetDeleteButton(data!),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _widgetDeleteButton(FollowerModel data) {
    return Positioned(
      top: 0,
      right: 0,
      child: CircleButton(
        iconName: ImgConstants.close,
        backgroundColor: _appConfig!.greyColor,
        iconColor: _appConfig!.whiteColor,
        buttonSize: 24,
        iconSize: 10,
        radius: 12,
        onPressed: () {
          if (data != null) {
            _selectedFollower!.remove(data);
            _blocAddGroup!.updateFollower(_selectedFollower!);
            _blocFollower!.updateFollower(_listFollower!);
          }
        },
      ),
    );
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
            _listFollower = snapshot.data;
            if (!isFirst) {
              isFirst = true;
              getSelectedUser(_listFollower);
            }
            print('Done data received 1');
          }

          if (_listFollower!.isEmpty) {
            return const SizedBox();
          }
          return Expanded(
            child: ListView.builder(
              shrinkWrap: true,
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: isLoading ? 5 : _listFollower!.length,
              itemBuilder: (_, int index) {
                FollowerModel? data = isLoading ? null : _listFollower![index];

                bool isSelected = false;
                FollowerModel? selected;
                if (data != null && _selectedFollower!.isNotEmpty) {
                  selected = _selectedFollower!.firstWhere(
                    (FollowerModel element) =>
                        element.followerId == data.followerId,
                    orElse: () => FollowerModel(),
                  );
                  isSelected =
                      (selected != null && selected.documentId != null);
                }

                return FollowerWidget(
                  data: data,
                  currentUser: _currentUser,
                  isSelectable: true,
                  isSelected: isSelected,
                  onPress: () {
                    if (data != null &&
                        _selectedFollower!.length < maxParticipents) {
                      if (selected != null && selected.documentId != null) {
                        _selectedFollower!.remove(selected);
                      } else {
                        _selectedFollower!.add(data);
                      }
                      _blocAddGroup!.updateFollower(_selectedFollower!);
                      _blocFollower!.updateFollower(_listFollower!);
                    }
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }

  // This is to get selected followers
  Future<void> getSelectedUser(List<FollowerModel>? listFollowers) async {
    listFollowers?.forEach((data) {
      if (_groupModel!.participantId!.contains(data.followerId)) {
        if (data.followerId != _currentUser!.documentId) {
          _selectedFollower!.add(data);
          _blocAddGroup!.updateFollower(_selectedFollower!);
        }
      }
    });
  }

  // This function for download group thumbnail
  Future<void> downloadFile(String uri, fileName) async {
    String savePath = await getFilePath(fileName);
    print(savePath);
    Dio dio = Dio();

    dio
        .download(
      uri,
      savePath,
      deleteOnError: true,
    )
        .then((value) {
      _blocAddGroup!
          .onChangeProfilePic(value: File(savePath), isShowError: true);
    });
  }

  Future<String> getFilePath(uniqueFileName) async {
    String path = '';

    Directory dir = await getApplicationDocumentsDirectory();

    path = '${dir.path}/$uniqueFileName.jpg';

    return path;
  }
}
