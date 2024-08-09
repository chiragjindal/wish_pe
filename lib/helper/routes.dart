// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:wish_pe/ui/pages/auth/forgetPswdPage.dart';
import 'package:wish_pe/ui/pages/auth/loginPage.dart';
import 'package:wish_pe/ui/pages/auth/logupPage.dart';
import 'package:wish_pe/ui/pages/auth/welcomePage.dart';
import 'package:wish_pe/ui/unused/verifyEmail.dart';
import 'package:wish_pe/ui/pages/search/searchPage.dart';
import 'package:wish_pe/ui/pages/splash.dart';
import 'package:wish_pe/ui/pages/homePage.dart';
import 'package:wish_pe/ui/pages/profile/follow/followerListPage.dart';
import 'package:wish_pe/ui/pages/settings/accountSettings/accountSettingsPage.dart';
import 'package:wish_pe/ui/pages/settings/settingsAndPrivacyPage.dart';

import '../helper/customRoute.dart';
import '../ui/pages/profile/profilePage.dart';
import '../widgets/customWidgets.dart';

class Routes {
  static dynamic route() {
    return {
      'SplashPage': (BuildContext context) => const SplashPage(),
    };
  }

  static void sendNavigationEventToFirebase(String? path) {
    if (path != null && path.isNotEmpty) {
      // analytics.setCurrentScreen(screenName: path);
    }
  }

  static Route? onGenerateRoute(RouteSettings settings) {
    final List<String> pathElements = settings.name!.split('/');
    if (pathElements[0] != '' || pathElements.length == 1) {
      return null;
    }
    switch (pathElements[1]) {
      case "ProfilePage":
        String profileId;
        if (pathElements.length > 2) {
          profileId = pathElements[2];
          return CustomRoute<bool>(
              builder: (BuildContext context) => ProfilePage(
                    profileId: profileId,
                  ));
        }
        return CustomRoute(builder: (BuildContext context) => const HomePage());
      case "WelcomePage":
        return CustomRoute<bool>(
            builder: (BuildContext context) => const GetStartedPage());
      case "SignIn":
        return CustomRoute<bool>(
            builder: (BuildContext context) => LoginPage());
      case "SignUp":
        return CustomRoute<bool>(
            builder: (BuildContext context) => LogupPage());
      case "ForgetPswdPage":
        return CustomRoute<bool>(
            builder: (BuildContext context) => const ForgetPswdPage());
      case "SearchPage":
        return CustomRoute<bool>(
            builder: (BuildContext context) => SearchPage());
      case "SettingsPage":
        return CustomRoute<bool>(
          builder: (BuildContext context) => const SettingsAndPrivacyPage(),
        );
      case "AccountSettingsPage":
        return CustomRoute<bool>(
          builder: (BuildContext context) => const AccountSettingsPage(),
        );
      case "FollowerListPage":
        return CustomRoute<bool>(
          builder: (BuildContext context) => FollowerListPage(),
        );
      case "VerifyEmailPage":
        return CustomRoute<bool>(
          builder: (BuildContext context) => VerifyEmailPage(),
        );
      default:
        return onUnknownRoute(const RouteSettings(name: '/Feature'));
    }
  }

  static Route onUnknownRoute(RouteSettings settings) {
    return MaterialPageRoute(
      builder: (context) => Scaffold(
        appBar: AppBar(
          title: customTitleText(
            settings.name!.split('/')[1],
          ),
          centerTitle: true,
        ),
        body: Center(
          child: Text('${settings.name!.split('/')[1]} Comming soon..'),
        ),
      ),
    );
  }
}
