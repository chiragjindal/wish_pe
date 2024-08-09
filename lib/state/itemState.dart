import 'dart:async';
import 'dart:io';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/firebase_database.dart' as database;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:wish_pe/helper/enum.dart';
import 'package:wish_pe/helper/fileHelper.dart';
import 'package:wish_pe/helper/shared_prefrence_helper.dart';
import 'package:wish_pe/model/itemDetailModel.dart';
import 'package:wish_pe/model/itemModel.dart';
import 'package:wish_pe/helper/utility.dart';
import 'package:wish_pe/model/user.dart';
import 'package:wish_pe/state/appState.dart';
import 'package:wish_pe/state/listState.dart';
import 'package:wish_pe/ui/unused/locator.dart';

import 'package:path/path.dart' as path;

class ItemState extends AppState {
  late UserModel? _currentUser;
  UserModel? get currentUser => _currentUser;
  void _setCurrentUser() async {
    _currentUser = await getIt<SharedPreferenceHelper>().getUserProfile();
  }

  bool isBusy = false;

  List<ItemModel>? _itemList;
  database.Query? _itemQuery;
  database.Query? _itemDetailQuery;

  final Map<String, ItemDetailModel> _cachedItemDetails = {};
  Map<String, ItemDetailModel>? get cachedItemDetails => _cachedItemDetails;

  Map<String, List<String>> _categoryProvidersMap = {};

  List<ItemModel>? getItems(List<String>? itemKeyList) {
    if (isBusy || _itemList == null) {
      return null;
    }

    List<ItemModel>? list = _itemList!
        .where((element) => itemKeyList!.contains(element.key))
        .toList();
    return list.isNotEmpty ? list : null;
  }

  ItemModel getItem(String itemKey) {
    return getItems([itemKey])!.first;
  }

  //---------------search-----------------
  List<ItemModel>? getSearchItems(ListState listState) {
    if (_currentUser == null || isBusy || _itemList == null) {
      return null;
    }

    return getItems(listState.getItemKeys(listState.searchLists ?? []));
  }
  //---------------search-----------------

  //---------------following-----------------
  //from following lists + liked items
  List<ItemModel>? getFollowingItems(ListState listState) {
    if (_currentUser == null || isBusy || _itemList == null) {
      return null;
    }

    return ((getItems(listState
                    .getItemKeys(listState.followingPageLists ?? [])) ??
                []) +
            (likedItems ?? []))
        .toSet()
        .toList();
  }

  List<String>? getTopFollowingCategories(ListState listState) {
    List<ItemModel> allItems = getFollowingItems(listState) ?? [];

    // Flatten the list of ItemModel instances into a list of category keys
    List allCategoryKeys =
        allItems.expand((item) => item.categoryKeyList ?? []).toList();

    // Count the occurrences of each category key
    Map<String, int> categoryCount = {};
    allCategoryKeys.forEach((categoryKey) {
      categoryCount[categoryKey] = (categoryCount[categoryKey] ?? 0) + 1;
    });

    // Sort the category keys based on occurrences in descending order
    List<String> sortedCategories = categoryCount.keys.toList()
      ..sort((a, b) => categoryCount[b]!.compareTo(categoryCount[a]!));

    // Take the top 4 categories
    return sortedCategories.take(4).toList();
  }
  //---------------following-----------------

  //---------------Library-----------------
  //My Liked Items
  List<ItemModel>? get likedItems {
    if (_currentUser == null || isBusy || _itemList == null) {
      return null;
    }

    List<ItemModel>? list = _itemList!
        .where((element) => element.likeList!.contains(_currentUser!.userId))
        .toList();

    return list.isNotEmpty ? list : null;
  }
  //---------------Library-----------------

  List<ItemModel>? getItemsByCategory(
      String? categoryKey, ListState listState) {
    if (categoryKey != null && categoryKey.isNotEmpty) {
      return getSearchItems(listState)!
          .where((x) =>
              x.title != null && x.categoryKeyList!.contains(categoryKey))
          .toList();
    }
    return null;
  }

