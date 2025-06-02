import 'package:flutter/widgets.dart';
import 'package:cloudkeja/services/platform_service.dart';
import 'package:cloudkeja/screens/chat/chat_screen_cupertino.dart';
import 'package:cloudkeja/screens/chat/chat_screen_material.dart';

class ChatScreenRouter extends StatelessWidget {
  const ChatScreenRouter({Key? key}) : super(key: key);

  static const String routeName = '/chats_router'; // Using plural for consistency if others are plural

  @override
  Widget build(BuildContext context) {
    if (PlatformService.useCupertino) {
      return const ChatScreenCupertino();
    } else {
      return const ChatScreenMaterial();
    }
  }
}
