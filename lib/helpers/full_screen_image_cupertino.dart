import 'package:flutter/cupertino.dart';
import 'package:cloudkeja/helpers/cached_image.dart'; // Ensure this is the updated cachedImage

class FullScreenImageCupertino extends StatelessWidget {
  final String image;

  const FullScreenImageCupertino({Key? key, required this.image}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      // backgroundColor: CupertinoColors.black, // Set background for the page
      navigationBar: CupertinoNavigationBar(
        // backgroundColor: CupertinoColors.black.withOpacity(0.7), // Semi-transparent like iOS photos app
        // border: null, // No border for a more immersive feel
        // middle: const Text('View Image'), // Optional title
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Text('Done', style: TextStyle(fontWeight: FontWeight.bold)), // Ensure Done is clearly visible
          onPressed: () => Navigator.pop(context),
        ),
      ),
      child: Container( // Add a container to set a background color for the screen itself
        color: CupertinoColors.black, // Black background for fullscreen image viewer
        child: Center(
          child: cachedImage(
            context, // Pass context
            image,
            width: double.infinity,
            fit: BoxFit.fitWidth, // Ensures image fits width, height will scale
          ),
        ),
      ),
    );
  }
}
