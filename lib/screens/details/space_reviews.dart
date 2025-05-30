import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
// import 'package:cloudkeja/helpers/my_ratings.dart'; // Assuming MyRatings will be replaced
import 'package:cloudkeja/models/review_model.dart';
import 'package:skeletonizer/skeletonizer.dart'; // For loading state

class SpaceReviews extends StatelessWidget {
  const SpaceReviews({Key? key, required this.spaceId}) : super(key: key);
  final String spaceId;

  Widget _buildRatingStars(BuildContext context, double rating, {double size = 16.0}) {
    final theme = Theme.of(context);
    // Using primary color for stars, but Colors.amber is also common and acceptable.
    final starColor = theme.colorScheme.primary;
    List<Widget> stars = [];
    int fullStars = rating.floor();
    bool halfStar = (rating - fullStars) >= 0.5;

    for (int i = 0; i < 5; i++) {
      if (i < fullStars) {
        stars.add(Icon(Icons.star, color: starColor, size: size));
      } else if (i == fullStars && halfStar) {
        stars.add(Icon(Icons.star_half, color: starColor, size: size));
      } else {
        stars.add(Icon(Icons.star_border, color: starColor.withOpacity(0.7), size: size));
      }
    }
    return Row(mainAxisSize: MainAxisSize.min, children: stars);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('spaces/$spaceId/reviews')
          .orderBy('createdAt', descending: true) // Show newest reviews first
          .snapshots(),
      builder: (ctx, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Skeleton for reviews list
          return Skeletonizer(
            enabled: true,
            effect: ShimmerEffect(
              baseColor: colorScheme.surfaceVariant.withOpacity(0.4),
              highlightColor: colorScheme.surfaceVariant.withOpacity(0.8),
            ),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              itemCount: 3, // Number of skeleton items
              itemBuilder: (context, index) => _ReviewTileSkeleton(theme: theme),
              separatorBuilder: (context, index) => Divider(indent: 16, endIndent: 16, height: 1, color: colorScheme.outline.withOpacity(0.2)),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
            child: Center(
              child: Text(
                'No reviews yet for this space.',
                style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface.withOpacity(0.7)),
              ),
            ),
          );
        }

        List<DocumentSnapshot> docs = snapshot.data!.docs;

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(), // If inside another scroll view
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0), // Standard padding
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final review = ReviewModel.fromJson(docs[index]);
            return ReviewTile(review: review, buildRatingStars: _buildRatingStars);
          },
          separatorBuilder: (context, index) => Divider(
            indent: 16, // Indent if avatar is present, or full width
            endIndent: 16,
            height: 1, // Standard divider height
            color: colorScheme.outline.withOpacity(0.2), // Themed divider color
          ),
        );
      },
    );
  }
}

class ReviewTile extends StatelessWidget {
  final ReviewModel review;
  final Widget Function(BuildContext context, double rating, {double size}) buildRatingStars;

  const ReviewTile({
    Key? key,
    required this.review,
    required this.buildRatingStars,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0), // Padding for each review item
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 22, // Standard avatar size
            backgroundImage: (review.imageUrl != null && review.imageUrl!.isNotEmpty)
                ? CachedNetworkImageProvider(review.imageUrl!)
                : null,
            backgroundColor: colorScheme.surfaceVariant,
            child: (review.imageUrl == null || review.imageUrl!.isEmpty)
                ? Icon(Icons.person_outline, color: colorScheme.onSurfaceVariant)
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  review.fullName ?? 'Anonymous User',
                  style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    buildRatingStars(context, review.rating ?? 0.0, size: 16.0),
                    const Spacer(),
                    Text(
                      review.createdAt != null
                          ? DateFormat('dd MMM yyyy').format(review.createdAt!.toDate())
                          : '', // Handle null date
                      style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurface.withOpacity(0.6)),
                    )
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  review.review ?? 'No comment provided.',
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.85),
                    height: 1.4, // Improved line height
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}

// Helper widget for skeleton loading of a single review tile
class _ReviewTileSkeleton extends StatelessWidget {
  final ThemeData theme;
  const _ReviewTileSkeleton({Key? key, required this.theme}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CircleAvatar(radius: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(height: 14, width: 100, color: Colors.transparent), // Name
                const SizedBox(height: 6),
                Container(height: 12, width: 80, color: Colors.transparent), // Rating
                const SizedBox(height: 8),
                Container(height: 12, width: double.infinity, color: Colors.transparent), // Review line 1
                const SizedBox(height: 4),
                Container(height: 12, width: MediaQuery.of(context).size.width * 0.5, color: Colors.transparent), // Review line 2
              ],
            ),
          )
        ],
      ),
    );
  }
}
