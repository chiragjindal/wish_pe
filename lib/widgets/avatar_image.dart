import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AvatarImage extends StatelessWidget {
  AvatarImage({
    Key? key,
    required this.name,
    this.width = 100,
    this.height = 100,
  }) : super(key: key);
  final String name;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    //String backgroundColor = RandomColor.getColor(Options(format: Format.hex));
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        //color: hexToColor(backgroundColor),
        color: Colors.amber,
        shape: BoxShape.rectangle,
      ),
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : '',
          style: TextStyle(
            fontSize: 36,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class ImageOrAvatar extends StatelessWidget {
  final String imagePath;
  final double width;
  final double height;
  final String name;

  ImageOrAvatar({
    required this.imagePath,
    required this.width,
    required this.height,
    required this.name,
  });

  Future<bool> _assetExists(String assetPath) async {
    try {
      await rootBundle.load(assetPath);
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _assetExists(imagePath),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator(); // or any other placeholder
        } else if (snapshot.hasData && snapshot.data == true) {
          return Image.asset(
            imagePath,
            height: height,
            fit: BoxFit.cover,
            width: width,
            alignment: Alignment.center,
          );
        } else {
          return AvatarImage(name: name, width: width, height: height);
        }
      },
    );
  }
}

class ImageOrAvatarDecoration extends StatelessWidget {
  final String imagePath;
  final double width;
  final double height;
  final String name;

  ImageOrAvatarDecoration({
    required this.imagePath,
    required this.width,
    required this.height,
    required this.name,
  });

  Future<bool> _assetExists(String assetPath) async {
    try {
      await rootBundle.load(assetPath);
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _assetExists(imagePath),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator(); // or any other placeholder
        } else if (snapshot.hasData && snapshot.data == true) {
          return Container(
            height: height,
            width: width,
            foregroundDecoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.center,
                end: Alignment.topCenter,
                colors: [
                  Colors.black.withOpacity(.5),
                  Colors.transparent,
                ],
              ),
            ),
            decoration: BoxDecoration(
              image: DecorationImage(
                fit: BoxFit.cover,
                alignment: FractionalOffset.topCenter,
                image: AssetImage(imagePath),
              ),
            ),
          );
        } else {
          return AvatarImage(name: name, width: width, height: height);
        }
      },
    );
  }
}
