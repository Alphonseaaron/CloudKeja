import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart'; // Added for CupertinoIcons and CupertinoTheme
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:provider/provider.dart'; // Added for Provider
import 'package:cloudkeja/services/platform_service.dart'; // Added for PlatformService

class Ratings extends StatelessWidget {
  const Ratings({Key? key, required this.rating}) : super(key: key);
  final double rating;

  @override
  Widget build(BuildContext context) {
    final platformService = Provider.of<PlatformService>(context, listen: false);
    final bool isCupertino = platformService.useCupertino;

    Widget fullStar;
    Widget halfStar;
    Widget emptyStar;

    if (isCupertino) {
      final cupertinoPrimaryColor = CupertinoTheme.of(context).primaryColor;
      fullStar = Icon(CupertinoIcons.star_fill, color: cupertinoPrimaryColor);
      halfStar = Icon(CupertinoIcons.star_lefthalf_fill, color: cupertinoPrimaryColor);
      emptyStar = Icon(CupertinoIcons.star, color: cupertinoPrimaryColor.withOpacity(0.4)); // Softer empty star
    } else {
      fullStar = const Icon(Icons.star, color: Colors.amber);
      halfStar = const Icon(Icons.star_half, color: Colors.amber);
      emptyStar = const Icon(Icons.star_border, color: Colors.amber);
    }

    return RatingBar(
      onRatingUpdate: (rating) {}, // Empty as per original
      initialRating: rating,
      itemSize: 18, // Kept itemSize as per original
      minRating: 1, // Consider setting a minRating if 0 is not a valid display state
      allowHalfRating: true, // Allow half ratings to match star_half icon
      ratingWidget: RatingWidget(
        full: fullStar,
        half: halfStar,
        empty: emptyStar,
      ),
    );
  }
}
