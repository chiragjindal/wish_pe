import 'package:flutter/material.dart';
import 'package:wish_pe/ui/theme/theme.dart';
import 'package:wish_pe/widgets/newWidget/title_text.dart';

class EmptyList extends StatelessWidget {
  const EmptyList(this.title, {Key? key, required this.subTitle});

  final String? subTitle;
  final String? title;

  @override
  Widget build(BuildContext context) {
    return Container(
        height: context.height - 135,
        color: Colors.black,
        child: NotifyText(
          title: title,
          subTitle: subTitle,
        ));
  }
}

class NotifyText extends StatelessWidget {
  final String? subTitle;
  final String? title;
  const NotifyText({Key? key, this.subTitle, this.title})
      : assert(title != null || subTitle != null,
            'title and subTitle must not be null'),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        if (title != null)
          TitleText(
            title!,
            fontSize: 16,
            textAlign: TextAlign.center,
            color: AppColor.darkGrey,
          ),
        if (subTitle != null) ...[
          const SizedBox(height: 20),
          TitleText(
            subTitle!,
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColor.darkGrey,
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}
