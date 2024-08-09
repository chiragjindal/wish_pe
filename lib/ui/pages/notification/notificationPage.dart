import 'package:flutter/material.dart';
import 'package:wish_pe/helper/enum.dart';
import 'package:wish_pe/model/notificationModel.dart';
import 'package:wish_pe/state/authState.dart';
import 'package:wish_pe/state/notificationState.dart';
import 'package:wish_pe/ui/pages/notification/widget/follow_notification_tile.dart';
import 'package:wish_pe/ui/pages/notification/widget/post_like_tile.dart';
import 'package:wish_pe/widgets/customAppBar.dart';
import 'package:wish_pe/widgets/newWidget/emptyList.dart';
import 'package:provider/provider.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({
    Key? key,
  }) : super(key: key);

  @override
  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      var state = Provider.of<NotificationState>(context, listen: false);
      var authState = Provider.of<AuthState>(context, listen: false);
      state.getDataFromDatabase(authState.userId);
    });
  }

  void onSettingIconPressed() {
    //TODO:
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: CustomAppBar(
        scaffoldKey: _scaffoldKey,
        isBackButton: true,
        title: Text(
          'Notifications',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: 20,
          ),
        ),
        //icon: AppIcon.settings,
        //onActionPressed: onSettingIconPressed,
      ),
      body: const NotificationPageBody(),
    );
  }
}

class NotificationPageBody extends StatelessWidget {
  const NotificationPageBody({Key? key}) : super(key: key);

  Widget _notificationRow(BuildContext context, NotificationModel model) {
    var state = Provider.of<NotificationState>(context);
    if (model.type == NotificationType.Follow.toString()) {
      return FollowNotificationTile(
        model: model,
      );
    }
    return FutureBuilder(
      future: model.type == NotificationType.LikeItem.toString()
          ? state.getItem(model.key!)
          : state.getList(model.key!),
      builder: (BuildContext context, AsyncSnapshot<Object?> snapshot) {
        if (snapshot.hasData) {
          return PostLikeTile(model: snapshot.data!);
        } else if (snapshot.connectionState == ConnectionState.waiting ||
            snapshot.connectionState == ConnectionState.active) {
          return const SizedBox(
            height: 4,
            child: LinearProgressIndicator(),
          );
        } else {
          /// remove notification from firebase db if item in not available or deleted.
          var authState = Provider.of<AuthState>(context);
          state.removeNotification(authState.userId, model.key!);
          return const SizedBox();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var state = Provider.of<NotificationState>(context);
    var list = state.notificationList;
    if (state.isbusy) {
      return const SizedBox(
        height: 3,
        child: LinearProgressIndicator(),
      );
    } else if (list == null || list.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 30),
        child: EmptyList(
          'No Notification available yet',
          subTitle: 'When new notification found, they\'ll show up here.',
        ),
      );
    }
    return ListView.builder(
      addAutomaticKeepAlives: true,
      itemBuilder: (context, index) => _notificationRow(context, list[index]),
      itemCount: list.length,
    );
  }
}
