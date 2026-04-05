import 'package:flutter/material.dart';
import '../config/constants.dart';

class WeatherBackground extends StatelessWidget {
  final String imagePath;

  const WeatherBackground({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: AppConstants.imageFadeDuration,
      child: Image.asset(
        imagePath,
        key: ValueKey(imagePath),
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        alignment: Alignment.center,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: const Color(0xFF1A1A2E),
            child: const Center(
              child: Icon(Icons.cloud_off, color: Colors.white38, size: 64),
            ),
          );
        },
      ),
    );
  }
}
