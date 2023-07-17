import 'dart:convert';

import 'package:energym/utils/helpers/firebase/firestore_provider.dart';
import 'package:dio/dio.dart';
import 'package:energym/utils/common/svg_picture_customise.dart';
import 'package:flutter/material.dart';
import 'package:energym/main.dart';
import 'package:energym/utils/common/base_bloc.dart';
import 'package:energym/utils/common/constants.dart';
import 'package:energym/utils/common/env.dart';
import 'package:energym/utils/helpers/internet_connection.dart';
import 'package:energym/reusable_component/custom_dialog.dart';
import 'package:package_info/package_info.dart';
import 'package:provider/provider.dart';
import 'device_info.dart';
import '../../reusable_component/shared_pref_helper.dart';
import 'package:energym/models/user_model.dart';

typedef SuccessResponseCallback<T> = T Function(
    Response response, Map<String, dynamic>? jsonData);
typedef ErrorResponseCallback<T> = T Function(
    Response response, Map<String, dynamic>? jsonData);
typedef DownloadProgress<T> = T Function(String progress);

class APIProvider {
  APIProvider({
    InternetConnection? internetConnection,
  }) : assert(internetConnection != null) {
    _internetConnection = internetConnection!;
  }

  static const Duration TIMEOUT = Duration(seconds: 20);

  InternetConnection? _internetConnection;
  bool isErrorDialogOpen = false;

  void dispose() {
    //dio.close();
  }

  Future<Dio> getDio(String jwtToken) async {
    final BaseOptions dioOptions = BaseOptions()
      //..baseUrl = 'https://production.sweatco.in';
      ..baseUrl = 'https://staging4.sweatco.in';

    dioOptions.headers = {
      // 'Authorization': aGeneralBloc.authToken.value,
      'Authorization': '$jwtToken',
      //'language': aGeneralBloc?.getCurrLocal() ?? 'en',
      //'cache-control': 'no-cache' // set content-length
    };
    dioOptions.responseType = ResponseType.plain;
    dioOptions.connectTimeout = 200000;
    dioOptions.receiveTimeout = 200000;
    final Dio dio = Dio(dioOptions);

    return dio;
  }

  Future<Options> getOption(String jwtToken) async {
    //String token = locator.get<SharedPrefsHelper>().get(SharedPrefskey.token) ?? '';

    print('hello1');
    // String token = await serviceLocator
    //     .get<SharedPrefsHelper>()
    //     .get(SharedPrefsHelper.token) as String;
    // print(token);

    final Options options = Options(headers: {
      'Authorization': jwtToken,
      'Content-Type': 'multipart/form-data',
      'responseType': ResponseType.json,
      //'language': aGeneralBloc?.currLocal?.value ?? 'en',
      //'cache-control': 'no-cache' // set content-length
    });
    //print('options >> ${options.headers}');
    return options;
  }

  static APIProvider of(BuildContext context, {bool listen = false}) {
    return Provider.of<APIProvider>(context, listen: listen);
  }

  Future<Response<dynamic>> getAPICall1(String url, String jwtToken) async {
    final Dio dio = await getDio(jwtToken);
    final Response<dynamic> response = await dio.get(url);
    throwIfNoSuccess(response);
    return response;
  }

