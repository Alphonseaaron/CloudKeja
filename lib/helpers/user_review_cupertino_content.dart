import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:provider/provider.dart';
import 'package:cloudkeja/models/review_model.dart';
import 'package:cloudkeja/providers/auth_provider.dart';
import 'package:cloudkeja/providers/post_provider.dart';

class UserReviewCupertinoContent extends StatefulWidget {
  final String spaceId;
  const UserReviewCupertinoContent({Key? key, required this.spaceId}) : super(key: key);

  @override
  State<UserReviewCupertinoContent> createState() => _UserReviewCupertinoContentState();
}

class _UserReviewCupertinoContentState extends State<UserReviewCupertinoContent> {
  double _rating = 0.0;
  final _reviewController = TextEditingController();
  String _flareAnimation = '0';
  bool _isLoading = false;
  String? _errorMessage; // For local error display

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

    if (user == null) {
      setState(() => _errorMessage = 'Please log in to submit a review.');
      return;
    }
    if (_rating == 0.0) {
      setState(() => _errorMessage = 'Please provide a rating.');
      return;
    }
     if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null; // Clear previous errors
    });

    final review = ReviewModel(
      rating: _rating,
      review: _reviewController.text.trim(),
      createdAt: Timestamp.now(),
      fullName: user.name!,
      id: FirebaseFirestore.instance.collection('dummy').doc().id,
      userId: user.userId!,
      imageUrl: user.profile,
      spaceId: widget.spaceId,
    );

    try {
      await Provider.of<PostProvider>(context, listen: false).sendRating(review);
      if (mounted) Navigator.of(context).pop(true); // Pop and indicate success
    } catch (e) {
      if (mounted) {
        setState(() => _errorMessage = 'Failed to submit review: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cupertinoTheme = CupertinoTheme.of(context);
    // Title "Leave a Rating" is expected to be part of the CupertinoAlertDialog title.
    // This widget provides the content.

    return SizedBox( // Constrain width for dialog content
      width: MediaQuery.of(context).size.width * 0.75, // Typical width for alert dialog content
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch, // Make button stretch
        children: [
          // Flare Animation
          if (FlareActor.doesExist('assets/feelings.flr'))
            SizedBox(
              height: 100,
              child: Transform.scale(
                scale: 1.8, // Adjusted scale
                child: FlareActor(
                  'assets/feelings.flr',
                  fit: BoxFit.contain,
                  animation: _flareAnimation,
                ),
              ),
            )
          else const SizedBox(height: 20),

          // Rating Bar
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Center( // Center the rating bar
              child: RatingBar.builder(
                initialRating: _rating,
                minRating: 1,
                direction: Axis.horizontal,
                allowHalfRating: true,
                itemCount: 5,
                itemPadding: const EdgeInsets.symmetric(horizontal: 3.0),
                itemBuilder: (context, _) => Icon(CupertinoIcons.star_fill, color: CupertinoColors.systemYellow),
                // For empty/half stars, flutter_rating_bar might need more config or custom painting for Cupertino style
                // For simplicity, using filled yellow for rated, and relying on its default for unrated (often greyish)
                // To be more specific:
                // empty: Icon(CupertinoIcons.star, color: CupertinoColors.systemGrey),
                // half: Icon(CupertinoIcons.star_lefthalf_fill, color: CupertinoColors.systemYellow)
                // This requires that RatingBar's RatingWidget takes separate empty/half widgets.
                // The default RatingBar.builder uses itemBuilder for all states, varying by rating.
                // The color of Icon above will apply to filled state.
                // Default unselected color of RatingBar is often grey.
                onRatingUpdate: _updateFlareAnimation,
                itemSize: 30, // Adjusted size
              ),
            ),
          ),

          // Review TextField
          CupertinoTextField(
            controller: _reviewController,
            placeholder: 'Write your review (optional)',
            maxLines: 3,
            textCapitalization: TextCapitalization.sentences,
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: CupertinoColors.tertiarySystemFill.resolveFrom(context),
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(color: CupertinoColors.systemGrey4.resolveFrom(context))
            ),
          ),
          const SizedBox(height: 20),

          if (_errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: Text(
                _errorMessage!,
                style: cupertinoTheme.textTheme.tabLabelTextStyle.copyWith(color: CupertinoColors.systemRed.resolveFrom(context)),
                textAlign: TextAlign.center,
              ),
            ),

          // Submit Button
          CupertinoButton.filled(
            onPressed: _isLoading ? null : _submitReview,
            child: _isLoading
                ? const CupertinoActivityIndicator(color: CupertinoColors.white) // White for filled button
                : const Text('Submit Review'),
          ),
          // A "Cancel" button is typically part of CupertinoAlertDialog.actions, not in the content.
        ],
      ),
    );
  }
}
