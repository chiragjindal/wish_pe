import 'package:flutter/cupertino.dart';
import 'package:wish_pe/state/profile_state.dart';
import 'package:provider/provider.dart';

bool isFollower(BuildContext context) {
  var authState = Provider.of<ProfileState>(context, listen: false);
  if (authState.profileUserModel.followersList != null &&
      authState.profileUserModel.followersList!.isNotEmpty) {
    return (authState.profileUserModel.followersList!
        .any((x) => x == authState.userId));
  } else {
    return false;
  }
}
