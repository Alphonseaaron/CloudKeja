import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';

import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:cloudkeja/helpers/cached_image.dart';
import 'package:cloudkeja/helpers/constants.dart';
import 'package:cloudkeja/helpers/full_screen_image.dart';
import 'package:cloudkeja/providers/auth_provider.dart';
import 'dart:ui' as ui;

import 'package:cloudkeja/models/message_model.dart';

class ChatBubble extends StatelessWidget {
  final MessageModel message;
  const ChatBubble(this.message, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    final uid = Provider.of<AuthProvider>(context).user!.userId;

    return Row(
      mainAxisAlignment: uid == message.senderId
          ? MainAxisAlignment.end
          : MainAxisAlignment.start,
      children: [
        if (message.mediaUrl!.isEmpty)
          Container(
            margin: const EdgeInsets.symmetric(vertical: 7.5),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            constraints: BoxConstraints(maxWidth: size.width * 0.8),
            child: ClipRRect(
              borderRadius: uid == message.senderId
                  ? const BorderRadius.only(
                      topLeft: Radius.circular(15),
                      bottomLeft: Radius.circular(15),
                      bottomRight: Radius.circular(15),
                    )
                  : const BorderRadius.only(
                      bottomLeft: Radius.circular(15),
                      topRight: Radius.circular(15),
                      bottomRight: Radius.circular(15),
                    ),
              child: BubbleBackground(
                colors: myColors
                    .map((e) => message.senderId == uid ? e : Colors.grey)
                    .toList(),
                child: DefaultTextStyle.merge(
                  style: const TextStyle(
                    fontSize: 18.0,
                    color: Colors.white,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Stack(
                      children: [
                        Container(
                          margin: const EdgeInsets.fromLTRB(0, 0, 40, 10),
                          child: Text(
                            message.message!,
                            style: const TextStyle(
                                color: Colors.white, fontSize: 15),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Text(
                              DateFormat('HH:mm')
                                  .format(message.sentAt!.toDate()),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              )),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        if (message.mediaUrl!.isNotEmpty)
          GestureDetector(
            onTap: () {
              Get.to(() => FullscreenImage(image: message.mediaUrl!));
            },
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 7.5, horizontal: 10),
              constraints: BoxConstraints(
                maxWidth: size.width * 0.6,
                maxHeight: size.height * 0.5,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Stack(
                  children: [
                    cachedImage(
                      message.mediaUrl!,
                    ),
                    Positioned(
                      bottom: 5,
                      right: 8,
                      child: Text(
                          DateFormat('HH:mm').format(message.sentAt!.toDate()),
                          style: TextStyle(
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                color: Colors.grey[500]!,
                                blurRadius: 2,
                              )
                            ],
                            fontSize: 12,
                          )),
                    )
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

@immutable
class BubbleBackground extends StatelessWidget {
  const BubbleBackground({
    Key? key,
    required this.colors,
    this.child,
  }) : super(key: key);

  final List<Color> colors;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: BubblePainter(
        scrollable: Scrollable.of(context)!,
        bubbleContext: context,
        colors: colors,
      ),
      child: child,
    );
  }
}

class BubblePainter extends CustomPainter {
  BubblePainter({
    @required ScrollableState? scrollable,
    @required BuildContext? bubbleContext,
    @required List<Color>? colors,
  })  : _scrollable = scrollable!,
        _bubbleContext = bubbleContext!,
        _colors = colors!,
        super(repaint: scrollable.position);

  final ScrollableState _scrollable;
  final BuildContext _bubbleContext;
  final List<Color> _colors;

  @override
  void paint(Canvas canvas, Size size) {
    final scrollableBox = _scrollable.context.findRenderObject() as RenderBox;
    final scrollableRect = Offset.zero & scrollableBox.size;
    final bubbleBox = _bubbleContext.findRenderObject() as RenderBox;

    final origin =
        bubbleBox.localToGlobal(Offset.zero, ancestor: scrollableBox);
    final paint = Paint()
      ..shader = ui.Gradient.linear(
        scrollableRect.topCenter,
        scrollableRect.bottomCenter,
        _colors,
        [
          0.0,
          0.1,
          0.2,
          0.4,
          1.0,
          1.1,
          1.3,
          1.4,
          1.6,
          1.8,
          1.0,
        ],
        TileMode.clamp,
        Matrix4.translationValues(-origin.dx, -origin.dy, 0.0).storage,
      );
    canvas.drawRect(Offset.zero & size, paint);
  }

  @override
  bool shouldRepaint(BubblePainter oldDelegate) {
    return oldDelegate._scrollable != _scrollable ||
        oldDelegate._bubbleContext != _bubbleContext ||
        oldDelegate._colors != _colors;
  }
}

List<Color> myColors = [
  kPrimaryColor,
  kPrimaryColor.withOpacity(0.8),
  kPrimaryColor.withOpacity(0.6),
  kPrimaryColor.withOpacity(0.4),
  kPrimaryColor.withOpacity(0.2),
  const Color(0xff64149b),
  const Color(0xff73178c),
  const Color(0xff971e68),
  const Color(0xffc0263f),
  const Color(0xffdb2c24),
  const Color(0xfffe3301),
];
