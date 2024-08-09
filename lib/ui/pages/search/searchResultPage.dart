import 'package:flutter/material.dart';
import 'package:wish_pe/state/itemState.dart';
import 'package:wish_pe/state/listState.dart';
import 'package:wish_pe/state/searchState.dart';
import 'package:wish_pe/ui/pages/search/recentSearch.dart';
import 'package:wish_pe/ui/pages/search/searchHelper.dart';
import 'package:provider/provider.dart';

class SearchResultsPage extends StatefulWidget {
  const SearchResultsPage({
    Key? key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _SearchResultsPageState();
}

class _SearchResultsPageState extends State<SearchResultsPage> {
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = Provider.of<SearchState>(context, listen: false);
      state.resetFilterList();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final feedState = context.watch<ItemState>();
    final listState = context.watch<ListState>();
    final state = Provider.of<SearchState>(context);
    state.setSearchItemList(
        feedState.getSearchItems(listState), listState.searchLists);
    final searchList = state.searchFilterlist;

    return Scaffold(
        backgroundColor: Colors.black,
        appBar: CustomAppBar(
          controller: _searchController,
          onPressed: () {
            state.resetFilterList();
            _searchController.clear();
          },
          onChanged: (String? text) {
            state.filterBySearch(text);
          },
        ),
        body: Builder(
          builder: (context) {
            if (_searchController.text.isEmpty) {
              return RecentSearch();
            } else {
              return ListView.builder(
                  itemCount: searchList!.length,
                  itemBuilder: (context, i) {
                    final info = searchList[i];
                    return getSearchResultTile(
                        info, state, feedState, listState, context);
                  });
            }
          },
        ));
  }
}

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final TextEditingController controller;
  final void Function(String? s) onChanged;
  final void Function() onPressed;
  const CustomAppBar({
    Key? key,
    required this.controller,
    required this.onChanged,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        color: Colors.grey.shade800,
        height: 60,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            children: [
              Container(
                color: Colors.grey.shade800,
                child: IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ),
              Expanded(
                child: TextField(
                  autofocus: true,
                  controller: controller,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: "Search",
                    filled: true,
                    hintStyle: const TextStyle(color: Colors.grey),
                    fillColor: Colors.grey.shade800,
                    border: InputBorder.none,
                  ),
                  onChanged: onChanged,
                ),
              ),
              Container(
                color: Colors.grey.shade800,
                child: IconButton(
                  splashRadius: 20,
                  icon: const Icon(
                    Icons.cancel,
                    color: Colors.white,
                  ),
                  onPressed: onPressed,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(60);
}
