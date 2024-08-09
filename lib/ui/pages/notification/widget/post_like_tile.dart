import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wish_pe/model/itemModel.dart';
import 'package:wish_pe/model/listModel.dart';
import 'package:wish_pe/model/user.dart';
import 'package:wish_pe/state/notificationState.dart';
import 'package:wish_pe/ui/pages/itemDetail/itemDetailPage.dart';
import 'package:wish_pe/ui/pages/list/listPage.dart';
import 'package:wish_pe/ui/pages/profile/profilePage.dart';
import 'package:wish_pe/ui/widgets/circular_image.dart';
import 'package:wish_pe/ui/theme/theme.dart';
import 'package:wish_pe/widgets/customWidgets.dart';
import 'package:wish_pe/widgets/newWidget/title_text.dart';
import 'package:wish_pe/widgets/url_text/customUrlText.dart';
import 'package:provider/provider.dart';

class PostLikeTile<T> extends StatelessWidget {
  final T model;
  const PostLikeTile({Key? key, required this.model}) : super(key: key);
  Widget _userList(BuildContext context, List<String>? list) {
    int length = list?.length ?? 0;
    List<Widget> avaterList = [];
    var state = Provider.of<NotificationState>(context);
    if (list != null) {
      if (list.length > 5) {
        list = list.take(5).toList();
      }
      avaterList = list.map((userId) {
        return _userAvater(userId, state, (name) {});
      }).toList();
    }
    if (length > 5) {
      avaterList.add(
        Text(
          " +${length - 5}",
          style: TextStyles.subtitleStyle.copyWith(fontSize: 16),
        ),
      );
    }

    var col = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            customIcon(
              context,
              icon: AppIcon.heartFill,
              iconColor: WishPeColor.ceriseRed,
              size: 18,
            ),
            const SizedBox(width: 10),
            Row(children: avaterList),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(left: 10, bottom: 5, top: 5),
          child: TitleText(
            '$length people like your Item',
            fontSize: 18,
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        )
      ],
    );
    return col;
  }

  Widget _userAvater(
      String userId, NotificationState state, ValueChanged<String> name) {
    return FutureBuilder(
      future: state.getUserDetail(userId),
      builder: (BuildContext context, AsyncSnapshot<UserModel?> snapshot) {
        if (snapshot.hasData) {
          name(snapshot.data!.displayName!);
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: GestureDetector(
              onTap: () {
                Navigator.push(context,
                    ProfilePage.getRoute(profileId: snapshot.data!.userId!));
              },
              child: CircularImage(path: snapshot.data!.profilePic, height: 30),
            ),
          );
        } else {
          return Container();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    String description = "";
    if (model is ItemModel && (model as ItemModel).title != null) {
      description = (model as ItemModel).title!.length > 150
          ? (model as ItemModel).title!.substring(0, 150) + '...'
          : (model as ItemModel).title!;
    } else if (model is ListModel && (model as ListModel).name != null) {
      description = (model as ListModel).name!.length > 150
          ? (model as ListModel).name!.substring(0, 150) + '...'
          : (model as ListModel).name!;
    }

    return Column(
      children: <Widget>[
        Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          color: Colors.black,
          child: ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: 20.0),
            onTap: () {
              if (model is ItemModel) {
                Navigator.push(
                    context,
                    CupertinoPageRoute(
                        builder: (context) => ItemDetailPage(
                              item: model as ItemModel,
                            )));
              } else if (model is ListModel) {
                Navigator.push(
                    context,
                    CupertinoPageRoute(
                        builder: (context) => ListPage(
                              list: model as ListModel,
                            )));
              }
            },
            title: _userList(
                context,
                (model is ItemModel)
                    ? (model as ItemModel).likeList
                    : (model as ListModel).likeList),
            subtitle: Padding(
              padding: const EdgeInsets.only(left: 10),
              child: UrlText(
                text: description,
                style: const TextStyle(
                  color: AppColor.darkGrey,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
        ),
        const Divider(
          height: 0,
          thickness: .6,
          color: Colors.grey,
        )
      ],
    );
  }
}
