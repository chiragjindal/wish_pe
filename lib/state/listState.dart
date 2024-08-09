import 'dart:async';
import 'dart:io';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/firebase_database.dart' as database;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:wish_pe/helper/enum.dart';
import 'package:wish_pe/helper/fileHelper.dart';
import 'package:wish_pe/helper/shared_prefrence_helper.dart';
import 'package:wish_pe/helper/utility.dart';
import 'package:wish_pe/model/listModel.dart';
import 'package:wish_pe/model/user.dart';
import 'package:wish_pe/state/appState.dart';
import 'package:wish_pe/ui/unused/locator.dart';
import 'package:path/path.dart' as path;

class ListState extends AppState {
  bool isBusy = false;
  SortList sortBy = SortList.Newest;

  List<ListModel>? _listList;
  database.Query? _listQuery;

  late UserModel? _currentUser;
  UserModel? get currentUser => _currentUser;
  void _setCurrentUser() async {
    _currentUser = await getIt<SharedPreferenceHelper>().getUserProfile();
  }

  //--------------Profile-------------------
  List<ListModel>? getProfileLists(UserModel userModel) {
    if (!isBusy && _listList != null && _listList!.isNotEmpty) {
      return _listList!.where((x) {
        if (x.userId == userModel.userId &&
            x.privacyLevel == ListPrivacyLevel.Public) {
          return true;
        } else {
          return false;
        }
      }).toList();
    }
    return null;
  }
  //-----------------Profile-----------------//

  //---------------Library-------------------//
  ListModel? get myDefaultList {
    if (myLists == null) {
      return null;
    } else {
      return myLists!.firstWhere((element) => element.isDefault);
    }
  }

  // My Universal List
  // All lists that I created
  List<ListModel>? get myLists {
    if (_listList != null && _listList!.isNotEmpty) {
      return _listList!.where((x) {
        if (x.userId == currentUser!.userId) {
          return true;
        } else {
          return false;
        }
      }).toList();
    }
    return null;
  }

  // My Liked Lists
  List<ListModel>? get likedLists {
    if (isBusy || _listList == null) {
      return null;
    }

    List<ListModel>? list = _listList!
        .where((element) => element.likeList!.contains(currentUser!.userId))
        .toList();

    return list.isNotEmpty ? list : null;
  }
  //-----------------Library-----------------//

  //-----------------Following-----------------//
  // All lists that I created
  // All lists that I follow/like
  // All public lists created by my following users
  List<ListModel>? get followingPageLists {
    if (!isBusy &&
        _listList != null &&
        _listList!.isNotEmpty &&
        currentUser != null) {
      return _listList!.where((x) {
        if (x.userId == currentUser!.userId ||
            (currentUser!.followingList != null &&
                currentUser!.followingList!.contains(x.userId) &&
                x.privacyLevel == ListPrivacyLevel.Public) ||
            x.likeList!.contains(currentUser!.userId)) {
          return true;
        } else {
          return false;
        }
      }).toList();
    }
    return null;
  }
  //-----------------Following-----------------//

  //-----------------Search-----------------//
  // All public lists and my all lists
  List<ListModel>? get searchLists {
    if (!isBusy && _listList != null && _listList!.isNotEmpty) {
      return _listList!.where((x) {
        if (x.privacyLevel == ListPrivacyLevel.Public ||
            x.userId == currentUser!.userId) {
          return true;
        } else {
          return false;
        }
      }).toList();
    }
    return null;
  }
  //-----------------Search-----------------//

  //-----------------Home-----------------//
  // all public lists except my lists
  List<ListModel>? get homeLists {
    _setCurrentUser();

    if (!isBusy &&
        _listList != null &&
        _listList!.isNotEmpty &&
        currentUser != null) {
      return _listList!.where((x) {
        if (x.userId != currentUser!.userId &&
            x.privacyLevel == ListPrivacyLevel.Public) {
          return true;
        } else {
          return false;
        }
      }).toList();
    }
    return null;
  }
  //-----------------Home-----------------//

  List<String>? getItemKeys(List<ListModel> lists) {
    return lists.expand((e) => e.itemKeyList!).toSet().toList();
  }

  ListModel getListFromKey(String listKey) {
    return _listList!.where((element) => element.key == listKey).first;
  }

