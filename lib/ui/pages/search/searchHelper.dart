import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wish_pe/model/searchItemModel.dart';
import 'package:wish_pe/state/itemState.dart';
import 'package:wish_pe/state/listState.dart';
import 'package:wish_pe/state/searchState.dart';
import 'package:wish_pe/ui/pages/category/categoryPage.dart';
import 'package:wish_pe/ui/pages/common/item.dart';
import 'package:wish_pe/ui/pages/common/listWidget.dart';
import 'package:wish_pe/ui/pages/list/listPage.dart';
import 'package:wish_pe/ui/pages/profile/profilePage.dart';
import 'package:wish_pe/ui/pages/provider/providerPage.dart';
import 'package:wish_pe/widgets/avatar_image.dart';
import 'package:provider/provider.dart';

Widget getSearchResultTile(SearchItem info, SearchState state,
    ItemState feedState, ListState listState, BuildContext context) {
  switch (info.type) {
    case SearchItemType.Category:
      return getSearchResultWidget(state, () {
        Navigator.push(
            context,
            CupertinoPageRoute(
                builder: (context) => CategoryPage(
                    category: state.getCategoryFromKey(info.key!))));
      }, info, context);
    case SearchItemType.Profile:
      return getSearchResultWidget(state, () {
        Navigator.push(
            context,
            ProfilePage.getRoute(
                profileId: state.getUserFromKey(info.key!).key!));
      }, info, context);
    case SearchItemType.Provider:
      return getSearchResultWidget(state, () {
        Navigator.push(
            context,
            ProviderPage.getRoute(
              providerKey: info.key!,
            ));
      }, info, context);
    case SearchItemType.Item:
      return Item(
          item: feedState.getItem(info.key!),
          subTitleText: getSearchItemSubtitle(context, info),
          onDismissedAction: () {
            state.removeFromRecentSearchList(info);
          },
          onTapAction: () {
            state.addRecentSearch(info);
          });
    case SearchItemType.List:
      return ListWidget(
          list: listState.getListFromKey(info.key!),
          subTitleText: getSearchItemSubtitle(context, info),
          onDismissedAction: () {
            state.removeFromRecentSearchList(info);
          },
          onTapAction: () {
            state.addRecentSearch(info);
            Navigator.push(
                context,
                CupertinoPageRoute(
                    builder: (context) =>
                        ListPage(list: listState.getListFromKey(info.key!))));
          });
  }
}

Widget getSearchResultWidget(SearchState state, Function onTapAction,
    SearchItem info, BuildContext context) {
  return Dismissible(
    key: UniqueKey(),
    onDismissed: (direction) {
      state.removeFromRecentSearchList(info);
    },
    direction: DismissDirection.endToStart,
    background: Container(
      alignment: Alignment.centerRight,
      child: const Padding(
        padding: EdgeInsets.all(20.0),
        child: Icon(
          CupertinoIcons.delete,
          color: Colors.white,
        ),
      ),
    ),
    child: InkWell(
      onTap: () {
        state.addRecentSearch(info);
        onTapAction();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: info.imageUrl == null
                  ? ImageOrAvatar(
                      imagePath:
                          'assets/images/' + info.title!.toLowerCase() + '.png',
                      width: 50,
                      height: 50,
                      name: info.title!)
                  : CachedNetworkImage(
                      imageUrl: info.imageUrl!,
                      fit: BoxFit.cover,
                      width: 50,
                      height: 50,
                      maxHeightDiskCache: 70,
                      maxWidthDiskCache: 70,
                      memCacheHeight:
                          (70 * MediaQuery.of(context).devicePixelRatio)
                              .round(),
                      memCacheWidth:
                          (70 * MediaQuery.of(context).devicePixelRatio)
                              .round(),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    info.title!,
                    style: const TextStyle(color: Colors.white, fontSize: 16.0),
                  ),
                  const SizedBox(
                    height: 4,
                  ),
                  Text(
                    info.type.toString().split('.').last,
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

String getSearchItemSubtitle(BuildContext context, SearchItem item) {
  final feedState = context.watch<SearchState>();
  return item.type.toString().split('.').last +
      (item.type == SearchItemType.Item
          ? (item.provider == null
              ? ''
              : ' • ' +
                  feedState.getProviderFromKey(item.provider!).displayName!)
          : ' • ' + item.userName!);
}
