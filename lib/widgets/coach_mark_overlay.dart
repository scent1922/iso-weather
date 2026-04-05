import 'dart:ui';
import 'package:flutter/material.dart';

class CoachMarkStep {
  final String description;
  final Rect Function(Size screenSize) spotlightRectBuilder;
  final bool tooltipAbove;

  const CoachMarkStep({
    required this.description,
    required this.spotlightRectBuilder,
    required this.tooltipAbove,
  });
}

class CoachMarkOverlay extends StatefulWidget {
  final VoidCallback onComplete;

  const CoachMarkOverlay({super.key, required this.onComplete});

  @override
  State<CoachMarkOverlay> createState() => _CoachMarkOverlayState();
}

class _CoachMarkOverlayState extends State<CoachMarkOverlay>
    with TickerProviderStateMixin {
  int _currentStep = 0;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late AnimationController _blinkController;
  late Animation<double> _blinkAnimation;

  static List<CoachMarkStep> _buildSteps() => [
        CoachMarkStep(
          description: '여기서 전 세계 도시를 검색할 수 있어요',
          spotlightRectBuilder: (size) {
            final top = size.height * 0.12;
            final width = size.width * 0.72;
            final left = (size.width - width) / 2;
            final height = size.height * 0.06;
            return Rect.fromLTWH(left, top, width, height);
          },
          tooltipAbove: false,
        ),
        CoachMarkStep(
          description: '현재 도시의 실시간 날씨 정보예요',
          spotlightRectBuilder: (size) {
            final top = size.height * 0.185;
            final width = size.width * 0.65;
            final left = (size.width - width) / 2;
            final height = size.height * 0.14;
            return Rect.fromLTWH(left, top, width, height);
          },
          tooltipAbove: false,
        ),
        CoachMarkStep(
          description: '계절, 시간, 날씨에 따라 배경이 바뀌어요',
          spotlightRectBuilder: (size) {
            final width = size.width * 0.85;
            final left = (size.width - width) / 2;
            final height = size.height * 0.38;
            final top = (size.height - height) / 2 - size.height * 0.02;
            return Rect.fromLTWH(left, top, width, height);
          },
          tooltipAbove: true,
        ),
        CoachMarkStep(
          description: '하루 전체를 분석한 맞춤 옷차림 추천이에요',
          spotlightRectBuilder: (size) {
            final width = size.width * 0.90;
            final left = (size.width - width) / 2;
            final height = size.height * 0.11;
            final top = size.height * 0.80;
            return Rect.fromLTWH(left, top, width, height);
          },
          tooltipAbove: true,
        ),
        CoachMarkStep(
          description: '옆으로 스와이프하면 상세 날씨를 볼 수 있어요',
          spotlightRectBuilder: (size) {
            final width = size.width * 0.22;
            final left = (size.width - width) / 2;
            final height = size.height * 0.035;
            final top = size.height * 0.955;
            return Rect.fromLTWH(left, top, width, height);
          },
          tooltipAbove: true,
        ),
      ];

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );
    _fadeController.forward();

    _blinkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _blinkAnimation = CurvedAnimation(
      parent: _blinkController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _blinkController.dispose();
    super.dispose();
  }

  void _advance() {
    final steps = _buildSteps();
    if (_currentStep < steps.length - 1) {
      _fadeController.reverse().then((_) {
        if (mounted) {
          setState(() => _currentStep++);
          _fadeController.forward();
        }
      });
    } else {
      _fadeController.reverse().then((_) {
        if (mounted) widget.onComplete();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final steps = _buildSteps();
    final step = steps[_currentStep];
    final size = MediaQuery.of(context).size;
    final spotlightRect = step.spotlightRectBuilder(size);
    final isLast = _currentStep == steps.length - 1;

    return GestureDetector(
      onTap: _advance,
      behavior: HitTestBehavior.opaque,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Stack(
          children: [
            // Dark overlay with spotlight cutout
            CustomPaint(
              size: size,
              painter: _SpotlightPainter(spotlightRect: spotlightRect),
            ),

            // Tooltip
            _buildTooltip(context, step, spotlightRect, size),

            // Step counter top-left
            Positioned(
              top: MediaQuery.of(context).padding.top + 16,
              left: 20,
              child: Text(
                '${_currentStep + 1}/${steps.length}',
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            // Tap to continue / start button at bottom
            Positioned(
              bottom: MediaQuery.of(context).padding.bottom + 24,
              left: 0,
              right: 0,
              child: isLast
                  ? Center(
                      child: GestureDetector(
                        onTap: _advance,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 40, vertical: 14),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.20),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.40),
                              width: 1,
                            ),
                          ),
                          child: const Text(
                            '시작하기',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    )
                  : FadeTransition(
                      opacity: _blinkAnimation,
                      child: const Center(
                        child: Text(
                          '탭하여 계속',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 12,
                            color: Colors.white,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTooltip(
    BuildContext context,
    CoachMarkStep step,
    Rect spotlightRect,
    Size size,
  ) {
    const tooltipWidth = 240.0;
    const tooltipPadding = 16.0;
    const arrowSize = 8.0;
    const gap = 12.0;

    final tooltipLeft =
        (size.width - tooltipWidth) / 2;

    final double tooltipTop;
    final bool arrowPointingDown;

    if (step.tooltipAbove) {
      tooltipTop = spotlightRect.top - gap - arrowSize - 80;
      arrowPointingDown = true;
    } else {
      tooltipTop = spotlightRect.bottom + gap + arrowSize;
      arrowPointingDown = false;
    }

    return Positioned(
      left: tooltipLeft,
      top: tooltipTop.clamp(
          MediaQuery.of(context).padding.top + 8,
          size.height - 120),
      width: tooltipWidth,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!arrowPointingDown) _buildArrow(pointing: 'up'),
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: tooltipPadding,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.20),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.30),
                    width: 1,
                  ),
                ),
                child: Text(
                  step.description,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    color: Colors.white,
                    height: 1.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
          if (arrowPointingDown) _buildArrow(pointing: 'down'),
        ],
      ),
    );
  }

  Widget _buildArrow({required String pointing}) {
    final isDown = pointing == 'down';
    return CustomPaint(
      size: const Size(16, 8),
      painter: _ArrowPainter(pointingDown: isDown),
    );
  }
}

class _SpotlightPainter extends CustomPainter {
  final Rect spotlightRect;

  _SpotlightPainter({required this.spotlightRect});

  @override
  void paint(Canvas canvas, Size size) {
    final fullRect = Rect.fromLTWH(0, 0, size.width, size.height);
    final expandedRect = spotlightRect.inflate(6);
    final rrect = RRect.fromRectAndRadius(expandedRect, const Radius.circular(16));

    final overlayPath = Path()..addRect(fullRect);
    final spotlightPath = Path()..addRRect(rrect);
    final cutout = Path.combine(PathOperation.difference, overlayPath, spotlightPath);

    // Dark overlay
    final overlayPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.70)
      ..style = PaintingStyle.fill;
    canvas.drawPath(cutout, overlayPaint);

    // Soft glow border around spotlight
    final glowPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.10)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawRRect(rrect, glowPaint);
  }

  @override
  bool shouldRepaint(_SpotlightPainter oldDelegate) =>
      oldDelegate.spotlightRect != spotlightRect;
}

class _ArrowPainter extends CustomPainter {
  final bool pointingDown;

  _ArrowPainter({required this.pointingDown});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.20)
      ..style = PaintingStyle.fill;

    final path = Path();
    if (pointingDown) {
      path.moveTo(0, 0);
      path.lineTo(size.width, 0);
      path.lineTo(size.width / 2, size.height);
      path.close();
    } else {
      path.moveTo(size.width / 2, 0);
      path.lineTo(size.width, size.height);
      path.lineTo(0, size.height);
      path.close();
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_ArrowPainter oldDelegate) =>
      oldDelegate.pointingDown != pointingDown;
}
