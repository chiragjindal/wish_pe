import 'package:flutter/material.dart';
import 'package:wish_pe/model/itemModel.dart';
import 'package:wish_pe/model/user.dart';
import 'package:wish_pe/state/searchState.dart';
import 'package:wish_pe/ui/pages/feed/widgets/horizontalLists.dart';
import 'package:wish_pe/ui/pages/feed/widgets/welcomeTitle.dart';
import 'package:wish_pe/ui/pages/followingFeed/followingItem.dart';
import 'package:wish_pe/ui/pages/profile/follow/followingListPage.dart';
import 'package:wish_pe/ui/widgets/itemBottomSheet.dart';
import 'package:wish_pe/state/itemState.dart';
import 'package:wish_pe/state/listState.dart';
import 'package:wish_pe/ui/theme/theme.dart';
import 'package:wish_pe/widgets/customWidgets.dart';
import 'package:wish_pe/widgets/newWidget/customLoader.dart';
import 'package:wish_pe/widgets/newWidget/emptyList.dart';
import 'package:provider/provider.dart';

class FollowingFeedPage extends StatelessWidget {
  const FollowingFeedPage(
      {Key? key, required this.scaffoldKey, this.refreshIndicatorKey})
      : super(key: key);

  final GlobalKey<ScaffoldState> scaffoldKey;

  final GlobalKey<RefreshIndicatorState>? refreshIndicatorKey;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SizedBox(
          height: context.height,
          width: context.width,
          child: RefreshIndicator(
            key: refreshIndicatorKey,
            onRefresh: () async {
              var itemState = Provider.of<ItemState>(context, listen: false);
              var listState = Provider.of<ListState>(context, listen: false);
              itemState.getDataFromDatabase();
              listState.getDataFromDatabase();
              return Future.value(true);
            },
            child: _FollowingFeedPageBody(
              refreshIndicatorKey: refreshIndicatorKey,
              scaffoldKey: scaffoldKey,
            ),
          ),
        ),
      ),
    );
  }
}

class _FollowingFeedPageBody extends StatelessWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;

  final GlobalKey<RefreshIndicatorState>? refreshIndicatorKey;

  const _FollowingFeedPageBody(
      {Key? key, required this.scaffoldKey, this.refreshIndicatorKey})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer2<ItemState, ListState>(
      builder: (context, state, listState, child) {
        final List<ItemModel>? list = state.getFollowingItems(listState);
        return CustomScrollView(
          slivers: <Widget>[
            SliverPadding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 0.0, vertical: 3.0),
              sliver: SliverAppBar(
                floating: true,
                elevation: 0,
                title: WelcomeTitle(
                  title: 'Following',
                ),
                backgroundColor: Colors.black,
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                child: Row(
                  children: [
                    Expanded(
                      child: HorizontalCircleList(
                        isFollowing: true,
                        size: 30,
                        isText: false,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 0),
                      child: Container(
                        width: 20,
                        child: InkWell(
                          onTap: () {
                            final state = Provider.of<SearchState>(context,
                                listen: false);
                            Navigator.push(
                              context,
                              FollowingListPage.getRoute(
                                profile: state.currentUser!,
                                userList: state.followingProviderList!
                                    .where((element) =>
                                        element.userType == UserType.provider)
                                    .map((e) => e.key!)
                                    .toList(),
                              ),
                            );
                          },
                          child: customText(
                            'All',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Divider(
                color: Colors.grey,
                thickness: 1,
              ),
            ),
            state.isBusy && list == null
                ? SliverToBoxAdapter(
                    child: SizedBox(
                      height: context.height - 135,
                      child: CustomScreenLoader(
                        height: double.infinity,
                        width: double.infinity,
                        backgroundColor: Colors.black,
                      ),
                    ),
                  )
                : !state.isBusy && list == null || list!.isEmpty
                    ? const SliverToBoxAdapter(
                        child: EmptyList(
                          'No Item added yet',
                          subTitle:
                              'When new Item added, they\'ll show up here \n or add new Items',
                        ),
                      )
                    : SliverList(
                        delegate: SliverChildListDelegate(
                          list.reversed.map(
                            (model) {
                              return Container(
                                color: Colors.black,
                                child: FollowingItem(
                                  model: model,
                                  trailing: ItemBottomSheet().itemOptionIcon(
                                      context,
                                      model: model,
                                      scaffoldKey: scaffoldKey),
                                  scaffoldKey: scaffoldKey,
                                ),
                              );
                            },
                          ).toList(),
                        ),
                      )
          ],
        );
      },
    );
  }
}
