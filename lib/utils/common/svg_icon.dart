import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// An icon that comes from an [SvgPicture], based on [ImageIcon]
class SvgIcon extends StatelessWidget {
  /// The image to display as the icon.
  ///
  /// The icon can be null, in which case the widget will render as an empty
  /// space of the specified [size].
//  final SvgPicture image;

  final String? fileName;

  /// The size of the icon in logical pixels.
  ///
  /// Icons occupy a square with width and height equal to size.
  ///
  /// Defaults to the current [IconTheme] size, if any. If there is no
  /// [IconTheme], or it does not specify an explicit size, then it defaults to
  /// 24.0.
  final double? size;

  /// The color to use when drawing the icon.
  ///
  /// Defaults to the current [IconTheme] color, if any. If there is
  /// no [IconTheme], then it defaults to not recolorizing the image.
  ///
  /// The image will additionally be adjusted by the opacity of the current
  /// [IconTheme], if any.
  final Color? color;

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

  /// Creates an SvgIcon
  ///
  /// The [size] and [color] default to the value given by the current [IconTheme].
  const SvgIcon.asset(
    this.fileName, {
    Key? key,
    this.size,
    this.color,
    this.semanticLabel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final IconThemeData iconTheme = IconTheme.of(context);
    final double iconSize = size ?? iconTheme.size!;

    if (fileName == null)
      return Semantics(
        label: semanticLabel,
        child: SizedBox(width: iconSize, height: iconSize),
      );

    final double iconOpacity = iconTheme.opacity!;
    Color iconColor = color ?? iconTheme.color!;

    if (iconOpacity != null && iconOpacity != 1.0)
      iconColor = iconColor.withOpacity(iconColor.opacity * iconOpacity);

    return Semantics(
      label: semanticLabel,
      child: SvgPicture.asset(
        fileName!,
        width: iconSize,
        height: iconSize,
        color: iconColor,
        fit: BoxFit.contain,
        alignment: Alignment.center,
        excludeFromSemantics: true,
      ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
//    properties.add(DiagnosticsProperty<ImageProvider>('image', image,
//        ifNull: '<empty>', showName: false));
//    properties.add(StringProperty('fi', image,
//        ifNull: '<empty>', showName: false));
    properties.add(DoubleProperty('size', size, defaultValue: null));
    properties.add(ColorProperty('color', color, defaultValue: null));
  }
}
