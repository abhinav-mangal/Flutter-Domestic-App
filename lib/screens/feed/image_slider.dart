import 'package:energym/app_config.dart';
import 'package:energym/utils/helpers/firebase/firestore_provider.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:skeleton_text/skeleton_text.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:url_launcher/url_launcher.dart';

class ImageSlider extends StatefulWidget {
  const ImageSlider({this.imageList, this.height});

  final List<Map<String, dynamic>>? imageList;
  final double? height;

  @override
  _ImageSliderState createState() => _ImageSliderState();
}

class _ImageSliderState extends State<ImageSlider> {
  final PageController controller = PageController(initialPage: 0);
  PublishSubject<int> dotSubject = PublishSubject<int>();
  List<Widget> tabs = <Widget>[];
  List<FadeInImage> networkImage = <FadeInImage>[];

  @override
  void initState() {
    widget.imageList!.forEach((Map<String, dynamic> data) {
      String imageURL = data[BannerCollectionField.bannerImg] as String;
      print('imageURL >> $imageURL');
      final FadeInImage image = FadeInImage.memoryNetwork(
        placeholder: kTransparentImage,
        image: imageURL,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        fadeInDuration: const Duration(milliseconds: 250),
      );
      networkImage.add(image);
    });
    super.initState();
  }

  /// Did Change Dependencies
  @override
  void didChangeDependencies() {
    networkImage.forEach((FadeInImage imageView) {
      precacheImage(imageView.image, context);
    });

    super.didChangeDependencies();
  }

  @override
  void dispose() {
    dotSubject.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppConfig config = AppConfig.of(context);
    //_setUpListOfImageWidget();
    return Container(
      padding: EdgeInsets.zero,
      height: widget.height ?? 200,
      child: Column(
        children: <Widget>[
          Expanded(
            child: PageView.builder(
              physics: const ClampingScrollPhysics(),
              controller: controller,
              itemCount: networkImage.length,
              itemBuilder: (BuildContext context, int index) {
                return Stack(
                  children: [
                    if (networkImage[index] != null)
                      GestureDetector(
                        onTap: () async {
                          Map<String, dynamic> data = widget.imageList![index];

                          String refLink =
                              data[BannerCollectionField.refLink] as String;

                          print('refLink >>> $refLink');
                          if (refLink != null && refLink.isNotEmpty) {
                            if (await canLaunch(refLink) != null) {
                              await launch(
                                refLink,
                                forceSafariVC: false,
                                forceWebView: false,
                                //headers: <String, String>{'my_header_key': 'my_header_value'},
                              );
                            } else {
                              throw 'Could not launch ${refLink}';
                            }
                          }
                        },
                        child: Container(
                          margin: const EdgeInsetsDirectional.fromSTEB(
                              16, 0, 16, 0),
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                  color: config.whiteColor.withOpacity(0.15))),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: networkImage[index],
                          ),
                        ),
                      ),
                  ],
                );
              },
              onPageChanged: (page) {
                dotSubject.sink.add(page);
              },
            ),
          ),
          const SizedBox(
            height: 8,
          ),
          dotIndicator(config),
        ],
      ),
    );
  }

  Widget dotIndicator(AppConfig config) {
    final double dotIndicatorWidth = (widget.imageList!.length * 20).toDouble();
    return StreamBuilder<int>(
      initialData: 0,
      stream: dotSubject.stream,
      builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
        final int currentIndex = snapshot.data ?? 0;
        return Container(
          padding: EdgeInsets.zero,
          width: dotIndicatorWidth,
          height: 10,
          child: ListView.builder(
            physics: const ClampingScrollPhysics(),
            scrollDirection: Axis.horizontal,
            itemCount: widget.imageList!.length,
            itemBuilder: (BuildContext context, int index) {
              return dotWidget(index, currentIndex, config);
            },
          ),
        );
      },
    );
  }

  Widget dotWidget(int index, int currentIndex, AppConfig config) {
    return Container(
      width: 10,
      height: 10,
      padding: const EdgeInsets.all(2),
      child: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(3),
            color:
                index == currentIndex ? config.whiteColor : config.greyColor),
      ),
    );
  }
}
