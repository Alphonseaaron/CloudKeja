import 'package:flutter/material.dart'; // Needed for StatelessWidget
import 'package:flutter/cupertino.dart'; // For Cupertino specific widgets if needed by router directly
import 'package:provider/provider.dart';
import 'package:cloudkeja/services/platform_service.dart';
import 'package:cloudkeja/widgets/custom_material_bottom_navigation_bar.dart';
import 'package:cloudkeja/widgets/custom_cupertino_bottom_navigation_bar.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onItemSelected;

  const CustomBottomNavigationBar({
    Key? key,
    required this.currentIndex,
    required this.onItemSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final platformService = Provider.of<PlatformService>(context, listen: false);

    if (platformService.useCupertino) {
      return CustomCupertinoBottomNavigationBar(
        currentIndex: currentIndex,
        onTap: onItemSelected, // Pass to onTap for CupertinoTabBar
      );
    } else {
      return CustomMaterialBottomNavigationBar(
        currentIndex: currentIndex,
        onDestinationSelected: onItemSelected, // Pass to onDestinationSelected for NavigationBar
      );
    }
  }
}
