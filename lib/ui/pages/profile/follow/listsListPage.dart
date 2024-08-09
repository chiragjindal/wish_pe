import 'package:flutter/cupertino.dart';
import 'package:wish_pe/model/listModel.dart';
import 'package:wish_pe/state/listState.dart';
import 'package:wish_pe/ui/pages/common/listWidget.dart';
import 'package:wish_pe/ui/pages/list/listPage.dart';
import 'package:wish_pe/ui/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:wish_pe/widgets/customAppBar.dart';
import 'package:wish_pe/widgets/newWidget/customLoader.dart';
import 'package:wish_pe/widgets/newWidget/emptyList.dart';
import 'package:provider/provider.dart';

class ListsListPage extends StatelessWidget {
  const ListsListPage({Key? key, required this.listList}) : super(key: key);
  final listList;

  @override
  Widget build(BuildContext context) {
    if (context.watch<ListState>().isbusy) {
      return SizedBox(
        height: context.height,
        child: const CustomScreenLoader(
          height: double.infinity,
          width: double.infinity,
          backgroundColor: Colors.black,
        ),
      );
    }
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: CustomAppBar(
        isBackButton: true,
        title: Text(
          'Lists',
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: Consumer<ListState>(
        builder: (context, state, child) {
          return listList != null && listList!.isNotEmpty
              ? ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, i) {
                    final ListModel list = listList[i];
                    return ListWidget(
                        list: list,
                        subTitleText: list.privacyLevel ==
                                ListPrivacyLevel.Private
                            ? list.privacyLevel.toString().split('.').last
                            : list.likeList!.length.toString() + " followers",
                        onTapAction: () {
                          Navigator.push(
                              context,
                              CupertinoPageRoute(
                                  builder: (context) =>
                                      ListPage(list: listList[i])));
                        });
                  },
                  itemCount: listList == null ? 0 : listList.length,
                )
              : Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(top: 0, left: 10, right: 10),
                  child: NotifyText(
                    title: 'No Lists to View',
                    subTitle: 'When present they\'ll be listed here.',
                  ),
                );
        },
      ),
    );
  }
}
