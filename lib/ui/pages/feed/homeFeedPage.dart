import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:wish_pe/helper/greeting.dart';
import 'package:wish_pe/model/itemModel.dart';
import 'package:wish_pe/model/listModel.dart';
import 'package:wish_pe/resource/gemini_client.dart';
import 'package:wish_pe/resource/gemini_prompts.dart';
import 'package:wish_pe/state/itemState.dart';
import 'package:wish_pe/state/listState.dart';
import 'package:wish_pe/ui/pages/feed/widgets/customTitle.dart';
import 'package:wish_pe/ui/pages/feed/widgets/horizontalLists.dart';
import 'package:wish_pe/ui/pages/feed/widgets/topList.dart';
import 'package:wish_pe/ui/pages/feed/widgets/weeklyList.dart';
import 'package:wish_pe/ui/pages/feed/widgets/weeklyTitle.dart';
import 'package:wish_pe/ui/pages/feed/widgets/welcomeTitle.dart';
import 'package:wish_pe/ui/theme/theme.dart';
import 'package:provider/provider.dart';

class HomeFeedPage extends StatelessWidget {
  const HomeFeedPage(
      {Key? key, required this.scaffoldKey, this.refreshIndicatorKey})
      : super(key: key);

  final GlobalKey<ScaffoldState> scaffoldKey;

  final GlobalKey<RefreshIndicatorState>? refreshIndicatorKey;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SizedBox(
          height: context.height,
          width: context.width,
          child: RefreshIndicator(
            key: refreshIndicatorKey,
            onRefresh: () async {
              var itemState = Provider.of<ItemState>(context, listen: false);
              var listState = Provider.of<ListState>(context, listen: false);
              itemState.getDataFromDatabase();
              listState.getDataFromDatabase();
              return Future.value(true);
            },
            child: _HomeFeedPageBody(
              refreshIndicatorKey: refreshIndicatorKey,
              scaffoldKey: scaffoldKey,
            ),
          ),
        ),
      ),
    );
  }
}

