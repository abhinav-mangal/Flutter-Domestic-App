import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:energym/models/group_model.dart';
import 'package:energym/reusable_component/shared_pref_helper.dart';
import 'package:energym/screens/login/login.dart';
import 'package:energym/utils/common/base_bloc.dart';
import 'package:energym/utils/helpers/device_info.dart';
import 'package:energym/utils/helpers/firebase/storage_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:energym/utils/common/constants.dart';
import 'package:energym/utils/helpers/firebase/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:energym/models/user_model.dart';
import 'package:energym/reusable_component/custom_dialog.dart';
import 'package:path/path.dart' as path;
import 'package:energym/models/comment_model.dart';
import 'package:http/http.dart' as http;
import 'package:energym/models/feed_model.dart';
import 'package:energym/models/notification_model.dart';

typedef SuccessResponseCallback<T> = T Function(Map<String, dynamic> jsonData);
typedef ErrorResponseCallback<T> = T Function(Map<String, dynamic> jsonData);

class FireStoreProvider {
  DocumentSnapshot? a;

  FireStoreProvider._privateConstructor();

  static final FireStoreProvider _instance =
      FireStoreProvider._privateConstructor();

  static FireStoreProvider get instance => _instance;

  FireStoreProvider._internal() {}

  final BehaviorSubject<DocumentSnapshot<Map<String, dynamic>>?>?
      _currentUserUpdate =
      BehaviorSubject<DocumentSnapshot<Map<String, dynamic>>?>.seeded(null);

  ValueStream<DocumentSnapshot<Map<String, dynamic>>?>
      get getCurrentUserUpdate => _currentUserUpdate!.stream;

  final BehaviorSubject<DocumentSnapshot<Map<String, dynamic>>?>? _userUpdate =
      BehaviorSubject<DocumentSnapshot<Map<String, dynamic>>?>.seeded(null);

  ValueStream<DocumentSnapshot<Map<String, dynamic>>?> get getUserUpdate =>
      _userUpdate!.stream;

  Future<String> getCMS(String cmsType) {
    return FirebaseFirestore.instance
        .collection(FSCollection.cms)
        .where(CMSCollectionField.type, isEqualTo: cmsType)
        .get()
        .then((QuerySnapshot<Map<String, dynamic>> querySnapshot) {
      final QueryDocumentSnapshot<Map<String, dynamic>> document =
          querySnapshot.docs.first;
      if (document != null) {
        Map<String, dynamic> data = document.data();
        return data['value'] as String;
      } else {
        return '';
      }
      // list.forEach((document) {

      //   print('document value >> ${data['value']}');
      // });
    });
  }

