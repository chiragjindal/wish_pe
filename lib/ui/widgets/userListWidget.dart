import 'package:flutter/material.dart';
import 'package:wish_pe/model/user.dart';
import 'package:wish_pe/state/authState.dart';
import 'package:wish_pe/ui/pages/profile/profilePage.dart';
import 'package:wish_pe/ui/pages/provider/providerPage.dart';
import 'package:wish_pe/ui/widgets/circular_image.dart';
import 'package:wish_pe/ui/theme/theme.dart';
import 'package:wish_pe/widgets/avatar_image.dart';
import 'package:wish_pe/widgets/customWidgets.dart';
import 'package:wish_pe/widgets/newWidget/rippleButton.dart';
import 'package:wish_pe/widgets/newWidget/title_text.dart';
import 'package:provider/provider.dart';

class UserListWidget extends StatelessWidget {
  final List<UserModel> list;

  final Function(UserModel user)? onFollowPressed;
  final bool Function(UserModel user)? isFollowing;
  const UserListWidget({
    Key? key,
    required this.list,
    this.onFollowPressed,
    this.isFollowing,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var state = Provider.of<AuthState>(context, listen: false);
    final currentUser = state.userModel!;
    return ListView.separated(
      itemBuilder: (context, index) {
        return UserTile(
          user: list[index],
          currentUser: currentUser,
          isFollowing: isFollowing,
          onTrailingPressed: () {
            if (onFollowPressed != null) {
              onFollowPressed!(list[index]);
            }
          },
        );
      },
      separatorBuilder: (context, index) {
        return const Divider(
          height: 0,
        );
      },
      itemCount: list.length,
    );
  }
}

class UserTile extends StatelessWidget {
  const UserTile({
    Key? key,
    required this.user,
    required this.currentUser,
    required this.onTrailingPressed,
    this.trailing,
    this.isFollowing,
  }) : super(key: key);
  final UserModel user;

  /// User profile of logged-in user
  final UserModel currentUser;
  final VoidCallback onTrailingPressed;
  final Widget? trailing;
  final bool Function(UserModel user)? isFollowing;

  /// Check if user followerlist contain your or not
  /// If your id exist in follower list it mean you are following him
  bool checkIfFollowing() {
    if (isFollowing != null) {
      return isFollowing!(user);
    }
    if (currentUser.followingList != null &&
        currentUser.followingList!.any((x) => x == user.userId)) {
      return true;
    } else {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isFollow = checkIfFollowing();
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      color: Colors.black,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          ListTile(
            onTap: () {
              user.userType == UserType.provider
                  ? Navigator.push(
                      context, ProviderPage.getRoute(providerKey: user.userId!))
                  : Navigator.push(
                      context, ProfilePage.getRoute(profileId: user.userId!));
            },
            leading: RippleButton(
              onPressed: () {
                user.userType == UserType.provider
                    ? Navigator.push(context,
                        ProviderPage.getRoute(providerKey: user.userId!))
                    : Navigator.push(
                        context, ProfilePage.getRoute(profileId: user.userId!));
              },
              borderRadius: const BorderRadius.all(Radius.circular(60)),
              child: user.userType == UserType.provider
                  ? ClipOval(
                      child: ImageOrAvatar(
                          imagePath: 'assets/images/' +
                              user.displayName!.toLowerCase() +
                              '.png',
                          width: 55,
                          height: 55,
                          name: user.displayName!))
                  : CircularImage(path: user.profilePic, height: 55),
            ),
            title: Row(
              children: <Widget>[
                ConstrainedBox(
                  constraints:
                      BoxConstraints(minWidth: 0, maxWidth: context.width * .4),
                  child: TitleText(user.displayName!,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      overflow: TextOverflow.ellipsis),
                ),
                const SizedBox(width: 3),
                user.isVerified ?? false
                    ? customIcon(
                        context,
                        icon: AppIcon.blueTick,
                        isCustomIcon: true,
                        iconColor: AppColor.primary,
                        size: 13,
                        paddingIcon: 3,
                      )
                    : const SizedBox(width: 0),
              ],
            ),
            subtitle: Text(user.followersList!.length.toString() + ' followers',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                )),
            trailing: RippleButton(
              onPressed: onTrailingPressed,
              splashColor: ColorConstants.primaryColor,
              borderRadius: BorderRadius.circular(25),
              child: trailing ??
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: isFollow ? 15 : 20,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      border: Border.all(
                          color: ColorConstants.primaryColor, width: 1),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Text(
                      isFollow ? 'Following' : 'Follow',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
