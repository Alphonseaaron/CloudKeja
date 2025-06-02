import 'package:flutter/widgets.dart';
import 'package:cloudkeja/services/platform_service.dart';
import 'package:cloudkeja/models/user_model.dart'; // For UserModel parameter
import 'package:cloudkeja/screens/chat/chat_room_screen_cupertino.dart';
import 'package:cloudkeja/screens/chat/chat_room_screen_material.dart';

class ChatRoomScreenRouter extends StatelessWidget {
  final UserModel userToChatWith;
  final String chatRoomId;

  const ChatRoomScreenRouter({
    Key? key,
    required this.userToChatWith,
    required this.chatRoomId,
  }) : super(key: key);

  // Static routeName is useful if this router itself is navigated to by name,
  // and arguments are passed through a mechanism like Get.toNamed(routeName, arguments: ...)
  // Or if it's used in a route map.
  static const String routeName = '/chat_room'; // Consistent with original ChatRoom

  @override
  Widget build(BuildContext context) {
    // This router receives arguments via its constructor when instantiated directly.
    // e.g., Get.to(() => ChatRoomScreenRouter(userToChatWith: user, chatRoomId: id))
    // It then passes these arguments to the constructors of the platform-specific screens.
    if (PlatformService.useCupertino) {
      return ChatRoomScreenCupertino(user: userToChatWith, chatRoomId: chatRoomId);
    } else {
      return ChatRoomScreenMaterial(user: userToChatWith, chatRoomId: chatRoomId);
    }
  }
}
