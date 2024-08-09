import 'package:flutter/material.dart';
import 'package:wish_pe/state/itemState.dart';
import 'package:wish_pe/state/listState.dart';
import 'package:wish_pe/state/searchState.dart';
import 'package:wish_pe/ui/pages/search/searchHelper.dart';
import 'package:wish_pe/widgets/newWidget/emptyList.dart';
import 'package:provider/provider.dart';

class RecentSearch extends StatelessWidget {
  const RecentSearch({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final feedState = context.watch<ItemState>();
    final listState = context.watch<ListState>();
    final state = Provider.of<SearchState>(context);
    final searchList = state.recentSearchlist;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        if (searchList != null && searchList.length != 0)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Text(
              'Recent Searches'.toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ),
        if (searchList == null || searchList.isEmpty)
          const SizedBox(
            height: 100,
            child: Center(
              child: NotifyText(
                title: "Keep Searching...",
              ),
            ),
          )
        else
          Expanded(
            child: ListView.builder(
              shrinkWrap: true,
              itemBuilder: (context, i) {
                final info = searchList[i];
                return getSearchResultTile(
                    info, state, feedState, listState, context);
              },
              itemCount: searchList.length,
            ),
          ),
      ],
    );
  }
}
