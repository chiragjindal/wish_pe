import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/firebase_database.dart' as database;
import 'package:wish_pe/helper/shared_prefrence_helper.dart';
import 'package:wish_pe/helper/utility.dart';
import 'package:wish_pe/model/categoryModel.dart';
import 'package:wish_pe/model/itemModel.dart';
import 'package:wish_pe/model/listModel.dart';
import 'package:wish_pe/model/searchItemModel.dart';
import 'package:wish_pe/model/user.dart';
import 'package:wish_pe/ui/unused/locator.dart';
import 'appState.dart';

class SearchState extends AppState {
  late UserModel? _currentUser;
  UserModel? get currentUser => _currentUser;
  void _setCurrentUser() async {
    _currentUser = await getIt<SharedPreferenceHelper>().getUserProfile();
  }

  bool isBusy = false;
  List<UserModel>? _userlist;
  database.Query? _userQuery;

  List<CategoryModel>? _categorylist;
  database.Query? _categoryQuery;

  List<SearchItem>? _searchFilterlist = <SearchItem>[];
  List<SearchItem>? _searchList = <SearchItem>[];

  database.Query? _recentSearchQuery;
  List<SearchItem>? _recentSearchlist;

  List<UserModel>? get userlist {
    if (_userlist == null) {
      return null;
    } else {
      return List.from(_userlist!);
    }
  }

  List<SearchItem>? get recentSearchlist {
    if (_recentSearchlist == null) {
      return null;
    } else {
      return List.from(_recentSearchlist!);
    }
  }

  List<CategoryModel>? get categorylist {
    if (_categorylist == null) {
      return null;
    } else {
      return List.from(_categorylist!);
    }
  }

  List<UserModel>? get providerList {
    if (_userlist == null) {
      return null;
    } else {
      return List.from(_userlist!
          .where((element) => element.userType == UserType.provider)
          .toList()
          .reversed);
    }
  }

  List<UserModel>? get followingProviderList {
    _setCurrentUser();
    if (_userlist == null || currentUser == null) {
      return null;
    } else {
      return List.from(providerList!
          .where((element) =>
              element.followersList != null &&
              element.followersList!.contains(currentUser!.userId))
          .toList()
          .reversed);
    }
  }

  List<SearchItem>? get searchFilterlist {
    if (_searchFilterlist == null) {
      return null;
    } else {
      return List.from(_searchFilterlist!);
    }
  }

  List<SearchItem>? get searchlist {
    if (_searchList == null) {
      return null;
    } else {
      return List.from(_searchList!);
    }
  }

  UserModel getProviderFromKey(String providerKey) {
    return providerList?.firstWhere(
          (element) => element.key == providerKey,
          orElse: () => UserModel(),
        ) ??
        UserModel();
  }

  String getItemModelSubTitle(ItemModel model) {
    String subTitle = '';
    if (model.price != null && model.price!.isNotEmpty) {
      subTitle += model.price!;
    }
    if (model.providerKey != null && model.providerKey!.isNotEmpty) {
      String displayName = getProviderFromKey(model.providerKey!).displayName!;
      if (displayName.isNotEmpty) {
        if (subTitle.length > 1) {
          subTitle += ' • ';
        }
        subTitle += displayName;
      }
    }

    return subTitle;
  }

  CategoryModel getCategoryFromKey(String categoryKey) {
    return _categorylist!.where((element) => element.key == categoryKey).first;
  }

  UserModel getUserFromKey(String userKey) {
    return _userlist!.where((element) => element.key == userKey).first;
  }

