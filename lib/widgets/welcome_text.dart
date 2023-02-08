import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:provider/provider.dart';
import 'package:cloudkeja/providers/auth_provider.dart';

import '../screens/chat/chat_screen.dart';

class WelcomeText extends StatelessWidget {
  const WelcomeText({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Hello ${user != null ? user.name!.split(' ')[0] : 'User'}',
                style: Theme.of(context).textTheme.bodyText1!.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              // IconButton(
              //   onPressed: () {
              //     Get.to(() => const ChatScreen());
              //   },
              //   icon: const Icon(CupertinoIcons.text_bubble),
              // ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Find your perfect space',
            style: Theme.of(context).textTheme.headline1!.copyWith(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }
}