  Future<bool> databaseInit() {
    try {
      if (_listQuery == null) {
        _listQuery = kDatabase.child("list");
        _listQuery!.onChildAdded.listen(_onListAdded);
        _listQuery!.onChildChanged.listen(_onListChanged);
        _listQuery!.onChildRemoved.listen(_onListRemoved);
      }
      return Future.value(true);
    } catch (error) {
      cprint(error, errorIn: 'databaseInit');
      return Future.value(false);
    }
  }

  void getDataFromDatabase() {
    try {
      isBusy = true;
      _listList = null;
      _setCurrentUser();
      notifyListeners();

      kDatabase.child('list').once().then((DatabaseEvent event) {
        final snapshot = event.snapshot;
        _listList = <ListModel>[];
        if (snapshot.value != null) {
          var map = snapshot.value as Map<dynamic, dynamic>?;
          if (map != null) {
            map.forEach((key, value) {
              var model = ListModel.fromJson(value);
              model.key = key;
              _listList!.add(model);
            });
            _listList!.sort((x, y) => DateTime.parse(y.createdAt)
                .compareTo(DateTime.parse(x.createdAt)));
          }
        } else {
          _listList = null;
        }

        isBusy = false;
        notifyListeners();
      });
    } catch (error) {
      isBusy = false;
      cprint(error, errorIn: 'getDataFromDatabase');
    }
  }

  /// [create] default list
  Future<void> createDefaultList(UserModel userModel) async {
    try {
      isBusy = true;
      notifyListeners();
      var list = ListModel(
          name: 'Universal List',
          //description: 'This is the default list.',
          userId: userModel.userId!,
          createdAt: DateTime.now().toUtc().toString(),
          privacyLevel: ListPrivacyLevel.Private,
          isDefault: true);
      await createList(list);
      isBusy = false;
      notifyListeners();
    } catch (error) {
      isBusy = false;
      cprint(error, errorIn: 'createDeafultList');
    }
  }

  Future<String?> createList(ListModel model) async {
    isBusy = true;
    notifyListeners();
    String? listKey;
    try {
      if (myLists != null &&
          myLists!.any((element) => element.name == model.name)) {
        return null;
      }
      DatabaseReference dbReference = kDatabase.child('list').push();
      await dbReference.set(model.toJson());
      listKey = dbReference.key;

      if (model.itemKeyList != null && model.itemKeyList!.isNotEmpty) {
        addToList(myDefaultList!, model.itemKeyList!.first);
      }
    } catch (error) {
      cprint(error, errorIn: 'createList');
      print(error.toString());
    }
    isBusy = false;
    notifyListeners();
    return listKey;
  }

  Future<void> updateList(ListModel model) async {
    await kDatabase.child('list').child(model.key!).set(model.toJson());
  }

  //add/remove item from list
  Future<void> addToList(ListModel model, String itemKey) async {
    if (model.itemKeyList != null &&
        model.itemKeyList!.isNotEmpty &&
        model.itemKeyList!.any((id) => id == itemKey)) {
      if (model != myDefaultList)
        model.itemKeyList!.removeWhere((id) => id == itemKey);
    } else {
      model.itemKeyList ??= [];
      model.itemKeyList!.add(itemKey);
      if (model != myDefaultList &&
          !myDefaultList!.itemKeyList!.any((id) => id == itemKey))
        myDefaultList!.itemKeyList!.add(itemKey);
    }
    this.updateList(model);
  }

  Future<void> addToLists(List<ListModel> models, String itemKey) async {
    for (var model in models) {
      addToList(model, itemKey);
    }
  }

  removeFromAll(String itemKey) {
    for (var list in myLists!) {
      if (list.itemKeyList!.contains(itemKey)) {
        list.itemKeyList!.remove(itemKey);
        this.updateList(list);
      }
    }
  }

  deleteList(String listKey) {
    try {
      kDatabase.child('list').child(listKey).remove();
    } catch (error) {
      cprint(error, errorIn: 'deleteList');
    }
    notifyListeners();
  }

