part of '../theme.dart';

class WishPeColor {
  static Color bondiBlue = const Color.fromRGBO(0, 132, 180, 1.0);
  static Color cerulean = const Color.fromRGBO(0, 172, 237, 1.0);
  static Color spindle = const Color.fromRGBO(192, 222, 237, 1.0);
  static Color white = const Color.fromRGBO(255, 255, 255, 1.0);
  static Color black = const Color.fromRGBO(0, 0, 0, 1.0);
  static Color woodsmoke = const Color.fromRGBO(20, 23, 2, 1.0);
  static Color woodsmoke_50 = const Color.fromRGBO(20, 23, 2, 0.5);
  static Color mystic = const Color.fromRGBO(230, 236, 240, 1.0);
  static Color dodgeBlue = const Color.fromRGBO(29, 162, 240, 1.0);
  static Color dodgeBlue_50 = const Color.fromRGBO(29, 162, 240, 0.5);
  static Color paleSky = const Color.fromRGBO(101, 119, 133, 1.0);
  static Color ceriseRed = const Color.fromRGBO(224, 36, 94, 1.0);
  static Color paleSky50 = const Color.fromRGBO(101, 118, 133, 0.5);
}

class AppColor {
  static const Color primary = Color(0xff1DA1F2);
  static const Color secondary = Color(0xff14171A);
  static const Color darkGrey = Color(0xff1657786);
  static const Color lightGrey = Color(0xffAAB8C2);
  static const Color extraLightGrey = Color(0xffE1E8ED);
  static const Color extraExtraLightGrey = Color(0xfF5F8FA);
  static const Color white = Color(0xFFffffff);
}

class ColorConstants {
  static Color starterWhite = hexToColor('#DADADA');
  static Color primaryColor = hexToColor('#1ED760');
  //static Color primaryColor = hexToColor('#f23005');
  static Color cardBackGroundColor = hexToColor('#0E0E0F');
  static Color inputHintColor = hexToColor('#FFFFFF');
}

Color hexToColor(String hex) {
  assert(RegExp(r'^#([0-9a-fA-F]{6})|([0-9a-fA-F]{8})$').hasMatch(hex));

  return Color(int.parse(hex.substring(1), radix: 16) +
      (hex.length == 7 ? 0xFF000000 : 0x00000000));
}
