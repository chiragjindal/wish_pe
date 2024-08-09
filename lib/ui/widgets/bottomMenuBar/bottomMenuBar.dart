import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wish_pe/state/appState.dart';
import 'package:wish_pe/ui/theme/theme.dart';
import 'package:wish_pe/ui/widgets/bottomMenuBar/tabItem.dart';
import 'package:provider/provider.dart';

import '../../../widgets/customWidgets.dart';

class BottomMenubar extends StatefulWidget {
  const BottomMenubar({
    Key? key,
  });
  @override
  _BottomMenubarState createState() => _BottomMenubarState();
}

class _BottomMenubarState extends State<BottomMenubar> {
  @override
  void initState() {
    super.initState();
  }

  Widget _iconRow() {
    var state = Provider.of<AppState>(
      context,
    );
    return Container(
      height: 50,
      decoration: BoxDecoration(color: Colors.black, boxShadow: const [
        BoxShadow(color: Colors.black12, offset: Offset(0, -.1), blurRadius: 0)
      ]),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          _icon(null, 0,
              icon: 0 == state.pageIndex ? AppIcon.homeFill : AppIcon.home,
              isCustomIcon: true),
          _icon(null, 1,
              icon: 1 == state.pageIndex ? AppIcon.searchFill : AppIcon.search,
              isCustomIcon: true),
          _icon(
              2 == state.pageIndex
                  ? CupertinoIcons.plus_app_fill
                  : CupertinoIcons.plus_app,
              2,
              isCustomIcon: false),
          _icon(
              3 == state.pageIndex
                  ? CupertinoIcons.star_fill
                  : CupertinoIcons.star,
              3,
              isCustomIcon: false),
          _icon(
              4 == state.pageIndex
                  ? CupertinoIcons.square_list_fill
                  : CupertinoIcons.square_list,
              4,
              isCustomIcon: false),
        ],
      ),
    );
  }

  Widget _icon(IconData? iconData, int index,
      {bool isCustomIcon = false, IconData? icon}) {
    if (isCustomIcon) {
      assert(icon != null);
    } else {
      assert(iconData != null);
    }
    var state = Provider.of<AppState>(
      context,
    );
    return Expanded(
      child: SizedBox(
        height: double.infinity,
        width: double.infinity,
        child: AnimatedAlign(
          duration: const Duration(milliseconds: ANIM_DURATION),
          curve: Curves.easeIn,
          alignment: const Alignment(0, ICON_ON),
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: ANIM_DURATION),
            opacity: ALPHA_ON,
            child: IconButton(
              highlightColor: Colors.transparent,
              splashColor: Colors.transparent,
              padding: const EdgeInsets.all(0),
              alignment: const Alignment(0, 0),
              icon: isCustomIcon
                  ? customIcon(context,
                      icon: icon!,
                      size: 22,
                      isCustomIcon: true,
                      isEnable: index == state.pageIndex)
                  : Icon(
                      iconData,
                      color: index == state.pageIndex
                          ? ColorConstants.primaryColor
                          : Colors.white,
                    ),
              onPressed: () {
                setState(() {
                  state.setPageIndex = index;
                });
              },
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _iconRow();
  }
}
