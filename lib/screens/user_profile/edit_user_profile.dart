import 'dart:io';

import 'package:energym/app_config.dart';
import 'package:energym/models/error_message_model.dart';
import 'package:energym/models/user_model.dart';
import 'package:energym/reusable_component/circular_image.dart';
import 'package:energym/reusable_component/custom_dialog.dart';
import 'package:energym/reusable_component/custom_scaffold.dart';
import 'package:energym/reusable_component/custom_textfield.dart';
import 'package:energym/reusable_component/date_picker.dart';
import 'package:energym/reusable_component/img_picker.dart';
import 'package:energym/screens/user_profile/edit_user_profile_bloc.dart';
import 'package:energym/utils/common/circle_button.dart';
import 'package:energym/utils/common/config.dart';
import 'package:energym/utils/common/constants.dart';
import 'package:energym/utils/common/main_app_bar.dart';
import 'package:energym/utils/common/svg_icon.dart';
import 'package:energym/utils/common/svg_picture_customise.dart';
import 'package:energym/utils/extensions/extension.dart';
import 'package:energym/utils/helpers/firebase/firestore_provider.dart';
import 'package:energym/utils/helpers/firebase/storage_provider.dart';
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

class EditProfile extends StatefulWidget {
  static const String routeName = '/EditProfile';
  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  AppConfig? _config;
  UserModel? _currentUser;
  dynamic? _selecteProfile;

  String? _selectedHeightType = 'cm';
  String? _selectedHeight = '168';

  String? _selectedWeightType = 'kg';
  double? _selectedWeight = 65.0;
  DateTime? _selectedDob;
  String? _selectedGender = 'Female';
  int? _selectedActivityLevel = 1;
  int? _selectedDailyGoal = 1;
  int? _selectedCaloriesTOBurn = 65;
  int? _selectedMinutes = 65;
  int? _selectedEnergyGenerate = 65;

  Coordinates? addressCoordinates;
  final ValueNotifier<bool> _notifierIsFetchingLocation =
      ValueNotifier<bool>(false);
  final ValueNotifier<bool> _notifierIsSaving = ValueNotifier<bool>(false);

  EditProfileBloc? _blocProfileSetUp;

  TextEditingController? _txtPhoneController;
  FocusNode? _focusNodePhone;

  TextEditingController? _txtEmailController;
  FocusNode? _focusNodeEmail;

  TextEditingController? _txtUserNameController;
  FocusNode? _focusNodeUserName;

  TextEditingController? _txtFullNameController;
  FocusNode? _focusNodeFullName;

  TextEditingController? _txtLocationController;
  FocusNode? _focusNodeLocation;

  TextEditingController? _txtHeightController;
  FocusNode? _focusNodeHeight;

  TextEditingController? _txtHeightTypeController;
  FocusNode? _focusNodeHeightType;

  TextEditingController? _txtWeightController;
  FocusNode? _focusNodeWeight;

  TextEditingController? _txtWeightTypeController;
  FocusNode? _focusNodeWeightType;

  TextEditingController? _txtBirhtdayController;
  FocusNode? _focusNodeBirhtday;

  TextEditingController? _txtGenderController;
  FocusNode? _focusNodeGender;

  TextEditingController? _txtActivityLevelController;
  FocusNode? _focusNodeActivityLevel;

  TextEditingController? _txtActivityGoalController;
  FocusNode? _focusNodeActivityGoal;

  TextEditingController? _txtCalorieGoalController;
  FocusNode? _focusNodeCalorieGoal;

  TextEditingController? _txtMinutesGoalController;
  FocusNode? _focusNodeMinutesGoal;

  TextEditingController? _txtEnergyGenerateGoalController;
  FocusNode? _focusNodeEnergyGenerateGoal;

  bool? isUpdate = false;

  @override
  void initState() {
    super.initState();
    _blocProfileSetUp = EditProfileBloc();
    _txtPhoneController = TextEditingController();
    _focusNodePhone = FocusNode();
    _txtEmailController = TextEditingController();
    _focusNodeEmail = FocusNode();
    _txtUserNameController = TextEditingController();
    _focusNodeUserName = FocusNode();
    _txtFullNameController = TextEditingController();
    _focusNodeFullName = FocusNode();
    _txtLocationController = TextEditingController();
    _focusNodeLocation = FocusNode();
    _txtHeightController = TextEditingController();
    _focusNodeHeight = FocusNode();
    _txtHeightTypeController = TextEditingController();
    _focusNodeHeightType = FocusNode();
    _txtWeightController = TextEditingController();
    _focusNodeWeight = FocusNode();
    _txtWeightTypeController = TextEditingController();
    _focusNodeWeightType = FocusNode();
    _txtBirhtdayController = TextEditingController();
    _focusNodeBirhtday = FocusNode();

    _txtGenderController = TextEditingController();
    _focusNodeGender = FocusNode();
    _txtActivityLevelController = TextEditingController();
    _focusNodeActivityLevel = FocusNode();

    _txtActivityGoalController = TextEditingController();
    _focusNodeActivityGoal = FocusNode();

    _txtCalorieGoalController = TextEditingController();
    _focusNodeCalorieGoal = FocusNode();

    _txtMinutesGoalController = TextEditingController();
    _focusNodeMinutesGoal = FocusNode();

    _txtEnergyGenerateGoalController = TextEditingController();
    _focusNodeEnergyGenerateGoal = FocusNode();
    
    FireStoreProvider.instance.fetchCurrentUser();
  }

  @override
  void dispose() {
    _txtPhoneController!.dispose();
    _focusNodePhone!.dispose();
    _txtEmailController!.dispose();
    _focusNodeEmail!.dispose();
    _txtUserNameController!.dispose();
    _focusNodeUserName!.dispose();
    _txtFullNameController!.dispose();
    _focusNodeFullName!.dispose();
    _txtLocationController!.dispose();
    _focusNodeLocation!.dispose();

    _txtGenderController!.dispose();
    _focusNodeGender!.dispose();

    _txtActivityLevelController!.dispose();
    _focusNodeActivityLevel!.dispose();

    _txtActivityGoalController!.dispose();
    _focusNodeActivityGoal!.dispose();

    _txtCalorieGoalController!.dispose();
    _focusNodeCalorieGoal!.dispose();

    _txtMinutesGoalController!.dispose();
    _focusNodeMinutesGoal!.dispose();

    _txtEnergyGenerateGoalController!.dispose();
    _focusNodeEnergyGenerateGoal!.dispose();

    _blocProfileSetUp!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _config = AppConfig.of(context);
    return CustomScaffold(
      appBar: _getAppBar(),
      body: SafeArea(
        child: _widgetMainContainer(context),
      ),
    );
  }

