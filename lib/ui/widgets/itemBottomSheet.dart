import 'package:flutter/material.dart';
import 'package:wish_pe/model/itemModel.dart';
import 'package:wish_pe/model/user.dart';
import 'package:wish_pe/state/authState.dart';
import 'package:wish_pe/state/itemState.dart';
import 'package:wish_pe/state/listState.dart';
import 'package:wish_pe/state/searchState.dart';
import 'package:wish_pe/ui/theme/theme.dart';
import 'package:wish_pe/widgets/customWidgets.dart';
import 'package:provider/provider.dart';

class ItemBottomSheet {
  Widget itemOptionIcon(BuildContext context,
      {required ItemModel model,
      required GlobalKey<ScaffoldState> scaffoldKey}) {
    return Container(
      width: 25,
      height: 25,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
      ),
      child: customIcon(context,
          icon: AppIcon.arrowDown,
          isCustomIcon: true,
          iconColor: AppColor.lightGrey),
    ).ripple(
      () {
        _openBottomSheet(context, model: model, scaffoldKey: scaffoldKey);
      },
      borderRadius: BorderRadius.circular(20),
    );
  }

  void _openBottomSheet(BuildContext context,
      {required ItemModel model,
      required GlobalKey<ScaffoldState> scaffoldKey}) async {
    var authState = Provider.of<AuthState>(context, listen: false);
    final searchState = Provider.of<SearchState>(context, listen: false);
    bool isMyItem = authState.userId == model.userId;
    await showModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: context,
      builder: (context) {
        return Container(
            padding: const EdgeInsets.only(top: 5, bottom: 0),
            height: context.height * (isMyItem ? .25 : .25),
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: _itemOptions(context,
                scaffoldKey: scaffoldKey,
                isMyItem: isMyItem,
                model: model,
                user: searchState.getUserFromKey(model.userId)));
      },
    );
  }

  Widget _itemOptions(BuildContext context,
      {required bool isMyItem,
      required ItemModel model,
      required UserModel? user,
      required GlobalKey<ScaffoldState> scaffoldKey}) {
    return Column(
      children: <Widget>[
        Container(
          width: context.width * .1,
          height: 5,
          decoration: BoxDecoration(
            color: Colors.grey,
            borderRadius: const BorderRadius.all(
              Radius.circular(10),
            ),
          ),
        ),
        SizedBox(
          height: context.height * .02,
        ),
        _widgetBottomSheetRow(context, AppIcon.link,
            text: 'Copy link to item', isEnable: false, onPressed: () async {}),
        isMyItem
            ? _widgetBottomSheetRow(
                context,
                AppIcon.delete,
                text: 'Delete Item',
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
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
                            Navigator.pop(context);
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
                            //Navigator.pop(context);
                            _deleteItem(
                              context,
                              model.key!,
                            );
                            //Navigator.pop(context);
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
                    ),
                  );
                },
                isEnable: true,
              )
            : _widgetBottomSheetRow(
                context,
                AppIcon.unFollow,
                isEnable: false,
                text: 'Unfollow ${user!.userName}',
                onPressed: () async {},
              ),
        _widgetBottomSheetRow(
          context,
          Icons.share,
          isEnable: false,
          text: 'Share',
          onPressed: () async {},
        ),
      ],
    );
  }

  Widget _widgetBottomSheetRow(BuildContext context, IconData icon,
      {required String text, Function? onPressed, bool isEnable = false}) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: <Widget>[
            customIcon(
              context,
              icon: icon,
              isCustomIcon: true,
              size: 25,
              paddingIcon: 8,
              iconColor:
                  onPressed != null ? AppColor.darkGrey : AppColor.lightGrey,
            ),
            const SizedBox(
              width: 10,
            ),
            customText(
              text,
              context: context,
              style: TextStyle(
                color: isEnable ? Colors.white : AppColor.lightGrey,
                fontSize: 18,
                fontWeight: FontWeight.w400,
              ),
            )
          ],
        ),
      ).ripple(() {
        if (onPressed != null) {
          onPressed();
        } else {
          Navigator.pop(context);
        }
      }),
    );
  }

  void _deleteItem(BuildContext context, String itemKey) {
    var state = Provider.of<ItemState>(context, listen: false);
    var listState = Provider.of<ListState>(context, listen: false);
    state.deleteItem(itemKey, listState: listState);
    // CLose bottom sheet
    Navigator.of(context).pop();
  }
}
