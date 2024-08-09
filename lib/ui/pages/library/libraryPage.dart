import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wish_pe/helper/enum.dart';
import 'package:wish_pe/model/listModel.dart';
import 'package:wish_pe/ui/pages/common/listWidget.dart';
import 'package:wish_pe/ui/pages/feed/widgets/welcomeTitle.dart';
import 'package:wish_pe/ui/pages/library/likedItems.dart';
import 'package:wish_pe/ui/pages/library/listCard.dart';
import 'package:wish_pe/ui/pages/list/listPage.dart';
import 'package:wish_pe/ui/widgets/newListDialogWidget.dart';
import 'package:wish_pe/state/itemState.dart';
import 'package:wish_pe/state/listState.dart';
import 'package:wish_pe/ui/theme/theme.dart';
import 'package:wish_pe/widgets/newWidget/title_text.dart';
import 'package:provider/provider.dart';

class Library extends StatefulWidget {
  const Library({Key? key, required this.scaffoldKey}) : super(key: key);

  final GlobalKey<ScaffoldState> scaffoldKey;

  @override
  _LibraryState createState() => _LibraryState();
}

class _LibraryState extends State<Library> {
  bool isGridView = true;

  void openBottomSheet(
      BuildContext context, double height, Widget child) async {
    await showModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: context,
      builder: (context) {
        return Container(
          height: height,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(15),
              topRight: Radius.circular(15),
            ),
          ),
          child: child,
        );
      },
    );
  }

  void openListSortSettings(BuildContext context, ListState state) {
    openBottomSheet(
      context,
      280,
      Column(
        children: <Widget>[
          const SizedBox(height: 5),
          Container(
            width: 40,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: TitleText('Sort By', color: Colors.white),
          ),
          const Divider(height: 0),
          _row(context, "Alphabetically", SortList.Alphabetically, state),
          const Divider(height: 0),
          _row(context, "Newest list", SortList.Newest, state),
          const Divider(height: 0),
          _row(context, "Oldest list", SortList.Oldest, state),
          const Divider(height: 0),
          _row(context, "Item Count", SortList.ItemCount, state),
        ],
      ),
    );
  }

  Widget _row(
      BuildContext context, String text, SortList sortBy, ListState state) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 5),
      child: RadioListTile<SortList>(
        value: sortBy,
        activeColor: Colors.white,
        groupValue: state.sortBy,
        onChanged: (val) {
          state.updateListSortPrefrence = val!;
          Navigator.pop(context);
        },
        title: Text(text, style: TextStyles.subtitleStyle),
        controlAffinity: ListTileControlAffinity.trailing,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<ItemState, ListState>(
      builder: (context, feedState, listState, child) {
        final listList = listState.myLists ?? [];
        final defaultList = listState.myDefaultList!;
        listList.remove(defaultList);
        return _body(context, listList, defaultList, feedState, listState);
      },
    );
  }

  Widget _body(
    BuildContext context,
    List<ListModel> listList,
    ListModel defaultList,
    ItemState feedState,
    ListState listState,
  ) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: LibraryAppBar(
        scaffoldKey: widget.scaffoldKey,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              height: 10,
            ),
            InkWell(
              onTap: () async {
                Navigator.push(context,
                    CupertinoPageRoute(builder: (context) => LikedItems()));
              },
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20.0, vertical: 4),
                child: Row(
                  children: [
                    ClipRRect(
                        borderRadius: BorderRadius.circular(5),
                        child: Container(
                          width: 60,
                          height: 60,
                          color: Colors.blue,
                          child: const Center(
                            child: Icon(
                              CupertinoIcons.heart_fill,
                              color: Colors.white,
                            ),
                          ),
                        )),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Liked',
                            style:
                                TextStyle(color: Colors.white, fontSize: 16.0),
                          ),
                          const SizedBox(height: 5),
                          // Text(
                          //   // ignore: unnecessary_null_comparison
                          //   (likedItemList == null
                          //           ? "0"
                          //           : likedItemList.length.toString()) +
                          //       " Items",
                          //   style: const TextStyle(
                          //       color: Colors.grey, fontSize: 14.0),
                          // ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            InkWell(
              onTap: () async {
                Navigator.push(
                    context,
                    CupertinoPageRoute(
                        builder: (context) => ListPage(list: defaultList)));
              },
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20.0, vertical: 4),
                child: Row(
                  children: [
                    ClipRRect(
                        borderRadius: BorderRadius.circular(5),
                        child: Container(
                          width: 60,
                          height: 60,
                          color: Colors.green,
                          child: const Center(
                            child: Icon(
                              CupertinoIcons.star_fill,
                              color: Colors.white,
                            ),
                          ),
                        )),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'My ' + defaultList.name!,
                            style:
                                TextStyle(color: Colors.white, fontSize: 16.0),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            defaultList.itemKeyList!.length.toString() +
                                " Items",
                            style: const TextStyle(
                                color: Colors.grey, fontSize: 14.0),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            /*
            InkWell(
              /*
              onTap: () async {
                Navigator.push(
                    context,
                    CupertinoPageRoute(
                        builder: (context) => ListPage(list: defaultList)));
              },
              */
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20.0, vertical: 4),
                child: Row(
                  children: [
                    ClipRRect(
                        borderRadius: BorderRadius.circular(5),
                        child: Container(
                          width: 60,
                          height: 60,
                          color: Colors.orange,
                          child: const Center(
                            child: Icon(
                              CupertinoIcons.share_solid,
                              color: Colors.white,
                            ),
                          ),
                        )),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Shared With You',
                            style:
                                TextStyle(color: Colors.white, fontSize: 16.0),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            "! Coming Soon !",
                            style: const TextStyle(
                                color: Colors.grey, fontSize: 14.0),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),*/
            SingleChildScrollView(
              physics: const NeverScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (listList.length != 0)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 24.0, horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: () {
                              openListSortSettings(context, listState);
                            },
                            child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Icon(
                                    Icons.sort,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    context.select((ListState value) =>
                                        value.selectedFilter),
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 12.0),
                                  ),
                                ]),
                          ),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                isGridView =
                                    !isGridView; // Toggle between grid and list view
                              });
                            },
                            child: Icon(
                              isGridView
                                  ? Icons.view_list
                                  : Icons
                                      .grid_view, // Toggle icons based on view mode
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  isGridView
                      ? Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: ListCard(listList: listList),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: listList.length,
                          itemBuilder: (context, i) {
                            return ListWidget(
                                list: listList[i],
                                onTapAction: () {
                                  Navigator.push(
                                      context,
                                      CupertinoPageRoute(
                                          builder: (context) =>
                                              ListPage(list: listList[i])));
                                },
                                onDismissedAction: () {
                                  listState.deleteList(listList[i].key!);
                                });
                          }),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class LibraryAppBar extends StatelessWidget implements PreferredSizeWidget {
  LibraryAppBar({Key? key, required this.scaffoldKey}) : super(key: key);
  final GlobalKey<ScaffoldState> scaffoldKey;

  @override
  Widget build(BuildContext context) {
    TextEditingController con = TextEditingController();
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      child: Container(
        color: Colors.black,
        child: SafeArea(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.all(0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        SizedBox(
                          width: 30,
                          height: 30,
                          child: IconButton(
                            icon: const Icon(Icons.menu),
                            onPressed: () {
                              scaffoldKey.currentState!.openDrawer();
                            },
                            iconSize: 30,
                            color: Colors.white,
                            padding: EdgeInsets.all(0),
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        WelcomeTitle(
                          title: 'Library',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.all(0),
                child: Column(
                  //crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    SizedBox(
                      width: 30,
                      height: 30,
                      child: IconButton(
                        icon: Icon(
                          Icons.add,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return DialogContentWidget(controller: con);
                              });
                        },
                      ),
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

  @override
  Size get preferredSize => const Size.fromHeight(65);
}
