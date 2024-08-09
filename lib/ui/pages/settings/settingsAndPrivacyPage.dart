import 'package:flutter/material.dart';
import 'package:wish_pe/model/user.dart';
import 'package:wish_pe/state/authState.dart';
import 'package:wish_pe/ui/theme/theme.dart';
import 'package:wish_pe/ui/pages/settings/widgets/headerWidget.dart';
import 'package:wish_pe/widgets/customAppBar.dart';
import 'package:wish_pe/widgets/customWidgets.dart';
import 'package:provider/provider.dart';

import 'widgets/settingsRowWidget.dart';

class SettingsAndPrivacyPage extends StatelessWidget {
  const SettingsAndPrivacyPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var user = Provider.of<AuthState>(context).userModel ?? UserModel();
    return Scaffold(
      backgroundColor: WishPeColor.black,
      appBar: CustomAppBar(
        isBackButton: true,
        title: customTitleText(
          'Settings',
        ),
      ),
      body: ListView(
        children: <Widget>[
          HeaderWidget(user.userName),
          const SettingRowWidget(
            "Account",
            navigateTo: 'AccountSettingsPage',
          ),
          const Divider(height: 0),
        ],
      ),
    );
  }
}
