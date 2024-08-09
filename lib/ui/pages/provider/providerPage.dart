import 'package:flutter/material.dart';
import 'package:wish_pe/model/itemModel.dart';
import 'package:wish_pe/model/user.dart';
import 'package:wish_pe/state/listState.dart';
import 'package:wish_pe/ui/pages/common/item.dart';
import 'package:wish_pe/ui/widgets/sliverAppbar.dart';
import 'package:wish_pe/state/itemState.dart';
import 'package:wish_pe/state/profile_state.dart';
import 'package:wish_pe/state/searchState.dart';
import 'package:provider/provider.dart';

// ignore: must_be_immutable
class ProviderPage extends StatelessWidget {
  String? categoryKey;
  final String providerKey;
  ProviderPage({Key? key, this.categoryKey, required this.providerKey})
      : super(key: key);

  static MaterialPageRoute getRoute(
      {required String providerKey, String? categoryKey}) {
    return MaterialPageRoute(
      builder: (_) => Provider(
        create: (_) => ProfileState(providerKey),
        child: ChangeNotifierProvider(
          create: (BuildContext context) => ProfileState(providerKey),
          builder: (_, child) => ProviderPage(
            providerKey: providerKey,
            categoryKey: categoryKey,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final searchState = Provider.of<SearchState>(context);
    var authState = Provider.of<ProfileState>(context);
    final state = Provider.of<ItemState>(context);
    final listState = Provider.of<ListState>(context);
    UserModel provider = searchState.getProviderFromKey(providerKey);
    final list =
        state.getItemsByProvider(provider.key!, categoryKey, listState) ?? [];

    return Scaffold(
      backgroundColor: Colors.black,
      extendBody: true,
      body: authState.isbusy
          ? const SizedBox.shrink()
          : CustomScrollView(
              slivers: [
                SliverPersistentHeader(
                  delegate: MyDelegate(
                      provider: provider,
                      followersCount:
                          authState.profileUserModel.getFollower.toString()),
                  pinned: true,
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Text(
                      "Popular",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (_, i) {
                      return Item(
                        item: list[i],
                        subTitleText: getSubTitle(list[i]),
                      );
                    },
                    childCount: list.length,
                  ),
                ),
                const SliverToBoxAdapter(
                  child: SizedBox(height: 150),
                )
              ],
            ),
    );
  }

  String getSubTitle(ItemModel model) {
    String subTitle = '';
    if (model.price != null && model.price!.isNotEmpty) {
      subTitle += model.price!;
    }
    if (subTitle.length > 1) {
      subTitle += ' • ';
    }
    if (model.likeCount! > 0) subTitle += model.likeCount.toString() + ' likes';

    return subTitle;
  }
}
