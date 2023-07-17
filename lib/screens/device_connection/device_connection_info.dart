import 'package:energym/app_config.dart';
import 'package:energym/reusable_component/circular_image.dart';
import 'package:flutter/material.dart';

class DeviceConnectionInfo extends StatelessWidget {
  final String?image;
  final String? title;
  final String? message;
  final bool? showSkip;
  final bool? showDone;

  DeviceConnectionInfo(
      {Key? key,
      this.image,
      this.title,
      this.message,
      this.showSkip,
      this.showDone})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    AppConfig config = AppConfig.of(context);
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          if (title != null)
            Container(
              padding: const EdgeInsetsDirectional.fromSTEB(24, 0, 24, 60),
              child: Text(
                title!,
                style: config.calibriHeading2FontStyle.apply(
                  color: config.whiteColor,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          if (image != null)
            Container(
                width: 220,
                height: 220,
                padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                child: Center(
                  child: Image.asset(
                      image!,
                    ),
                ),
              ),
          if (message != null)
            Expanded(
                          child: Container(
                padding: const EdgeInsetsDirectional.fromSTEB(24, 60, 24, 60),
                child: Text(
                  message!,
                  style: config.paragraphNormalFontStyle.apply(
                    color: config.greyColor,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
