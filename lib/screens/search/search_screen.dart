import 'package:flutter/widgets.dart';
import 'package:cloudkeja/services/platform_service.dart';
import 'package:cloudkeja/screens/search/search_screen_cupertino.dart'; // This file will be created in the next step
import 'package:cloudkeja/screens/search/search_screen_material.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  // Optional: Add a static routeName if direct navigation is needed
  // static const String routeName = '/search';

  @override
  Widget build(BuildContext context) {
    if (PlatformService.useCupertino) {
      // TODO: Point to SearchScreenCupertino once it's created
      // For now, to avoid errors, it can temporarily point to Material or a placeholder
      return const SearchScreenCupertino(); // Placeholder removed
    } else {
      return const SearchScreenMaterial();
    }
  }
}