  PreferredSizeWidget _getAppBar() {
    return getMainAppBar(context, _config!,
        backgoundColor: Colors.transparent,
        textColor: _config!.whiteColor,
        title: AppConstants.myProfile,
        elevation: 0, onBack: () {
      Navigator.pop(context);
    }, actions: <Widget>[
      StreamBuilder<bool>(
          stream: _blocProfileSetUp!.getEditFormValid,
          builder: (BuildContext snapcontext, AsyncSnapshot<bool> snapshot) {
            bool isValid = false;
            if (snapshot.hasData && snapshot.data != null) {
              isValid = snapshot.data!;
            }

            return ValueListenableBuilder<bool>(
              valueListenable: _notifierIsSaving,
              builder: (BuildContext? context, bool? isSaving, Widget? child) {
                return isSaving!
                    ? Container(
                        width: 30,
                        height: 20,
                        padding: EdgeInsets.zero,
                        child: Center(
                          child: SpinKitCircle(
                            color: _config!.btnPrimaryColor,
                            size: 20,
                            // size: loaderWidth ,
                          ),
                        ),
                      )
                    : IconButton(
                        highlightColor: Colors.transparent,
                        splashColor: Colors.transparent,
                        //iconSize: 16,
                        icon: Text(
                          AppConstants.save,
                          style: _config!.linkNormalFontStyle.apply(
                              color: isValid
                                  ? _config!.btnPrimaryColor
                                  : _config!.greyColor),
                        ),
                        //color: color,
                        tooltip: MaterialLocalizations.of(context!)
                            .backButtonTooltip,
                        onPressed: () {
                          if (isValid) {
                            _updateDataForStep();
                          }
                        },
                      );
              },
            );
          })
    ]);
  }

