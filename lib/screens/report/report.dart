import 'package:energym/app_config.dart';
import 'package:energym/models/error_message_model.dart';
import 'package:energym/reusable_component/custom_textfield.dart';
import 'package:energym/screens/report/report_bloc.dart';
import 'package:energym/utils/common/base_bloc.dart';
import 'package:energym/utils/common/constants.dart';
import 'package:energym/utils/common/main_app_bar.dart';
import 'package:energym/utils/common/svg_icon.dart';
import 'package:energym/utils/helpers/api_provider.dart';
import 'package:energym/utils/helpers/firebase/firestore_provider.dart';
import 'package:energym/utils/theme/colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:energym/utils/extensions/extension.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:energym/models/feed_model.dart';
import 'package:energym/models/user_model.dart';

class Report extends StatefulWidget {
  final FeedModel? feed;
  final UserModel? user;
  final bool? isRepostPost;
  Report({Key? key, required this.isRepostPost, this.feed, this.user})
      : super(key: key);

  @override
  _ReportState createState() => _ReportState();
}

class _ReportState extends State<Report> {
  FeedModel? _feed;
  UserModel? _user;
  bool? _isRepostPost;
  TextEditingController? _txtTitleController;
  ValueNotifier<bool>? _isLoading = ValueNotifier(false);
  ReportBloc? _blocReport;
  AppConfig? _appConfig;
  UserModel? _currentUser;
  @override
  void initState() {
    super.initState();
    _blocReport = ReportBloc();
    _currentUser = aGeneralBloc.currentUser;
    _txtTitleController = TextEditingController();
    _feed = widget.feed;
    _user = widget.user;
    _isRepostPost = widget.isRepostPost;
  }

  @override
  void dispose() {
    //Step 1
    _isLoading!.dispose();
    _txtTitleController!.dispose();
    _blocReport!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _appConfig = AppConfig.of(context);
    double bootmPading = context.keyboardHeight == 0 ? 40 : 0;
    return SafeArea(
      bottom: false,
      maintainBottomViewPadding: true,
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Padding(
          padding: EdgeInsets.zero, //MediaQuery.of(context).viewInsets,
          child: Container(
            constraints: const BoxConstraints(maxHeight: 300),
            decoration: BoxDecoration(
                color: _appConfig!.borderColor,
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(30.0),
                    topRight: Radius.circular(30.0))),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                _getAppBar(context),
                const Spacer(),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Expanded(
                      child: _widgetTitleTextField(context),
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    _widgetButtonSend(context),
                  ],
                ),
                SizedBox(
                  height: bootmPading,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _widgetButtonSend(BuildContext context) {
    return StreamBuilder<bool>(
      stream: _blocReport!.validateReportForm,
      builder: (BuildContext context, AsyncSnapshot<bool> btnEnableSnapshot) {
        bool isValid = false;
        if (btnEnableSnapshot.hasData && btnEnableSnapshot.data != null) {
          isValid = btnEnableSnapshot.data!;
        }
        return ValueListenableBuilder<bool>(
          valueListenable: _isLoading!,
          builder: (BuildContext? context, bool? isloading, Widget? child) {
            return Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                ),
                onPressed: () async {
                  if (isValid && isloading == false) {
                    _isLoading!.value = true;
                    FocusScope.of(context!).unfocus();
                    Map<String, dynamic> data = <String, dynamic>{};
                    data[ReportCollectionField.message] =
                        _txtTitleController!.text;
                    data[ReportCollectionField.entityId] =
                        _isRepostPost! ? _feed!.documentId : _feed!.userId;
                    data[ReportCollectionField.type] =
                        _isRepostPost! ? ReportType.post : ReportType.user;

                    data[ReportCollectionField.userFullName] =
                        _feed!.userFullName;
                    data[ReportCollectionField.userId] = _feed!.userId;
                    data[ReportCollectionField.userMobileNumber] =
                        _feed!.userMobileNumber;
                    data[ReportCollectionField.userProfilePhoto] =
                        _feed!.userProfilePicture;
                    data[ReportCollectionField.username] = _feed!.userName;

                    data[ReportCollectionField.senderUserFullName] =
                        _currentUser!.fullName;
                    data[ReportCollectionField.senderUserId] =
                        _currentUser!.documentId;
                    data[ReportCollectionField.senderUserMobileNumber] =
                        _currentUser!.mobileNumber;
                    data[ReportCollectionField.senderUserProfilePhoto] =
                        _currentUser!.profilePhoto;
                    data[ReportCollectionField.senderUsername] =
                        _currentUser!.username;
                    data[ReportCollectionField.createdAt] = Timestamp.now();

                    FireStoreProvider.instance.createReport(
                      context: context,
                      data: data,
                      onSuccess: (Map<String, dynamic> success) {
                        _isLoading!.value = false;
                        Navigator.pop(context, true);
                      },
                      onError: (Map<String, dynamic> success) {
                        _isLoading!.value = false;
                      },
                    );
                  }
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    isloading!
                        ? SpinKitCircle(
                            color: _appConfig!.btnPrimaryColor,
                            size: 15,

                            //lineWidth: 3,
                          )
                        : Text(
                            AppConstants.send,
                            style: _appConfig!.linkNormalFontStyle.apply(
                              color: _appConfig!.btnPrimaryColor,
                            ),
                          ),
                    const SizedBox(
                      width: 5,
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  PreferredSizeWidget _getAppBar(BuildContext context) {
    return getMainAppBar(
      context,
      _appConfig!,
      title: _isRepostPost! ? AppConstants.reportPost : AppConstants.reportUser,
      backgoundColor: Colors.transparent,
      textColor: _appConfig!.whiteColor,
      elevation: 0,
      isBackEnable: false,
      actions: [
        IconButton(
          highlightColor: Colors.transparent,
          splashColor: Colors.transparent,
          iconSize: 16,
          icon: SvgIcon.asset(
            ImgConstants.close,
            color: _appConfig!.whiteColor,
          ),
          //color: color,
          tooltip: MaterialLocalizations.of(context).backButtonTooltip,
          onPressed: () {
            Navigator.pop(context);
          },
        )
      ],
      onBack: () {
        Navigator.pop(context);
      },
    );
  }

  Widget _widgetTitleTextField(BuildContext context) {
    return StreamBuilder<ErrorMessage>(
      stream: _blocReport!.getMessageErrorMessage,
      initialData: ErrorMessage(false, ''),
      builder: (BuildContext context, AsyncSnapshot<ErrorMessage> snapshot) {
        return CustomTextField(
          context: context,
          controller: _txtTitleController,
          padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 0),
          contentPadding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
          lableText: AppConstants.writeYourReport,
          hindText: AppConstants.writeYourReport,
          inputType: TextInputType.multiline,
          inputAction: TextInputAction.newline,
          enableSuggestions: true,
          isAutocorrect: true,
          maxline: null,
          maxlength: 255,
          errorText: snapshot.data!.errorMessage.isEmpty
              ? null
              : snapshot.data!.errorMessage,
          onchange: (String value) {
            _blocReport!.onChangeMessageValidation(
                value: value, isShowError: true);
          },
        );
      },
    );
  }
}
