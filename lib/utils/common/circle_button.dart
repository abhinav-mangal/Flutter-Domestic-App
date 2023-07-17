import 'package:energym/utils/common/svg_icon.dart';
import 'package:energym/utils/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:energym/utils/extensions/extension.dart';

class CircleButton extends StatelessWidget {
  const CircleButton({
    Key? key,
    this.onPressed,
    this.onLongPressed,
    @required this.iconName,
    this.iconColor,
    this.backgroundColor,
    this.buttonSize = 40,
    this.iconSize = 24,
    this.isLoading = false,
    this.radius,
    this.borderColor = Colors.transparent,
    this.padding,
    this.isBorderd = true,
  }) : super(key: key);

  final String? iconName;
  final Color? iconColor;
  final Color? backgroundColor;
  final double? buttonSize;
  final double? iconSize;
  final double? radius;
  final VoidCallback? onPressed;
  final VoidCallback? onLongPressed;
  final bool? isLoading;
  final Color? borderColor;
  final EdgeInsetsGeometry? padding;
  final bool? isBorderd;
  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasMaterialLocalizations(context));

    return ButtonTheme(
      minWidth: buttonSize!,
      height: buttonSize!,
      padding: EdgeInsetsDirectional.zero,
      child: TextButton(
        style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(radius ?? (buttonSize! / 2)),
              side: isBorderd! ? BorderSide(
                color: borderColor ?? AppColors.textColorGrey.withOpacity(0.20),
              ) : BorderSide.none,
            ),
            backgroundColor:
                backgroundColor ?? AppColors.textColorGrey.withOpacity(0.20),
            minimumSize: Size(buttonSize!, buttonSize!)),
        onPressed: onPressed,
        onLongPress: onLongPressed,
        child: Container(
          constraints: BoxConstraints.tight(Size.square(buttonSize!)),
          child: Center(
            child: isLoading! ? _loadingIcon(context) : _icon(),
          ),
        ),
      ),
    );
  }

  Widget _icon() {
    if (iconName!.endsWith('.svg')) {
      return Padding(
        padding: padding ?? const EdgeInsets.all(0.0),
        child: SvgIcon.asset(
          iconName,
          size: iconSize,
          color: iconColor,
        ),
      );
    } else {
      return Container(
        padding: padding ?? const EdgeInsets.all(0.0),
        width: iconSize,
        height: iconSize,
        child: Image.asset(
          iconName!,
          fit: BoxFit.contain,
        ),
      );
    }
  }

  Widget _loadingIcon(BuildContext context) {
    return SpinKitCircle(
      color: iconColor,
      size: iconSize!,
    );
  }
}
