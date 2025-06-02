import 'package:flutter/widgets.dart';
import 'package:cloudkeja/services/platform_service.dart';
import 'package:cloudkeja/screens/admin/all_users_screen_cupertino.dart';
import 'package:cloudkeja/screens/admin/all_users_screen_material.dart';

class AllUsersScreenRouter extends StatelessWidget {
  const AllUsersScreenRouter({Key? key}) : super(key: key);

  static const String routeName = '/admin/all_users'; 

  @override
  Widget build(BuildContext context) {
    if (PlatformService.useCupertino) {
      return const AllUsersScreenCupertino();
    } else {
      return const AllUsersScreenMaterial();
    }
  }
}
