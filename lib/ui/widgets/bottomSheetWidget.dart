import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wish_pe/helper/fileHelper.dart';
import 'package:wish_pe/model/itemModel.dart';
import 'package:wish_pe/model/listModel.dart';
import 'package:wish_pe/model/user.dart';
import 'package:wish_pe/state/authState.dart';
import 'package:wish_pe/state/itemState.dart';
import 'package:wish_pe/state/listState.dart';
import 'package:wish_pe/state/searchState.dart';
import 'package:wish_pe/ui/pages/common/addItems.dart';
import 'package:wish_pe/ui/pages/common/addToList.dart';
import 'package:wish_pe/ui/pages/composeItem/ComposeItemPage.dart';
import 'package:wish_pe/ui/pages/list/editListPage.dart';
import 'package:wish_pe/ui/pages/profile/profilePage.dart';
import 'package:wish_pe/ui/pages/profile/qrCode/scanner.dart';
import 'package:wish_pe/ui/pages/provider/providerPage.dart';
import 'package:wish_pe/ui/theme/theme.dart';
import 'package:wish_pe/ui/widgets/dynamicImageWidget.dart';
import 'package:wish_pe/ui/widgets/likeButton.dart';
import 'package:provider/provider.dart';

class BottomSheetWidget extends StatelessWidget {
  final ItemModel? item;
  final ListModel? list;
  final UserModel? user;
  const BottomSheetWidget({Key? key, this.item, this.list, this.user})
      : super(key: key);

