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
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.25),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.15),
              width: 0.5,
            ),
          ),
          child: Column(
            children: [
              const Icon(
                Icons.checkroom,
                color: Color(0xCCFFFFFF),
                size: 20,
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 15,
                  color: Color(0xF0FFFFFF),
                  height: 1.6,
                  shadows: [
                    Shadow(
                        offset: Offset(0, 1),
                        blurRadius: 6,
                        color: Color(0xAA000000)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
