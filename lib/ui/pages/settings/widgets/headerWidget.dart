import 'package:flutter/material.dart';
import 'package:wish_pe/ui/theme/theme.dart';
import 'package:wish_pe/widgets/url_text/customUrlText.dart';

class HeaderWidget extends StatelessWidget {
  final String? title;
  final bool secondHeader;
  const HeaderWidget(this.title, {Key? key, this.secondHeader = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: secondHeader
          ? const EdgeInsets.only(left: 18, right: 18, bottom: 10, top: 35)
          : const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      color: AppColor.darkGrey,
      alignment: Alignment.centerLeft,
      child: UrlText(
        text: title ?? '',
        style: const TextStyle(
            fontSize: 20, color: Colors.white, fontWeight: FontWeight.w700),
      ),
    );
  }
}