  Widget _widgetMainContainer(BuildContext mainContext) {
    // ignore: always_specify_types
    return StreamBuilder<DocumentSnapshot?>(
      stream: FireStoreProvider.instance.getCurrentUserUpdate,
      builder:
          // ignore: always_specify_types
          (BuildContext context, AsyncSnapshot<DocumentSnapshot?> snapshot) {
        if (snapshot.hasData && snapshot.data != null) {
          _currentUser = UserModel.fromJson(
              snapshot.data!.data() as Map<String, dynamic>,
              doumentId: snapshot.data!.id);

          _fillUserInfo();
        }
        return Container(
          width: double.infinity,
          height: double.infinity,
          padding: const EdgeInsetsDirectional.fromSTEB(0, 16, 0, 16),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _userProfile(mainContext),
                _widgetEmailAddress(),
                // _widgetPhoneNumber(),
                _widgetUserName(),
                _widgetFullName(),
                _widgetLocation(mainContext),
                _widgetHeight(mainContext),
                _widgetWeight(mainContext),
                _widgetBirthday(mainContext),
                _widgetGender(mainContext),
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(0, 24, 0, 0),
                  child: Divider(
                    thickness: 8,
                    color: _config!.borderColor,
                  ),
                ),
                _wdgetActivityLevel(),
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(0, 24, 0, 0),
                  child: Divider(
                    thickness: 8,
                    color: _config!.borderColor,
                  ),
                ),
                _widgetDailyActivityGoal(),
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(0, 24, 0, 0),
                  child: Divider(
                    thickness: 8,
                    color: _config!.borderColor,
                  ),
                ),
                _widgetCalorieGoal(),
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(0, 24, 0, 0),
                  child: Divider(
                    thickness: 8,
                    color: _config!.borderColor,
                  ),
                ),
                _widgetMinutesGoal(),
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(0, 24, 0, 0),
                  child: Divider(
                    thickness: 8,
                    color: _config!.borderColor,
                  ),
                ),
                _widgetEnergyGenerate(),
              ],
            ),
          ),
        );
      },
    );
  }

  void _fillUserInfo() {
    if (_currentUser != null) {
      if (_currentUser!.profilePhoto != null) {
        _selecteProfile = _currentUser!.profilePhoto;
        _blocProfileSetUp!
            .onChangeProfilePic(value: _selecteProfile, isShowError: true);
      }

      final String code = _currentUser!.countryCode!;
      final String mobile = _currentUser!.mobileNumber!;

      // _txtPhoneController!.text = '$mobile'; //_txtPhoneController!.text = '$code $mobile';
      // if (_txtPhoneController!.text.isNotEmpty) {
      // // TODOO ON UNCOMMENT Genrate ERROR
      // _blocProfileSetUp!.onChangePhoneNumber(
      //     value: _txtPhoneController!.text, isShowError: true);
      // }

      _txtEmailController!.text = _currentUser!.email!;
      if (_txtEmailController!.text.isNotEmpty) {
        // TODOO ON UNCOMMENT Genrate ERROR
        _blocProfileSetUp!.onChangeEmailAddress(
            value: _txtEmailController!.text, isShowError: true);
      }

      _txtUserNameController!.text = _currentUser!.username!;
      if (_txtUserNameController!.text.isNotEmpty) {
        // TODOO ON UNCOMMENT Genrate ERROR
        _blocProfileSetUp!.onChangeUserName(
            value: _txtUserNameController!.text, isShowError: true);
      }

      _txtFullNameController!.text = _currentUser!.fullName!;
      if (_txtFullNameController!.text.isNotEmpty) {
        _blocProfileSetUp!.onChangeFullName(
            value: _txtFullNameController!.text, isShowError: true);
      }

      _txtLocationController!.text = _currentUser!.address!;
      if (_txtLocationController!.text.isNotEmpty) {
        _blocProfileSetUp!.onChangeLocation(
            value: _txtLocationController!.text, isShowError: true);
      }

      _selectedHeight = _currentUser!.height;
      _txtHeightController!.text = _selectedHeight!;
      if (_txtHeightController!.text.isNotEmpty) {
        //_selectedHeight = int.tryParse(_txtController.text) ?? 168;
        _blocProfileSetUp!
            .onChangeHeight(value: _selectedHeight, isShowError: true);
      }
      _selectedHeightType = _currentUser!.heightType;
      _txtHeightTypeController!.text = _selectedHeightType!;
      if (_txtHeightTypeController!.text.isNotEmpty) {
        _blocProfileSetUp!
            .onChangeHeightType(value: _selectedHeightType, isShowError: true);
      }

      _selectedWeight = _currentUser!.wight;
      _txtWeightController!.text = _selectedWeight?.toString() ?? '';
      if (_txtWeightController!.text.isNotEmpty) {
        //_selectedWeight = double.tryParse(_txtController.text) ?? 65.0;
        _blocProfileSetUp!
            .onChangeWeight(value: _selectedWeight, isShowError: true);
      }

      _selectedWeightType = _currentUser!.wightType;
      _txtWeightTypeController!.text = _selectedWeightType!;
      if (_txtWeightTypeController!.text.isNotEmpty) {
        _blocProfileSetUp!
            .onChangeWeightType(value: _selectedWeightType, isShowError: true);
      }

      _selectedDob = _currentUser!.birthDate;
      _txtBirhtdayController!.text = _selectedDob!.dateTimeString();
      if (_txtBirhtdayController!.text.isNotEmpty) {
        _blocProfileSetUp!.onChangeBirthday(
            value: _txtBirhtdayController!.text, isShowError: true);
      }

      _selectedGender = _currentUser!.gender;
      _txtGenderController!.text = _selectedGender!;
      if (_txtGenderController!.text.isNotEmpty) {
        _blocProfileSetUp!.onChangeGender(
            value: _txtGenderController!.text, isShowError: true);
      }

      _selectedActivityLevel = _currentUser!.activityLevel;
      _txtActivityLevelController!.text = _selectedActivityLevel.toString();
      if (_txtActivityLevelController!.text.isNotEmpty) {
        _blocProfileSetUp!.onChangeActivityLevel(
            value: _selectedActivityLevel, isShowError: true);
      }

      _selectedDailyGoal = _currentUser!.activityGoal;
      _txtActivityGoalController!.text = _selectedDailyGoal.toString();
      if (_txtActivityGoalController!.text.isNotEmpty) {
        _blocProfileSetUp!
            .onChangeActivityGoal(value: _selectedDailyGoal, isShowError: true);
      }

      _selectedCaloriesTOBurn = _currentUser!.calorieGoal;
      if (_selectedCaloriesTOBurn != null) {
        _txtCalorieGoalController!.text =
            '$_selectedCaloriesTOBurn ${AppConstants.calories}';
        _blocProfileSetUp!.onChangeCaloriesGoal(
            value: _txtCalorieGoalController!.text, isShowError: true);
      }

      _selectedMinutes = _currentUser!.activeMinuteGoal;

      if (_selectedMinutes != null) {
        _txtMinutesGoalController!.text =
            '$_selectedMinutes ${AppConstants.minutes}';
        _blocProfileSetUp!.onChangeMinutesGoal(
            value: _txtMinutesGoalController!.text, isShowError: true);
      }

      _selectedEnergyGenerate = _currentUser!.energyGenerateGoal;

      if (_selectedEnergyGenerate != null) {
        _txtEnergyGenerateGoalController!.text =
            '$_selectedEnergyGenerate ${AppConstants.watt}';
        _blocProfileSetUp!.onChangeEnergyEngGoal(
            value: _txtEnergyGenerateGoalController!.text, isShowError: true);
      }
    }
  }

  Widget _userProfile(BuildContext context) {
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
            ],
          );
        });
  }

  Widget _widgetPofilePictureHintText() {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 0),
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
                    isUpdate = true;
                    _blocProfileSetUp!
                        .onChangeProfilePic(value: file, isShowError: true);
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
                buttonSize: 80,
                iconColor: _config!.whiteColor,
                iconSize: 20,
                //onPressed: () {},
              )
            else if (_selecteProfile != null && _selecteProfile is String)
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(80 / 2),
                ),
                child: ClipRRect(
                    borderRadius: BorderRadius.circular(80 / 2),
                    child: CircularImage(
                      _selecteProfile as String,
                      width: 80,
                      height: 80,
                    )),
              )
            else if (_selecteProfile != null && _selecteProfile is File)
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(80 / 2),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(80 / 2),
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
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(width: 2, color: _config!.borderColor),
                      color: _config!.greyColor),
                  child: Center(
                    child: SvgIcon.asset(
                      ImgConstants.camera,
                      color: _config!.whiteColor,
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

  Widget _widgetPhoneNumber() {
    return Container(
      padding: const EdgeInsetsDirectional.fromSTEB(16, 24, 16, 0),
      child: StreamBuilder<ErrorMessage>(
        stream: _blocProfileSetUp!.getPhoneNumberErrorMessage,
        initialData: ErrorMessage(false, ''),
        builder: (BuildContext context, AsyncSnapshot<ErrorMessage> snapshot) {
          return CustomTextField(
            context: context,
            isEnable: false,
            controller: _txtPhoneController,
            showFlotingHint: true,
            floatingLabelBehavior: FloatingLabelBehavior.auto,
            focussNode: _focusNodePhone,
            lableText: AppConstants.phoneNumber.toUpperCase(),
            inputType: TextInputType.phone,
            capitalization: TextCapitalization.none,
            inputAction: TextInputAction.next,
            padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
            maxlength: 12,
            mainTextStyle: _config!.calibriHeading3FontStyle.apply(
              color: _config!.greyColor,
            ),
            onchange: (String value) {
              _blocProfileSetUp!
                  .onChangePhoneNumber(value: value, isShowError: true);
            },
            onSubmit: (String value) {
              FocusScope.of(context).requestFocus(_focusNodeEmail);
            },
            errorText: snapshot.data!.errorMessage.isEmpty
                ? null
                : snapshot.data!.errorMessage,
          );
        },
      ),
    );
  }

  Widget _widgetEmailAddress() {
    return Container(
      padding: const EdgeInsetsDirectional.fromSTEB(16, 24, 16, 0),
      child: StreamBuilder<ErrorMessage>(
        stream: _blocProfileSetUp!.getEmailErrorMessage,
        initialData: ErrorMessage(false, ''),
        builder: (BuildContext context, AsyncSnapshot<ErrorMessage> snapshot) {
          return CustomTextField(
            isEnable: false,
            stackAlignment: Alignment.centerRight,
            context: context,
            controller: _txtEmailController,
            focussNode: _focusNodeEmail,
            showFlotingHint: true,
            floatingLabelBehavior: FloatingLabelBehavior.auto,
            lableText: AppConstants.hintEmailAddress,
            mainTextStyle: _config!.calibriHeading3FontStyle.apply(
              color: _config!.greyColor,
            ),
            //hindText: AppConstants.hintFullName,
            inputType: TextInputType.emailAddress,
            capitalization: TextCapitalization.none,
            inputAction: TextInputAction.go,
            enableSuggestions: true,
            isAutocorrect: true,
            maxlength: 50,
            padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
            // sufixWidget: snapshot.data.errorMessage.isEmpty
            //     ? _widgetCheckMark()
            //     : const SizedBox(),
            onchange: (String value) {
              _blocProfileSetUp!
                  .onChangeEmailAddress(value: value, isShowError: true);
            },
            onSubmit: (String value) {
              FocusScope.of(context).requestFocus(_focusNodeUserName);
            },
            errorText: snapshot.data!.errorMessage.isEmpty
                ? null
                : snapshot.data!.errorMessage,
          );
        },
      ),
    );
  }

  Widget _widgetUserName() {
    return Container(
      padding: const EdgeInsetsDirectional.fromSTEB(16, 24, 16, 0),
      child: StreamBuilder<ErrorMessage>(
        stream: _blocProfileSetUp!.getUserNameErrorMessage,
        initialData: ErrorMessage(false, ''),
        builder: (BuildContext context, AsyncSnapshot<ErrorMessage> snapshot) {
          return CustomTextField(
            stackAlignment: Alignment.centerRight,
            context: context,
            controller: _txtUserNameController,
            focussNode: _focusNodeUserName,
            showFlotingHint: true,
            isEnable: false,
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
            mainTextStyle: _config!.calibriHeading3FontStyle.apply(
              color: _config!.greyColor,
            ),
            onSubmit: (String value) {
              FocusScope.of(context).requestFocus(_focusNodeFullName);
            },
            errorText: snapshot.data!.errorMessage.isEmpty
                ? null
                : snapshot.data!.errorMessage,
          );
        },
      ),
    );
  }

  Widget _widgetFullName() {
    return Container(
      padding: const EdgeInsetsDirectional.fromSTEB(16, 24, 16, 0),
      child: StreamBuilder<ErrorMessage>(
        stream: _blocProfileSetUp!.getFullNameErrorMessage,
        initialData: ErrorMessage(false, ''),
        builder: (BuildContext context, AsyncSnapshot<ErrorMessage> snapshot) {
          return CustomTextField(
            context: context,
            controller: _txtFullNameController,
            focussNode: _focusNodeFullName,
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
              isUpdate = true;
              _blocProfileSetUp!
                  .onChangeFullName(value: value, isShowError: true);
            },
            onSubmit: (String value) {
              FocusScope.of(context).requestFocus(_focusNodeLocation);
            },
            errorText: snapshot.data!.errorMessage.isEmpty
                ? null
                : snapshot.data!.errorMessage,
          );
        },
      ),
    );
  }

  Widget _widgetLocation(BuildContext mainContext) {
    return Container(
      padding: const EdgeInsetsDirectional.fromSTEB(16, 24, 16, 0),
      child: StreamBuilder<ErrorMessage>(
        stream: _blocProfileSetUp!.getLocationErrorMessage,
        initialData: ErrorMessage(false, ''),
        builder:
            (BuildContext context, AsyncSnapshot<ErrorMessage> errorSnapshot) {
          return CustomTextField(
            stackAlignment: Alignment.centerRight,
            context: context,
            controller: _txtLocationController,
            focussNode: _focusNodeLocation,
            showFlotingHint: true,
            floatingLabelBehavior: FloatingLabelBehavior.auto,
            lableText: AppConstants.hintLocation,
            //hindText: AppConstants.hintFullName,
            inputType: TextInputType.text,
            capitalization: TextCapitalization.sentences,
            inputAction: TextInputAction.done,
            enableSuggestions: true,
            isAutocorrect: true,
            maxlength: 255,
            padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
            contentPadding: const EdgeInsetsDirectional.fromSTEB(0, 0, 20, 0),
            sufixWidget: _widgetLocationPin(mainContext),
            onchange: (String value) {
              isUpdate = true;
              _blocProfileSetUp!
                  .onChangeLocation(value: value, isShowError: true);
            },
            onSubmit: (String value) {
              _focusNodeLocation!.unfocus();
            },
            errorText: errorSnapshot.data!.errorMessage.isEmpty
                ? null
                : errorSnapshot.data!.errorMessage,
          );
        },
      ),
    );
  }

  Widget _widgetLocationPin(BuildContext mainContext) {
    return ValueListenableBuilder<bool>(
      valueListenable: _notifierIsFetchingLocation,
      builder: (BuildContext? context, bool? isFetching, Widget? child) {
        return TextButton(
          onPressed: () {
            if (!isFetching!) {
              _notifierIsFetchingLocation.value = true;
              _checkForLocationPemission(mainContext);
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
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (serviceEnabled) {
      final PermissionStatus status =
          await Permission.locationWhenInUse.request();

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
    GeoCode geoCode = GeoCode();
    try {
      final Position currentLocation = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      addressCoordinates = Coordinates(
          latitude: currentLocation.latitude,
          longitude: currentLocation.longitude);
      Address addresses = await geoCode.reverseGeocoding(
          latitude: currentLocation.latitude,
          longitude: currentLocation.longitude);
      if (addresses != null) {
        final Address address = addresses;
        final String addressLine2 = address.toString();
        _txtLocationController!.text = addressLine2;
        _blocProfileSetUp!
            .onChangeLocation(value: addressLine2, isShowError: true);
        _notifierIsFetchingLocation.value = false;
      }
    } on Exception catch (_) {}
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

  Widget _widgetHeight(BuildContext mainContext) {
    return Container(
      padding: const EdgeInsetsDirectional.fromSTEB(16, 24, 16, 0),
      child: Row(
        children: <Widget>[
          Expanded(
            child: GestureDetector(
              onTap: () {
                showModalBottomSheet(
                    context: context,
                    builder: (BuildContext builder) {
                      final List<String> feetList =
                          List<String>.generate(304, (int index) {
                        final int cm = 1 + index;
                        String value = '';
                        if (_selectedHeightType == 'cm') {
                          value = '$cm cm';
                        } else {
                          //final int feet = (cm.toDouble() * 0.0328).toInt();
                          //value = '$feet ft';
                          const double inchInCm = 2.54;

                          int numInches = (cm.toDouble() / inchInCm).toInt();
                          int feet = (numInches / 12).toInt();
                          int inches = numInches % 12;
                          value = '$feet\'$inches\'\'';
                        }

                        return value;
                      }).toSet().toList();
                      String initValue = _selectedHeight.toString();
                      if (_selectedHeightType == 'cm') {
                        initValue = '$initValue cm';
                      } else {
                        initValue = '$initValue ft';
                      }
                      return DatePicker(
                        selectedIndex: feetList.indexOf(initValue),
                        onDone: (int value) {
                          final String selectedHeight = feetList[value];
                          _selectedHeight = selectedHeight;
                          _txtHeightController!.clear();
                          _txtHeightController!.text = selectedHeight;
                          isUpdate = true;
                          _blocProfileSetUp!.onChangeHeight(
                              value: _selectedHeight, isShowError: true);
                        },
                        items: feetList,
                      );
                    });
              },
              child: Container(
                padding: EdgeInsets.zero,
                width: double.infinity,
                height: 48,
                child: StreamBuilder<ErrorMessage>(
                  stream: _blocProfileSetUp!.getHeightErrorMessage,
                  initialData: ErrorMessage(false, ''),
                  builder: (BuildContext context,
                      AsyncSnapshot<ErrorMessage> snapshot) {
                    return CustomTextField(
                      stackAlignment: Alignment.centerRight,
                      context: context,
                      controller: _txtHeightController,
                      focussNode: _focusNodeHeight,
                      showFlotingHint: true,
                      isEnable: false,
                      floatingLabelBehavior: FloatingLabelBehavior.auto,
                      lableText: AppConstants.hintHeight,
                      //hindText: AppConstants.hintFullName,
                      inputType: TextInputType.text,
                      capitalization: TextCapitalization.sentences,
                      inputAction: TextInputAction.go,
                      enableSuggestions: true,
                      isAutocorrect: true,
                      maxlength: 255,
                      padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                      contentPadding:
                          const EdgeInsetsDirectional.fromSTEB(0, 0, 20, 0),
                      sufixWidget: _widgetDownArrow(),
                      onchange: (String value) {
                        _blocProfileSetUp!
                            .onChangeLocation(value: value, isShowError: true);
                      },
                      onSubmit: (String value) {
                        //_focusNode.unfocus();
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
          const SizedBox(
            width: 41,
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                showModalBottomSheet(
                    context: context,
                    builder: (BuildContext builder) {
                      final List<String> heightType = <String>['cm', 'ft'];

                      return DatePicker(
                        selectedIndex: heightType.indexOf(_selectedHeightType!),
                        onDone: (int value) {
                          final String selectedType = heightType[value];
                          _selectedHeightType = selectedType;
                          _txtHeightTypeController!.clear();
                          _txtHeightTypeController!.text = selectedType;
                          isUpdate = true;
                          _blocProfileSetUp!.onChangeHeightType(
                              value: _txtHeightTypeController!.text,
                              isShowError: true);

                          _txtHeightController!.clear();
                          if (_selectedHeightType == 'cm') {
                            _selectedHeight = '168';
                          } else {
                            _selectedHeight = '5\'6\'\'';
                          }

                          _txtHeightController!.text =
                              _selectedHeight.toString();
                          _blocProfileSetUp!.onChangeHeight(
                              value: _selectedHeight, isShowError: true);
                        },
                        items: heightType,
                      );
                    });
              },
              child: Container(
                padding: EdgeInsets.zero,
                width: double.infinity,
                height: 48,
                child: StreamBuilder<ErrorMessage>(
                  stream: _blocProfileSetUp!.getHeightTypeErrorMessage,
                  initialData: ErrorMessage(false, ''),
                  builder: (BuildContext context,
                      AsyncSnapshot<ErrorMessage> snapshot) {
                    return CustomTextField(
                      stackAlignment: Alignment.centerRight,
                      context: context,
                      controller: _txtHeightTypeController,
                      focussNode: _focusNodeHeightType,
                      lableText: AppConstants.hintHeight,
                      inputType: TextInputType.text,
                      capitalization: TextCapitalization.none,
                      inputAction: TextInputAction.next,
                      maxlength: 5,
                      sufixWidget: _widgetDownArrow(),
                      isEnable: false,
                      padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
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
    );
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

  Widget _widgetWeight(BuildContext mainContext) {
    return Container(
      padding: const EdgeInsetsDirectional.fromSTEB(16, 24, 16, 0),
      child: Row(
        children: <Widget>[
          Expanded(
            child: GestureDetector(
              onTap: () {
                showModalBottomSheet(
                    context: context,
                    builder: (BuildContext builder) {
                      final List<String> kgList =
                          List<String>.generate(400, (int index) {
                        final double kg = (1 + index) * 0.5;
                        String value = '';
                        if (_selectedWeightType == 'kg') {
                          value = '$kg kg';
                        } else {
                          final int pound = (kg.toDouble() * 2.20462).toInt();
                          value = '$pound pound';
                        }

                        return value;
                      }).toSet().toList();
                      String initValue = _selectedWeight.toString();
                      if (_selectedWeightType == 'kg') {
                        initValue = '$initValue kg';
                      } else {
                        initValue = '$initValue pound';
                      }
                      return DatePicker(
                        selectedIndex: kgList.indexOf(initValue),
                        onDone: (int value) {
                          final String selectedWeight =
                              kgList[value].split(' ').first;
                          _selectedWeight = double.tryParse(selectedWeight);
                          _txtWeightController!.clear();
                          _txtWeightController!.text = selectedWeight;
                          isUpdate = true;
                          _blocProfileSetUp!.onChangeWeight(
                              value: _selectedWeight, isShowError: true);
                        },
                        items: kgList,
                      );
                    });
              },
              child: Container(
                padding: EdgeInsets.zero,
                width: double.infinity,
                height: 48,
                child: StreamBuilder<ErrorMessage>(
                  stream: _blocProfileSetUp!.getHeightErrorMessage,
                  initialData: ErrorMessage(false, ''),
                  builder: (BuildContext context,
                      AsyncSnapshot<ErrorMessage> snapshot) {
                    return CustomTextField(
                      stackAlignment: Alignment.centerRight,
                      context: context,
                      controller: _txtWeightController,
                      focussNode: _focusNodeWeight,
                      showFlotingHint: true,
                      isEnable: false,
                      floatingLabelBehavior: FloatingLabelBehavior.auto,
                      lableText: AppConstants.hintWeight,
                      //hindText: AppConstants.hintFullName,
                      inputType: TextInputType.text,
                      capitalization: TextCapitalization.sentences,
                      inputAction: TextInputAction.go,
                      enableSuggestions: true,
                      isAutocorrect: true,
                      maxlength: 255,
                      padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                      contentPadding:
                          const EdgeInsetsDirectional.fromSTEB(0, 0, 20, 0),
                      sufixWidget: _widgetDownArrow(),
                      onchange: (String value) {
                        //_blocProfileSetUp.onChangeWeight(value: value);
                      },
                      onSubmit: (String value) {
                        //_focusNode.unfocus();
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
          const SizedBox(
            width: 41,
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                showModalBottomSheet(
                    context: context,
                    builder: (BuildContext builder) {
                      final List<String> weightType = <String>['kg', 'pound'];

                      return DatePicker(
                        selectedIndex: weightType.indexOf(_selectedWeightType!),
                        onDone: (int value) {
                          final String selectedType = weightType[value];
                          _selectedWeightType = selectedType;
                          _txtWeightTypeController!.clear();
                          _txtWeightTypeController!.text = selectedType;
                          isUpdate = true;
                          _blocProfileSetUp!.onChangeWeightType(
                              value: _txtWeightTypeController!.text,
                              isShowError: true);

                          _txtWeightController!.clear();
                          if (_selectedWeightType == 'kg') {
                            _selectedWeight = 65.0;
                          } else {
                            _selectedWeight = 22.0;
                          }

                          _txtWeightController!.text =
                              _selectedWeight.toString();
                          _blocProfileSetUp!.onChangeWeight(
                              value: _selectedWeight, isShowError: true);
                        },
                        items: weightType,
                      );
                    });
              },
              child: Container(
                padding: EdgeInsets.zero,
                width: double.infinity,
                height: 48,
                child: StreamBuilder<ErrorMessage>(
                  stream: _blocProfileSetUp!.getWeightTypeErrorMessage,
                  initialData: ErrorMessage(false, ''),
                  builder: (BuildContext context,
                      AsyncSnapshot<ErrorMessage> snapshot) {
                    return CustomTextField(
                      stackAlignment: Alignment.centerRight,
                      context: context,
                      controller: _txtWeightTypeController,
                      focussNode: _focusNodeWeightType,
                      lableText: AppConstants.hintWeight,
                      inputType: TextInputType.text,
                      capitalization: TextCapitalization.none,
                      inputAction: TextInputAction.go,
                      maxlength: 5,
                      sufixWidget: _widgetDownArrow(),
                      isEnable: false,
                      padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
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
    );
  }

  Widget _widgetBirthday(BuildContext mainContext) {
    return Container(
      padding: const EdgeInsetsDirectional.fromSTEB(16, 24, 16, 0),
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
                  intialdate: _selectedDob ??
                      dateOf16Year.subtract(const Duration(minutes: 1)),
                  //minmumDate: DateTime(1958),
                  maximumDate: dateOf16Year,
                  //max: DateTime.now(),
                  onDone: (DateTime date) {
                    final DateTime selectedDate = date;
                    if (selectedDate != null) {
                      _selectedDob = selectedDate;
                      _txtBirhtdayController!.clear();
                      _txtBirhtdayController!.text =
                          _selectedDob!.dateTimeString();
                      isUpdate = true;
                      _blocProfileSetUp!.onChangeBirthday(
                          value: _txtBirhtdayController!.text,
                          isShowError: true);
                    }
                  },
                );
              });
        },
        child: Container(
          padding: EdgeInsets.zero,
          width: double.infinity,
          child: StreamBuilder<ErrorMessage>(
            stream: _blocProfileSetUp!.getBirthdayErrorMessage,
            initialData: ErrorMessage(false, ''),
            builder:
                (BuildContext context, AsyncSnapshot<ErrorMessage> snapshot) {
              return CustomTextField(
                stackAlignment: Alignment.centerRight,
                context: context,
                controller: _txtBirhtdayController,
                focussNode: _focusNodeBirhtday,
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
                  //_focusNode.unfocus();
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

  Widget _widgetGender(BuildContext mainContext) {
    return Container(
      padding: const EdgeInsetsDirectional.fromSTEB(16, 24, 16, 0),
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();

          showModalBottomSheet(
              context: context,
              builder: (BuildContext builder) {
                final List<String> genderList = [
                  AppConstants.female,
                  AppConstants.male
                ];
                return DatePicker(
                  selectedIndex: genderList.indexOf(_selectedGender.toString()),
                  onDone: (int value) {
                    final String selected = genderList[value];
                    _selectedGender = selected;
                    _txtGenderController!.clear();
                    _txtGenderController!.text =
                        _selectedGender ?? AppConstants.female;
                    _blocProfileSetUp!
                        .onChangeGender(value: _txtGenderController!.text);
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
                controller: _txtGenderController,
                focussNode: _focusNodeGender,
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
                  // _blocProfileSetUp?.onChangeGender(value: value);
                },
                onSubmit: (String value) {
                  _focusNodeGender!.unfocus();
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

  // String _getHeaderTitle() {
  //   switch (_currentSetupStep) {
  //     case 9:
  //       return AppConstants.activityLevelTitle;
  //     case 10:
  //       return AppConstants.dailyGoalTitle;
  //     case 11:
  //       return AppConstants.calorieGoalTitle;
  //     case 12:
  //       return AppConstants.minutesGoalTitle;
  //     case 13:
  //       return AppConstants.energyGoalTitle;
  //     default:
  //       return AppConstants.completeYourProfileTitle;
  //   }
  // }

  Widget _wdgetActivityLevel() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _widgetActivityTitle(),
        _widgetActivityMsg(),
        _widgetActivityLevelSlider()
      ],
    );
  }

  Widget _widgetActivityTitle() {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(16, 24, 16, 0),
      child: Align(
        alignment: Alignment.topLeft,
        child: Text(
          AppConstants.activityLevelTitle,
          style: _config!.calibriHeading3FontStyle.apply(
            color: _config!.whiteColor,
          ),
          textAlign: TextAlign.left,
        ),
      ),
    );
  }

  Widget _widgetActivityMsg() {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(16, 8, 16, 0),
      child: Align(
        alignment: Alignment.topLeft,
        child: RichText(
          textAlign: TextAlign.left,
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
      padding: const EdgeInsetsDirectional.fromSTEB(0, 22, 0, 0),
      child: StreamBuilder<int>(
        stream: _blocProfileSetUp!.getActivityLevel,
        initialData: _selectedActivityLevel,
        builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
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
              isUpdate = true;
              _blocProfileSetUp!.onChangeActivityLevel(
                  value: newValue.round(), isShowError: true);
            },
          );
        },
      ),
    );
  }

  Widget _widgetDailyActivityGoal() {
    return Column(
      children: <Widget>[
        _widgetActivityGoalTitle(),
        _widgetActivityGoalMsg(),
        _widgetActivityGoalSlider()
      ],
    );
  }

  Widget _widgetActivityGoalTitle() {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(16, 24, 16, 0),
      child: Align(
        alignment: Alignment.topLeft,
        child: Text(
          AppConstants.dailyGoalTitle,
          style: _config!.calibriHeading3FontStyle.apply(
            color: _config!.whiteColor,
          ),
          textAlign: TextAlign.left,
        ),
      ),
    );
  }

  Widget _widgetActivityGoalMsg() {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(16, 8, 16, 0),
      child: Align(
        alignment: Alignment.topLeft,
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
      padding: const EdgeInsetsDirectional.fromSTEB(0, 22, 0, 0),
      child: StreamBuilder<int>(
        stream: _blocProfileSetUp!.getActivityGoal,
        initialData: _selectedDailyGoal,
        builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
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
              isUpdate = true;
              final double newValue = value as double;
              _blocProfileSetUp!.onChangeActivityGoal(
                  value: newValue.round(), isShowError: true);
            },
          );
        },
      ),
    );
  }

  Widget _widgetCalorieGoal() {
    return Column(
      children: <Widget>[
        _widgetCalorieGoalTitle(),
        _widgetCalorieGoalMsg(),
        _widgetCalorieBurnPicker()
      ],
    );
  }

  Widget _widgetCalorieGoalTitle() {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(16, 24, 16, 0),
      child: Align(
        alignment: Alignment.topLeft,
        child: Text(
          AppConstants.calorieGoalTitle,
          style: _config!.calibriHeading3FontStyle.apply(
            color: _config!.whiteColor,
          ),
          textAlign: TextAlign.left,
        ),
      ),
    );
  }

  Widget _widgetCalorieGoalMsg() {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(16, 8, 16, 0),
      child: Align(
        alignment: Alignment.topLeft,
        child: Text(
          AppConstants.calorieGoalMsg,
          style: _config!.paragraphNormalFontStyle.apply(
            color: _config!.greyColor,
          ),
          textAlign: TextAlign.left,
        ),
      ),
    );
  }

  Widget _widgetCalorieBurnPicker() {
    return Container(
      padding: const EdgeInsetsDirectional.fromSTEB(16, 22, 16, 0),
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();

          showModalBottomSheet(
              context: context,
              builder: (BuildContext builder) {
                final List<String> caloriesList =
                    List<String>.generate(1000, (int index) {
                  final int value = 1 + index;
                  return value.toString();
                }).toSet().toList();

                return DatePicker(
                  selectedIndex:
                      caloriesList.indexOf(_selectedCaloriesTOBurn.toString()),
                  onDone: (int value) {
                    final String selected = caloriesList[value];
                    _selectedCaloriesTOBurn = int.tryParse(selected);
                    _txtCalorieGoalController!.clear();
                    _txtCalorieGoalController!.text =
                        '$_selectedCaloriesTOBurn ${AppConstants.calories}';
                    isUpdate = true;
                    _blocProfileSetUp!.onChangeCaloriesGoal(
                        value: _txtCalorieGoalController!.text,
                        isShowError: true);
                  },
                  items: caloriesList,
                );
              });
        },
        child: Container(
          padding: EdgeInsets.zero,
          width: double.infinity,
          child: StreamBuilder<ErrorMessage>(
            stream: _blocProfileSetUp!.getBirthdayErrorMessage,
            initialData: ErrorMessage(false, ''),
            builder:
                (BuildContext context, AsyncSnapshot<ErrorMessage> snapshot) {
              return CustomTextField(
                stackAlignment: Alignment.centerRight,
                context: context,
                controller: _txtCalorieGoalController,
                focussNode: _focusNodeCalorieGoal,
                showFlotingHint: true,
                isEnable: false,
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
                sufixWidget: _widgetDownArrow(),
                onchange: (String value) {
                  //_blocProfileSetUp.onChangeWeight(value: value);
                },
                onSubmit: (String value) {
                  //_focusNode.unfocus();
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

  Widget _widgetMinutesGoal() {
    return Column(
      children: <Widget>[
        _widgetMinutesTitle(),
        _widgetMinutesMsg(),
        _widgetMinutesPicker()
      ],
    );
  }

  Widget _widgetMinutesTitle() {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(16, 24, 16, 0),
      child: Align(
        alignment: Alignment.topLeft,
        child: Text(
          AppConstants.minutesGoalTitle,
          style: _config!.calibriHeading3FontStyle.apply(
            color: _config!.whiteColor,
          ),
          textAlign: TextAlign.left,
        ),
      ),
    );
  }

  Widget _widgetMinutesMsg() {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(16, 8, 16, 0),
      child: Align(
        alignment: Alignment.topLeft,
        child: Text(
          AppConstants.minutesGoalMsg,
          style: _config!.paragraphNormalFontStyle.apply(
            color: _config!.greyColor,
          ),
          textAlign: TextAlign.left,
        ),
      ),
    );
  }

  Widget _widgetMinutesPicker() {
    return Container(
      padding: const EdgeInsetsDirectional.fromSTEB(16, 22, 16, 0),
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();

          showModalBottomSheet(
              context: context,
              builder: (BuildContext builder) {
                final List<String> minutesList =
                    List<String>.generate(1000, (int index) {
                  final int value = 1 + index;
                  return value.toString();
                }).toSet().toList();

                return DatePicker(
                  selectedIndex:
                      minutesList.indexOf(_selectedMinutes.toString()),
                  onDone: (int value) {
                    final String selected = minutesList[value];
                    _selectedMinutes = int.tryParse(selected);
                    _txtMinutesGoalController!.clear();
                    _txtMinutesGoalController!.text =
                        '$_selectedMinutes ${AppConstants.minutes}';
                    isUpdate = true;
                    _blocProfileSetUp!.onChangeMinutesGoal(
                        value: _txtMinutesGoalController!.text,
                        isShowError: true);
                  },
                  items: minutesList,
                );
              });
        },
        child: Container(
          padding: EdgeInsets.zero,
          width: double.infinity,
          child: StreamBuilder<ErrorMessage>(
            stream: _blocProfileSetUp!.getMinutesGoalErrorMessage,
            initialData: ErrorMessage(false, ''),
            builder:
                (BuildContext context, AsyncSnapshot<ErrorMessage> snapshot) {
              return CustomTextField(
                stackAlignment: Alignment.centerRight,
                context: context,
                controller: _txtMinutesGoalController,
                focussNode: _focusNodeMinutesGoal,
                showFlotingHint: true,
                isEnable: false,
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
                sufixWidget: _widgetDownArrow(),
                onchange: (String value) {
                  //_blocProfileSetUp.onChangeWeight(value: value);
                },
                onSubmit: (String value) {
                  //_focusNode.unfocus();
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

  Widget _widgetEnergyGenerate() {
    return Column(
      children: <Widget>[
        _widgetEnergyGenerateTitle(),
        _widgetEnergyGenerateMsg(),
        _widgetEnergyGeneratePicker()
      ],
    );
  }

  Widget _widgetEnergyGenerateTitle() {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(16, 24, 16, 0),
      child: Align(
        alignment: Alignment.topLeft,
        child: Text(
          AppConstants.energyGoalTitle,
          style: _config!.calibriHeading3FontStyle.apply(
            color: _config!.whiteColor,
          ),
          textAlign: TextAlign.left,
        ),
      ),
    );
  }

  Widget _widgetEnergyGenerateMsg() {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(16, 8, 16, 0),
      child: Align(
        alignment: Alignment.topLeft,
        child: Text(
          AppConstants.energyGoalMsg,
          style: _config!.paragraphNormalFontStyle.apply(
            color: _config!.greyColor,
          ),
          textAlign: TextAlign.left,
        ),
      ),
    );
  }

  Widget _widgetEnergyGeneratePicker() {
    return Container(
      padding: const EdgeInsetsDirectional.fromSTEB(16, 22, 16, 0),
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();

          showModalBottomSheet(
              context: context,
              builder: (BuildContext builder) {
                final List<String> wattList =
                    List<String>.generate(1000, (int index) {
                  final int value = 1 + index;
                  return value.toString();
                }).toSet().toList();

                return DatePicker(
                  selectedIndex:
                      wattList.indexOf(_selectedEnergyGenerate.toString()),
                  onDone: (int value) {
                    final String selected = wattList[value];
                    _selectedEnergyGenerate = int.tryParse(selected);
                    _txtEnergyGenerateGoalController!.clear();
                    _txtEnergyGenerateGoalController!.text =
                        '$_selectedEnergyGenerate ${AppConstants.watt}';
                    isUpdate = true;
                    _blocProfileSetUp!.onChangeEnergyEngGoal(
                        value: _txtEnergyGenerateGoalController!.text,
                        isShowError: true);
                  },
                  items: wattList,
                );
              });
        },
        child: Container(
          padding: EdgeInsets.zero,
          width: double.infinity,
          child: StreamBuilder<ErrorMessage>(
            stream: _blocProfileSetUp!.getEnergyEngGoalErrorMessage,
            initialData: ErrorMessage(false, ''),
            builder:
                (BuildContext context, AsyncSnapshot<ErrorMessage> snapshot) {
              return CustomTextField(
                stackAlignment: Alignment.centerRight,
                context: context,
                controller: _txtEnergyGenerateGoalController,
                focussNode: _focusNodeEnergyGenerateGoal,
                showFlotingHint: true,
                isEnable: false,
                floatingLabelBehavior: FloatingLabelBehavior.auto,
                lableText: AppConstants.hintEnergyGenerate.toUpperCase(),
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
                  //_focusNode.unfocus();
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

  Future<void> _updateDataForStep() async {
    final Map<String, dynamic> _neetToStoreData = <String, dynamic>{};
    _notifierIsSaving.value = true;
    _neetToStoreData[UserCollectionField.fullName] =
        _txtFullNameController!.text;
    if (_selecteProfile is String) {
      _neetToStoreData[UserCollectionField.profilePhoto] = _selecteProfile;
    }
    _neetToStoreData[UserCollectionField.address] =
        _txtLocationController!.text;
    _neetToStoreData[UserCollectionField.latLong] =
        addressCoordinates.toString();

    _neetToStoreData[UserCollectionField.height] = _selectedHeight;
    _neetToStoreData[UserCollectionField.heightType] = _selectedHeightType;

    _neetToStoreData[UserCollectionField.wight] = _selectedWeight;
    _neetToStoreData[UserCollectionField.wightType] = _selectedWeightType;

    if (_selectedDob != null) {
      _neetToStoreData[UserCollectionField.birthDate] =
          _selectedDob?.toIso8601String();
    }

    if (_selectedGender != null) {
      _neetToStoreData[UserCollectionField.gender] = _selectedGender;
    }

    _neetToStoreData[UserCollectionField.activityLevel] =
        _selectedActivityLevel;
    _neetToStoreData[UserCollectionField.activityGoal] = _selectedDailyGoal;

    _neetToStoreData[UserCollectionField.calorieGoal] = _selectedCaloriesTOBurn;

    _neetToStoreData[UserCollectionField.activeMinuteGoal] = _selectedMinutes;

    _neetToStoreData[UserCollectionField.energyGenerateGoal] =
        _selectedEnergyGenerate;

    if (_selecteProfile is File) {
      final File image = _selecteProfile as File;
      final String fileExtenstion = path.extension(image.path);
      final String fileName = '${_currentUser!.documentId}$fileExtenstion';
      StorageProvider.instance.uploadFile(
          profilePic: image,
          fileName: fileName,
          onSuccess: (String imageUrl) {
            _neetToStoreData[UserCollectionField.profilePhoto] = imageUrl;
            updateUserDataToFireStore(data: _neetToStoreData);
          },
          onError: (String errorMsg) {
            _notifierIsSaving.value = false;
          });
    } else {
      updateUserDataToFireStore(data: _neetToStoreData);
    }
  }

  void updateUserDataToFireStore({required Map<String, dynamic>? data}) {
    FireStoreProvider.instance.updateUser(
      userId: _currentUser!.documentId,
      userData: data!,
      onSuccess: (Map<String, dynamic> successResponse) {
        _notifierIsSaving.value = false;
        Navigator.pop(context);
      },
      onError: (Map<String, dynamic> errorResponse) {
        _notifierIsSaving.value = false;
      },
    );
  }
}