  List<String>? getProvidersByCategory(
      String? categoryKey, ListState listState) {
    if (_categoryProvidersMap.containsKey(categoryKey))
      return _categoryProvidersMap[categoryKey]!;

    getSearchItems(listState)!.forEach((item) {
      List<String>? categories = item.categoryKeyList;
      String? providerKey = item.providerKey;

      if (categories != null && providerKey != null) {
        for (String category in categories) {
          if (category == categoryKey) {
            _categoryProvidersMap
                .putIfAbsent(category, () => [])
                .add(providerKey);
          }
        }
      }
    });

    return _categoryProvidersMap[categoryKey] ?? null;
  }

  List<ItemModel>? getItemsByProvider(
      String? providerKey, String? categoryKey, ListState listState) {
    if (providerKey != null && providerKey.isNotEmpty) {
      return getSearchItems(listState) == null
          ? []
          : getSearchItems(listState)!
              .where((x) =>
                  x.title != null &&
                  x.providerKey == providerKey &&
                  (categoryKey == null ||
                      x.categoryKeyList!.contains(categoryKey)))
              .toList();
    }
    return null;
  }

  Map<String, dynamic> _linkWebInfos = {};
  Map<String, dynamic> get linkWebInfos => _linkWebInfos;
  void addWebInfo(String url, dynamic webInfo) {
    _linkWebInfos.addAll({url: webInfo});
  }

  /// [Subscribe Items] firebase Database
  Future<bool> databaseInit() {
    try {
      if (_itemQuery == null) {
        _itemQuery = kDatabase.child("item");
        _itemQuery!.onChildAdded.listen(_onItemAdded);
        _itemQuery!.onChildChanged.listen(_onItemChanged);
        _itemQuery!.onChildRemoved.listen(_onItemRemoved);
      }

      if (_itemDetailQuery == null) {
        _itemDetailQuery = kDatabase.child("itemDetail");
        _itemDetailQuery!.onChildAdded.listen(_onItemDetailAdded);
        _itemDetailQuery!.onChildChanged.listen(_onItemDetailChanged);
        _itemDetailQuery!.onChildRemoved.listen(_onItemDetailRemoved);
      }

      return Future.value(true);
    } catch (error) {
      cprint(error, errorIn: 'databaseInit');
      return Future.value(false);
    }
  }

  /// get [Item list] from firebase realtime database
  void getDataFromDatabase() {
    try {
      isBusy = true;
      _itemList = null;
      _setCurrentUser();
      notifyListeners();
      kDatabase.child('item').once().then((DatabaseEvent event) {
        final snapshot = event.snapshot;
        _itemList = <ItemModel>[];
        if (snapshot.value != null) {
          var map = snapshot.value as Map<dynamic, dynamic>?;
          if (map != null) {
            map.forEach((key, value) {
              var model = ItemModel.fromJson(value);
              model.key = key;
              _itemList!.add(model);
            });

            /// Sort Item by time
            _itemList!.sort((x, y) => DateTime.parse(x.createdAt)
                .compareTo(DateTime.parse(y.createdAt)));
          }
        } else {
          _itemList = null;
        }
        isBusy = false;
        notifyListeners();
      });
    } catch (error) {
      isBusy = false;
      cprint(error, errorIn: 'getDataFromDatabase');
    }
  }

  void fetchItemDetail(String itemKey) async {
    if (_cachedItemDetails.containsKey(itemKey)) {
      return;
    } else {
      ItemDetailModel _itemDetail;
      var event = await kDatabase.child('itemDetail').child(itemKey).once();
      if (event.snapshot.value != null) {
        var map = event.snapshot.value as Map<dynamic, dynamic>;
        _itemDetail = ItemDetailModel.fromJson(map);
        _itemDetail.key = event.snapshot.key!;
        _cachedItemDetails[itemKey] = _itemDetail;
        return;
      } else {
        return;
      }
    }
  }