  void setSearchItemList(List<ItemModel>? list1, List<ListModel>? list2,
      {bool onlyItems = false}) {
    _searchList?.clear();

    void addItemToSearchList(String? key, String? title, SearchItemType type,
        {String? provider = '', String? imageUrl = '', String? userName = ''}) {
      _searchList!.add(SearchItem(
        key: key,
        title: title,
        type: type,
        provider: provider,
        imageUrl: imageUrl,
        userName: userName,
      ));
    }

    list1?.forEach((element) {
      addItemToSearchList(element.key, element.title, SearchItemType.Item,
          provider: element.providerKey, imageUrl: element.imageUrl);
    });

    if (onlyItems) return;

    list2?.forEach((element) {
      addItemToSearchList(element.key, element.name, SearchItemType.List,
          userName: getUserFromKey(element.userId).userName);
    });

    _categorylist?.forEach((element) {
      addItemToSearchList(element.key, element.name, SearchItemType.Category,
          imageUrl: element.imageUrl);
    });

    _userlist?.forEach((element) {
      addItemToSearchList(
        element.key,
        element.displayName,
        element.userType == UserType.profile
            ? SearchItemType.Profile
            : SearchItemType.Provider,
        imageUrl: element.profilePic,
      );
    });
  }

  /// get [UserModel list] from firebase realtime Database
  Future<void> getDataFromDatabase() async {
    try {
      isBusy = true;
      _setCurrentUser();

      final recentSearchFuture = _getDataFromDatabaseHelper('recentsearch');
      final categoryFuture = _getDataFromDatabaseHelper('category');
      final profileFuture = _getDataFromDatabaseHelper('profile');

      final List<dynamic> results = await Future.wait([
        recentSearchFuture,
        categoryFuture,
        profileFuture,
      ]);

      _processData('recentsearch', results[0]);
      _processData('category', results[1]);
      _processData('profile', results[2]);
    } catch (error) {
      cprint(error, errorIn: 'getDataFromDatabase');
    } finally {
      isBusy = false;
    }
  }

  Future<Map<dynamic, dynamic>?> _getDataFromDatabaseHelper(
      String child) async {
    final event = await kDatabase.child(child).once();
    final snapshot = event.snapshot;

    if (snapshot.value != null) {
      return snapshot.value as Map<dynamic, dynamic>?;
    }

    return null;
  }

  void _processData(String child, Map<dynamic, dynamic>? value) {
    switch (child) {
      case 'recentsearch':
        _recentSearchlist = <SearchItem>[];
        break;
      case 'category':
        _categorylist = <CategoryModel>[];
        break;
      case 'profile':
        _userlist = <UserModel>[];
        break;
    }

    if (value != null) {
      value.forEach((key, data) {
        switch (child) {
          case 'recentsearch':
            var model = SearchItem.fromJson(data);
            model.key = key;
            _recentSearchlist!.add(model);
            break;
          case 'category':
            var model = CategoryModel.fromJson(data);
            model.key = key;
            _categorylist!.add(model);
            break;
          case 'profile':
            var model = UserModel.fromJson(data);
            model.key = key;
            _userlist!.add(model);
            break;
        }
      });
      notifyListeners();
    } else {
      switch (child) {
        case 'recentsearch':
          _recentSearchlist = null;
          break;
        case 'category':
          _categorylist = null;
          break;
        case 'profile':
          _userlist = null;
          break;
      }
    }
  }

  void resetFilterList() {
    if (_searchFilterlist != null) {
      _searchFilterlist!.clear();
    }
    notifyListeners();
  }

  void filterBySearch(String? searchTerm) {
    if (searchTerm != null &&
        searchTerm.isEmpty &&
        _searchList != null &&
        _searchFilterlist != null) {
      _searchFilterlist!.clear();
    }
    // return if userList is empty or null
    if (_searchList == null && _searchList!.isEmpty) {
      cprint("Search list is empty");
      return;
    }
    // sortBy userlist on the basis of username
    else if (searchTerm != null && searchTerm.isNotEmpty) {
      _searchFilterlist = _searchList!
          .where((x) =>
              x.title != null &&
              x.title!.toLowerCase().contains(searchTerm.toLowerCase()))
          .toList();
    }
    notifyListeners();
  }

  Future<bool> databaseInit() {
    try {
      if (_recentSearchQuery == null) {
        _recentSearchQuery = kDatabase.child("recentsearch");
        _recentSearchQuery!.onChildRemoved.listen(_onRecentSearchRemoved);
      }

      if (_categoryQuery == null) {
        _categoryQuery = kDatabase.child("category");
        _categoryQuery!.onChildAdded.listen(_onCategoryAdded);
        _categoryQuery!.onChildChanged.listen(_onCategoryChanged);
      }

      if (_userQuery == null) {
        _userQuery = kDatabase.child("profile");
        _userQuery!.onChildAdded.listen(_onProfileAdded);
        _userQuery!.onChildChanged.listen(_onProfileChanged);
      }

      return Future.value(true);
    } catch (error) {
      cprint(error, errorIn: 'databaseInit');
      return Future.value(false);
    }
  }

