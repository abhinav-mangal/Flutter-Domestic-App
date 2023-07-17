import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:skeleton_text/skeleton_text.dart';

import '../app_config.dart';
import '../utils/common/constants.dart';

class SkeletonText extends StatelessWidget {
  final double width;
  final double height;
  final BoxFit boxFit;
  SkeletonText({
    this.width = double.infinity,
    this.height = 22,
    this.boxFit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    AppConfig _appConfig = AppConfig.of(context);
    return ClipRRect(
      borderRadius: BorderRadius.circular(height),
      child: SkeletonAnimation(
        shimmerColor: _appConfig.skeletonShimmerColor,
        gradientColor: _appConfig.skeletonGradientColor,
        child: Container(
          color: _appConfig.skeletonBackgroundColor,
          width: width,
          height: height,
        ),
      ),
    );
  }
}

class SkeletonImage extends StatelessWidget {
  final double? width;
  final double? height;
  final String? imageUrl;
  final BorderRadius? borderRadius;
  final BoxFit? boxFit;
  final String? imgPlaceHolder;
  SkeletonImage({
    this.width,
    this.height,
    this.imageUrl,
    this.borderRadius,
    this.boxFit,
    this.imgPlaceHolder,
  });

  @override
  Widget build(BuildContext context) {
    AppConfig _appConfig = AppConfig.of(context);
    BorderRadius borderRadius = this.borderRadius ?? BorderRadius.circular(4);

    return ClipRRect(
        borderRadius: borderRadius,
        child: imageUrl != null
            ? _image(context, _appConfig)
            : _skeletonImage(context, _appConfig)
        // child: Stack(
        //   children: [
        //     //_skeletonImage(config),
        //     if (imageUrl != null)
        //       _image(config)
        //   ],
        // ),
        );
  }

  Widget _skeletonImage(BuildContext context, AppConfig appConfig) {
    return SkeletonAnimation(
      //shimmerColor: appConfig.skeletonShimmerColor,
      //gradientColor: appConfig.skeletonGradientColor,
      child: Container(
        width: width ?? double.infinity,
        height: height ?? double.infinity,
        decoration: BoxDecoration(
          color: appConfig.skeletonBackgroundColor,
        ),
        child: _imagePlaceholder(context),
      ),
    );
  }

  Widget _imagePlaceholder(BuildContext context) {
    String image = imgPlaceHolder ?? ImgConstants.imagePlaceholder;

    return Container(
      width: width ?? double.infinity,
      height: height ?? double.infinity,
      child: image.endsWith('.svg')
          ? SvgPicture.asset(
              image,
              width: width ?? double.infinity,
              height: height ?? double.infinity,
              //color: onPressed == null ? disabledColor : iconColor,
            )
          : Image.asset(
              image,
              fit: BoxFit.cover,
            ),
    );
  }

  Widget _image(BuildContext context, AppConfig appConfig) {
    if (imageUrl!.trim().isNotEmpty) {
      return CachedNetworkImage(
        placeholder: (context, imageUrl) => _skeletonImage(context, appConfig),
        imageUrl: imageUrl!,
        fit: boxFit ?? BoxFit.cover,
        width: width ?? double.infinity,
        height: height ?? double.infinity,
        filterQuality: FilterQuality.high,
        //color: config.skeletonBackgroundColor,
        fadeInDuration: Duration(milliseconds: 250),
      );
    } else {
      //print('image url is empty >>>>>>>>>>>>');
      return _imagePlaceholder(context);
    }
  }
}

class SkeletonContainer extends StatelessWidget {
  final double? width;
  final double? height;
  final BorderRadius? radius;
  final Color? backgroundColor;
  final Color? shimmerColor;
  final Color? gradientColor;
  final Gradient? bgGradiant;
  final Widget? child;
  SkeletonContainer({
    this.width = 100,
    this.height = 100,
    this.radius,
    this.backgroundColor,
    this.shimmerColor,
    this.gradientColor,
    this.bgGradiant,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    AppConfig _appConfig = AppConfig.of(context);
    return ClipRRect(
      borderRadius: radius ?? BorderRadius.circular(4),
      child: SkeletonAnimation(
        shimmerColor: shimmerColor ?? _appConfig.skeletonShimmerColor,
        gradientColor: gradientColor ?? _appConfig.skeletonGradientColor,
        curve: Curves.easeInOutSine,
        child: Container(
          width: this.width ?? double.infinity,
          height: this.height ?? double.infinity,
          decoration: BoxDecoration(
              color: backgroundColor ?? _appConfig.skeletonBackgroundColor,
              gradient: bgGradiant),
          child: Center(child: child ?? const SizedBox()),
        ),
      ),
    );
  }
}
