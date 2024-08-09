import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wish_pe/helper/fileHelper.dart';
import 'package:wish_pe/model/itemModel.dart';
import 'package:wish_pe/model/user.dart';
import 'package:wish_pe/state/searchState.dart';
import 'package:wish_pe/ui/pages/category/categoryPage.dart';
import 'package:wish_pe/ui/pages/itemDetail/itemDetailPage.dart';
import 'package:wish_pe/ui/pages/provider/providerPage.dart';
import 'package:wish_pe/widgets/avatar_image.dart';
import 'package:wish_pe/widgets/newWidget/emptyList.dart';
import 'package:provider/provider.dart';

class HorizontalSquareList extends StatelessWidget {
  final List<ItemModel> items;
  const HorizontalSquareList({
    Key? key,
    required this.items,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final devicePexelRatio = MediaQuery.of(context).devicePixelRatio;
    if (items.isEmpty) {
      return Center(
        child: NotifyText(
          title: "No items found",
        ),
      );
    }
    return SizedBox(
      height: 210,
      child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: items.length,
          itemBuilder: (context, i) {
            final item = items[i];
            return InkWell(
              onTap: () {
                Navigator.push(
                    context,
                    CupertinoPageRoute(
                        builder: (context) => ItemDetailPage(
                              item: item,
                            )));
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                  width: 150,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(5),
                        child: item.imageUrl!.startsWith("data:")
                            ? buildBase64Image(item.imageUrl!, 150, 150)
                            : CachedNetworkImage(
                                imageUrl: item.imageUrl!,
                                width: 150,
                                height: 150,
                                maxHeightDiskCache:
                                    (200 * devicePexelRatio).round(),
                                maxWidthDiskCache:
                                    (200 * devicePexelRatio).round(),
                                memCacheHeight:
                                    (200 * devicePexelRatio).round(),
                                memCacheWidth: (200 * devicePexelRatio).round(),
                                fit: BoxFit.cover,
                              ),
                      ),
                      const SizedBox(height: 7),
                      Text(
                        item.title!,
                        maxLines: 2,
                        style: Theme.of(context)
                            .textTheme
                            .bodyLarge!
                            .copyWith(color: Colors.grey),
                      )
                    ],
                  ),
                ),
              ),
            );
          }),
    );
  }
}

class HorizontalCategoryList extends StatelessWidget {
  const HorizontalCategoryList({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final devicePexelRatio = MediaQuery.of(context).devicePixelRatio;
    final state = Provider.of<SearchState>(context);
    final categories = state.categorylist ?? [];
    if (categories.isEmpty) {
      return Center(
        child: NotifyText(
          title: "No category found",
        ),
      );
    } else
      categories.shuffle();
    return SizedBox(
      height: 210,
      child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: categories.length,
          itemBuilder: (context, i) {
            final item = categories[i];
            return InkWell(
              onTap: () {
                Navigator.push(
                    context,
                    CupertinoPageRoute(
                        builder: (context) => CategoryPage(category: item)));
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                  width: 150,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(5),
                        child: item.imageUrl!.startsWith("data:")
                            ? buildBase64Image(item.imageUrl!, 150, 150)
                            : CachedNetworkImage(
                                imageUrl: item.imageUrl!,
                                width: 150,
                                height: 150,
                                maxHeightDiskCache:
                                    (200 * devicePexelRatio).round(),
                                maxWidthDiskCache:
                                    (200 * devicePexelRatio).round(),
                                memCacheHeight:
                                    (200 * devicePexelRatio).round(),
                                memCacheWidth: (200 * devicePexelRatio).round(),
                                fit: BoxFit.cover,
                              ),
                      ),
                      const SizedBox(height: 7),
                      Text(
                        item.name!,
                        maxLines: 2,
                        style: Theme.of(context)
                            .textTheme
                            .bodyLarge!
                            .copyWith(color: Colors.grey),
                      )
                    ],
                  ),
                ),
              ),
            );
          }),
    );
  }
}

// ignore: must_be_immutable
class HorizontalCircleList extends StatelessWidget {
  String? categoryKey;
  List<String>? providerKeys;
  bool? isFollowing;
  double? size;
  bool? isText;
  late List<UserModel> list;
  HorizontalCircleList(
      {Key? key,
      this.categoryKey,
      this.providerKeys,
      this.isFollowing = false,
      this.size = 150,
      this.isText = true})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<SearchState>(context);
    list = state.providerList ?? [];

    if (providerKeys != null) {
      list =
          list.where((element) => providerKeys!.contains(element.key)).toList();
    }

    if (isFollowing!) {
      list = state.followingProviderList ?? [];
    }

    if (topProviders.isEmpty) {
      return Center(
        child: NotifyText(
          title: "No providers found",
        ),
      );
    }
    return SizedBox(
      height: size! + (isText! ? 40 : 22),
      child: ListView.builder(
          itemCount: topProviders.length,
          scrollDirection: Axis.horizontal,
          itemBuilder: (context, i) {
            final provider = topProviders[i];
            return InkWell(
              onTap: () {
                Navigator.push(
                    context,
                    ProviderPage.getRoute(
                        providerKey: provider.key!, categoryKey: categoryKey));
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                  width: size,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ClipOval(
                        child: ImageOrAvatar(
                            imagePath: 'assets/images/' +
                                provider.displayName!.toLowerCase() +
                                '.png',
                            width: size!,
                            height: size!,
                            name: provider.displayName!),
                      ),
                      Visibility(
                        visible: isText!,
                        child: const SizedBox(height: 5),
                      ),
                      Visibility(
                        visible: isText!,
                        child: Text(
                          provider.displayName!,
                          maxLines: 1,
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge!
                              .copyWith(color: Colors.grey),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
    );
  }

  List<UserModel> get topProviders {
    // Sort the filtered lists based on likes count
    list.sort((a, b) => (b.followers ?? 0).compareTo(a.followers ?? 0));

    // Take the top 15 lists
    return list.take(10).toList();
  }
}
