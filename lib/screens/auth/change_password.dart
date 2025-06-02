import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:cloudkeja/services/platform_service.dart';
import 'package:cloudkeja/screens/auth/change_password_material.dart';
import 'package:cloudkeja/screens/auth/change_password_cupertino.dart';

class ChangePassword extends StatelessWidget {
  static const routeName = '/change-password'; // Keep routeName here for the router

  const ChangePassword({Key? key}) : super(key: key); // Added constructor

  @override
  Widget build(BuildContext context) {
    final platformService = Provider.of<PlatformService>(context, listen: false);

    if (platformService.useCupertino) {
      return ChangePasswordCupertino();
    } else {
      return ChangePasswordMaterial();
    }
  }
}
