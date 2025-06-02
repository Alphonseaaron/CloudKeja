import 'package:flutter/cupertino.dart';
import 'package:get/get.dart'; // For navigation if needed for search results
import 'package:cloudkeja/screens/search/search_results_screen.dart'; // Import Material SearchResultsScreen

class SearchScreenCupertino extends StatefulWidget {
  const SearchScreenCupertino({super.key});

  @override
  State<SearchScreenCupertino> createState() => _SearchScreenCupertinoState();
}

class _SearchScreenCupertinoState extends State<SearchScreenCupertino> {
  final TextEditingController _searchController = TextEditingController();
  List<String> _recentSearches = List.generate(4, (index) => 'Sample Recent Search ${index + 1}'); // Mock data

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchSubmitted(String value) {
    final searchTerm = value.trim();
    if (searchTerm.isNotEmpty) {
      // TODO: Update recent searches list (persisting logic)
      print('Cupertino Search Submitted: $searchTerm');
      Get.to(() => SearchResultsScreen(searchText: searchTerm)); // Navigate to Material SearchResultsScreen
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = CupertinoTheme.of(context);

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Search Properties'),
        // Optional: Add a cancel button if it makes sense for the UX flow
        // trailing: CupertinoButton(
        //   padding: EdgeInsets.zero,
        //   child: const Text('Cancel'),
        //   onPressed: () => Get.back(),
        // ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: CupertinoSearchTextField(
                controller: _searchController,
                placeholder: 'Search by location, property type...',
                autofocus: true,
                onSubmitted: _onSearchSubmitted,
              ),
            ),
            // TODO: Add a Hero widget here if a shared element transition is desired from home screen's search input
            Expanded(
              child: ListView(
                children: [
                  if (_recentSearches.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 8.0, bottom: 8.0),
                      child: Text(
                        'Recent Searches',
                        style: theme.textTheme.navTitleTextStyle.copyWith(
                          color: CupertinoColors.secondaryLabel.resolveFrom(context)
                        ),
                      ),
                    ),
                  ..._recentSearches.map((term) {
                    return CupertinoListTile(
                      leading: const Icon(CupertinoIcons.time, color: CupertinoColors.secondaryLabel),
                      title: Text(term, style: theme.textTheme.textStyle),
                      trailing: const Icon(CupertinoIcons.chevron_up_chevron_down, color: CupertinoColors.tertiaryLabel), // Icon to suggest 'fill search bar'
                      onTap: () {
                        _searchController.text = term;
                        // Optionally trigger search submission directly:
                        // _onSearchSubmitted(term);
                      },
                    );
                  }).toList(),
                  // Add a small spacer at the bottom if needed
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
