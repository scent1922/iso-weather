import 'dart:ui';
import 'package:flutter/material.dart';

class ClothingCard extends StatefulWidget {
  final String message;

  const ClothingCard({super.key, required this.message});

  @override
  State<ClothingCard> createState() => _ClothingCardState();
}

class _ClothingCardState extends State<ClothingCard> {
  final ScrollController _scrollController = ScrollController();
  double _scrollFraction = 0.0;
  bool _canScroll = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkCanScroll());
  }

  @override
  void didUpdateWidget(ClothingCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.message != widget.message) {
      _scrollController.jumpTo(0);
      _scrollFraction = 0.0;
      WidgetsBinding.instance.addPostFrameCallback((_) => _checkCanScroll());
    }
  }

  void _checkCanScroll() {
    if (_scrollController.hasClients) {
      setState(() {
        _canScroll = _scrollController.position.maxScrollExtent > 0;
      });
    }
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final max = _scrollController.position.maxScrollExtent;
    if (max <= 0) return;
    setState(() {
      _scrollFraction = (_scrollController.offset / max).clamp(0.0, 1.0);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

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
                    controller: _scrollController,
                    physics: const BouncingScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Column(
                        children: [
                          const SizedBox(height: 4),
                          const Icon(Icons.checkroom, color: Colors.white, size: 20),
                          const SizedBox(height: 8),
                          Text(
                            widget.message,
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
              if (_canScroll)
                LayoutBuilder(
                  builder: (context, constraints) {
                    const trackMargin = 8.0;
                    final trackHeight = constraints.maxHeight - trackMargin * 2;
                    const handleHeight = 24.0;
                    final maxOffset = trackHeight - handleHeight;
                    final handleOffset = maxOffset * _scrollFraction;

                    return Container(
                      width: 3,
                      margin: const EdgeInsets.symmetric(vertical: trackMargin),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(1.5),
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            top: handleOffset,
                            child: Container(
                              width: 3,
                              height: handleHeight,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.5),
                                borderRadius: BorderRadius.circular(1.5),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              const SizedBox(width: 12),
            ],
          ),
        ),
      ),
    );
  }
}
