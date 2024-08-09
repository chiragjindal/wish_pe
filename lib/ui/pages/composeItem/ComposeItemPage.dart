import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wish_pe/helper/constant.dart';
import 'package:wish_pe/helper/imagePicker.dart';
import 'package:wish_pe/helper/utility.dart';
import 'package:wish_pe/model/itemDetailModel.dart';
import 'package:wish_pe/model/itemModel.dart';
import 'package:wish_pe/model/listModel.dart';
import 'package:wish_pe/ui/pages/itemDetail/itemDetailPage.dart';
import 'package:wish_pe/ui/widgets/categoryIcon.dart';
import 'package:wish_pe/ui/widgets/newListDialogWidget.dart';
import 'package:wish_pe/state/authState.dart';
import 'package:wish_pe/state/itemState.dart';
import 'package:wish_pe/state/listState.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:provider/provider.dart';

// ignore: must_be_immutable
class ComposeItemPage extends StatefulWidget {
  ItemModel? model;
  ItemDetailModel? itemDetailModel;
  File? itemImageFile;
  final GlobalKey<ScaffoldState>? scaffoldKey;
  ComposeItemPage(
      {Key? key,
      this.scaffoldKey,
      this.model,
      this.itemDetailModel,
      this.itemImageFile})
      : super(key: key);

  @override
  _ComposeItemPageState createState() => _ComposeItemPageState();
}

class _ComposeItemPageState extends State<ComposeItemPage> {
  File? _banner;
  late TextEditingController _title;
  late TextEditingController _price;
  late TextEditingController _desc;
  late TextEditingController _url;

  late ItemState state;
  late AuthState authState;
  late ListState listState;
  late bool isEdit;
  late bool isExtendedVisible = false;
  late bool isImage404 = false;

  late String selectedCurrency;
  late List<ListModel> selectedLists;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  List<String> currencies = [
    '\$',
    '₹',
    'USD',
    'INR',
    'EUR',
    'GBP',
    'JPY',
  ];
  @override
  void initState() {
    _title = TextEditingController();
    _price = TextEditingController();
    _desc = TextEditingController();
    _url = TextEditingController();

    _banner = widget.itemImageFile;

    state = Provider.of<ItemState>(context, listen: false);
    authState = Provider.of<AuthState>(context, listen: false);
    listState = Provider.of<ListState>(context, listen: false);
    isEdit = widget.model != null;

    _title.text = widget.model == null ? '' : widget.model!.title!;
    if (widget.model != null && widget.itemDetailModel == null) {
      state.fetchItemDetail(widget.model!.key!);
      widget.itemDetailModel = state.cachedItemDetails![widget.model!.key!];
    }
    _price.text = widget.itemDetailModel?.finalPrice ?? '';
    _desc.text = widget.itemDetailModel?.description ?? '';
    _url.text = widget.itemDetailModel?.url ?? '';

    selectedCurrency = widget.itemDetailModel?.currency ?? currencies.first;
    selectedLists = [listState.myDefaultList!];
    super.initState();
  }

  @override
  void dispose() {
    _title.dispose();
    _price.dispose();
    _desc.dispose();
    _url.dispose();
    super.dispose();
  }

