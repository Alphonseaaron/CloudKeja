import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/route_manager.dart';
import 'package:cloudkeja/screens/search/search_results_screen.dart';

class SearchScreenMaterial extends StatefulWidget { // Changed to StatefulWidget
  const SearchScreenMaterial({Key? key}) : super(key: key);

  @override
  State<SearchScreenMaterial> createState() => _SearchScreenMaterialState();
}

class _SearchScreenMaterialState extends State<SearchScreenMaterial> { // Added State class
  late TextEditingController _searchController;
  // Mock data for recent searches, similar to Cupertino version for consistency
  final List<String> _recentSearches = List.generate(4, (index) => 'Sample Recent Search M ${index + 1}');

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final inputDecorationTheme = theme.inputDecorationTheme;


    return Scaffold(
      backgroundColor: colorScheme.background, // Themed background
      appBar: AppBar( // Added AppBar
        title: const Text("Search Properties"),
        elevation: 0, // Optional: for a flatter look
        // backgroundColor: colorScheme.background, // Optional: if specific color needed
      ),
      body: SafeArea( // Add SafeArea
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 12.0), // Padding for the ListView
          children: [
            Hero(
              tag: 'textfield', // This tag should match the one in search_input.dart
              transitionOnUserGestures: true,
              // Wrap with Material to provide a consistent background for the Hero animation
              // if the source (search_input) has a different background than the destination (TextFormField here).
              child: Material(
                type: MaterialType.transparency, // Avoid double backgrounds
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: TextFormField(
                    controller: _searchController, // Use controller
                    autofocus: true, 
                    onFieldSubmitted: (val) {
                      if (val.trim().isNotEmpty) {
                        // TODO: Update recent searches list (persisting logic)
                        Get.to(() => SearchResultsScreen(searchText: val.trim()));
                      }
                    },
                    decoration: InputDecoration(
                      // fillColor, filled, border, contentPadding will come from inputDecorationTheme
                      hintText: 'Search by location, property type...',
                      prefixIcon: Padding( // Adjusted padding for prefix icon
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
                      // Suffix icon for clearing search (optional)
                      // suffixIcon: IconButton(
                      //   icon: Icon(Icons.clear, color: colorScheme.onSurfaceVariant),
                      //   onPressed: () { /* Clear text field */ },
                      // ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Recent Searches',
                style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 8),
            // Removed Image.asset('assets/images/accent.png')
            // Using a simple Divider or nothing if section title is enough
            // Divider(height: 1, thickness: 1, indent: 16, endIndent: 16, color: colorScheme.outline.withOpacity(0.5)),

            // Placeholder ListTiles for recent searches
            ..._recentSearches.map((term) { // Use _recentSearches list
              return ListTile(
                leading: Icon(Icons.history_outlined, color: colorScheme.onSurfaceVariant.withOpacity(0.8)),
                title: Text(term, style: textTheme.bodyMedium),
                trailing: Icon(Icons.north_west_outlined, color: colorScheme.onSurfaceVariant.withOpacity(0.8)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 0),
                onTap: () {
                  _searchController.text = term;
                  _searchController.selection = TextSelection.fromPosition(TextPosition(offset: term.length)); // Move cursor to end
                  // Optionally trigger search directly:
                  // if (term.trim().isNotEmpty) {
                  //   Get.to(() => SearchResultsScreen(searchText: term.trim()));
                  // }
                },
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}
