import 'package:flutter/material.dart';
import 'package:wish_pe/helper/utility.dart';
import 'package:wish_pe/model/itemDetailModel.dart';
import 'package:wish_pe/model/itemModel.dart';
import 'package:wish_pe/model/listModel.dart';
import 'package:wish_pe/ui/widgets/bottomSheetWidget.dart';
import 'package:wish_pe/ui/widgets/categoryIcon.dart';
import 'package:wish_pe/ui/widgets/likeButton.dart';
import 'package:wish_pe/state/itemState.dart';
import 'package:wish_pe/state/searchState.dart';
import 'package:wish_pe/widgets/newWidget/title_text.dart';
import 'package:wish_pe/ui/widgets/itemImage.dart';
import 'package:provider/provider.dart';

// ignore: must_be_immutable
class ItemDetailPage extends StatefulWidget {
  ItemModel? item;
  ListModel? parentList;
  final String? itemKey;
  final bool isNavigatedFromComposePage;
  ItemDetailPage(
      {Key? key,
      this.isNavigatedFromComposePage = false,
      this.item,
      this.parentList,
      this.itemKey})
      : super(key: key);

  @override
  State<ItemDetailPage> createState() => _ItemDetailPageState();
}

class _ItemDetailPageState extends State<ItemDetailPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isExpanded = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<ItemState>(context);
    if (widget.itemKey != null) {
      widget.item = state.getItem(widget.itemKey!);
    }
    return FutureBuilder(
      future: state.fetchItemDetailAsync(widget.item!.key!),
      builder:
          (BuildContext context, AsyncSnapshot<ItemDetailModel?> snapshot) {
        if (snapshot.hasData) {
          return _body(context, snapshot.data!);
          // } else if (snapshot.connectionState == ConnectionState.waiting ||
          //     snapshot.connectionState == ConnectionState.active) {
          //   return const SizedBox(
          //     height: 4,
          //     child: LinearProgressIndicator(),
          //   );
        } else {
          return const SizedBox();
        }
      },
    );
  }

  Widget _categoryWidget(context, categoryList) {
    return Container(
        margin: EdgeInsets.symmetric(vertical: 10),
        width: MediaQuery.of(context).size.width,
        height: 30,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: categoryList
                .map<Widget>(
                  (category) => CategoryIcon(
                    categoryKey: category,
                  ),
                )
                .toList(),
          ),
        ));
  }

  Widget _body(BuildContext context, ItemDetailModel model) {
    final state = Provider.of<SearchState>(context);
    return Scaffold(
        body: SafeArea(
      child: Container(
        color: Colors.black,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0.0),
          child: Stack(
            children: [
              Column(
                children: [
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: Row(
                        children: [
                          BackButton(
                            color: Colors.white,
                            onPressed: () {
                              if (widget.isNavigatedFromComposePage) {
                                Navigator.pop(context);
                                Navigator.pop(context);
                                //Navigator.pop(context);
                              } else {
                                Navigator.pop(context);
                              }
                            },
                          ),
                          Expanded(
                            child: Center(
                              child: Column(
                                children: [
                                  Text(
                                    widget.item!.title!,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                    ),
                                    textAlign: TextAlign.justify,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(
                                    height: 4,
                                  ),
                                  Text(
                                    widget.parentList == null
                                        ? widget.item!.providerKey == null
                                            ? ''
                                            : state
                                                .getProviderFromKey(
                                                    widget.item!.providerKey!)
                                                .displayName!
                                        : widget.parentList!.name!,
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 14,
                                    ),
                                    textAlign: TextAlign.justify,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              showModalBottomSheet(
                                  useRootNavigator: true,
                                  isScrollControlled: true,
                                  elevation: 100,
                                  backgroundColor: Colors.black38,
                                  context: context,
                                  builder: (context) {
                                    return BottomSheetWidget(
                                      item: widget.item,
                                      list: widget.parentList,
                                    );
                                  });
                            },
                            icon: const Icon(
                              Icons.more_vert,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 16, right: 16),
                    child: ItemImage(
                      imageUrls: model.images,
                    ),
                  ),
                ],
              ),
              DraggableScrollableSheet(
                maxChildSize: .8,
                initialChildSize: .6,
                minChildSize: .45,
                builder: (context, scrollController) {
                  return Container(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10)
                        .copyWith(bottom: 0),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(40),
                          topRight: Radius.circular(40),
                        ),
                        color: Colors.white),
                    child: SingleChildScrollView(
                      controller: scrollController,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.max,
                        children: <Widget>[
                          SizedBox(height: 5),
                          Container(
                            alignment: Alignment.center,
                            child: Container(
                              width: 50,
                              height: 5,
                              decoration: BoxDecoration(
                                  color: Color(0xffa8a09b),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10))),
                            ),
                          ),
                          SizedBox(height: 10),
                          _categoryWidget(
                              context, widget.item!.categoryKeyList),
                          Container(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Row(
                                        children: <Widget>[
                                          model.discount == null ||
                                                  (model.discount == '0' &&
                                                      model.finalPrice == null)
                                              ? SizedBox()
                                              : TitleText(
                                                  '- ' +
                                                      (model.discount ?? '0'),
                                                  fontSize: 18,
                                                  color: Colors.red,
                                                ),
                                          model.discount == null ||
                                                  (model.discount == '0' &&
                                                      model.finalPrice == null)
                                              ? SizedBox()
                                              : SizedBox(width: 5),
                                          model.finalPrice == null
                                              ? SizedBox()
                                              : TitleText(
                                                  (model.currency ?? '\$') +
                                                      ' ' +
                                                      (model.finalPrice ?? ''),
                                                  fontSize: 18,
                                                ),
                                        ],
                                      ),
                                      model.initialPrice == null
                                          ? SizedBox()
                                          : Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: <Widget>[
                                                TitleText(
                                                  'M.R.P.: ',
                                                  fontSize: 8,
                                                  color: Colors.grey,
                                                ),
                                                Text(
                                                  (model.currency ?? '\$') +
                                                      (model.initialPrice ??
                                                          ''),
                                                  style: TextStyle(
                                                    fontSize: 8,
                                                    color: Colors.grey,
                                                    decoration: TextDecoration
                                                        .lineThrough,
                                                  ),
                                                ),
                                              ],
                                            ),
                                    ]),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: <Widget>[
                                    Row(
                                      children: <Widget>[
                                        LikeButton(
                                            item: widget.item, isIcon: false),
                                        SizedBox(width: 10),
                                        IconButton(
                                          icon: Icon(
                                            Icons.open_in_browser,
                                            color: Colors.grey,
                                          ),
                                          onPressed: () async {
                                            Utility.launchURL(model.url!);
                                          },
                                        )
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 10),
                          Container(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Row(
                                        children: <Widget>[
                                          TitleText(
                                            'Brand: ',
                                            fontSize: 12,
                                          ),
                                          SizedBox(width: 5),
                                          Text(
                                            model.brand ?? '',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 5),
                                      Row(
                                        children: <Widget>[
                                          TitleText(
                                            'Product ID: ',
                                            fontSize: 12,
                                          ),
                                          SizedBox(width: 5),
                                          Text(
                                            model.upin ?? '',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ]),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: <Widget>[
                                    Row(
                                      children: <Widget>[
                                        for (int i = 0; i < 5; i++)
                                          Icon(
                                            i < getRatingCount(model)
                                                ? Icons.star
                                                : Icons.star_border,
                                            color: Colors.yellow,
                                            size: 17,
                                          ),
                                      ],
                                    ),
                                    SizedBox(height: 5),
                                    Row(
                                      children: <Widget>[
                                        model.reviewsCount == null
                                            ? SizedBox()
                                            : Text(
                                                model.reviewsCount! +
                                                    ' reviews',
                                                style: TextStyle(fontSize: 12),
                                              ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              TitleText(
                                "Description",
                                fontSize: 14,
                              ),
                              SizedBox(height: 10),
                              Text(model.description ?? ''),
                            ],
                          ),
                          SizedBox(height: 10),
                          model.insights == null
                              ? SizedBox()
                              : _buildUserInsights(context, model),
                          SizedBox(height: 20),
                        ],
                      ),
                    ),
                  );
                },
              )
            ],
          ),
        ),
      ),
    ));
  }

  Widget _buildUserInsights(BuildContext context, ItemDetailModel model) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 200),
      height: _isExpanded ? null : 60,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
                if (_isExpanded) {
                  _controller.forward();
                } else {
                  _controller.reverse();
                }
              });
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    TitleText(
                      "User Insights",
                      fontSize: 14,
                    ),
                    IconButton(
                      icon: Image.asset(
                          'assets/images/Google-Gemini-AI-Icon.png'),
                      onPressed: () {},
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text(
                      "Summarized by AI",
                      style: TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                    SizedBox(width: 8),
                    RotationTransition(
                      turns: _controller,
                      child: Icon(
                        _isExpanded ? Icons.expand_less : Icons.expand_more,
                        size: 18,
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
          AnimatedCrossFade(
            firstChild: SizedBox.shrink(),
            secondChild: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 10),
                _buildInsightSection("Review insights", model.insights!),
                SizedBox(height: 10),
                _buildInsightSection("Pros", model.pros!.join('\n'),
                    width: double.infinity),
                SizedBox(height: 10),
                _buildInsightSection("Cons", model.cons!.join('\n'),
                    width: double.infinity),
              ],
            ),
            crossFadeState: _isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: Duration(milliseconds: 200),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightSection(String title, String content,
      {double width = double.infinity}) {
    return Container(
      padding: EdgeInsets.all(16),
      width: width,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TitleText(
            title,
            fontSize: 14,
          ),
          SizedBox(height: 10),
          if (title != "Review insights")
            ...content
                .split("\n")
                .map((item) => _buildInsightItem(
                    title == "Pros" ? Icons.check_circle : Icons.cancel, item))
                .toList()
          else
            Text(
              content,
              style: TextStyle(fontSize: 12),
            ),
        ],
      ),
    );
  }

  Widget _buildInsightItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          color: icon == Icons.check_circle ? Colors.green : Colors.red,
          size: 18,
        ),
        SizedBox(width: 10),
        Text(
          text,
          style: TextStyle(fontSize: 12),
        ),
      ],
    );
  }

  int getRatingCount(ItemDetailModel model) {
    if (model.rating == null) return 0;
    double ratingValue = double.parse(model.rating!);
    return ratingValue.toInt();
  }
}
