import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wish_pe/model/listModel.dart';
import 'package:wish_pe/state/itemState.dart';
import 'package:wish_pe/state/listState.dart';
import 'package:wish_pe/state/searchState.dart';
import 'package:wish_pe/ui/pages/common/item.dart';
import 'package:wish_pe/ui/pages/search/searchHelper.dart';
import 'package:provider/provider.dart';

class AddItemsPage extends StatefulWidget {
  final ListModel list;
  const AddItemsPage({
    Key? key,
    required this.list,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _AddItemsPageState();
}

class _AddItemsPageState extends State<AddItemsPage> {
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

    // exclude items already in list
    final searchItems = feedState
        .getSearchItems(listState)!
        .where((element) => !widget.list.itemKeyList!.contains(element.key))
        .toList();

    state.setSearchItemList(searchItems, null, onlyItems: true);
    final searchList = state.searchFilterlist!
        .where((element) => !widget.list.itemKeyList!.contains(element.key))
        .toList();
    final suggestionList = state.searchlist!.take(50).toList();

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
            return ListView.builder(
              itemCount: _searchController.text.isEmpty
                  ? suggestionList.length
                  : searchList.length,
              itemBuilder: (context, i) {
                final info = _searchController.text.isEmpty
                    ? suggestionList[i]
                    : searchList[i];
                return Item(
                  item: feedState.getItem(info.key!),
                  subTitleText: getSearchItemSubtitle(context, info),
                  trailing: IconButton(
                    onPressed: () {
                      listState.addToList(widget.list, info.key!);
                    },
                    icon: const Icon(
                      CupertinoIcons.add_circled,
                      color: Colors.white,
                    ),
                  ),
                );
              },
            );
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
                    hintText: "Search Items",
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