  Future<T?> getSweatCoinUser<T>(
    BuildContext context, {
    SuccessResponseCallback<T>? onSuccess,
    ErrorResponseCallback<T>? onError,
  }) async {
    UserModel _currentUser = aGeneralBloc.currentUser!;
    String url =
        '${APIConstant.getSweatCoinUser}${_currentUser.documentId}.json';
    print('getSweatCoinUser url >> $url');
    try {
      //404

      final Dio dio = await getDio(_currentUser.jwtToken!);
      Options option = await getOption(_currentUser.jwtToken!);

      Map<String, dynamic> data = {};
      data[APIConstant.requestKeys.clientId] =
          AppKeyConstant.sweatCoinClientIdProduction;

      final Response<dynamic> response =
          await dio.get(url, queryParameters: data, options: null);

      print('response data >>> ${response.data}');

      Map<String, dynamic>? jsonData;
      if (response.data != null) {
        try {
          jsonData =
              json.decode(response.data as String) as Map<String, dynamic>;
        } catch (e) {
          throw e;
        }
      }
      print('getSweatCoinUser jsonData >> $jsonData');

      final bool successHttpStatusCode =
          response.statusCode! >= 200 && response.statusCode! < 300;

      if (successHttpStatusCode) {
        if (onSuccess == null) {
          return null;
        } else {
          return onSuccess(response, jsonData!);
        }
      } else {
        if (onError != null) {
          _throwApiError(response, context, url);
          return onError(response, jsonData!);
        }
        _throwApiError(response, context, url);
        return null;
      }
    } on DioError catch (e) {
      // The request was made and the server responded with a status code
      // that falls out of the range of 2xx and is also not 304.
      if (e.response != null) {
        Map<String, dynamic> jsonData;
        try {
          jsonData =
              json.decode(e.response?.data as String) as Map<String, dynamic>;
        } catch (e) {
          throw e;
        }
        _throwApiError(e.response!, context, url);
        return onError!(e.response!, jsonData);
      } else {
        _throwApiError(e.response!, context, url);
        return onError!(e.response!, e.response?.data as Map<String, dynamic>);
      }
    }
  }

  Future<T?> addRewardToUaser<T>(
    BuildContext context, {
    required double? amount,
    required String? token,
    required String? description,
    SuccessResponseCallback<T>? onSuccess,
    ErrorResponseCallback<T>? onError,
  }) async {
    String operationUuid = DateTime.now().millisecondsSinceEpoch.toString();
    print('operation_uuid >>> $operationUuid');
    String jwtToken = aGeneralBloc.createjWTToken({
      'amount': amount,
      'authentication_token': token,
      'operation_uuid': operationUuid,
      'title': description
    });

    String url = APIConstant.rewardSweatCoinUser;

    Map<String, dynamic> data = {};
    data[APIConstant.requestKeys.clientId] =
        AppKeyConstant.sweatCoinClientIdProduction;
    data[APIConstant.requestKeys.payload] = jwtToken;

    try {
      //404
      final Dio dio = await getDio(jwtToken);
      Options option = await getOption(jwtToken);

      final Response response =
          await dio.post(url, data: data, options: option);
      print('url >>> ${response.requestOptions.baseUrl}');
      print('addRewardToUaser response data >>> ${response.data}');

      Map<String, dynamic> jsonData = {};
      if (response.data != null && (response.data as String).isNotEmpty) {
        print('addRewardToUaser is not empty >>> ');
        try {
          jsonData =
              json.decode(response.data as String) as Map<String, dynamic>;
        } catch (e) {
          throw e;
        }
      }

      final bool successHttpStatusCode =
          response.statusCode! >= 200 && response.statusCode! < 300;

      if (successHttpStatusCode) {
        jsonData[TransactionCollectionField.amount] = amount;
        jsonData[TransactionCollectionField.transactionDescription] =
            description;
        jsonData[TransactionCollectionField.transactionId] = operationUuid;
        print('addRewardToUaser jsonData >> $jsonData');

        if (onSuccess == null) {
          return null;
        } else {
          return onSuccess(response, jsonData);
        }
      } else {
        if (onError != null) {
          _throwApiError(response, context, url);
          return onError(response, jsonData);
        }
        _throwApiError(response, context, url);
        return null;
      }
    } on DioError catch (e) {
      // The request was made and the server responded with a status code
      // that falls out of the range of 2xx and is also not 304.
      if (e.response != null) {
        Map<String, dynamic> jsonData;
        try {
          jsonData =
              json.decode(e.response?.data as String) as Map<String, dynamic>;
        } catch (e) {
          print('e >>> ${e.toString()}');

          throw e;
        }
        _throwApiError(e.response!, context, url);
        return onError!(e.response!, jsonData);
      } else {
        _throwApiError(e.response!, context, url);
        return onError!(e.response!, e.response?.data as Map<String, dynamic>);
      }
    }
  }

