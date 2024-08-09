import 'package:flutter/material.dart';
import 'package:wish_pe/helper/utility.dart';
import 'package:wish_pe/model/itemModel.dart';
import 'package:wish_pe/model/listModel.dart';
import 'package:wish_pe/state/authState.dart';
import 'package:wish_pe/state/listState.dart';
import 'package:provider/provider.dart';

// ignore: must_be_immutable
class DialogContentWidget extends StatefulWidget {
  final TextEditingController controller;
  ItemModel? item;

  DialogContentWidget({required this.controller, this.item});

  @override
  _DialogContentWidgetState createState() => _DialogContentWidgetState();
}

class _DialogContentWidgetState extends State<DialogContentWidget> {
  bool isPublic = false;
  @override
  Widget build(BuildContext context) {
    return Dialog(
        insetPadding: EdgeInsets.zero,
        backgroundColor: Colors.transparent,
        child: AlertDialog(
          backgroundColor: Colors.grey.shade900,
          title: const Text(
            "Give your list a name.",
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: widget.controller,
                cursorColor: Colors.lightGreen,
                style: const TextStyle(color: Colors.white, fontSize: 24),
                autofocus: true,
                onChanged: (text) {
                  setState(() {});
                },
                decoration: const InputDecoration(
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.lightGreen, width: 2),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Make Public",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  Switch(
                    value: isPublic,
                    onChanged: (value) {
                      setState(() {
                        isPublic = value;
                      });
                    },
                    activeColor: Colors.lightGreen,
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "CANCEL",
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
            TextButton(
              onPressed: () async {
                var listKey = await _createList(context, widget.item);
                if (listKey != null) {
                  Utility.customToast(context, "Added");
                  Navigator.pop(context);
                  if (widget.item != null) {
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                  }
                } else {
                  Utility.errorSnackBar(context, "List already exists");
                }
              },
              child: Text(
                widget.controller.text.isEmpty ? "SKIP" : "CREATE",
                style: TextStyle(color: Colors.lightGreen[700], fontSize: 12),
              ),
            )
          ],
        ));
  }

  Future<String?> _createList(BuildContext context, ItemModel? item) async {
    var authState = Provider.of<AuthState>(context, listen: false);
    final state = Provider.of<ListState>(context, listen: false);

    var myUser = authState.userModel;
    var newList = new ListModel(
        name: (widget.controller.text.isEmpty
            ? "My list #${myUser!.listCounter! + 1}"
            : widget.controller.text),
        userId: myUser!.userId!,
        privacyLevel: isPublic ? ListPrivacyLevel.Public : null,
        createdAt: DateTime.now().toString());
    if (item != null) {
      newList.itemKeyList = [item.key!];
    }

    if (widget.controller.text.isEmpty) {
      myUser.listCounter = myUser.listCounter! + 1;
      await authState.updateUserProfile(myUser);
    }
    final listKey = await state.createList(newList);
    return listKey;
  }
}