  void alreadySignedIn(BuildContext context) {
    // [START single_value_read]
    String userID = AuthProvider.instance.currentUserId();

    StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _service;

    _service = FirebaseFirestore.instance
        .collection(FSCollection.user)
        .where(UserCollectionField.documentId, isEqualTo: userID)
        .snapshots()
        .listen((QuerySnapshot<Map<String, dynamic>> querySnapshot) async {
      DocumentSnapshot<Map<String, dynamic>> data = querySnapshot.docs.first;
      if (data != null) {
        UserModel _currentUser = UserModel.fromJson(
            data.data() as Map<String, dynamic>,
            doumentId: userID);
        print('alreadySignedIn _currentUser name >> ${_currentUser.fullName}');

        final String fcmToken =
            await sharedPrefsHelper.get(SharedPrefskey.fcmToken) as String;

        print('fcmToken >> $fcmToken');
        print('_currentUser.deviceToken >> ${_currentUser.deviceToken}');
        if (_currentUser.deviceToken != null &&
            _currentUser.deviceToken!.isNotEmpty) {
          if (_currentUser.deviceToken != fcmToken) {
            _service!.cancel();
            const CustomAlertDialog().showAlert(
              context: context,
              title: AppConstants.logout,
              message: AppConstants.loguoutSingleDevice,
              onSuccess: () async {
                aGeneralBloc.updateAPICalling(true);

                AuthProvider.instance.signOut(
                    context: context,
                    isForceLogout: true,
                    onSuccess: (Map<String, dynamic> succesResponse) {
                      aGeneralBloc.updateAPICalling(false);
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        Login.routeName,
                        ModalRoute.withName('/'),
                      );
                    },
                    onError: (Map<String, dynamic> errorResponse) {
                      aGeneralBloc.updateAPICalling(false);
                    });
              },
            );
          }
        }
      }
    });
  }

  Future<List<String>> getDefaultPlaceHolder() async {
    return FirebaseFirestore.instance
        .collection(FSCollection.masterUserPlaceholder)
        .get()
        .then((QuerySnapshot<Map<String, dynamic>> querySnapshot) {
      final List<String> categotyList = querySnapshot.docs
          .map((QueryDocumentSnapshot<Map<String, dynamic>> document) =>
              document.data()['place_holder'] as String)
          .toList();

      return categotyList;
    });
  }

  Future<bool> isUserExists({String? mobile}) async {
    return FirebaseFirestore.instance
        .collection(FSCollection.user)
        .where(UserCollectionField.mobileNumber, isEqualTo: mobile)
        .get()
        .then((QuerySnapshot<Map<String, dynamic>> querySnapshot) {
      final List<DocumentSnapshot<Map<String, dynamic>>> data =
          querySnapshot.docs;

      if (data.isNotEmpty) {
        return true;
      } else {
        return false;
      }
    });
  }

  Future<void> registerNewUser<T>({
    //@required BuildContext context,
    required String? mobile,
    required String? documentId,
    required Map<String, dynamic>? data,
    SuccessResponseCallback<T>? onSuccess,
    ErrorResponseCallback<T>? onError,
  }) async {
    FirebaseFirestore.instance
        .collection(FSCollection.user)
        .doc(documentId)
        .set(data!)
        .then((_) async {
      await FirebaseFirestore.instance
          .collection(FSCollection.user)
          .where(UserCollectionField.mobileNumber, isEqualTo: mobile)
          .get()
          .then((QuerySnapshot<Map<String, dynamic>> querySnapshot) {
        final DocumentSnapshot<Map<String, dynamic>> data =
            querySnapshot.docs.first;
        if (data != null) {
          final Map<String, dynamic> suceessResponse = <String, dynamic>{};
          suceessResponse['user'] = data;
          return onSuccess!(suceessResponse);
        } else {
          final Map<String, dynamic> errorResponse = <String, dynamic>{};
          errorResponse[AppKeyConstant.message] = AppConstants.somethingWronge;
          errorResponse[AppKeyConstant.code] = '201';
          return onError!(errorResponse);
        }
      }).catchError((error) {
        final Map<String, dynamic> errorResponse = <String, dynamic>{};
        errorResponse[AppKeyConstant.message] = error.message;
        errorResponse[AppKeyConstant.code] = error.code;
        return onError!(errorResponse);
      });
    }).catchError((error) {
      final Map<String, dynamic> errorResponse = <String, dynamic>{};
      errorResponse[AppKeyConstant.message] = error.message;
      errorResponse[AppKeyConstant.code] = error.code;
      return onError!(errorResponse);
    });
  }

  Future<void> updateUser<T>({
    //@required BuildContext context,
    required String? userId,
    required Map<String, dynamic>? userData,
    SuccessResponseCallback<T>? onSuccess,
    ErrorResponseCallback<T>? onError,
  }) async {
    FirebaseFirestore.instance
        .collection(FSCollection.user)
        .doc(userId)
        .update(userData!)
        .then((_) {
      final Map<String, dynamic> suceessResponse = <String, dynamic>{};
      suceessResponse['suceess'] = 'Success';
      return onSuccess!(suceessResponse);
    }).catchError((error) {
      final Map<String, dynamic> errorResponse = <String, dynamic>{};
      errorResponse[AppKeyConstant.message] = error.message ?? '';
      errorResponse[AppKeyConstant.code] = error.code ?? '';
      return onError!(errorResponse);
    });
  }

  // void fetchCurrentUser({String? userId}) async {
  //   await FirebaseFirestore.instance
  //       .collection(FSCollection.user)
  //       //.doc(AuthProvider.instance.currentUserId())
  //       .doc(userId ?? AuthProvider.instance.currentUserId())
  //       .get()
  //       .then((DocumentSnapshot<Map<String, dynamic>>? documentSnapshot) {
  //     print('11111');
  //     print(documentSnapshot);
  //     _currentUserUpdate!.sink.add(documentSnapshot!);
  //   });
  // }

  Future<UserModel?> fetchUserInGroup(String groupMember) async {
    await FirebaseFirestore.instance
        .collection(FSCollection.user)
        .where(UserCollectionField.documentId, isEqualTo: groupMember)
        .get()
        .then((QuerySnapshot<Map<String, dynamic>> querySnapshot) {
      final List<DocumentSnapshot<Map<String, dynamic>>> data =
          querySnapshot.docs;

      return UserModel.fromJson(data.first.data()!);
    });
    return null;
  }

  void fetchCurrentUser({String? userId}) {
    FirebaseFirestore.instance
        .collection(FSCollection.user)
        //.doc(AuthProvider.instance.currentUserId())
        .doc(userId ?? AuthProvider.instance.currentUserId())
        .get()
        .then((DocumentSnapshot<Map<String, dynamic>> documentSnapshot) {
      _currentUserUpdate!.sink.add(documentSnapshot);
    });
  }

  void fetchUser({String? userId}) {
    FirebaseFirestore.instance
        .collection(FSCollection.user)
        //.doc(AuthProvider.instance.currentUserId())
        .doc(userId ?? AuthProvider.instance.currentUserId())
        .get()
        .then((DocumentSnapshot<Map<String, dynamic>> documentSnapshot) {
      _userUpdate!.sink.add(documentSnapshot);
    });
  }

  Future<bool> isUserNameExists({
    required String? userName,
  }) async {
    //print('isUserNameExists >>> $userName');
    return FirebaseFirestore.instance
        .collection(FSCollection.user)
        .where(UserCollectionField.username, isEqualTo: userName)
        .get()
        .then((QuerySnapshot<Map<String, dynamic>> querySnapshot) {
      final List<DocumentSnapshot<Map<String, dynamic>>> data =
          querySnapshot.docs;

      if (data.isNotEmpty) {
        return true;
      } else {
        return false;
      }
    });
  }

  Future<bool> isEmailExists({
    required String? email,
  }) async {
    //print('isUserNameExists >>> $userName');
    return FirebaseFirestore.instance
        .collection(FSCollection.user)
        .where(UserCollectionField.email, isEqualTo: email)
        .get()
        .then((QuerySnapshot<Map<String, dynamic>> querySnapshot) {
      final List<DocumentSnapshot<Map<String, dynamic>>> data =
          querySnapshot.docs;

      if (data.isNotEmpty) {
        return true;
      } else {
        return false;
      }
    });
  }

  Future<void> getCurrentUserData(
      {required String? userId,
      Function(UserModel)? onSuccess,
      Function(Map<String, dynamic>)? onError}) async {
    print('userId >>>> $userId');
    FirebaseFirestore.instance
        .collection(FSCollection.user)
        .doc(userId)
        .get()
        .then((DocumentSnapshot<Map<String, dynamic>> documentSnapshot) {
      final UserModel _currentUser =
          UserModel.fromJson(documentSnapshot.data()!);
      return onSuccess!(_currentUser);
    });
  }

  Future<UserModel> getUserData(
      {required String? userId,
      Function(UserModel)? onSuccess,
      Function(Map<String, dynamic>)? onError}) async {
    return FirebaseFirestore.instance
        .collection(FSCollection.user)
        .doc(userId)
        .get()
        .then((DocumentSnapshot<Map<String, dynamic>> documentSnapshot) {
      final UserModel _user = UserModel.fromJson(documentSnapshot.data()!);
      return _user;
    }).catchError((error) {
      return null;
    });
  }

  Future<DocumentSnapshot<Map<String, dynamic>>?> getUserWithMobile(
      {required String? mobile}) async {
    return FirebaseFirestore.instance
        .collection(FSCollection.user)
        .where(UserCollectionField.mobileNumber, isEqualTo: mobile)
        .get()
        .then((QuerySnapshot<Map<String, dynamic>> querySnapshot) {
      final List<DocumentSnapshot<Map<String, dynamic>>> data =
          querySnapshot.docs;

      if (data.isNotEmpty) {
        return data.first;
      } else {
        return null;
      }
    });
  }

  Future<DocumentSnapshot<Map<String, dynamic>>?> getUserWithUsername(
      {required String? username}) async {
    return FirebaseFirestore.instance
        .collection(FSCollection.user)
        .where(UserCollectionField.username, isEqualTo: username)
        .get()
        .then((QuerySnapshot<Map<String, dynamic>> querySnapshot) {
      final List<DocumentSnapshot<Map<String, dynamic>>> data =
          querySnapshot.docs;

      if (data.isNotEmpty) {
        return data.first;
      } else {
        return null;
      }
    });
  }

  Future<bool> isFollowing(
      {required String? uesrId, required String? followerId}) async {
    return FirebaseFirestore.instance
        .collection(FSCollection.follower)
        .where(FollowerCollectionField.userId, isEqualTo: uesrId)
        .where(FollowerCollectionField.followerId, isEqualTo: followerId)
        .get()
        .then((QuerySnapshot<Map<String, dynamic>> querySnapshot) {
      final List<dynamic> data = querySnapshot.docs;

      if (data.isNotEmpty) {
        return true;
      } else {
        return false;
      }
    });
  }

  Future<List<String>> getUserFollowerIds() async {
    return FirebaseFirestore.instance
        .collection(FSCollection.follower)
        .where(FollowerCollectionField.followerId,
            isEqualTo: AuthProvider.instance.currentUserId())
        .get()
        .then((QuerySnapshot<Map<String, dynamic>> querySnapshot) {
      //print('getUserFollowerIds >>> $querySnapshot');
      final List<String> followerIds = querySnapshot.docs
          .map((QueryDocumentSnapshot<Map<String, dynamic>> document) =>
              document.data()[FollowerCollectionField.userId] as String)
          .toList();

      return followerIds;
    });
  }

  Future<void> followUser<T>({
    required BuildContext? context,
    required UserModel? userData,
    required UserModel? followerUserData,
    SuccessResponseCallback<T>? onSuccess,
    ErrorResponseCallback<T>? onError,
  }) async {
    final Map<String, dynamic> data = <String, dynamic>{};

    data[FollowerCollectionField.userId] = userData!.documentId;
    data[FollowerCollectionField.userFullName] = userData.fullName;
    data[FollowerCollectionField.userMobileNumber] = userData.mobileNumber;
    data[FollowerCollectionField.userProfilePhoto] = userData.profilePhoto;
    data[FollowerCollectionField.username] = userData.username;
    data[FollowerCollectionField.followerId] = followerUserData!.documentId;
    data[FollowerCollectionField.followerFullName] = followerUserData.fullName;
    data[FollowerCollectionField.followerSearchNameSet] =
        setSearchParam(followerUserData.fullName!);
    data[FollowerCollectionField.followerMobileNumber] =
        followerUserData.mobileNumber;
    data[FollowerCollectionField.followerProfilePhoto] =
        followerUserData.profilePhoto;
    data[FollowerCollectionField.followerUsername] = followerUserData.username;
    data[FollowerCollectionField.status] = true;
    data[FollowerCollectionField.createdAt] = Timestamp.now();
    //print('data >>>> $data');

    FirebaseFirestore.instance
        .collection(FSCollection.follower)
        .add(data)
        .then((DocumentReference<Map<String, dynamic>> value) async {
      FirebaseFirestore.instance
          .collection(FSCollection.follower)
          .doc(value.id)
          .update({
        FollowerCollectionField.documentId: value.id,
      }).then((_) async {
        Map<String, dynamic> successResponse = <String, dynamic>{};
        successResponse[AppKeyConstant.title] = AppConstants.follow;
        successResponse[AppKeyConstant.message] = AppConstants.followMsg;

        return onSuccess!(successResponse);
      }).catchError((error) {
        Map<String, dynamic> errorResponse = {};
        errorResponse[AppKeyConstant.message] = error.message;
        errorResponse[AppKeyConstant.code] = error.code;

        const CustomAlertDialog().showExeptionErrorMessage(
          context: context,
          title: errorResponse[AppKeyConstant.code] as String,
          message: errorResponse[AppKeyConstant.message] as String,
          buttonTitle: AppConstants.ok,
          onPress: () {},
        );

        return onError!(errorResponse);
      });
    }).catchError((error) {
      final Map<String, dynamic> errorResponse = <String, dynamic>{};
      errorResponse[AppKeyConstant.message] = error.message;
      errorResponse[AppKeyConstant.code] = error.code;

      const CustomAlertDialog().showExeptionErrorMessage(
        context: context,
        title: errorResponse[AppKeyConstant.code] as String,
        message: errorResponse[AppKeyConstant.message] as String,
        buttonTitle: AppConstants.ok,
        onPress: () {},
      );
      return onError!(errorResponse);
    });
  }

  Future<void> unfollowUser<T>({
    required BuildContext? context,
    required UserModel? followUserData,
    SuccessResponseCallback<T>? onSuccess,
    ErrorResponseCallback<T>? onError,
  }) async {
    FirebaseFirestore.instance
        .collection(FSCollection.follower)
        .where(FollowerCollectionField.userId,
            isEqualTo: followUserData!.documentId)
        .where(FollowerCollectionField.followerId,
            isEqualTo: AuthProvider.instance.currentUserId())
        .get()
        .then((QuerySnapshot<Map<String, dynamic>> querySnapshot) {
      final List<DocumentSnapshot<Map<String, dynamic>>> data =
          querySnapshot.docs;
      final DocumentSnapshot<Map<String, dynamic>> document = data.first;
      if (document != null) {
        FirebaseFirestore.instance
            .collection(FSCollection.follower)
            .doc(document.id)
            .delete()
            .then((_) {
          final Map<String, dynamic> successResponse = {};
          successResponse[AppKeyConstant.title] = AppConstants.unfollow;
          successResponse[AppKeyConstant.message] = AppConstants.unfollowMsg;

          return onSuccess!(successResponse);
        }).catchError((error) {
          final Map<String, dynamic> errorResponse = <String, dynamic>{};
          errorResponse[AppKeyConstant.message] = error.message;
          errorResponse[AppKeyConstant.code] = error.code;

          const CustomAlertDialog().showExeptionErrorMessage(
            context: context,
            title: errorResponse[AppKeyConstant.code] as String,
            message: errorResponse[AppKeyConstant.message] as String,
            buttonTitle: AppConstants.ok,
            onPress: () {},
          );
          return onError!(errorResponse);
        });
      } else {
        final Map<String, dynamic> errorResponse = <String, dynamic>{};
        errorResponse[AppKeyConstant.title] = AppConstants.error;
        errorResponse[AppKeyConstant.message] = AppConstants.errotMsg;

        const CustomAlertDialog().showExeptionErrorMessage(
          context: context,
          title: errorResponse[AppKeyConstant.title] as String,
          message: errorResponse[AppKeyConstant.message] as String,
          buttonTitle: AppConstants.ok,
          onPress: () {},
        );
        return onError!(errorResponse);
      }
    });
  }

  Future<int> getFollowerCount({required String? uesrId}) async {
    final QuerySnapshot<Map<String, dynamic>> doucument =
        await FirebaseFirestore.instance
            .collection(FSCollection.follower)
            .where(FollowerCollectionField.userId, isEqualTo: uesrId)
            .get();

    return doucument.size;
  }

  Future<List<Map<String, dynamic>>> getBannerImage() async {
    return FirebaseFirestore.instance
        .collection(FSCollection.bannerMaster)
        .where(BannerCollectionField.isActive, isEqualTo: true)
        //.where(BannerCollectionField.expiryDate, isGreaterThanOrEqualTo: DateTime.now())
        .get()
        .then((QuerySnapshot<Map<String, dynamic>> querySnapshot) {
      final List<Map<String, dynamic>> categotyList = querySnapshot.docs
          .map((QueryDocumentSnapshot<Map<String, dynamic>> document) =>
              document.data() as Map<String, dynamic>)
          .toList();

      return categotyList;
    });
  }

  Future<void> createPost<T>({
    required BuildContext? context,
    required UserModel? userData,
    required String? postType,
    required String? postTitle,
    Map<String, dynamic>? postData,
    File? attachment,
    SuccessResponseCallback<T>? onSuccess,
    ErrorResponseCallback<T>? onError,
  }) async {
    Map<String, dynamic> data = <String, dynamic>{};
    data[PostCollectionField.title] = postTitle;
    data[PostCollectionField.data] = postData;
    data[PostCollectionField.type] = postType;
    data[PostCollectionField.userId] = userData!.documentId;
    data[PostCollectionField.userFullName] = userData.fullName;
    data[PostCollectionField.userMobileNumber] = userData.mobileNumber;
    data[PostCollectionField.userProfilePhoto] = userData.profilePhoto;
    data[PostCollectionField.username] = userData.username;
    data[PostCollectionField.isActive] = true;
    data[PostCollectionField.createdAt] = Timestamp.now();

    FirebaseFirestore.instance
        .collection(FSCollection.post)
        .add(data)
        .then((DocumentReference<Map<String, dynamic>> value) async {
      Map<String, dynamic> updatedData = <String, dynamic>{};

      updatedData[PostCollectionField.documentId] = value.id;
      if (attachment != null) {
        final String fileExtenstion = path.extension(attachment.path);
        final String fileName = '${value.id}$fileExtenstion';

        String? attachmentUrl = await StorageProvider.instance
            .uploadPostAttachment(profilePic: attachment, fileName: fileName);

        if (attachmentUrl != null) {
          updatedData[PostCollectionField.attachment] = [attachmentUrl];
        }
      }

      FirebaseFirestore.instance
          .collection(FSCollection.post)
          .doc(value.id)
          .update(updatedData)
          .then((_) async {
        Map<String, dynamic> successResponse = <String, dynamic>{};
        successResponse[AppKeyConstant.title] = AppConstants.postTitle;
        successResponse[AppKeyConstant.message] = AppConstants.postMsg;

        return onSuccess!(successResponse);
      }).catchError((error) {
        Map<String, dynamic> errorResponse = {};
        errorResponse[AppKeyConstant.message] = error.message;
        errorResponse[AppKeyConstant.code] = error.code;

        const CustomAlertDialog().showExeptionErrorMessage(
          context: context,
          title: errorResponse[AppKeyConstant.code] as String,
          message: errorResponse[AppKeyConstant.message] as String,
          buttonTitle: AppConstants.ok,
          onPress: () {},
        );

        return onError!(errorResponse);
      });
    }).catchError((error) {
      final Map<String, dynamic> errorResponse = <String, dynamic>{};
      errorResponse[AppKeyConstant.message] = error.message;
      errorResponse[AppKeyConstant.code] = error.code;

      const CustomAlertDialog().showExeptionErrorMessage(
        context: context,
        title: errorResponse[AppKeyConstant.code] as String,
        message: errorResponse[AppKeyConstant.message] as String,
        buttonTitle: AppConstants.ok,
        onPress: () {},
      );
      return onError!(errorResponse);
    });
  }

  Future<List<DocumentSnapshot<Map<String, dynamic>?>?>?> getPost(
      BuildContext mainContext,
      {String? userId,
      int? docmentLimit,
      DocumentSnapshot<Map<String, dynamic>?>? lastDocument}) async {
    List<String> userIds = <String>[];
    if (userId != null && userId.isNotEmpty) {
      userIds.add(userId);
    } else {
      userIds = await getUserFollowerIds();
      userIds.add(AuthProvider.instance.currentUserId());
      //print('AuthProvider.instance.currentUserId() >>> ${AuthProvider.instance.currentUserId()}');
    }

    List<DocumentSnapshot<Map<String, dynamic>>>? documentList =
        <DocumentSnapshot<Map<String, dynamic>>>[];

    try {
      if (lastDocument == null) {
        documentList = (await FirebaseFirestore.instance
                .collection(FSCollection.post)
                .where(PostCollectionField.userId, whereIn: userIds)
                .where(PostCollectionField.isActive, isEqualTo: true)
                .orderBy(PostCollectionField.createdAt, descending: true)
                .limit(docmentLimit ?? 20)
                .get())
            .docs;

        debugPrint('documentList last null >> $documentList');
      } else {
        documentList = (await FirebaseFirestore.instance
                .collection(FSCollection.post)
                .where(PostCollectionField.userId, whereIn: userIds)
                .where(PostCollectionField.isActive, isEqualTo: true)
                .orderBy(PostCollectionField.createdAt, descending: true)
                .startAfterDocument(lastDocument)
                .limit(docmentLimit ?? 20)
                .get())
            .docs;

        debugPrint('documentList >> $documentList');
      }

      return documentList;
    } on SocketException {
      const CustomAlertDialog().showExeptionErrorMessage(
        context: mainContext,
        title: AppConstants.noInternetTitle,
        message: AppConstants.noInternetMsg,
        buttonTitle: AppConstants.ok,
        onPress: () {},
      );

      return null;
    } catch (error) {
      print('error >> $error');
      const CustomAlertDialog().showExeptionErrorMessage(
        context: mainContext,
        title: error as String,
        message: error as String,
        buttonTitle: AppConstants.ok,
        onPress: () {},
      );

      return null;
    }
  }

  Future<void> createReport<T>({
    required BuildContext? context,
    required Map<String, dynamic>? data,
    SuccessResponseCallback<T>? onSuccess,
    ErrorResponseCallback<T>? onError,
  }) async {
    FirebaseFirestore.instance
        .collection(FSCollection.report)
        .add(data!)
        .then((DocumentReference<Map<String, dynamic>> value) async {
      Map<String, dynamic> updatedData = <String, dynamic>{};

      updatedData[ReportCollectionField.documentId] = value.id;
      FirebaseFirestore.instance
          .collection(FSCollection.report)
          .doc(value.id)
          .update(updatedData)
          .then((_) async {
        Map<String, dynamic> successResponse = <String, dynamic>{};
        successResponse[AppKeyConstant.title] = AppConstants.postTitle;
        successResponse[AppKeyConstant.message] = AppConstants.postMsg;

        return onSuccess!(successResponse);
      }).catchError((error) {
        Map<String, dynamic> errorResponse = {};
        errorResponse[AppKeyConstant.message] = error.message;
        errorResponse[AppKeyConstant.code] = error.code;

        const CustomAlertDialog().showExeptionErrorMessage(
          context: context,
          title: errorResponse[AppKeyConstant.code] as String,
          message: errorResponse[AppKeyConstant.message] as String,
          buttonTitle: AppConstants.ok,
          onPress: () {},
        );

        return onError!(errorResponse);
      });
    }).catchError((error) {
      final Map<String, dynamic> errorResponse = <String, dynamic>{};
      errorResponse[AppKeyConstant.message] = error.message;
      errorResponse[AppKeyConstant.code] = error.code;

      const CustomAlertDialog().showExeptionErrorMessage(
        context: context,
        title: errorResponse[AppKeyConstant.code] as String,
        message: errorResponse[AppKeyConstant.message] as String,
        buttonTitle: AppConstants.ok,
        onPress: () {},
      );
      return onError!(errorResponse);
    });
  }

  Future<void> deletePost<T>({
    required BuildContext? context,
    required FeedModel? feed,
    SuccessResponseCallback<T>? onSuccess,
    ErrorResponseCallback<T>? onError,
  }) async {
    if (feed != null &&
        feed.attachment != null &&
        feed.attachment!.isNotEmpty) {
      feed.attachment!.forEach((String fileUrl) {
        StorageProvider.instance.deleteFile(fileUrl: fileUrl);
      });
    }

    FirebaseFirestore.instance
        .collection(FSCollection.post)
        .doc(feed?.documentId ?? '')
        .delete()
        .then((_) {
      final Map<String, dynamic> successResponse = {};
      successResponse[AppKeyConstant.title] = AppConstants.unfollow;
      successResponse[AppKeyConstant.message] = AppConstants.unfollowMsg;

      return onSuccess!(successResponse);
    }).catchError((error) {
      final Map<String, dynamic> errorResponse = <String, dynamic>{};
      errorResponse[AppKeyConstant.message] = error.message;
      errorResponse[AppKeyConstant.code] = error.code;

      const CustomAlertDialog().showExeptionErrorMessage(
        context: context,
        title: errorResponse[AppKeyConstant.code] as String,
        message: errorResponse[AppKeyConstant.message] as String,
        buttonTitle: AppConstants.ok,
        onPress: () {},
      );
      return onError!(errorResponse);
    });
  }

  Future<bool> isLiked(
      {required String? uesrId, required String? postId}) async {
    return FirebaseFirestore.instance
        .collection(FSCollection.like)
        .where(LikeCollectionField.userId, isEqualTo: uesrId)
        .where(LikeCollectionField.postId, isEqualTo: postId)
        .get()
        .then((QuerySnapshot<Map<String, dynamic>> querySnapshot) {
      final List<dynamic> data = querySnapshot.docs;

      if (data.isNotEmpty) {
        return true;
      } else {
        return false;
      }
    });
  }

  Future<void> likePost<T>({
    required BuildContext? context,
    required String? postId,
    required UserModel? userData,
    SuccessResponseCallback<T>? onSuccess,
    ErrorResponseCallback<T>? onError,
  }) async {
    final Map<String, dynamic> data = <String, dynamic>{};

    data[LikeCollectionField.postId] = postId;
    data[LikeCollectionField.userId] = userData!.documentId;
    data[LikeCollectionField.userFullName] = userData.fullName;
    data[LikeCollectionField.userMobileNumber] = userData.mobileNumber;
    data[LikeCollectionField.userProfilePhoto] = userData.profilePhoto;
    data[LikeCollectionField.username] = userData.username;
    data[LikeCollectionField.status] = true;
    data[LikeCollectionField.createdAt] = Timestamp.now();
    //print('data >>>> $data');

    FirebaseFirestore.instance
        .collection(FSCollection.like)
        .add(data)
        .then((DocumentReference<Map<String, dynamic>> value) async {
      FirebaseFirestore.instance
          .collection(FSCollection.like)
          .doc(value.id)
          .update({
        LikeCollectionField.documentId: value.id,
      }).then((_) async {
        Map<String, dynamic> successResponse = <String, dynamic>{};
        successResponse[AppKeyConstant.title] = AppConstants.follow;
        successResponse[AppKeyConstant.message] = AppConstants.followMsg;

        return onSuccess!(successResponse);
      }).catchError((error) {
        Map<String, dynamic> errorResponse = {};
        errorResponse[AppKeyConstant.message] = error.message;
        errorResponse[AppKeyConstant.code] = error.code;

        const CustomAlertDialog().showExeptionErrorMessage(
          context: context,
          title: errorResponse[AppKeyConstant.code] as String,
          message: errorResponse[AppKeyConstant.message] as String,
          buttonTitle: AppConstants.ok,
          onPress: () {},
        );

        return onError!(errorResponse);
      });
    }).catchError((error) {
      final Map<String, dynamic> errorResponse = <String, dynamic>{};
      errorResponse[AppKeyConstant.message] = error.message;
      errorResponse[AppKeyConstant.code] = error.code;

      const CustomAlertDialog().showExeptionErrorMessage(
        context: context,
        title: errorResponse[AppKeyConstant.code] as String,
        message: errorResponse[AppKeyConstant.message] as String,
        buttonTitle: AppConstants.ok,
        onPress: () {},
      );
      return onError!(errorResponse);
    });
  }

  Future<void> unLikePost<T>({
    required BuildContext? context,
    required String? postId,
    required String? userId,
    SuccessResponseCallback<T>? onSuccess,
    ErrorResponseCallback<T>? onError,
  }) async {
    FirebaseFirestore.instance
        .collection(FSCollection.like)
        .where(LikeCollectionField.postId, isEqualTo: postId)
        .where(LikeCollectionField.userId, isEqualTo: userId)
        .get()
        .then((QuerySnapshot<Map<String, dynamic>> querySnapshot) {
      final List<DocumentSnapshot<Map<String, dynamic>>> data =
          querySnapshot.docs;
      final DocumentSnapshot<Map<String, dynamic>> document = data.first;
      if (document != null) {
        FirebaseFirestore.instance
            .collection(FSCollection.like)
            .doc(document.id)
            .delete()
            .then((_) {
          final Map<String, dynamic> successResponse = {};
          successResponse[AppKeyConstant.title] = AppConstants.unfollow;
          successResponse[AppKeyConstant.message] = AppConstants.unfollowMsg;

          return onSuccess!(successResponse);
        }).catchError((error) {
          final Map<String, dynamic> errorResponse = <String, dynamic>{};
          errorResponse[AppKeyConstant.message] = error.message;
          errorResponse[AppKeyConstant.code] = error.code;

          const CustomAlertDialog().showExeptionErrorMessage(
            context: context,
            title: errorResponse[AppKeyConstant.code] as String,
            message: errorResponse[AppKeyConstant.message] as String,
            buttonTitle: AppConstants.ok,
            onPress: () {},
          );
          return onError!(errorResponse);
        });
      } else {
        final Map<String, dynamic> errorResponse = <String, dynamic>{};
        errorResponse[AppKeyConstant.title] = AppConstants.error;
        errorResponse[AppKeyConstant.message] = AppConstants.errotMsg;

        const CustomAlertDialog().showExeptionErrorMessage(
          context: context,
          title: errorResponse[AppKeyConstant.title] as String,
          message: errorResponse[AppKeyConstant.message] as String,
          buttonTitle: AppConstants.ok,
          onPress: () {},
        );
        return onError!(errorResponse);
      }
    });
  }

  Future<int> getLikedCount(
      {required String? postId, required String? uesrId}) async {
    final QuerySnapshot<Map<String, dynamic>> doucument =
        await FirebaseFirestore.instance
            .collection(FSCollection.like)
            .where(LikeCollectionField.userId, isEqualTo: uesrId)
            .where(LikeCollectionField.postId, isEqualTo: postId)
            .get();

    return doucument.size;
  }

  Future<List<DocumentSnapshot<Map<String, dynamic>?>?>?> fetchPostComment(
      BuildContext? mainContext,
      {String? feedId,
      int? docmentLimit,
      DocumentSnapshot<Map<String, dynamic>?>? lastDocument}) async {
    List<DocumentSnapshot<Map<String, dynamic>>> documentList =
        <DocumentSnapshot<Map<String, dynamic>>>[];

    try {
      if (lastDocument == null) {
        documentList = (await FirebaseFirestore.instance
                .collection(FSCollection.comment)
                .where(CommentCollectionField.postId, isEqualTo: feedId)
                .orderBy(PostCollectionField.createdAt, descending: true)
                .limit(docmentLimit ?? 20)
                .get())
            .docs;
      } else {
        documentList = (await FirebaseFirestore.instance
                .collection(FSCollection.comment)
                .where(CommentCollectionField.postId, isEqualTo: feedId)
                .orderBy(PostCollectionField.createdAt, descending: true)
                .startAfterDocument(lastDocument)
                .limit(docmentLimit ?? 20)
                .get())
            .docs;
      }

      return documentList;
    } on SocketException {
      const CustomAlertDialog().showExeptionErrorMessage(
        context: mainContext,
        title: AppConstants.noInternetTitle,
        message: AppConstants.noInternetMsg,
        buttonTitle: AppConstants.ok,
        onPress: () {},
      );

      return null;
    } catch (error) {
      //print('error >> $error');
      const CustomAlertDialog().showExeptionErrorMessage(
        context: mainContext,
        title: error as String,
        message: error as String,
        buttonTitle: AppConstants.ok,
        onPress: () {},
      );

      return null;
    }
  }

  Future<void> addComment<T>({
    required BuildContext? context,
    required Map<String, dynamic>? data,
    SuccessResponseCallback<T>? onSuccess,
    ErrorResponseCallback<T>? onError,
  }) async {
    FirebaseFirestore.instance
        .collection(FSCollection.comment)
        .add(data!)
        .then((DocumentReference<Map<String, dynamic>> value) async {
      Map<String, dynamic> updatedData = <String, dynamic>{};

      updatedData[ReportCollectionField.documentId] = value.id;
      FirebaseFirestore.instance
          .collection(FSCollection.comment)
          .doc(value.id)
          .update(updatedData)
          .then((_) async {
        Map<String, dynamic> successResponse = <String, dynamic>{};
        successResponse[AppKeyConstant.title] = AppConstants.postTitle;
        successResponse[AppKeyConstant.message] = AppConstants.postMsg;

        return onSuccess!(successResponse);
      }).catchError((error) {
        Map<String, dynamic> errorResponse = {};
        errorResponse[AppKeyConstant.message] = error.message;
        errorResponse[AppKeyConstant.code] = error.code;

        const CustomAlertDialog().showExeptionErrorMessage(
          context: context,
          title: errorResponse[AppKeyConstant.code] as String,
          message: errorResponse[AppKeyConstant.message] as String,
          buttonTitle: AppConstants.ok,
          onPress: () {},
        );

        return onError!(errorResponse);
      });
    }).catchError((error) {
      final Map<String, dynamic> errorResponse = <String, dynamic>{};
      errorResponse[AppKeyConstant.message] = error.message;
      errorResponse[AppKeyConstant.code] = error.code;

      const CustomAlertDialog().showExeptionErrorMessage(
        context: context,
        title: errorResponse[AppKeyConstant.code] as String,
        message: errorResponse[AppKeyConstant.message] as String,
        buttonTitle: AppConstants.ok,
        onPress: () {},
      );
      return onError!(errorResponse);
    });
  }

  Future<int> getCommentCount({required String postId}) async {
    final QuerySnapshot<Map<String, dynamic>> doucument =
        await FirebaseFirestore.instance
            .collection(FSCollection.comment)
            .where(LikeCollectionField.postId, isEqualTo: postId)
            .get();

    return doucument.size;
  }

  Future<List<DocumentSnapshot<Map<String, dynamic>?>?>?> getUserFollower(
      BuildContext mainContext,
      {required String userId}) async {
    List<DocumentSnapshot<Map<String, dynamic>>> documentList =
        <DocumentSnapshot<Map<String, dynamic>>>[];

    //print('search >> $search');

    try {
      documentList = (await FirebaseFirestore.instance
              .collection(FSCollection.follower)
              .where(FollowerCollectionField.userId, isEqualTo: userId)
              .orderBy(FollowerCollectionField.followerFullName,
                  descending: false)
              .get())
          .docs;

      return documentList;
    } on SocketException {
      const CustomAlertDialog().showExeptionErrorMessage(
        context: mainContext,
        title: AppConstants.noInternetTitle,
        message: AppConstants.noInternetMsg,
        buttonTitle: AppConstants.ok,
        onPress: () {},
      );

      return null;
    } catch (error) {
      //print('error >> $error');
      const CustomAlertDialog().showExeptionErrorMessage(
        context: mainContext,
        title: error as String,
        message: error as String,
        buttonTitle: AppConstants.ok,
        onPress: () {},
      );

      return null;
    }
  }

  Future<void> updatefollowUser<T>({
    required BuildContext? context,
    required String? documentId,
    required UserModel? userData,
    required UserModel? followerUserData,
  }) async {
    final Map<String, dynamic> data = <String, dynamic>{};

    data[FollowerCollectionField.userId] = userData!.documentId;
    data[FollowerCollectionField.userFullName] = userData.fullName;
    data[FollowerCollectionField.userMobileNumber] = userData.mobileNumber;
    data[FollowerCollectionField.userProfilePhoto] = userData.profilePhoto;
    data[FollowerCollectionField.username] = userData.username;
    data[FollowerCollectionField.followerId] = followerUserData!.documentId;
    data[FollowerCollectionField.followerFullName] = followerUserData.fullName;
    data[FollowerCollectionField.followerSearchNameSet] =
        setSearchParam(followerUserData.fullName!);
    data[FollowerCollectionField.followerMobileNumber] =
        followerUserData.mobileNumber;
    data[FollowerCollectionField.followerProfilePhoto] =
        followerUserData.profilePhoto;
    data[FollowerCollectionField.followerUsername] = followerUserData.username;
    //print('data >>>> $data');

    FirebaseFirestore.instance
        .collection(FSCollection.follower)
        .doc(documentId)
        .update(data)
        .then((_) async {
      Map<String, dynamic> successResponse = <String, dynamic>{};
      successResponse[AppKeyConstant.title] = AppConstants.follow;
      successResponse[AppKeyConstant.message] = AppConstants.followMsg;
    });
  }

  Future<void> updateGroup<T>({
    required BuildContext? context,
    required String? groupId,
    required File? groupImage,
    required String? groupName,
    required String? adminId,
    required List<String>? participantesId,
    required List<String>? participantesName,
    required String groupType,
    SuccessResponseCallback<T>? onSuccess,
    ErrorResponseCallback<T>? onError,
  }) async {
    Map<String, dynamic> data = <String, dynamic>{};
    data[GroupCollectionField.groupName] = groupName;
    data[GroupCollectionField.participantId] = participantesId;
    data[GroupCollectionField.participantName] = participantesName;
    data[GroupCollectionField.adminId] = adminId;
    data[GroupCollectionField.isActivie] = true;
    data[GroupCollectionField.groupType] = groupType;
    data[GroupCollectionField.createdAt] = Timestamp.now();
    data[GroupCollectionField.totalWatts] = 0;

    // FirebaseFirestore.instance
    //     .collection(FSCollection.group)
    //     .add(data)
    //     .then((DocumentReference<Map<String, dynamic>> value) async {
    FirebaseFirestore.instance
        .collection(FSCollection.group)
        .doc(groupId)
        .update(data)
        .then((_) async {
      final Map<String, dynamic> updatedData = <String, dynamic>{};

      updatedData[GroupCollectionField.documentId] = groupId;
      if (groupImage != null) {
        final String fileExtenstion = path.extension(groupImage.path);
        final String fileName = '${groupId}$fileExtenstion';

        String? attachmentUrl = await StorageProvider.instance
            .uploadPostAttachment(profilePic: groupImage, fileName: fileName);

        if (attachmentUrl != null) {
          updatedData[GroupCollectionField.groupProfile] = attachmentUrl;
        }
      }

      FirebaseFirestore.instance
          .collection(FSCollection.group)
          .doc(groupId)
          .update(updatedData)
          .then((_) async {
        Map<String, dynamic> successResponse = <String, dynamic>{};
        successResponse[AppKeyConstant.title] = AppConstants.groupTitle;
        successResponse[AppKeyConstant.message] = AppConstants.groupUpdateMsg;

        return onSuccess!(successResponse);
      }).catchError((error) {
        Map<String, dynamic> errorResponse = {};
        errorResponse[AppKeyConstant.message] = error.message;
        errorResponse[AppKeyConstant.code] = error.code;

        const CustomAlertDialog().showExeptionErrorMessage(
          context: context,
          title: errorResponse[AppKeyConstant.code] as String,
          message: errorResponse[AppKeyConstant.message] as String,
          buttonTitle: AppConstants.ok,
          onPress: () {},
        );

        return onError!(errorResponse);
      });
    }).catchError((error) {
      final Map<String, dynamic> errorResponse = <String, dynamic>{};
      errorResponse[AppKeyConstant.message] = error.message;
      errorResponse[AppKeyConstant.code] = error.code;

      const CustomAlertDialog().showExeptionErrorMessage(
        context: context,
        title: errorResponse[AppKeyConstant.code] as String,
        message: errorResponse[AppKeyConstant.message] as String,
        buttonTitle: AppConstants.ok,
        onPress: () {},
      );
      return onError!(errorResponse);
    });
  }

  Future<void> createGroup<T>({
    required BuildContext? context,
    required File? groupImage,
    required String? groupName,
    required String? adminId,
    required List<String>? participantesId,
    required List<String>? participantesName,
    required String groupType,
    SuccessResponseCallback<T>? onSuccess,
    ErrorResponseCallback<T>? onError,
  }) async {
    Map<String, dynamic> data = <String, dynamic>{};
    data[GroupCollectionField.groupName] = groupName;
    data[GroupCollectionField.participantId] = participantesId;
    data[GroupCollectionField.participantName] = participantesName;
    data[GroupCollectionField.adminId] = adminId;
    data[GroupCollectionField.isActivie] = true;
    data[GroupCollectionField.groupType] = groupType;
    data[GroupCollectionField.createdAt] = Timestamp.now();
    data[GroupCollectionField.totalWatts] = 0;
    if (groupImage == null) data[GroupCollectionField.groupProfile] = '';

    FirebaseFirestore.instance
        .collection(FSCollection.group)
        .add(data)
        .then((DocumentReference<Map<String, dynamic>> value) async {
      final Map<String, dynamic> updatedData = <String, dynamic>{};

      updatedData[GroupCollectionField.documentId] = value.id;
      if (groupImage != null) {
        final String fileExtenstion = path.extension(groupImage.path);
        final String fileName = '${value.id}$fileExtenstion';

        String? attachmentUrl = await StorageProvider.instance
            .uploadPostAttachment(profilePic: groupImage, fileName: fileName);

        if (attachmentUrl != null) {
          updatedData[GroupCollectionField.groupProfile] = attachmentUrl;
        }
      }

      FirebaseFirestore.instance
          .collection(FSCollection.group)
          .doc(value.id)
          .update(updatedData)
          .then((_) async {
        Map<String, dynamic> successResponse = <String, dynamic>{};
        successResponse[AppKeyConstant.title] = AppConstants.groupTitle;
        successResponse[AppKeyConstant.message] = AppConstants.groupMsg;

        return onSuccess!(successResponse);
      }).catchError((error) {
        Map<String, dynamic> errorResponse = {};
        errorResponse[AppKeyConstant.message] = error.message;
        errorResponse[AppKeyConstant.code] = error.code;

        const CustomAlertDialog().showExeptionErrorMessage(
          context: context,
          title: errorResponse[AppKeyConstant.code] as String,
          message: errorResponse[AppKeyConstant.message] as String,
          buttonTitle: AppConstants.ok,
          onPress: () {},
        );

        return onError!(errorResponse);
      });
    }).catchError((error) {
      final Map<String, dynamic> errorResponse = <String, dynamic>{};
      errorResponse[AppKeyConstant.message] = error.message;
      errorResponse[AppKeyConstant.code] = error.code;

      const CustomAlertDialog().showExeptionErrorMessage(
        context: context,
        title: errorResponse[AppKeyConstant.code] as String,
        message: errorResponse[AppKeyConstant.message] as String,
        buttonTitle: AppConstants.ok,
        onPress: () {},
      );
      return onError!(errorResponse);
    });
  }

  List<String> setSearchParam(String name) {
    List<String> caseSearchList = <String>[];
    String temp = "";
    for (int i = 0; i < name.length; i++) {
      temp = temp + name[i];
      caseSearchList.add(temp);
    }
    return caseSearchList;
  }

  Future<List<DocumentSnapshot<Map<String, dynamic>?>?>?> getUserGroups(
    BuildContext mainContext, {
    String? userId,
  }) async {
    List<DocumentSnapshot<Map<String, dynamic>>> documentList =
        <DocumentSnapshot<Map<String, dynamic>>>[];

    try {
      documentList = (await FirebaseFirestore.instance
              .collection(FSCollection.group)
              .where(GroupCollectionField.isActivie, isEqualTo: true)
              .where(GroupCollectionField.participantId, arrayContains: userId)
              .orderBy(GroupCollectionField.createdAt, descending: true)
              .get())
          .docs;

      return documentList;
    } on SocketException {
      const CustomAlertDialog().showExeptionErrorMessage(
        context: mainContext,
        title: AppConstants.noInternetTitle,
        message: AppConstants.noInternetMsg,
        buttonTitle: AppConstants.ok,
        onPress: () {},
      );

      return null;
    } catch (error) {
      //print('error >> $error');
      const CustomAlertDialog().showExeptionErrorMessage(
        context: mainContext,
        title: error as String,
        message: error as String,
        buttonTitle: AppConstants.ok,
        onPress: () {},
      );

      return null;
    }
  }

  Future<void> saveDeviceToken<T>(
      {required BuildContext? context,
      required String? deviceType,
      required String? deviceToke,
      required bool? isLogOut}) async {
    String userDocId = AuthProvider.instance.currentUserId();
    print('saveDeviceToken >>> ');
    print('deviceType >>> $deviceType');
    print('deviceToke >>> $deviceToke');
    // Save it to Firestore
    if (deviceToke != null && userDocId.isNotEmpty) {
      FirebaseFirestore.instance
          .collection(FSCollection.user)
          .doc(userDocId)
          .update({
        UserCollectionField.deviceToken: deviceToke,
        UserCollectionField.deviceType: deviceType
      }).then((_) {
        if (!isLogOut!) {
          FireStoreProvider.instance.alreadySignedIn(context!);
        }
      }).catchError((error) {
        //print('error?.message >> ${error?.message}');
      });
    }
  }

  Future<void> updateSweatCoinBalance<T>({
    required double? balance,
  }) async {
    String userDocId = AuthProvider.instance.currentUserId();
    if (balance != null) {
      FirebaseFirestore.instance
          .collection(FSCollection.user)
          .doc(userDocId)
          .update({
            UserCollectionField.sweatcoinBalance: balance,
          })
          .then((_) {})
          .catchError((error) {
            //print('error?.message >> ${error?.message}');
          });
    }
  }

  Future<String?> getUserDeviceToken({
    required String? userId,
  }) async {
    if (userId != null && userId.isNotEmpty) {
      DocumentSnapshot document = await FirebaseFirestore.instance
          .collection(FSCollection.user)
          .doc(userId)
          .get();
      String? deviceToken;
      if (document != null) {
        Map<String, dynamic> data = document.data() as Map<String, dynamic>;
        deviceToken = data[UserCollectionField.deviceToken] as String;
      }
      return deviceToken;
    } else {
      return null;
    }
  }

  Future<void> sendFcmNotification(
      UserModel senderUser,
      String recivierUserId,
      String notificationType,
      String entityId,
      GroupModel? groupModel,
      String? invitedUserName) async {
    if (senderUser.documentId != recivierUserId ||
        notificationType == NotificationType.welcome ||
        notificationType == NotificationType.ftpReminder ||
        notificationType == NotificationType.follower) {
      try {
        final String? deviceToken = await FireStoreProvider.instance
            .getUserDeviceToken(userId: recivierUserId);
        String message = 'New Notification';
        final Map<String, dynamic> data = <String, dynamic>{};

        switch (notificationType) {
          case NotificationType.likePost:
            message = '${senderUser.fullName} like your post';
            break;
          case NotificationType.commentPost:
            message = '${senderUser.fullName} comment on your post';
            break;
          case NotificationType.welcome:
            message = '${senderUser.fullName} welcome to energym';
            break;
          case NotificationType.ftpReminder:
            message =
                'Hey ${senderUser.fullName}, this is a reminder to check FTP level';
            break;
          case NotificationType.inviteGroupMember:
            message =
                'Reminder: ${senderUser.fullName}, invited you to join the private group ${groupModel?.groupName}';
            data[NotificaitonCollectionField.groupId] = groupModel?.documentId;
            data[NotificaitonCollectionField.invitedMemberName] =
                invitedUserName;

            break;
          case NotificationType.follower:
            message = '${senderUser.fullName} is following you';

            break;
          default:
        }

        data[NotificaitonCollectionField.senderId] = senderUser.documentId;
        data[NotificaitonCollectionField.receiverId] = recivierUserId;
        data[NotificaitonCollectionField.entityType] = notificationType;
        data[NotificaitonCollectionField.entityId] = entityId;
        data[NotificaitonCollectionField.title] = message;
        data[NotificaitonCollectionField.seenStatus] = 0;
        data[NotificaitonCollectionField.isActive] = true;

        String url = 'https://fcm.googleapis.com/fcm/send';
        final Map<String, String> header = {
          'Content-Type': 'application/json',
          'Authorization':
              'key=AAAAr4V-XVo:APA91bE2pRXxvXj9gW91zuhiKlT6M6tB5vru7dWbFfqzk3hJCEKjmQMKN_wtSqaIM9PwJ-CzBFCuYhk5_Wdf5s-uFJgXbPptBbU03iWa9uuwdpSFypIqTrhKBDhqxkPuaE6Qx6WxY1h0',
        };

        final Map<String, Object> request = {
          'notification': {
            'title': 'energym',
            'body': message,
            'sound': true,
          },
          'data': {
            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
            'type': notificationType,
            'extra': data,
          },
          //'priority': 'high',
          'to': deviceToken!,
        };

        print('notificaiton request >> $request');

        final Uri uri = Uri.parse(url);
        final http.Client client = http.Client();
        final http.Response response =
            await client.post(uri, headers: header, body: json.encode(request));
        print('notificaiton response >> ${response.body}');
        final bool successHttpStatusCode =
            response.statusCode >= 200 && response.statusCode < 300;
        if (successHttpStatusCode) {
          data[NotificaitonCollectionField.createdAt] = Timestamp.now();
          FireStoreProvider.instance.createNotification(data: data);
        }
      } catch (e, s) {
        print(e);
      }
    }
  }

  Future<void> createNotification<T>({
    required Map<String, dynamic>? data,
  }) async {
    FirebaseFirestore.instance
        .collection(FSCollection.notification)
        .add(data!)
        .then((DocumentReference<Map<String, dynamic>> value) async {
      final Map<String, dynamic> updatedData = <String, dynamic>{};

      updatedData[GroupCollectionField.documentId] = value.id;
      FirebaseFirestore.instance
          .collection(FSCollection.notification)
          .doc(value.id)
          .update(updatedData)
          .then((_) async {})
          .catchError((error) {});
    }).catchError((error) {});
  }

  Future<List<NotificationModel>> fetchUserNotification(
      @required String userId) async {
    final QuerySnapshot<Map<String, dynamic>> querySnapshot =
        await FirebaseFirestore.instance
            .collection(FSCollection.notification)
            .where(NotificaitonCollectionField.receiverId, isEqualTo: userId)
            .orderBy(NotificaitonCollectionField.createdAt, descending: true)
            .get();

    final List<NotificationModel> notificationList = querySnapshot.docs
        .map((QueryDocumentSnapshot<Map<String, dynamic>> document) =>
            NotificationModel.fromJson(document.data()))
        .toList();

    return notificationList;

    // return FirebaseFirestore.instance
    //     .collection(FSCollection.notification)
    //     .where(NotificaitonCollectionField.receiverId, isEqualTo: userId)
    //     .orderBy(NotificaitonCollectionField.createdAt, descending: true)
    //     .get()
    //     .then((QuerySnapshot<Map<String, dynamic>> querySnapshot) {
    //   final List<NotificationModel> notificationList = querySnapshot.docs
    //       .map((QueryDocumentSnapshot<Map<String, dynamic>> document) =>
    //           NotificationModel.fromJson(document.data()))
    //       .toList();

    //   return notificationList;
    // });
  }

  Future<FeedModel> getPostData({required String? feedId}) async {
    return FirebaseFirestore.instance
        .collection(FSCollection.post)
        .doc(feedId)
        .get()
        .then((DocumentSnapshot<Map<String, dynamic>> documentSnapshot) {
      final FeedModel feed = FeedModel.fromJson(documentSnapshot.data()!);
      return feed;
    }).catchError((error) {
      return null;
    });
  }

  Future<void> createTransaction<T>({
    required BuildContext? context,
    required Map<String, dynamic>? data,
    SuccessResponseCallback<T>? onSuccess,
    ErrorResponseCallback<T>? onError,
  }) async {
    FirebaseFirestore.instance
        .collection(FSCollection.transaction)
        .add(data!)
        .then((DocumentReference<Map<String, dynamic>> value) async {
      final Map<String, dynamic> updatedData = <String, dynamic>{};

      updatedData[TransactionCollectionField.documentId] = value.id;
      print('createTransaction updatedData >>> $updatedData}');
      FirebaseFirestore.instance
          .collection(FSCollection.transaction)
          .doc(value.id)
          .update(updatedData)
          .then((_) async {
        Map<String, dynamic> successResponse = <String, dynamic>{};
        successResponse[AppKeyConstant.title] = AppConstants.workout;
        successResponse[AppKeyConstant.message] = AppConstants.workoutMsg;
        print('createTransaction onSuccess >>> $successResponse}');
        return onSuccess!(successResponse);
      }).catchError((error) {
        print('createTransaction error >>> ${error.toString()}');
        Map<String, dynamic> errorResponse = {};
        errorResponse[AppKeyConstant.message] = error.message;
        errorResponse[AppKeyConstant.code] = error.code;

        const CustomAlertDialog().showExeptionErrorMessage(
          context: context,
          title: errorResponse[AppKeyConstant.code] as String,
          message: errorResponse[AppKeyConstant.message] as String,
          buttonTitle: AppConstants.ok,
          onPress: () {},
        );

        return onError!(errorResponse);
      });
    }).catchError((error) {
      final Map<String, dynamic> errorResponse = <String, dynamic>{};
      errorResponse[AppKeyConstant.message] = error.message;
      errorResponse[AppKeyConstant.code] = error.code;

      const CustomAlertDialog().showExeptionErrorMessage(
        context: context,
        title: errorResponse[AppKeyConstant.code] as String,
        message: errorResponse[AppKeyConstant.message] as String,
        buttonTitle: AppConstants.ok,
        onPress: () {},
      );
      return onError!(errorResponse);
    });
  }

  Future<List<DocumentSnapshot<Map<String, dynamic>?>?>?> getTransaction(
      BuildContext? mainContext,
      {int? docmentLimit,
      DocumentSnapshot<Map<String, dynamic>?>? lastDocument}) async {
    String userId = AuthProvider.instance.currentUserId();

    List<DocumentSnapshot<Map<String, dynamic>>> documentList =
        <DocumentSnapshot<Map<String, dynamic>>>[];

    try {
      if (lastDocument == null) {
        documentList = (await FirebaseFirestore.instance
                .collection(FSCollection.transaction)
                .where(TransactionCollectionField.userId, isEqualTo: userId)
                .where(TransactionCollectionField.status, isEqualTo: true)
                .orderBy(TransactionCollectionField.createdAt, descending: true)
                .limit(docmentLimit ?? 20)
                .get())
            .docs;

        debugPrint('documentList last null >> $documentList');
      } else {
        documentList = (await FirebaseFirestore.instance
                .collection(FSCollection.transaction)
                .where(TransactionCollectionField.userId, isEqualTo: userId)
                .where(TransactionCollectionField.status, isEqualTo: true)
                .orderBy(TransactionCollectionField.createdAt, descending: true)
                .startAfterDocument(lastDocument)
                .limit(docmentLimit ?? 20)
                .get())
            .docs;

        debugPrint('documentList >> $documentList');
      }

      return documentList;
    } on SocketException {
      const CustomAlertDialog().showExeptionErrorMessage(
        context: mainContext,
        title: AppConstants.noInternetTitle,
        message: AppConstants.noInternetMsg,
        buttonTitle: AppConstants.ok,
        onPress: () {},
      );

      return null;
    } catch (error) {
      print('error >> $error');
      const CustomAlertDialog().showExeptionErrorMessage(
        context: mainContext,
        title: error as String,
        message: error as String,
        buttonTitle: AppConstants.ok,
        onPress: () {},
      );

      return null;
    }
  }

  void sigOut() {
    _currentUserUpdate!.sink.add(null);
  }

  Future<void> saveFirebaseWorkoutData<T>({
    required BuildContext? context,
    required UserModel? userData,
    required int? watts,
    required int? resistance,
    required int? calories,
    required int? cadence,
    required double? activeMinutes,
    SuccessResponseCallback<T>? onSuccess,
    ErrorResponseCallback<T>? onError,
  }) async {
    Map<String, dynamic> data = <String, dynamic>{};
    data[WorkoutCollectionField.watts] = watts;
    data[WorkoutCollectionField.resistance] = resistance;
    data[WorkoutCollectionField.calories] = calories;
    data[WorkoutCollectionField.cadence] = cadence;
    data[WorkoutCollectionField.userId] = userData!.documentId;
    data[WorkoutCollectionField.userFullName] = userData.fullName;
    data[WorkoutCollectionField.userMobileNumber] = userData.mobileNumber;
    data[WorkoutCollectionField.userProfilePhoto] = userData.profilePhoto;
    data[WorkoutCollectionField.username] = userData.username;
    data[WorkoutCollectionField.activeMinutes] = activeMinutes;
    data[WorkoutCollectionField.createdAt] = Timestamp.now();

    FirebaseFirestore.instance
        .collection(FSCollection.workout)
        .add(data)
        .then((DocumentReference<Map<String, dynamic>> value) async {
      Map<String, dynamic> updatedData = <String, dynamic>{};

      updatedData[PostCollectionField.documentId] = value.id;

      FirebaseFirestore.instance
          .collection(FSCollection.workout)
          .doc(value.id)
          .update(updatedData)
          .then((_) async {
        Map<String, dynamic> successResponse = <String, dynamic>{};
        successResponse[AppKeyConstant.title] = AppConstants.workout;
        successResponse[AppKeyConstant.message] = AppConstants.workoutAlertMsg;

        return onSuccess!(successResponse);
      }).catchError((error) {
        Map<String, dynamic> errorResponse = {};
        errorResponse[AppKeyConstant.message] = error.message;
        errorResponse[AppKeyConstant.code] = error.code;

        const CustomAlertDialog().showExeptionErrorMessage(
          context: context,
          title: errorResponse[AppKeyConstant.code] as String,
          message: errorResponse[AppKeyConstant.message] as String,
          buttonTitle: AppConstants.ok,
          onPress: () {},
        );

        return onError!(errorResponse);
      });
    }).catchError((error) {
      final Map<String, dynamic> errorResponse = <String, dynamic>{};
      errorResponse[AppKeyConstant.message] = error.message;
      errorResponse[AppKeyConstant.code] = error.code;

      const CustomAlertDialog().showExeptionErrorMessage(
        context: context,
        title: errorResponse[AppKeyConstant.code] as String,
        message: errorResponse[AppKeyConstant.message] as String,
        buttonTitle: AppConstants.ok,
        onPress: () {},
      );
      return onError!(errorResponse);
    });
  }

  Future<List<DocumentSnapshot<Map<String, dynamic>?>?>?> getWorkoutData(
      {required BuildContext mainContext}) async {
    List<DocumentSnapshot<Map<String, dynamic>>>? documentList =
        <DocumentSnapshot<Map<String, dynamic>>>[];

    try {
      documentList = (await FirebaseFirestore.instance
              .collection(FSCollection.workout)
              .where('user_id',
                  isEqualTo: AuthProvider.instance.currentUserId())
              .where('created_at', isLessThan: DateTime.now())
              .where('created_at',
                  isGreaterThanOrEqualTo:
                      DateTime.now().subtract(Duration(days: 6)))
              .get())
          .docs;

      return documentList;
    } on SocketException {
      const CustomAlertDialog().showExeptionErrorMessage(
        context: mainContext,
        title: AppConstants.noInternetTitle,
        message: AppConstants.noInternetMsg,
        buttonTitle: AppConstants.ok,
        onPress: () {},
      );

      return null;
    } catch (error) {
      //print('error >> $error');
      const CustomAlertDialog().showExeptionErrorMessage(
        context: mainContext,
        title: error as String,
        message: error as String,
        buttonTitle: AppConstants.ok,
        onPress: () {},
      );

      return null;
    }
  }

  Future<List<DocumentSnapshot<Map<String, dynamic>>>?> getWorkoutDataSum(
      {required BuildContext mainContext, required int index}) async {
    List<DocumentSnapshot<Map<String, dynamic>>>? documentList =
        <DocumentSnapshot<Map<String, dynamic>>>[];

    try {
      if (index == 0) {
        documentList = (await FirebaseFirestore.instance
                .collection(FSCollection.workout)
                .where('user_id',
                    isEqualTo: AuthProvider.instance.currentUserId())
                .where('created_at',
                    isGreaterThanOrEqualTo: DateTime(DateTime.now().year,
                        DateTime.now().month, DateTime.now().day))
                // .where('created_at', isEqualTo: DateTime.now())
                .get())
            .docs;
      } else if (index == 1) {
        documentList = (await FirebaseFirestore.instance
                .collection(FSCollection.workout)
                .where('user_id',
                    isEqualTo: AuthProvider.instance.currentUserId())
                // .where('created_at', isLessThan: DateTime.now())
                .where('created_at',
                    isGreaterThanOrEqualTo: DateTime(DateTime.now().year,
                            DateTime.now().month, DateTime.now().day)
                        .subtract(Duration(days: 6)))
                .get())
            .docs;
      } else if (index == 2) {
        documentList = (await FirebaseFirestore.instance
                .collection(FSCollection.workout)
                .where('user_id',
                    isEqualTo: AuthProvider.instance.currentUserId())
                // .where('created_at', isLessThan: DateTime.now())
                .where('created_at',
                    isGreaterThanOrEqualTo: DateTime(DateTime.now().year,
                            DateTime.now().month, DateTime.now().day)
                        .subtract(Duration(days: 29)))
                .get())
            .docs;
      }

      return documentList;
    } on SocketException {
      const CustomAlertDialog().showExeptionErrorMessage(
        context: mainContext,
        title: AppConstants.noInternetTitle,
        message: AppConstants.noInternetMsg,
        buttonTitle: AppConstants.ok,
        onPress: () {},
      );

      return null;
    } catch (error) {
      //print('error >> $error');
      const CustomAlertDialog().showExeptionErrorMessage(
        context: mainContext,
        title: error as String,
        message: error as String,
        buttonTitle: AppConstants.ok,
        onPress: () {},
      );

      return null;
    }
  }

  Future<void> registerNewUserWilthEmail<T>({
    //@required BuildContext context,
    required String? email,
    required String? documentId,
    required Map<String, dynamic>? data,
    SuccessResponseCallback<T>? onSuccess,
    ErrorResponseCallback<T>? onError,
  }) async {
    FirebaseFirestore.instance
        .collection(FSCollection.user)
        .doc(documentId)
        .set(data!)
        .then((_) async {
      await FirebaseFirestore.instance
          .collection(FSCollection.user)
          .where(UserCollectionField.email, isEqualTo: email)
          .get()
          .then((QuerySnapshot<Map<String, dynamic>> querySnapshot) {
        final DocumentSnapshot<Map<String, dynamic>> data =
            querySnapshot.docs.first;
        if (data != null) {
          final Map<String, dynamic> suceessResponse = <String, dynamic>{};
          suceessResponse['user'] = data;
          return onSuccess!(suceessResponse);
        } else {
          final Map<String, dynamic> errorResponse = <String, dynamic>{};
          errorResponse[AppKeyConstant.message] = AppConstants.somethingWronge;
          errorResponse[AppKeyConstant.code] = '201';
          return onError!(errorResponse);
        }
      }).catchError((error) {
        final Map<String, dynamic> errorResponse = <String, dynamic>{};
        errorResponse[AppKeyConstant.message] = error.message;
        errorResponse[AppKeyConstant.code] = error.code;
        return onError!(errorResponse);
      });
    }).catchError((error) {
      final Map<String, dynamic> errorResponse = <String, dynamic>{};
      errorResponse[AppKeyConstant.message] = error.message;
      errorResponse[AppKeyConstant.code] = error.code;
      return onError!(errorResponse);
    });
  }

  Future<List<DocumentSnapshot<Map<String, dynamic>?>?>?> getUserLeaderBoard(
      BuildContext mainContext,
      {String? timeZone,
      bool? sortedByWatts,
      bool? sortedByFTP}) async {
    List<DocumentSnapshot<Map<String, dynamic>>> documentList =
        <DocumentSnapshot<Map<String, dynamic>>>[];

    try {
      if (timeZone == '') {
        if (sortedByWatts ?? false) {
          documentList = (await FirebaseFirestore.instance
                  .collection(FSCollection.user)
                  .where(UserCollectionField.isActive, isEqualTo: true)
                  // .orderBy(UserCollectionField.watts, descending: true)
                  .get())
              .docs;
        } else if (sortedByFTP ?? false) {
          documentList = (await FirebaseFirestore.instance
                  .collection(FSCollection.user)
                  .where(UserCollectionField.isActive, isEqualTo: true)
                  // .orderBy(UserCollectionField.ftpLeaderboard, descending: true)
                  .get())
              .docs;
        }
      } else {
        if (sortedByWatts ?? false) {
          documentList = (await FirebaseFirestore.instance
                  .collection(FSCollection.user)
                  .where(UserCollectionField.isActive, isEqualTo: true)
                  .where(UserCollectionField.timeZoneName, isEqualTo: timeZone)
                  // .orderBy(UserCollectionField.watts, descending: true)
                  .get())
              .docs;
        } else if (sortedByFTP ?? false) {
          documentList = (await FirebaseFirestore.instance
                  .collection(FSCollection.user)
                  .where(UserCollectionField.isActive, isEqualTo: true)
                  .where(UserCollectionField.timeZoneName, isEqualTo: timeZone)
                  // .orderBy(UserCollectionField.ftpLeaderboard, descending: true)
                  .get())
              .docs;
        }
      }

      print(documentList);
      return documentList;
    } on SocketException {
      const CustomAlertDialog().showExeptionErrorMessage(
        context: mainContext,
        title: AppConstants.noInternetTitle,
        message: AppConstants.noInternetMsg,
        buttonTitle: AppConstants.ok,
        onPress: () {},
      );

      return null;
    } on FirebaseException {
      print('');
    } catch (error) {
      //print('error >> $error');
      const CustomAlertDialog().showExeptionErrorMessage(
        context: mainContext,
        title: error as String,
        message: error as String,
        buttonTitle: AppConstants.ok,
        onPress: () {},
      );

      return null;
    }
  }

  Future<void> deleteGroup<T>({
    required BuildContext? context,
    required GroupModel? groupModel,
    SuccessResponseCallback<T>? onSuccess,
    ErrorResponseCallback<T>? onError,
  }) async {
    if (groupModel != null && groupModel.groupProfile!.isNotEmpty) {
      StorageProvider.instance.deleteFile(fileUrl: groupModel.groupProfile);
    }

    FirebaseFirestore.instance
        .collection(FSCollection.group)
        .doc(groupModel?.documentId ?? '')
        .delete()
        .then((_) {
      final Map<String, dynamic> successResponse = {};
      successResponse[AppKeyConstant.title] = AppConstants.appName;
      successResponse[AppKeyConstant.message] = 'Test message manish';

      return onSuccess!(successResponse);
    }).catchError((error) {
      final Map<String, dynamic> errorResponse = <String, dynamic>{};
      errorResponse[AppKeyConstant.message] = error.message;
      errorResponse[AppKeyConstant.code] = error.code;

      const CustomAlertDialog().showExeptionErrorMessage(
        context: context,
        title: errorResponse[AppKeyConstant.code] as String,
        message: errorResponse[AppKeyConstant.message] as String,
        buttonTitle: AppConstants.ok,
        onPress: () {},
      );
      return onError!(errorResponse);
    });
  }

  Future<void> updateGroupParticipant<T>({
    required BuildContext context,
    required GroupModel? groupModel,
    required Map<String, dynamic>? data,
    SuccessResponseCallback<T>? onSuccess,
    ErrorResponseCallback<T>? onError,
  }) async {
    FirebaseFirestore.instance
        .collection(FSCollection.group)
        .doc(groupModel?.documentId)
        .update(data!)
        .then((_) {
      final Map<String, dynamic> suceessResponse = <String, dynamic>{};
      suceessResponse['suceess'] = 'Success';
      return onSuccess!(suceessResponse);
    }).catchError((error) {
      final Map<String, dynamic> errorResponse = <String, dynamic>{};
      errorResponse[AppKeyConstant.message] = error.message ?? '';
      errorResponse[AppKeyConstant.code] = error.code ?? '';
      return onError!(errorResponse);
    });
  }

  Future<List<DocumentSnapshot<Map<String, dynamic>?>?>?>
      getPublicGroupsWhichNotJoined(
    BuildContext mainContext, {
    String? userId,
  }) async {
    List<DocumentSnapshot<Map<String, dynamic>>> documentList =
        <DocumentSnapshot<Map<String, dynamic>>>[];
    final List<String> ids = [userId!];
    try {
      documentList = (await FirebaseFirestore.instance
              .collection(FSCollection.group)
              .where(GroupCollectionField.isActivie, isEqualTo: true)
              // .where(GroupCollectionField.participantId, whereNotIn: ids)
              .where(GroupCollectionField.groupType, isEqualTo: 'Public')
              .orderBy(GroupCollectionField.createdAt, descending: true)
              .get())
          .docs;

      return documentList;
    } on SocketException {
      const CustomAlertDialog().showExeptionErrorMessage(
        context: mainContext,
        title: AppConstants.noInternetTitle,
        message: AppConstants.noInternetMsg,
        buttonTitle: AppConstants.ok,
        onPress: () {},
      );

      return null;
    } catch (error) {
      //print('error >> $error');
      const CustomAlertDialog().showExeptionErrorMessage(
        context: mainContext,
        title: error as String,
        message: error as String,
        buttonTitle: AppConstants.ok,
        onPress: () {},
      );

      return null;
    }
  }

  Future<List<DocumentSnapshot<Map<String, dynamic>?>?>?> getAllUsers(
      BuildContext mainContext) async {
    List<DocumentSnapshot<Map<String, dynamic>>> documentList =
        <DocumentSnapshot<Map<String, dynamic>>>[];
    try {
      documentList = (await FirebaseFirestore.instance
              .collection(FSCollection.user)
              .where(UserCollectionField.isActive, isEqualTo: true)
              .orderBy(UserCollectionField.fullName, descending: true)
              .get())
          .docs;

      return documentList;
    } on SocketException {
      const CustomAlertDialog().showExeptionErrorMessage(
        context: mainContext,
        title: AppConstants.noInternetTitle,
        message: AppConstants.noInternetMsg,
        buttonTitle: AppConstants.ok,
        onPress: () {},
      );

      return null;
    } catch (error) {
      //print('error >> $error');
      const CustomAlertDialog().showExeptionErrorMessage(
        context: mainContext,
        title: error as String,
        message: error as String,
        buttonTitle: AppConstants.ok,
        onPress: () {},
      );

      return null;
    }
  }

  Future<GroupModel?> fetchGroup(String groupId) async {
    List<DocumentSnapshot<Map<String, dynamic>>> data = [];
    await FirebaseFirestore.instance
        .collection(FSCollection.group)
        .where(GroupCollectionField.documentId, isEqualTo: groupId)
        .get()
        .then((QuerySnapshot<Map<String, dynamic>> querySnapshot) {
      data = querySnapshot.docs;

      return GroupModel.fromJson(data.first.data()!);
    });
    return GroupModel.fromJson(data.first.data()!);
  }

  Future<void> updateNotification<T>({
    //@required BuildContext context,
    required String? notificaiionId,
    required Map<String, dynamic>? notificationData,
    SuccessResponseCallback<T>? onSuccess,
    ErrorResponseCallback<T>? onError,
  }) async {
    FirebaseFirestore.instance
        .collection(FSCollection.notification)
        .doc(notificaiionId)
        .update(notificationData!)
        .then((_) {
      final Map<String, dynamic> suceessResponse = <String, dynamic>{};
      suceessResponse['suceess'] = 'Success';
      return onSuccess!(suceessResponse);
    }).catchError((error) {
      final Map<String, dynamic> errorResponse = <String, dynamic>{};
      errorResponse[AppKeyConstant.message] = error.message ?? '';
      errorResponse[AppKeyConstant.code] = error.code ?? '';
      return onError!(errorResponse);
    });
  }

  Future<void> saveLevelData<T>({
    required BuildContext context,
    required Map<String, dynamic> data,
    SuccessResponseCallback<T>? onSuccess,
    ErrorResponseCallback<T>? onError,
  }) async {
    FirebaseFirestore.instance
        .collection(FSCollection.level)
        .add(data)
        .then((DocumentReference<Map<String, dynamic>> response) {
      final Map<String, dynamic> suceessResponse = <String, dynamic>{};
      suceessResponse['suceess'] = 'Success';
      return onSuccess!(suceessResponse);
    }).catchError((error) {
      final Map<String, dynamic> errorResponse = <String, dynamic>{};
      errorResponse[AppKeyConstant.message] = error.message ?? '';
      errorResponse[AppKeyConstant.code] = error.code ?? '';
      return onError!(errorResponse);
    });
  }

  Future<Map<String, dynamic>?> fetchLevelData<T>({
    String? userId,
    required SuccessResponseCallback<T>? onSuccess,
    required ErrorResponseCallback<T>? onError,
  }) async {
    FirebaseFirestore.instance
        .collection(FSCollection.level)
        .get()
        .then((QuerySnapshot<Map<String, dynamic>> querySnapshot) {
      final QueryDocumentSnapshot<Map<String, dynamic>> document =
          querySnapshot.docs.first;
      Map<String, dynamic> data = document.data();
      data.forEach((key, value) {
        if (key == userId) {
          onSuccess!(value as Map<String, dynamic>);
          return;
        }
      });
      print(data);
    }).catchError((error) {
      final Map<String, dynamic> errorResponse = <String, dynamic>{};
      errorResponse[AppKeyConstant.message] = error.message ?? '';
      errorResponse[AppKeyConstant.code] = error.code ?? '';
      return onError!(errorResponse);
    });
  }
}

