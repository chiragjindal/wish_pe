import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wish_pe/model/itemModel.dart';
import 'package:wish_pe/model/listModel.dart';
import 'package:wish_pe/state/itemState.dart';
import 'package:wish_pe/state/listState.dart';
import 'package:wish_pe/ui/pages/common/item.dart';
import 'package:wish_pe/ui/pages/common/listWidget.dart';
import 'package:wish_pe/ui/pages/list/listPage.dart';
import 'package:wish_pe/widgets/newWidget/emptyList.dart';
import 'package:provider/provider.dart';

class LikedItems extends StatelessWidget {
  const LikedItems({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final itemState = Provider.of<ItemState>(context);
    final listState = Provider.of<ListState>(context);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              expandedHeight: 100,
              backgroundColor: Colors.black,
              iconTheme: IconThemeData(color: Colors.white),
              flexibleSpace: FlexibleSpaceBar(
                centerTitle: true,
                collapseMode: CollapseMode.pin,
                background: ClipRRect(
                  child: Stack(
                    children: [
                      CachedNetworkImage(
                        imageUrl:
                            'https://images.unsplash.com/photo-1578070181910-f1e514afdd08?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=933&q=80',
                        height: 100,
                        memCacheHeight:
                            (100 * MediaQuery.of(context).devicePixelRatio)
                                .round(),
                        memCacheWidth: (MediaQuery.of(context).size.width *
                                MediaQuery.of(context).devicePixelRatio)
                            .round(),
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
                          height: 150,
                          width: MediaQuery.of(context).size.width,
                        ),
                      )
                    ],
                  ),
                ),
                title: Text(
                  "Liked",
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
            /*
            SliverToBoxAdapter(
                child: ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, i) {
                return Item(
                    item: list[i],
                    onDismissedAction: () {
                      state.addLikeToItem(list[i]);
                    });
              },
              itemCount: list.length,
            )),
            const SliverToBoxAdapter(
              child: SizedBox(height: 150),
            )*/
            SliverToBoxAdapter(
              child: TabBar(
                tabs: [
                  Tab(text: 'Items'),
                  Tab(text: 'Lists'),
                ],
                labelColor: Colors.white,
                unselectedLabelColor: Colors.grey,
                indicatorColor: Colors.white,
              ),
            ),
            SliverFillRemaining(
              child: TabBarView(
                children: [
                  buildItemTab(itemState.likedItems ?? [], itemState),
                  buildListTab(listState.likedLists ?? [], listState),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget buildItemTab(List<ItemModel> list, ItemState state) {
  return list.isEmpty
      ? Container(
          width: double.infinity,
          padding: const EdgeInsets.only(top: 0, left: 10, right: 10),
          child: NotifyText(
            title: 'No Items to View',
            subTitle: 'When liked they\'ll be listed here.',
          ),
        )
      : ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, i) {
            return Item(
              item: list[i],
              onDismissedAction: () {
                state.addLikeToItem(list[i]);
              },
            );
          },
          itemCount: list.length,
        );
}

Widget buildListTab(List<ListModel> list, ListState state) {
  return list.isEmpty
      ? Container(
          width: double.infinity,
          padding: const EdgeInsets.only(top: 0, left: 10, right: 10),
          child: NotifyText(
            title: 'No Lists to View',
            subTitle: 'When liked they\'ll be listed here.',
          ),
        )
      : ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, i) {
            return ListWidget(
              list: list[i],
              onTapAction: () {
                Navigator.push(
                    context,
                    CupertinoPageRoute(
                        builder: (context) => ListPage(list: list[i])));
              },
              onDismissedAction: () {
                state.addLikeToList(list[i]);
              },
            );
          },
          itemCount: list.length,
        );
}
