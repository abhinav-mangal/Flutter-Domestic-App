import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lottie/lottie.dart';

import '../app_config.dart';
import '../utils/common/constants.dart';
import '../utils/common/svg_picture_customise.dart';

class NODataWidget extends StatelessWidget {
  NODataWidget({
    Key? key,
    this.icon = ImgConstants.nodata,
    this.messge,
    this.messgeStyle,
    this.isShowMsgAtBottom = true,
    this.isLottieAnimation = false,
  }) : super(key: key);
  final String? icon;
  final String? messge;
  final TextStyle? messgeStyle;
  final bool? isShowMsgAtBottom;
  final bool? isLottieAnimation;

  @override
  Widget build(BuildContext context) {
    AppConfig _appConfig = AppConfig.of(context);
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        //mainAxisSize: MainAxisSize.min,
        children: [
          if (!isShowMsgAtBottom!) _widgetMessage(context, _appConfig),
          _icon(context, _appConfig),
          if (isShowMsgAtBottom!) _widgetMessage(context, _appConfig),
        ],
      ),
    );
  }

  Widget _widgetMessage(BuildContext context, AppConfig appConfig) {
    return Text(
      messge ?? AppConstants.noData,
      style: messgeStyle ??
          appConfig.calibriHeading2FontStyle.apply(color: appConfig.whiteColor),
      textAlign: TextAlign.center,
    );
  }

  Widget _icon(BuildContext context, AppConfig _appConfig) {
    if (isLottieAnimation!) {
      return Lottie.asset(
        icon!,
        fit: BoxFit.cover,
      );
    } else {
      if (icon!.contains('.png')) {
        return Container(
          padding: const EdgeInsetsDirectional.fromSTEB(0, 20, 0, 20),
          width: 150,
          height: 150,
          child: Image.asset(
            icon ?? ImgConstants.imagePlaceholder,
            width: 150,
            height: 150,
            fit: BoxFit.fill,
          ),
        );
      } else {
        return Container(
          padding: const EdgeInsetsDirectional.fromSTEB(0, 20, 0, 20),
          width: 150,
          height: 150,
          child: SvgPictureRecolor.asset(
            icon ?? ImgConstants.nodata,
            width: 150,
            height: 150,
            boxfix: BoxFit.fill,
            replacements: {
              '#6c63ff': _appConfig.btnPrimaryColor,
            },
          ),
        );
      }
    }
  }
}
