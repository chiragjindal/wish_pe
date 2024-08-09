import 'package:flutter/material.dart';
import 'package:wish_pe/model/user.dart';
import 'package:wish_pe/state/authState.dart';
import 'package:wish_pe/ui/theme/theme.dart';
import 'package:wish_pe/ui/pages/settings/widgets/headerWidget.dart';
import 'package:wish_pe/ui/pages/settings/widgets/settingsAppbar.dart';
import 'package:wish_pe/ui/pages/settings/widgets/settingsRowWidget.dart';
import 'package:provider/provider.dart';

class AccountSettingsPage extends StatelessWidget {
  const AccountSettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var user = Provider.of<AuthState>(context).userModel ?? UserModel();
    return Scaffold(
      backgroundColor: WishPeColor.black,
      appBar: SettingsAppBar(
        title: 'Account',
        subtitle: user.userName,
      ),
      body: ListView(
        children: <Widget>[
          const HeaderWidget('Login'),
          SettingRowWidget(
            "Username",
            subtitle: user.userName,
          ),
          const Divider(height: 0),
          SettingRowWidget(
            "Email address",
            subtitle: user.email,
            //navigateTo: 'VerifyEmailPage',
          ),
        ],
      ),
    );
  }
}
