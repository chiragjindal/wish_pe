import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wish_pe/model/itemModel.dart';
import 'package:wish_pe/model/listModel.dart';
import 'package:wish_pe/resource/gemini_client.dart';
import 'package:wish_pe/resource/gemini_prompts.dart';
import 'package:wish_pe/state/searchState.dart';
import 'package:wish_pe/ui/pages/common/addItems.dart';
import 'package:wish_pe/ui/pages/common/item.dart';
import 'package:wish_pe/ui/pages/profile/profilePage.dart';
import 'package:wish_pe/ui/widgets/bottomSheetWidget.dart';
import 'package:wish_pe/state/authState.dart';
import 'package:wish_pe/state/itemState.dart';
import 'package:wish_pe/state/listState.dart';
import 'package:wish_pe/ui/widgets/circular_image.dart';
import 'package:wish_pe/ui/theme/theme.dart';
import 'package:wish_pe/ui/widgets/likeButton.dart';
import 'package:wish_pe/widgets/newWidget/rippleButton.dart';
import 'package:wish_pe/widgets/newWidget/title_text.dart';
import 'package:provider/provider.dart';

// ignore: must_be_immutable
class ListPage extends StatelessWidget {
  ListModel? list;
  final String? listKey;
  ListPage({
    Key? key,
    this.list,
    this.listKey,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<ItemState>(context);
    final listState = Provider.of<ListState>(context);
    final authState = Provider.of<AuthState>(context, listen: false);
    final searchState = Provider.of<SearchState>(context, listen: false);

    if (listKey != null) list = listState.getListFromKey(listKey!);
    final itemsList = state.getItems(list!.itemKeyList!);
    final listUser = searchState.getUserFromKey(list!.userId);
    final isMyList = authState.userId == list!.userId;

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
                      imageUrl:
                          "https://images.unsplash.com/photo-1533038590840-1cde6e668a91?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=MnwyNjQwNTF8MHwxfHNlYXJjaHw2N3x8bmF0dXJlfGVufDB8fHx8MTYzNDM4MDExMw&ixlib=rb-1.2.1&q=80&w=1080",
                      height: 200,
                      memCacheHeight:
                          (200 * MediaQuery.of(context).devicePixelRatio)
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
                        height: 250,
                        width: MediaQuery.of(context).size.width,
                      ),
                    )
                  ],
                ),
              ),
              title: Text(
                list!.name!,
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            actions: [
              Visibility(
                visible: list != listState.myDefaultList,
                child: IconButton(
                  icon: Icon(
                    Icons.more_vert,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    showModalBottomSheet(
                        useRootNavigator: true,
                        isScrollControlled: true,
                        elevation: 100,
                        backgroundColor: Colors.black38,
                        context: context,
                        builder: (context) {
                          return BottomSheetWidget(list: list);
                        });
                  },
                ),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.only(left: 16.0, right: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    list!.description ?? "",
                    style: const TextStyle(color: Colors.grey, fontSize: 14.0),
                  ),
                  SizedBox(height: 10.0),
                  Container(
                    padding: EdgeInsets.all(6),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Color.fromARGB(52, 238, 238, 238),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: FutureBuilder<String>(
                      future: generateListDescription(itemsList),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Text(
                            "Loading AI generated description...",
                            style: const TextStyle(
                                color: Colors.grey, fontSize: 12.0),
                          );
                        } else if (snapshot.hasError) {
                          return Text(
                            "Error: ${snapshot.error}",
                            style: const TextStyle(
                                color: Colors.red, fontSize: 12.0),
                          );
                        } else {
                          return Text(
                            snapshot.data ?? "",
                            style: const TextStyle(
                                color: Colors.grey, fontSize: 12.0),
                          );
                        }
                      },
                    ),
                  ),
                  SizedBox(height: 10.0),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(context,
                                ProfilePage.getRoute(profileId: list!.userId));
                          },
                          child: CircularImage(path: listUser.profilePic),
                        ),
                      ),
                      const SizedBox(width: 10),
                      ConstrainedBox(
                        constraints: BoxConstraints(
                            minWidth: 0, maxWidth: context.width * .5),
                        child: TitleText(listUser.displayName!,
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            overflow: TextOverflow.ellipsis),
                      ),
                      Spacer(),
                      !isMyList
                          ? ConstrainedBox(
                              constraints: BoxConstraints(
                                  minWidth: 0, maxWidth: context.width * .5),
                              child: Padding(
                                padding: EdgeInsets.only(right: 30),
                                child: LikeButton(list: list, isIcon: false),
                              ),
                            )
                          : Container(),
                      /*
                      const SizedBox(width: 5),
                      Flexible(
                        child: customText(
                          '${list!.user!.userName}',
                          style: TextStyles.userNameStyle,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),*/
                    ],
                  ),
                  SizedBox(height: 10.0),
                  Text(
                    getListPageSubTitle(context, isMyList),
                    style: const TextStyle(color: Colors.grey, fontSize: 14.0),
                  ),
                ],
              ),
            ),
          ),
          isMyList
              ? SliverToBoxAdapter(
                  child: Align(
                  alignment: Alignment.center,
                  child: Padding(
                    padding: EdgeInsets.only(left: 16.0, right: 8, top: 10),
                    child: RippleButton(
                      splashColor: ColorConstants.primaryColor,
                      borderRadius: const BorderRadius.all(Radius.circular(60)),
                      onPressed: () {
                        Navigator.push(
                            context,
                            CupertinoPageRoute(
                                builder: (context) => AddItemsPage(
                                      list: list!,
                                    )));
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          border: Border.all(color: Colors.grey, width: 1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Add items',
                          style: TextStyle(
                            color: WishPeColor.white,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ),
                ))
              : const SliverToBoxAdapter(
                  child: SizedBox(),
                ),
          SliverToBoxAdapter(
            child: ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, i) {
                return Item(
                    item: itemsList![i],
                    parentList: list!,
                    onDismissedAction: () {
                      listState.addToList(list!, itemsList[i].key!);
                    });
              },
              itemCount: itemsList == null ? 0 : itemsList.length,
            ),
          ),
          const SliverToBoxAdapter(
            child: SizedBox(height: 20),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.only(
                left: 16.0,
                right: 16,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          TitleText(
                            "Story Board",
                            fontSize: 14,
                            color: Colors.white,
                          ),
                          IconButton(
                            icon: Image.asset(
                                'assets/images/Google-Gemini-AI-Icon.png'),
                            onPressed: () {},
                          ),
                        ],
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 0),
                        child: RippleButton(
                          splashColor: ColorConstants.primaryColor,
                          borderRadius:
                              const BorderRadius.all(Radius.circular(60)),
                          onPressed: () {
                            generateListStory(listState, itemsList);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              border: Border.all(color: Colors.grey, width: 1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              list!.story == null || list!.story!.isEmpty
                                  ? 'Create Story'
                                  : 'Regenerate Story',
                              style: TextStyle(
                                color: WishPeColor.white,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: EdgeInsets.all(6),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Color.fromARGB(52, 238, 238, 238),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: list!.story == null || list!.story!.isEmpty
                        ? Text(
                            "Spinning your wishlist story with AI...",
                            style: const TextStyle(
                                color: Colors.grey, fontSize: 12.0),
                          )
                        : ExpandableStoryWidget(
                            story: list!.story!,
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String getListPageSubTitle(BuildContext context, bool isMyList) {
    var retVal = '';
    if (!isMyList) {
      retVal += list!.likeList!.length.toString() + ' likes • ';
    }

    return retVal +
        (list!.itemKeyList == null || list!.itemKeyList!.isEmpty
            ? '0'
            : list!.itemKeyList!.length.toString()) +
        " Items";
  }

  Future<String> generateListDescription(List<ItemModel>? items) async {
    String details = "List: ${list!.name ?? 'Untitled'} \n";
    if (list!.description != null && list!.description!.isNotEmpty) {
      details += "Description: ${list!.description} \n";
    }

    // Add item details
    if (items != null && items.isNotEmpty) {
      details += "Items:\n";
      for (ItemModel item in items) {
        details += "- ${item.title ?? 'Untitled'}\n";
        if (item.price != null) {
          details += "   Price: ${item.price}\n";
        }
        details += "\n";
      }
    }

    final gemini = GeminiClient();
    final res = await gemini.generateContent(
        prompt: listDescriptionPrompt, input: details);
    return res;
  }

  Future<void> generateListStory(
      ListState listState, List<ItemModel>? items) async {
    String details = "List: ${list!.name ?? 'Untitled'} \n";
    if (list!.description != null && list!.description!.isNotEmpty) {
      details += "Description: ${list!.description} \n";
    }

    // Add item details
    if (items != null && items.isNotEmpty) {
      details += "Items:\n";
      for (ItemModel item in items) {
        details += "- ${item.title ?? 'Untitled'}\n";
        if (item.price != null) {
          details += "   Price: ${item.price}\n";
        }
        details += "\n";
      }
    }

    final gemini = GeminiClient();
    final res =
        await gemini.generateContent(prompt: listStoryPrompt, input: details);

    list!.story = res;
    listState.updateList(list!);
  }
}

class ExpandableStoryWidget extends StatefulWidget {
  final String story;
  ExpandableStoryWidget({required this.story});

  @override
  _ExpandableStoryWidgetState createState() => _ExpandableStoryWidgetState();
}

class _ExpandableStoryWidgetState extends State<ExpandableStoryWidget> {
  bool _isExpanded = false;

  void _toggleExpansion() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggleExpansion,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _isExpanded
                ? widget.story
                : '${widget.story.length > 100 ? widget.story.substring(0, 100) + '...' : widget.story}',
            style: const TextStyle(color: Colors.grey, fontSize: 12.0),
          ),
          if (widget.story.length > 100)
            Text(
              _isExpanded ? 'Read Less' : 'Read More',
              style: TextStyle(
                color: Theme.of(context).cardColor,
                fontSize: 12.0,
                fontWeight: FontWeight.bold,
              ),
            ),
        ],
      ),
    );
  }
}
