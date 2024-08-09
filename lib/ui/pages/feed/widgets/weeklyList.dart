import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wish_pe/model/listModel.dart';
import 'package:wish_pe/ui/pages/list/listPage.dart';
import 'package:wish_pe/ui/widgets/dynamicImageWidget.dart';
import 'package:wish_pe/ui/theme/theme.dart';
import 'package:wish_pe/widgets/newWidget/emptyList.dart';

class WeeklyList extends StatelessWidget {
  final List<ListModel> lists;
  const WeeklyList({Key? key, required this.lists}) : super(key: key);

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
      height: 160,
      child: ListView.builder(
          shrinkWrap: true,
          itemCount: lists.length,
          physics: const BouncingScrollPhysics(),
          scrollDirection: Axis.horizontal,
          itemBuilder: (context, int index) {
            final slid = lists[index];
            return InkWell(
                onTap: () {
                  Navigator.push(
                      context,
                      CupertinoPageRoute(
                          builder: (context) => ListPage(list: slid)));
                },
                child: Column(
                  children: [
                    Container(
                        height: 135,
                        width: 150,
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        padding: const EdgeInsets.only(
                            right: 5, left: 5, top: 5, bottom: 5),
                        child: Align(
                            alignment: Alignment.center,
                            child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  DynamicListImage(
                                    list: slid,
                                    width: 140, // Width of the container
                                    height: 110, // Height of the container
                                  )
                                ]))),
                    const SizedBox(
                      height: 8,
                    ),
                    Text(slid.name!,
                        style: TextStyle(
                          color: ColorConstants.starterWhite,
                          fontSize: 11,
                          fontWeight: FontWeight.w400,
                        ))
                  ],
                ));
          }),
    );
  }
}
