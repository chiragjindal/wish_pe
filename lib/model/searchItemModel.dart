// ignore_for_file: avoid_print

class SearchItem {
  String? key;
  String? title;
  late SearchItemType type;
  String? provider;
  String? imageUrl;
  String? userName;
  SearchItem({
    this.key,
    required this.title,
    required this.type,
    this.provider,
    this.imageUrl,
    this.userName,
  });

  toJson() {
    return {
      "key": key,
      "title": title,
      "type": type.toString().split('.').last,
      "provider": provider,
      "image": imageUrl,
      "userName": userName ?? "",
    };
  }

  SearchItem.fromJson(Map<dynamic, dynamic> map) {
    key = map['key'];
    title = map['title'];
    type = _getSearchItemTypeFromString(map['type']);
    provider = map['provider'];
    imageUrl = map['image'];
    userName = map['userName'];
  }

  // Helper function to map string value to enum
  static SearchItemType _getSearchItemTypeFromString(String typeString) {
    switch (typeString.toLowerCase()) {
      case 'provider':
        return SearchItemType.Provider;
      case 'item':
        return SearchItemType.Item;
      case 'list':
        return SearchItemType.List;
      case 'category':
        return SearchItemType.Category;
      case 'profile':
        return SearchItemType.Profile;
      default:
        throw ArgumentError('Invalid SearchItemType: $typeString');
    }
  }
}

enum SearchItemType { Provider, Item, List, Category, Profile }
