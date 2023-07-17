import 'dart:io';

import 'package:energym/screens/feed/add_feed_bloc.dart';
import 'package:energym/utils/common/base_bloc.dart';
import 'package:energym/utils/common/circle_button.dart';
import 'package:energym/utils/common/config.dart';
import 'package:energym/utils/common/constants.dart';
import 'package:energym/utils/common/main_app_bar.dart';
import 'package:energym/utils/common/svg_icon.dart';
import 'package:energym/utils/helpers/firebase/firestore_provider.dart';
import 'package:flutter/material.dart';
import 'package:energym/reusable_component/custom_scaffold.dart';
import 'package:energym/app_config.dart';
import 'package:energym/models/user_model.dart';
import 'package:energym/reusable_component/circular_image.dart';
import 'package:energym/reusable_component/loader_button.dart';
import 'package:energym/reusable_component/custom_textfield.dart';
import 'package:energym/models/error_message_model.dart';
import 'package:energym/utils/extensions/extension.dart';
import 'package:energym/reusable_component/img_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:energym/reusable_component/custom_dialog.dart';

class AddFeed extends StatefulWidget {
  static const String routeName = '/AddFeed';
  @override
  _AddFeedState createState() => _AddFeedState();
}

class _AddFeedState extends State<AddFeed> {
  AppConfig? _appConfig;
  UserModel? _currentUser;
  final AddFeedBloc _blocAddFeed = AddFeedBloc();
  final TextEditingController _txtWhatsImMind = TextEditingController();
  final FocusNode _focusNodeWhatsImMind = FocusNode();
  File? _attachment;

  @override
  void initState() {
    _currentUser = aGeneralBloc.currentUser;
    super.initState();
  }

  @override
  void dispose() {
    _txtWhatsImMind.dispose();
    _focusNodeWhatsImMind.dispose();
    _blocAddFeed.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _appConfig = AppConfig.of(context);
    return CustomScaffold(
      resizeToAvoidBottomInset: true,
      appBar: _getAppBar(),
      body: SafeArea(
        child: GestureDetector(
          onTap: () {
            _focusNodeWhatsImMind.unfocus();
          },
          child: Container(
            padding: EdgeInsets.zero,
            width: double.infinity,
            height: double.infinity,
            child: _mainContainerWidget(context),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: _widgetBottomView(context),
    );
  }

  PreferredSizeWidget _getAppBar() {
    return getMainAppBar(
      context,
      _appConfig!,
      backgoundColor: Colors.transparent,
      textColor: _appConfig!.whiteColor,
      title: NavigationBarConstants.createPost,
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
          }),
    );
  }

  Widget _mainContainerWidget(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsetsDirectional.fromSTEB(0, 16, 0, 0),
      child: Column(
        children: [
          _widgetCreatePost(),
          _widgetTextField(),
          _widgetAttechment(context),
        ],
      ),
    );
  }

