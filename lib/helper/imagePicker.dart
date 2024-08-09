import 'dart:io';

import 'package:flutter/material.dart';
import 'package:wish_pe/ui/theme/theme.dart';
import 'package:wish_pe/widgets/customWidgets.dart';
import 'package:image_picker/image_picker.dart';

openImagePicker(BuildContext context, Function(File) onImageSelected) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (BuildContext context) {
      return Container(
        padding: const EdgeInsets.only(top: 5, bottom: 0),
        height: context.height * .15,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: _imageOptions(
          context,
          onImageSelected,
        ),
      );
    },
  );
}

Widget _imageOptions(BuildContext context, Function(File) onImageSelected) {
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
      _widgetBottomSheetRow(
        context,
        AppIcon.camera,
        isEnable: true,
        text: 'Take photo',
        onPressed: () {
          getImage(context, ImageSource.camera, onImageSelected);
        },
      ),
      _widgetBottomSheetRow(
        context,
        AppIcon.image,
        isEnable: true,
        text: 'Choose photo',
        onPressed: () {
          getImage(context, ImageSource.gallery, onImageSelected);
        },
      ),
    ],
  );
}

Widget _widgetBottomSheetRow(BuildContext context, IconData icon,
    {required String text, Function? onPressed, bool isEnable = false}) {
  return Expanded(
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
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

getImage(
    BuildContext context, ImageSource source, Function(File) onImageSelected) {
  ImagePicker().pickImage(source: source, imageQuality: 50).then((
    XFile? file,
  ) {
    onImageSelected(File(file!.path));
    Navigator.pop(context);
  });
}
