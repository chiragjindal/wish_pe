import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wish_pe/model/itemModel.dart';
import 'package:wish_pe/model/listModel.dart';
import 'package:wish_pe/state/authState.dart';
import 'package:wish_pe/state/itemState.dart';
import 'package:wish_pe/state/listState.dart';
import 'package:provider/provider.dart';

class LikeButton extends StatelessWidget {
  final ItemModel? item;
  final ListModel? list;
  final bool? isIcon;

  LikeButton({Key? key, this.item, this.list, this.isIcon}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer2<ItemState, ListState>(
      builder: (context, feedState, listState, child) {
        var liked;
        if (item != null) {
          liked = item!.likeList!
              .contains(Provider.of<AuthState>(context, listen: false).userId);
        } else {
          liked = list!.likeList!
              .contains(Provider.of<AuthState>(context, listen: false).userId);
        }

        return buildLikeButton(context, liked, feedState, listState);
      },
    );
  }

  Widget buildLikeButton(BuildContext context, bool liked, ItemState feedState,
      ListState listState) {
    if (isIcon != false) {
      return ListTile(
        minLeadingWidth: 30,
        contentPadding: const EdgeInsets.symmetric(horizontal: 30),
        onTap: () {
          if (item != null) {
            feedState.addLikeToItem(item!);
          } else {
            listState.addLikeToList(list!);
          }
        },
        leading: liked
            ? const Icon(
                CupertinoIcons.heart_solid,
                color: Colors.lightGreen,
              )
            : const Icon(
                CupertinoIcons.heart,
                color: Colors.grey,
              ),
        title: Text(
          liked ? "Liked" : "Like",
          style: Theme.of(context)
              .textTheme
              .bodyMedium!
              .copyWith(fontSize: 20, color: Colors.white),
        ),
      );
    } else {
      return InkWell(
        onTap: () {
          if (item != null) {
            feedState.addLikeToItem(item!);
          } else {
            listState.addLikeToList(list!);
          }
        },
        child: liked
            ? const Icon(
                CupertinoIcons.heart_solid,
                color: Colors.lightGreen,
              )
            : const Icon(
                CupertinoIcons.heart,
                color: Colors.grey,
              ),
      );
    }
  }
}
