import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wish_pe/helper/fileHelper.dart';
import 'package:wish_pe/model/listModel.dart';
import 'package:wish_pe/state/itemState.dart';
import 'package:provider/provider.dart';

class ListImageWidget extends StatelessWidget {
  final ListModel list;
  final double height;
  final double width;
  const ListImageWidget({
    Key? key,
    required this.list,
    required this.height,
    required this.width,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<ItemState>(context);
    final itemsList = state.getItems(list.itemKeyList!);

    List<Widget> listImages = [];

    if (itemsList!.isEmpty) {
      listImages.add(Container());
    } else {
      var maxLength = itemsList.length > 4 ? 4 : itemsList.length;
      for (int i = 0; i < maxLength; i++) {
        listImages.add(
          ListImage(
            image: itemsList[i].imageUrl!,
            height: height,
            width: width,
          ),
        );
      }
    }

    return Wrap(
      children: listImages,
    );
  }
}

class ListImage extends StatelessWidget {
  const ListImage({
    Key? key,
    required this.image,
    required this.height,
    required this.width,
  }) : super(key: key);

  final String image;
  final double height;
  final double width;

  @override
  Widget build(BuildContext context) {
    final devicePexelRatio = MediaQuery.of(context).devicePixelRatio;
    return image.startsWith("data:")
        ? buildBase64Image(image, width, height)
        : CachedNetworkImage(
            imageUrl: image,
            width: width,
            height: height,
            memCacheHeight: (height * devicePexelRatio).round(),
            memCacheWidth: (height * devicePexelRatio).round(),
            maxHeightDiskCache: (height * devicePexelRatio).round(),
            maxWidthDiskCache: (height * devicePexelRatio).round(),
            fit: BoxFit.cover);
  }
}