class WorkoutDataKey {
  static String wattsGenerated = 'watts_generated';
  static String caloriesBurned = 'calories_burned';
  static String sweatCoinsEarned = 'sweatcoins_earned';
  static String milesCovered = 'miles_covered';
  static String resistance = 'miles_covered';
  static String ftpValue = 'ftp_value';
  static String oldFtpValue = 'old_ftp_value';
}

class PostType {
  static String general = 'general';
  static String workout = 'workout';
  static String ftpWorkout = 'ftp_workout';
}

class NotificationType {
  static const String likePost = 'like_post';
  static const String commentPost = 'comment_post';
  static const String welcome = 'wellcome';
  static const String ftpReminder = 'ftp_reminder';
  static const String inviteGroupMember = 'invite_group_member';
  static const String inviteGroupMemberDeleted = 'invite_group_member_deleted';
  static const String inviteGroupMemberJoined = 'invite_group_member_joined';
  static const String follower = 'follower';
}

class FSCollection {
  static String cms = 'master_cms';
  static String user = 'user';
  static String masterUserPlaceholder = 'master_user_placeholder';
  static String follower = 'follower';
  static String post = 'post';
  static String bannerMaster = 'banner_master';
  static String report = 'report';
  static String like = 'like';
  static String comment = 'comment';
  static String group = 'group';
  static String notification = 'notification';
  static String transaction = 'transaction';
  static String workout = 'workout';
  static String level = 'level';
}

