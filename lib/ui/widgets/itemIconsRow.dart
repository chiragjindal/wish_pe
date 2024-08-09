import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wish_pe/model/itemModel.dart';
import 'package:wish_pe/state/authState.dart';
import 'package:wish_pe/state/itemState.dart';
import 'package:wish_pe/state/listState.dart';
import 'package:wish_pe/state/searchState.dart';
import 'package:wish_pe/ui/pages/common/addToList.dart';
import 'package:wish_pe/ui/pages/provider/providerPage.dart';
import 'package:wish_pe/ui/theme/theme.dart';
import 'package:wish_pe/widgets/avatar_image.dart';
import 'package:wish_pe/widgets/customWidgets.dart';
import 'package:provider/provider.dart';

class ItemIconsRow extends StatelessWidget {
  final ItemModel model;
  final Color iconColor;
  final Color iconEnableColor;
  final double? size;
  final bool? isProviderIcon;
  final GlobalKey<ScaffoldState> scaffoldKey;
  const ItemIconsRow(
      {Key? key,
      required this.model,
      required this.iconColor,
      required this.iconEnableColor,
      this.size,
      this.isProviderIcon = false,
      required this.scaffoldKey})
      : super(key: key);

  Widget _likeCommentsIcons(BuildContext context, ItemModel model) {
    var authState = Provider.of<AuthState>(context, listen: false);

    return Container(
      color: Colors.black,
      padding: const EdgeInsets.only(bottom: 0, top: 0, left: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          isProviderIcon!
              ? _providerWidget(context)
              : const SizedBox(
                  width: 10,
                ),
          const SizedBox(
            width: 10,
          ),
          _iconWidget(
            context,
            text: '0',
            icon: null,
            sysIcon: Icons.comment,
            iconColor: iconColor,
            size: size ?? 20,
            onPressed: () {
              //addLikeToItem(context);
            },
          ),
          _iconWidget(
            context,
            text: model.likeCount.toString(),
            icon: model.likeList!.any((userId) => userId == authState.userId)
                ? AppIcon.heartFill
                : AppIcon.heartEmpty,
            onPressed: () {
              addLikeToItem(context);
            },
            iconColor:
                model.likeList!.any((userId) => userId == authState.userId)
                    ? iconEnableColor
                    : iconColor,
            size: size ?? 20,
          ),
          addItemToDefaultList(context, model),
        ],
      ),
    );
  }

  Widget _providerWidget(
    BuildContext context,
  ) {
    final state = Provider.of<SearchState>(context);
    if (model.providerKey == null) return const SizedBox();
    final provider = state.getProviderFromKey(model.providerKey!);
    return Row(
      children: <Widget>[
        InkWell(
          onTap: () {
            Navigator.push(
                context, ProviderPage.getRoute(providerKey: provider.key!));
          },
          child: ClipOval(
            child: ImageOrAvatar(
                imagePath: 'assets/images/' +
                    provider.displayName!.toLowerCase() +
                    '.png',
                width: 20,
                height: 20,
                name: provider.displayName!),
          ),
        ),
        const SizedBox(
          width: 10,
        ),
        Container(
          width: 80,
          child: customText(
            model.price,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: iconColor,
              fontSize: 15,
            ),
            context: context,
          ),
        ),
        const SizedBox(
          width: 20,
        ),
        Container(
          width: 5,
          height: 25,
          decoration: BoxDecoration(
              color: Color(0xffa8a09b),
              borderRadius: BorderRadius.all(Radius.circular(10))),
        ),
      ],
    );
  }

  Widget _iconWidget(BuildContext context,
      {required String text,
      IconData? icon,
      Function? onPressed,
      IconData? sysIcon,
      required Color iconColor,
      double size = 20}) {
    if (sysIcon == null) assert(icon != null);
    if (icon == null) assert(sysIcon != null);

    return Expanded(
      child: Row(
        children: <Widget>[
          IconButton(
            onPressed: () {
              if (onPressed != null) onPressed();
            },
            icon: sysIcon != null
                ? Icon(sysIcon, color: iconColor, size: size)
                : customIcon(
                    context,
                    size: size,
                    icon: icon!,
                    isCustomIcon: true,
                    iconColor: iconColor,
                  ),
          ),
          customText(
            text,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: iconColor,
              fontSize: size - 5,
            ),
            context: context,
          ),
        ],
      ),
    );
  }

  void addLikeToItem(BuildContext context) {
    var state = Provider.of<ItemState>(context, listen: false);
    state.addLikeToItem(model);
  }

  Widget addItemToDefaultList(BuildContext context, ItemModel item) {
    var state = Provider.of<ListState>(context, listen: false);
    var isPresent =
        state.myDefaultList!.itemKeyList!.any((element) => element == item.key);
    return _iconWidget(context,
        text: '',
        icon: null,
        sysIcon: isPresent
            ? CupertinoIcons.check_mark_circled_solid
            : CupertinoIcons.add_circled, onPressed: () {
      if (!isPresent) {
        state.addToList(state.myDefaultList!, item.key!);
        isPresent = true;
      } else {
        Navigator.push(context,
            CupertinoPageRoute(builder: (BuildContext context) {
          return AddToList(
            item: item,
          );
        }));
      }
    }, iconColor: iconColor, size: size ?? 20);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[_likeCommentsIcons(context, model)],
    );
  }
}