  void throwIfNoSuccess(Response<dynamic> response) {
    if (response.statusCode! < 200 || response.statusCode! > 299) {
      throw HttpException(response);
    }
  }

  void _throwApiError(Response response, BuildContext context, [String? url]) {
    if (response == null) {
      return;
    }

    final Map<String, dynamic> data =
        json.decode(response.data as String) as Map<String, dynamic>;

    if (url == APIConstant.logout) {
      forceLogout(context);
    } else {
      print('data >>> $data');
      if (isErrorDialogOpen == false) {
        isErrorDialogOpen = true;
        CustomAlertDialog().showExeptionErrorMessage(
          context: context,
          //title: 'The given data was invalid',
          title: '',
          message: data['settings']['messageEn'] as String,
          buttonTitle: AppConstants.ok,
          onPress: () {
            isErrorDialogOpen = false;
            int errorCode = data['settings']['code'] as int;
            print('errorCode >>> $errorCode');
            print('response.statusCode >>> ${response.statusCode}');
            if (response.statusCode == 401 || errorCode == 401) {
              forceLogout(context);
            }
          },
          errorIcon: AspectRatio(
            //aspectRatio:  ,
            aspectRatio: Size(500, 400).aspectRatio,
            child: SvgPictureRecolor.asset(
              ImgConstants.backArrow,
              width: double.infinity,
              height: double.infinity,
              boxfix: BoxFit.fill,
            ),
          ),
        );
      }
    }
  }

  Future<void> forceLogout(BuildContext context) async {
    // print('forceLogout >>> ');
    // aGeneralBloc.updateToken(null);
    // aGeneralBloc.updateCurrentUser(null);
    // await sharedPrefsHelper.logout();
    // //await QuickBlox.instance.userLogoutQB();
    // //disconnectFromChat();
    // //userLogoutQB();
    // Navigator.pushNamedAndRemoveUntil(
    //     context, Login.routeName, (route) => false);
  }

  Future<T?> postAPICall<T>(
    BuildContext? context,
    String? url,
    dynamic? data, {
    required String? jwtToken,
    CancelToken? cancelToken,
    SuccessResponseCallback<T>? onSuccess,
    ErrorResponseCallback<T>? onError,
  }) async {
    try {
      //404
      final Dio dio = await getDio(jwtToken!);
      Options option = await getOption(jwtToken);
      final Response response = await dio.post(url!,
          data: data, options: option, cancelToken: cancelToken);
      print('url >>> ${response.requestOptions.baseUrl}');
      Map<String, dynamic>? jsonData;
      if (response.data != null) {
        try {
          jsonData =
              json.decode(response.data as String) as Map<String, dynamic>;
        } catch (e) {
          throw e;
        }
      }

      final bool successHttpStatusCode =
          response.statusCode! >= 200 && response.statusCode! < 300;

      print('jsonData >>> $jsonData');
      // final bool validResponse =
      //     (jsonData != null && jsonData['settings']['status'] == true);

      if (successHttpStatusCode) {
        return onSuccess == null ? null : onSuccess(response, jsonData!);
      } else {
        //print('nikunj  >>> error');
        if (onError != null) {
          _throwApiError(response, context!, url);
          return onError(response, jsonData!);
        }
        _throwApiError(response, context!, url);
        return null;
      }
    } on DioError catch (e) {
      print('e >>> ${e.toString()}');
      // The request was made and the server responded with a status code
      // that falls out of the range of 2xx and is also not 304.
      // if (e.response != null) {
      //   Map<String, dynamic> jsonData;
      //   try {
      //     jsonData =
      //         json.decode(e.response?.data as String) as Map<String, dynamic>;
      //   } catch (e) {
      //     print('e >>> ${e.toString()}');

      //     throw e;
      //   }
      //   _throwApiError(e.response!, context!, url!);
      //   return onError!(e.response!, jsonData);
      // } else {
      //   _throwApiError(e.response!, context!, url!);
      //   return onError!(e.response!, e.response?.data as Map<String, dynamic>);
      // }
    }
  }
}

