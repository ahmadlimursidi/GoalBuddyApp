import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class LottieLoadingWidget extends StatelessWidget {
  final double width;
  final double height;
  final Color? color;
  final String? animationUrl;

  const LottieLoadingWidget({
    Key? key,
    this.width = 100,
    this.height = 100,
    this.color,
    this.animationUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Lottie.asset(
      animationUrl ?? 'assets/animations/loading.json',
      width: width,
      height: height,
      fit: BoxFit.contain,
      repeat: true,
      animate: true,
      errorBuilder: (context, error, stackTrace) {
        // Fallback to a simple spinner if the animation fails to load
        return SizedBox(
          width: width,
          height: height,
          child: CircularProgressIndicator(
            valueColor: color != null ? AlwaysStoppedAnimation<Color>(color!) : null,
          ),
        );
      },
    );
  }
}