import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:wish_pe/helper/fileHelper.dart';
import 'package:wish_pe/model/listModel.dart';
import 'package:wish_pe/state/itemState.dart';
import 'package:wish_pe/widgets/avatar_image.dart';
import 'package:provider/provider.dart';

class DynamicListImage extends StatelessWidget {
  final ListModel list;
  final double width;
  final double height;

  DynamicListImage({
    required this.list,
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<ItemState>(context);

    if (list.listImagePath != null) {
      return CachedNetworkImage(
        imageUrl: list.listImagePath!,
        width: width,
        height: height,
        fit: BoxFit.cover,
      );
    }

    final listImages = state.getItems(list.itemKeyList!)?.map((item) {
      return item.imageUrl;
    }).toList();

    if (listImages == null || listImages.isEmpty) {
      return AvatarImage(name: list.name!, width: width, height: height);
    }

    // Center alignment for single image
    if (listImages.length == 1) {
      return Center(
        child: listImages[0]!.startsWith("data:")
            ? buildBase64Image(listImages[0]!, width, height)
            : CachedNetworkImage(
                imageUrl: listImages[0]!,
                width: width,
                height: height,
                fit: BoxFit.cover,
              ),
      );
    }

    // Center alignment for 2 or 3 images in a row
    if (listImages.length <= 3) {
      return Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: width / 2,
              height: height,
              child: listImages[0]!.startsWith("data:")
                  ? buildBase64Image(listImages[0]!, width / 2, height)
                  : CachedNetworkImage(
                      imageUrl: listImages[0]!,
                      fit: BoxFit.cover,
                    ),
            ),
            if (listImages.length > 1)
              Container(
                width: width / 2,
                height: height,
                child: listImages[1]!.startsWith("data:")
                    ? buildBase64Image(listImages[1]!, width / 2, height)
                    : CachedNetworkImage(
                        imageUrl: listImages[1]!,
                        fit: BoxFit.cover,
                      ),
              ),
          ],
        ),
      );
    }

    // Center alignment for 4 images in a 2x2 grid
    if (listImages.length >= 4) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: width / 2,
                  height: height / 2,
                  child: listImages[0]!.startsWith("data:")
                      ? buildBase64Image(listImages[0]!, width / 2, height / 2)
                      : CachedNetworkImage(
                          imageUrl: listImages[0]!,
                          fit: BoxFit.cover,
                        ),
                ),
                Container(
                  width: width / 2,
                  height: height / 2,
                  child: listImages[1]!.startsWith("data:")
                      ? buildBase64Image(listImages[1]!, width / 2, height / 2)
                      : CachedNetworkImage(
                          imageUrl: listImages[1]!,
                          fit: BoxFit.cover,
                        ),
                ),
              ],
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: width / 2,
                  height: height / 2,
                  child: listImages[2]!.startsWith("data:")
                      ? buildBase64Image(listImages[2]!, width / 2, height / 2)
                      : CachedNetworkImage(
                          imageUrl: listImages[2]!,
                          fit: BoxFit.cover,
                        ),
                ),
                Container(
                  width: width / 2,
                  height: height / 2,
                  child: listImages[3]!.startsWith("data:")
                      ? buildBase64Image(listImages[3]!, width / 2, height / 2)
                      : CachedNetworkImage(
                          imageUrl: listImages[3]!,
                          fit: BoxFit.cover,
                        ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    // This code should not be reached if the input is well-formed.
    return Container();
  }
}
