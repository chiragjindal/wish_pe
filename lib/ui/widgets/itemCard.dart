import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wish_pe/helper/fileHelper.dart';
import 'package:wish_pe/model/itemModel.dart';
import 'package:wish_pe/state/searchState.dart';
import 'package:wish_pe/ui/pages/itemDetail/itemDetailPage.dart';
import 'package:wish_pe/ui/theme/theme.dart';
import 'package:wish_pe/widgets/newWidget/customLoader.dart';
import 'package:wish_pe/widgets/newWidget/title_text.dart';
import 'package:provider/provider.dart';

class ItemCard extends StatelessWidget {
  final ItemModel item;
  ItemCard({Key? key, required this.item}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<SearchState>(context);
    final devicePexelRatio = MediaQuery.of(context).devicePixelRatio;

    return Container(
      width: 150,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(20)),
        boxShadow: <BoxShadow>[
          BoxShadow(color: Color(0xfff8f8f8), blurRadius: 15, spreadRadius: 10),
        ],
      ),
      margin: EdgeInsets.symmetric(vertical: 20),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Expanded(
                  child: Stack(
                    alignment: Alignment.center,
                    children: <Widget>[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(5),
                        child: item.imageUrl!.startsWith("data:")
                            ? buildBase64Image(item.imageUrl!, 150, 150)
                            : CachedNetworkImage(
                                imageUrl: item.imageUrl!,
                                width: 150,
                                height: 150,
                                maxHeightDiskCache:
                                    (200 * devicePexelRatio).round(),
                                maxWidthDiskCache:
                                    (200 * devicePexelRatio).round(),
                                memCacheHeight:
                                    (200 * devicePexelRatio).round(),
                                memCacheWidth: (200 * devicePexelRatio).round(),
                                fit: BoxFit.cover,
                              ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 5),
                TitleText(
                  item.title!,
                  fontSize: 14,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                state.isBusy
                    ? SizedBox(
                        height: 0,
                        child: const CustomScreenLoader(
                          height: double.infinity,
                          width: double.infinity,
                          backgroundColor: Colors.black,
                        ),
                      )
                    : TitleText(
                        item.providerKey == null
                            ? ''
                            : state
                                .getProviderFromKey(item.providerKey!)
                                .displayName!,
                        fontSize: 12,
                        color: Colors.orange,
                      ),
                TitleText(
                  item.price.toString(),
                  fontSize: 16,
                ),
              ],
            ),
          ],
        ),
      ).ripple(() {
        Navigator.push(
            context,
            CupertinoPageRoute(
                builder: (context) => ItemDetailPage(item: item)));
      }, borderRadius: BorderRadius.all(Radius.circular(20))),
    );
  }
}