  Future<ItemDetailModel?> fetchItemDetailAsync(String itemKey) async {
    if (_cachedItemDetails.containsKey(itemKey)) {
      return cachedItemDetails![itemKey];
    } else {
      ItemDetailModel _itemDetail;
      var event = await kDatabase.child('itemDetail').child(itemKey).once();
      if (event.snapshot.value != null) {
        var map = event.snapshot.value as Map<dynamic, dynamic>;
        _itemDetail = ItemDetailModel.fromJson(map);
        _itemDetail.key = event.snapshot.key!;
        _cachedItemDetails[itemKey] = _itemDetail;
        return _itemDetail;
      } else {
        return null;
      }
    }
  }

  /// create [New Item]
  Future<String?> createItem(ItemModel model,
      {ItemDetailModel? itemDetailModel}) async {
    ///  Create item in [Firebase kDatabase]
    isBusy = true;
    notifyListeners();
    String? itemKey;
    try {
      DatabaseReference dbReference = kDatabase.child('item').push();
      await dbReference.set(model.toJson());
      itemKey = dbReference.key;

      if (itemDetailModel != null) {
        itemDetailModel.key = itemKey;
        await createItemDetail(itemDetailModel);
      }
    } catch (error) {
      cprint(error, errorIn: 'createItem');
    }
    isBusy = false;
    notifyListeners();
    return itemKey;
  }

  Future<void> createItemDetail(ItemDetailModel model) async {
    isBusy = true;
    notifyListeners();
    try {
      await kDatabase.child('itemDetail').child(model.key!).set(model.toJson());
    } catch (error) {
      cprint(error, errorIn: 'createItemDetail');
    }
    isBusy = false;
    notifyListeners();
  }

  deleteItem(String itemKey, {ListState? listState}) {
    try {
      kDatabase.child('item').child(itemKey).remove().then((_) {
        kDatabase.child('itemDetail').child(itemKey).remove();
      }).then((_) {
        kDatabase.child('recentSearch').child(itemKey).remove();
      }).then((_) {
        if (listState != null) {
          for (var list in listState.myLists!) {
            if (list.itemKeyList!.contains(itemKey)) {
              list.itemKeyList!.remove(itemKey);
              listState.updateList(list);
            }
          }
        }
      });
    } catch (error) {
      cprint(error, errorIn: 'deleteItem');
    }
  }

  /// upload [file] to firebase storage and return its  path url
  Future<String?> uploadFile(File file) async {
    try {
      isBusy = true;
      notifyListeners();
      var storageReference = FirebaseStorage.instance
          .ref()
          .child("itemImage")
          .child(path.basename(DateTime.now().toIso8601String() + file.path));
      await storageReference.putFile(file);

      var url = await storageReference.getDownloadURL();
      // ignore: unnecessary_null_comparison
      if (url != null) {
        return url;
      }
      return null;
    } catch (error) {
      cprint(error, errorIn: 'uploadFile');
      return null;
    }
  }

  /// [update] item
  Future<void> updateItem(ItemModel model) async {
    await kDatabase
        .child('item')
        .child(model.key!)
        .set(model.toJson())
        .then((_) {
      ItemDetailModel? detailModel = _cachedItemDetails[model.key!];
      kDatabase
          .child('itemDetail')
          .child(detailModel!.key!)
          .set(detailModel.toJson());
    });
  }

  /// Add/Remove like on a Item
  /// [postId] is item id, [userId] is user's id who like/unlike Item
  addLikeToItem(ItemModel item) {
    try {
      if (item.likeList != null &&
          item.likeList!.isNotEmpty &&
          item.likeList!.any((id) => id == _currentUser!.userId)) {
        // If user wants to undo/remove his like on item
        item.likeList!.removeWhere((id) => id == _currentUser!.userId);
        item.likeCount = item.likeCount! - 1;
      } else {
        // If user like item
        item.likeList ??= [];
        item.likeList!.add(_currentUser!.userId!);
        item.likeCount = item.likeCount! + 1;
      }
      // update likeList of a item
      kDatabase
          .child('item')
          .child(item.key!)
          .child('likeList')
          .set(item.likeList);

      // Sends notification to user who created item
      // UserModel owner can see notification on notification page
      kDatabase.child('notification').child(item.userId).child(item.key!).set({
        'type': item.likeList!.isEmpty
            ? null
            : NotificationType.LikeItem.toString(),
        'updatedAt':
            item.likeList!.isEmpty ? null : DateTime.now().toUtc().toString(),
      });
    } catch (error) {
      cprint(error, errorIn: 'addLikeToItem');
    }
    notifyListeners();
  }