class HttpException implements Exception {
  HttpException(this.response);

  Response<dynamic> response;
}

//******************* UNUSED METHODS START FOR CLASS APIProvider

// Future<T?> getAPICall<T>(
//   BuildContext? context,
//   String? url, {
//   String? jwtToken,
//   SuccessResponseCallback<T>? onSuccess,
//   ErrorResponseCallback<T>? onError,
// }) async {
//   try {
//     //404

//     final Dio dio = await getDio(jwtToken!);
//     Options option = await getOption(jwtToken);

//     final Response<dynamic> response = await dio.get(url!, options: option);
//     print('url >>> ${response.requestOptions.baseUrl}');

//     Map<String, dynamic>? jsonData;
//     if (response.data != null) {
//       try {
//         jsonData =
//             json.decode(response.data as String) as Map<String, dynamic>;
//       } catch (e) {
//         throw e;
//       }
//     }

//     final bool successHttpStatusCode =
//         response.statusCode! >= 200 && response.statusCode! < 300;
//     final bool validResponse =
//         (jsonData != null && jsonData['settings']['status'] == true);
//     if (successHttpStatusCode && validResponse) {
//       return onSuccess == null ? null : onSuccess(response, jsonData);
//     } else {
//       if (onError != null) {
//         _throwApiError(response, context!, url);
//         return onError(response, jsonData!);
//       }
//       _throwApiError(response, context!, url);
//       return null;
//     }
//   } on DioError catch (e) {
//     // The request was made and the server responded with a status code
//     // that falls out of the range of 2xx and is also not 304.
//     if (e.response != null) {
//       Map<String, dynamic> jsonData;
//       try {
//         jsonData =
//             json.decode(e.response?.data as String) as Map<String, dynamic>;
//       } catch (e) {
//         throw e;
//       }
//       _throwApiError(e.response!, context!, url!);
//       return onError!(e.response!, jsonData);
//     } else {
//       _throwApiError(e.response!, context!, url!);
//       return onError!(e.response!, e.response?.data as Map<String, dynamic>);
//     }
//   }
// }

// Future<T?> getQueryAPICall<T>(
//   BuildContext? context,
//   String? url,
//   Map<String, dynamic>? data, {
//   String? jwtToken,
//   CancelToken? cancelToken,
//   SuccessResponseCallback<T>? onSuccess,
//   ErrorResponseCallback<T>? onError,
// }) async {
//   try {
//     //404

//     final Dio dio = await getDio(jwtToken!);
//     Options option = await getOption(jwtToken);
//     //print('dio.options.headers >>> ${dio.options.headers}');
//     print('url >>> $url');
//     final Response<dynamic> response = await dio.get(url!,
//         queryParameters: data, cancelToken: cancelToken, options: option);
//     Map<String, dynamic>? jsonData;
//     if (response.data != null) {
//       try {
//         jsonData =
//             json.decode(response.data as String) as Map<String, dynamic>;
//       } catch (e) {
//         throw e;
//       }
//     }

//     final bool successHttpStatusCode =
//         response.statusCode! >= 200 && response.statusCode! < 300;
//     final bool validResponse =
//         (jsonData != null && jsonData['settings']['status'] == true);

//     if (successHttpStatusCode && validResponse) {
//       return onSuccess == null ? null : onSuccess(response, jsonData);
//     } else {
//       if (onError != null) {
//         _throwApiError(response, context!);
//         return onError(response, jsonData!);
//       }
//       _throwApiError(response, context!);
//       return null;
//     }
//   } on DioError catch (e) {
//     // The request was made and the server responded with a status code
//     // that falls out of the range of 2xx and is also not 304.

