import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:energym/utils/extensions/extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import 'package:lottie/lottie.dart';

import '../app_config.dart';
import '../utils/common/constants.dart';
import '../utils/theme/colors.dart';

class LoaderButton extends StatelessWidget {
  final Function? onPressed;
  final String? title;
  final Color? titleColor;
  final TextStyle? titleStyle;
  final Widget? leadingIcon;
  final bool? isEnabled;
  final Color? backgroundColor;
  final double? buttonHeight;
  final bool? isLoading;
  final EdgeInsetsDirectional? padding;
  final bool? isOutLine;
  final Color? outLineColor;
  final double? leadingIconSpace;
  final double? radius;
  final bool isAGradientShadow;
  const LoaderButton(
      {this.onPressed,
      this.title,
      this.titleColor,
      this.titleStyle,
      this.leadingIcon,
      this.backgroundColor,
      this.isEnabled = true,
      this.isLoading = false,
      this.buttonHeight = 46.0, //56.0,
      this.padding,
      this.isOutLine = false,
      this.outLineColor,
      this.leadingIconSpace = 12,
      this.radius,
      this.isAGradientShadow = false});

  @override
  Widget build(BuildContext context) {
    final Color filterColor = context.theme.brightness == Brightness.dark
        ? Colors.black
        : Colors.white;

    AppConfig _config = AppConfig.of(context);
    return Container(
      padding:
          this.padding ?? const EdgeInsetsDirectional.fromSTEB(24, 0, 24, 0),
      height: buttonHeight,
      width: double.infinity,
      child: Stack(
        alignment: Alignment.center,
        children: [
          _flatButton(_config, isAGradientShadow),
        ],
      ),
    );
  }

  Widget _flatButton(AppConfig config, bool isAGradientShadow) {
    Color buttonColor = Colors.transparent;
    if (!isOutLine!) {
      buttonColor = (outLineColor == null) ? config.greyColor : outLineColor!;
      if (isEnabled!) {
        buttonColor = backgroundColor ?? config.btnPrimaryColor;
      }
    }

    return TextButton(
      onPressed: () {
        if (isEnabled! && !isLoading!) {
          onPressed!();
        }
      },
      style: TextButton.styleFrom(
        backgroundColor: buttonColor,
        minimumSize: Size(double.infinity, double.infinity),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius ?? 4.0),
          side: isOutLine!
              ? BorderSide(
                  color: (outLineColor == null)
                      ? config.borderColor
                      : outLineColor!,
                  width: isOutLine! ? 0 : 0,
                )
              : BorderSide.none,
        ),
      ),
      child: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: isAGradientShadow ? decoration() : null,
        child: Center(
          child: isLoading!
              ? Lottie.asset(LottieConstants.loader)
              // ? WavyAnimatedTextKit(
              //     speed: Duration(milliseconds: 200),
              //     //gradient: AppColors.gradintBtnSignUp,
              //     textStyle: titleStyle ??
              //         config.linkNormalFontStyle
              //             .apply(color: titleColor ?? config.whiteColor),
              //     text: [
              //       "Loading...",
              //     ],
              //     isRepeatingAnimation: true,
              //   )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (this.leadingIcon != null) ...[
                      leadingIcon!,
                      SizedBox(
                        width: leadingIconSpace,
                      ),
                    ],
                    Text(
                      title!,
                      style: titleStyle ??
                          config.linkNormalFontStyle
                              .apply(color: titleColor ?? config.whiteColor),
                    )
                  ],
                ),
        ),
      ),
    );
  }

  BoxDecoration? decoration() {
    return BoxDecoration(
      borderRadius: BorderRadius.all(Radius.circular(12)),
      gradient: LinearGradient(
        colors: [AppColors.greenColor1, AppColors.greenColor2],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        stops: [0.0, 1],
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.white24,
          blurRadius: 2,
          offset: const Offset(1, 1),
          spreadRadius: 1,
        ),
      ],
    );
  }
}

/*
return ButtonTheme(
      height: buttonHeight,
      child: FlatButton(
        padding: EdgeInsets.all(0),
        shape: RoundedRectangleBorder(
          borderRadius: borderRadius,
        ),
        color: buttonColor,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        disabledColor: buttonColor,
        onPressed: isEnabled
            ? () {
                if (onPressed != null) {
                  onPressed();
                }
              }
            : null,
        child: ClipRRect(
          borderRadius: borderRadius,
          child: Stack(children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 18),
              width: double.infinity,
              height: buttonHeight,
              child: Row(
                mainAxisAlignment: trailing == null
                    ? MainAxisAlignment.center
                    : MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: [
                  title,
                  if (trailing != null) trailing,
                ],
              ),
            ),
            if (!isEnabled)
              Container(
                width: double.infinity,
                height: buttonHeight,
                color: filterColor.withOpacity(0.5),
              )
          ]),
        ),
      ),
    );
*/

class UnicornOutlineButton extends StatelessWidget {
  final _GradientPainter _painter;
  final Widget _child;
  final VoidCallback _callback;
  final double _radius;
  final double _btnHeight;

  UnicornOutlineButton({
    @required double? strokeWidth,
    @required double? radius,
    @required double? btnHeight,
    @required Gradient? gradient,
    @required Widget? child,
    @required VoidCallback? onPressed,
  })  : this._painter = _GradientPainter(
            strokeWidth: strokeWidth!, radius: radius!, gradient: gradient!),
        this._child = child!,
        this._callback = onPressed!,
        this._radius = radius,
        this._btnHeight = btnHeight!;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
      height: _btnHeight,
      width: double.infinity,
      child: CustomPaint(
        painter: _painter,
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: _callback,
          child: InkWell(
            borderRadius: BorderRadius.circular(_radius),
            onTap: _callback,
            child: Container(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  _child,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GradientPainter extends CustomPainter {
  final Paint _paint = Paint();
  final double radius;
  final double strokeWidth;
  final Gradient gradient;

  _GradientPainter(
      {@required double? strokeWidth,
      @required double? radius,
      @required Gradient? gradient})
      : this.strokeWidth = strokeWidth!,
        this.radius = radius!,
        this.gradient = gradient!;

  @override
  void paint(Canvas canvas, Size size) {
    // create outer rectangle equals size
    Rect outerRect = Offset.zero & size;
    var outerRRect =
        RRect.fromRectAndRadius(outerRect, Radius.circular(radius));

    // create inner rectangle smaller by strokeWidth
    Rect innerRect = Rect.fromLTWH(strokeWidth, strokeWidth,
        size.width - strokeWidth * 2, size.height - strokeWidth * 2);
    var innerRRect = RRect.fromRectAndRadius(
        innerRect, Radius.circular(radius - strokeWidth));

    // apply gradient shader
    _paint.shader = gradient.createShader(outerRect);

    // create difference between outer and inner paths and draw it
    Path path1 = Path()..addRRect(outerRRect);
    Path path2 = Path()..addRRect(innerRRect);
    var path = Path.combine(PathOperation.difference, path1, path2);
    canvas.drawPath(path, _paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => oldDelegate != this;
}
