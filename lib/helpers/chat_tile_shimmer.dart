import 'package:flutter/material.dart';
import 'package:cloudkeja/helpers/my_shimmer.dart';

class ChatTileShimmer extends StatelessWidget {
  const ChatTileShimmer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      child: Row(
        children: [
          const MyShimmer(
            child: CircleAvatar(
              radius: 24,
              backgroundColor: Colors.grey,
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
                  color: Colors.grey,
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              MyShimmer(
                child: Container(
                  height: 15,
                  width: size.width * 0.4,
                  color: Colors.grey,
                ),
              ),
            ],
          ))
        ],
      ),
    );
  }
}
