import 'package:energym/app_config.dart';
import 'package:flutter/material.dart';
import 'package:energym/utils/common/back_button.dart';
import 'package:energym/utils/extensions/extension.dart';

AppBar getMainAppBar(
  BuildContext? context, 
  AppConfig? appConfig,
  {
  VoidCallback? onBack,
  String? title,
  Widget? widget,
  Widget? leadingWidget,
  List<Widget>? actions,
  double? elevation,
  bool? isBackEnable = true,
  bool? centerTitle = true,
  Color? backgoundColor,
  Color? textColor,
}) {
  assert(context != null);

  final TextStyle textStyle = appConfig!.calibriHeading3FontStyle
      .apply(color: textColor ?? context!.theme.accentColor);

  // ignore: parameter_assignments
  isBackEnable ??= ModalRoute.of(context!)!.canPop;

  return AppBar(
    automaticallyImplyLeading: false,
    leading: isBackEnable
        ? AppBackButton(
            onPressed: onBack,
            color: textColor,
          )
        : leadingWidget ,
    centerTitle: centerTitle,
    backgroundColor: backgoundColor ?? context!.theme.accentColor,
    title: title != null
        ? Text(title, style: textStyle)
        : widget,
    actions: actions,
    elevation: elevation,
  );
}
