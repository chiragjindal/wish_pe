import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wish_pe/model/listModel.dart';
import 'package:wish_pe/ui/pages/list/listPage.dart';
import 'package:wish_pe/ui/widgets/dynamicImageWidget.dart';
import 'package:wish_pe/ui/theme/theme.dart';

class ListCard extends StatelessWidget {
  final List<ListModel>? listList;
  const ListCard({Key? key, required this.listList}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const BouncingScrollPhysics(),
      itemCount: listList!.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
      ),
      itemBuilder: (context, int index) {
        final list = listList![index];
        return InkWell(
          onTap: () {
            Navigator.push(context,
                CupertinoPageRoute(builder: (context) => ListPage(list: list)));
          },
          child: Container(
            decoration: BoxDecoration(
                color: ColorConstants.cardBackGroundColor,
                borderRadius: BorderRadius.circular(10)),
            padding:
                const EdgeInsets.only(top: 10, left: 5, right: 5, bottom: 10),
            margin: const EdgeInsets.all(4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                DynamicListImage(list: list, width: 130, height: 115),
                const SizedBox(
                  height: 4,
                ),
                Text(list.name!,
                    style: TextStyle(
                      color: ColorConstants.starterWhite,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    )),
                const SizedBox(
                  height: 4,
                ),
                Text(
                  list.itemKeyList!.length.toString() +
                      " Items" +
                      " • " +
                      list.privacyLevel.toString().split('.').last,
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