  _onItemChanged(DatabaseEvent event) {
    var model =
        ItemModel.fromJson(event.snapshot.value as Map<dynamic, dynamic>);
    model.key = event.snapshot.key!;
    if (_itemList!.any((x) => x.key == model.key)) {
      var oldEntry = _itemList!.lastWhere((entry) {
        return entry.key == event.snapshot.key;
      });
      _itemList![_itemList!.indexOf(oldEntry)] = model;
    }

    cprint('Item updated');
    isBusy = false;
    notifyListeners();
    // }
  }

  _onItemAdded(DatabaseEvent event) {
    ItemModel item = ItemModel.fromJson(event.snapshot.value as Map);
    item.key = event.snapshot.key!;

    item.key = event.snapshot.key!;
    _itemList ??= <ItemModel>[];
    if ((_itemList!.isEmpty || _itemList!.any((x) => x.key != item.key))) {
      _itemList!.add(item);
      cprint('Item Added');
    }
    isBusy = false;
    notifyListeners();
  }

  _onItemRemoved(DatabaseEvent event) async {
    ItemModel item = ItemModel.fromJson(event.snapshot.value as Map);
    item.key = event.snapshot.key!;
    var itemKey = item.key;

    try {
      late ItemModel deletedItem;
      if (_itemList!.any((x) => x.key == itemKey)) {
        deletedItem = _itemList!.firstWhere((x) => x.key == itemKey);
        _itemList!.remove(deletedItem);

        if (_itemList!.isEmpty) {
          _itemList = null;
        }
        cprint('Item deleted from home page item list');
      }

      /// Delete item image from firebase storage if exist.
      if (deletedItem.imageUrl != null && deletedItem.imageUrl!.isNotEmpty) {
        deleteFile(deletedItem.imageUrl!, 'itemImage');
      }

      /// Delete notification related to deleted Item.
      if (deletedItem.likeCount! > 0) {
        kDatabase
            .child('notification')
            .child(item.userId)
            .child(item.key!)
            .remove();
      }

      //remove from recnt searches
      kDatabase.child('recentSearch').child(item.key!).remove();
      notifyListeners();
    } catch (error) {
      cprint(error, errorIn: '_onItemRemoved');
    }
  }

  _onItemDetailChanged(DatabaseEvent event) {
    var model =
        ItemDetailModel.fromJson(event.snapshot.value as Map<dynamic, dynamic>);
    model.key = event.snapshot.key!;
    if (_cachedItemDetails.containsKey(model.key)) {
      _cachedItemDetails[model.key!] = model;
    }

    cprint('Item updated');
    isBusy = false;
    notifyListeners();
    // }
  }

  _onItemDetailAdded(DatabaseEvent event) {
    ItemDetailModel item =
        ItemDetailModel.fromJson(event.snapshot.value as Map);
    item.key = event.snapshot.key!;

    item.key = event.snapshot.key!;
    if (_cachedItemDetails.isEmpty ||
        _cachedItemDetails.containsKey(item.key)) {
      _cachedItemDetails[item.key!] = item;
      cprint('Item Added');
    }
    isBusy = false;
    notifyListeners();
  }

  _onItemDetailRemoved(DatabaseEvent event) async {
    ItemDetailModel item =
        ItemDetailModel.fromJson(event.snapshot.value as Map);
    item.key = event.snapshot.key!;
    var itemKey = item.key;

    try {
      if (_cachedItemDetails.containsKey(itemKey)) {
        _cachedItemDetails.remove(itemKey);

        cprint('Item deleted from home page item list');
      }
      notifyListeners();
    } catch (error) {
      cprint(error, errorIn: '_onItemRemoved');
    }
  }
}
