import 'package:energym/app_config.dart';
import 'package:energym/screens/feed/add_feed.dart';
import 'package:energym/screens/feed/feed_bloc.dart';
import 'package:energym/screens/feed/image_slider.dart';
import 'package:energym/screens/feed/widget_feed.dart';
import 'package:energym/utils/common/base_bloc.dart';
import 'package:energym/utils/common/constants.dart';
import 'package:energym/utils/helpers/firebase/firestore_provider.dart';
import 'package:flutter/material.dart';
import 'package:energym/models/user_model.dart';
import 'package:energym/reusable_component/circular_image.dart';
import 'package:energym/reusable_component/skeleton.dart';
import 'package:energym/models/feed_model.dart';

class Feed extends StatefulWidget {
  @override
  _FeedState createState() => _FeedState();
}

class _FeedState extends State<Feed> {
  AppConfig? _appConfig;
  UserModel? _currentUser;
  final FeedBloc _blocFeed = FeedBloc();

  @override
  void initState() {
    super.initState();
    _currentUser = aGeneralBloc.currentUser;
    _blocFeed.getFeed(context);
  }

  @override
  void dispose() {
    _blocFeed.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _appConfig = AppConfig.of(context);
    return Container(
      padding: EdgeInsets.zero,
      width: double.infinity,
      height: double.infinity,
      child: Column(
        children: <Widget>[
          _widgetCreatePost(),
          Expanded(child: _widgetMainContainer())
        ],
      ),
    );
  }

  Widget _widgetCreatePost() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsetsDirectional.fromSTEB(16, 12, 16, 0),
      child: TextButton(
        child: Row(
          children: <Widget>[
            CircularImage(
              _currentUser?.profilePhoto ?? '',
            ),
            const SizedBox(
              width: 16,
            ),
            Text(
              AppConstants.shareYourThoughts,
              style: _appConfig!.paragraphNormalFontStyle
                  .apply(color: _appConfig!.greyColor),
            )
          ],
        ),
        onPressed: () {
          Navigator.pushNamed(context, AddFeed.routeName).then((value) {
            if (value != null) {
              _blocFeed.getFeed(context, isReset: true);
            }
          });
        },
      ),
    );
  }

  Widget _widgetMainContainer() {
    return NotificationListener<ScrollNotification>(
      onNotification: (scrollNotification) {
        if (scrollNotification.metrics.axis == Axis.vertical) {
          if (scrollNotification.metrics.pixels ==
              scrollNotification.metrics.maxScrollExtent) {
            _blocFeed.getFeed(context);
          }

          return true;
        }
        return false;
      },
      child: SingleChildScrollView(
        padding: const EdgeInsetsDirectional.fromSTEB(0, 16, 0, 0),
        child: Column(
          children: <Widget>[
            _widgetBanner(),
            _widgetFeed(),
          ],
        ),
      ),
    );
  }

  Widget _widgetBanner() {
    return FutureBuilder<List<Map<String, dynamic>>>(
        future: FireStoreProvider.instance.getBannerImage(),
        builder: (BuildContext contxt, AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
          List<Map<String, dynamic>>? _list;
          if (snapshot.hasData && snapshot.data != null) {
            _list = snapshot.data!;
          }
          if (_list == null) {
            return Container(
              margin: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 0),
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                      color: _appConfig!.whiteColor.withOpacity(0.15))),
              child: SkeletonContainer(
                width: double.infinity,
                height: 200,
                //backgroundColor: Colors.transparent,
              ),
            );
          } else {
            if (_list.isEmpty) {
              return const SizedBox();
            }
            return Container(
              width: double.infinity,
              // height: 200,
              margin: const EdgeInsets.fromLTRB(0, 0, 0, 0),
              child: AspectRatio(
                aspectRatio: 343 / 180,
                child: ImageSlider(
                  imageList: _list,
                ),
              ),
            );
          }
        });
  }

  Widget _widgetFeed() {
    return StreamBuilder<List<FeedModel>>(
        stream: _blocFeed.getUserFeed,
        builder: (_, AsyncSnapshot<List<FeedModel>> snapshot) {
          final bool isLoading = !snapshot.hasData;
          List<FeedModel> _list = <FeedModel>[];
          if (snapshot.hasData && snapshot.data != null) {
            _list.addAll(snapshot.data!);
          }

          if (_list.isEmpty) {
            return const SizedBox();
          }
          return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: isLoading ? 5 : _list.length,
              itemBuilder: (_, int index) {
                final FeedModel? data = isLoading ? null : _list[index];
                return FeedWidget(
                  data: data,
                  currentUser: _currentUser,
                  onDelete: (bool isDelete) {
                    _list.removeAt(index);
                    _blocFeed.updateFeed(_list);
                  },
                );
              });
        });
  }
}
