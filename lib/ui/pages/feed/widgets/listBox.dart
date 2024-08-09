import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wish_pe/model/listModel.dart';
import 'package:wish_pe/ui/pages/list/listPage.dart';
import 'package:wish_pe/ui/widgets/dynamicImageWidget.dart';

class ListBox extends StatelessWidget {
  final List<ListModel> lists;
  const ListBox({
    Key? key,
    required this.lists,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 5),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                runSpacing: 8,
                spacing: 8,
                children: [
                  ...lists
                      .map((list) => InkWell(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  CupertinoPageRoute(
                                      builder: (context) =>
                                          ListPage(list: list)));
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white12,
                                borderRadius: BorderRadius.circular(3),
                              ),
                              width: lists.length == 1
                                  ? (MediaQuery.of(context).size.width) - 16
                                  : (MediaQuery.of(context).size.width * .5) -
                                      24,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(3),
                                    child: DynamicListImage(
                                        list: list, width: 55, height: 55),
                                  ),
                                  Flexible(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 14, vertical: 8),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            list.name!,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 14.0),
                                          ),
                                          Text(
                                            list.likeList!.length.toString() +
                                                " followers",
                                            style: const TextStyle(
                                                color: Colors.grey,
                                                fontSize: 8.0),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ))
                      .toList(),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