  Widget _itemBody(
      BuildContext context,
      double devicePexelRatio,
      ItemState state,
      SearchState searchState,
      ListState listState,
      bool isMyList,
      bool isMyItem) {
    List<Widget> listItems = [
      SizedBox(
        height: MediaQuery.of(context).size.height * .2,
      ),
      SizedBox(
        width: MediaQuery.of(context).size.width * .4,
        child: Column(
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: item!.imageUrl!.startsWith("data:")
                  ? buildBase64Image(item!.imageUrl!, 50, 50)
                  : CachedNetworkImage(
                      imageUrl: item!.imageUrl!,
                      memCacheHeight: (300 * devicePexelRatio).round(),
                      memCacheWidth: (300 * devicePexelRatio).round(),
                      maxHeightDiskCache: (300 * devicePexelRatio).round(),
                      maxWidthDiskCache: (300 * devicePexelRatio).round(),
                      fit: BoxFit.cover,
                    ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 20),
      Padding(
        padding: EdgeInsets.only(left: 10, right: 10),
        child: Text(
          item!.title!,
          textAlign: TextAlign.center,
          style: Theme.of(context)
              .textTheme
              .headlineMedium!
              .copyWith(fontSize: 20, color: Colors.white),
        ),
      ),
      const SizedBox(height: 5),
      Text(
        searchState.getItemModelSubTitle(item!),
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
              color: Colors.grey,
            ),
      ),
      const SizedBox(height: 20),
      LikeButton(item: item, isIcon: true),
      ListTile(
        onTap: () {
          Navigator.push(context,
              CupertinoPageRoute(builder: (BuildContext context) {
            return AddToList(
              item: item!,
            );
          }));
        },
        minLeadingWidth: 30,
        contentPadding: const EdgeInsets.symmetric(horizontal: 30),
        leading: const Icon(
          CupertinoIcons.add_circled,
          color: Colors.grey,
        ),
        title: Text(
          isMyList ? "Add to other List" : "Add to List",
          style: Theme.of(context)
              .textTheme
              .bodyMedium!
              .copyWith(fontSize: 20, color: Colors.white),
        ),
      ),
      item!.providerKey != null
          ? ListTile(
              onTap: () {
                Navigator.push(context,
                    ProviderPage.getRoute(providerKey: item!.providerKey!));
              },
              minLeadingWidth: 30,
              contentPadding: const EdgeInsets.symmetric(horizontal: 30),
              leading: const Icon(
                CupertinoIcons.person_2,
                color: Colors.grey,
              ),
              title: Text(
                "View Provider",
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium!
                    .copyWith(fontSize: 20, color: Colors.white),
              ),
            )
          : const SizedBox(),
      ListTile(
        onTap: () {
          Navigator.push(
              context, ProfilePage.getRoute(profileId: item!.userId));
        },
        minLeadingWidth: 30,
        contentPadding: const EdgeInsets.symmetric(horizontal: 30),
        leading: const Icon(
          AppIcon.profile,
          color: Colors.grey,
        ),
        title: Text(
          "Go to Profile",
          style: Theme.of(context)
              .textTheme
              .bodyMedium!
              .copyWith(fontSize: 20, color: Colors.white),
        ),
      ),
      ListTile(
        onTap: () async {
          Navigator.pop(context);
        },
        minLeadingWidth: 30,
        contentPadding: const EdgeInsets.symmetric(horizontal: 30),
        leading: const Icon(
          Icons.share,
          color: Colors.grey,
        ),
        title: Text(
          "Share",
          style: Theme.of(context)
              .textTheme
              .bodyMedium!
              .copyWith(fontSize: 20, color: Colors.white),
        ),
      ),
    ];

    if (isMyList) {
      if (list != listState.myDefaultList) {
        listItems.add(ListTile(
          onTap: () {
            Navigator.pop(context);
            listState.addToList(list!, item!.key!);
          },
          minLeadingWidth: 30,
          contentPadding: const EdgeInsets.symmetric(horizontal: 30),
          leading: const Icon(
            CupertinoIcons.minus_circled,
            color: Colors.grey,
          ),
          title: Text(
            "Remove from this List",
            style: Theme.of(context)
                .textTheme
                .bodyMedium!
                .copyWith(fontSize: 20, color: Colors.white),
          ),
          subtitle: Text(
            "Item stays in the Universal List",
            style: Theme.of(context)
                .textTheme
                .bodyMedium!
                .copyWith(fontSize: 10, color: Colors.grey),
          ),
        ));
      } else if (!isMyItem) {
        listItems.add(ListTile(
          onTap: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text(
                    "Remove item",
                    style: TextStyle(
                        color: Colors.black, fontWeight: FontWeight.bold),
                  ),
                  content: Text(
                      "This will permanently remove this item from all your lists. Are you sure?",
                      style: TextStyle(color: Colors.black)),
                  actions: <Widget>[
                    TextButton(
                      child: Text(
                        "Cancel",
                        style: TextStyle(color: Colors.black),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    MaterialButton(
                      color: Colors.lightGreenAccent[700],
                      minWidth: MediaQuery.of(context).size.width * .2,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(30), // Circular border
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                        Navigator.pop(context);
                        listState.removeFromAll(item!.key!);
                        Navigator.pop(context);
                      },
                      child: const Padding(
                        padding: EdgeInsets.all(4.0),
                        child: Text(
                          "Remove",
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 14,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
          },
          minLeadingWidth: 30,
          contentPadding: const EdgeInsets.symmetric(horizontal: 30),
          leading: const Icon(
            CupertinoIcons.minus_circled,
            color: Colors.grey,
          ),
          title: Text(
            "Remove Permanently",
            style: Theme.of(context)
                .textTheme
                .bodyMedium!
                .copyWith(fontSize: 20, color: Colors.white),
          ),
          subtitle: Text(
            "Item is removed from all Lists",
            style: Theme.of(context)
                .textTheme
                .bodyMedium!
                .copyWith(fontSize: 10, color: Colors.grey),
          ),
        ));
      }

      if (isMyItem) {
        listItems.addAll(
          [
            ListTile(
              onTap: () {
                Navigator.push(context,
                    CupertinoPageRoute(builder: (BuildContext context) {
                  return ComposeItemPage(
                    model: item!,
                  );
                }));
              },
              minLeadingWidth: 30,
              contentPadding: const EdgeInsets.symmetric(horizontal: 30),
              leading: const Icon(
                CupertinoIcons.pencil,
                color: Colors.grey,
              ),
              title: Text(
                "Edit item",
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium!
                    .copyWith(fontSize: 20, color: Colors.white),
              ),
            ),
            ListTile(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text(
                        "Delete item",
                        style: TextStyle(
                            color: Colors.black, fontWeight: FontWeight.bold),
                      ),
                      content: Text(
                          "This will permanently delete this item from all your lists. Are you sure?",
                          style: TextStyle(color: Colors.black)),
                      actions: <Widget>[
                        TextButton(
                          child: Text(
                            "Cancel",
                            style: TextStyle(color: Colors.black),
                          ),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                        MaterialButton(
                          color: Colors.lightGreenAccent[700],
                          minWidth: MediaQuery.of(context).size.width * .2,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(30), // Circular border
                          ),
                          onPressed: () {
                            Navigator.of(context).pop();
                            Navigator.pop(context);
                            state.deleteItem(item!.key!, listState: listState);
                            Navigator.pop(context);
                          },
                          child: const Padding(
                            padding: EdgeInsets.all(4.0),
                            child: Text(
                              "Delete",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
              minLeadingWidth: 30,
              contentPadding: const EdgeInsets.symmetric(horizontal: 30),
              leading: const Icon(
                CupertinoIcons.trash,
                color: Colors.grey,
              ),
              title: Text(
                "Delete",
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium!
                    .copyWith(fontSize: 20, color: Colors.white),
              ),
            ),
          ],
        );
      }
    }

    listItems.add(const SizedBox(
      height: 30,
    ));

    return SingleChildScrollView(
      // Wrap the Column with SingleChildScrollView
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: listItems,
      ),
    );
  }

  Widget _listBody(BuildContext context, double devicePexelRatio,
      ListState state, UserModel? listUser) {
    return SingleChildScrollView(
      // Wrap the Column with SingleChildScrollView
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * .2,
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width * .4,
            child: Column(
              children: [
                AspectRatio(
                  aspectRatio: 1,
                  child: DynamicListImage(list: list!, width: 144, height: 144),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            list!.name!,
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .headlineMedium!
                .copyWith(fontSize: 20, color: Colors.white),
          ),
          const SizedBox(height: 5),
          Text(
            'by ' + listUser!.displayName!,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                  color: Colors.grey,
                ),
          ),
          const SizedBox(height: 20),
          LikeButton(list: list, isIcon: true),
          ListTile(
            onTap: () async {
              Navigator.pop(context);
            },
            minLeadingWidth: 30,
            contentPadding: const EdgeInsets.symmetric(horizontal: 30),
            leading: const Icon(
              Icons.share,
              color: Colors.grey,
            ),
            title: Text(
              "Share",
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium!
                  .copyWith(fontSize: 20, color: Colors.white),
            ),
          ),
          const SizedBox(
            height: 30,
          ),
        ],
      ),
    );
  }

  Widget _userListBody(BuildContext context, double devicePexelRatio,
      ListState state, UserModel? listUser) {
    List<Widget> listItems = [
      SizedBox(
        height: MediaQuery.of(context).size.height * .2,
      ),
      SizedBox(
        width: MediaQuery.of(context).size.width * .4,
        child: Column(
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: DynamicListImage(list: list!, width: 144, height: 144),
            ),
          ],
        ),
      ),
      const SizedBox(height: 20),
      Text(
        list!.name!,
        textAlign: TextAlign.center,
        style: Theme.of(context)
            .textTheme
            .headlineMedium!
            .copyWith(fontSize: 20, color: Colors.white),
      ),
      const SizedBox(height: 5),
      Text(
        'by ' + listUser!.displayName!,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
              color: Colors.grey,
            ),
      ),
      const SizedBox(height: 20),
      ListTile(
        onTap: () {
          Navigator.push(context,
              CupertinoPageRoute(builder: (BuildContext context) {
            return AddItemsPage(
              list: list!,
            );
          }));
        },
        minLeadingWidth: 30,
        contentPadding: const EdgeInsets.symmetric(horizontal: 30),
        leading: const Icon(
          CupertinoIcons.add_circled,
          color: Colors.grey,
        ),
        title: Text(
          "Add Items",
          style: Theme.of(context)
              .textTheme
              .bodyMedium!
              .copyWith(fontSize: 20, color: Colors.white),
        ),
      ),
      ListTile(
        onTap: () {
          Navigator.push(context,
              CupertinoPageRoute(builder: (BuildContext context) {
            return EditListPage(
              listModel: list!,
            );
          }));
        },
        minLeadingWidth: 30,
        contentPadding: const EdgeInsets.symmetric(horizontal: 30),
        leading: const Icon(
          CupertinoIcons.pencil,
          color: Colors.grey,
        ),
        title: Text(
          "Edit list",
          style: Theme.of(context)
              .textTheme
              .bodyMedium!
              .copyWith(fontSize: 20, color: Colors.white),
        ),
      ),
      ListTile(
        onTap: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text(
                  "Delete list",
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold),
                ),
                content: Text("Are you sure you want to delete this list?",
                    style: TextStyle(color: Colors.black)),
                actions: <Widget>[
                  TextButton(
                    child: Text(
                      "Cancel",
                      style: TextStyle(color: Colors.black),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  MaterialButton(
                    color: Colors.lightGreenAccent[700],
                    minWidth: MediaQuery.of(context).size.width * .2,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(30), // Circular border
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.pop(context);
                      state.deleteList(list!.key!);
                      Navigator.pop(context);
                    },
                    child: const Padding(
                      padding: EdgeInsets.all(4.0),
                      child: Text(
                        "Delete",
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
        minLeadingWidth: 30,
        contentPadding: const EdgeInsets.symmetric(horizontal: 30),
        leading: const Icon(
          CupertinoIcons.trash,
          color: Colors.grey,
        ),
        title: Text(
          "Delete list",
          style: Theme.of(context)
              .textTheme
              .bodyMedium!
              .copyWith(fontSize: 20, color: Colors.white),
        ),
      ),
      ListTile(
        onTap: () {
          Navigator.pop(context);
          list!.privacyLevel = list!.privacyLevel == ListPrivacyLevel.Private
              ? ListPrivacyLevel.Public
              : ListPrivacyLevel.Private;
          state.updateList(list!);
        },
        minLeadingWidth: 30,
        contentPadding: const EdgeInsets.symmetric(horizontal: 30),
        leading: list!.privacyLevel == ListPrivacyLevel.Private
            ? const Icon(CupertinoIcons.lock_open, color: Colors.grey)
            : const Icon(CupertinoIcons.lock, color: Colors.grey),
        title: Text(
          "Make " +
              (list!.privacyLevel == ListPrivacyLevel.Private
                  ? "Public"
                  : "Private"),
          style: Theme.of(context)
              .textTheme
              .bodyMedium!
              .copyWith(fontSize: 20, color: Colors.white),
        ),
      ),
      ListTile(
        onTap: () async {
          Navigator.pop(context);
        },
        minLeadingWidth: 30,
        contentPadding: const EdgeInsets.symmetric(horizontal: 30),
        leading: const Icon(
          Icons.share,
          color: Colors.grey,
        ),
        title: Text(
          "Share",
          style: Theme.of(context)
              .textTheme
              .bodyMedium!
              .copyWith(fontSize: 20, color: Colors.white),
        ),
      ),
      const SizedBox(
        height: 30,
      ),
    ];

    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: listItems,
      ),
    );
  }

  Widget _userBody(
      BuildContext context, double devicePexelRatio, AuthState state) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * .2,
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width * .4,
            child: Column(
              children: [
                AspectRatio(
                  aspectRatio: 1,
                  child: CachedNetworkImage(
                    imageUrl: user!.profilePic!,
                    memCacheHeight: (300 * devicePexelRatio).round(),
                    memCacheWidth: (300 * devicePexelRatio).round(),
                    maxHeightDiskCache: (300 * devicePexelRatio).round(),
                    maxWidthDiskCache: (300 * devicePexelRatio).round(),
                    fit: BoxFit.cover,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            user!.displayName!,
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .headlineMedium!
                .copyWith(fontSize: 20, color: Colors.white),
          ),
          const SizedBox(height: 5),
          Text(
            user!.userName!,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                  color: Colors.grey,
                ),
          ),
          const SizedBox(height: 20),
          ListTile(
            onTap: () {},
            minLeadingWidth: 30,
            contentPadding: const EdgeInsets.symmetric(horizontal: 30),
            leading: const Icon(
              Icons.share,
              color: Colors.grey,
            ),
            title: Text(
              "Share",
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium!
                  .copyWith(fontSize: 20, color: Colors.white),
            ),
          ),
          ListTile(
            onTap: () {
              Navigator.push(context, ScanScreen.getRoute(user!));
            },
            minLeadingWidth: 30,
            contentPadding: const EdgeInsets.symmetric(horizontal: 30),
            leading: const Icon(
              CupertinoIcons.qrcode,
              color: Colors.grey,
            ),
            title: Text(
              "QR Code",
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium!
                  .copyWith(fontSize: 20, color: Colors.white),
            ),
          ),
          const SizedBox(
            height: 30,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final devicePexelRatio = MediaQuery.of(context).devicePixelRatio;
    final state = Provider.of<ListState>(context);
    final feedState = Provider.of<ItemState>(context);
    final searchState = Provider.of<SearchState>(context);
    final authState = Provider.of<AuthState>(context);

    final isMyList = list != null && authState.userId == list!.userId;
    final isMyItem = item != null && authState.userId == item!.userId;
    UserModel? listUser;
    if (list != null) {
      listUser = searchState.getUserFromKey(list!.userId);
    }
    return Container(
        color: Colors.black,
        child: user != null
            ? _userBody(context, devicePexelRatio, authState)
            : item != null
                ? _itemBody(context, devicePexelRatio, feedState, searchState,
                    state, isMyList, isMyItem)
                : isMyList
                    ? _userListBody(context, devicePexelRatio, state, listUser)
                    : _listBody(context, devicePexelRatio, state, listUser));
  }
}
