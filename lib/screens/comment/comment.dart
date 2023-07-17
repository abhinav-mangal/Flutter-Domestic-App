import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:energym/screens/comment/widget_comment.dart';
import 'package:energym/utils/extensions/extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../../app_config.dart';
import '../../models/comment_model.dart';
import '../../models/error_message_model.dart';
import '../../models/user_model.dart';
import '../../reusable_component/custom_scaffold.dart';
import '../../reusable_component/custom_textfield.dart';
import '../../reusable_component/main_app_bar.dart';
import '../../utils/common/base_bloc.dart';
import '../../utils/common/constants.dart';
import '../../utils/helpers/firebase/firestore_provider.dart';
import '../../utils/helpers/routing/router.dart';
import 'comment_bloc.dart';

class CommentArgs extends RoutesArgs {
  CommentArgs({
    @required this.feedId,
  }) : super(isHeroTransition: true);
  final String? feedId;
}

class Comment extends StatefulWidget {
  const Comment({
    Key? key,
    @required this.feedId,
  }) : super(key: key);

  static const String routeName = '/Comment';
  final String? feedId;

  @override
  _CommentState createState() => _CommentState();
}

class _CommentState extends State<Comment> {
  AppConfig? _appConfig;
  String? _feedId;
  CommentBloc? _blocComment;
  TextEditingController? _txtTitleController;
  final ValueNotifier<bool> _isLoading = ValueNotifier(false);
  UserModel? _currentUser;
  List<CommentModel> _list = <CommentModel>[];

  @override
  void initState() {
    _txtTitleController = TextEditingController();
    _currentUser = aGeneralBloc.currentUser;
    _feedId = widget.feedId;
    _blocComment = CommentBloc();
    if (_feedId != null) {
      _blocComment!.getComment(context, _feedId!);
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
      floatingActionButton: null,
    );
  }

  PreferredSizeWidget _getAppBar() {
    return getMainAppBar(
      context,
      _appConfig!,
      backgoundColor: Colors.transparent,
      textColor: _appConfig!.whiteColor,
      title: NavigationBarConstants.comments,
      elevation: 0,
      isBackEnable: false,
      onBack: () {},
      leadingWidget: IconButton(
          icon: Icon(
            Icons.close,
            size: 24,
            color: _appConfig!.whiteColor,
          ),
          onPressed: () {
            aGeneralBloc.updateAPICalling(false);
            Navigator.pop(context, _list.length);
          }),
    );
  }

  Widget _mainContainerWidget(BuildContext mainContext) {
    return Column(
      children: [
        Expanded(child: _widgetCommentView(mainContext)),
        _commentTextView()
      ],
    );
  }

  Widget _widgetCommentView(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (scrollNotification) {
        if (scrollNotification.metrics.axis == Axis.vertical) {
          if (scrollNotification.metrics.pixels ==
              scrollNotification.metrics.maxScrollExtent) {
            _blocComment!.getComment(context, _feedId!);
          }

          return true;
        }
        return false;
      },
      child: Container(
        width: double.infinity,
        height: double.infinity,
        child: StreamBuilder<List<CommentModel>>(
            stream: _blocComment!.getFeedComment,
            builder: (BuildContext context,
                AsyncSnapshot<List<CommentModel>> snapshot) {
              // List<CommentModel> _list = [];
              if (snapshot.hasData && snapshot.data != null) {
                _list = snapshot.data!;
              }
              if (_list.isEmpty) {
                return const SizedBox();
              }
              return ListView.builder(
                  itemCount: _list.length,
                  itemBuilder: (_, int index) {
                    CommentModel comment = _list[index];
                    return CommentWidget(data: comment);
                  });
            }),
      ),
    );
  }

  Widget _commentTextView() {
    final double bootmPading = context.keyboardHeight == 0 ? 40 : 0;
    return Container(
      width: double.infinity,
      color: _appConfig!.borderColor,
      padding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, bootmPading),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          Expanded(
            child: _widgetTextField(context),
          ),
          const SizedBox(
            width: 5,
          ),
          _widgetButtonSend(context),
        ],
      ),
    );
  }

  Widget _widgetTextField(BuildContext context) {
    return StreamBuilder<ErrorMessage>(
      stream: _blocComment!.getMessageErrorMessage,
      initialData: ErrorMessage(false, ''),
      builder: (BuildContext context, AsyncSnapshot<ErrorMessage> snapshot) {
        return CustomTextField(
          context: context,
          controller: _txtTitleController,
          padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 0, 0),
          contentPadding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
          lableText: AppConstants.writeYourComment,
          hindText: AppConstants.writeYourComment,
          inputType: TextInputType.multiline,
          inputAction: TextInputAction.newline,
          enableSuggestions: true,
          isAutocorrect: true,
          maxline: null,
          maxlength: 255,
          errorText: snapshot.data!.errorMessage.isEmpty
              ? null
              : snapshot.data!.errorMessage,
          onchange: (String value) {
            _blocComment!.onChangeMessageValidation(
              value: value,
            );
          },
        );
      },
    );
  }

  Widget _widgetButtonSend(BuildContext context) {
    return StreamBuilder<bool>(
      stream: _blocComment!.validateCommentForm,
      builder: (BuildContext context, AsyncSnapshot<bool> btnEnableSnapshot) {
        bool isValid = false;
        if (btnEnableSnapshot.hasData && btnEnableSnapshot.data != null) {
          isValid = btnEnableSnapshot.data!;
        }
        return ValueListenableBuilder<bool>(
          valueListenable: _isLoading!,
          builder: (BuildContext? context, bool? isloading, Widget? child) {
            return Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                ),
                onPressed: () async {
                  if (isValid && isloading == false) {
                    _isLoading!.value = true;
                    FocusScope.of(context!).unfocus();
                    Map<String, dynamic> data = <String, dynamic>{};
                    data[CommentCollectionField.comment] =
                        _txtTitleController!.text;
                    data[CommentCollectionField.userFullName] =
                        _currentUser!.fullName;
                    data[CommentCollectionField.userId] =
                        _currentUser!.documentId;
                    data[CommentCollectionField.userMobileNumber] =
                        _currentUser!.mobileNumber;
                    data[CommentCollectionField.userProfilePhoto] =
                        _currentUser!.profilePhoto;
                    data[CommentCollectionField.username] =
                        _currentUser!.username;
                    data[CommentCollectionField.postId] = _feedId;
                    data[CommentCollectionField.status] = true;
                    data[CommentCollectionField.createdAt] = Timestamp.now();

                    FireStoreProvider.instance.addComment(
                      context: context,
                      data: data,
                      onSuccess: (Map<String, dynamic> success) {
                        _isLoading!.value = false;
                        _txtTitleController!.clear();

                        _blocComment!.onChangeMessageValidation(
                          value: _txtTitleController!.text,
                        );
                        if (_feedId != null) {
                          _blocComment!
                              .getComment(context, _feedId!, isReset: true);
                        }
                      },
                      onError: (Map<String, dynamic> success) {
                        _isLoading!.value = false;
                      },
                    );
                  }
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    isloading!
                        ? SpinKitCircle(
                            color: _appConfig!.btnPrimaryColor,
                            size: 15,

                            //lineWidth: 3,
                          )
                        : Text(
                            AppConstants.send,
                            style: _appConfig!.linkNormalFontStyle.apply(
                              color: _appConfig!.btnPrimaryColor,
                            ),
                          ),
                    const SizedBox(
                      width: 5,
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
