import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart'; // Added for Cupertino
import 'package:provider/provider.dart'; // Added for Provider
import 'package:cloudkeja/services/platform_service.dart'; // Added for PlatformService
import 'package:cloudkeja/helpers/my_shimmer.dart';

class ChatTileShimmer extends StatelessWidget {
  const ChatTileShimmer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final platformService = Provider.of<PlatformService>(context, listen: false);
    final bool isCupertino = platformService.useCupertino;

    Color placeholderColor;
    if (isCupertino) {
      placeholderColor = CupertinoColors.systemGrey5.resolveFrom(context);
    } else {
      placeholderColor = Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.7);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10), // Adjusted vertical padding
      child: Row(
        children: [
          MyShimmer( // MyShimmer should ideally also adapt its base/highlight colors or be transparent
            child: CircleAvatar(
              radius: 24,
              backgroundColor: placeholderColor, // Applied platform-adaptive color
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MyShimmer(
                child: Container(
                  height: 20,
                  width: size.width * 0.6,
                  decoration: BoxDecoration( // Using decoration for rounded corners
                    color: placeholderColor, // Applied platform-adaptive color
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(
                height: 8, // Adjusted spacing
              ),
              MyShimmer(
                child: Container(
                  height: 15,
                  width: size.width * 0.4,
                   decoration: BoxDecoration(
                    color: placeholderColor, // Applied platform-adaptive color
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ],
          ))
        ],
      ),
    );
  }
}
