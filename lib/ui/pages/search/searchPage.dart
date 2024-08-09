import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wish_pe/helper/stringMethods.dart';
import 'package:wish_pe/model/categoryModel.dart';
import 'package:wish_pe/state/itemState.dart';
import 'package:wish_pe/state/listState.dart';
import 'package:wish_pe/state/searchState.dart';
import 'package:wish_pe/ui/pages/category/categoryPage.dart';
import 'package:wish_pe/ui/pages/feed/widgets/customTitle.dart';
import 'package:wish_pe/ui/pages/feed/widgets/welcomeTitle.dart';
import 'package:wish_pe/ui/pages/search/searchResultPage.dart';
import 'package:wish_pe/widgets/newWidget/emptyList.dart';
import 'package:provider/provider.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({Key? key, this.scaffoldKey}) : super(key: key);

  final GlobalKey<ScaffoldState>? scaffoldKey;

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<SearchState>(context);
    final itemState = Provider.of<ItemState>(context);
    final listState = Provider.of<ListState>(context);

    final allCategories = state.categorylist ?? [];
    final topCategories = allCategories
        .where((element) => itemState
            .getTopFollowingCategories(listState)!
            .contains(element.key))
        .toList();
    if (topCategories.length > 4)
      topCategories.removeRange(4, topCategories.length);
    allCategories.removeWhere((element) => topCategories.contains(element.key));

    return Scaffold(
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: SafeArea(
          child: NestedScrollView(
            headerSliverBuilder:
                (BuildContext context, bool innerBoxIsScrolled) {
              return [
                SliverToBoxAdapter(
                  child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: WelcomeTitle(
                        title: 'Search',
                      )),
                ),
                const SliverToBoxAdapter(
                    child: SizedBox(
                  height: 5,
                )),
                SliverPersistentHeader(
                  pinned: true,
                  delegate: SliverSearchAppBar(),
                ),
              ];
            },
            body: ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 18.0),
                  child: CustomTitle(title: 'Your Top category'),
                ),
                topCategories.length < 1
                    ? NotifyText(
                        title: "No category found",
                      )
                    : GridView.builder(
                        itemCount: topCategories.length,
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 14,
                          crossAxisSpacing: 14,
                          childAspectRatio: 16 / 8,
                        ),
                        itemBuilder: (context, i) {
                          return CategoryWidget(category: topCategories[i]);
                        },
                      ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24.0),
                  child: CustomTitle(title: 'Browse all'),
                ),
                allCategories.length < 5
                    ? NotifyText(
                        subTitle:
                            "when new categories added, they'll appear here",
                      )
                    : GridView.builder(
                        itemCount: allCategories.sublist(4).length,
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 14,
                          crossAxisSpacing: 14,
                          childAspectRatio: 16 / 8,
                        ),
                        itemBuilder: (context, i) {
                          return CategoryWidget(
                              category: allCategories.sublist(4)[i]);
                        },
                      ),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CategoryWidget extends StatelessWidget {
  final CategoryModel category;
  const CategoryWidget({
    Key? key,
    required this.category,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
            context,
            CupertinoPageRoute(
                builder: (context) => CategoryPage(category: category)));
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(5),
        child: Container(
          decoration: BoxDecoration(
              color: category.color,
              borderRadius: BorderRadius.circular(5),
              boxShadow: [
                BoxShadow(
                    color: Colors.grey.shade900,
                    offset: const Offset(1, 1),
                    spreadRadius: 1,
                    blurRadius: 50,
                    blurStyle: BlurStyle.outer),
              ]),
          child: Stack(
            children: [
              const SizedBox(
                width: double.infinity,
                height: double.infinity,
              ),
              Positioned(
                bottom: 5,
                right: -15,
                child: RotationTransition(
                  turns: const AlwaysStoppedAnimation(385 / 360),
                  child: Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: category.color,
                      borderRadius: BorderRadius.circular(3),
                      boxShadow: kElevationToShadow[2],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: CachedNetworkImage(
                        imageUrl: category.imageUrl!,
                        fit: BoxFit.cover,
                        width: 70,
                        height: 70,
                        maxHeightDiskCache: 120,
                        maxWidthDiskCache: 120,
                        memCacheHeight:
                            (120 * MediaQuery.of(context).devicePixelRatio)
                                .round(),
                        memCacheWidth:
                            (120 * MediaQuery.of(context).devicePixelRatio)
                                .round(),
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                child: Text(
                  category.name!.toTitleCase(),
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SliverSearchAppBar extends SliverPersistentHeaderDelegate {
  SliverSearchAppBar();
  @override
  Widget build(context, double shrinkOffset, bool overlapsContent) {
    return InkWell(
      onTap: () {
        Navigator.push(context,
            CupertinoPageRoute(builder: (context) => SearchResultsPage()));
      },
      child: Container(
        color: Colors.black,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          child: Container(
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(5),
            ),
            height: 50,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Row(
                children: [
                  const SizedBox(
                      height: 50, child: Icon(CupertinoIcons.search)),
                  const SizedBox(width: 10),
                  Text(
                    "Lists, Items, Categories or Users",
                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                          color: Colors.grey.shade800,
                          fontSize: 18,
                        ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  double get maxExtent => 70;

  @override
  double get minExtent => 70;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) => true;
}