  Future<void> addRecentSearch(SearchItem model) async {
    isBusy = true;
    notifyListeners();
    _recentSearchlist ??= <SearchItem>[];
    if (_recentSearchlist != null &&
        !_recentSearchlist!.any((x) => x.key == model.key))
      try {
        await kDatabase
            .child('recentsearch')
            .child(model.key!)
            .set(model.toJson());
        _recentSearchlist!.add(model);
      } catch (error) {
        cprint(error, errorIn: 'createRecent');
      }
    isBusy = false;
    notifyListeners();
  }

  // Function to remove an item from recentSearchlist
  void removeFromRecentSearchList(SearchItem model) {
    // Remove from the database
    _recentSearchlist!.remove(model);
    kDatabase.child('recentsearch').child(model.key!).remove();

    // Notify listeners to update the UI
    notifyListeners();
  }

  List<UserModel> getuserDetail(List<String> userIds) {
    final list = _userlist!.where((x) {
      if (userIds.contains(x.key)) {
        return true;
      } else {
        return false;
      }
    }).toList();
    return list;
  }

  _onCategoryAdded(DatabaseEvent event) {
    CategoryModel category =
        CategoryModel.fromJson(event.snapshot.value as Map);
    category.key = event.snapshot.key!;

    _categorylist ??= <CategoryModel>[];
    if ((_categorylist!.isEmpty ||
        _categorylist!.any((x) => x.key != category.key))) {
      _categorylist!.add(category);
      cprint('Category Added');
    }
    isBusy = false;
    notifyListeners();
  }

  _onCategoryChanged(DatabaseEvent event) {
    var model =
        CategoryModel.fromJson(event.snapshot.value as Map<dynamic, dynamic>);
    model.key = event.snapshot.key!;
    if (_categorylist!.any((x) => x.key == model.key)) {
      var oldEntry = _categorylist!.lastWhere((entry) {
        return entry.key == event.snapshot.key;
      });
      _categorylist![_categorylist!.indexOf(oldEntry)] = model;
    }

    cprint('category updated');
    isBusy = false;
    notifyListeners();
  }

  _onRecentSearchRemoved(DatabaseEvent event) async {
    SearchItem item = SearchItem.fromJson(event.snapshot.value as Map);
    item.key = event.snapshot.key!;
    var itemKey = item.key;

    try {
      late SearchItem deletedItem;
      if (_recentSearchlist!.any((x) => x.key == itemKey)) {
        deletedItem = _recentSearchlist!.firstWhere((x) => x.key == itemKey);
        _recentSearchlist!.remove(deletedItem);

        if (_recentSearchlist!.isEmpty) {
          _recentSearchlist = null;
        }
        cprint('Item deleted from home page item list');
      }

      notifyListeners();
    } catch (error) {
      cprint(error, errorIn: '_onItemRemoved');
    }
  }

  _onProfileChanged(DatabaseEvent event) {
    var model =
        UserModel.fromJson(event.snapshot.value as Map<dynamic, dynamic>);
    model.key = event.snapshot.key!;
    if (_userlist!.any((x) => x.key == model.key)) {
      var oldEntry = _userlist!.lastWhere((entry) {
        return entry.key == event.snapshot.key;
      });
      _userlist![_userlist!.indexOf(oldEntry)] = model;
    }

    cprint('profile updated');
    isBusy = false;
    notifyListeners();
  }

  _onProfileAdded(DatabaseEvent event) {
    UserModel model = UserModel.fromJson(event.snapshot.value as Map);
    model.key = event.snapshot.key!;

    _userlist ??= <UserModel>[];
    if ((_userlist!.isEmpty || _userlist!.any((x) => x.key != model.key))) {
      _userlist!.add(model);
      cprint('profile Added');
    }
    isBusy = false;
    notifyListeners();
  }
}
