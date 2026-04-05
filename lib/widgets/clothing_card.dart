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
          height: 120,
          padding: const EdgeInsets.only(left: 20, top: 14, bottom: 14),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.15),
              width: 0.5,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: ShaderMask(
                  shaderCallback: (Rect bounds) {
                    return const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Colors.white, Colors.white, Colors.transparent],
                      stops: [0.0, 0.08, 0.9, 1.0],
                    ).createShader(bounds);
                  },
                  blendMode: BlendMode.dstIn,
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Column(
                        children: [
                          const SizedBox(height: 4),
                          const Icon(
                            Icons.checkroom,
                            color: Colors.white,
                            size: 20,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            message,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 15,
                              color: Colors.white,
                              height: 1.6,
                              shadows: [
                                Shadow(offset: Offset(0, 1), blurRadius: 4, color: Color(0xAA000000)),
                              ],
                            ),
                          ),
                          const SizedBox(height: 4),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              // Scroll indicator bar
              Container(
                width: 3,
                margin: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(1.5),
                ),
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Container(
                    width: 3,
                    height: 30,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(1.5),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
            ],
          ),
        ),
      ),
    );
  }
}
