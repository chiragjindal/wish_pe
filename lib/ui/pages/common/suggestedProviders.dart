import 'package:flutter/material.dart';
import 'package:wish_pe/state/authState.dart';
import 'package:wish_pe/state/suggestionProviderState.dart';
import 'package:wish_pe/state/searchState.dart';
import 'package:wish_pe/ui/widgets/userListWidget.dart';
import 'package:wish_pe/ui/theme/theme.dart';
import 'package:wish_pe/widgets/customFlatButton.dart';
import 'package:wish_pe/widgets/newWidget/customLoader.dart';
import 'package:wish_pe/widgets/newWidget/emptyList.dart';
import 'package:wish_pe/widgets/newWidget/title_text.dart';
import 'package:provider/provider.dart';

class SuggestedProviders extends StatefulWidget {
  const SuggestedProviders({Key? key, this.appbar}) : super(key: key);
  final SliverAppBar? appbar;

  @override
  State<SuggestedProviders> createState() => _SuggestedProvidersState();
}

class _SuggestedProvidersState extends State<SuggestedProviders> {
  late ValueNotifier<bool> isLoading;
  @override
  void initState() {
    isLoading = ValueNotifier<bool>(false);
    super.initState();
  }

  @override
  void dispose() {
    isLoading.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchState = context.watch<SearchState>();
    final authState = context.watch<AuthState>();
    final state = context.watch<SuggestionsState>();
    state.setProviderlist(searchState.userlist);

    final isFollowListAvailable = !searchState.isBusy &&
        searchState.userlist != null &&
        searchState.userlist!.isNotEmpty;

    return Scaffold(
      backgroundColor: Colors.black,
      bottomNavigationBar: !isFollowListAvailable
          ? null
          : BottomAppBar(
              child: Container(
                color: Colors.black,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Spacer(),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: CustomFlatButton(
                        onPressed: () async {
                          isLoading.value = true;
                          await state.followUsers();
                          isLoading.value = false;
                        },
                        label: 'Follow ${state.selectedProvidersCount}',
                        isWrapped: true,
                        borderRadius: 50,
                        labelStyle: TextStyles.onPrimaryTitleText
                            .copyWith(color: Colors.black),
                        color: ColorConstants.primaryColor,
                        isLoading: isLoading,
                      ),
                    ),
                  ],
                ),
              ),
            ),
      body: SafeArea(
        child: Container(
          child: searchState.isBusy
              ? SizedBox(
                  height: context.height,
                  child: const CustomScreenLoader(
                    height: double.infinity,
                    width: double.infinity,
                    backgroundColor: Colors.black,
                  ),
                )
              : CustomScrollView(
                  slivers: [
                    SliverAppBar(
                      title:
                          Image.asset('assets/images/icon-480.png', height: 40),
                      backgroundColor: Colors.black,
                      centerTitle: true,
                      pinned: true,
                      primary: true,
                      elevation: 2,
                      expandedHeight:
                          kToolbarHeight + (isFollowListAvailable ? 180 : 100),
                      flexibleSpace: FlexibleSpaceBar(
                        stretchModes: const <StretchMode>[
                          StretchMode.zoomBackground,
                          StretchMode.blurBackground
                        ],
                        background: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: kToolbarHeight),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  TitleText(
                                    'Follow providers of your choice.',
                                    color: Colors.white,
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'This helps us recommend Lists and Items on your timeline.',
                                    style: TextStyles.textStyle14,
                                  ),
                                ],
                              ),
                            ),
                            if (isFollowListAvailable) ...[
                              Divider(),
                              Container(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    TitleText(
                                      'You may be Interested In',
                                      color: Colors.white,
                                    ),
                                    IconButton(
                                      onPressed: () {
                                        state.toggleAllSelections();
                                      },
                                      icon: state.selectedProvidersCount ==
                                              state.providerlist!.length
                                          ? Icon(
                                              Icons.check_circle,
                                              color:
                                                  ColorConstants.primaryColor,
                                            )
                                          : Icon(
                                              Icons.add_circle_outline_outlined,
                                              color: Colors.grey,
                                            ),
                                    ),
                                  ],
                                ),
                              ),
                              Divider(),
                            ],
                          ],
                        ),
                      ),
                    ),
                    !isFollowListAvailable
                        ? SliverFillRemaining(
                            child: Column(
                              children: [
                                SizedBox(height: 100),
                                NotifyText(
                                    subTitle:
                                        'No provider available to follow'),
                                TextButton(
                                  onPressed: () {
                                    state.displaySuggestions = false;
                                  },
                                  child: Text('Skip'),
                                ),
                              ],
                            ),
                          )
                        : SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final user = state.providerlist != null
                                    ? state.providerlist![index]
                                    : null;

                                if (user == null) {
                                  return SizedBox();
                                }
                                return UserTile(
                                  user: user,
                                  currentUser: authState.userModel!,
                                  onTrailingPressed: () {
                                    state.toggleUserSelection(user);
                                  },
                                  trailing: IconButton(
                                    onPressed: null,
                                    icon: state.isSelected(user)
                                        ? Icon(
                                            Icons.check_circle,
                                            color: ColorConstants.primaryColor,
                                          )
                                        : Icon(
                                            Icons.add_circle_outline_outlined,
                                            color: Colors.grey,
                                          ),
                                  ),
                                );
                              },
                              childCount: state.providerlist?.length ?? 0,
                            ),
                          )
                  ],
                ),
        ),
      ),
    );
  }
}
