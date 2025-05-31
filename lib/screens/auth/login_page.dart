import 'package:flutter/widgets.dart'; // For Widget
import 'package:cloudkeja/services/platform_service.dart';
import 'package:cloudkeja/screens/auth/cupertino_login_page.dart';
import 'package:cloudkeja/screens/auth/login_page_material.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    if (PlatformService.useCupertino) {
      return const CupertinoLoginPage();
    } else {
      return const LoginPageMaterial();
    }
  }
}
