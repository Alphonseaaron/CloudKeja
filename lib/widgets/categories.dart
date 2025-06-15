import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:cloudkeja/services/platform_service.dart';
import 'package:cloudkeja/widgets/categories_material.dart';
import 'package:cloudkeja/widgets/categories_cupertino.dart';

// Renamed original Categories to CategoriesRouter to act as the router
class CategoriesRouter extends StatelessWidget {
  const CategoriesRouter({Key? key}) : super(key: key);

  // If an onCategorySelected callback were needed, it would be added here:
  // final Function(String category)? onCategorySelected;
  // const CategoriesRouter({Key? key, this.onCategorySelected}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final platformService = Provider.of<PlatformService>(context, listen: false);

    if (platformService.useCupertino) {
      return const CategoriesCupertino(
        key: key, // Pass key
        // onCategorySelected: onCategorySelected, // Pass callback if it existed
      );
    } else {
      return const CategoriesMaterial(
        key: key, // Pass key
        // onCategorySelected: onCategorySelected, // Pass callback if it existed
      );
    }
  }
}
