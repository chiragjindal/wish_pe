import 'package:flutter/material.dart';
import 'package:wish_pe/ui/theme/theme.dart';

class WeeklyTitle extends StatelessWidget {
  final Widget? icon;
  final String? text;
  const WeeklyTitle({Key? key, this.icon, this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        icon ??
            Icon(
              Icons.electric_bolt_outlined,
              color: ColorConstants.primaryColor,
            ),
        const SizedBox(
          width: 6,
        ),
        RichText(
          text: TextSpan(
            text: text ?? 'Weekly Trending ',
            style: TextStyle(
                color: ColorConstants.primaryColor,
                fontSize: 18,
                fontWeight: FontWeight.w600),
            // children: const [
            //   TextSpan(
            //     text: ' Trending Lists',
            //     style: TextStyle(
            //         color: Colors.white,
            //         fontSize: 18,
            //         fontWeight: FontWeight.w600),
            //   ),
            // ],
          ),
        ),
      ],
    );
  }
}
