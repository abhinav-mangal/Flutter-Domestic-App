import 'package:energym/app_config.dart';
import 'package:energym/utils/common/base_bloc.dart';
import 'package:flutter/material.dart';
import 'package:energym/utils/common/constants.dart';
import 'package:energym/utils/common/svg_icon.dart';

/// Based on [BackButton]
class AppBackButton extends StatelessWidget {
  const AppBackButton({Key? key, this.color, this.onPressed, this.backIcon})
      : super(key: key);
  final Color? color;
  final VoidCallback? onPressed;
  final String? backIcon;

  @override
  Widget build(BuildContext context) {
    final AppConfig _config = AppConfig.of(context);
    assert(debugCheckHasMaterialLocalizations(context));

    return IconButton(
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
      iconSize: 20,
      icon: SvgIcon.asset(
        backIcon ?? ImgConstants.backArrow,
        color: color ?? _config.whiteColor,
      ),
      //color: color,
      tooltip: MaterialLocalizations.of(context).backButtonTooltip,
      onPressed: () {
        aGeneralBloc.updateAPICalling(false);
        if (onPressed != null) {
          onPressed!();
        } else {
          Navigator.maybePop(context);
        }
      },
    );

    // return Container(
    //   child: IconButton(
    //     iconSize: 10,
    //     icon: SvgPicture.asset(
    //       ImgConstants.appBarBackArrow,
    //       color: AppColors.textColorWhite,
    //     ),
    //     color: color,
    //     tooltip: MaterialLocalizations.of(context).backButtonTooltip,
    //     onPressed: () {
    //       if (onPressed != null) {
    //         onPressed();
    //       } else {
    //         Navigator.maybePop(context);
    //       }
    //     },
    //   ),
    // );
  }
}

// /// Based on [BackButton]
// class AppCircleBackButton extends StatelessWidget {
//   final Color color;
//   final VoidCallback onPressed;

//   const AppCircleBackButton({Key key, this.color, this.onPressed})
//       : super(key: key);

//   @override
//   Widget build(BuildContext context) {

//     return CircleButton(
//       iconName: ImageFileName.appBarBackArrow,
//       iconColor: color ?? config.textColorBlack,
//       iconSize: 22,
//       onPressed: () {
//         if (onPressed != null) {
//           onPressed();
//         } else {
//           Navigator.pop(context);
//         }
//       },
//     );
//   }
// }
