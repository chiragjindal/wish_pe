import 'package:flutter/material.dart';
import 'package:wish_pe/model/itemModel.dart';
import 'package:wish_pe/ui/widgets/itemCard.dart';

class ItemWidget extends StatelessWidget {
  final List<ItemModel> items;
  const ItemWidget({Key? key, required this.items}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 280,
      child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: items.length,
          itemBuilder: (context, i) {
            final item = items[i];
            return InkWell(
                child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ItemCard(item: item)));
          }),
    );
  }
}
