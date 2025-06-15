import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:provider/provider.dart';
import 'package:cloudkeja/models/review_model.dart';
import 'package:cloudkeja/providers/auth_provider.dart';
import 'package:cloudkeja/providers/post_provider.dart';
// Removed UserModel import as user is obtained from AuthProvider

class UserReviewMaterialContent extends StatefulWidget {
  final String spaceId;
  const UserReviewMaterialContent({Key? key, required this.spaceId}) : super(key: key); // Added required for spaceId
  @override
  _UserReviewMaterialContentState createState() => _UserReviewMaterialContentState();
}

class _UserReviewMaterialContentState extends State<UserReviewMaterialContent> {
  double _rating = 0.0;
  final _reviewController = TextEditingController();
  String _flareAnimation = '0';
  bool _isLoading = false;

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  void _updateFlareAnimation(double rating) {
    setState(() {
      _rating = rating;
      if (rating >= 4.5) _flareAnimation = '100';
      else if (rating >= 3.5) _flareAnimation = '75';
      else if (rating >= 2.5) _flareAnimation = '50';
      else if (rating >= 1.5) _flareAnimation = '25';
      else if (rating > 0) _flareAnimation = '10';
      else _flareAnimation = '0';
    });
  }

  Future<void> _submitReview() async {
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    final colorScheme = Theme.of(context).colorScheme; // For snackbar theming

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(content: Text('Please log in to submit a review.', style: TextStyle(color: colorScheme.onError)), backgroundColor: colorScheme.error),
      );
      return;
    }
    if (_rating == 0.0) {
       ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(content: Text('Please provide a rating.', style: TextStyle(color: colorScheme.onError)), backgroundColor: colorScheme.error),
      );
      return;
    }

    setState(() => _isLoading = true);

    final review = ReviewModel(
      rating: _rating,
      review: _reviewController.text.trim(),
      createdAt: Timestamp.now(),
      fullName: user.name!, // Assuming user.name is non-null if user exists
      id: FirebaseFirestore.instance.collection('dummy').doc().id,
      userId: user.userId!,
      imageUrl: user.profile,
      spaceId: widget.spaceId,
    );

    try {
      await Provider.of<PostProvider>(context, listen: false).sendRating(review);
      Navigator.of(context).pop(true); // Pop and indicate success
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to submit review: ${e.toString()}', style: TextStyle(color: colorScheme.onError)), backgroundColor: colorScheme.error),
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

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Text(
                'Leave a Rating',
                style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
              ),
              Positioned(
                top: -8,
                right: -8,
                child: TextButton( // Changed to TextButton for less emphasis than IconButton in this context
                  onPressed: () => Navigator.of(context).pop(false), // Indicate not successful
                  child: Text('Cancel', style: textTheme.labelLarge?.copyWith(color: colorScheme.primary)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          if ( FlareActor.doesExist('assets/feelings.flr'))
            SizedBox(
              height: 100,
              child: Transform.scale(
                scale: 2,
                child: FlareActor(
                  'assets/feelings.flr',
                  fit: BoxFit.contain,
                  animation: _flareAnimation,
                ),
              ),
            )
          else const SizedBox(height: 20),

          RatingBar.builder(
            initialRating: _rating,
            minRating: 1,
            direction: Axis.horizontal,
            allowHalfRating: true,
            itemCount: 5,
            itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
            itemBuilder: (context, _) => const Icon(Icons.star, color: Colors.amber), // Kept Colors.amber
            onRatingUpdate: _updateFlareAnimation,
            itemSize: 32,
          ),
          const SizedBox(height: 24),

          TextField(
            controller: _reviewController,
            decoration: const InputDecoration(
              hintText: 'Write your review (optional)',
            ),
            maxLines: 3,
            textCapitalization: TextCapitalization.sentences,
          ),
          const SizedBox(height: 24),

          ElevatedButton(
            onPressed: _isLoading ? null : _submitReview,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 44) // Make button wider
            ),
            child: _isLoading
                ? SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: colorScheme.onPrimary,
                    ),
                  )
                : Text('Submit Review', style: textTheme.labelLarge?.copyWith(color: colorScheme.onPrimary)),
          ),
        ],
      ),
    );
  }
}
