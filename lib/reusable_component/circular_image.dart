import 'package:energym/reusable_component/skeleton.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../utils/common/constants.dart';
import '../utils/common/svg_icon.dart';
import '../utils/theme/colors.dart';

class CircularImage extends StatelessWidget {
  const CircularImage(this.imageFileName,
      {double width = 40,
      double height = 40,
      double? borderRadius,
      String? imgPlaceHolder,
      Color borderColor = Colors.transparent,
      double borderWidth = 2.0,
      bool isLocalImage = false,
      BoxFit? boxFit})
      : _width = width,
        _height = height,
        _borderColor = borderColor,
        _borderRadius = borderRadius,
        _borderWidth = borderWidth,
        _boxFit = boxFit,
        _imgPlaceHolder = imgPlaceHolder,
        _isLocalImage = isLocalImage;

  final double _width, _height;
  final String imageFileName;
  final Color _borderColor;
  final double _borderWidth;
  final double? _borderRadius;
  final BoxFit? _boxFit;
  final String? _imgPlaceHolder;
  final bool _isLocalImage;

  @override
  Widget build(BuildContext context) {
    return _widgetProfilePicture(context);
  }

  Widget _widgetProfilePicture(BuildContext context) {
    if (imageFileName != null && imageFileName.isNotEmpty) {
      return Container(
        width: _width,
        height: _height,
        //padding: const EdgeInsetsDirectional.fromSTEB(10, 0, 10, 0),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(_borderRadius ?? (_height / 2)),
            border: Border.all(
              color: _borderColor,
              width: _borderWidth,
            )
            //color: AppColors.hintColor,
            ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(_borderRadius ?? _height / 2),
          child: _isLocalImage
              ? Image.asset(
                  imageFileName,
                )
              : SkeletonImage(
                  width: _width,
                  height: _width,
                  imageUrl: imageFileName,
                  imgPlaceHolder:
                      _imgPlaceHolder, //APIConstant.baseURLImage + imageFileName,
                  boxFit: _boxFit,
                ),
        ),
      );
    } else {
      return Container(
        width: _width,
        height: _height,
        //padding: const EdgeInsetsDirectional.fromSTEB(10, 0, 10, 0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(_width / 2),
          color: AppColors.hintColor,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(_width / 2),
          child: _placeHolder(),
        ),
      );
    }
  }

  Widget _placeHolder() {
    String image = _imgPlaceHolder ?? ImgConstants.imagePlaceholder;
    if (image.endsWith('.svg')) {
      return SvgIcon.asset(image
          //size: iconSize,
          //color: onPressed == null ? disabledColor : iconColor,
          );
    } else {
      return Image.asset(
        image,
        fit: BoxFit.cover,
        //color: AppColors.hintDarkColor,
      );
    }
  }
}
