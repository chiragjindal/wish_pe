import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wish_pe/ui/pages/composeItem/ComposeItemPage.dart';
import 'package:wish_pe/ui/widgets/newListDialogWidget.dart';
import 'package:wish_pe/ui/theme/theme.dart';
import 'package:wish_pe/widgets/customWidgets.dart';

openPicker(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (BuildContext context) {
      return Container(
        padding: const EdgeInsets.only(top: 5, bottom: 0),
        height: context.height * .23,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: _composeOptions(
          context,
        ),
      );
    },
  );
}

Widget _composeOptions(BuildContext context) {
  TextEditingController con = TextEditingController();
  return Column(
    children: <Widget>[
      Container(
        width: context.width * .1,
        height: 5,
        decoration: BoxDecoration(
          color: Colors.grey,
          borderRadius: const BorderRadius.all(
            Radius.circular(10),
          ),
        ),
      ),
      SizedBox(height: 10),
      customText(
        "Create",
        context: context,
        style: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w400,
        ),
      ),
      Divider(
        color: Colors.grey,
        thickness: 0.2,
      ),
      _widgetBottomSheetRow(
        context,
        AppIcon.moments,
        isEnable: true,
        text: 'Item',
        onPressed: () {
          Navigator.push(
            context,
            CupertinoPageRoute(
              builder: (context) => ComposeItemPage(),
            ),
          );
        },
      ),
      _widgetBottomSheetRow(
        context,
        AppIcon.lists,
        isEnable: true,
        text: 'List',
        onPressed: () {
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return DialogContentWidget(controller: con);
              });
        },
      ),
    ],
  );
}

Widget _widgetBottomSheetRow(BuildContext context, IconData icon,
    {required String text, Function? onPressed, bool isEnable = false}) {
  return Expanded(
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        children: <Widget>[
          customIcon(
            context,
            icon: icon,
            isCustomIcon: true,
            size: 25,
            paddingIcon: 8,
            iconColor:
                onPressed != null ? AppColor.darkGrey : AppColor.lightGrey,
          ),
          const SizedBox(
            width: 10,
          ),
          customText(
            text,
            context: context,
            style: TextStyle(
              color: isEnable ? Colors.white : AppColor.lightGrey,
              fontSize: 18,
              fontWeight: FontWeight.w400,
            ),
          )
        ],
      ),
    ).ripple(() {
      if (onPressed != null) {
        onPressed();
      } else {
        Navigator.pop(context);
      }
    }),
  );
}