  Widget _widgetCreatePost() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsetsDirectional.fromSTEB(24, 12, 24, 0),
      child: Row(
        children: <Widget>[
          CircularImage(
            _currentUser?.profilePhoto ?? '',
          ),
          const SizedBox(
            width: 16,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  _currentUser!.fullName!,
                  style: _appConfig!.calibriHeading4FontStyle
                      .apply(color: _appConfig!.whiteColor),
                ),
                const SizedBox(
                  height: 2,
                ),
                Text(
                  _currentUser!.username!,
                  style: _appConfig!.paragraphSmallFontStyle
                      .apply(color: _appConfig!.greyColor),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _widgetTextField() {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(24, 24, 24, 0),
      child: StreamBuilder<ErrorMessage>(
          stream: _blocAddFeed.getWhatsInMindErrorMessage,
          initialData: ErrorMessage(false, ''),
          builder:
              (BuildContext context, AsyncSnapshot<ErrorMessage> snapshot) {
            return CustomTextField(
              context: context,
              controller: _txtWhatsImMind,
              focussNode: _focusNodeWhatsImMind,
              bgColor: Colors.transparent,
              lableText: AppConstants.whatOnYourMind,
              inputType: TextInputType.text,
              capitalization: TextCapitalization.sentences,
              inputAction: TextInputAction.done,
              isAutocorrect: true,
              enableSuggestions: true,
              padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
              contentPadding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
              maxlength: 255,
              mainTextStyle: _appConfig!.paragraphLargeFontStyle
                  .apply(color: _appConfig!.whiteColor),
              onchange: (String value) {
                _blocAddFeed.onChangeWhatsInMind(value: value);
              },
              onSubmit: (String value) {
                _focusNodeWhatsImMind.unfocus();
              },
              errorText: snapshot.data!.errorMessage.isEmpty
                  ? null
                  : snapshot.data!.errorMessage,
            );
          }),
    );
  }

  Widget _widgetAttechment(BuildContext mainContext) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(24, 24, 24, 0),
      child: StreamBuilder<File?>(
        stream: _blocAddFeed.getPostAttachment,
        builder: (BuildContext context, AsyncSnapshot<File?> fileSnapshot) {
          print('FileSnapShot Before === $fileSnapshot');
          if (fileSnapshot.hasData) {
            print('FileSnapShot If === $fileSnapshot');
            _attachment = fileSnapshot.data;
          }
          return Container(
              width: double.infinity,
              height: (context.width - 48) * 0.64,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
              ),
              child: _attachment != null
                  ? _widgetAttachmentPhoto(mainContext)
                  : const SizedBox());
        },
      ),
    );
  }

  Widget _widgetAttachmentPhoto(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(4)),
            child: Image.file(
              _attachment!,
              fit: BoxFit.cover,
            ),
          ),
        ),
        _widgetDeleteButton(
          context: context,
        ),
      ],
    );
  }

  Widget _widgetDeleteButton({BuildContext? context}) {
    return Positioned(
      top: 8,
      right: 8,
      child: CircleButton(
        iconName: ImgConstants.close,
        backgroundColor: _appConfig!.borderColor,
        iconColor: _appConfig!.whiteColor,
        buttonSize: 32,
        iconSize: 16,
        radius: 4,
        onPressed: () {
          _attachment = null;
          _blocAddFeed.updateAttachement(value: _attachment);
        },
      ),
    );
  }

  Widget _widgetBottomView(BuildContext context) {
    double bottomSpace = MediaQuery.of(context).viewInsets.bottom;
    if (bottomSpace == 0.0) {
      bottomSpace = 10.0;
    }
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(24, 0, 24, 10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          _widgetAddImage(context),
          const SizedBox(
            height: 24,
          ),
          _btnPost(context),
        ],
      ),
    );
  }

  Widget _widgetAddImage(BuildContext mainContext) {
    return Align(
      alignment: Alignment.centerLeft,
      child: TextButton(
        onPressed: () {
          FocusScope.of(context).unfocus();
          showModalBottomSheet<void>(
              context: mainContext,
              builder: (BuildContext context) {
                return ImagePickerHelper(
                  //title: AppConstants.hintProfilePicture,
                  isCropped: true,
                  size: SizeConfig.kSquare400Size,
                  cropStyle: CropStyle.rectangle,
                  onDone: (File? file) {
                    if (file != null) {
                      _blocAddFeed.updateAttachement(value: file);
                    }
                  },
                );
              });
        },
        style: TextButton.styleFrom(
          padding: EdgeInsets.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            SvgIcon.asset(
              ImgConstants.camera,
              size: 20,
              color: _appConfig!.btnPrimaryColor,
            ),
            const SizedBox(
              width: 8,
            ),
            Text(
              AppConstants.addPhoto,
              style: _appConfig!.linkSmallFontStyle.apply(
                color: _appConfig!.btnPrimaryColor,
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _btnPost(BuildContext mainContext) {
    return StreamBuilder<bool>(
      stream: _blocAddFeed.validatePostForm,
      builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
        bool isValid = false;
        if (snapshot.hasData && snapshot.data != null) {
          isValid = snapshot.data!;
        }
        return StreamBuilder<bool>(
          stream: aGeneralBloc.getIsApiCalling,
          initialData: false,
          builder:
              (BuildContext context, AsyncSnapshot<bool> apiCallingSnapshot) {
            bool isLoading = false;
            if (apiCallingSnapshot.hasData && apiCallingSnapshot.data != null) {
              isLoading = apiCallingSnapshot.data!;
            }
            return LoaderButton(
                backgroundColor: _appConfig!.btnPrimaryColor,
                isEnabled: isValid,
                isLoading: isLoading,
                padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                onPressed: () async {
                  FocusScope.of(context).unfocus();
                  aGeneralBloc.updateAPICalling(true);
                  FireStoreProvider.instance.createPost(
                    context: context,
                    userData: _currentUser,
                    postType: PostType.general,
                    attachment: _attachment,
                    postTitle: _txtWhatsImMind.text.trim(),
                    onSuccess: (Map<String, dynamic> success) {
                      aGeneralBloc.updateAPICalling(false);
                      Navigator.pop(context, true);
                    },
                    onError: (Map<String, dynamic> success) {
                      aGeneralBloc.updateAPICalling(false);
                    },
                  );
                },
                title: AppConstants.post);
          },
        );
      },
    );
  }
}