  Widget _body() {
    TextEditingController con = TextEditingController();
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
        _entry('Item Title', controller: _title),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Expanded(
              child: _buildCurrencyDropdown(),
            ),
            const SizedBox(width: 5),
            Expanded(
              flex: 3,
              child: _entry('Price', controller: _price),
            ),
          ],
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Expanded(
              child: _buildListDropdown(),
            ),
            const SizedBox(width: 5),
            Padding(
              padding:
                  EdgeInsets.only(top: 20, bottom: 20, left: 10, right: 10),
              child: Column(
                children: [
                  SizedBox(
                    width: 30,
                    height: 30,
                    child: IconButton(
                      icon: Icon(
                        Icons.add,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return DialogContentWidget(controller: con);
                            });
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        widget.model == null
            ? SizedBox()
            : _categoryWidget(context, widget.model!.categoryKeyList),
        Center(
          child: Container(
            margin: const EdgeInsets.only(top: 10, bottom: 10),
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 5,
            ),
            decoration: BoxDecoration(
              color: Colors.transparent,
              border: Border.all(color: Colors.grey, width: 1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: InkWell(
              onTap: () => {
                setState(() {
                  isExtendedVisible = !isExtendedVisible;
                })
              },
              child: Text(
                'Add More Details',
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 10,
                ),
              ),
            ),
          ),
        ),
        isExtendedVisible ? _extendedBody() : Container(),
      ],
    );
  }

  Widget _extendedBody() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _entry('Description', controller: _desc),
        _entry('Provider Webpage Url', controller: _url),
      ],
    );
  }

  Widget _buildCurrencyDropdown() {
    return Container(
      margin: const EdgeInsets.only(top: 20, bottom: 20, left: 9),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButton<String>(
              value: selectedCurrency,
              style: TextStyle(
                color: Colors.white,
              ),
              dropdownColor: Colors.black,
              underline: Container(
                height: 0,
              ),
              icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey),
              items: currencies.map((String currency) {
                return DropdownMenuItem<String>(
                  value: currency,
                  child: Text(
                    currency,
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  selectedCurrency = newValue!;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListDropdown() {
    final allLists = listState.myLists!;
    final defaultList = listState.myDefaultList!;
    return Container(
      margin: const EdgeInsets.only(top: 20, bottom: 20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: MultiSelectDialogField(
          buttonText: Text('Add to List',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
              )),
          buttonIcon: const Icon(Icons.keyboard_arrow_down,
              color: Colors.grey, size: 16),
          items: allLists.map((e) => MultiSelectItem(e, e.name!)).toList(),
          initialValue: selectedLists,
          searchable: true,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
          listType: MultiSelectListType.CHIP,
          confirmText: Text('OK',
              style: const TextStyle(
                color: Colors.lightGreen,
                fontSize: 14,
              )),
          cancelText: Text('CANCEL',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
              )),
          title: Text('Select',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
              )),
          selectedColor: Colors.lightGreen[700],
          backgroundColor: Colors.grey.shade900,
          unselectedColor: Colors.grey,
          searchIcon: const Icon(Icons.search, color: Colors.white),
          closeSearchIcon: const Icon(Icons.close, color: Colors.white),
          itemsTextStyle: const TextStyle(color: Colors.white),
          searchTextStyle: const TextStyle(color: Colors.white),
          searchHintStyle: const TextStyle(color: Colors.grey),
          selectedItemsTextStyle: const TextStyle(color: Colors.white),
          separateSelectedItems: true,
          chipDisplay: MultiSelectChipDisplay(
            onTap: (value) {
              if (value != defaultList) {
                setState(() {
                  selectedLists.remove(value);
                });
              }
            },
            chipColor: Colors.lightGreen[700],
            textStyle: const TextStyle(color: Colors.white),
            items:
                selectedLists.map((e) => MultiSelectItem(e, e.name!)).toList(),
          ),
          onConfirm: (List<ListModel> values) {
            if (!values.contains(defaultList)) {
              values.add(defaultList);
            }
            selectedLists = values;
          },
        ),
      ),
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
                : widget.model != null && widget.model!.imageUrl != null
                    ? CachedNetworkImage(
                        imageUrl: widget.model!.imageUrl!,
                        width: 140,
                        height: 140,
                        fit: BoxFit.cover,
                        errorWidget: (context, url, error) {
                          isImage404 = true;
                          return Image.asset(
                            'assets/images/default_item_pic.png',
                            width: 140,
                            height: 140,
                            fit: BoxFit.cover,
                          );
                        },
                      )
                    : Image.asset(
                        'assets/images/default_item_pic.png',
                        width: 140,
                        height: 140,
                        fit: BoxFit.cover,
                      ),
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
    if (_title.text.length > 200) {
      Utility.customToast(context, 'Title length cannot exceed 200 character');
      return;
    }

    if (_title.text.isEmpty) {
      Utility.customToast(context, 'Title cannot be empty');
      return;
    }

    if (isEdit == false) {
      widget.model = ItemModel(
          createdAt: DateTime.now().toUtc().toString(),
          categoryKeyList: <String>[],
          likeList: <String>[],
          likeCount: 0,
          imageUrl: Constants.defaultItemPicPath,
          userId: authState.userModel!.userId!);

      widget.itemDetailModel =
          ItemDetailModel(images: [Constants.defaultItemPicPath]);
    }

    if (isImage404 == true) {
      widget.model!.imageUrl = Constants.defaultItemPicPath;
      widget.itemDetailModel!.images = [Constants.defaultItemPicPath];
    }

    if (_title.text.isNotEmpty) {
      widget.model!.title = _title.text;
    }
    if (_price.text.isNotEmpty) {
      widget.model!.price = selectedCurrency + ' ' + _price.text;
      widget.itemDetailModel!.finalPrice = _price.text;
      widget.itemDetailModel!.currency = selectedCurrency;
    }

    if (widget.itemDetailModel!.initialPrice == null ||
        widget.itemDetailModel!.initialPrice!.isEmpty) {
      widget.itemDetailModel!.initialPrice = widget.itemDetailModel!.finalPrice;
      widget.itemDetailModel!.discount = "0";
    }

    if (_desc.text.isNotEmpty) {
      widget.itemDetailModel!.description = _desc.text;
    }

    if (_url.text.isNotEmpty) {
      widget.itemDetailModel!.url = _url.text;
    }

    if (_banner != null) {
      /*
      ByteData data =
          await rootBundle.load("assets/images/default_item_pic.png");
      List<int> bytes = data.buffer.asUint8List();

      // Get the temporary directory path
      Directory tempDir = await getTemporaryDirectory();

      // Create a temporary File from the loaded bytes
      File tempFile = File('${tempDir.path}/defaultItemImage.png');
      await tempFile.writeAsBytes(bytes);
      _banner = File(tempFile.path);
      */

      await state.uploadFile(_banner!).then((imagePath) async {
        if (imagePath != null) {
          widget.model!.imageUrl = imagePath;
          widget.itemDetailModel!.images = [imagePath];
          await compose();
        }
      });
    } else {
      await compose();
    }

    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => ItemDetailPage(
          item: widget.model,
          isNavigatedFromComposePage: true,
        ),
      ),
    );
    //Navigator.of(context).pop();
  }

  void uploadBanner() {
    openImagePicker(context, (file) {
      setState(() {
        _banner = file;
      });
    });
  }

  compose() async {
    var state = Provider.of<ItemState>(context, listen: false);
    var listState = Provider.of<ListState>(context, listen: false);
    if (isEdit && widget.itemDetailModel == null) {
      state.updateItem(widget.model!);
    } else {
      var itemKey = await state.createItem(widget.model!,
          itemDetailModel: widget.itemDetailModel!);
      widget.model!.key = itemKey;
      listState.addToLists(selectedLists, itemKey!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text((widget.model == null ? 'Create' : 'Edit') + ' Item',
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

  Widget _categoryWidget(context, categoryList) {
    return Container(
        margin: EdgeInsets.symmetric(horizontal: 10),
        width: MediaQuery.of(context).size.width,
        height: 30,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: categoryList
                .map<Widget>(
                  (category) => CategoryIcon(
                    categoryKey: category,
                    color: Colors.white,
                  ),
                )
                .toList(),
          ),
        ));
  }
}
