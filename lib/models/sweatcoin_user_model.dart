// To parse this JSON data, do
//
//     final sweatCoinUserModel = sweatCoinUserModelFromJson(jsonString);

import 'dart:convert';

SweatCoinUserModel sweatCoinUserModelFromJson(String str) => SweatCoinUserModel.fromJson(json.decode(str));

//String sweatCoinUserModelToJson(SweatCoinUserModel data) => json.encode(data.toJson());

class SweatCoinUserModel {
    SweatCoinUserModel({
        this.data,
    });

    final Data? data;

    factory SweatCoinUserModel.fromJson(Map<String, dynamic> json) => SweatCoinUserModel(
        data: json["data"] == null ? Data.fromJson(json["data"]) : Data.fromJson(json["data"]),
    );

    // Map<String, dynamic> toJson() => {
    //     "data": data == null ? null : data.toJson(),
    // };
}

class Data {
    Data({
        this.user,
    });

    final SweatCoinUser? user;

    factory Data.fromJson(Map<String, dynamic> json) => Data(
        user: json["user"] == null ? SweatCoinUser.fromJson(json["user"]) : SweatCoinUser.fromJson(json["user"]),
    );

    // Map<String, dynamic> toJson() => {
    //     "user": user == null ? null : user.toJson(),
    // };
}

class SweatCoinUser {
    SweatCoinUser({
        this.username,
        this.balance,
    });

    final String? username;
    final double? balance;

    factory SweatCoinUser.fromJson(Map<String, dynamic> json) => SweatCoinUser(
        username: json["username"] == null ? '' : json["username"],
        balance: json["balance"] == null ? 0.0 : json["balance"],
    );

    Map<String, dynamic> toJson() => {
        "username": username == null ? null : username,
        "balance": balance == null ? null : balance,
    };
}
