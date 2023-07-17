import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
//import 'package:thedealer/app_config.dart';

class SvgPictureColorCustomise extends StatelessWidget {
  /// The image to display as the icon.
  ///
  /// The icon can be null, in which case the widget will render as an empty
  /// space of the specified [size].
//  final SvgPicture image;

  final String? fileName;

  /// The color to use when drawing the icon.
  ///
  /// Defaults to the current [IconTheme] color, if any. If there is
  /// no [IconTheme], then it defaults to not recolorizing the image.
  ///
  /// The image will additionally be adjusted by the opacity of the current
  /// [IconTheme], if any.
  final List<String>? defaultColorHex;

  /// The color to use when drawing update the icon.

  final List<Color>? updatedColor;

  /// Semantic label for the icon.
  ///
  /// Announced in accessibility modes (e.g TalkBack/VoiceOver).
  /// This label does not show in the UI.
  ///
  /// See also:
  ///
  ///  * [Semantics.label], which is set to [semanticLabel] in the underlying
  ///    [Semantics] widget.
  final String? semanticLabel;

  final double? width;
  final double? height;

  /// Creates an SvgIcon
  ///
  /// The [size] and [color] default to the value given by the current [IconTheme].
  const SvgPictureColorCustomise.asset(
    this.fileName, {
    Key? key,
    this.defaultColorHex,
    this.updatedColor,
    this.semanticLabel,
    this.width = 149,
    this.height = 169,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final IconThemeData iconTheme = IconTheme.of(context);
    final double iconSize = iconTheme.size!;
    //AppConfig config = AppConfig.of(context);

    if (fileName == null)
      return Semantics(
        label: semanticLabel,
        child: SizedBox(width: iconSize, height: iconSize),
      );

    return FutureBuilder<String>(
      future: rootBundle.loadString(this.fileName!),
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
        SvgPicture? svgPicture;

        if (snapshot.hasData) {
          String svgData = snapshot.data!;

          for (var i = 0; i < this.defaultColorHex!.length; i++) {
            String defaultHexColor = this.defaultColorHex![i];
            Color updatedNewColor = this.updatedColor![i];

            if (defaultHexColor != null && updatedNewColor != null) {
              String colorHex =
                  "#${updatedNewColor.value.toRadixString(16).toString()}";
              svgData = svgData.replaceAll('#$defaultHexColor', colorHex);
            }
          }

          // if (config.isDark) {
          //   svgData = svgData.replaceAll('#FFF', '#404040');
          //   svgData = svgData.replaceAll('#222', '#fff');
          // }
          svgPicture = SvgPicture.string(
            svgData,
            semanticsLabel: semanticLabel,
            width: width,
            height: height,
          );
        }

        return Container(
          margin: EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          child: svgPicture,
        );
      },
    );
  }
}

class SvgPictureRecolor extends StatelessWidget {
  /// The SVG image file name to display
  ///
  /// The filename can be null in which case the widget will render as an empty
  /// space of the specified size.
  final String fileName;

  /// The colors to replace in the SVG. The keys must match exactly how it is
  /// shown in the SVG.
  ///
  /// e.g. {
  ///   'red': Colors.blue,
  ///   'green': 'blue',
  ///   '#fff': const Color(0xff0000),
  /// }
  ///
  final Map<String, dynamic>? replacements;

  /// Semantic label for the icon.
  ///
  /// Announced in accessibility modes (e.g TalkBack/VoiceOver).
  /// This label does not show in the UI.
  ///
  /// See also:
  ///
  ///  * [Semantics.label], which is set to [semanticLabel] in the underlying
  ///    [Semantics] widget.
  final String? semanticLabel;

  final double? width;
  final double? height;
  final BoxFit? boxfix;
  const SvgPictureRecolor.asset(
    this.fileName, {
    Key? key,
    this.width,
    this.height,
    this.replacements,
    this.semanticLabel,
    this.boxfix,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // final config = AppConfig.of(context);

    if (fileName == null) {
      return Semantics(
        label: semanticLabel,
        child: SizedBox(width: width, height: height),
      );
    }

    return FutureBuilder<String>(
      future: rootBundle.loadString(this.fileName),
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
        SvgPicture? svgPicture;

        if (snapshot.hasData) {
          String svgData = snapshot.data!;

          if (replacements != null) {
            replacements!.forEach((String original, dynamic replacement) {
              if (replacement is Color) {
                replacement = _colorToHex(replacement as Color);
              }
              svgData = svgData.replaceAll(original, replacement as String);
            });
          }

//          if (config.isDark) {
//            svgData = svgData.replaceAll('#FFF', '#404040');
//            svgData = svgData.replaceAll('#fff', '#404040');
//            svgData = svgData.replaceAll('white', '#404040');
//            svgData = svgData.replaceAll('white', '#777');
//            svgData = svgData.replaceAll('#F3F3F3', '#fff');
//          }

          svgPicture = SvgPicture.string(
            svgData,
            semanticsLabel: semanticLabel,
            width: width,
            height: height,
            fit: boxfix ?? BoxFit.cover,
          );
        }

        return Container(
          width: width,
          height: height,
          child: svgPicture,
        );
      },
    );
  }

  String _colorToHex(Color color) {
    return "#${color.value.toRadixString(16).toString()}";
  }
}
