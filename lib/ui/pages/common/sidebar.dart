import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wish_pe/helper/constant.dart';
import 'package:wish_pe/state/authState.dart';
import 'package:wish_pe/ui/pages/profile/follow/followerListPage.dart';
import 'package:wish_pe/ui/pages/profile/follow/followingListPage.dart';
import 'package:wish_pe/ui/pages/profile/follow/listsListPage.dart';
import 'package:wish_pe/ui/pages/profile/profilePage.dart';
import 'package:wish_pe/ui/widgets/circular_image.dart';
import 'package:wish_pe/state/listState.dart';
import 'package:wish_pe/ui/theme/theme.dart';
import 'package:wish_pe/widgets/customWidgets.dart';
import 'package:wish_pe/widgets/url_text/customUrlText.dart';
import 'package:provider/provider.dart';

class SidebarMenu extends StatefulWidget {
  const SidebarMenu({Key? key, this.scaffoldKey}) : super(key: key);

  final GlobalKey<ScaffoldState>? scaffoldKey;

  @override
  _SidebarMenuState createState() => _SidebarMenuState();
}

class _SidebarMenuState extends State<SidebarMenu> {
  Widget _menuHeader() {
    final state = context.watch<AuthState>();
    if (state.userModel == null) {
      return ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 200, minHeight: 100),
        child: Center(
          child: Text(
            'Login to continue',
            style: TextStyles.onPrimaryTitleText,
          ),
        ),
      ).ripple(() {
        _logOut();
      });
    } else {
      return Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              height: 56,
              width: 56,
              margin: const EdgeInsets.only(left: 17, top: 10),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 2),
                borderRadius: BorderRadius.circular(28),
                image: DecorationImage(
                  image: customAdvanceNetworkImage(
                    state.userModel!.profilePic ?? Constants.dummyProfilePic,
                  ),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            ListTile(
              onTap: () {
                Navigator.push(context,
                    ProfilePage.getRoute(profileId: state.userModel!.userId!));
              },
              title: Row(
                children: <Widget>[
                  UrlText(
                    text: state.userModel!.displayName ?? "",
                    style: TextStyles.onPrimaryTitleText
                        .copyWith(color: Colors.white, fontSize: 20),
                  ),
                  const SizedBox(
                    width: 3,
                  ),
                  state.userModel!.isVerified ?? false
                      ? customIcon(context,
                          icon: AppIcon.blueTick,
                          isCustomIcon: true,
                          iconColor: AppColor.primary,
                          size: 18,
                          paddingIcon: 3)
                      : const SizedBox(
                          width: 0,
                        ),
                ],
              ),
              subtitle: customText(
                state.userModel!.userName,
                style: TextStyles.onPrimarySubTitleText
                    .copyWith(color: Colors.grey, fontSize: 15),
              ),
            ),
            Container(
              alignment: Alignment.center,
              child: Row(
                children: <Widget>[
                  const SizedBox(
                    width: 17,
                  ),
                  _textButton(context, state.userModel!.getFollower.toString(),
                      ' Followers', 'FollowerListPage'),
                  const SizedBox(width: 10),
                  _textButton(context, state.userModel!.getFollowing.toString(),
                      ' Following', 'FollowingListPage'),
                ],
              ),
            ),
          ],
        ),
      );
    }
  }

  Widget _textButton(
      BuildContext context, String count, String text, String navigateTo) {
    return InkWell(
      onTap: () {
        var authState = context.read<AuthState>();
        late List<String> usersList;
        authState.getProfileUser();
        Navigator.pop(context);
        switch (navigateTo) {
          case "FollowerListPage":
            usersList = authState.userModel!.followersList!;
            Navigator.push(
              context,
              FollowerListPage.getRoute(
                profile: authState.userModel!,
                userList: usersList,
              ),
            );
            break;
          case "FollowingListPage":
            usersList = authState.userModel!.followingList!;
            Navigator.push(
              context,
              FollowingListPage.getRoute(
                profile: authState.userModel!,
                userList: usersList,
              ),
            );
            break;
        }
      },
      child: Row(
        children: <Widget>[
          customText(
            '$count ',
            style: const TextStyle(
                color: AppColor.white,
                fontWeight: FontWeight.bold,
                fontSize: 17),
          ),
          customText(
            text,
            style: const TextStyle(color: AppColor.darkGrey, fontSize: 17),
          ),
        ],
      ),
    );
  }

  ListTile _menuListRowButton(String title,
      {Function? onPressed, IconData? icon, bool isEnable = false}) {
    return ListTile(
      onTap: () {
        if (onPressed != null) {
          onPressed();
        }
      },
      leading: icon == null
          ? null
          : Padding(
              padding: const EdgeInsets.only(top: 5),
              child: customIcon(
                context,
                icon: icon,
                size: 25,
                iconColor: isEnable ? AppColor.white : AppColor.darkGrey,
              ),
            ),
      title: customText(
        title,
        style: TextStyle(
          fontSize: 20,
          color: isEnable ? AppColor.white : AppColor.darkGrey,
        ),
      ),
    );
  }

  void _logOut() {
    final state = Provider.of<AuthState>(context, listen: false);
    Navigator.pop(context);
    state.logoutCallback();
  }

  void _navigateTo(String path) {
    Navigator.pop(context);
    Navigator.of(context).pushNamed('/$path');
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: Colors.black, // Set your desired background color here
        child: SafeArea(
          child: Stack(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(bottom: 45),
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  children: <Widget>[
                    Container(
                      child: _menuHeader(),
                    ),
                    const Divider(
                      color: Colors.grey,
                    ),
                    _menuListRowButton('Profile',
                        icon: AppIcon.profile, isEnable: true, onPressed: () {
                      var state = context.read<AuthState>();
                      Navigator.push(context,
                          ProfilePage.getRoute(profileId: state.userId));
                    }),
                    _menuListRowButton('Lists',
                        icon: AppIcon.lists, isEnable: true, onPressed: () {
                      var state = context.read<ListState>();
                      Navigator.push(
                          context,
                          CupertinoPageRoute(
                              builder: (context) => ListsListPage(
                                    listList: state.myLists,
                                  )));
                    }),
                    const Divider(
                      color: Colors.grey,
                    ),
                    _menuListRowButton('Settings', isEnable: true,
                        onPressed: () {
                      _navigateTo('SettingsPage');
                    }),
                    _menuListRowButton('Help Center'),
                    const Divider(
                      color: Colors.grey,
                    ),
                    _menuListRowButton('Logout',
                        icon: null, onPressed: _logOut, isEnable: true),
                  ],
                ),
              ),
              //_footer()
            ],
          ),
        ),
      ),
    );
  }
}
