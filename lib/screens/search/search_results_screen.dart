import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/route_manager.dart';
import 'package:provider/provider.dart';
import 'package:cloudkeja/helpers/loading_effect.dart'; // Themed loading effect
import 'package:cloudkeja/models/space_model.dart';
import 'package:cloudkeja/providers/post_provider.dart';
import 'package:cloudkeja/screens/search/search_screen.dart';
import 'package:cloudkeja/widgets/space_tile.dart'; // Renamed from SpacerTile to SpaceTile if that was the case, or ensure correct import
import 'package:skeletonizer/skeletonizer.dart'; // For skeleton loading of results

class SearchResultsScreen extends StatelessWidget {
  final String searchText;

  const SearchResultsScreen({Key? key, required this.searchText}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final inputDecorationTheme = theme.inputDecorationTheme;

    return Scaffold(
      backgroundColor: colorScheme.background, // Themed background
      // AppBar can be added if needed, e.g., to show the search query or allow modification
      appBar: AppBar(
        title: Text('Results for "$searchText"', style: textTheme.titleMedium),
        // leading: IconButton(icon: Icon(Icons.arrow_back), onPressed: () => Get.back()), // Get.back() is default
      ),
      body: SafeArea( // Added SafeArea
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Non-interactive display of the search query, consistent with SearchScreen's field
            // This Hero widget's tag must match the source for the animation.
            Hero(
              tag: 'textfield', // Ensure this tag matches the source Hero widget tag
              transitionOnUserGestures: true,
              child: Material( // Wrap with Material for consistent Hero animation background
                type: MaterialType.transparency,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: AbsorbPointer( // Makes the TextFormField non-interactive
                    child: TextFormField(
                      initialValue: searchText,
                      enabled: false, // Visually disabled but shows text
                      decoration: InputDecoration(
                        // fillColor, filled, border, contentPadding from inputDecorationTheme
                        // hintText: 'Search here...', // Not needed as initialValue is set
                        prefixIcon: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          child: SvgPicture.asset(
                            'assets/icons/search.svg',
                            colorFilter: ColorFilter.mode(
                              inputDecorationTheme.hintStyle?.color ?? colorScheme.onSurfaceVariant,
                              BlendMode.srcIn,
                            ),
                            width: 20,
                            height: 20,
                          ),
                        ),
                        // To make it look more like a display field rather than interactive
                        disabledBorder: inputDecorationTheme.border ?? OutlineInputBorder(borderSide: BorderSide.none),
                      ),
                      style: textTheme.bodyLarge, // Ensure text inside is styled
                    ),
                  ),
                ),
              ),
            ),
            
            // Search results list
            Expanded(
              child: FutureBuilder<List<SpaceModel>>(
                future: Provider.of<PostProvider>(context, listen: false).searchSpaces(searchText),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    // Use Skeletonizer for the list items
                    return Skeletonizer(
                      enabled: true,
                       effect: ShimmerEffect(
                        baseColor: colorScheme.surfaceVariant.withOpacity(0.4),
                        highlightColor: colorScheme.surfaceVariant.withOpacity(0.8),
                      ),
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16.0), // Standard padding
                        itemCount: 5, // Number of skeleton items
                        itemBuilder: (context, index) => Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          // Use a generic card skeleton that SpaceTile would roughly match
                          child: Card(child: SizedBox(height: 100, child: Center(child: Text("Loading...", style: textTheme.bodySmall)))),
                          // Or, if SpaceTile has an empty constructor for skeleton:
                          // child: SpaceTile(space: SpaceModel.empty()), 
                        ),
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text('Error: ${snapshot.error}', style: textTheme.bodyMedium?.copyWith(color: colorScheme.error)),
                      ),
                    );
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          'No results found for "$searchText".\nTry a different search term.',
                          textAlign: TextAlign.center,
                          style: textTheme.bodyLarge?.copyWith(color: colorScheme.onSurface.withOpacity(0.7)),
                        ),
                      ),
                    );
                  }
                  
                  // Display results using the themed SpaceTile
                  return ListView.builder(
                    padding: const EdgeInsets.all(16.0), // Standard padding for the list
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      // SpaceTile was already refactored to be theme-aware.
                      // Its margin is handled internally now.
                      return SpaceTile(space: snapshot.data![index]);
                    },
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}

// Ensure SpaceModel.empty() is available if used for skeletonizer with SpaceTile
// extension EmptySpaceModelForSearchResults on SpaceModel {
//   static SpaceModel empty() {
//     return SpaceModel(
//       id: 'skeleton_search_result',
//       spaceName: 'Loading Space Name...',
//       address: 'Loading address...',
//       price: 0.0,
//       images: ['https://via.placeholder.com/100/F0F0F0/AAAAAA?text=Loading...'],
//       description: 'Loading description...',
//       isAvailable: true,
//       ownerId: 'skeleton_owner',
//       category: 'skeleton_category',
//     );
//   }
// }
