import 'dart:async';
import 'dart:io';

import 'package:energym/app_config.dart';
import 'package:energym/models/error_message_model.dart';
import 'package:energym/reusable_component/circular_image.dart';
import 'package:energym/reusable_component/custom_dialog.dart';
import 'package:energym/reusable_component/custom_scaffold.dart';
import 'package:energym/reusable_component/custom_textfield.dart';
import 'package:energym/reusable_component/date_picker.dart';
import 'package:energym/reusable_component/img_picker.dart';
import 'package:energym/reusable_component/loader_button.dart';
import 'package:energym/reusable_component/shared_pref_helper.dart';
import 'package:energym/screens/cms/cms.dart';
import 'package:energym/screens/profile_setup/profile_setup_bloc.dart';
import 'package:energym/utils/common/base_bloc.dart';
import 'package:energym/utils/common/circle_button.dart';
import 'package:energym/utils/common/config.dart';
import 'package:energym/utils/common/constants.dart';
import 'package:energym/utils/common/main_app_bar.dart';
import 'package:energym/utils/common/svg_icon.dart';
import 'package:energym/utils/common/svg_picture_customise.dart';
import 'package:energym/utils/extensions/extension.dart';
import 'package:energym/utils/helpers/firebase/firestore_provider.dart';
import 'package:energym/utils/helpers/firebase/storage_provider.dart';
import 'package:energym/utils/helpers/health_provider.dart';
import 'package:energym/utils/helpers/routing/router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geocode/geocode.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:path/path.dart' as path;
import 'package:permission_handler/permission_handler.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';

class ProfileSetUpArgs extends RoutesArgs {
  ProfileSetUpArgs({
    required this.userId,
    required this.isNewUser,
    this.currentStep,
  }) : super(isHeroTransition: true);
  final String? userId;
  final bool? isNewUser;
  final int? currentStep;
}

class ProfileSetUp extends StatefulWidget {
  const ProfileSetUp({
    Key? key,
    required this.userId,
    required this.isNewUser,
    this.currentStep,
  }) : super(key: key);

  static const String? routeName = '/ProfileSetUp';
  final String? userId;
  final bool? isNewUser;
  final int? currentStep;

  @override
  _ProfileSetUpState createState() => _ProfileSetUpState();
}