//     if (e.response != null) {
//       Map<String, dynamic> jsonData;
//       try {
//         jsonData =
//             json.decode(e.response?.data as String) as Map<String, dynamic>;
//       } catch (e) {
//         throw e;
//       }
//       _throwApiError(e.response!, context!);
//       return onError!(e.response!, jsonData);
//     } else {
//       //print('e?.response?.data >>> ${e?.response?.data}');
//       _throwApiError(e.response!, context!);
//       return onError!(e.response!, e.response?.data as Map<String, dynamic>);
//     }
//   }
// }

// Future<T?> postQueryAPICall<T>(
//   BuildContext? context,
//   String? url,
//   Map<String, dynamic>? data, {
//   String? jwtToken,
//   SuccessResponseCallback<T>? onSuccess,
//   ErrorResponseCallback<T>? onError,
// }) async {
//   try {
//     //404
//     final Dio dio = await getDio(jwtToken!);
//     Options option = await getOption(jwtToken);
//     final Response response =
//         await dio.post(url!, queryParameters: data, options: option);
//     Map<String, dynamic>? jsonData;
//     if (response.data != null) {
//       try {
//         jsonData =
//             json.decode(response.data as String) as Map<String, dynamic>;
//       } catch (e) {
//         throw e;
//       }
//     }

//     final bool successHttpStatusCode =
//         response.statusCode! >= 200 && response.statusCode! < 300;
//     final bool validResponse =
//         (jsonData != null && jsonData['settings']['status'] == true);

//     if (successHttpStatusCode && validResponse) {
//       return onSuccess == null ? null : onSuccess(response, jsonData);
//     } else {
//       //print('nikunj  >>> error');
//       if (onError != null) {
//         _throwApiError(response, context!, url);
//         return onError(response, jsonData!);
//       }
//       _throwApiError(response, context!, url);
//       return null;
//     }
//   } on DioError catch (e) {
//     // The request was made and the server responded with a status code
//     // that falls out of the range of 2xx and is also not 304.
//     if (e.response != null) {
//       Map<String, dynamic> jsonData;
//       try {
//         jsonData =
//             json.decode(e.response?.data as String) as Map<String, dynamic>;
//       } catch (e) {
//         print('e >>> ${e.toString()}');

//         throw e;
//       }
//       _throwApiError(e.response!, context!, url!);
//       return onError!(e.response!, jsonData);
//     } else {
//       _throwApiError(e.response!, context!, url!);
//       return onError!(e.response!, e.response?.data as Map<String, dynamic>);
//     }
//   }
// }

// Future<Response<dynamic>> getAPICallWithQueryParam(
//     String url, dynamic data, String jwtToken) async {
//   Options option = await getOption(jwtToken);
//   final Dio dio = await getDio(jwtToken);
//   final Response<dynamic> response = await dio.get(url,
//       queryParameters: data as Map<String, dynamic>, options: option);
//   print('url >>> ${response.requestOptions.baseUrl}');
//   throwIfNoSuccess(response);
//   return response;
// }

// Future<Response<dynamic>> formDataPostAPICall(
//     String url, dynamic data, String jwtToken) async {
//   final Dio dio = await getDio(jwtToken);
//   final Response<dynamic> response = await dio.post(url,
//       data: data,
//       options: Options(
//         contentType: 'multipart/form-data',
//       ));
//   print('url >>> ${response.requestOptions.baseUrl}');
//   throwIfNoSuccess(response);
//   return response;
// }

// Future<T?> deleteAPICall<T>(
//   BuildContext? context,
//   String? url,
//   dynamic? data, {
//   String? jwtToken,
//   SuccessResponseCallback<T>? onSuccess,
//   ErrorResponseCallback<T>? onError,
// }) async {
//   // Options option = await getOption();
//   // final Response<dynamic> response = await dio.delete(url, options: option);
//   // print('url >>> ${response.request.baseUrl}');
//   // throwIfNoSuccess(response);
//   // return response;

