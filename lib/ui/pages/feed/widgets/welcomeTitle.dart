import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wish_pe/ui/pages/notification/notificationPage.dart';

// ignore: must_be_immutable
class WelcomeTitle extends StatelessWidget {
  WelcomeTitle({
    Key? key,
    required this.title,
    this.showIcon = false,
  }) : super(key: key);

  final String title;
  bool showIcon = false;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w700,
                fontStyle: FontStyle.normal)),
        Visibility(
          visible: showIcon,
          child: SizedBox(
            width: 30,
            height: 30,
            child: IconButton(
                icon: Icon(
                  Icons.notifications,
                  color: Colors.white,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    CupertinoPageRoute(
                        builder: (context) => NotificationPage()),
                  );
                }),
          ),
        ),
      ],
    );
  }
}
