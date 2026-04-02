import 'dart:math';
import 'package:flutter/material.dart';

class ParticleOverlay extends StatefulWidget {
  final String weatherType; // 'snow', 'rain', 'fog', 'clear', 'cloudy'
  final bool enabled;

  const ParticleOverlay({
    super.key,
    required this.weatherType,
    this.enabled = true,
  });

  @override
  State<ParticleOverlay> createState() => _ParticleOverlayState();
}

class _ParticleOverlayState extends State<ParticleOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<_Particle> _particles;
  final _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();
    _particles = _generateParticles();
  }

  @override
  void didUpdateWidget(ParticleOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.weatherType != widget.weatherType) {
      _particles = _generateParticles();
    }
  }

  List<_Particle> _generateParticles() {
    final count = switch (widget.weatherType) {
      'snow' => 60,
      'rain' => 150,
      'fog' => 15,
      _ => 0,
    };

    return List.generate(count, (_) => _Particle(
      x: _random.nextDouble(),
      y: _random.nextDouble(),
      speed: _random.nextDouble() * 0.5 + 0.3,
      size: _random.nextDouble() * 4 + 2,
      wobble: _random.nextDouble() * 2 * pi,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled ||
        widget.weatherType == 'clear' ||
        widget.weatherType == 'cloudy') {
      return const SizedBox.shrink();
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return RepaintBoundary(
          child: CustomPaint(
            size: Size.infinite,
            painter: _ParticlePainter(
              particles: _particles,
              weatherType: widget.weatherType,
              time: DateTime.now().millisecondsSinceEpoch / 1000.0,
            ),
          ),
        );
      },
    );
  }
}

class _Particle {
  double x;
  double y;
  final double speed;
  final double size;
  final double wobble;

  _Particle({
    required this.x,
    required this.y,
    required this.speed,
    required this.size,
    required this.wobble,
  });
}

class _ParticlePainter extends CustomPainter {
  final List<_Particle> particles;
  final String weatherType;
  final double time;

  _ParticlePainter({
    required this.particles,
    required this.weatherType,
    required this.time,
  });

  @override
  void paint(Canvas canvas, Size size) {
    switch (weatherType) {
      case 'snow':
        _paintSnow(canvas, size);
        break;
      case 'rain':
        _paintRain(canvas, size);
        break;
      case 'fog':
        _paintFog(canvas, size);
        break;
    }
  }

  void _paintSnow(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withValues(alpha: 0.8);

    for (final p in particles) {
      p.y += p.speed * 0.002;
      p.x += sin(time * 1.5 + p.wobble) * 0.001;

      if (p.y > 1.0) {
        p.y = -0.05;
        p.x = Random().nextDouble();
      }
      if (p.x < 0) p.x = 1.0;
      if (p.x > 1) p.x = 0.0;

      canvas.drawCircle(
        Offset(p.x * size.width, p.y * size.height),
        p.size,
        paint,
      );
    }
  }

  void _paintRain(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.4)
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    for (final p in particles) {
      p.y += p.speed * 0.008;
      p.x += 0.001;

      if (p.y > 1.0) {
        p.y = -0.05;
        p.x = Random().nextDouble();
      }

      final startX = p.x * size.width;
      final startY = p.y * size.height;
      final length = p.size * 3;

      canvas.drawLine(
        Offset(startX, startY),
        Offset(startX + 2, startY + length),
        paint,
      );
    }
  }

  void _paintFog(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withValues(alpha: 0.08);

    for (final p in particles) {
      p.x += sin(time * 0.3 + p.wobble) * 0.0005;
      if (p.x < -0.3) p.x = 1.3;
      if (p.x > 1.3) p.x = -0.3;

      canvas.drawCircle(
        Offset(p.x * size.width, p.y * size.height),
        p.size * 20,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter oldDelegate) => true;
}