//   try {
//     //404
//     final Dio dio = await getDio(jwtToken!);
//     Options option = await getOption(jwtToken);
//     final Response response =
//         await dio.delete(url!, data: data, options: option);
//     print('url >>> ${response.requestOptions.baseUrl}');
//     Map<String, dynamic>? jsonData;
//     if (response.data != null) {
//       try {
//         jsonData =
//             json.decode(response.data as String) as Map<String, dynamic>;
//       } catch (e) {
//         throw e;
//       }
//     }

//     final bool successHttpStatusCode =
//         response.statusCode! >= 200 && response.statusCode! < 300;
//     final bool validResponse =
//         (jsonData != null && jsonData['settings']['status'] == true);
//     if (successHttpStatusCode && validResponse) {
//       return onSuccess == null ? null : onSuccess(response, jsonData);
//     } else {
//       //print('nikunj  >>> error');
//       if (onError != null) {
//         _throwApiError(response, context!, url);
//         return onError(response, jsonData!);
//       }
//       _throwApiError(response, context!, url);
//       return null;
//     }
//   } on DioError catch (e) {
//     // The request was made and the server responded with a status code
//     // that falls out of the range of 2xx and is also not 304.
//     if (e.response != null) {
//       print('>>> e response >>> ${e.response}');
//       Map<String, dynamic> jsonData;
//       try {
//         jsonData =
//             json.decode(e.response?.data as String) as Map<String, dynamic>;
//       } catch (e) {
//         print('e >>> ${e.toString()}');

//         throw e;
//       }
//       _throwApiError(e.response!, context!, url!);
//       return onError!(e.response!, jsonData);
//     } else {
//       _throwApiError(e.response!, context!, url!);
//       return onError!(e.response!, e.response?.data as Map<String, dynamic>);
//     }
//   }
// }

// Future<T?> putAPICall<T>(
//   BuildContext? context,
//   String? url,
//   dynamic? data, {
//   String? jwtToken,
//   CancelToken? cancelToken,
//   SuccessResponseCallback<T>? onSuccess,
//   ErrorResponseCallback<T>? onError,
// }) async {
//   try {
//     //404
//     final Dio dio = await getDio(jwtToken!);
//     Options option = await getOption(jwtToken);
//     final Response response = await dio.put(url!,
//         data: data, options: option, cancelToken: cancelToken);
//     print('url >>> ${response.requestOptions.baseUrl}');
//     Map<String, dynamic>? jsonData;
//     if (response.data != null) {
//       try {
//         jsonData =
//             json.decode(response.data as String) as Map<String, dynamic>;
//       } catch (e) {
//         throw e;
//       }
//     }

//     final bool successHttpStatusCode =
//         response.statusCode! >= 200 && response.statusCode! < 300;

//     //print('jsonData >>> $jsonData');
//     final bool validResponse =
//         (jsonData != null && jsonData['settings']['status'] == true);

//     if (successHttpStatusCode && validResponse) {
//       return onSuccess == null ? null : onSuccess(response, jsonData);
//     } else {
//       //print('nikunj  >>> error');
//       if (onError != null) {
//         _throwApiError(response, context!, url);
//         return onError(response, jsonData!);
//       }
//       _throwApiError(response, context!, url);
//       return null;
//     }
//   } on DioError catch (e) {
//     // The request was made and the server responded with a status code
//     // that falls out of the range of 2xx and is also not 304.
//     if (e.response != null) {
//       Map<String, dynamic> jsonData;
//       try {
//         jsonData =
//             json.decode(e.response?.data as String) as Map<String, dynamic>;
//       } catch (e) {
//         print('e >>> ${e.toString()}');

//         throw e;
//       }
//       _throwApiError(e.response!, context!, url!);
//       return onError!(e.response!, jsonData);
//     } else {
//       _throwApiError(e.response!, context!, url!);
//       return onError!(e.response!, e.response?.data as Map<String, dynamic>);
//     }
//   }
// }