  addLikeToList(ListModel list) {
    try {
      if (list.likeList != null &&
          list.likeList!.isNotEmpty &&
          list.likeList!.any((id) => id == currentUser!.userId)) {
        // If user wants to undo/remove his like on list
        list.likeList!.removeWhere((id) => id == currentUser!.userId);
      } else {
        // If user like List
        list.likeList ??= [];
        list.likeList!.add(currentUser!.userId!);
      }
      // update likeList of a list in firebase realtime database
      kDatabase
          .child('list')
          .child(list.key!)
          .child('likeList')
          .set(list.likeList);

      // Sends notification to user who created list
      // UserModel owner can see notification on notification page
      kDatabase.child('notification').child(list.userId).child(list.key!).set({
        'type': list.likeList!.isEmpty
            ? null
            : NotificationType.LikeList.toString(),
        'updatedAt':
            list.likeList!.isEmpty ? null : DateTime.now().toUtc().toString(),
      });
    } catch (error) {
      cprint(error, errorIn: 'addLikeToList');
    }
    notifyListeners();
  }

  /// Trigger when new list added
  /// It will add new list in home page list.
  _onListAdded(DatabaseEvent event) {
    ListModel list = ListModel.fromJson(event.snapshot.value as Map);
    list.key = event.snapshot.key!;

    _listList ??= <ListModel>[];
    if ((_listList!.isEmpty || _listList!.any((x) => x.key != list.key))) {
      _listList!.add(list);
      cprint('List Added');
    }
    isBusy = false;
    notifyListeners();
  }

  /// Trigger when any list changes or update
  /// When any list changes it update it in UI
  _onListChanged(DatabaseEvent event) {
    var model =
        ListModel.fromJson(event.snapshot.value as Map<dynamic, dynamic>);
    model.key = event.snapshot.key!;
    if (_listList!.any((x) => x.key == model.key)) {
      var oldEntry = _listList!.lastWhere((entry) {
        return entry.key == event.snapshot.key;
      });
      _listList![_listList!.indexOf(oldEntry)] = model;
    }

    cprint('List updated');
    isBusy = false;
    notifyListeners();
  }

  _onListRemoved(DatabaseEvent event) async {
    ListModel list = ListModel.fromJson(event.snapshot.value as Map);
    list.key = event.snapshot.key!;

    try {
      late ListModel deletedList;
      if (_listList!.any((x) => x.key == list.key)) {
        deletedList = _listList!.firstWhere((x) => x.key == list.key);
        _listList!.remove(deletedList);

        if (_listList!.isEmpty) {
          _listList = null;
        }
        cprint('List deleted');
      }

      /// Delete list image from firebase storage if exist.
      if (deletedList.listImagePath != null &&
          deletedList.listImagePath!.isNotEmpty) {
        deleteFile(deletedList.listImagePath!, 'listImage');
      }

      /// Delete notification related to deleted List.
      if (deletedList.likeList!.length > 0) {
        kDatabase
            .child('notification')
            .child(list.userId)
            .child(list.key!)
            .remove();
      }
      notifyListeners();
    } catch (error) {
      cprint(error, errorIn: '_onListRemoved');
    }
  }

  /// upload [file] to firebase storage and return its  path url
  Future<String?> uploadFile(File file) async {
    try {
      isBusy = true;
      notifyListeners();
      var storageReference = FirebaseStorage.instance
          .ref()
          .child("listImage")
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

  set updateListSortPrefrence(SortList val) {
    sortBy = val;
    _listList = _sortList();
    notifyListeners();
  }

  List<ListModel> _sortList() {
    switch (sortBy) {
      case SortList.Alphabetically:
        return _listList!.toList()..sort((x, y) => x.name!.compareTo(y.name!));

      case SortList.ItemCount:
        return _listList!.toList()
          ..sort(
              (x, y) => y.itemKeyList!.length.compareTo(x.itemKeyList!.length));

      case SortList.Newest:
        return _listList!.toList()
          ..sort((x, y) => DateTime.parse(y.createdAt)
              .compareTo(DateTime.parse(x.createdAt)));

      case SortList.Oldest:
        return _listList!.toList()
          ..sort((x, y) => DateTime.parse(x.createdAt)
              .compareTo(DateTime.parse(y.createdAt)));

      default:
        return _listList!;
    }
  }

  String get selectedFilter {
    switch (sortBy) {
      case SortList.Alphabetically:
        return "Alphabetically";

      case SortList.ItemCount:
        return "Item Count";

      case SortList.Newest:
        return "Newest list";

      case SortList.Oldest:
        return "Oldest list";

      default:
        return "Unknown";
    }
  }
}
