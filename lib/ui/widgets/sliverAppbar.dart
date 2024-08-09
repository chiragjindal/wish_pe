import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:wish_pe/model/user.dart';
import 'package:wish_pe/state/profile_state.dart';
import 'package:wish_pe/ui/pages/profile/profileHelper.dart';
import 'package:wish_pe/widgets/avatar_image.dart';
import 'package:provider/provider.dart';

double _appTopBarHeight = 60;

class MyDelegate extends SliverPersistentHeaderDelegate {
  final UserModel provider;
  final String followersCount;
  MyDelegate({required this.provider, this.followersCount = '0'});
  @override
  Widget build(context, double shrinkOffset, bool overlapsContent) {
    var shrinkPercentage =
        min(1, shrinkOffset / (maxExtent - minExtent)).toDouble();

    var authState = Provider.of<ProfileState>(context);
    return Stack(
      clipBehavior: Clip.hardEdge,
      fit: StackFit.expand,
      children: [
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Container(
            height: _appTopBarHeight,
            color: Colors.transparent,
          ),
        ),
        Column(
          children: [
            Flexible(
              flex: 1,
              child: Stack(
                children: [
                  ClipRRect(
                    child: Container(
                      foregroundDecoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          tileMode: TileMode.mirror,
                          colors: [
                            Colors.transparent,
                            Colors.transparent,
                          ],
                        ),
                      ),
                      height: _appTopBarHeight + 35,
                      child: Stack(
                        children: [
                          ImageOrAvatar(
                              imagePath: 'assets/images/' +
                                  provider.displayName!.toLowerCase() +
                                  '.png',
                              width: MediaQuery.of(context).size.width,
                              height: 40,
                              name: provider.displayName!),
                          BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
                            child: Container(
                              height: 60,
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  Opacity(
                    opacity: 1 - shrinkPercentage,
                    child: ImageOrAvatarDecoration(
                        imagePath: 'assets/images/' +
                            provider.displayName!.toLowerCase() +
                            '.png',
                        width: MediaQuery.of(context).size.width,
                        height: 400,
                        name: provider.displayName!),
                  ),
                ],
              ),
            ),
            DecoratedBox(
              decoration: const BoxDecoration(boxShadow: [
                BoxShadow(
                  offset: Offset(0, -23),
                  spreadRadius: 2,
                  blurRadius: 50,
                )
              ]),
              child: ClipRRect(
                child: Container(
                  foregroundDecoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      tileMode: TileMode.mirror,
                      colors: [
                        Colors.black,
                        Colors.transparent,
                      ],
                    ),
                  ),
                  height: 70,
                  child: Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ImageOrAvatar(
                            imagePath: 'assets/images/' +
                                provider.displayName!.toLowerCase() +
                                '.png',
                            width: MediaQuery.of(context).size.width,
                            height: 40,
                            name: provider.displayName!),
                      ),
                      BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
                        child: SizedBox(
                          height: 60,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12.0,
                            ),
                            child: Opacity(
                              opacity: max(1 - shrinkPercentage * 6, 0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const SizedBox(
                                    height: 12,
                                  ),
                                  Row(
                                    children: [
                                      InkWell(
                                        onTap: () => authState.followUser(
                                            removeFollower:
                                                isFollower(context)),
                                        child: Container(
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                              border: Border.all(
                                                  width: .5,
                                                  color: Colors.white)),
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(
                                              isFollower(context)
                                                  ? 'Following'
                                                  : 'Follow',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyText1!
                                                  .copyWith(
                                                    color: Colors.white,
                                                  ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      Text(
                                        followersCount + ' Followers',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyText1!
                                            .copyWith(
                                              color: Colors.white,
                                            ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
        Stack(
          clipBehavior: Clip.hardEdge,
          fit: StackFit.expand,
          children: [
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 35,
                  ),
                  SizedBox(
                    height: _appTopBarHeight,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                          ),
                        ),
                        Flexible(
                          child: Opacity(
                            opacity: shrinkPercentage,
                            child: Text(
                              provider.displayName!,
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineMedium!
                                  .copyWith(
                                    fontSize: 16,
                                    color: Colors.white,
                                  ),
                            ),
                          ),
                        ),
                        Opacity(
                          opacity: max(1 - shrinkPercentage * 6, 0),
                          child: IconButton(
                            onPressed: () {},
                            icon: const Icon(
                              Icons.more_vert,
                              color: Colors.transparent,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
                bottom: 70,
                child: Opacity(
                  opacity: max(1 - shrinkPercentage * 6, 0),
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Text(provider.displayName!,
                          textAlign: TextAlign.left,
                          style: Theme.of(context)
                              .textTheme
                              .headline4
                              ?.copyWith(fontSize: 48, color: Colors.white)),
                    ),
                  ),
                )),
          ],
        ),
      ],
    );
  }

  @override
  double get maxExtent => 400;

  @override
  double get minExtent => 110;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) => true;
}