class CMSCollectionField {
  static String type = 'type';
  static String value = 'value';
}

class CMSType {
  static const String terms = 'terms';
  static const String privacy = 'privacy';
  static const String info = 'info';
}

class UserCollectionField {
  static String documentId = 'document_id';
  static String activeMinuteGoal = 'active_minute_goal';
  static String activityGoal = 'activity_goal';
  static String activityLevel = 'activity_level';
  static String address = 'address';
  static String birthDate = 'birth_date';
  static String gender = 'gender';
  static String calorieGoal = 'calorie_goal';
  static String countryCode = 'country_code';
  static String currStep = 'curr_step';
  static String email = 'email';
  static String energyGenerateGoal = 'energy_generate_goal';
  static String fullName = 'full_name';
  static String height = 'height';
  static String heightType = 'height_type';
  static String isActive = 'is_active';
  static String isVerified = 'is_verified';
  static String latLong = 'lat_long';
  static String mobileNumber = 'mobile_number';
  static String profilePhoto = 'profile_photo';
  static String socialId = 'social_id';
  static String socialLoginType = 'social_login_type';
  static String sweatcoinBalance = 'sweatcoin_balance';
  static String sweatcoinId = 'sweatcoin_id';
  static String sweatcoinTransactions = 'sweatcoin_transactions';
  static String username = 'username';
  static String wight = 'wight';
  static String wightType = 'wight_type';
  static String followers = 'followers';
  static String deviceToken = 'device_token';
  static String deviceType = 'device_type';
  static String jwtToken = 'jwt_tooken';
  static String resistence = 'resistence';
  static String cadence = 'cadence';
  static String watts = 'watts';
  static String calories = 'calories';
  static String timeZoneName = 'time_zone_name';
  static String ftpValue = 'ftp_value';
  static String ftpLeaderboard = 'ftp_value_leaderboard';
  static String workoutCount = 'workout_count';
  static String videoName = 'video_name';
  static String level = 'level';
  static String levelName = 'level_name';
  static String badge = 'badge';
  static String workoutCountInLevel = 'workout_count_in_level';
  static String generatedenergy = 'generated_energy';
}

