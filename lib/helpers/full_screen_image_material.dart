import 'package:flutter/material.dart';
import 'package:cloudkeja/helpers/cached_image.dart'; // Ensure this is the updated cachedImage

class FullScreenImageMaterial extends StatelessWidget {
  final String image;

  const FullScreenImageMaterial({Key? key, required this.image}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true, // To make body content go behind transparent AppBar
      appBar: AppBar(
        backgroundColor: Colors.transparent, // Transparent background
        elevation: 0, // No shadow
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white), // White back button for contrast on image
          onPressed: () => Navigator.pop(context),
          tooltip: 'Back',
        ),
      ),
      body: Container( // Add a container to set a background color for the screen itself
        color: Colors.black, // Black background for fullscreen image viewer
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