// Future<T?>? downloadAPICall<T>(
//   BuildContext? context,
//   String? url,
//   String? localPath, {
//   String? jwtToken,
//   SuccessResponseCallback<T?>? onSuccess,
//   DownloadProgress<T?>? onProgress,
//   ErrorResponseCallback<T?>? onError,
// }) async {
//   try {
//     final Dio? dio = await getDio(jwtToken!);

//     Options? option = await getOption(jwtToken);

//     final Response response = await dio!.download(
//       url!,
//       localPath,
//       onReceiveProgress: (received, total) {
//         if (total != -1) {
//           String progress = (received / total * 100).toStringAsFixed(0) + "%";
//           onProgress!(progress);
//         }
//       },
//     );

//     ResponseBody data = response.data as ResponseBody;

//     final bool successHttpStatusCode =
//         response.statusCode! >= 200 && response.statusCode! < 300;

//     if (successHttpStatusCode) {
//       return onSuccess == null ? null : onSuccess(response, null);
//     } else {
//       //print('nikunj  >>> error');
//       if (onError != null) {
//         _throwApiError(response, context!, url);
//         return onError(response, null);
//       }
//       _throwApiError(response, context!, url);
//       return null;
//     }
//   } on DioError catch (e) {
//     // The request was made and the server responded with a status code
//     // that falls out of the range of 2xx and is also not 304.
//     if (e.response != null) {
//       Map<String, dynamic> jsonData;
//       try {
//         jsonData =
//             json.decode(e.response?.data as String) as Map<String, dynamic>;
//       } catch (e) {
//         print('e >>> ${e.toString()}');

//         throw e;
//       }
//       _throwApiError(e.response!, context!, url!);
//       return onError!(e.response!, jsonData);
//     } else {
//       _throwApiError(e.response!, context!, url!);
//       return onError!(e.response!, e.response?.data as Map<String, dynamic>);
//     }
//   }
// }

// Future<T?>? userFollowUnfollow<T>(
//   BuildContext? context, {
//   String? jwtToken,
//   String? actionType,
//   String? userId,
//   SuccessResponseCallback<T>? onSuccess,
//   ErrorResponseCallback<T>? onError,
// }) async {
//   String method = '$actionType$userId';
//   try {
//     final Dio dio = await getDio(jwtToken!);
//     Options option = await getOption(jwtToken);
//     final Response response =
//         await dio.post(method, data: null, options: option);

//     Map<String, dynamic>? jsonData;
//     if (response.data != null) {
//       try {
//         jsonData =
//             json.decode(response.data as String) as Map<String, dynamic>;
//       } catch (e) {
//         throw e;
//       }
//     }

//     final bool successHttpStatusCode =
//         response.statusCode! >= 200 && response.statusCode! < 300;

//     //print('jsonData >>> $jsonData');
//     final bool validResponse =
//         (jsonData != null && jsonData['settings']['status'] == true);

//     if (successHttpStatusCode && validResponse) {
//       return onSuccess == null ? null : onSuccess(response, jsonData);
//     } else {
//       //print('nikunj  >>> error');
//       if (onError != null) {
//         _throwApiError(response, context!, method);
//         return onError(response, jsonData!);
//       }
//       _throwApiError(response, context!, method);
//       return null;
//     }
//   } on DioError catch (e) {
//     // The request was made and the server responded with a status code
//     // that falls out of the range of 2xx and is also not 304.
//     if (e.response != null) {
//       Map<String, dynamic> jsonData;
//       try {
//         jsonData =
//             json.decode(e.response?.data as String) as Map<String, dynamic>;
//       } catch (e) {
//         print('e >>> ${e.toString()}');

//         throw e;
//       }
//       _throwApiError(e.response!, context!, method);
//       return onError!(e.response!, jsonData);
//     } else {
//       _throwApiError(e.response!, context!, method);
//       return onError!(e.response!, e.response?.data as Map<String, dynamic>);
//     }
//   }
// }

//******************* UNUSED METHODS END FOR CLASS APIPROVIDER

// class APIConstants {
//   static final String userRegister = "user/register";
// }

// class RequestKeys {}