class FollowerCollectionField {
  static String userId = 'user_id';
  static String userMobileNumber = 'user_mobile_number';
  static String userProfilePhoto = 'user_profile_photo';
  static String userFullName = 'user_full_name';
  static String username = 'username';
  static String followerId = 'follower_id';
  static String followerMobileNumber = 'follower_mobile_number';
  static String followerProfilePhoto = 'follower_profile_photo';
  static String followerFullName = 'follower_full_name';
  static String followerSearchNameSet = 'follower_search_name';
  static String followerUsername = 'follower_username';
  static String status = 'status';
  static String createdAt = 'created_at';
  static String deletedAt = 'deleted_at';
  static String updatedAt = 'updated_at';
  static String documentId = 'document_id';
}

class BannerCollectionField {
  static String bannerImg = 'banner_img';
  static String expiryDate = 'expiry_date';
  static String isActive = 'is_active';
  static String refLink = 'ref_link';
}

class PostCollectionField {
  static String attachment = 'attachment';
  static String createdAt = 'created_at';
  static String description = 'description';
  static String documentId = 'document_id';
  static String title = 'title';
  static String data = 'data';
  static String type = 'type';
  static String updatedAt = 'updated_at';
  static String userFullName = 'user_full_name';
  static String userId = 'user_id';
  static String userMobileNumber = 'user_mobile_number';
  static String userProfilePhoto = 'user_profile_photo';
  static String username = 'username';
  static String isActive = 'is_active';
  static String isUserPost = 'is_user_post';
  static String isLiked = 'is_liked';
}

