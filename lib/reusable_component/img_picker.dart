// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:energym/utils/extensions/extension.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

import 'package:permission_handler/permission_handler.dart';

import '../app_config.dart';
import '../utils/common/constants.dart';
import '../utils/common/svg_icon.dart';
import 'custom_dialog.dart';

enum ImagePickerType { gallary, camera, file }

enum SourceFileType { image, video }

enum AppState {
  free,
  picked,
  cropped,
}

class ImagePickerHelper extends StatefulWidget {
  ImagePickerHelper(
      {Key? key,
      this.onDone,
      this.isCropped,
      this.isAllowFile = false,
      required this.size,
      this.title,
      this.fileType = SourceFileType.image,
      this.cropStyle = CropStyle.rectangle})
      : super(key: key);

  final Function(File?)? onDone;
  final bool? isCropped;
  final Size? size;
  final CropStyle? cropStyle;
  final String? title;
  final bool? isAllowFile;
  final SourceFileType? fileType;

  @override
  State<ImagePickerHelper> createState() => _ImagePickerHelperState();
}

class _ImagePickerHelperState extends State<ImagePickerHelper> {
  File? imageFile;

  late AppState state;

  @override
  Widget build(BuildContext context) {
    AppConfig _appConfig = AppConfig.of(context);

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(
        topLeft: Radius.circular(12),
        topRight: Radius.circular(12),
      )),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const SizedBox(
            height: 10,
          ),
          Stack(
            alignment: Alignment.center,
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  highlightColor: Colors.transparent,
                  splashColor: Colors.transparent,
                  iconSize: 15,
                  icon: SvgIcon.asset(ImgConstants.close,
                      color: _appConfig.whiteColor),
                  //color: color,
                  tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                  onPressed: () {
                    context.navigateBack();
                    widget.onDone!(null);
                  },
                ),
              ),
              if (widget.title != null && widget.title!.isNotEmpty)
                Text(
                  widget.title!,
                  style: _appConfig.paragraphLargeFontStyle.apply(
                    color: _appConfig.whiteColor,
                  ),
                ),
            ],
          ),

          const SizedBox(
            height: 10,
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsetsDirectional.fromSTEB(30, 0, 30, 0),
            //height: 60,
            child: Row(
              children: [
                Expanded(
                  child: ListTile(
                    title: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SvgIcon.asset(ImgConstants.galary,
                              size: 30, color: _appConfig.whiteColor),
                          const SizedBox(
                            height: 5,
                          ),
                          Text(
                            AppConstants.gallery,
                            style: _appConfig.paragraphLargeFontStyle.apply(
                              color: _appConfig.whiteColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    onTap: () async {
                      var status = await Permission.photos.request();
                      if (status.isGranted || status.isLimited) {
                        if (widget.fileType == SourceFileType.image) {
                          // ignore: use_build_context_synchronously
                          getCroppedImage(
                                  _appConfig,
                                  ImagePickerType.gallary,
                                  widget.size!.height,
                                  widget.size!.width,
                                  context,
                                  widget.cropStyle!)
                              .then((File? img) {
                            print('imageFile == $imageFile');
                            context.navigateBack();
                            widget.onDone!(imageFile);
                          });
                        } else {
                          getTrimmedVideo(ImagePickerType.gallary, context)
                              .then((File? img) {
                            context.navigateBack();
                            widget.onDone!(imageFile);
                          });
                        }
                      } else {
                        //final size = Size(149, 169);

                        CustomAlertDialog().showErrorMessage(
                            context: context,
                            tital: AppConstants.galleryPermissionTital,
                            message: AppConstants.galleryPermissionMsg,
                            buttonTitle: AppConstants.appSetting,
                            onPress: () {
                              openAppSettings();
                            });
                      }
                    },
                  ),
                ),
                Expanded(
                  child: ListTile(
                    title: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SvgIcon.asset(ImgConstants.camera,
                              size: 30, color: _appConfig.whiteColor),
                          const SizedBox(
                            height: 5,
                          ),
                          Text(
                            AppConstants.camera,
                            style: _appConfig.paragraphLargeFontStyle.apply(
                              color: _appConfig.whiteColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    onTap: () async {
                      var status = await Permission.camera.request();
                      if (status.isGranted || status.isLimited) {
                        if (widget.fileType == SourceFileType.video) {
                          getTrimmedVideo(ImagePickerType.camera, context)
                              .then((File? img) {
                            context.navigateBack();
                            widget.onDone!(imageFile);
                          });
                        } else {
                          getCroppedImage(
                                  _appConfig,
                                  ImagePickerType.camera,
                                  widget.size!.height,
                                  widget.size!.width,
                                  context,
                                  widget.cropStyle!)
                              .then((File? img) {
                            context.navigateBack();
                            widget.onDone!(imageFile);
                          });
                        }
                      } else {
                        CustomAlertDialog().showErrorMessage(
                            context: context,
                            tital: AppConstants.cameraPermissionTital,
                            message: AppConstants.cameraPermissionMsg,
                            buttonTitle: AppConstants.appSetting,
                            onPress: () {
                              openAppSettings();
                            });
                      }
                    },
                  ),
                ),
                if (widget.isAllowFile!)
                  Expanded(
                    child: ListTile(
                      title: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // SvgIcon.asset(ImgConstants.postFile,
                            //     size: 30, color: AppColors.accentColor),
                            // const SizedBox(
                            //   height: 5,
                            // ),
                            // Text(
                            //   AppConstants.postFile,
                            //   style: context.theme.textTheme.subtitle1.apply(
                            //     color: AppColors.accentColor,
                            //   ),
                            // ),
                          ],
                        ),
                      ),
                      onTap: () async {
                        if (widget.fileType == SourceFileType.video) {
                          getTrimmedVideo(ImagePickerType.file, context)
                              .then((File? img) {
                            context.navigateBack();
                            widget.onDone!(imageFile);
                          });
                        } else {
                          getCroppedImage(
                                  _appConfig,
                                  ImagePickerType.file,
                                  widget.size!.height,
                                  widget.size!.width,
                                  context,
                                  widget.cropStyle!)
                              .then((File? img) {
                            context.navigateBack();
                            widget.onDone!(imageFile);
                          });
                        }
                      },
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(
            height: 25,
          ),
          // ListTile(
          //   title: Text('Cancel'.tr(), style: TextStyle(color: Colors.red)),
          //   onTap: () {
          //     context.navigateBack();
          //     onDone(null);
          //   },
          // ),
        ],
      ),
    );
  }

  Future<Null> _pickImage(ImagePickerType type) async {
    XFile? pickedImage = await ImagePicker().pickImage(
        source: type == ImagePickerType.gallary
            ? ImageSource.gallery
            : ImageSource.camera);
    imageFile = pickedImage != null ? File(pickedImage.path) : null;
    if (imageFile != null) {
      setState(() {
        state = AppState.picked;
      });
    }
  }

  Future<File?> getCroppedImage(
      AppConfig config,
      ImagePickerType type,
      double height,
      double width,
      BuildContext context,
      CropStyle cropStyle) async {
    if (type == ImagePickerType.file) {
      return null;
    } else {
      return _pickImage(type).then(
        (PickedFile? value) async {
          final File? croppedFile = await ImageCropper().cropImage(
              sourcePath: imageFile!.path,
              androidUiSettings: const AndroidUiSettings(
                  toolbarTitle: 'Cropper',
                  toolbarColor: Colors.deepOrange,
                  toolbarWidgetColor: Colors.white,
                  initAspectRatio: CropAspectRatioPreset.original,
                  lockAspectRatio: false),
              iosUiSettings: const IOSUiSettings(
                title: 'Cropper',
              ));
          if (croppedFile != null) {
            imageFile = croppedFile;
            setState(() {
              state = AppState.cropped;
            });
          }
        },
      );
    }
  }

  Future<File?> getTrimmedVideo(
      ImagePickerType type, BuildContext context) async {
    return null;
    // if (type == ImagePickerType.file) {
    //   print('This is video from file');
    //   FilePickerResult result = await FilePicker.platform.pickFiles(
    //     type: FileType.video,
    //     allowCompression: false,
    //   );
    //   if (result != null) {
    //     File file = File(result.files.single.path);
    //     Trimmer _trimmer = await Trimmer();
    //     await _trimmer.loadVideo(videoFile: file);
    //     final resultTrimmer = await Navigator.pushNamed(
    //       context,
    //       TrimmerView.routeName,
    //       arguments: TrimmerViewArge(trimmer: _trimmer),
    //     );
    //     if (resultTrimmer != null) {
    //       return resultTrimmer;
    //     }
    //   } else {}
    // } else {
    //   File file = await ImagePicker()
    //       .getVideo(
    //           source: type == ImagePickerType.camera
    //               ? ImageSource.camera
    //               : ImageSource.gallery)
    //       .then(
    //     (PickedFile value) async {
    //       if (value != null) {
    //         File file = File(value.path);
    //         return file;
    //       } else {}
    //     },
    //   );
    //   if (file != null) {
    //     print('This is video from gallary or camera 1>> $file');
    //     Trimmer _trimmer = await Trimmer();
    //     print('This is video from gallary or camera 2 >> $file');
    //     await _trimmer.loadVideo(videoFile: file);
    //     print('This is video from gallary or camera 3 >> $file');
    //     final resultTrimmer = await Navigator.pushNamed(
    //       context,
    //       TrimmerView.routeName,
    //       arguments: TrimmerViewArge(trimmer: _trimmer),
    //     );
    //     if (resultTrimmer != null) {
    //       return resultTrimmer;
    //     }
    //   } else {}
    // }
  }
}
