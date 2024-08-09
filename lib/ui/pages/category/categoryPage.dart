import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:wish_pe/helper/stringMethods.dart';
import 'package:wish_pe/model/categoryModel.dart';
import 'package:wish_pe/model/itemModel.dart';
import 'package:wish_pe/state/listState.dart';
import 'package:wish_pe/state/searchState.dart';
import 'package:wish_pe/ui/pages/common/item.dart';
import 'package:wish_pe/ui/pages/feed/widgets/horizontalLists.dart';
import 'package:wish_pe/state/itemState.dart';
import 'package:provider/provider.dart';

class CategoryPage extends StatelessWidget {
  final CategoryModel category;
  const CategoryPage({
    Key? key,
    required this.category,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final devicePexelRatio = MediaQuery.of(context).devicePixelRatio;
    final width = MediaQuery.of(context).size.width;

    final state = Provider.of<ItemState>(context);
    final listState = Provider.of<ListState>(context);
    final list = state.getItemsByCategory(category.key, listState) ?? [];
    final providerKeys =
        state.getProvidersByCategory(category.key, listState) ?? [];

    final searchState = Provider.of<SearchState>(context);
    return Scaffold(
        backgroundColor: Colors.black,
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              expandedHeight: 200,
              backgroundColor: Colors.black,
              iconTheme: IconThemeData(color: Colors.white),
              flexibleSpace: FlexibleSpaceBar(
                centerTitle: true,
                collapseMode: CollapseMode.pin,
                background: ClipRRect(
                  child: Stack(
                    children: [
                      CachedNetworkImage(
                        imageUrl: category.imageUrl!,
                        height: 200,
                        memCacheHeight: (200 * devicePexelRatio).round(),
                        memCacheWidth: (width * devicePexelRatio).round(),
                        maxHeightDiskCache: (200 * devicePexelRatio).round(),
                        maxWidthDiskCache: (width * devicePexelRatio).round(),
                        width: MediaQuery.of(context).size.width,
                        fit: BoxFit.cover,
                      ),
                      BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.center,
                              colors: [
                                Colors.black,
                                Colors.black.withOpacity(0.5),
                              ],
                            ),
                          ),
                          height: 250,
                          width: MediaQuery.of(context).size.width,
                        ),
                      )
                    ],
                  ),
                ),
                title: Text(
                  category.name!.toTitleCase(),
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 16.0, horizontal: 16),
                  child: Text(
                    "Top Providers",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: HorizontalCircleList(
                    categoryKey: category.key,
                    providerKeys: providerKeys,
                    size: 60),
              ),
            ),
            /*
            SliverToBoxAdapter(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 16.0, horizontal: 16),
                  child: Text(
                    "Best Lists",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
            */
            /*
            SliverToBoxAdapter(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16),
                child: Text(
                  "Items",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
            */
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (_, i) {
                  return Item(
                    item: list[i],
                    subTitleText: getSubTitle(list[i], searchState),
                  );
                },
                childCount: list.length,
              ),
            ),
            const SliverToBoxAdapter(
              child: SizedBox(height: 150),
            )
          ],
        ));
  }

  String getSubTitle(ItemModel model, SearchState searchState) {
    String subTitle = '';
    if (model.price != null && model.price!.isNotEmpty) {
      subTitle += model.price!;
    }
    if (subTitle.length > 1) {
      subTitle += ' • ';
    }
    subTitle += searchState.getUserFromKey(model.userId).displayName!;

    return subTitle;
  }
}