class ReportType {
  static const String post = 'post';
  static const String user = 'user';
}

class ReportCollectionField {
  static String createdAt = 'created_at';
  static String message = 'message';
  static String documentId = 'document_id';
  static String updatedAt = 'updated_at';
  static String userFullName = 'user_full_name';
  static String userId = 'user_id';
  static String userMobileNumber = 'user_mobile_number';
  static String userProfilePhoto = 'user_profile_photo';
  static String username = 'username';
  static String entityId = 'entity_id';
  static String type = 'type';
  static String senderUserFullName = 'sender_user_full_name';
  static String senderUserId = 'sender_user_id';
  static String senderUserMobileNumber = 'sender_user_mobile_number';
  static String senderUserProfilePhoto = 'sender_user_profile_photo';
  static String senderUsername = 'sender_username';
}

class LikeCollectionField {
  static String documentId = 'document_id';
  static String userFullName = 'user_full_name';
  static String userId = 'user_id';
  static String userMobileNumber = 'user_mobile_number';
  static String userProfilePhoto = 'user_profile_photo';
  static String username = 'username';
  static String postId = 'post_id';
  static String updatedAt = 'updated_at';
  static String createdAt = 'created_at';
  static String status = 'status';
}

class CommentCollectionField {
  static String documentId = 'document_id';
  static String userFullName = 'user_full_name';
  static String userId = 'user_id';
  static String userMobileNumber = 'user_mobile_number';
  static String userProfilePhoto = 'user_profile_photo';
  static String username = 'username';
  static String postId = 'post_id';
  static String updatedAt = 'updated_at';
  static String createdAt = 'created_at';
  static String comment = 'comment';
  static String status = 'status';
}

