import 'package:wish_pe/helper/utility.dart';
import 'package:wish_pe/model/user.dart';
import 'package:wish_pe/state/appState.dart';

class SuggestionsState extends AppState {
  List<UserModel>? _providerlist;

  UserModel? currentUser;
  void initUser(UserModel? model) {
    if (model != null && currentUser != model) {
      currentUser = model;
      _displaySuggestions = int.tryParse(currentUser!.getFollowing)! < 5;
    }
  }

  bool _displaySuggestions = false;
  bool get displaySuggestions => _displaySuggestions;
  set displaySuggestions(bool value) {
    if (value != _displaySuggestions) {
      _displaySuggestions = value;
      notifyListeners();
    }
  }

  //show top 20 providers by followers count
  List<UserModel>? get providerlist => _providerlist;
  void setProviderlist(List<UserModel>? list) {
    if (list != null && _providerlist == null) {
      list = list
          .where((element) => element.userType == UserType.provider)
          .toList();
      list.sort((a, b) {
        if (a.followersList != null && b.followersList != null) {
          return b.followersList!.length.compareTo(a.followersList!.length);
        } else if (a.followersList != null) {
          return 0;
        }
        return 1;
      });

      _providerlist = list.take(20).toList();
      _providerlist!.removeWhere((element) => isFollowing(element));
      _selectedProviders = List.from(_providerlist!);
    }
  }

  /// Check if user followerList contain your or not
  /// If your id exist in follower list it mean you are following him
  bool isFollowing(UserModel user) {
    if (user.followersList != null &&
        user.followersList!.any((x) => x == currentUser!.userId)) {
      return true;
    } else {
      return false;
    }
  }

  List<UserModel> _selectedProviders = [];
  int get selectedProvidersCount => _selectedProviders.length;

  bool isSelected(UserModel user) {
    return _selectedProviders.contains(user);
  }

  void toggleAllSelections() {
    if (_selectedProviders.length == _providerlist!.length) {
      _selectedProviders = [];
    } else {
      _selectedProviders = List.from(_providerlist!);
    }
    notifyListeners();
  }

  void toggleUserSelection(UserModel user) {
    if (isSelected(user)) {
      _selectedProviders.remove(user);
    } else {
      _selectedProviders.add(user);
    }

    notifyListeners();
  }

  Future<void> followUsers() async {
    try {
      if (_selectedProviders.length > 0) {
        /// Add current user id to the following list of all selected users
        for (final user in _selectedProviders) {
          user.followersList ??= [];
          user.followersList!.add(currentUser!.userId!);
          user.followers = user.followersList!.length;
          await kDatabase
              .child('profile')
              .child(user.userId!)
              .child('followerList')
              .set(user.followersList);

          cprint('user added to following list');
        }

        /// Add all selected users to current user following list
        currentUser!.followingList ??= [];
        currentUser!.followingList!
            .addAll(_selectedProviders.map((e) => e.userId!));
        currentUser!.following = currentUser!.followingList!.length;
        await kDatabase
            .child('profile')
            .child(currentUser!.userId!)
            .child('followingList')
            .set(currentUser!.followingList);
      }
      displaySuggestions = false;
    } catch (error) {
      isBusy = false;
      cprint(error, errorIn: 'followUsers');
    }
  }
}
