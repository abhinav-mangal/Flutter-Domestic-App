import 'package:energym/utils/extensions/extension.dart';
import 'package:flutter/material.dart';

import 'package:flutter/services.dart';
import 'package:flutter_html/style.dart';

import '../app_config.dart';
import '../utils/common/back_button.dart';
import '../utils/common/constants.dart';

AppBar getMainAppBar(BuildContext context, AppConfig config,
    {VoidCallback? onBack,
    String? title,
    TextStyle? titleStyle,
    Widget? widget,
    Widget? leadingWidget,
    List<Widget>? actions,
    double? elevation,
    bool? isBackEnable = true,
    String? backIcon = ImgConstants.backArrow,
    bool? centerTitle = true,
    Color? backgoundColor,
    Color? textColor,
    Gradient? gradient,
    double? radiusValue = 0}) {
  assert(context != null);

  TextStyle textStyle = context.theme.textTheme.headline4!
      .apply(color: textColor ?? Colors.white);

  if (titleStyle != null) {
    textStyle = titleStyle;
  }

  // ignore: parameter_assignments
  isBackEnable ??= ModalRoute.of(context)!.canPop;

  return AppBar(
    automaticallyImplyLeading: false,
    leading: isBackEnable
        ? AppBackButton(
            onPressed: onBack!,
            color: textColor!,
            backIcon: backIcon!,
          )
        : leadingWidget,
    centerTitle: centerTitle,
    backgroundColor: backgoundColor ?? context.theme.accentColor,
    title: title != null ? Text(title, style: textStyle) : widget,
    actions: actions,
    elevation: gradient != null ? 0 : elevation,
    flexibleSpace: gradient != null
        ? Container(
            decoration: BoxDecoration(
              color: Colors.white,
              gradient: gradient,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(radiusValue!),
                bottomRight: Radius.circular(radiusValue),
              ),
            ),
          )
        : const SizedBox(),
  );
}
