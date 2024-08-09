import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wish_pe/helper/fileHelper.dart';
import 'package:wish_pe/model/itemModel.dart';
import 'package:wish_pe/ui/pages/itemDetail/imageViewPage.dart';

// ignore: must_be_immutable
class ItemImage extends StatefulWidget {
  ItemImage({Key? key, this.model, this.imageUrls}) : super(key: key);

  ItemModel? model;
  List<String>? imageUrls = [];

  @override
  _ItemImageState createState() => _ItemImageState();
}

class _ItemImageState extends State<ItemImage> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final devicePixelRatio = MediaQuery.of(context).devicePixelRatio;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      alignment: Alignment.centerRight,
      child: widget.imageUrls == null || widget.imageUrls!.isEmpty
          ? const SizedBox.shrink()
          : Column(
              children: [
                Container(
                  height: 300,
                  child: PageView.builder(
                    itemCount: widget.imageUrls!.length,
                    onPageChanged: (index) {
                      setState(() {
                        _currentIndex = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 0),
                        child: InkWell(
                          borderRadius: BorderRadius.all(
                            Radius.circular(10),
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              CupertinoPageRoute(
                                builder: (context) => ImageViewPage(
                                  imagePath: widget.imageUrls![index],
                                ),
                              ),
                            );
                          },
                          child: ClipRRect(
                            borderRadius: BorderRadius.all(
                              Radius.circular(10),
                            ),
                            child: Container(
                              width:
                                  MediaQuery.of(context).size.width * .95 - 8,
                              decoration: BoxDecoration(
                                color: Colors.black,
                              ),
                              child: AspectRatio(
                                aspectRatio: 3 / 3,
                                child: widget.imageUrls![index]
                                        .startsWith("data:")
                                    ? buildBase64Image(
                                        widget.imageUrls![index], 100, 100)
                                    : CachedNetworkImage(
                                        height: 100,
                                        imageUrl: widget.imageUrls![index],
                                        memCacheHeight:
                                            (200 * devicePixelRatio).round(),
                                        memCacheWidth:
                                            (200 * devicePixelRatio).round(),
                                        maxHeightDiskCache:
                                            (200 * devicePixelRatio).round(),
                                        maxWidthDiskCache:
                                            (200 * devicePixelRatio).round(),
                                        fit: BoxFit.cover,
                                      ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Image ${_currentIndex + 1} of ${widget.imageUrls!.length}',
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
    );
  }
}
