class ListModel {
  String? key;
  String? name;
  String? description;
  String? story;
  late String userId;
  late String createdAt;
  List<String>? itemKeyList;
  List<String>? likeList;
  ListPrivacyLevel? privacyLevel;
  bool isDefault = false;
  String? listImagePath;
  ListModel(
      {this.key,
      this.name,
      this.description,
      this.story,
      required this.userId,
      required this.createdAt,
      this.itemKeyList,
      this.likeList,
      this.privacyLevel,
      this.isDefault = false,
      this.listImagePath});
  toJson() {
    return {
      "userId": userId,
      "name": name,
      "description": description,
      "story": story,
      "createdAt": createdAt,
      "itemKeyList": itemKeyList,
      "likeList": likeList,
      "isDefault": isDefault,
      "listImagePath": listImagePath,
      "privacyLevel": privacyLevel == null
          ? ListPrivacyLevel.Private.toString()
          : privacyLevel.toString(),
    };
  }

  ListModel.fromJson(Map<dynamic, dynamic> map) {
    key = map['key'];
    name = map['name'];
    description = map['description'];
    story = map['story'];
    userId = map['userId'];
    createdAt = map['createdAt'];
    isDefault = map['isDefault'] ?? false;
    listImagePath = map['listImagePath'];

    privacyLevel = ListPrivacyLevel.values.firstWhere(
        (element) => element.toString() == map['privacyLevel'],
        orElse: () => ListPrivacyLevel.Private);

    if (map['itemKeyList'] != null) {
      itemKeyList = <String>[];
      map['itemKeyList'].forEach((value) {
        itemKeyList!.add(value);
      });
    } else {
      itemKeyList = [];
    }

    if (map["likeList"] != null) {
      likeList = <String>[];
      map["likeList"].forEach((value) {
        likeList!.add(value);
      });
    } else {
      likeList = [];
    }
  }
}

enum ListPrivacyLevel {
  Public,
  Private,
  Shared,
}
