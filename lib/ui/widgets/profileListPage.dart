import 'package:flutter/material.dart';
import 'package:wish_pe/model/user.dart';
import 'package:wish_pe/state/searchState.dart';
import 'package:wish_pe/ui/widgets/userListWidget.dart';
import 'package:wish_pe/widgets/customAppBar.dart';
import 'package:wish_pe/widgets/newWidget/emptyList.dart';
import 'package:provider/provider.dart';

class ProfileListPage extends StatelessWidget {
  const ProfileListPage({
    Key? key,
    this.pageTitle = "",
    required this.emptyScreenText,
    required this.emptyScreenSubTileText,
    this.userIdsList,
    this.onFollowPressed,
    this.isFollowing,
  }) : super(key: key);

  final String pageTitle;
  final String emptyScreenText;
  final String emptyScreenSubTileText;
  final bool Function(UserModel user)? isFollowing;
  final List<String>? userIdsList;
  final Function(UserModel user)? onFollowPressed;

  @override
  Widget build(BuildContext context) {
    List<UserModel>? userList;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: CustomAppBar(
        isBackButton: true,
        title: Text(
          pageTitle,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: Consumer<SearchState>(
        builder: (context, state, child) {
          if (userIdsList != null && userIdsList!.isNotEmpty) {
            userList = state.getuserDetail(userIdsList!);
          }
          return userList != null && userList!.isNotEmpty
              ? UserListWidget(
                  list: userList!,
                  onFollowPressed: onFollowPressed,
                  isFollowing: isFollowing,
                )
              : Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(top: 0, left: 10, right: 10),
                  child: NotifyText(
                    title: emptyScreenText,
                    subTitle: emptyScreenSubTileText,
                  ),
                );
        },
      ),
    );
  }
}
