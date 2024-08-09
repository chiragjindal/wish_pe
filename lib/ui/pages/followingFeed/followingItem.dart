import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wish_pe/helper/utility.dart';
import 'package:wish_pe/model/itemModel.dart';
import 'package:wish_pe/state/searchState.dart';
import 'package:wish_pe/ui/pages/itemDetail/itemDetailPage.dart';
import 'package:wish_pe/ui/pages/profile/profilePage.dart';
import 'package:wish_pe/ui/widgets/circular_image.dart';
import 'package:wish_pe/ui/widgets/itemImageFeed.dart';
import 'package:wish_pe/ui/theme/theme.dart';
import 'package:wish_pe/widgets/customWidgets.dart';
import 'package:wish_pe/widgets/newWidget/title_text.dart';
import 'package:wish_pe/ui/widgets/itemIconsRow.dart';
import 'package:wish_pe/widgets/url_text/customUrlText.dart';
import 'package:provider/provider.dart';

class FollowingItem extends StatelessWidget {
  final ItemModel model;
  final Widget? trailing;
  final GlobalKey<ScaffoldState> scaffoldKey;
  const FollowingItem({
    Key? key,
    required this.model,
    this.trailing,
    required this.scaffoldKey,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topLeft,
      children: <Widget>[
        InkWell(
          onTap: () {
            Navigator.push(
              context,
              CupertinoPageRoute(
                builder: (context) => ItemDetailPage(
                  item: model,
                ),
              ),
            );
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                  padding: EdgeInsets.only(top: 12),
                  child: _FollowingItemBody(
                    model: model,
                    trailing: trailing,
                  )),
              Padding(
                padding: const EdgeInsets.only(right: 15),
                child: ItemImage(
                  model: model,
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 0),
                child: ItemIconsRow(
                  model: model,
                  iconColor: Colors.white,
                  iconEnableColor: WishPeColor.ceriseRed,
                  size: 20,
                  isProviderIcon: true,
                  scaffoldKey: GlobalKey<ScaffoldState>(),
                ),
              ),
              const Divider(
                height: .5,
                thickness: .5,
                color: Colors.grey,
              )
            ],
          ),
        ),
      ],
    );
  }
}

class _FollowingItemBody extends StatelessWidget {
  final ItemModel model;
  final Widget? trailing;
  const _FollowingItemBody({
    Key? key,
    required this.model,
    this.trailing,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final searchState = context.watch<SearchState>();
    final user = searchState.getUserFromKey(model.userId);
    double descriptionFontSize = 15;
    FontWeight descriptionFontWeight = FontWeight.w400;
    TextStyle textStyle = TextStyle(
        color: Colors.white,
        fontSize: descriptionFontSize,
        fontWeight: descriptionFontWeight);
    TextStyle urlStyle = TextStyle(
        color: Colors.blue,
        fontSize: descriptionFontSize,
        fontWeight: descriptionFontWeight);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const SizedBox(width: 15),
        SizedBox(
          width: 40,
          height: 40,
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                  context, ProfilePage.getRoute(profileId: model.userId));
            },
            child: CircularImage(path: user.profilePic),
          ),
        ),
        const SizedBox(width: 20),
        SizedBox(
          width: context.width - 90,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Expanded(
                    child: Row(
                      children: <Widget>[
                        ConstrainedBox(
                          constraints: BoxConstraints(
                              minWidth: 0, maxWidth: context.width * .5),
                          child: TitleText(user.displayName!,
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
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
                        SizedBox(
                          width: user.isVerified! ? 5 : 0,
                        ),
                        Flexible(
                          child: customText(
                            '${user.userName}',
                            style: TextStyles.userNameStyle,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 4),
                        customText(
                          '· ${Utility.getChatTime(model.createdAt)}',
                          style:
                              TextStyles.userNameStyle.copyWith(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  Container(child: trailing ?? const SizedBox()),
                ],
              ),
              const SizedBox(height: 5),
              model.title == null
                  ? const SizedBox()
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        UrlText(
                          text: model.title!.removeSpaces,
                          style: textStyle,
                          urlStyle: urlStyle,
                        ),
                      ],
                    ),
            ],
          ),
        ),
        const SizedBox(width: 15),
      ],
    );
  }
}
