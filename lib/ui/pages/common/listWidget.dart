import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wish_pe/model/listModel.dart';
import 'package:wish_pe/ui/widgets/dynamicImageWidget.dart';

// ignore: must_be_immutable
class ListWidget extends StatelessWidget {
  final ListModel list;
  Function? onDismissedAction;
  Function? onTapAction;
  String? subTitleText;
  bool? isSelected;
  ListWidget(
      {Key? key,
      required this.list,
      this.onDismissedAction,
      this.onTapAction,
      this.subTitleText,
      this.isSelected = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return buildWidget();
  }

  Widget buildWidget() {
    Widget content = InkWell(
      onTap: () {
        if (onTapAction != null) onTapAction!();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: DynamicListImage(list: list, width: 50, height: 50),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    list.name!,
                    style: const TextStyle(color: Colors.white, fontSize: 16.0),
                  ),
                  const SizedBox(
                    height: 4,
                  ),
                  Text(
                    subTitleText ??
                        (list.itemKeyList!.length.toString() +
                            " Items" +
                            " • " +
                            list.privacyLevel.toString().split('.').last),
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
            Spacer(),
            if (isSelected != null && isSelected!)
              Icon(
                Icons.check,
                color: Colors.white,
              ),
          ],
        ),
      ),
    );

    if (onDismissedAction != null) {
      content = Dismissible(
        key: UniqueKey(),
        onDismissed: (direction) {
          if (onDismissedAction != null) onDismissedAction!();
        },
        direction: DismissDirection.endToStart,
        background: Container(
          alignment: Alignment.centerRight,
          child: const Padding(
            padding: EdgeInsets.all(20.0),
            child: Icon(
              CupertinoIcons.delete,
              color: Colors.white,
            ),
          ),
        ),
        child: content,
      );
    }

    return content;
  }
}
