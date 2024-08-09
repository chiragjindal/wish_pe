import 'package:flutter/material.dart';
import 'package:wish_pe/helper/fileHelper.dart';
import 'package:wish_pe/widgets/cache_image.dart';

class ImageViewPage extends StatelessWidget {
  final String imagePath;

  const ImageViewPage({Key? key, required this.imagePath}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          Colors.black, // Set the background color of the Scaffold to black
      body: Column(
        children: <Widget>[
          SizedBox(
            height: MediaQuery.of(context)
                .padding
                .top, // Adjust the height as needed for desired spacing
          ),
          Row(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(0),
                child: BackButton(color: Colors.white),
              ),
            ],
          ),
          Expanded(
            child: InteractiveViewer(
              child: imagePath.startsWith("data:")
                  ? buildBase64Image(imagePath, 200, 200)
                  : CacheImage(
                      path: imagePath,
                      fit: BoxFit.contain,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
