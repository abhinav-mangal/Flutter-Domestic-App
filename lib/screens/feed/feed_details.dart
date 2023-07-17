import 'package:energym/app_config.dart';
import 'package:energym/reusable_component/custom_scaffold.dart';
import 'package:energym/reusable_component/main_app_bar.dart';
import 'package:energym/screens/feed/widget_feed.dart';
import 'package:energym/utils/common/base_bloc.dart';
import 'package:energym/utils/common/constants.dart';
import 'package:energym/utils/helpers/firebase/firestore_provider.dart';
import 'package:energym/utils/helpers/routing/router.dart';
import 'package:flutter/material.dart';
import 'package:energym/models/feed_model.dart';
import 'package:energym/models/user_model.dart';

class FeedDetailsArgs extends RoutesArgs {
  FeedDetailsArgs({
    this.feedId,
  }) : super(isHeroTransition: true);
  final String? feedId;
}

class FeedDetails extends StatefulWidget {
  const FeedDetails({
    Key? key,
     this.feedId,
  }) : super(key: key);

  static const String routeName = '/FeedDetails';
  final String? feedId;

  @override
  _FeedDetailsState createState() => _FeedDetailsState();
}

class _FeedDetailsState extends State<FeedDetails> {
  AppConfig? _appConfig;
  String? _feedId;
  TextEditingController? _txtTitleController;
  ValueNotifier<bool>? _isLoading = ValueNotifier(false);
  UserModel? _currentUser;
  @override
  void initState() {
    _txtTitleController = TextEditingController();
    _currentUser = aGeneralBloc.currentUser;
    _feedId = widget.feedId;
    if (_feedId != null) {
      //FireStoreProvider.instance.fetchPostComment(_feedId);
    }
    super.initState();
  }

  @override
  void dispose() {
    _txtTitleController!.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _appConfig = AppConfig.of(context);
    return CustomScaffold(
      appBar: _getAppBar(),
      body: SafeArea(
        bottom: false,
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: Container(
            padding: EdgeInsets.zero,
            width: double.infinity,
            height: double.infinity,
            child: _mainContainerWidget(context),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _getAppBar() {
    return getMainAppBar(
      context,
      _appConfig!,
      backgoundColor: Colors.transparent,
      textColor: _appConfig!.whiteColor,
      title: NavigationBarConstants.feed,
      elevation: 0,
      onBack: () {
        Navigator.pop(context);
      },
    );
  }

  Widget _mainContainerWidget(BuildContext mainContext) {
    return Column(
      children: [
        _widgetFeed()
      ],
    );
  }

  Widget _widgetFeed() {
    return FutureBuilder<FeedModel>(
        future: FireStoreProvider.instance.getPostData(feedId: _feedId!),
        builder: (BuildContext context, AsyncSnapshot<FeedModel> snapshot) {
          FeedModel? data;
          if (snapshot.hasData) {
            data = snapshot.data;
          }
          return FeedWidget(data: data!, currentUser: _currentUser!);
        });
  }
}
