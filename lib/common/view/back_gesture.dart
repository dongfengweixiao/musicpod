// Code by @whiskeyPeak

import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';
import 'package:yaru/icons.dart';

import '../../library/library_model.dart';

const double _kButtonSize = 50;
const double _kMaxExtent = 800;

class BackGesture extends StatefulWidget {
  final Widget child;

  const BackGesture({
    super.key,
    required this.child,
  });

  @override
  State<BackGesture> createState() => _BackGestureState();
}

class _BackGestureState extends State<BackGesture>
    with SingleTickerProviderStateMixin {
  late AnimationController swipeBackController;

  double xPosition = 0;
  double yPosition = 0;

  double currentExtent = 0;

  bool isVisible = false;

  @override
  void initState() {
    super.initState();
    swipeBackController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    )..addListener(() {
        xPosition -= (xPosition + _kButtonSize) * swipeBackController.value;
      });
  }

  @override
  void dispose() {
    swipeBackController.dispose();
    super.dispose();
  }

  void onPanUpdate(DragUpdateDetails details) {
    if (details.delta.dx > 0 &&
        details.delta.dy < 50 &&
        details.delta.dy > -50 &&
        currentExtent + details.delta.dx <= _kMaxExtent) {
      currentExtent += details.delta.dx;
      setState(() {
        xPosition += details.delta.dx * 0.2;
      });
    }
    if (details.delta.dx < 0 &&
        details.delta.dy < 50 &&
        details.delta.dy > -50 &&
        currentExtent - details.delta.dx >= -_kButtonSize) {
      currentExtent -= -details.delta.dx;
      setState(() {
        xPosition -= -details.delta.dx * 0.2;
      });
    }
  }

  void onPanStart(DragStartDetails details, BoxConstraints constraints) {
    swipeBackController.reset();
    currentExtent = 0;
    xPosition = 0 - _kButtonSize;
    yPosition = (constraints.maxHeight - _kButtonSize) / 2;
    setState(() {
      isVisible = true;
    });
  }

  void onPanEnd(DragEndDetails details) {
    swipeBackController.forward().whenComplete(() {
      swipeBackController.reset();
      setState(() {
        isVisible = false;
      });
    });
    if (currentExtent > (_kMaxExtent / 2)) {
      di<LibraryModel>().pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return GestureDetector(
          behavior: HitTestBehavior.translucent,
          onPanUpdate: onPanUpdate,
          onPanStart: (details) => onPanStart(details, constraints),
          onPanEnd: onPanEnd,
          child: Stack(
            children: <Widget>[
              widget.child,
              AnimatedBuilder(
                animation: swipeBackController,
                builder: (BuildContext context, Widget? child) {
                  return Positioned(
                    top: yPosition,
                    left: xPosition,
                    child: Visibility(
                      visible: isVisible,
                      child: SizedBox(
                        width: _kButtonSize,
                        height: _kButtonSize,
                        child: OutlinedButton(
                          onPressed: () {},
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.zero,
                            backgroundColor:
                                Theme.of(context).brightness == Brightness.light
                                    ? Colors.grey[100]
                                    : Colors.grey[900],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(_kButtonSize),
                            ),
                          ),
                          child: const Icon(
                            YaruIcons.go_previous,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
