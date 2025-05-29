import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// import 'package:cloudkeja/helpers/loading_effect.dart'; // Will be replaced by Skeletonizer
import 'package:cloudkeja/models/space_model.dart';
import 'package:cloudkeja/providers/post_provider.dart';
import 'package:cloudkeja/widgets/recommended_house.dart';
import 'package:cloudkeja/widgets/custom_app_bar.dart';
import 'package:cloudkeja/widgets/search_input.dart';
import 'package:cloudkeja/widgets/welcome_text.dart';
import 'package:cloudkeja/widgets/categories.dart';
import 'package:cloudkeja/widgets/best_offer.dart';
import 'package:skeletonizer/skeletonizer.dart'; // Import skeletonizer

class Home extends StatefulWidget { // Changed to StatefulWidget for managing loading state with Skeletonizer
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late Future<List<SpaceModel>> _spacesFuture;
  bool _isLoading = true; // Manage skeletonizer state

  @override
  void initState() {
    super.initState();
    _spacesFuture = Provider.of<PostProvider>(context, listen: false).getSpaces();
    _spacesFuture.then((_) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }).catchError((_) {
       if (mounted) {
        setState(() {
          _isLoading = false; // Also stop loading on error to show error message or empty state
        });
      }
    });
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Define a placeholder list of spaces for skeletonizer
    // This helps skeletonizer build appropriate number of shimmer items
    final _mockSpaces = List.generate(3, (index) => SpaceModel.empty());


    return Scaffold(
      backgroundColor: colorScheme.background, // Use themed background
      appBar: const CustomAppBar(), // Already refactored
      body: Skeletonizer(
        enabled: _isLoading,
        effect: ShimmerEffect( // Configure shimmer effect using theme colors
          baseColor: colorScheme.surfaceVariant.withOpacity(0.4),
          highlightColor: colorScheme.surfaceVariant.withOpacity(0.8),
        ),
        child: RefreshIndicator( // Added RefreshIndicator for pull-to-refresh
          onRefresh: () async {
            if (mounted) {
              setState(() { _isLoading = true; });
            }
            // Re-fetch data
            _spacesFuture = Provider.of<PostProvider>(context, listen: false).getSpaces(forceRefresh: true);
            try {
              await _spacesFuture;
            } finally {
              if (mounted) {
                setState(() { _isLoading = false; });
              }
            }
          },
          child: ListView( // Changed to ListView for better structure and pull-to-refresh
            children: [
              const WelcomeText(), // Already refactored
              const SearchInput(), // Already refactored
              
              _buildSectionTitle(context, 'Categories'),
              const Categories(), // Already refactored
              
              _buildSectionTitle(context, 'Recommended For You'),
              FutureBuilder<List<SpaceModel>>(
                future: _spacesFuture,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}', style: TextStyle(color: colorScheme.error)));
                  }
                  // When loading, Skeletonizer handles the visual.
                  // When data is available (or future is resolved), show RecommendedHouse.
                  // If using Skeletonizer's built-in future handling is not desired,
                  // then _isLoading will control the Skeletonizer's enabled state.
                  return RecommendedHouse(
                    spaces: _isLoading ? _mockSpaces : (snapshot.data ?? _mockSpaces),
                  );
                },
              ),
              
              _buildSectionTitle(context, 'Best Offers'),
              FutureBuilder<List<SpaceModel>>(
                future: _spacesFuture,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    // This error is already handled by the above FutureBuilder if it's the same future.
                    // If it's a different future, this specific error handling would be needed.
                    return const SizedBox.shrink(); // Or specific error display for this section
                  }
                  return BestOffer(
                     spaces: _isLoading ? _mockSpaces : (snapshot.data ?? _mockSpaces),
                  );
                },
              ),
              const SizedBox(height: 20), // Bottom padding
            ],
          ),
        ),
      ),
    );
  }
}

// Extension for SpaceModel to create an empty model for skeletonizer
extension EmptySpaceModel on SpaceModel {
  static SpaceModel empty() {
    return SpaceModel(
      id: 'skeleton', // Unique ID for skeleton items
      spaceName: 'Loading Space Name...',
      address: 'Loading address...',
      price: 0.0,
      images: ['https://via.placeholder.com/230x300/F0F0F0/AAAAAA?text=Loading...'], // Placeholder image
      // Initialize other required fields with default/placeholder values
      description: 'Loading description...',
      isAvailable: true,
      ownerId: 'skeleton_owner',
      category: 'skeleton_category',
      // Add any other non-nullable fields here
    );
  }
}
