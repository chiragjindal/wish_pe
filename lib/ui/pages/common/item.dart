import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wish_pe/helper/fileHelper.dart';
import 'package:wish_pe/model/itemModel.dart';
import 'package:wish_pe/model/listModel.dart';
import 'package:wish_pe/state/listState.dart';
import 'package:wish_pe/ui/pages/itemDetail/itemDetailPage.dart';
import 'package:wish_pe/ui/widgets/bottomSheetWidget.dart';
import 'package:wish_pe/state/searchState.dart';
import 'package:provider/provider.dart';

// ignore: must_be_immutable
class Item extends StatelessWidget {
  final ItemModel item;
  final ListModel? parentList;
  Function? onDismissedAction;
  Function? onTapAction;
  Widget? trailing;
  String? subTitleText;
  Item(
      {Key? key,
      required this.item,
      this.parentList,
      this.onDismissedAction,
      this.onTapAction,
      this.trailing,
      this.subTitleText})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return buildItemWidget(context);
  }

  Widget buildItemWidget(BuildContext context) {
    final devicePixelRatio = MediaQuery.of(context).devicePixelRatio;
    final state = Provider.of<SearchState>(context);
    final listState = Provider.of<ListState>(context);

    Widget itemWidget = ListTile(
      onTap: () {
        FocusScope.of(context).unfocus();
        if (onTapAction != null) onTapAction!();
        Navigator.push(
          context,
          CupertinoPageRoute(
            builder: (context) => ItemDetailPage(
              item: item,
              parentList: parentList,
            ),
          ),
        );
      },
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(5),
        child: item.imageUrl!.startsWith("data:")
            ? buildBase64Image(item.imageUrl!, 50, 50)
            : CachedNetworkImage(
                imageUrl: item.imageUrl!,
                width: 50,
                height: 50,
                memCacheHeight: (70 * devicePixelRatio).round(),
                memCacheWidth: (70 * devicePixelRatio).round(),
                maxHeightDiskCache: (70 * devicePixelRatio).round(),
                maxWidthDiskCache: (70 * devicePixelRatio).round(),
                fit: BoxFit.cover,
              ),
      ),
      title: Text(
        item.title.toString(),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: Colors.white,
          decoration: TextDecoration.none,
        ),
      ),
      subtitle: Text(
        subTitleText ?? state.getItemModelSubTitle(item),
        style: const TextStyle(color: Colors.grey),
      ),
      trailing: trailing ??
          IconButton(
            onPressed: () {
              showModalBottomSheet(
                useRootNavigator: true,
                isScrollControlled: true,
                elevation: 100,
                backgroundColor: Colors.black38,
                context: context,
                builder: (context) {
                  return BottomSheetWidget(
                    item: item,
                    list: parentList,
                  );
                },
              );
            },
            icon: const Icon(
              Icons.more_vert,
              color: Colors.white,
            ),
          ),
    );

    itemWidget = Opacity(
      opacity: 1.0,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.transparent,
            width: 2.0,
          ),
        ),
        child: itemWidget,
      ),
    );

    if (onDismissedAction != null && parentList != listState.myDefaultList) {
      itemWidget = Dismissible(
        key: UniqueKey(),
        onDismissed: (direction) {
          if (onDismissedAction != null) onDismissedAction!();
        },
        direction: DismissDirection.endToStart,
        background: Container(
          alignment: Alignment.centerRight,
          child: const Padding(
            padding: EdgeInsets.all(20.0),
            child: Icon(
              CupertinoIcons.minus_circled,
              color: Colors.white,
            ),
          ),
        ),
        child: itemWidget,
      );
    }

    return itemWidget;
  }
}