class _ProfileSetUpState extends State<ProfileSetUp>
    with SingleTickerProviderStateMixin {
  AppConfig? _config;
  String? _userId;
  bool? _isNewUser;
  List<Widget>? _listWidget = <Widget>[];
  PageController? _pageController;
  ProfileSetUpBloc? _blocProfileSetUp;
  int? _currentSetupStep = 0;
  int? maxStep = 13;
  TextEditingController? _txtController;
  FocusNode? _focusNode;
  TextEditingController? _txtTypeController;
  FocusNode? _typeFocusNode;

  dynamic? _selecteProfile;
  Position? currentLocation;
  Coordinates? addressCoordinates;
  final ValueNotifier<bool>? _notifierIsFetchingLocation =
      ValueNotifier<bool>(false);

  String? _selectedHeightType = 'ft';
  String? _selectedHeight = '5\'6\'\'';

  String? _selectedWeightType = 'kg';
  double? _selectedWeight = 65.0;
  DateTime? _selectedDob;
  int? _selectedActivityLevel = 1;
  int? _selectedDailyGoal = 1;
  int? _selectedCaloriesTOBurn = 65;
  String? _selectedGender = 'Female';

  int? _selectedMinutes = 65;
  int? _selectedEnergyGenerate = 65;
  int? _selectedFTP = 100;
  Map<String?, dynamic>? _profileData = <String, dynamic>{};

  bool isSearching = false;
  Timer? _searchTimer;
  String? jwtToken;

  TabController? _tabController;
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _userId = widget.userId;
    _isNewUser = widget.isNewUser;
    if (!_isNewUser!) {
      FireStoreProvider.instance.fetchCurrentUser();
    }

    _currentSetupStep = (widget.currentStep! > 0) ? (widget.currentStep! - 1) : 0;
    _txtController = TextEditingController();
    _focusNode = FocusNode();
    _txtTypeController = TextEditingController();
    _typeFocusNode = FocusNode();
    _blocProfileSetUp = ProfileSetUpBloc();
    _blocProfileSetUp!.updateSetp(stepValue: _currentSetupStep);
    _pageController = PageController(initialPage: _currentSetupStep!);
  }

  @override
  void dispose() {
    _focusNode!.dispose();
    _txtController!.dispose();
    _txtTypeController!.dispose();
    _typeFocusNode!.dispose();
    if (_searchTimer != null) {
      _searchTimer!.cancel();
    }
    _tabController!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _config = AppConfig.of(context);

    return StreamBuilder<int?>(
        stream: _blocProfileSetUp!.getProfileSetUpStep,
        initialData: _currentSetupStep,
        builder: (BuildContext? context, AsyncSnapshot<int?> snapshot) {
          if (snapshot.hasData && snapshot.data != null) {
            _currentSetupStep = snapshot.data;
          }
          return CustomScaffold(
            resizeToAvoidBottomInset: true,
            appBar: _getAppBar(),
            body: SafeArea(
              child: GestureDetector(
                onTap: () {
                  FocusScope.of(context!).unfocus();
                },
                child: Container(
                  padding: EdgeInsets.zero,
                  width: double.infinity,
                  height: double.infinity,
                  child: StreamBuilder<DocumentSnapshot?>(
                      stream: FireStoreProvider.instance.getCurrentUserUpdate,
                      builder: (BuildContext context,
                          AsyncSnapshot<DocumentSnapshot?> snapshot) {
                        print('NO DATA');
                        if (snapshot.hasData && snapshot.data != null) {
                          _profileData =
                              snapshot.data!.data()! as Map<String, dynamic>;
                          print('ProfileData = $_profileData');
                        }
                        return _mainContainer(context);
                      }),
                ),
              ),
            ),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerDocked,
            floatingActionButton: _btnNext(),
          );
        });
  }

  PreferredSizeWidget _getAppBar() {
    return getMainAppBar(context, _config!,
        widget: Text(
          '${_currentSetupStep! + 1} ${AppConstants.of} $maxStep',
          style: _config!.paragraphNormalFontStyle
              .apply(color: _config!.greyColor),
        ),
        backgoundColor: Colors.transparent,
        elevation: 0,
        isBackEnable: _currentSetupStep != 0, onBack: () {
      aGeneralBloc.updateAPICalling(false);
      if (_currentSetupStep == 0) {
        //Navigator.pop(context);
      } else {
        _currentSetupStep! - 1;
        _txtController!.text = '';
        _txtTypeController!.text = '';
        _blocProfileSetUp!.updateSetp(stepValue: _currentSetupStep ?? 0 + 1);
      }
    }, actions: <Widget>[
      if (_currentSetupStep! >= 1 && _currentSetupStep! <= 5)
        IconButton(
          highlightColor: Colors.transparent,
          splashColor: Colors.transparent,
          //iconSize: 16,
          icon: Text(
            AppConstants.skip,
            style:
                _config!.linkNormalFontStyle.apply(color: _config!.greyColor),
          ),
          //color: color,
          tooltip: MaterialLocalizations.of(context).backButtonTooltip,
          onPressed: () {
            _txtController!.text = '';
            _txtTypeController!.text = '';
            _currentSetupStep! + 1;
            _blocProfileSetUp!
                .updateSetp(stepValue: (_currentSetupStep ?? 0) + 1);
          },
        ),
      if (_currentSetupStep == 7 || _currentSetupStep == 8)
        IconButton(
          highlightColor: Colors.transparent,
          splashColor: Colors.transparent,
          //iconSize: 16,
          icon: Icon(
            Icons.info_outline,
            size: 24,
            color: _config!.whiteColor,
          ),
          //color: color,
          tooltip: MaterialLocalizations.of(context).backButtonTooltip,
          onPressed: () {
            Navigator.pushNamed(context, CMS.routeName,
                arguments: CmsArgs(cmsType: CMSType.info));
          },
        )
    ]);
  }

  Widget _mainContainer(BuildContext mainContext) {
    return StreamBuilder<int?>(
      stream: _blocProfileSetUp!.getProfileSetUpStep,
      builder: (BuildContext? steamContext, AsyncSnapshot<int?> snapshot) {
        print('Hello');
        if (snapshot.hasData && snapshot.data != null) {
          print('Hello1');
          _currentSetupStep = snapshot.data;
          print('${snapshot.data}');
          changeStepView(mainContext);
          print('Hello3');
        }
        return Column(
          children: <Widget>[
            _widgetVerifyText(),
            Expanded(
              child: Container(
                padding: EdgeInsets.zero,
                width: double.infinity,
                height: double.infinity,
                child: _getStepWidget(mainContext),
              ),
            )
          ],
        );
      },
    );
  }

  void changeStepView(BuildContext mainContext) {
    _pageController!
        .animateToPage(_currentSetupStep!,
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOut)
        .then((value) {
      switch (_currentSetupStep) {
        case -1:
          if (_txtController!.text.isEmpty) {
            print(
                '_textController == ${_profileData![UserCollectionField.fullName]}');
            if (_profileData![UserCollectionField.fullName] != null) {
              _txtController!.text =
                  _profileData![UserCollectionField.fullName] as String;
            }

            if (_txtController!.text.isNotEmpty) {
              _blocProfileSetUp!.onChangeFullName(value: _txtController!.text);
            }
          }

          break;
        case -2:
          if (_txtController!.text.isEmpty) {
            if (_profileData![UserCollectionField.email] != null) {
              _txtController!.text =
                  _profileData![UserCollectionField.email] as String;
            }
            if (_txtController!.text.isNotEmpty) {
              _blocProfileSetUp!
                  .onChangeEmailAddress(value: _txtController!.text);
            }
          }

          break;
        case 0:
          if (_txtController!.text.isEmpty) {
            if (_profileData![UserCollectionField.username] != null) {
              _txtController!.text =
                  _profileData![UserCollectionField.username] as String;
            }
            if (_txtController!.text.isNotEmpty) {
              _blocProfileSetUp!.onChangeUserName(value: _txtController!.text);
            }
          }

          break;
        case 1:
          if (_profileData![UserCollectionField.profilePhoto] != null) {
            final String profileImageUrl =
                _profileData![UserCollectionField.profilePhoto] as String;
            if (profileImageUrl != null && profileImageUrl.isNotEmpty) {
              _selecteProfile = profileImageUrl;
              _blocProfileSetUp!.onChangeProfilePic(value: _selecteProfile);
            }
          }
          break;
        case 2:
          _checkForLocationPemission(mainContext);
          if (_txtController!.text.isEmpty) {
            if (_profileData![UserCollectionField.address] != null) {
              _txtController!.text =
                  _profileData![UserCollectionField.address] as String;
            }
            if (_txtController!.text.isNotEmpty) {
              _blocProfileSetUp!.onChangeLocation(value: _txtController!.text);
            }
          }

          break;
        case 3:
          if (_profileData![UserCollectionField.height] != null) {
            _selectedHeight =
                _profileData![UserCollectionField.height] as String;
          }
          _txtController!.text = _selectedHeight!;
          if (_txtController!.text.isNotEmpty) {
            _blocProfileSetUp!.onChangeHeight(value: _selectedHeight);
          }

          if (_profileData![UserCollectionField.heightType] != null) {
            _txtTypeController!.text =
                _profileData![UserCollectionField.heightType] as String;
          }
          _txtTypeController!.text = _selectedHeightType!;
          if (_txtController!.text.isNotEmpty) {
            _blocProfileSetUp!.onChangeHeightType(value: _selectedHeightType);
          }

          break;
        case 4:
          if (_profileData![UserCollectionField.wight] != null) {
            _selectedWeight =
                _profileData![UserCollectionField.wight] as double;
          }
          _txtController!.text = _selectedWeight.toString();
          if (_txtController!.text.isNotEmpty) {
            _blocProfileSetUp!.onChangeWeight(value: _selectedWeight);
          }

          _txtTypeController!.text = _selectedWeightType!;
          if (_profileData![UserCollectionField.wightType] != null) {
            _txtTypeController!.text =
                _profileData![UserCollectionField.wightType] as String;
          }

          if (_txtController!.text.isNotEmpty) {
            _selectedWeightType = _txtTypeController!.text;
            _blocProfileSetUp!.onChangeWeightType(value: _selectedWeightType);
          }
          break;
        case 5:
          if (_profileData![UserCollectionField.birthDate] != null) {
            final String dateStr =
                _profileData![UserCollectionField.birthDate] as String;

            if (dateStr.isNotEmpty) {
              _selectedDob = dateStr.getDateFromString();
            }
            if (_selectedDob != null) {
              _txtController!.text = _selectedDob!.dateTimeString();
              _blocProfileSetUp!.onChangeBirthday(value: _txtController!.text);
            }
          }
          break;
        case 6:
          if (_profileData![UserCollectionField.gender] != null) {
            _txtController!.text =
                _profileData![UserCollectionField.gender] as String;
          }
          _txtController!.text = _selectedGender!;
          if (_txtController!.text.isNotEmpty) {
            _blocProfileSetUp!.onChangeGender(value: _selectedGender);
          }
          break;
        case 7:
          if (_profileData![UserCollectionField.activityLevel] != null) {
            final int level =
                _profileData![UserCollectionField.activityLevel] as int;
            _blocProfileSetUp!.onChangeActivityLevel(value: level);
          }

          break;
        case 8:
          if (_profileData![UserCollectionField.activityGoal] != null) {
            final int goal =
                _profileData![UserCollectionField.activityGoal] as int;
            _blocProfileSetUp!.onChangeActivityGoal(value: goal);
          }

          break;
        case 9:
          if (_profileData![UserCollectionField.calorieGoal] != null) {
            _selectedCaloriesTOBurn =
                _profileData![UserCollectionField.calorieGoal] as int;
          }

          if (_selectedCaloriesTOBurn != null) {
            _txtController!.text =
                '$_selectedCaloriesTOBurn'; // ${AppConstants.calories}';
            _blocProfileSetUp!
                .onChangeCaloriesGoal(value: _txtController!.text);
          }
          break;
        case 10:
          if (_profileData![UserCollectionField.activeMinuteGoal] != null) {
            _selectedMinutes =
                _profileData![UserCollectionField.activeMinuteGoal] as int;
          }

          if (_selectedMinutes != null) {
            _txtController!.text =
                '$_selectedMinutes'; // ${AppConstants.minutes}';
            _blocProfileSetUp!.onChangeMinutesGoal(value: _txtController!.text);
          }

          break;
        case 11:
          if (_profileData![UserCollectionField.energyGenerateGoal] != null) {
            _selectedEnergyGenerate =
                _profileData![UserCollectionField.energyGenerateGoal] as int;
          }

          if (_selectedMinutes != null) {
            _txtController!.text =
                '$_selectedEnergyGenerate'; // ${AppConstants.watt}';
            _blocProfileSetUp!
                .onChangeEnergyEngGoal(value: _txtController!.text);
          }

          break;
        case 12:
          if (_profileData![UserCollectionField.ftpValue] != null) {
            _selectedFTP = _profileData![UserCollectionField.ftpValue] as int;
          }
          if (_selectedFTP != null) {
            _txtController!.text = '$_selectedFTP';
            _blocProfileSetUp!.onChangeFTP(value: _txtController!.text);
          }

          break;
        default:
          break;
      }
    });
  }

  Widget _widgetVerifyText() {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(32, 0, 32, 0),
      child: Align(
        alignment: Alignment.topCenter,
        child: Text(
          _getHeaderTitle(),
          style: _config!.calibriHeading2FontStyle.apply(
            color: _config!.whiteColor,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  String _getHeaderTitle() {
    switch (_currentSetupStep) {
      case 7:
        return AppConstants.activityLevelTitle;
      case 8:
        return AppConstants.dailyGoalTitle;
      case 9:
        return AppConstants.calorieGoalTitle;
      case 10:
        return AppConstants.minutesGoalTitle;
      case 11:
        return AppConstants.energyGoalTitle;
      case 12:
        return AppConstants.titleFTP;
      default:
        return AppConstants.completeYourProfileTitle;
    }
  }

  Future<List<Widget>> setUpStepWidget(BuildContext mainContext) async {
    final List<Widget> _list = <Widget>[];
    // _list.add(_step1FullName());
    // _list.add(_step2Email());
    _list.add(_step3UserName());
    _list.add(_step4Profile(mainContext));
    _list.add(_step5location(mainContext));
    _list.add(_step6Height(mainContext));
    _list.add(_step7Weight(mainContext));
    _list.add(_step8Birthday(mainContext));
    _list.add(_stepGender());
    _list.add(_step9ActivityLevel());
    _list.add(_step10DailyActivityGoal());
    _list.add(_step11CalorieGoal());
    _list.add(_step12MinutesGoal());
    _list.add(_step13EnergyGenerate());
    _list.add(_step14SetFTP());
    return _list;
  }

  Widget _getStepWidget(BuildContext mainContext) {
    return FutureBuilder<List<Widget>>(
        future: setUpStepWidget(mainContext),
        builder: (BuildContext context, AsyncSnapshot<List<Widget>> snapshot) {
          if (snapshot.hasData && snapshot.data != null) {
            _listWidget = snapshot.data;
          }
          return PageView(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            onPageChanged: (int page) {},
            children: _listWidget!,
          );
        });
  }

  // ************ START SCREENS ***************

  Widget _step1FullName() {
    return SingleChildScrollView(
      padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
      child: Container(
        padding: const EdgeInsetsDirectional.fromSTEB(24, 86, 24, 0),
        child: StreamBuilder<ErrorMessage?>(
          stream: _blocProfileSetUp!.getFullNameErrorMessage,
          initialData: ErrorMessage(false, ''),
          builder:
              (BuildContext? context, AsyncSnapshot<ErrorMessage?> snapshot) {
            return CustomTextField(
              context: context,
              controller: _txtController,
              focussNode: _focusNode,
              showFlotingHint: true,
              floatingLabelBehavior: FloatingLabelBehavior.auto,
              lableText: AppConstants.hintFullName,
              //hindText: AppConstants.hintFullName,
              inputType: TextInputType.text,
              capitalization: TextCapitalization.words,
              inputAction: TextInputAction.next,
              enableSuggestions: true,
              isAutocorrect: true,
              maxlength: 50,
              padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
              onchange: (String value) {
                _blocProfileSetUp!.onChangeFullName(value: value);
              },
              onSubmit: (String value) {
                _focusNode!.unfocus();
              },
              errorText: snapshot.data!.errorMessage.isEmpty
                  ? null
                  : snapshot.data!.errorMessage,
            );
          },
        ),
      ),
    );
  }

  Widget _step2Email() {
    return SingleChildScrollView(
      padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
      child: Container(
        padding: const EdgeInsetsDirectional.fromSTEB(24, 86, 24, 0),
        child: StreamBuilder<ErrorMessage?>(
          stream: _blocProfileSetUp!.getEmailErrorMessage,
          initialData: ErrorMessage(false, ''),
          builder:
              (BuildContext? context, AsyncSnapshot<ErrorMessage?> snapshot) {
            return CustomTextField(
              stackAlignment: Alignment.centerRight,
              context: context,
              controller: _txtController,
              focussNode: _focusNode,
              showFlotingHint: true,
              floatingLabelBehavior: FloatingLabelBehavior.auto,
              lableText: AppConstants.hintEmailAddress,
              hindText: AppConstants.hintFullName,
              inputType: TextInputType.emailAddress,
              capitalization: TextCapitalization.none,
              inputAction: TextInputAction.go,
              enableSuggestions: true,
              isAutocorrect: true,
              maxlength: 50,
              padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
              sufixWidget: snapshot.data!.errorMessage.isEmpty
                  ? _widgetCheckMark()
                  : const SizedBox(),
              onchange: (String value) {
                _blocProfileSetUp!
                    .onChangeEmailAddress(value: value, isShowError: true);
              },
              onSubmit: (String value) {
                _focusNode!.unfocus();
              },
              errorText: snapshot.data!.errorMessage.isEmpty
                  ? null
                  : snapshot.data!.errorMessage,
            );
          },
        ),
      ),
    );
  }

  Widget _widgetCheckMark() {
    return Container(
      padding: EdgeInsets.zero,
      width: 20,
      height: 20,
      child: SvgIcon.asset(
        ImgConstants.checkmark,
        size: 15,
        color: _config!.btnPrimaryColor,
      ),
    );
  }

  Widget _step3UserName() {
    //String userName = _profileData![UserCollectionField.username] as String;
    return SingleChildScrollView(
      padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
      child: Container(
        padding: const EdgeInsetsDirectional.fromSTEB(24, 86, 24, 0),
        child: StreamBuilder<ErrorMessage?>(
          stream: _blocProfileSetUp!.getUserNameErrorMessage,
          initialData: ErrorMessage(false, ''),
          builder:
              (BuildContext? context, AsyncSnapshot<ErrorMessage?> snapshot) {
            return CustomTextField(
              stackAlignment: Alignment.centerRight,
              context: context,
              controller: _txtController,
              focussNode: _focusNode,
              showFlotingHint: true,
              //isEnable: userName.isEmpty,
              floatingLabelBehavior: FloatingLabelBehavior.auto,
              lableText: AppConstants.hintUserName,
              //hindText: AppConstants.hintFullName,
              inputType: TextInputType.text,
              capitalization: TextCapitalization.none,
              inputAction: TextInputAction.go,
              enableSuggestions: true,
              isAutocorrect: true,
              maxlength: 50,
              padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
              sufixWidget: snapshot.data!.errorMessage.isEmpty
                  ? _widgetCheckMark()
                  : const SizedBox(),
              //onchange: _onSearch,
              onchange: (String value) {
                _blocProfileSetUp!
                    .onChangeUserName(value: value, isShowError: true);
              },
              onSubmit: (String value) {
                _focusNode!.unfocus();
              },
              errorText: snapshot.data!.errorMessage.isEmpty
                  ? null
                  : snapshot.data!.errorMessage,
            );
          },
        ),
      ),
    );
  }

  void _onSearch(String text) {
    if (_searchTimer?.isActive ?? false) _searchTimer!.cancel();
    _searchTimer = Timer(const Duration(milliseconds: 500), () async {
      isSearching = true;
    });
  }

  Widget _step4Profile(BuildContext context) {
    return StreamBuilder<dynamic>(
        stream: _blocProfileSetUp!.getProfilePic,
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.hasData && snapshot.data != null) {
            _selecteProfile = snapshot.data;
          }
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              _widgetPofilePictureHintText(),
              _widgetProfilePickButton(mainContext: context),
              _widgetOR(),
              _widgetSelecteFromBelowHintText(),
              _listVectorProfile(),
            ],
          );
        });
  }

  Widget _widgetPofilePictureHintText() {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
      child: Text(
        AppConstants.hintProfilePicture.toUpperCase(),
        style: _config!.paragraphExtraSmallFontStyle.apply(
          color: _config!.greyColor,
        ),
      ),
    );
  }

  Widget _widgetProfilePickButton({BuildContext? mainContext}) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(0, 24, 0, 0),
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
                    _blocProfileSetUp!.onChangeProfilePic(value: file);
                  }
                },
              );
            },
          );
        },
        child: Stack(
          children: <Widget>[
            if (_selecteProfile == null)
              CircleButton(
                iconName: ImgConstants.camera,
                backgroundColor: _config!.borderColor,
                buttonSize: 120,
                iconColor: _config!.whiteColor,
                iconSize: 48,
                //onPressed: () {},
              )
            else if (_selecteProfile != null && _selecteProfile is String)
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(120 / 2),
                ),
                child: ClipRRect(
                    borderRadius: BorderRadius.circular(120 / 2),
                    child: CircularImage(
                      _selecteProfile as String,
                      width: 120,
                      height: 120,
                    )),
              )
            else if (_selecteProfile != null && _selecteProfile is File)
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(120 / 2),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(120 / 2),
                  child: Image.file(
                    _selecteProfile as File,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            if (_selecteProfile != null)
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(width: 2, color: _config!.borderColor),
                      color: _config!.greyColor),
                  child: Center(
                    child: SvgIcon.asset(
                      ImgConstants.camera,
                      color: _config!.whiteColor,
                      size: 18,
                    ),
                  ),
                ),
              )
          ],
        ),
      ),
    );
  }

  Widget _widgetOR() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsetsDirectional.fromSTEB(24, 60, 24, 0),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Divider(
              color: _config!.borderColor,
              height: 1,
            ),
          ),
          const SizedBox(
            width: 8,
          ),
          Text(
            AppConstants.or,
            style: _config!.paragraphExtraSmallFontStyle.apply(
              color: _config!.greyColor,
            ),
          ),
          const SizedBox(
            width: 8,
          ),
          Expanded(
            child: Divider(
              color: _config!.borderColor,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _widgetSelecteFromBelowHintText() {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(0, 60, 0, 0),
      child: Text(
        AppConstants.hindSelectFromBelow,
        style: _config!.paragraphExtraSmallFontStyle.apply(
          color: _config!.greyColor,
        ),
      ),
    );
  }

  Widget _listVectorProfile() {
    return FutureBuilder<List<String>>(
      future: FireStoreProvider.instance.getDefaultPlaceHolder(),
      builder: (BuildContext context, AsyncSnapshot<List<String>> snapshot) {
        List<String> _list = <String>[];
        if (snapshot.hasData && snapshot.data != null) {
          _list = snapshot.data!;
        }
        return Container(
          width: double.infinity,
          height: 140,
          padding: const EdgeInsetsDirectional.fromSTEB(0, 24, 0, 20),
          child: ListView.builder(
            padding: const EdgeInsetsDirectional.fromSTEB(24, 0, 24, 0),
            scrollDirection: Axis.horizontal,
            itemCount: _list.length,
            itemBuilder: (BuildContext context, int index) {
              final String fileUrl = _list[index];
              bool isSelectd = false;
              if (_selecteProfile != null && fileUrl == _selecteProfile) {
                isSelectd = true;
              }
              return GestureDetector(
                onTap: () {
                  if (!isSelectd) {
                    _selecteProfile = fileUrl;
                    _blocProfileSetUp!.onChangeProfilePic(value: fileUrl);
                  }
                },
                child: Container(
                  width: 98,
                  height: 98,
                  decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(98 / 2),
                      border: Border.all(
                          color: isSelectd
                              ? _config!.whiteColor
                              : Colors.transparent,
                          width: isSelectd ? 1 : 0)),
                  padding: const EdgeInsetsDirectional.fromSTEB(4, 4, 4, 4),
                  child: fileUrl != null && fileUrl.isNotEmpty
                      ? CircularImage(
                          fileUrl,
                          height: 90,
                          width: 90,
                        )
                      : SpinKitCircle(
                          size: 30,
                          color: _config!.btnPrimaryColor,
                        ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _step5location(BuildContext mainContext) {
    return SingleChildScrollView(
      padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
      child: Container(
        padding: const EdgeInsetsDirectional.fromSTEB(24, 86, 24, 0),
        child: StreamBuilder<ErrorMessage?>(
          stream: _blocProfileSetUp!.getLocationErrorMessage,
          initialData: ErrorMessage(false, ''),
          builder: (BuildContext? context,
              AsyncSnapshot<ErrorMessage?> errorSnapshot) {
            return CustomTextField(
              stackAlignment: Alignment.centerRight,
              context: context,
              controller: _txtController,
              focussNode: _focusNode,
              showFlotingHint: true,
              floatingLabelBehavior: FloatingLabelBehavior.auto,
              lableText: AppConstants.hintLocation,
              //hindText: AppConstants.hintFullName,
              inputType: TextInputType.text,
              capitalization: TextCapitalization.sentences,
              inputAction: TextInputAction.go,
              enableSuggestions: true,
              isAutocorrect: true,
              maxlength: 255,
              padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
              contentPadding: const EdgeInsetsDirectional.fromSTEB(0, 0, 20, 0),
              sufixWidget: _widgetLocationPin(mainContext),
              onchange: (String value) {
                _blocProfileSetUp!.onChangeLocation(value: value);
              },
              onSubmit: (String value) {
                _focusNode!.unfocus();
              },
              errorText: errorSnapshot.data!.errorMessage.isEmpty
                  ? null
                  : errorSnapshot.data!.errorMessage,
            );
          },
        ),
      ),
    );
  }

  Widget _widgetLocationPin(BuildContext mainContext) {
    return ValueListenableBuilder<bool>(
      valueListenable: _notifierIsFetchingLocation!,
      builder: (BuildContext? context, bool? isFetching, Widget? child) {
        return TextButton(
          onPressed: () {
            if (currentLocation != null) {
              getAddress();
            } else {
              if (!isFetching!) {
                _notifierIsFetchingLocation!.value = true;
                _checkForLocationPemission(mainContext);
              }
            }
          },
          style: TextButton.styleFrom(
            padding: const EdgeInsets.all(0),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            minimumSize: const Size(20, 20),
          ),
          child: Container(
            child: isFetching!
                ? SpinKitCircle(
                    color: _config!.btnPrimaryColor,
                    size: 20,
                    // size: loaderWidth ,
                  )
                : SvgIcon.asset(
                    ImgConstants.locationPin,
                    color: _config!.greyColor,
                  ),
          ),
        );
      },
    );
  }

  Future<void> _checkForLocationPemission(BuildContext mainContext) async {
    bool serviceEnabled;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (serviceEnabled) {
      final PermissionStatus status = await Permission.location.request();

      if (status.isGranted) {
        _getCurrentLocation();
      } else {
        showLocationServiceError(
            mainContext,
            AppConstants.locationPermissionTitle,
            AppConstants.locationPermissionMessage);
      }
    } else {
      showLocationServiceError(
        mainContext,
        AppConstants.locationServiceTitle,
        AppConstants.locationServiceMessage,
      );
    }
  }

  Future<void> _getCurrentLocation() async {
    if (currentLocation == null) {
      try {
        currentLocation = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
        addressCoordinates = Coordinates(
            latitude: currentLocation!.latitude,
            longitude: currentLocation!.longitude);
        getAddress();
      } on Exception catch (_) {}
    }
  }

  Future<void> getAddress() async {
    if (_currentSetupStep == 2) {
      GeoCode geoCode = GeoCode();
      Address addresses = await geoCode.reverseGeocoding(
          latitude: currentLocation!.latitude,
          longitude: currentLocation!.longitude);
      // final List<Address> addresses =
      //     await Geocoder.local.findAddressesFromCoordinates(addressCoordinates);

      // final List<Address> addresses = await Geocoder.google('AIzaSyBdF7JF47NdfJq3lWrohOun9eXWYlqsgLI')
      //     .findAddressesFromCoordinates(addressCoordinates);
      if (addresses != null) {
        final Address addressLine2 = addresses;
        // final String addressLine2 = address.toString();
        print('GET Current Location === $addressLine2');
        _txtController!.text =
            '${addressLine2.streetAddress}, ${addressLine2.city}, ${addressLine2.countryName}';
        _blocProfileSetUp!
            .onChangeLocation(value: addressLine2.streetAddress ?? '');
        _notifierIsFetchingLocation!.value = false;
      }
    }
  }

  void showLocationServiceError(
      BuildContext mainContext, String title, String message) {
    const Size size = Size(149, 169);
    const CustomAlertDialog().showErrorMessage(
        context: mainContext,
        tital: title,
        message: message,
        buttonTitle: AppConstants.appSetting,
        errorIcon: AspectRatio(
          aspectRatio: size.aspectRatio,
          child: SvgPictureRecolor.asset(
            ImgConstants.camera,
            width: double.infinity,
            height: double.infinity,
            boxfix: BoxFit.fill,
          ),
        ),
        onPress: () {
          openAppSettings();
        });
  }

  Widget _step6Height(BuildContext mainContext) {
    return FutureBuilder<int?>(
        future: HealthProvider.instance.getHeight(),
        builder: (BuildContext context, AsyncSnapshot<int?> snapshot) {
          if (snapshot.hasData && snapshot.data != null) {
            if (_selectedHeightType == 'ft') {
              // const double inch_in_cm = 2.54;

              // int numInches = (snapshot.data!.toDouble() / inch_in_cm).toInt();
              // int feet = (numInches / 12).toInt();
              // int inches = numInches % 12;
              // _selectedHeight = '$feet\'$inches\'\'';
            }
            // _selectedHeight = snapshot.data.toString();
          }
          return SingleChildScrollView(
            padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
            child: Container(
              padding: const EdgeInsetsDirectional.fromSTEB(24, 86, 24, 0),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.zero,
                      width: double.infinity,
                      height: 48,
                      child: StreamBuilder<ErrorMessage?>(
                        stream: _blocProfileSetUp!.getHeightErrorMessage,
                        initialData: ErrorMessage(false, ''),
                        builder: (BuildContext? context,
                            AsyncSnapshot<ErrorMessage?> snapshot) {
                          return CustomTextField(
                            stackAlignment: Alignment.centerRight,
                            context: context,
                            controller: _txtController,
                            focussNode: _focusNode,
                            showFlotingHint: true,
                            floatingLabelBehavior: FloatingLabelBehavior.auto,
                            lableText: AppConstants.hintHeight,
                            //hindText: AppConstants.hintFullName,
                            inputType: TextInputType.text,
                            capitalization: TextCapitalization.sentences,
                            inputAction: TextInputAction.go,
                            enableSuggestions: true,
                            isAutocorrect: true,
                            maxlength: 255,
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                0, 0, 0, 0),
                            contentPadding:
                                const EdgeInsetsDirectional.fromSTEB(
                                    0, 0, 20, 0),
                            // sufixWidget: _widgetDownArrow(),
                            onchange: (String value) {
                              _selectedHeight = value;
                              _blocProfileSetUp!
                                  .onChangeHeight(value: _txtController?.text);
                            },
                            onSubmit: (String value) {
                              _focusNode!.unfocus();
                            },
                            errorText: snapshot.data!.errorMessage.isEmpty
                                ? null
                                : snapshot.data!.errorMessage,
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 24,
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        showModalBottomSheet(
                            context: context,
                            builder: (BuildContext builder) {
                              final List<String> heightType = <String>[
                                'CM',
                                'ft'
                              ];

                              return DatePicker(
                                selectedIndex:
                                    heightType.indexOf(_selectedHeightType!),
                                onDone: (int value) {
                                  final String selectedType = heightType[value];
                                  _selectedHeightType = selectedType;
                                  _txtTypeController!.clear();
                                  _txtTypeController!.text = selectedType;
                                  _blocProfileSetUp!.onChangeHeightType(
                                      value: _txtTypeController!.text);

                                  _txtController!.clear();
                                  // if (_selectedHeightType == 'CM') {
                                  //   _selectedHeight = '168';
                                  // } else {
                                  //   _selectedHeight = '5\'6\'\'';
                                  // }

                                  _txtController!.text =
                                      _selectedHeight.toString();
                                  _blocProfileSetUp!
                                      .onChangeHeight(value: _selectedHeight);
                                },
                                items: heightType,
                              );
                            });
                      },
                      child: Container(
                        padding: EdgeInsets.zero,
                        width: double.infinity,
                        height: 48,
                        child: StreamBuilder<ErrorMessage?>(
                          stream: _blocProfileSetUp!.getHeightTypeErrorMessage,
                          initialData: ErrorMessage(false, ''),
                          builder: (BuildContext? context,
                              AsyncSnapshot<ErrorMessage?> snapshot) {
                            return CustomTextField(
                              stackAlignment: Alignment.centerRight,
                              context: context,
                              controller: _txtTypeController,
                              focussNode: _typeFocusNode,
                              lableText: AppConstants.hintHeight,
                              inputType: TextInputType.text,
                              capitalization: TextCapitalization.none,
                              inputAction: TextInputAction.next,
                              maxlength: 5,
                              sufixWidget: _widgetDownArrow(),
                              isEnable: false,
                              padding: const EdgeInsetsDirectional.fromSTEB(
                                  0, 0, 0, 0),
                              onchange: (String value) {
                                // _blocLogin.onChangeCountryCodeValidation(
                                //     value: value, isShowError: false);
                              },
                              errorText: snapshot.data!.errorMessage.isEmpty
                                  ? null
                                  : snapshot.data!.errorMessage,
                            );
                          },
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          );
        });
  }

  Widget _widgetDownArrow() {
    return Container(
      height: 48,
      width: 10,
      padding: const EdgeInsetsDirectional.fromSTEB(0, 10, 0, 0),
      child: SvgPicture.asset(
        ImgConstants.downArrow,
        color: _config!.whiteColor,
        //width: 8,
        //height: 4,
      ),
    );
  }

  Widget _step7Weight(BuildContext mainContext) {
    return FutureBuilder<double?>(
        future: HealthProvider.instance.getWeight(),
        builder: (BuildContext context, AsyncSnapshot<double?> snapshot) {
          if (snapshot.hasData && snapshot.data != null) {
            // _selectedWeight = snapshot.data;
          }
          return SingleChildScrollView(
            padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
            child: Container(
              padding: const EdgeInsetsDirectional.fromSTEB(24, 86, 24, 0),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.zero,
                      width: double.infinity,
                      height: 48,
                      child: StreamBuilder<ErrorMessage?>(
                        stream: _blocProfileSetUp!.getHeightErrorMessage,
                        initialData: ErrorMessage(false, ''),
                        builder: (BuildContext? context,
                            AsyncSnapshot<ErrorMessage?> snapshot) {
                          return CustomTextField(
                            stackAlignment: Alignment.centerRight,
                            context: context,
                            controller: _txtController,
                            focussNode: _focusNode,
                            showFlotingHint: true,
                            floatingLabelBehavior: FloatingLabelBehavior.auto,
                            lableText: AppConstants.hintWeight,
                            //hindText: AppConstants.hintFullName,
                            inputType: TextInputType.text,
                            capitalization: TextCapitalization.sentences,
                            inputAction: TextInputAction.go,
                            enableSuggestions: true,
                            isAutocorrect: true,
                            maxlength: 255,
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                0, 0, 0, 0),
                            contentPadding:
                                const EdgeInsetsDirectional.fromSTEB(
                                    0, 0, 20, 0),
                            // sufixWidget: _widgetDownArrow(),
                            onchange: (String value) {
                              print('object');
                              _selectedWeight = double.parse(value);
                              _blocProfileSetUp!
                                  .onChangeWeight(value: _selectedWeight);
                            },
                            onSubmit: (String value) {
                              _focusNode!.unfocus();
                            },
                            errorText: snapshot.data!.errorMessage.isEmpty
                                ? null
                                : snapshot.data!.errorMessage,
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 24,
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        showModalBottomSheet(
                            context: context,
                            builder: (BuildContext builder) {
                              final List<String> weightType = <String>[
                                'kg',
                                'pound'
                              ];

                              return DatePicker(
                                selectedIndex:
                                    weightType.indexOf(_selectedWeightType!),
                                onDone: (int value) {
                                  final String selectedType = weightType[value];
                                  _selectedWeightType = selectedType;
                                  _txtTypeController!.clear();
                                  _txtTypeController!.text = selectedType;
                                  _blocProfileSetUp!.onChangeWeightType(
                                      value: _txtTypeController!.text);

                                  _txtController!.clear();
                                  // if (_selectedWeightType == 'kg') {
                                  //   _selectedWeight = 65.0;
                                  // } else {
                                  //   _selectedWeight = 22.0;
                                  // }

                                  _txtController!.text =
                                      _selectedWeight.toString();
                                  _blocProfileSetUp!
                                      .onChangeWeight(value: _selectedWeight);
                                },
                                items: weightType,
                              );
                            });
                      },
                      child: Container(
                        padding: EdgeInsets.zero,
                        width: double.infinity,
                        height: 48,
                        child: StreamBuilder<ErrorMessage?>(
                          stream: _blocProfileSetUp!.getWeightTypeErrorMessage,
                          initialData: ErrorMessage(false, ''),
                          builder: (BuildContext? context,
                              AsyncSnapshot<ErrorMessage?> snapshot) {
                            return CustomTextField(
                              stackAlignment: Alignment.centerRight,
                              context: context,
                              controller: _txtTypeController,
                              focussNode: _typeFocusNode,
                              lableText: AppConstants.hintWeight,
                              inputType: TextInputType.text,
                              capitalization: TextCapitalization.none,
                              inputAction: TextInputAction.go,
                              maxlength: 5,
                              sufixWidget: _widgetDownArrow(),
                              isEnable: false,
                              padding: const EdgeInsetsDirectional.fromSTEB(
                                  0, 0, 0, 0),
                              onchange: (String value) {
                                // _blocLogin.onChangeCountryCodeValidation(
                                //     value: value, isShowError: false);
                              },
                              errorText: snapshot.data!.errorMessage.isEmpty
                                  ? null
                                  : snapshot.data!.errorMessage,
                            );
                          },
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          );
        });
  }

  Widget _step8Birthday(BuildContext mainContext) {
    return SingleChildScrollView(
      padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
      child: Container(
        padding: const EdgeInsetsDirectional.fromSTEB(24, 86, 24, 0),
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();

            showModalBottomSheet(
                context: mainContext,
                builder: (BuildContext builder) {
                  final DateTime current = DateTime.now();
                  final DateTime dateOf16Year =
                      DateTime(current.year - 10, current.month, current.day);

                  return DatePickerDateMode(
                    intialdate:
                        dateOf16Year.subtract(const Duration(minutes: 1)),
                    //minmumDate: DateTime(1958),
                    maximumDate: dateOf16Year,
                    //max: DateTime.now(),
                    onDone: (DateTime date) {
                      final DateTime selectedDate = date;
                      if (selectedDate != null) {
                        _selectedDob = selectedDate;
                        _txtController!.clear();
                        _txtController!.text = _selectedDob!.dateTimeString();
                        _blocProfileSetUp!
                            .onChangeBirthday(value: _txtController!.text);
                      }
                    },
                  );
                });
          },
          child: Container(
            padding: EdgeInsets.zero,
            width: double.infinity,
            child: StreamBuilder<ErrorMessage?>(
              stream: _blocProfileSetUp!.getBirthdayErrorMessage,
              initialData: ErrorMessage(false, ''),
              builder: (BuildContext? context,
                  AsyncSnapshot<ErrorMessage?> snapshot) {
                return CustomTextField(
                  stackAlignment: Alignment.centerRight,
                  context: context,
                  controller: _txtController,
                  focussNode: _focusNode,
                  showFlotingHint: true,
                  isEnable: false,
                  floatingLabelBehavior: FloatingLabelBehavior.auto,
                  lableText: AppConstants.hintDateOfBirth,
                  //hindText: AppConstants.hintFullName,
                  inputType: TextInputType.text,
                  capitalization: TextCapitalization.sentences,
                  inputAction: TextInputAction.go,
                  enableSuggestions: true,
                  isAutocorrect: true,
                  maxlength: 255,
                  padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                  sufixWidget: _widgetDownArrow(),
                  onchange: (String value) {
                    //_blocProfileSetUp.onChangeWeight(value: value);
                  },
                  onSubmit: (String value) {
                    _focusNode!.unfocus();
                  },
                  errorText: snapshot.data!.errorMessage.isEmpty
                      ? null
                      : snapshot.data!.errorMessage,
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _step9ActivityLevel() {
    return Column(
      children: <Widget>[_widgetActivityType(), _widgetActivityLevelSlider()],
    );
  }

  Widget _widgetActivityType() {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(0, 16, 0, 0),
      child: Align(
        alignment: Alignment.topCenter,
        child: RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            text: AppConstants.activityLevelMin,
            style: _config!.paragraphNormalFontStyle.apply(
              color: _config!.whiteColor,
            ),
            children: <TextSpan>[
              TextSpan(
                text: AppConstants.activityLevelMsg1,
                style: _config!.paragraphNormalFontStyle.apply(
                  color: _config!.greyColor,
                ),
              ),
              TextSpan(
                text: AppConstants.activityLevelMix,
                style: _config!.paragraphNormalFontStyle.apply(
                  color: _config!.whiteColor,
                ),
              ),
              TextSpan(
                text: AppConstants.activityLevelMsg2,
                style: _config!.paragraphNormalFontStyle.apply(
                  color: _config!.greyColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _widgetActivityLevelSlider() {
    return Container(
      padding: const EdgeInsetsDirectional.fromSTEB(24, 185, 25, 0),
      child: StreamBuilder<int?>(
        stream: _blocProfileSetUp!.getActivityLevel,
        initialData: _selectedActivityLevel,
        builder: (BuildContext? context, AsyncSnapshot<int?> snapshot) {
          if (snapshot.hasData && snapshot.data != null) {
            _selectedActivityLevel = snapshot.data;
          }
          return SfSlider(
            max: 5.0,
            value: _selectedActivityLevel!.toDouble(),
            interval: 1,
            showLabels: true,
            activeColor: _config!.btnPrimaryColor,
            inactiveColor: _config!.borderColor,
            onChanged: (dynamic value) {
              final double newValue = value as double;
              _blocProfileSetUp!.onChangeActivityLevel(value: newValue.round());
            },
          );
        },
      ),
    );
  }

  Widget _step10DailyActivityGoal() {
    return Column(
      children: <Widget>[
        _widgetActivityGoalTitle(),
        _widgetActivityGoalSlider()
      ],
    );
  }

  Widget _widgetActivityGoalTitle() {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(0, 16, 0, 0),
      child: Align(
        alignment: Alignment.topCenter,
        child: Text(
          AppConstants.dailyGoalMsg,
          style: _config!.paragraphNormalFontStyle.apply(
            color: _config!.greyColor,
          ),
        ),
      ),
    );
  }

  Widget _widgetActivityGoalSlider() {
    return Container(
      padding: const EdgeInsetsDirectional.fromSTEB(24, 185, 25, 0),
      child: StreamBuilder<int?>(
        stream: _blocProfileSetUp!.getActivityGoal,
        initialData: _selectedDailyGoal,
        builder: (BuildContext? context, AsyncSnapshot<int?> snapshot) {
          if (snapshot.hasData && snapshot.data != null) {
            _selectedDailyGoal = snapshot.data;
          }
          return SfSlider(
            min: 1.0,
            max: 7.0,
            value: _selectedDailyGoal!.toDouble(),
            interval: 1,
            showLabels: true,
            activeColor: _config!.btnPrimaryColor,
            inactiveColor: _config!.borderColor,
            onChanged: (dynamic value) {
              final double newValue = value as double;
              _blocProfileSetUp!.onChangeActivityGoal(value: newValue.round());
            },
          );
        },
      ),
    );
  }

  Widget _stepGender() {
    return Column(
      children: <Widget>[
        _widgetGenderPicker(),
      ],
    );
  }

  Widget _widgetGenderPicker() {
    return Container(
      padding: const EdgeInsetsDirectional.fromSTEB(24, 86, 24, 0),
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();

          showModalBottomSheet(
              context: context,
              builder: (BuildContext builder) {
                final List<String> genderList = [AppConstants.female, AppConstants.male];
                return DatePicker(
                  selectedIndex: genderList.indexOf(_selectedGender.toString()),
                  onDone: (int value) {
                    final String selected = genderList[value];
                    _selectedGender = selected;
                    _txtController!.clear();
                    _txtController!.text = _selectedGender ?? AppConstants.female;
                    _blocProfileSetUp!
                        .onChangeGender(value: _txtController!.text);
                  },
                  items: genderList,
                );
              });
        },
        child: Container(
          padding: EdgeInsets.zero,
          width: double.infinity,
          child: StreamBuilder<ErrorMessage?>(
            stream: _blocProfileSetUp!.getGenderErrorMessage,
            initialData: ErrorMessage(false, ''),
            builder:
                (BuildContext? context, AsyncSnapshot<ErrorMessage?> snapshot) {
              return CustomTextField(
                stackAlignment: Alignment.centerRight,
                context: context,
                controller: _txtController,
                focussNode: _focusNode,
                showFlotingHint: true,
                isEnable: false,
                floatingLabelBehavior: FloatingLabelBehavior.auto,
                lableText: AppConstants.sex.toUpperCase(),
                //hindText: AppConstants.hintFullName,
                inputType: TextInputType.text,
                capitalization: TextCapitalization.sentences,
                inputAction: TextInputAction.go,
                enableSuggestions: true,
                isAutocorrect: true,
                maxlength: 255,
                padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                sufixWidget: _widgetDownArrow(),
                onchange: (String value) {
                  //_blocProfileSetUp.onChangeWeight(value: value);
                },
                onSubmit: (String value) {
                  _focusNode!.unfocus();
                },
                errorText: snapshot.data!.errorMessage.isEmpty
                    ? null
                    : snapshot.data!.errorMessage,
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _step11CalorieGoal() {
    return Column(
      children: <Widget>[
        _widgetCalorieGoalTitle(),
        _widgetCalorieBurnPicker(),
      ],
    );
  }

  Widget _widgetCalorieGoalTitle() {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(32, 16, 32, 0),
      child: Align(
        alignment: Alignment.topCenter,
        child: Text(
          AppConstants.calorieGoalMsg,
          style: _config!.paragraphNormalFontStyle.apply(
            color: _config!.greyColor,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _widgetCalorieBurnPicker() {
    return Container(
      padding: const EdgeInsetsDirectional.fromSTEB(24, 86, 24, 0),
      child: Container(
        padding: EdgeInsets.zero,
        width: double.infinity,
        child: StreamBuilder<ErrorMessage?>(
          stream: _blocProfileSetUp!.getBirthdayErrorMessage,
          initialData: ErrorMessage(false, ''),
          builder:
              (BuildContext? context, AsyncSnapshot<ErrorMessage?> snapshot) {
            return CustomTextField(
              stackAlignment: Alignment.centerRight,
              context: context,
              controller: _txtController,
              focussNode: _focusNode,
              showFlotingHint: true,
              isEnable: true,
              floatingLabelBehavior: FloatingLabelBehavior.auto,
              lableText: AppConstants.hintCalories.toUpperCase(),
              //hindText: AppConstants.hintFullName,
              inputType: TextInputType.text,
              capitalization: TextCapitalization.sentences,
              inputAction: TextInputAction.go,
              enableSuggestions: true,
              isAutocorrect: true,
              maxlength: 255,
              padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
              // sufixWidget: _widgetDownArrow(),
              onchange: (String value) {
                final String selected = value;
                _selectedCaloriesTOBurn = int.tryParse(selected);
              },
              onSubmit: (String value) {
                _focusNode!.unfocus();
              },
              errorText: snapshot.data!.errorMessage.isEmpty
                  ? null
                  : snapshot.data!.errorMessage,
            );
          },
        ),
      ),
    );
  }

  Widget _step12MinutesGoal() {
    return Column(
      children: <Widget>[
        _widgetMinutesTitle(),
        _widgetMinutesPicker(),
      ],
    );
  }

  Widget _widgetMinutesTitle() {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(24, 16, 24, 0),
      child: Align(
        alignment: Alignment.topCenter,
        child: Text(
          AppConstants.minutesGoalMsg,
          style: _config!.paragraphNormalFontStyle.apply(
            color: _config!.greyColor,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _widgetMinutesPicker() {
    return Container(
      padding: const EdgeInsetsDirectional.fromSTEB(24, 86, 24, 0),
      child: Container(
        padding: EdgeInsets.zero,
        width: double.infinity,
        child: StreamBuilder<ErrorMessage?>(
          stream: _blocProfileSetUp!.getBirthdayErrorMessage,
          initialData: ErrorMessage(false, ''),
          builder:
              (BuildContext? context, AsyncSnapshot<ErrorMessage?> snapshot) {
            return CustomTextField(
              stackAlignment: Alignment.centerRight,
              context: context,
              controller: _txtController,
              focussNode: _focusNode,
              showFlotingHint: true,
              floatingLabelBehavior: FloatingLabelBehavior.auto,
              lableText: AppConstants.hintMinutes.toUpperCase(),
              //hindText: AppConstants.hintFullName,
              inputType: TextInputType.text,
              capitalization: TextCapitalization.sentences,
              inputAction: TextInputAction.go,
              enableSuggestions: true,
              isAutocorrect: true,
              maxlength: 255,
              padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
              // sufixWidget: _widgetDownArrow(),
              onchange: (String value) {
                final String selected = value;
                _selectedMinutes = int.tryParse(selected);
              },
              onSubmit: (String value) {
                _focusNode!.unfocus();
              },
              errorText: snapshot.data!.errorMessage.isEmpty
                  ? null
                  : snapshot.data!.errorMessage,
            );
          },
        ),
      ),
    );
  }

  Widget _step13EnergyGenerate() {
    return Column(
      children: <Widget>[
        _widgetEnergyGenerateTitle(),
        _widgetEnergyGeneratePicker(),
      ],
    );
  }

  Widget _widgetEnergyGenerateTitle() {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(24, 16, 24, 0),
      child: Align(
        alignment: Alignment.topCenter,
        child: Text(
          AppConstants.energyGoalMsg,
          style: _config!.paragraphNormalFontStyle.apply(
            color: _config!.greyColor,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _widgetEnergyGeneratePicker() {
    return Container(
      padding: const EdgeInsetsDirectional.fromSTEB(24, 86, 24, 0),
      child: Container(
        padding: EdgeInsets.zero,
        width: double.infinity,
        child: StreamBuilder<ErrorMessage?>(
          stream: _blocProfileSetUp!.getEnergyEngGoalErrorMessage,
          initialData: ErrorMessage(false, ''),
          builder:
              (BuildContext? context, AsyncSnapshot<ErrorMessage?> snapshot) {
            return CustomTextField(
              stackAlignment: Alignment.centerRight,
              context: context,
              controller: _txtController,
              focussNode: _focusNode,
              showFlotingHint: true,
              floatingLabelBehavior: FloatingLabelBehavior.auto,
              lableText: AppConstants.hintEnergyGenerate.toUpperCase(),
              inputType: TextInputType.text,
              inputAction: TextInputAction.go,
              enableSuggestions: false,
              isAutocorrect: false,
              maxlength: 255,
              padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
              // sufixWidget: _widgetDownArrow(),
              onchange: (String value) {
                final String selected = value;
                _selectedEnergyGenerate = int.tryParse(selected);
              },
              onSubmit: (String value) {
                _focusNode!.unfocus();
              },
              errorText: snapshot.data!.errorMessage.isEmpty
                  ? null
                  : snapshot.data!.errorMessage,
            );
          },
        ),
      ),
    );
  }

  Widget _step14SetFTP() {
    return Column(
      children: [
        _widgetTypeFTP(),
        _widgetorSelect(),
        _widgetTabBar(),
        const SizedBox(height: 50),
        _widgetDescription()
      ],
    );
  }

  Widget _widgetTypeFTP() {
    return Container(
      padding: const EdgeInsetsDirectional.fromSTEB(24, 86, 24, 0),
      child: StreamBuilder<ErrorMessage?>(
        stream: _blocProfileSetUp!.getUserNameErrorMessage,
        initialData: ErrorMessage(false, ''),
        builder:
            (BuildContext? context, AsyncSnapshot<ErrorMessage?> snapshot) {
          return CustomTextField(
            stackAlignment: Alignment.centerRight,
            context: context,
            controller: _txtController,
            focussNode: _focusNode,
            showFlotingHint: true,
            //isEnable: userName.isEmpty,
            floatingLabelBehavior: FloatingLabelBehavior.auto,
            lableText: AppConstants.hintFTP,
            //hindText: AppConstants.hintFullName,
            inputType: TextInputType.number,
            capitalization: TextCapitalization.none,
            inputAction: TextInputAction.go,
            enableSuggestions: true,
            isAutocorrect: true,
            maxlength: 50,
            padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
            onchange: (String value) {
              _selectedFTP = int.parse(value);
            },
            onSubmit: (String value) {
              _focusNode!.unfocus();
            },
            errorText: snapshot.data!.errorMessage.isEmpty
                ? null
                : snapshot.data!.errorMessage,
          );
        },
      ),
    );
  }

  Widget _widgetorSelect() {
    return Padding(
      padding: const EdgeInsets.only(top: 25, bottom: 15, left: 24, right: 24),
      child: Container(
        width: double.infinity,
        child: Text(AppConstants.orSelectFTP,
            textAlign: TextAlign.left,
            style: _config!.paragraphNormalFontStyle
                .apply(color: _config!.greyColor)),
      ),
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
        labelStyle: _config!.calibriHeading5FontStyle,
        unselectedLabelColor: _config!.greyColor,
        unselectedLabelStyle: _config!.calibriHeading5FontStyle,
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _config!.lightBorderColor,
          ),
          color: _config!.darkGreyColor,
        ),
        tabs: <Tab>[
          Tab(
            text: AppConstants.beginnerFTP,
          ),
          Tab(
            text: AppConstants.mediumFTP,
          ),
          Tab(
            text: AppConstants.athleteFTP,
          ),
        ],
        onTap: (index) async {
          print(index);
          if (index == 0) {
            _selectedFTP = int.parse('100');
          } else if (index == 1) {
            _selectedFTP = int.parse('200');
          } else if (index == 2) {
            _selectedFTP = int.parse('250');
          }
          _txtController!.text = _selectedFTP.toString();
          _blocProfileSetUp!.onChangeFTP(value: _txtController!.text);
        },
      ),
    );
  }

  Widget _widgetDescription() {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(32, 16, 32, 0),
      child: Align(
        alignment: Alignment.topCenter,
        child: Text(
          AppConstants.ftpDescription,
          style: _config!.paragraphNormalFontStyle.apply(
            color: _config!.greyColor,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
// ************ END SCREENS ***************

  Widget _btnNext() {
    final double bottom =
        MediaQuery.of(context).viewInsets.bottom == 0 ? 20 : 60;
    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, bottom),
      child: StreamBuilder<bool?>(
          stream: _blocProfileSetUp!.getFormValid,
          builder: (BuildContext? context, AsyncSnapshot<bool?> snapshot) {
            bool isValid = false;
            if (snapshot.hasData && snapshot.data != null) {
              isValid = snapshot.data!;
            }
            return StreamBuilder<bool>(
                stream: aGeneralBloc.getIsApiCalling,
                builder: (BuildContext context,
                    AsyncSnapshot<bool> apiCallingSnapshot) {
                  bool isLoading = false;
                  if (apiCallingSnapshot.hasData &&
                      apiCallingSnapshot.data != null) {
                    isLoading = apiCallingSnapshot.data!;
                  }
                  return LoaderButton(
                      backgroundColor: _config!.btnPrimaryColor,
                      isEnabled: isValid,
                      isLoading: isLoading,
                      padding:
                          const EdgeInsetsDirectional.fromSTEB(24, 0, 24, 0),
                      onPressed: () async {
                        FocusScope.of(context).unfocus();
                        aGeneralBloc.updateAPICalling(true);
                        // late String? email =
                        //     _profileData![UserCollectionField.email] as String;
                        // late String? userName =
                        //     _profileData![UserCollectionField.username]
                        //         as String;
                        // if (_currentSetupStep == 1) {
                        //   FireStoreProvider.instance
                        //       .isEmailExists(email: _txtController!.text)
                        //       .then(
                        //     (bool isEmailExists) {
                        //       if (isEmailExists) {
                        //         aGeneralBloc.updateAPICalling(false);

                        //         _blocProfileSetUp!.showErrorEmailExists(
                        //             isEmailExists: isEmailExists,
                        //             value: _txtController!.text,
                        //             isShowError: true);
                        //       } else {
                        //         _updateDataForStep();
                        //       }
                        //     },
                        //   );
                        // } else
                        if (_currentSetupStep == 0) {
                          FireStoreProvider.instance
                              .isUserNameExists(userName: _txtController!.text)
                              .then(
                            (bool isUserNameExists) {
                              if (isUserNameExists) {
                                aGeneralBloc.updateAPICalling(false);

                                _blocProfileSetUp!.showErrorUserNotExists(
                                    isUserExists: isUserNameExists,
                                    value: _txtController!.text,
                                    isShowError: true);
                              } else {
                                _updateDataForStep();
                              }
                            },
                          );
                        } else {
                          _updateDataForStep();
                        }
                      },
                      title: AppConstants.next);
                });
          }),
    );
  }

  Future<void> _updateDataForStep() async {
    final Map<String, dynamic> _neetToStoreData = <String, dynamic>{};

    switch (_currentSetupStep) {
      case -1:
        _profileData![UserCollectionField.fullName] = _txtController!.text;
        _neetToStoreData[UserCollectionField.fullName] = _txtController!.text;
        break;
      case -2:
        _profileData![UserCollectionField.email] = _txtController!.text;
        _neetToStoreData[UserCollectionField.email] = _txtController!.text;
        break;
      case 0:
        _profileData![UserCollectionField.username] = _txtController!.text;
        _neetToStoreData[UserCollectionField.username] = _txtController!.text;
        break;
      case 1:
        if (_selecteProfile is String) {
          _profileData![UserCollectionField.profilePhoto] = _selecteProfile;
          _neetToStoreData[UserCollectionField.profilePhoto] = _selecteProfile;
        }
        break;
      case 2:
        _profileData![UserCollectionField.address] = _txtController!.text;
        _profileData![UserCollectionField.latLong] =
            addressCoordinates.toString();
        _neetToStoreData[UserCollectionField.address] = _txtController!.text;
        _neetToStoreData[UserCollectionField.latLong] =
            addressCoordinates.toString();
        break;
      case 3:
        _profileData![UserCollectionField.height] = _selectedHeight;
        _profileData![UserCollectionField.heightType] =
            _txtTypeController!.text;
        _neetToStoreData[UserCollectionField.height] = _selectedHeight;
        _neetToStoreData[UserCollectionField.heightType] =
            _txtTypeController!.text;

        break;
      case 4:
        _profileData![UserCollectionField.wight] = _selectedWeight;
        _profileData![UserCollectionField.wightType] = _txtTypeController!.text;
        _neetToStoreData[UserCollectionField.wight] = _selectedWeight;
        _neetToStoreData[UserCollectionField.wightType] = _selectedWeightType;
        break;
      case 5:
        if (_selectedDob != null) {
          _profileData![UserCollectionField.birthDate] =
              _selectedDob?.toIso8601String();
          _neetToStoreData[UserCollectionField.birthDate] =
              _selectedDob!.toIso8601String();
        }

        break;
      case 6:
        if (_selectedGender != null) {
          _profileData![UserCollectionField.gender] = _selectedGender;
          _neetToStoreData[UserCollectionField.gender] = _selectedGender;
        }

        break;
      case 7:
        _profileData![UserCollectionField.activityLevel] =
            _selectedActivityLevel;
        _neetToStoreData[UserCollectionField.activityLevel] =
            _selectedActivityLevel;
        break;
      case 8:
        _profileData![UserCollectionField.activityGoal] = _selectedDailyGoal;
        _neetToStoreData[UserCollectionField.activityGoal] = _selectedDailyGoal;
        break;
      case 9:
        _profileData![UserCollectionField.calorieGoal] =
            _selectedCaloriesTOBurn;
        _neetToStoreData[UserCollectionField.calorieGoal] =
            _selectedCaloriesTOBurn;
        break;
      case 10:
        _profileData![UserCollectionField.activeMinuteGoal] = _selectedMinutes;
        _neetToStoreData[UserCollectionField.activeMinuteGoal] =
            _selectedMinutes;
        break;
      case 11:
        _profileData![UserCollectionField.energyGenerateGoal] =
            _selectedEnergyGenerate;
        _neetToStoreData[UserCollectionField.energyGenerateGoal] =
            _selectedEnergyGenerate;
        break;
      case 12:
        _profileData![UserCollectionField.ftpValue] = _selectedFTP;
        _neetToStoreData[UserCollectionField.ftpValue] = _selectedFTP;
        _neetToStoreData[UserCollectionField.isActive] = true;
        break;
      default:
        break;
    }

    _profileData![UserCollectionField.currStep] = _currentSetupStep;
    _neetToStoreData[UserCollectionField.currStep] = _currentSetupStep;

    if (_currentSetupStep == 3 && _selecteProfile is File) {
      final File image = _selecteProfile as File;
      final String fileExtenstion = path.extension(image.path);
      final String fileName = '$_userId$fileExtenstion';

      StorageProvider.instance.uploadFile(
          profilePic: image,
          fileName: fileName,
          onSuccess: (String imageUrl) {
            _profileData![UserCollectionField.profilePhoto] = imageUrl;
            _neetToStoreData[UserCollectionField.profilePhoto] = imageUrl;
            updateUserDataToFireStore(data: _neetToStoreData);
          },
          onError: (String errorMsg) {
            aGeneralBloc.updateAPICalling(false);
          });
    } else {
      updateUserDataToFireStore(data: _neetToStoreData);
    }
  }

  void updateUserDataToFireStore({required Map<String, dynamic>? data}) {
    FireStoreProvider.instance.updateUser(
      userId: _userId!,
      userData: data!,
      onSuccess: (Map<String, dynamic> successResponse) async {
        aGeneralBloc.updateAPICalling(false);
        await sharedPrefsHelper.set(
            SharedPrefskey.currentStep, _currentSetupStep);
        if (_currentSetupStep == (maxStep! - 1)) {
          Navigator.pushNamed(
            context,
            CMS.routeName,
            arguments: CmsArgs(isShowAgreeButton: true, cmsType: CMSType.terms),
          );
        } else {
          _txtController!.text = '';
          _txtTypeController!.text = '';
          print('Befor === $_currentSetupStep');
          _currentSetupStep = _currentSetupStep! + 1;
          print('After === $_currentSetupStep');
          _blocProfileSetUp!.updateSetp(stepValue: _currentSetupStep);
        }
      },
      onError: (Map<String, dynamic> errorResponse) {
        aGeneralBloc.updateAPICalling(false);
      },
    );
  }
}
