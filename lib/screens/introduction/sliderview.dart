import 'package:energym/app_config.dart';
import 'package:energym/utils/common/svg_picture_customise.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SliderView extends StatelessWidget {
  final String? image;
  final String? title;
  final bool? showSkip;
  final bool? showDone;

  SliderView({Key? key, this.image, this.title, this.showSkip, this.showDone})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    AppConfig config = AppConfig.of(context);
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            padding: const EdgeInsetsDirectional.fromSTEB(32, 0, 32, 0),
            child: Text(
              title!,
              style: config.calibriHeading2FontStyle.apply(
                color: config.whiteColor,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: Container(
              width: double.infinity,
              height: double.infinity,
              padding: const EdgeInsetsDirectional.fromSTEB(0, 44, 0, 24),
              child: Center(
                child: Image.asset(
                  image!,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
