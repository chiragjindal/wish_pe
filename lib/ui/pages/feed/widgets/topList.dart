import 'package:flutter/cupertino.dart';
import 'package:wish_pe/model/listModel.dart';
import 'package:wish_pe/ui/pages/list/listPage.dart';
import 'package:wish_pe/ui/widgets/dynamicImageWidget.dart';
import 'package:wish_pe/ui/theme/theme.dart';
import 'package:wish_pe/widgets/newWidget/emptyList.dart';

class TopList extends StatelessWidget {
  final List<ListModel> lists;
  const TopList({Key? key, required this.lists}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (lists.isEmpty) {
      return Center(
        child: NotifyText(
          title: "No lists found",
        ),
      );
    }
    return SizedBox(
      height: 190,
      child: ListView.builder(
          shrinkWrap: true,
          itemCount: lists.length,
          physics: const BouncingScrollPhysics(),
          scrollDirection: Axis.horizontal,
          itemBuilder: (context, int index) {
            final topMix = lists[index];

            return GestureDetector(
              onTap: () => Navigator.push(
                  context,
                  CupertinoPageRoute(
                      builder: (context) => ListPage(list: topMix))),
              child: Container(
                decoration: BoxDecoration(
                    color: ColorConstants.cardBackGroundColor,
                    borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.only(
                    right: 15, left: 15, top: 15, bottom: 0),
                margin: const EdgeInsets.all(4),
                width: 160,
                height: 195,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                        height: 113,
                        width: 125,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            DynamicListImage(
                              list: topMix,
                              width: 125, // Width of the container
                              height: 113, // Height of the container
                            ),
                            /*
                            Container(
                              width: 7,
                              height: 22,
                              //decoration:
                              //BoxDecoration(color: hexToColor(color)),
                            ),
                            const SizedBox(
                              height: 12,
                            ),
                            Container(
                              height: 8,
                              decoration: BoxDecoration(
                                  //color: hexToColor(color),
                                  borderRadius: const BorderRadius.only(
                                bottomLeft: Radius.circular(15),
                                bottomRight: Radius.circular(15),
                              )),
                            ),
                            */
                          ],
                        )),
                    const SizedBox(
                      height: 8,
                    ),
                    Text(topMix.name!,
                        style: TextStyle(
                          color: ColorConstants.starterWhite,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        )),
                    const SizedBox(
                      height: 2,
                    ),
                    Text(topMix.itemKeyList!.length.toString() + ' Items',
                        style: TextStyle(
                          color: ColorConstants.starterWhite,
                          fontSize: 11,
                          fontWeight: FontWeight.w400,
                        ))
                  ],
                ),
              ),
            );
          }),
    );
  }
}
