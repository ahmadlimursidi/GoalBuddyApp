import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class LottieAnimationWidget extends StatelessWidget {
  final String animationPath;
  final double width;
  final double height;
  final bool repeat;
  final bool reverse;

  const LottieAnimationWidget({
    super.key,
    required this.animationPath,
    this.width = 300,
    this.height = 300,
    this.repeat = true,
    this.reverse = false,
  });

  @override
  Widget build(BuildContext context) {
    return Lottie.asset(
      animationPath,
      width: width,
      height: height,
      fit: BoxFit.fill,
      repeat: repeat,
      reverse: reverse,
    );
  }
}

// Example widget for drill session animations
class DrillAnimationWidget extends StatelessWidget {
  final String drillName;
  final String animationPath;
  final bool showTitle;

  const DrillAnimationWidget({
    super.key,
    required this.drillName,
    required this.animationPath,
    this.showTitle = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showTitle)
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Text(
              drillName,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        Lottie.asset(
          animationPath,
          width: 200,
          height: 200,
          fit: BoxFit.fill,
        ),
      ],
    );
  }
}