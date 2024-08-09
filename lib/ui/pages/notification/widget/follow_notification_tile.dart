import 'package:flutter/material.dart';
import 'package:wish_pe/model/notificationModel.dart';
import 'package:wish_pe/model/user.dart';
import 'package:wish_pe/ui/pages/profile/profilePage.dart';
import 'package:wish_pe/ui/widgets/circular_image.dart';
import 'package:wish_pe/ui/theme/theme.dart';
import 'package:wish_pe/widgets/customWidgets.dart';
import 'package:wish_pe/widgets/url_text/customUrlText.dart';

class FollowNotificationTile extends StatelessWidget {
  final NotificationModel model;
  const FollowNotificationTile({Key? key, required this.model})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: Colors.black,
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          child: Column(
            children: [
              Row(
                children: [
                  customIcon(
                    context,
                    icon: AppIcon.profile,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    model.user.displayName!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                  Text(" Followed you", style: TextStyles.subtitleStyle),
                ],
              ),
              const SizedBox(width: 10),
              _UserCard(user: model.user)
            ],
          ),
        ),
        const Divider(height: 0, thickness: .6)
      ],
    );
  }
}

class _UserCard extends StatelessWidget {
  final UserModel user;
  const _UserCard({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.only(left: 30, top: 10, bottom: 8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          decoration: BoxDecoration(
            border: Border.all(color: AppColor.extraLightGrey, width: .5),
            borderRadius: const BorderRadius.all(Radius.circular(15)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircularImage(path: user.profilePic, height: 40),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  children: <Widget>[
                    UrlText(
                      text: user.displayName!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(width: 3),
                    user.isVerified ?? false
                        ? customIcon(context,
                            icon: AppIcon.blueTick,
                            isCustomIcon: true,
                            iconColor: AppColor.primary,
                            size: 13,
                            paddingIcon: 3)
                        : const SizedBox(width: 0),
                  ],
                ),
              ),
              //const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 0),
                child: customText(
                  '${user.userName}',
                  style: TextStyles.subtitleStyle.copyWith(fontSize: 13),
                ),
              ),
            ],
          ),
        ).ripple(() {
          Navigator.push(
              context, ProfilePage.getRoute(profileId: user.userId!));
        }, borderRadius: BorderRadius.circular(15)));
  }
}
