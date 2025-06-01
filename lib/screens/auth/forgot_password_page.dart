import 'package:flutter/widgets.dart';
import 'package:cloudkeja/services/platform_service.dart';
import 'package:cloudkeja/screens/auth/cupertino_forgot_password_page.dart';
import 'package:cloudkeja/screens/auth/forgot_password_page_material.dart';

class ForgotPasswordPage extends StatelessWidget {
  const ForgotPasswordPage({super.key});

  static const String routeName = '/forgot-password'; // Optional route name

  @override
  Widget build(BuildContext context) {
    if (PlatformService.useCupertino) {
      return const CupertinoForgotPasswordPage();
    } else {
      return const ForgotPasswordPageMaterial();
    }
  }
}
