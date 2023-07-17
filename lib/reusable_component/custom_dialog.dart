import 'package:auto_size_text/auto_size_text.dart';
import 'package:energym/utils/extensions/extension.dart';

import 'package:flutter/material.dart';

import 'package:flutter_svg/svg.dart';

import 'package:lottie/lottie.dart';

import '../app_config.dart';
import '../utils/common/base_bloc.dart';
import '../utils/common/constants.dart';
import '../utils/theme/colors.dart';
import 'loader_button.dart';

class AppDialog extends StatelessWidget {
  final String? title;
  final String? message;
  final String? okButtonTitle;
  final String? cancelButtonTitle;
  final bool? showCloseButton;
  final Function? onSuccess;

  const AppDialog({
    Key? key,
    this.title,
    this.message,
    this.okButtonTitle,
    this.cancelButtonTitle,
    this.onSuccess,
    this.showCloseButton = false,
  }) : super(key: key);

  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        side: BorderSide(color: context.theme.accentColor, width: 1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Stack(
        children: [
          if (showCloseButton!)
            Positioned(
              top: 0,
              right: 0,
              child: IconButton(
                iconSize: 18,
                onPressed: () {
                  Navigator.pop(context);
                },
                tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                color: context.theme.accentColor,
                icon: SvgPicture.asset(ImgConstants.backArrow),
              ),
            ),
          Container(
            padding: showCloseButton!
                ? const EdgeInsets.all(24).copyWith(top: 44)
                : const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title!,
                  style:
                      context.theme.textTheme.bodyText1!.copyWith(fontSize: 20),
                  textAlign: TextAlign.center,
                ),
                if (message != null) ...[
                  SizedBox(height: 14),
                  Text(
                    message!,
                    style: context.theme.textTheme.bodyText1,
                    textAlign: TextAlign.center,
                  ),
                ],
                SizedBox(height: 20),
                /*AppPrimaryButton(
                  title: okButtonTitle,
                  onPressed: () {
                    Navigator.pop(context);
                    if (onSuccess != null) {
                      onSuccess();
                    }
                  },
                ),*/
                if (cancelButtonTitle != null) ...[
                  SizedBox(height: 12),
                  // AppSecondaryButton(
                  //   title: cancelButtonTitle,
                  //   onPressed: () {
                  //     Navigator.pop(context);
                  //   },
                  // ),
                ]
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CustomAlertDialog {
  const CustomAlertDialog();

  Future<void> showAlert({
    required BuildContext context,
    String? title,
    Widget? imageFile,
    String? message,
    String? okButtonTitle,
    Color? okButtonColor,
    Gradient? gradiant,
    Function? onSuccess,
  }) async {
    showDialog(
      barrierDismissible: false,
      barrierColor: AppColors.secondDarkColor.withOpacity(0.8),
      context: context,
      builder: (BuildContext context) {
        AppConfig _config = AppConfig.of(context);
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Container(
            padding: EdgeInsets.fromLTRB(20, 20, 20, 20),
            decoration: BoxDecoration(
              color: AppColors.backgroundColor,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (title != null)
                  Text(
                    title,
                    style: _config.calibriHeading2FontStyle
                        .apply(color: _config.blackColor),
                    textAlign: TextAlign.center,
                  ),
                if (imageFile != null)
                  Container(
                    padding: EdgeInsets.fromLTRB(0, 14, 0, 0),
                    child: imageFile,
                  ),
                if (message != null)
                  Container(
                    padding: EdgeInsets.fromLTRB(0, 14, 0, 0),
                    child: AutoSizeText(
                      message,
                      textAlign: TextAlign.center,
                      style: _config.paragraphNormalFontStyle
                          .apply(color: _config.blackColor),
                    ),
                  ),
                const SizedBox(
                  height: 20,
                ),
                LoaderButton(
                    backgroundColor: okButtonColor ?? _config.btnPrimaryColor,
                    padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                    buttonHeight: 46.0,
                    onPressed: () async {
                      Navigator.pop(context);
                      if (onSuccess != null) {
                        onSuccess();
                      }
                    },
                    title: okButtonTitle ?? AppConstants.ok)
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> showErrorMessage(
      {BuildContext? context,
      String? tital,
      TextStyle? titalStyle,
      String? message,
      //TextStyle messageStyle,
      String? buttonTitle,
      Widget? errorIcon,
      Function? onClose,
      Function? onPress}) async {
    showDialog(
      barrierDismissible: false,
      context: context!,
      builder: (BuildContext context) {
        AppConfig _config = AppConfig.of(context);
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
          child: Container(
            //width: MediaQuery.of(context).size.width * 0.9,
            //height: MediaQuery.of(context).size.height * 0.34,
            padding: EdgeInsets.fromLTRB(20, 20, 20, 20),
            decoration: BoxDecoration(
                color: AppColors.hintColor,
                borderRadius: BorderRadius.circular(10)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (onPress != null)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        height: 24,
                        width: 24,
                        child: IconButton(
                          padding: EdgeInsets.all(0),
                          iconSize: 20,
                          icon: SvgPicture.asset(
                            ImgConstants.backArrow,
                          ),
                          color: AppColors.hintColor,
                          tooltip: MaterialLocalizations.of(context)
                              .backButtonTooltip,
                          onPressed: () {
                            Navigator.pop(context);
                            if (onClose != null) {
                              onClose();
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                SizedBox(height: 15),
                Text(
                  tital!,
                  style: titalStyle != null
                      ? titalStyle
                      : context.theme.textTheme.subtitle1!
                          .apply(color: AppColors.textColorBlack),
                  textAlign: TextAlign.center,
                ),
                if (errorIcon != null)
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.fromLTRB(0, 18, 0, 0),
                      child: errorIcon,
                    ),
                  ),
                if (message != null && message.isNotEmpty)
                  Container(
                    padding: EdgeInsets.fromLTRB(0, 18, 0, 10),
                    child: AutoSizeText(
                      message,
                      minFontSize: 5,
                      textAlign: TextAlign.center,
                      style: context.theme.textTheme.subtitle2!
                          .apply(color: AppColors.textColorBlack),
                    ),
                  ),
                MaterialButton(
                  padding: EdgeInsetsDirectional.fromSTEB(0, 8, 0, 0),
                  onPressed: () {
                    Navigator.pop(context);
                    if (onPress != null) {
                      onPress();
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.zero,
                    width: double.infinity,
                    height: 48,
                    decoration: BoxDecoration(
                        color: _config.btnPrimaryColor,
                        border: Border.all(
                          color: _config.btnPrimaryColor,
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(10)),
                    child: Center(
                      child: Text(
                        buttonTitle!,
                        style: _config.linkNormalFontStyle
                            .apply(color: _config.whiteColor),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> showExeptionErrorMessage(
      {BuildContext? context,
      String? title,
      TextStyle? titalStyle,
      String? message,
      TextStyle? messageStyle,
      String? buttonTitle,
      Widget? errorIcon,
      Function? onPress}) async {
    showDialog(
      barrierDismissible: false,
      context: context!,
      builder: (BuildContext context) {
        AppConfig _config = AppConfig.of(context);
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.8,
            //height: MediaQuery.of(context).size.height * 0.34,
            padding: EdgeInsets.fromLTRB(20, 20, 20, 20),
            decoration: BoxDecoration(
                color: _config.borderColor,
                borderRadius: BorderRadius.circular(10)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (title != null && title.isNotEmpty)
                  Container(
                    padding: EdgeInsets.fromLTRB(0, 18, 0, 0),
                    child: Text(
                      title,
                      style: titalStyle != null
                          ? titalStyle
                          : _config.calibriHeading2FontStyle
                              .apply(color: _config.whiteColor),
                      textAlign: TextAlign.center,
                    ),
                  ),
                if (errorIcon != null)
                  Container(
                    padding: EdgeInsets.fromLTRB(0, 18, 0, 10),
                    child: errorIcon,
                  ),
                if (message != null && message.isNotEmpty)
                  Container(
                    padding: EdgeInsets.fromLTRB(0, 18, 0, 10),
                    child: Text(
                      message,
                      textAlign: TextAlign.center,
                      style: messageStyle != null
                          ? messageStyle
                          : _config.calibriHeading4FontStyle
                              .apply(color: _config.whiteColor),
                    ),
                  ),
                SizedBox(
                  height: 20,
                ),
                MaterialButton(
                  padding: EdgeInsets.all(0),
                  onPressed: () {
                    Navigator.pop(context);
                    if (onPress != null) {
                      onPress();
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.zero,
                    width: double.infinity,
                    height: 48,
                    decoration: BoxDecoration(
                        color: _config.btnPrimaryColor,
                        border: Border.all(
                          color: _config.btnPrimaryColor,
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(10)),
                    child: Center(
                      child: Text(
                        buttonTitle!,
                        style: _config.linkNormalFontStyle
                            .apply(color: _config.whiteColor),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> showSuccessMessage(
      {BuildContext? context,
      String? title,
      TextStyle? titalStyle,
      String? message,
      TextStyle? messageStyle,
      String? buttonTitle,
      Widget? successIcon,
      Function? onPress}) async {
    showDialog(
      barrierDismissible: false,
      context: context!,
      builder: (BuildContext context) {
        AppConfig _config = AppConfig.of(context);
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.8,
            //height: MediaQuery.of(context).size.height * 0.34,
            padding: EdgeInsets.fromLTRB(20, 20, 20, 20),
            decoration: BoxDecoration(
                color: AppColors.hintColor,
                borderRadius: BorderRadius.circular(10)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (successIcon != null)
                  Container(
                    padding: EdgeInsets.fromLTRB(0, 18, 0, 10),
                    child: successIcon,
                  ),
                if (title != null && title.isNotEmpty)
                  Text(
                    title,
                    style: titalStyle != null
                        ? titalStyle
                        : context.theme.textTheme.headline5!.apply(
                            color: AppColors.textColorGrey,
                            fontWeightDelta: -2),
                    textAlign: TextAlign.center,
                  ),
                if (message != null && message.isNotEmpty)
                  Container(
                    padding: EdgeInsets.fromLTRB(0, 18, 0, 10),
                    child: Text(
                      message,
                      textAlign: TextAlign.center,
                      style: messageStyle != null
                          ? messageStyle
                          : context.theme.textTheme.headline5!.apply(
                              color: AppColors.textColorGrey,
                              fontWeightDelta: -2),
                    ),
                  ),
                SizedBox(
                  height: 20,
                ),
                MaterialButton(
                  padding: EdgeInsets.all(0),
                  onPressed: () {
                    Navigator.pop(context);
                    if (onPress != null) {
                      onPress();
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.zero,
                    width: double.infinity,
                    height: 48,
                    decoration: BoxDecoration(
                        color: context.theme.accentColor,
                        border: Border.all(
                          color: context.theme.accentColor,
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(10)),
                    child: Center(
                      child: Text(
                        buttonTitle!,
                        style: _config.linkNormalFontStyle
                            .apply(color: _config.whiteColor),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> confirmationDialog({
    BuildContext? context,
    String? title,
    Widget? imageFile,
    String? message,
    String? okButtonTitle,
    Color? okButtonBgColor,
    String? cancelButtonTitle,
    Function? onSuccess,
  }) async {
    showDialog(
      barrierDismissible: false,
      context: context!,
      builder: (BuildContext context) {
        AppConfig _config = AppConfig.of(context);
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Container(
            //width: MediaQuery.of(context).size.width * 0.8,
            //height: MediaQuery.of(context).size.height * 0.34,
            padding: EdgeInsets.fromLTRB(20, 20, 20, 20),
            decoration: BoxDecoration(
                color: AppColors.hintColor,
                borderRadius: BorderRadius.circular(10)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (title != null)
                  Text(
                    title,
                    style: _config.calibriHeading2FontStyle
                        .apply(color: _config.blackColor),
                    textAlign: TextAlign.center,
                  ),
                if (imageFile != null)
                  Container(
                    padding: EdgeInsets.fromLTRB(0, 14, 0, 0),
                    child: imageFile,
                  ),
                if (message != null)
                  Container(
                    padding: EdgeInsets.fromLTRB(0, 14, 0, 0),
                    child: AutoSizeText(
                      message,
                      textAlign: TextAlign.center,
                      style: _config.paragraphNormalFontStyle
                          .apply(color: _config.blackColor),
                    ),
                  ),
                const SizedBox(
                  height: 20,
                ),
                StreamBuilder<bool>(
                  stream: aGeneralBloc.getIsApiCalling,
                  initialData: false,
                  builder: (BuildContext context,
                      AsyncSnapshot<bool> apiCallingSnapshot) {
                    bool isLoading = false;
                    if (apiCallingSnapshot.hasData &&
                        apiCallingSnapshot.data != null) {
                      isLoading = apiCallingSnapshot.data!;
                    }
                    return LoaderButton(
                        backgroundColor: okButtonBgColor ?? Colors.red,
                        isLoading: isLoading,
                        padding:
                            const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                        buttonHeight: 46.0,
                        onPressed: () async {
                          if (onSuccess != null) {
                            //print('onSuccess >>> $onSuccess');
                            onSuccess();
                          } else {
                            //print('onSuccess is null >>> $onSuccess');
                            Navigator.pop(context);
                          }
                        },
                        title: okButtonTitle!);
                  },
                ),
                const SizedBox(
                  height: 16,
                ),
                LoaderButton(
                    backgroundColor: Colors.transparent,
                    titleColor: _config.greyColor,
                    isOutLine: true,
                    padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                    onPressed: () async {
                      aGeneralBloc.updateAPICalling(false);
                      Navigator.pop(context);
                    },
                    title: cancelButtonTitle!),
                const SizedBox(
                  height: 8,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
