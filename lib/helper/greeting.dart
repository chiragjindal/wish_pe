import 'dart:math';

String greeting() {
  var hour = DateTime.now().hour;
  if (hour < 12) {
    return 'Good morning';
  }
  if (hour < 17) {
    return 'Good afternoon';
  }
  return 'Good Evening';
}

String getRandomColor() {
  Random random = Random();
  return '0x${random.nextInt(0xFFFFFF).toRadixString(16).padLeft(6, '0')}';
}
