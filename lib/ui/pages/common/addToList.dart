import 'package:flutter/material.dart';
import 'package:wish_pe/model/itemModel.dart';
import 'package:wish_pe/model/listModel.dart';
import 'package:wish_pe/ui/pages/common/listWidget.dart';
import 'package:wish_pe/ui/widgets/newListDialogWidget.dart';
import 'package:wish_pe/state/listState.dart';
import 'package:provider/provider.dart';

class AddToList extends StatelessWidget {
  final ItemModel item;
  const AddToList({
    Key? key,
    required this.item,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    TextEditingController con = TextEditingController();
    final state = Provider.of<ListState>(context);
    final allLists = state.myLists!;
    final defaultList = state.myDefaultList!;
    allLists.remove(defaultList);
    final isPresentInDefaultList = itemPresentInList(defaultList, item.key!);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
          title: Text(
            "Add to list",
            style: Theme.of(context)
                .textTheme
                .bodyMedium!
                .copyWith(fontSize: 20, color: Colors.white),
          ),
          backgroundColor: Colors.black,
          iconTheme: IconThemeData(color: Colors.white)),
      body: ListView(
        children: [
          const SizedBox(
            height: 20,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              MaterialButton(
                color: Colors.lightGreenAccent[700],
                minWidth: MediaQuery.of(context).size.width * .4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30), // Circular border
                ),
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return DialogContentWidget(controller: con, item: item);
                      });
                },
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    "New List",
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Show defaultList first
                Opacity(
                  opacity: isPresentInDefaultList ? 0.5 : 1.0,
                  child: ListWidget(
                    list: defaultList,
                    isSelected: isPresentInDefaultList,
                    onTapAction: () {
                      if (!isPresentInDefaultList) {
                        state.addToList(defaultList, item.key!);
                      }
                      Navigator.pop(context);
                      if (Navigator.canPop(context)) Navigator.pop(context);
                    },
                  ),
                ),
                const SizedBox(height: 10),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: allLists.length,
                  itemBuilder: (context, i) {
                    return ListWidget(
                      list: allLists[i],
                      isSelected: itemPresentInList(allLists[i], item.key!),
                      onTapAction: () {
                        state.addToList(allLists[i], item.key!);
                        Navigator.pop(context);
                        if (Navigator.canPop(context)) Navigator.pop(context);
                      },
                    );
                  },
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  bool itemPresentInList(ListModel list, String itemKey) {
    return list.itemKeyList!.any((element) => element == itemKey);
  }
}
