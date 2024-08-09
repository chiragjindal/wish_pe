import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wish_pe/helper/fileHelper.dart';
import 'package:wish_pe/model/itemModel.dart';
import 'package:wish_pe/ui/pages/itemDetail/imageViewPage.dart';
import 'package:wish_pe/widgets/cache_image.dart';
import 'package:wish_pe/ui/theme/theme.dart';

class ItemImage extends StatelessWidget {
  const ItemImage({Key? key, required this.model}) : super(key: key);

  final ItemModel model;
  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      alignment: Alignment.centerRight,
      child: model.imageUrl == null
          ? const SizedBox.shrink()
          : Padding(
              padding: const EdgeInsets.only(top: 8, left: 15),
              child: InkWell(
                borderRadius: BorderRadius.all(
                  Radius.circular(20),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    CupertinoPageRoute(
                      builder: (context) => ImageViewPage(
                        imagePath: model.imageUrl!,
                      ),
                    ),
                  );
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.all(
                    Radius.circular(20),
                  ),
                  child: Container(
                    width: context.width - 10,
                    decoration: BoxDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                    ),
                    child: AspectRatio(
                      aspectRatio: 4 / 3,
                      child: model.imageUrl!.startsWith("data:")
                          ? buildBase64Image(model.imageUrl!, 50, 50)
                          : CacheImage(
                              path: model.imageUrl!,
                              fit: BoxFit.cover,
                            ),
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
