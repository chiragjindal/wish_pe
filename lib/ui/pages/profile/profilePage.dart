import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wish_pe/model/listModel.dart';
import 'package:wish_pe/ui/pages/feed/widgets/listBox.dart';
import 'package:wish_pe/ui/pages/profile/EditProfilePage.dart';
import 'package:wish_pe/ui/pages/profile/follow/followerListPage.dart';
import 'package:wish_pe/ui/pages/profile/follow/followingListPage.dart';
import 'package:wish_pe/ui/pages/profile/follow/listsListPage.dart';
import 'package:wish_pe/ui/pages/profile/profileHelper.dart';
import 'package:wish_pe/ui/widgets/bottomSheetWidget.dart';
import 'package:wish_pe/state/listState.dart';
import 'package:wish_pe/state/profile_state.dart';
import 'package:wish_pe/ui/theme/theme.dart';
import 'package:wish_pe/widgets/customWidgets.dart';
import 'package:wish_pe/widgets/newWidget/rippleButton.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatelessWidget {
  ProfilePage({Key? key, required this.profileId}) : super(key: key);

  final String profileId;
  static MaterialPageRoute getRoute({required String profileId}) {
    return MaterialPageRoute(
      builder: (_) => Provider(
        create: (_) => ProfileState(profileId),
        child: ChangeNotifierProvider(
          create: (BuildContext context) => ProfileState(profileId),
          builder: (_, child) => ProfilePage(
            profileId: profileId,
          ),
        ),
      ),
    );
  }

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  /// This method called when user pressed back button
  /// When profile page is about to close
  /// Maintain minimum user's profile in profile page list
  Future<bool> _onWillPop() async {
    return true;
  }

  Widget _emptyBox() {
    return const SliverToBoxAdapter(child: SizedBox.shrink());
  }

  @override
  build(BuildContext context) {
    var state = Provider.of<ListState>(context);
    var authState = Provider.of<ProfileState>(context);
    List<ListModel> profileLists = !authState.isbusy
        ? state.getProfileLists(authState.profileUserModel) ?? []
        : [];
    bool isMyProfile = authState.isMyProfile;

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
          key: scaffoldKey,
          backgroundColor: Colors.black,
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                expandedHeight: 150,
                backgroundColor: Colors.black,
                iconTheme: IconThemeData(color: Colors.white),
                flexibleSpace: FlexibleSpaceBar(
                  centerTitle: true,
                  collapseMode: CollapseMode.pin,
                  background: authState.isbusy
                      ? const SizedBox.shrink()
                      : ClipRRect(
                          child: Stack(
                            children: [
                              CachedNetworkImage(
                                imageUrl:
                                    'https://images.unsplash.com/photo-1578070181910-f1e514afdd08?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=933&q=80',
                                height: 150,
                                memCacheHeight: (150 *
                                        MediaQuery.of(context).devicePixelRatio)
                                    .round(),
                                memCacheWidth: (MediaQuery.of(context)
                                            .size
                                            .width *
                                        MediaQuery.of(context).devicePixelRatio)
                                    .round(),
                                width: MediaQuery.of(context).size.width,
                                fit: BoxFit.cover,
                              ),
                              BackdropFilter(
                                filter:
                                    ImageFilter.blur(sigmaX: 50, sigmaY: 50),
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.bottomCenter,
                                      end: Alignment.center,
                                      colors: [
                                        Colors.black,
                                        Colors.black.withOpacity(0.5),
                                      ],
                                    ),
                                  ),
                                  height: 200,
                                  width: MediaQuery.of(context).size.width,
                                ),
                              )
                            ],
                          ),
                        ),
                  title: authState.isbusy
                      ? const SizedBox.shrink()
                      : Text(
                          authState.profileUserModel.displayName!,
                          style: const TextStyle(color: Colors.white),
                        ),
                ),
                actions: [
                  authState.isbusy
                      ? const SizedBox.shrink()
                      : IconButton(
                          icon: Icon(
                            Icons.more_vert,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            showModalBottomSheet(
                                useRootNavigator: true,
                                isScrollControlled: true,
                                elevation: 100,
                                backgroundColor: Colors.black38,
                                context: context,
                                builder: (context) {
                                  return BottomSheetWidget(
                                      user: authState.profileUserModel);
                                });
                          },
                        ),
                ],
              ),
              authState.isbusy
                  ? _emptyBox()
                  : SliverToBoxAdapter(
                      child: Center(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Align(
                              alignment: Alignment.center,
                              child: RippleButton(
                                splashColor: ColorConstants.primaryColor,
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(60)),
                                onPressed: () {
                                  if (isMyProfile) {
                                    Navigator.push(
                                        context, EditProfilePage.getRoute());
                                  } else {
                                    authState.followUser(
                                        removeFollower: isFollower(context));
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.transparent,
                                    border: Border.all(
                                        color: isMyProfile
                                            ? Colors.grey
                                            : ColorConstants.primaryColor,
                                        width: 1),
                                    borderRadius: BorderRadius.circular(20),
                                  ),

                                  /// If [isMyProfile] is true then Edit profile button will display
                                  // Otherwise Follow/Following button will be display
                                  child: Text(
                                    isMyProfile
                                        ? 'Edit profile'
                                        : isFollower(context)
                                            ? 'Following'
                                            : 'Follow',
                                    style: TextStyle(
                                      color: WishPeColor.white,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            ////
                            /*
                            isMyProfile
                                ? Align(
                                    alignment: Alignment.center,
                                    child: RippleButton(
                                      splashColor: ColorConstants.primaryColor,
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(60)),
                                      onPressed: () {
                                        Navigator.push(
                                            context,
                                            CupertinoPageRoute(
                                                builder: (context) =>
                                                    AddSnapshot()));
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 5,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.transparent,
                                          border: Border.all(
                                              color: Colors.grey, width: 1),
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        child: Text(
                                          'Debug',
                                          style: TextStyle(
                                            color: WishPeColor.white,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                : const SizedBox.shrink(),
                            //////
                            */
                            Align(
                              alignment: Alignment.center,
                              child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    _textButton(
                                        context,
                                        profileLists.length.toString(),
                                        'LISTS', () {
                                      Navigator.push(
                                          context,
                                          CupertinoPageRoute(
                                              builder: (context) =>
                                                  ListsListPage(
                                                    listList: profileLists,
                                                  )));
                                    }),
                                    _textButton(
                                        context,
                                        authState.profileUserModel.getFollower
                                            .toString(),
                                        'FOLLOWERS', () {
                                      var state = context.read<ProfileState>();
                                      Navigator.push(
                                        context,
                                        FollowerListPage.getRoute(
                                          profile: state.profileUserModel,
                                          userList: state
                                              .profileUserModel.followersList!
                                              .where((element) =>
                                                  element != state.userId)
                                              .toList(),
                                        ),
                                      );
                                    }),
                                    _textButton(
                                        context,
                                        authState.profileUserModel.getFollowing,
                                        'FOLLOWING', () {
                                      var state = context.read<ProfileState>();
                                      Navigator.push(
                                        context,
                                        FollowingListPage.getRoute(
                                          profile: state.profileUserModel,
                                          userList: state
                                              .profileUserModel.followingList!
                                              .where((element) =>
                                                  element != state.userId)
                                              .toList(),
                                        ),
                                      );
                                    }),
                                  ]),
                            ),
                          ],
                        ),
                      ),
                    ),
              const SliverToBoxAdapter(
                child: SizedBox(height: 30),
              ),
              authState.isbusy
                  ? _emptyBox()
                  : SliverToBoxAdapter(
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            "Lists",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
              authState.isbusy
                  ? _emptyBox()
                  : SliverToBoxAdapter(
                      child: ListBox(lists: profileLists.take(4).toList())),
              authState.isbusy || profileLists.length <= 4
                  ? _emptyBox()
                  : SliverToBoxAdapter(
                      child: Center(
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                                context,
                                CupertinoPageRoute(
                                    builder: (context) => ListsListPage(
                                          listList: profileLists,
                                        )));
                          },
                          child: customText(
                            'See All',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.blueGrey,
                            ),
                          ),
                        ),
                      ),
                    ),
              const SliverToBoxAdapter(
                child: SizedBox(height: 150),
              ),
            ],
          )),
    );
  }
}

Widget _textButton(
  BuildContext context,
  String count,
  String text,
  Function onPressed,
) {
  return Expanded(
    child: InkWell(
      onTap: () {
        onPressed();
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          customText(
            '$count ',
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white,
            ),
          ),
          customText(
            text,
            style: const TextStyle(color: AppColor.darkGrey, fontSize: 12),
          ),
        ],
      ),
    ),
  );
}
