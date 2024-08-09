import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wish_pe/model/categoryModel.dart';
import 'package:wish_pe/state/searchState.dart';
import 'package:wish_pe/ui/pages/category/categoryPage.dart';
import 'package:wish_pe/ui/theme/theme.dart';
import 'package:wish_pe/widgets/newWidget/title_text.dart';
import 'package:provider/provider.dart';

class CategoryIcon extends StatelessWidget {
  final String categoryKey;
  final Color? color;
  CategoryIcon({Key? key, required this.categoryKey, this.color})
      : super(key: key);

  Widget build(BuildContext context) {
    final state = Provider.of<SearchState>(context);
    var model = state.categorylist!.firstWhere(
      (x) => x.key == categoryKey,
      orElse: () => CategoryModel(),
    );
    return model.key == null
        ? Container(width: 5)
        : Container(
            margin: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: 10,
              ),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                color: Colors.transparent,
                border: Border.all(
                  color: Colors.grey,
                  width: 1,
                ),
                // boxShadow: <BoxShadow>[
                //   BoxShadow(
                //     color: Colors.white,
                //     blurRadius: 10,
                //     spreadRadius: 5,
                //     offset: Offset(5, 5),
                //   ),
                // ],
              ),
              child: Row(
                children: <Widget>[
                  model.name == null
                      ? Container()
                      : Container(
                          child: TitleText(
                            model.name!,
                            color: color ?? Colors.black,
                            fontWeight: FontWeight.w700,
                            fontSize: 8,
                          ),
                        )
                ],
              ),
            ).ripple(
              () {
                Navigator.push(
                    context,
                    CupertinoPageRoute(
                        builder: (context) => CategoryPage(category: model)));
              },
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
          );
  }
}
