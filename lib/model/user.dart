import 'package:equatable/equatable.dart';

// ignore: must_be_immutable
class UserModel extends Equatable {
  String? key;
  String? email;
  String? userId;
  String? displayName;
  String? userName;
  String? webSite;
  String? profilePic;
  String? createdAt;
  bool? isVerified;
  int? followers;
  int? following;
  String? fcmToken;
  List<String>? followersList;
  List<String>? followingList;
  UserType userType = UserType.profile;
  int? listCounter;

  UserModel(
      {this.email,
      this.userId,
      this.displayName,
      this.profilePic,
      this.key,
      this.createdAt,
      this.userName,
      this.followers,
      this.following,
      this.webSite,
      this.isVerified,
      this.fcmToken,
      this.followersList,
      this.followingList,
      this.userType = UserType.profile,
      this.listCounter = 0});

  UserModel.fromJson(Map<dynamic, dynamic>? map) {
    if (map == null) {
      return;
    }
    followersList ??= [];
    followingList ??= [];
    email = map['email'];
    userId = map['userId'];
    displayName = map['displayName'];
    profilePic = map['profilePic'];
    key = map['key'];
    createdAt = map['createdAt'];
    followers = map['followers'];
    following = map['following'];
    userName = map['userName'];
    webSite = map['webSite'];
    fcmToken = map['fcmToken'];
    isVerified = map['isVerified'] ?? false;
    userType = _getUserTypeFromString(map['userType'] ?? 'profile');
    listCounter = map['listCounter'] ?? 0;
    if (map['followerList'] != null) {
      followersList = <String>[];
      map['followerList'].forEach((value) {
        followersList!.add(value);
      });
    }
    followers = followersList != null ? followersList!.length : null;
    if (map['followingList'] != null) {
      followingList = <String>[];
      map['followingList'].forEach((value) {
        followingList!.add(value);
      });
    }
    following = followingList != null ? followingList!.length : null;
  }
  toJson() {
    return {
      'key': key,
      "userId": userId,
      "email": email,
      'displayName': displayName,
      'profilePic': profilePic,
      'createdAt': createdAt,
      'followers': followersList != null ? followersList!.length : null,
      'following': followingList != null ? followingList!.length : null,
      'userName': userName,
      'webSite': webSite,
      'isVerified': isVerified ?? false,
      'fcmToken': fcmToken,
      'followerList': followersList,
      'followingList': followingList,
      "userType": userType.toString().split('.').last,
      'listCounter': listCounter
    };
  }

  UserModel copyWith({
    String? email,
    String? userId,
    String? displayName,
    String? profilePic,
    String? key,
    String? location,
    String? createdAt,
    String? userName,
    int? followers,
    int? following,
    String? webSite,
    bool? isVerified,
    String? fcmToken,
    List<String>? followingList,
    List<String>? followersList,
    UserType? userType,
    int? listCounter,
  }) {
    return UserModel(
        email: email ?? this.email,
        createdAt: createdAt ?? this.createdAt,
        displayName: displayName ?? this.displayName,
        followers: followers ?? this.followers,
        following: following ?? this.following,
        isVerified: isVerified ?? this.isVerified,
        key: key ?? this.key,
        profilePic: profilePic ?? this.profilePic,
        userId: userId ?? this.userId,
        userName: userName ?? this.userName,
        webSite: webSite ?? this.webSite,
        fcmToken: fcmToken ?? this.fcmToken,
        followersList: followersList ?? this.followersList,
        followingList: followingList ?? this.followingList,
        userType: userType ?? this.userType,
        listCounter: listCounter ?? this.listCounter);
  }

  String get getFollower {
    return '${followers ?? 0}';
  }

  String get getFollowing {
    return '${following ?? 0}';
  }

  // Helper function to map string value to enum
  static UserType _getUserTypeFromString(String typeString) {
    switch (typeString.toLowerCase()) {
      case 'provider':
        return UserType.provider;
      case 'profile':
        return UserType.profile;
      default:
        throw ArgumentError('Invalid UserType: $typeString');
    }
  }

  @override
  List<Object?> get props => [
        key,
        email,
        userId,
        displayName,
        userName,
        webSite,
        profilePic,
        createdAt,
        isVerified,
        followers,
        following,
        fcmToken,
        followersList,
        followingList,
        userType,
        listCounter
      ];
}

enum UserType { provider, profile }
