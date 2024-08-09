import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wish_pe/helper/imagePicker.dart';
import 'package:wish_pe/helper/utility.dart';
import 'package:wish_pe/model/listModel.dart';
import 'package:wish_pe/ui/widgets/dynamicImageWidget.dart';
import 'package:wish_pe/state/itemState.dart';
import 'package:wish_pe/state/listState.dart';
import 'package:wish_pe/state/searchState.dart';
import 'package:provider/provider.dart';

class EditListPage extends StatefulWidget {
  final ListModel listModel;
  const EditListPage({Key? key, required this.listModel}) : super(key: key);

  @override
  _EditListPageState createState() => _EditListPageState();
}

class _EditListPageState extends State<EditListPage> {
  File? _banner;
  late TextEditingController _name;
  late TextEditingController _desc;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  void initState() {
    _name = TextEditingController();
    _desc = TextEditingController();
    _name.text = widget.listModel.name ?? '';
    _desc.text = widget.listModel.description ?? '';
    super.initState();
  }

  @override
  void dispose() {
    _name.dispose();
    _desc.dispose();
    super.dispose();
  }

  Widget _body() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Center(
          child: SizedBox(
            width: MediaQuery.of(context).size.width * .4,
            child: Column(
              children: [
                AspectRatio(
                  aspectRatio: 1,
                  child: _bannerImage(),
                ),
              ],
            ),
          ),
        ),
        _entry('List name', controller: _name),
        _entry('Give your list a description', controller: _desc),
        _itemList(),
      ],
    );
  }

  Widget _bannerImage() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.black45,
      ),
      child: Stack(
        children: [
          Center(
            child: _banner != null
                ? Image.file(_banner!,
                    fit: BoxFit.fill, width: MediaQuery.of(context).size.width)
                : DynamicListImage(
                    list: widget.listModel, width: 140, height: 140),
          ),
          Center(
            child: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  color: Colors.black38),
              child: IconButton(
                onPressed: uploadBanner,
                icon: const Icon(Icons.camera_alt, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _itemList() {
    final state = Provider.of<ItemState>(context);
    final listState = Provider.of<ListState>(context);
    final searchState = Provider.of<SearchState>(context);
    final itemsList = state.getItems(widget.listModel.itemKeyList!);

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, i) {
        final info = itemsList![i];

        return Dismissible(
          key: Key(info.title.toString()),
          onDismissed: (direction) {
            listState.addToList(widget.listModel, itemsList[i].key!);
            Utility.customToast(context, "Removed from Playlist.");
          },
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            child: const Padding(
              padding: EdgeInsets.all(20.0),
              child: Icon(
                CupertinoIcons.delete,
                color: Colors.white,
              ),
            ),
          ),
          child: ListTile(
            leading: IconButton(
              onPressed: () {
                listState.addToList(widget.listModel, itemsList[i].key!);
                Utility.customToast(context, "Removed from Playlist.");
              },
              icon: const Icon(
                Icons.remove_circle,
                color: Colors.grey,
              ),
            ),
            title: Text(
              info.title.toString(),
              maxLines: 1,
              style: const TextStyle(color: Colors.white),
            ),
            subtitle: Text(
              searchState.getItemModelSubTitle(info),
              style: const TextStyle(color: Colors.grey),
            ),
          ),
        );
      },
      itemCount: itemsList == null ? 0 : itemsList.length,
    );
  }

  Widget _entry(String hintText,
      {required TextEditingController controller,
      int maxLine = 1,
      bool enabled = true}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TextField(
            enabled: enabled,
            controller: controller,
            maxLines: maxLine,
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: const TextStyle(color: Colors.grey),
              focusColor: Colors.white,
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.grey),
              ),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.grey),
              ), //
              contentPadding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
            ),
            cursorColor: Colors.white,
            style: TextStyle(color: Colors.white),
          )
        ],
      ),
    );
  }

  void _submitButton() async {
    if (_name.text.length > 27) {
      Utility.customToast(context, 'Name length cannot exceed 27 character');
      return;
    }
    var state = Provider.of<ListState>(context, listen: false);
    if (_name.text.isNotEmpty) {
      widget.listModel.name = _name.text;
    }
    if (_desc.text.isNotEmpty) {
      widget.listModel.description = _desc.text;
    }

    if (_banner != null) {
      await state.uploadFile(_banner!).then((imagePath) async {
        if (imagePath != null) {
          widget.listModel.listImagePath = imagePath;
        }
      });
    }

    state.updateList(widget.listModel);
    Navigator.of(context).pop();
  }

  void uploadBanner() {
    openImagePicker(context, (file) {
      setState(() {
        _banner = file;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text('Edit List',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
            )),
        actions: <Widget>[
          InkWell(
            onTap: _submitButton,
            child: const Center(
              child: Text(
                'Save',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 20),
        ],
      ),
      body: SingleChildScrollView(
        child: _body(),
      ),
    );
  }
}
