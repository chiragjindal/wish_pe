import 'dart:async';

import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:wish_pe/helper/enum.dart';
import 'package:wish_pe/helper/utility.dart';
import 'package:wish_pe/model/push_notification_model.dart';
import 'package:wish_pe/resource/push_notification_service.dart';
import 'package:wish_pe/state/appState.dart';
import 'package:wish_pe/state/authState.dart';
import 'package:wish_pe/state/listState.dart';
import 'package:wish_pe/state/suggestionProviderState.dart';
import 'package:wish_pe/state/itemState.dart';
import 'package:wish_pe/state/notificationState.dart';
import 'package:wish_pe/state/searchState.dart';
import 'package:wish_pe/ui/pages/composeItem/AddWishPage.dart';
import 'package:wish_pe/ui/pages/feed/homeFeedPage.dart';
import 'package:wish_pe/ui/pages/followingFeed/folllowingFeedPage.dart';
import 'package:wish_pe/ui/pages/library/libraryPage.dart';
import 'package:wish_pe/ui/pages/profile/profilePage.dart';
import 'package:wish_pe/ui/pages/search/searchPage.dart';
import 'package:wish_pe/ui/widgets/bottomMenuBar/bottomMenuBar.dart';
import 'package:provider/provider.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

import '../unused/locator.dart';
import 'common/sidebar.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();
  int pageIndex = 0;
  // ignore: cancel_subscription
  late StreamSubscription<PushNotificationModel> pushNotificationSubscription;
  String? _sharedText;
  List<SharedMediaFile>? _sharedFiles;

  @override
  void initState() {
    initDynamicLinks();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      var state = Provider.of<AppState>(context, listen: false);
      state.setPageIndex = 0;
      initProfile();
      initSearch();
      initLists();
      initItems();
      initNotification();
    });

    super.initState();

    // For sharing or opening image coming from outside the app while the app is in memory
    ReceiveSharingIntent.getMediaStream().listen((List<SharedMediaFile> value) {
      setState(() {
        _sharedFiles = value;
        if (_sharedFiles != null && _sharedFiles!.isNotEmpty) {
          Future.microtask(() => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => AddWishPage(
                          sharedFiles: _sharedFiles,
                          scaffoldKey: _scaffoldKey,
                        )),
              ));
        }
      });
    }, onError: (err) {
      print("getMediaStream error: $err");
    });

    // For sharing or opening image from outside the app while the app is closed
    ReceiveSharingIntent.getInitialMedia().then((List<SharedMediaFile> value) {
      setState(() {
        _sharedFiles = value;
        if (_sharedFiles != null && _sharedFiles!.isNotEmpty) {
          Future.microtask(() => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => AddWishPage(
                          sharedFiles: _sharedFiles,
                          scaffoldKey: _scaffoldKey,
                        )),
              ));
        }
      });
    });

    // For sharing or opening URLs coming from outside the app while the app is in memory
    ReceiveSharingIntent.getTextStream().listen((value) {
      setState(() {
        _sharedText = value.toString();
        if (_sharedText != 'null' &&
            _sharedText != null &&
            _sharedText!.isNotEmpty) {
          Future.microtask(() => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => AddWishPage(
                          sharedUrl: _sharedText,
                          scaffoldKey: _scaffoldKey,
                        )),
              ));
        }
      });
    }, onError: (err) {
      print("getTextStreamAsUri error: $err");
    });

    // For sharing or opening URLs coming from outside the app while the app is closed
    ReceiveSharingIntent.getInitialText().then((value) {
      setState(() {
        _sharedText = value.toString();
        if (_sharedText != 'null' &&
            _sharedText != null &&
            _sharedText!.isNotEmpty) {
          Future.microtask(() => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => AddWishPage(
                          sharedUrl: _sharedText,
                          scaffoldKey: _scaffoldKey,
                        )),
              ));
        }
      });
    });
  }

  @override
  void dispose() {
    pushNotificationSubscription.cancel();
    super.dispose();
  }

  void initProfile() {
    var state = Provider.of<AuthState>(context, listen: false);
    state.databaseInit();
  }

  void initSearch() {
    var searchState = Provider.of<SearchState>(context, listen: false);
    searchState.databaseInit();
    searchState.getDataFromDatabase();
  }

  void initLists() {
    var state = Provider.of<ListState>(context, listen: false);
    state.databaseInit();
    state.getDataFromDatabase();
  }

  void initItems() {
    var state = Provider.of<ItemState>(context, listen: false);
    state.databaseInit();
    state.getDataFromDatabase();
  }

  void initNotification() {
    var state = Provider.of<NotificationState>(context, listen: false);
    var authState = Provider.of<AuthState>(context, listen: false);
    state.databaseInit(authState.userId);

    /// configure push notifications
    state.initFirebaseService();

    /// Subscribe the push notifications
    /// Whenever devices receive push notification, `listenPushNotification` callback will trigger.
    pushNotificationSubscription = getIt<PushNotificationService>()
        .pushNotificationResponseStream
        .listen(listenPushNotification);
  }

  /// Listen for every push notifications when app is in background
  /// Check for push notifications when app is launched by tapping on push notifications from system tray.
  /// If notification type is `NotificationType.Message` then chat screen will open
  void listenPushNotification(PushNotificationModel model) {
    final authState = Provider.of<AuthState>(context, listen: false);

    if (model.type == NotificationType.Mention.toString() &&
        model.receiverId == authState.user!.uid) {}
  }

  /// Initialize the firebase dynamic link sdk
  void initDynamicLinks() async {
    FirebaseDynamicLinks.instance.onLink.listen(
        (PendingDynamicLinkData? dynamicLink) async {
      final Uri? deepLink = dynamicLink?.link;

      if (deepLink != null) {
        redirectFromDeepLink(deepLink);
      }
    }, onError: (e) async {
      cprint(e.message, errorIn: "onLinkError");
    });

    final PendingDynamicLinkData? data =
        await FirebaseDynamicLinks.instance.getInitialLink();
    final Uri? deepLink = data?.link;

    if (deepLink != null) {
      redirectFromDeepLink(deepLink);
    }
  }

  /// Redirect user to specific screen when app is launched by tapping on deep link.
  void redirectFromDeepLink(Uri deepLink) {
    cprint("Found Url from share: ${deepLink.path}");
    var type = deepLink.path.split("/")[1];
    var id = deepLink.path.split("/")[2];
    if (type == "profilePage") {
      Navigator.push(context, ProfilePage.getRoute(profileId: id));
    }
  }

  Widget _body() {
    return SafeArea(
      child: Container(
        child: _getPage(Provider.of<AppState>(context).pageIndex),
      ),
    );
  }

  Widget _getPage(int index) {
    switch (index) {
      case 0:
        return HomeFeedPage(
          scaffoldKey: _scaffoldKey,
          refreshIndicatorKey: refreshIndicatorKey,
        );
      case 1:
        return SearchPage(scaffoldKey: _scaffoldKey);
      case 2:
        return AddWishPage(
          scaffoldKey: _scaffoldKey,
        );
      case 3:
        return FollowingFeedPage(
          scaffoldKey: _scaffoldKey,
          refreshIndicatorKey: refreshIndicatorKey,
        );
      case 4:
        return Library(
          scaffoldKey: _scaffoldKey,
        );
      default:
        return FollowingFeedPage(scaffoldKey: _scaffoldKey);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AuthState>();
    context.read<SuggestionsState>().initUser(state.userModel);

    // if (context
    //     .select<SuggestionsState, bool>((state) => state.displaySuggestions)) {
    //   return SuggestedProviders();
    // }

    return Scaffold(
      key: _scaffoldKey,
      bottomNavigationBar: BottomMenubar(),
      drawer: const SidebarMenu(),
      body: _body(),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(
        DiagnosticsProperty<StreamSubscription<PushNotificationModel>>(
            'pushNotificationSubscription', pushNotificationSubscription));
  }
}