class GroupCollectionField {
  static String documentId = 'document_id';
  static String groupName = 'group_name';
  static String groupProfile = 'group_profile';
  static String isActivie = 'is_active';
  static String participantId = 'participant_id';
  static String participantName = 'participant_name';
  static String adminId = 'admin_id';
  static String updatedAt = 'updated_at';
  static String createdAt = 'created_at';
  static String groupType = 'group_Type';
  static String totalWatts = 'total_watts';
  static String participantInviteId = 'participant_invite_id';
  static String participantInviteName = 'participant_invite_name';
}

class NotificaitonCollectionField {
  static String documentId = 'document_id';
  static String senderId = 'sender_id';
  static String receiverId = 'receiver_id';
  static String entityType = 'entity_type';
  static String entityId = 'entity_id';
  static String title = 'title';
  static String seenStatus = 'seen_status';
  static String updatedAt = 'updated_at';
  static String createdAt = 'created_at';
  static String isActive = 'is_active';
  static String groupId = 'group_id';
  static String invitedMemberName = 'invited_member_name';
}

class TransactionCollectionField {
  static String documentId = 'document_id';
  static String userId = 'user_id';
  static String transactionId = 'transaction_id';
  static String transactionEntryMode = 'transaction_entry_mode';
  static String transactionEntryType = 'transaction_entry_type';
  static String transactionDescription = 'transaction_description';
  static String referralUserId = 'referral_user_id';
  static String amount = 'amount';
  static String wattsGenerated = 'watts_generated';
  static String updatedAt = 'updated_at';
  static String createdAt = 'created_at';
  static String status = 'status';
}

class TransactionMode {
  static String credit = 'credit';
  static String debit = 'debit';
}

class TransactionType {
  static const String referral = 'referral';
  static const String earned = 'earned';
  static const String spent = 'spent';
}

class WorkoutCollectionField {
  static String documentId = 'document_id';
  static String userId = 'user_id';
  static String reward = 'reward';
  static String watts = 'watts';
  static String resistance = 'resistance';
  static String calories = 'calories';
  static String cadence = 'cadence';
  static String updatedAt = 'updated_at';
  static String createdAt = 'created_at';
  static String userFullName = 'user_full_name';
  static String userMobileNumber = 'user_mobile_number';
  static String userProfilePhoto = 'user_profile_photo';
  static String username = 'username';
  static String activeMinutes = 'activeMinutes';
}
