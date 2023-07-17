import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class AppConfig with ChangeNotifier {
  String fireStoreDB;
  //String supportEmail = 'support@thedealerapp.co.uk';
  Brightness? _brightness;

  AppThemeData? defaultThemeData;
  AppThemeData? lightThemeData;
  AppThemeData? darkThemeData;

  AppConfig({
    required this.fireStoreDB,
    //this.supportEmail,
    @required Brightness? brightness,
    this.defaultThemeData,
    this.lightThemeData,
    this.darkThemeData,
  })  : assert(fireStoreDB != null),
        assert(brightness != null),
        assert(defaultThemeData != null ||
            (lightThemeData != null && darkThemeData != null)),
        assert(defaultThemeData?.accentColor != null ||
            (lightThemeData?.accentColor != null &&
                darkThemeData?.accentColor != null)) {
    this.brightness = brightness!;
  }

  static AppConfig of(BuildContext context, {bool listen = true}) {
    return Provider.of<AppConfig>(context, listen: listen);
  }

  Brightness get brightness => _brightness!;

  set brightness(Brightness value) {
    _brightness = value;
    SystemChrome.setSystemUIOverlayStyle(getSystemUiOverlayStyle(_brightness!));
    // SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    //   statusBarColor: Colors.transparent,
    //   systemNavigationBarColor: Colors.transparent,
    //   systemNavigationBarDividerColor: Colors.transparent,
    // ));
  }

  static SystemUiOverlayStyle getSystemUiOverlayStyle(Brightness brightness) {
    bool isDark = brightness == Brightness.dark;

    SystemUiOverlayStyle style =
        isDark ? SystemUiOverlayStyle.dark : SystemUiOverlayStyle.light;

    return style.copyWith(
      statusBarColor: isDark ? Colors.black : Colors.white,
      systemNavigationBarColor: isDark ? Colors.black : Colors.white,
      systemNavigationBarDividerColor: isDark ? Colors.black : Colors.white,
      systemNavigationBarIconBrightness:
          isDark ? Brightness.light : Brightness.dark,
      statusBarBrightness: isDark ? Brightness.light : Brightness.dark,
      statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
    );
  }

  bool get isDark => brightness == Brightness.dark;

  SystemUiOverlayStyle get systemUiOverlayStyle =>
      getSystemUiOverlayStyle(brightness);

  AppThemeData? get themeData {
    AppThemeData? themeData = isDark ? darkThemeData : lightThemeData;
    return themeData ?? defaultThemeData;
  }

  SystemUiOverlayStyle get loginSystemUiOverlayStyle =>
      getSystemUiOverlayStyle(brightness);

  Color? get accentColor =>
      themeData?.accentColor ?? defaultThemeData!.accentColor;

  Brightness? get accentBrightness {
    return themeData?.accentBrightness ?? defaultThemeData!.accentBrightness;
  }

//  Brightness get accentBrightness {
//    log('accent brightness: ' + ThemeData.estimateBrightnessForColor(accentColor).toString());
//    return ThemeData.estimateBrightnessForColor(accentColor);
//  }

  Color get colorOnAccentBg =>
      accentBrightness == Brightness.dark ? Colors.white : Colors.black;

  List<Color>? get accentColors {
    return themeData?.accentColors ?? defaultThemeData!.accentColors;
  }

  Color? getAccentColorAtIndex(int index) =>
      themeData?.getAccentColorAtIndex(index) ??
      defaultThemeData?.getAccentColorAtIndex(index) ??
      accentColor;

  Color? get textAccentColor =>
      themeData?.textAccentColor ??
      defaultThemeData?.textAccentColor ??
      accentColor;

  Color? get primaryButtonColor =>
      themeData?.primaryButtonColor ??
      defaultThemeData?.primaryButtonColor ??
      accentColor;

  Brightness? get primaryButtonBrightness =>
      themeData?.primaryButtonBrightness ??
      defaultThemeData?.primaryButtonBrightness ??
      accentBrightness;

  Color get primaryButtonTextColor =>
      primaryButtonBrightness == Brightness.dark ? Colors.white : Colors.black;

  Color get windowBackground =>
      isDark ? const Color(0xff000000) : const Color(0xffffffff);

  Color get barBackground => getBarBackground(_brightness!);

  static Color getBarBackground(Brightness brightness) =>
      brightness == Brightness.dark ? Colors.black : Colors.white;

  Color get whiteColor =>
      primaryButtonBrightness == Brightness.dark ? Colors.white : Colors.black;

  Color get blackColor =>
      primaryButtonBrightness == Brightness.dark ? Colors.black : Colors.white;

  Color get greyColor => primaryButtonBrightness == Brightness.dark
      ? const Color(0xff929394)
      : const Color(0xff929394);
  Color get lightGreyColor => primaryButtonBrightness == Brightness.dark
      ? const Color(0xffC4C4C4)
      : const Color(0xffC4C4C4);

  Color get btnPrimaryColor => primaryButtonBrightness == Brightness.dark
      ? const Color(0xff0DC523)
      : const Color(0xff0DC523);

  Color get blueColor => primaryButtonBrightness == Brightness.dark
      ? const Color(0xff3E95F7)
      : const Color(0xff3E95F7);

  Color get borderColor => primaryButtonBrightness == Brightness.dark
      ? const Color(0xff212121)
      : const Color(0xff212121);

  Color get pickerBgColor => primaryButtonBrightness == Brightness.dark
      ? const Color(0xff2D2C2E)
      : const Color(0xff2D2C2E);

  Color get darkGreyColor => primaryButtonBrightness == Brightness.dark
      ? const Color(0xff404040)
      : const Color(0xff404040);

  Color get lightBorderColor => primaryButtonBrightness == Brightness.dark
      ? const Color(0xff636363)
      : const Color(0xff636363);

  Color get skyBlueColor => primaryButtonBrightness == Brightness.dark
      ? const Color(0xff00DFFF)
      : const Color(0xff00DFFF);

  Color get orangeColor => primaryButtonBrightness == Brightness.dark
      ? const Color(0xffEC4025)
      : const Color(0xffEC4025);

  Color get shimmerColor => primaryButtonBrightness == Brightness.dark
      ? Colors.black54
      : Colors.white54;

  Color get skeletonBackgroundColor => const Color(0xffdddddd);
  Color get skeletonShimmerColor => primaryButtonBrightness == Brightness.dark
      ? Colors.white54
      : Colors.white54;
  Color get skeletonGradientColor => skeletonBackgroundColor.withOpacity(0);

  Color get purpelColor => primaryButtonBrightness == Brightness.dark
      ? const Color(0xff5C80FF)
      : const Color(0xff5C80FF);

  String get fontFamilyAntonio => 'Antonio';
  String get fontFamilyCalibri => 'Calibri';
  String get fontFamilyInter => 'Inter';
  String get fontFamilyAbel => 'Abel';

  TextStyle get interButtonFontStyle =>
      TextStyle(fontFamily: fontFamilyInter, fontSize: 18, color: Colors.white);

  TextStyle get interTextField1FontStyle =>
      TextStyle(fontFamily: fontFamilyInter, fontSize: 15, color: Colors.grey);
  TextStyle get abel20FontStyle => TextStyle(
        fontFamily: fontFamilyAbel,
        fontStyle: FontStyle.normal,
        fontWeight: FontWeight.normal,
        fontSize: 20,
        //height: 46.16,
      );

  TextStyle get abel24FontStyle => TextStyle(
        fontFamily: fontFamilyAbel,
        fontStyle: FontStyle.normal,
        fontWeight: FontWeight.normal,
        fontSize: 24,
        //height: 46.16,
      );
  TextStyle get abelNormalFontStyle => TextStyle(
        fontFamily: fontFamilyAbel,
        fontStyle: FontStyle.normal,
        fontWeight: FontWeight.normal,
        fontSize: 16,
        //height: 22,
      );
       TextStyle get abel14FontStyle => TextStyle(
        fontFamily: fontFamilyAbel,
        fontStyle: FontStyle.normal,
        fontWeight: FontWeight.normal,
        fontSize: 14,
        
      );
  TextStyle get abel11FontStyle => TextStyle(
        fontFamily: fontFamilyAbel,
        fontStyle: FontStyle.normal,
        fontWeight: FontWeight.normal,
        fontSize: 11,
      );
  TextStyle get antonioHeading1FontStyle => TextStyle(
        fontFamily: fontFamilyAntonio,
        fontStyle: FontStyle.normal,
        fontWeight: FontWeight.normal,
        fontSize: 32,
        //height: 46.16,
      );
  TextStyle get able36FontStyle => TextStyle(
        fontFamily: fontFamilyAbel,
        fontStyle: FontStyle.normal,
        fontWeight: FontWeight.normal,
        fontSize: 36,
        //height: 46.16,
      );
  TextStyle get antonio36FontStyle => TextStyle(
        fontFamily: fontFamilyAntonio,
        fontStyle: FontStyle.normal,
        fontWeight: FontWeight.normal,
        fontSize: 36,
        //height: 46.16,
      );
  TextStyle get antonio48FontStyle => TextStyle(
        fontFamily: fontFamilyAntonio,
        fontStyle: FontStyle.normal,
        fontWeight: FontWeight.normal,
        fontSize: 48,
        //height: 46.16,
      );
  TextStyle get antonioHeading2FontStyle => TextStyle(
      fontFamily: fontFamilyAntonio,
      fontStyle: FontStyle.normal,
      fontWeight: FontWeight.normal,
      fontSize: 24
      //height: 34.62,
      );
  TextStyle get antonioHeading3FontStyle => TextStyle(
        fontFamily: fontFamilyAntonio,
        fontStyle: FontStyle.normal,
        fontWeight: FontWeight.normal,
        fontSize: 18,
        //height: 25.96,
      );

  TextStyle get antonioHeading4FontStyle => TextStyle(
        fontFamily: fontFamilyAntonio,
        fontStyle: FontStyle.normal,
        fontWeight: FontWeight.normal,
        fontSize: 14,
        //height: 20.19,
      );

  TextStyle get antonioHeading5FontStyle => TextStyle(
        fontFamily: fontFamilyAntonio,
        fontStyle: FontStyle.normal,
        fontWeight: FontWeight.normal,
        fontSize: 12,
        //height: 20.19,
      );

  TextStyle get antonioTimerFontStyle => TextStyle(
        fontFamily: fontFamilyAntonio,
        fontStyle: FontStyle.normal,
        fontWeight: FontWeight.normal,
        fontSize: 100,
        //height: 20.19,
      );
  TextStyle get antonio60FontStyle => TextStyle(
        fontFamily: fontFamilyAntonio,
        fontStyle: FontStyle.normal,
        fontWeight: FontWeight.normal,
        fontSize: 60,
        //height: 20.19,
      );

  TextStyle get antonio14FontStyle => TextStyle(
        fontFamily: fontFamilyAntonio,
        fontStyle: FontStyle.normal,
        fontWeight: FontWeight.normal,
        fontSize: 14,
        //height: 20.19,
      );

  TextStyle get calibriHeading1FontStyle => TextStyle(
        fontFamily: fontFamilyCalibri,
        fontStyle: FontStyle.normal,
        fontWeight: FontWeight.bold,
        fontSize: 32,
        //height: 39.06,
      );
  TextStyle get calibriHeading2FontStyle => TextStyle(
        fontFamily: fontFamilyCalibri,
        fontStyle: FontStyle.normal,
        fontWeight: FontWeight.bold,
        fontSize: 24,
        //height: 29.3,
      );
  TextStyle get calibriHeading3FontStyle => TextStyle(
        fontFamily: fontFamilyCalibri,
        fontStyle: FontStyle.normal,
        fontWeight: FontWeight.bold,
        fontSize: 20,
        //height: 24.41,
      );
  TextStyle get calibriHeading4FontStyle => TextStyle(
        fontFamily: fontFamilyCalibri,
        fontStyle: FontStyle.normal,
        fontWeight: FontWeight.bold,
        fontSize: 16,
        //height: 19.53,
      );
  TextStyle get calibriHeading5FontStyle => TextStyle(
        fontFamily: fontFamilyCalibri,
        fontStyle: FontStyle.normal,
        fontWeight: FontWeight.bold,
        fontSize: 14,
        //height: 17.09,
      );

  TextStyle get paragraphLargeFontStyle => TextStyle(
        fontFamily: fontFamilyCalibri,
        fontStyle: FontStyle.normal,
        fontWeight: FontWeight.normal,
        fontSize: 20,
        //height: 30,
      );

  TextStyle get paragraphNormalFontStyle => TextStyle(
        fontFamily: fontFamilyCalibri,
        fontStyle: FontStyle.normal,
        fontWeight: FontWeight.normal,
        fontSize: 16,
        //height: 22,
      );

  TextStyle get paragraphSmallFontStyle => TextStyle(
        fontFamily: fontFamilyCalibri,
        fontStyle: FontStyle.normal,
        fontWeight: FontWeight.normal,
        fontSize: 14,
        //height: 17.09,
      );

  TextStyle get paragraphExtraSmallFontStyle => TextStyle(
        fontFamily: fontFamilyCalibri,
        fontStyle: FontStyle.normal,
        fontWeight: FontWeight.normal,
        fontSize: 12,
        //height: 14.65,
      );

  TextStyle get linkLargeFontStyle => TextStyle(
        fontFamily: fontFamilyCalibri,
        fontStyle: FontStyle.normal,
        fontWeight: FontWeight.bold,
        fontSize: 20,
        //height: 14.41,
      );

  TextStyle get linkNormalFontStyle => TextStyle(
        fontFamily: fontFamilyCalibri,
        fontStyle: FontStyle.normal,
        fontWeight: FontWeight.bold,
        fontSize: 16,
        //height: 20,
      );

  TextStyle get linkSmallFontStyle => TextStyle(
        fontFamily: fontFamilyCalibri,
        fontStyle: FontStyle.normal,
        fontWeight: FontWeight.bold,
        fontSize: 14,
        //height: 17.09,
      );

  TextStyle get labelLargeFontStyle => TextStyle(
        fontFamily: fontFamilyCalibri,
        fontStyle: FontStyle.normal,
        fontWeight: FontWeight.normal,
        fontSize: 16,
        //height: 19.53,
        letterSpacing: 1,
      );

  TextStyle get labelNormalFontStyle => TextStyle(
        fontFamily: fontFamilyCalibri,
        fontStyle: FontStyle.normal,
        fontWeight: FontWeight.normal,
        fontSize: 12,
        //height: 14.65,
        letterSpacing: 1,
      );

  TextStyle get labelSmallFontStyle => TextStyle(
        fontFamily: fontFamilyCalibri,
        fontStyle: FontStyle.normal,
        fontWeight: FontWeight.normal,
        fontSize: 10,
        //height: 12.21,
        letterSpacing: 1,
      );

  void notify() {
    notifyListeners();
  }
}

class AppThemeData {
  Color? accentColor;
  Brightness? accentBrightness;
  List<Color>? accentColors;

  Color? primaryButtonColor;
  Brightness? primaryButtonBrightness;

  Color? textAccentColor;

  AppThemeData({
    this.accentColor,
    this.accentBrightness,
    this.accentColors,
    this.textAccentColor,
    this.primaryButtonColor,
    this.primaryButtonBrightness,
  });

  Color? getAccentColorAtIndex(int index) {
    return accentColors == null
        ? null
        : accentColors![index % accentColors!.length];
  }
}
