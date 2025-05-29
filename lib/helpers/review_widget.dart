import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flare_flutter/flare_actor.dart'; // Assuming this package is intended and works
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
// import 'package:get/get.dart'; // Not used in this snippet

import 'package:provider/provider.dart';
// import 'package:cloudkeja/helpers/constants.dart'; // kPrimaryColor replaced by theme
// import 'package:cloudkeja/helpers/my_loader.dart'; // MyLoader will be replaced
import 'package:cloudkeja/models/review_model.dart';
import 'package:cloudkeja/providers/auth_provider.dart';
import 'package:cloudkeja/providers/post_provider.dart';
import 'package:cloudkeja/models/user_model.dart'; // For user model

class UserReview extends StatefulWidget {
  final String spaceId;
  const UserReview(this.spaceId, {Key? key}) : super(key: key);
  @override
  _UserReviewState createState() => _UserReviewState();
}

class _UserReviewState extends State<UserReview> {
  double _rating = 0.0; // Initialize rating
  final _reviewController = TextEditingController();
  String _flareAnimation = '0'; // Initial animation state for FlareActor
  bool _isLoading = false;

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  void _updateFlareAnimation(double rating) {
    setState(() {
      _rating = rating;
      if (rating >= 4.5) _flareAnimation = '100'; // Excellent
      else if (rating >= 3.5) _flareAnimation = '75'; // Good
      else if (rating >= 2.5) _flareAnimation = '50'; // Okay
      else if (rating >= 1.5) _flareAnimation = '25'; // Bad
      else if (rating > 0) _flareAnimation = '10';   // Very Bad
      else _flareAnimation = '0'; // No rating
    });
  }

  Future<void> _submitReview() async {
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(content: Text('Please log in to submit a review.', style: TextStyle(color: Theme.of(context).colorScheme.onError)), backgroundColor: Theme.of(context).colorScheme.error),
      );
      return;
    }
    if (_rating == 0.0) {
       ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(content: Text('Please provide a rating.', style: TextStyle(color: Theme.of(context).colorScheme.onError)), backgroundColor: Theme.of(context).colorScheme.error),
      );
      return;
    }

    setState(() => _isLoading = true);

    final review = ReviewModel(
      rating: _rating,
      review: _reviewController.text.trim(),
      createdAt: Timestamp.now(),
      fullName: user.name!,
      id: FirebaseFirestore.instance.collection('dummy').doc().id, // Firestore generates ID on server
      userId: user.userId!,
      imageUrl: user.profile,
      spaceId: widget.spaceId,
    );

    try {
      await Provider.of<PostProvider>(context, listen: false).sendRating(review);
      Navigator.of(context).pop(true); // Pop and indicate success
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to submit review: $e', style: TextStyle(color: Theme.of(context).colorScheme.onError)), backgroundColor: Theme.of(context).colorScheme.error),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    // This widget is typically shown in a Dialog.
    // The SimpleDialog in details.dart should provide the overall card/dialog shape.
    // This content will be inside that.
    return Padding(
      padding: const EdgeInsets.all(20.0), // Padding for the content
      child: Column(
        mainAxisSize: MainAxisSize.min, // Important for content in a dialog
        children: [
          // Header: Title and Cancel button
          Stack(
            alignment: Alignment.center, // Center the title
            children: [
              Text(
                'Leave a Rating',
                style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
              ),
              Positioned(
                top: -8, // Adjust to align with visual center of title
                right: -8, // Adjust for better tap area
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Cancel', style: textTheme.labelLarge?.copyWith(color: colorScheme.primary)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Flare Animation (kept as is, assuming it's a desired feature)
          if ( FlareActor.doesExist('assets/feelings.flr')) // Check if asset exists
            SizedBox(
              height: 100,
              child: Transform.scale(
                scale: 2, // This might make it too large, consider adjusting
                child: FlareActor(
                  'assets/feelings.flr',
                  fit: BoxFit.contain,
                  animation: _flareAnimation,
                ),
              ),
            )
          else const SizedBox(height: 20), // Fallback spacing if flare not used/found

          // Rating Bar
          RatingBar.builder(
            initialRating: _rating,
            minRating: 1,
            direction: Axis.horizontal,
            allowHalfRating: true,
            itemCount: 5,
            itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
            itemBuilder: (context, _) => const Icon(Icons.star, color: Colors.amber),
            onRatingUpdate: _updateFlareAnimation,
            itemSize: 32, // Slightly larger stars
          ),
          const SizedBox(height: 24),

          // Review TextField
          TextField(
            controller: _reviewController,
            decoration: const InputDecoration( // Will use global InputDecorationTheme
              hintText: 'Write your review (optional)',
              // labelText: 'Review', // Can also use labelText
            ),
            maxLines: 3, // Allow for a few lines of text
            textCapitalization: TextCapitalization.sentences,
          ),
          const SizedBox(height: 24),

          // Submit Button
          ElevatedButton(
            onPressed: _isLoading ? null : _submitReview, // Disable button when loading
            // Style will come from ElevatedButtonThemeData
            child: _isLoading
                ? SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: colorScheme.onPrimary, // Loader color on button
                    ),
                  )
                : Text('Submit Review', style: textTheme.labelLarge?.copyWith(color: colorScheme.onPrimary)),
          ),
        ],
      ),
    );
  }

  // buildReview method was not used and seems redundant with RatingBar.builder above.
  // Removed for clarity.
}
