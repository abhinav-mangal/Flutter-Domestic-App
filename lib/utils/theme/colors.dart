import 'package:flutter/material.dart';

class AppColors {
  static Color get mainColor => const Color(0xFF1B2850);
  static Color get secondColor => const Color(0xFFFFFFFF);
  static Color get accentColor => const Color(0xFF1B2850);
  static Color get mainDarkColor => const Color(0xFF000000);
  static Color get secondDarkColor => const Color(0xFF000000);
  static Color get accentDarkColor => const Color(0xFF000000);
  static Color get backgroundColor => const Color(0xFFFFFFFF);
  
  //Done
  static Color get greenColor => const Color(0xFF5FAA2D);
  //Done
  static Color get textColorBlue => const Color(0xFF1B2850);
  //Done
  static Color get textColorWhite => const Color(0xFFFFFFFF);
  //Done
  static Color get textColorBlack => const Color(0xFF1F2326);
  //Done
  static Color get textColorGrey => const Color(0xFFA5A6B6);
  //Done
  static Color get textColorDarkBlue => const Color(0xFF472EB3);
  
  static Color get textColorLightBlue => const Color(0xFFB9AEEA);
  //Done
  static Color get borderColors => const Color(0xFFA5A6B6);
  
  //Done
  static Color get btnSignInOne => const Color(0xFF452DB3);
  static Color get btnSignInTwo => const Color(0xFFBE68D4);

  //Done
  static Gradient get gradintBtnSignIn =>  LinearGradient(
              begin: Alignment.bottomLeft,
              end: Alignment.topRight,
              colors: [AppColors.btnSignInOne, AppColors.btnSignInTwo]);

  //Done
  static Color get greenGradiantOne => const Color(0xFF5FAA2D);
  static Color get greenGradiantTwo => const Color(0xFF95D444);

  //Done
  static Gradient get gradintGreen =>  LinearGradient(
              begin: Alignment.bottomLeft,
              end: Alignment.topRight,
              colors: [AppColors.greenGradiantOne, AppColors.greenGradiantTwo]);

  //Done
  static Color get blueGradiantOne => const Color(0xFF4C88EF);
  static Color get blueGradiantTwo => const Color(0xFF8FCE94);

  //Done
  static Gradient get gradintOutLineBlue =>  LinearGradient(
              begin: Alignment.bottomLeft,
              end: Alignment.topRight,
              colors: [AppColors.blueGradiantOne, AppColors.blueGradiantTwo]);

  
  //Done
  static Gradient get gradintBlue =>  LinearGradient(
              begin: Alignment.bottomLeft,
              end: Alignment.topRight,
              colors: [AppColors.blueGradiantOne, AppColors.blueGradiantTwo]);


  //Done
  static Color get orangeGradiantOne => const Color(0xFFF77523);
  static Color get orangeGradiantTwo => const Color(0xFFF9C655);

  //Done
  static Gradient get gradintOrange =>  LinearGradient(
              begin: Alignment.bottomLeft,
              end: Alignment.topRight,
              colors: [AppColors.orangeGradiantOne, AppColors.orangeGradiantTwo]);

  //Done
  static Color get redGradiantOne => const Color(0xFF9F031B);
  static Color get redGradiantTwo => const Color(0xFFF5515F);

  //Done
  static Gradient get gradintRed =>  LinearGradient(
              begin: Alignment.bottomLeft,
              end: Alignment.topRight,
              colors: [AppColors.redGradiantOne, AppColors.redGradiantTwo]);

  //Done
  static Color get bluePurpelGradiantOne => const Color(0xFF00EAF8);
  static Color get bluePurpelGradiantTwo => const Color(0xFF6D42EF);

  //Done
  static Gradient get gradintBluePurpel =>  LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.bluePurpelGradiantOne, AppColors.bluePurpelGradiantTwo]);

  static Color get hintColor => const Color(0xFFf3f3f3);
  // static Color get skeletonBackgroundColor => const Color(0xffdddddd);
  // static Color get skeletonShimmerColor => Colors.white54;
  // static Color get skeletonGradientColor =>
  //     skeletonBackgroundColor.withOpacity(0);

  static Color get darkRed => const Color(0xFFFB2343);
  static Color get darkGreen => const Color(0xFF47B872);
  static Color get offWhite => const Color(0xFFF7F7F7);

  //Done
  static Color get pinkGradiantOne => const Color(0xFFC11999);
  static Color get pinlGradiantTwo => const Color(0xFFFF02F6
);

  //Done
  static Gradient get gradintPink =>  LinearGradient(
              begin: Alignment.bottomLeft,
              end: Alignment.topRight,
              colors: [AppColors.pinkGradiantOne, AppColors.pinlGradiantTwo]);

static Color get pink => const Color(0xFFBC1DD9);
static Color get blue => const Color(0xFF1C3AA7);

//Done
  static Color get blackGradiantOne => const Color(0xFF6A6864);
  static Color get blackGradiantTwo => const Color(0xFF28231F);

  //Done
  static Gradient get gradintBlack =>  LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.blackGradiantOne, AppColors.blackGradiantTwo]);

  //Done
  static Color get lightGreen => const Color(0xFF76CC3D);
  static Color get lightRed => const Color(0xFFDC0425);

  static Color get blueworkout => const Color.fromRGBO(0, 129, 143, 1);
  static Color get orangeworkout => const Color.fromRGBO(195, 79, 38, 1);
  static Color get brownworkout => const Color.fromRGBO(176, 111, 0, 1);
  static Color get greenworkout => const Color.fromRGBO(49, 114, 34, 1);
  static Color get lightgreenworkout => const Color.fromRGBO(20, 52, 14, 1);
  static Color get grayworkout => const Color.fromRGBO(190, 190, 190, 1);
  static Color get graytextworkout => const Color.fromRGBO(3, 9, 11, 1);
  static Color get grayinfoworkout => const Color.fromRGBO(115, 115, 115, 1);
  static Color get darkgreen => const Color.fromRGBO(47, 109, 29, 1);
  static Color get greyColor => Color.fromRGBO(31, 32, 38, 1);
  static Color get greyColor1 => Color.fromRGBO(32, 33, 39, 1);
  static Color get greyColor2 => Color.fromRGBO(36, 37, 42, 1);
  static Color get black => Colors.black;
  static Color get greenColor1 => Color.fromRGBO(0, 255, 51, 1);
  static Color get greenColor2 => Color.fromRGBO(29, 165, 56, 1);
  static Color get darkblackgreen => const Color.fromRGBO(3, 91, 21, 1);
}
