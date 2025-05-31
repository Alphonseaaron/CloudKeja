import 'package:flutter/widgets.dart'; // For Widget
import 'package:cloudkeja/services/platform_service.dart';
import 'package:cloudkeja/screens/auth/cupertino_register_page.dart';
import 'package:cloudkeja/screens/auth/register_page_material.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    if (PlatformService.useCupertino) {
      return const CupertinoRegisterPage();
    } else {
      return const RegisterPageMaterial();
    }
  }
}
