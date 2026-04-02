import 'dart:ui';
import 'package:flutter/material.dart';

class ClothingCard extends StatelessWidget {
  final String message;

  const ClothingCard({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.2),
              width: 0.5,
            ),
          ),
          child: Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white,
              height: 1.6,
              shadows: [
                Shadow(offset: Offset(0, 1), blurRadius: 4, color: Color(0x80000000)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