// ignore: must_be_immutable
class _HomeFeedPageBody extends StatelessWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;

  final GlobalKey<RefreshIndicatorState>? refreshIndicatorKey;
  late List<ListModel> lists;
  late List<ItemModel> items;

  late List<ListModel> followedFeedLists;
  late List<ItemModel> followedFeedItems;

  late List<ListModel> _generatedLists = [];
  late List<ItemModel> _generatedItems = [];

  _HomeFeedPageBody(
      {Key? key, required this.scaffoldKey, this.refreshIndicatorKey})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer2<ListState, ItemState>(
      builder: (context, state, feedState, child) {
        lists = state.isBusy ? [] : state.homeLists ?? [];
        items = feedState.getItems(state.getItemKeys(lists)) ?? [];

        followedFeedLists = state.isBusy ? [] : state.followingPageLists ?? [];
        followedFeedItems =
            feedState.getItems(state.getItemKeys(followedFeedLists)) ?? [];
        generateListsForYou(state);
        generateItemsForYou(feedState);

        List<Widget> homeTiles = [
          WelcomeTitle(
            title: greeting(),
            showIcon: true,
          ),
          SizedBox(
            height: 28,
          ),
          WeeklyTitle(),
          SizedBox(
            height: 24,
          ),
        ];

        if (weeklyLists.isNotEmpty) {
          homeTiles.addAll([
            WeeklyList(lists: weeklyLists),
            SizedBox(
              height: 16,
            ),
          ]);
        }

        if (generatedListsForYou.isNotEmpty) {
          homeTiles.addAll([
            WeeklyTitle(
                icon: IconButton(
                  icon: Image.asset('assets/images/Google-Gemini-AI-Icon.png'),
                  iconSize: 12,
                  padding: EdgeInsets.all(0),
                  onPressed: () {},
                ),
                text: 'Picked for you'),
            SizedBox(
              height: 12,
            ),
            TopList(lists: generatedListsForYou.take(15).toList()),
            SizedBox(
              height: 12,
            ),
          ]);
        }

        if (topLists.isNotEmpty) {
          homeTiles.addAll([
            CustomTitle(title: 'Top Lists'),
            SizedBox(
              height: 12,
            ),
            TopList(lists: topLists),
            SizedBox(
              height: 12,
            ),
          ]);
        }

        if (recentItems.isNotEmpty) {
          homeTiles.addAll([
            CustomTitle(title: 'Recently Added'),
            SizedBox(
              height: 12,
            ),
            HorizontalSquareList(items: recentItems),
            SizedBox(
              height: 12,
            ),
          ]);
        }

        if (generatedItemsForYou.isNotEmpty) {
          homeTiles.addAll([
            WeeklyTitle(
                icon: IconButton(
                  icon: Image.asset('assets/images/Google-Gemini-AI-Icon.png'),
                  iconSize: 12,
                  padding: EdgeInsets.all(0),
                  onPressed: () {},
                ),
                text: 'More of what you like'),
            SizedBox(
              height: 12,
            ),
            HorizontalSquareList(items: generatedItemsForYou.take(15).toList()),
            SizedBox(
              height: 12,
            ),
          ]);
        }

        homeTiles.addAll([
          CustomTitle(title: 'Best of Providers'),
          SizedBox(
            height: 12,
          ),
          HorizontalCircleList(),
          SizedBox(
            height: 12,
          ),
          CustomTitle(title: 'Based on Category'),
          SizedBox(
            height: 12,
          ),
          HorizontalCategoryList(),
          SizedBox(
            height: 16,
          ),
        ]);

        return SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: homeTiles,
            ),
          ),
        );
      },
    );
  }

  List<ListModel> get weeklyLists {
    // Filter lists created in the last week
    DateTime now = DateTime.now();
    DateTime lastWeek = now.subtract(Duration(days: 7));
    List<ListModel> listsLastWeek = lists.where((list) {
      DateTime createdAt = DateTime.parse(list.createdAt);
      return createdAt.isAfter(lastWeek);
    }).toList();

    // Sort the filtered lists based on likes count
    listsLastWeek.sort(
        (a, b) => (a.likeList?.length ?? 0).compareTo(b.likeList?.length ?? 0));

    // Take the top 15 lists
    return listsLastWeek.take(15).toList();
  }

  List<ListModel> get topLists {
    // Sort the filtered lists based on likes count
    lists.sort(
        (a, b) => (a.likeList?.length ?? 0).compareTo(b.likeList?.length ?? 0));

    // Take the top 15 lists
    return lists.take(15).toList();
  }

  List<ItemModel> get recentItems {
    items.sort((a, b) =>
        DateTime.parse(b.createdAt).compareTo(DateTime.parse(a.createdAt)));

    // Take the top 15 lists
    return items.take(15).toList();
  }

  List<ListModel> get generatedListsForYou => _generatedLists;
  List<ItemModel> get generatedItemsForYou => _generatedItems;

  void generateListsForYou(ListState state) {
    String goldSet = formatInputDataForListPrompt(
        followedFeedLists, followedFeedItems, "GoldSet--");
    String testSet =
        goldSet + formatInputDataForListPrompt(lists, items, "TestSet--");

    final gemini = GeminiClient();
    gemini
        .generateContent(prompt: personalizedListsPrompt, input: testSet)
        .then((value) {
      final keys = jsonDecode(value.split('```json\n')[1].split('```')[0]);
      for (var key in keys) {
        _generatedLists.add(state.getListFromKey(key));
      }
    }).catchError((error) {
      print('Error fetching data: $error');
      _generatedLists = [];
    });
  }

  void generateItemsForYou(ItemState state) {
    String goldSet =
        formatInputDataForItemPrompt(followedFeedItems, "GoldSet--");
    String testSet = goldSet + formatInputDataForItemPrompt(items, "TestSet--");

    final gemini = GeminiClient();
    gemini
        .generateContent(prompt: personalizedItemsPrompt, input: testSet)
        .then((value) {
      final keys = jsonDecode(value.split('```json\n')[1].split('```')[0]);
      for (var key in keys) {
        _generatedItems.add(state.getItem(key));
      }
    }).catchError((error) {
      print('Error fetching data: $error');
      _generatedItems = [];
    });
  }

  String formatInputDataForListPrompt(
      List<ListModel> lists, List<ItemModel> items, String prefix) {
    String formattedData = "";
    formattedData += prefix;
    for (var listItem in lists) {
      formattedData += "* **List Name:** ${listItem.name}\n";
      formattedData += "* **List Key:** ${listItem.key}\n";
      formattedData += "  * **Items:**\n";
      for (var item in items) {
        formattedData += "    * **Name:** ${item.title}\n";
      }
      formattedData += "\n";
    }
    return formattedData;
  }

  String formatInputDataForItemPrompt(List<ItemModel> items, String prefix) {
    String formattedData = "";
    formattedData += prefix;
    for (var item in items) {
      formattedData += "    * **Name:** ${item.title}\n";
      formattedData += "    * **Key:** ${item.key}\n";
    }
    formattedData += "\n";
    return formattedData;
  }
}
