import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:cloudkeja/services/platform_service.dart';
import 'package:cloudkeja/screens/search/search_results_screen_material.dart';
import 'package:cloudkeja/screens/search/search_results_screen_cupertino.dart';

class SearchResultsScreenRouter extends StatelessWidget {
  final String searchText;
  // final PropertyFilterStateModel? initialFilters; // If needed in future

  const SearchResultsScreenRouter({
    Key? key,
    required this.searchText,
    // this.initialFilters,
  }) : super(key: key);

  // static const String routeName = '/search-results'; // Optional

  @override
  Widget build(BuildContext context) {
    final platformService = Provider.of<PlatformService>(context, listen: false);

    if (platformService.useCupertino) {
      return SearchResultsScreenCupertino(
        key: key, // Pass key
        searchText: searchText,
        // initialFilters: initialFilters, // Pass if used
      );
    } else {
      return SearchResultsScreenMaterial(
        key: key, // Pass key
        searchText: searchText,
        // initialFilters: initialFilters, // Pass if used
      );
    }
  }
}
