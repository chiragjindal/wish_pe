class ItemModel {
  String? key;
  String? title;
  late String createdAt;
  List<String>? categoryKeyList;
  String? providerKey;
  String? imageUrl;
  String? price;

  late String userId;
  int? likeCount;
  List<String>? likeList;
  ItemModel({
    this.key,
    this.title,
    required this.userId,
    this.likeCount,
    required this.createdAt,
    this.likeList,
    this.categoryKeyList,
    this.providerKey,
    this.imageUrl,
    this.price,
  });
  toJson() {
    return {
      "userId": userId,
      "title": title,
      "likeCount": likeCount,
      "createdAt": createdAt,
      "likeList": likeList,
      "categoryKeyList": categoryKeyList,
      "providerKey": providerKey,
      "imageUrl": imageUrl,
      "price": price,
    };
  }

  ItemModel.fromJson(Map<dynamic, dynamic> map) {
    key = map['key'];
    title = map['title'];
    userId = map['userId'];
    likeCount = map['likeCount'] ?? 0;
    createdAt = map['createdAt'];
    providerKey = map['providerKey'];
    imageUrl = map['imageUrl'];
    price = map['price'];

    if (map["likeList"] != null) {
      likeList = <String>[];
      map['likeList'].forEach((value) {
        likeList!.add(value);
      });
      likeCount = likeList!.length;
    } else {
      likeList = [];
      likeCount = 0;
    }
    if (map['categoryKeyList'] != null) {
      map['categoryKeyList'].forEach((value) {
        categoryKeyList = <String>[];
        map['categoryKeyList'].forEach((value) {
          categoryKeyList!.add(value);
        });
      });
    } else {
      categoryKeyList = [];
    }
  }
}
