import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

/// Animated radar dish with sweep and ping animations
class RadarWidget extends StatefulWidget {
  final bool isScanning;
  final int deviceCount;
  final int? lastDetectedRssi;

  const RadarWidget({
    super.key,
    required this.isScanning,
    this.deviceCount = 0,
    this.lastDetectedRssi,
  });

  @override
  State<RadarWidget> createState() => _RadarWidgetState();
}

class _RadarWidgetState extends State<RadarWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _sweepAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );
    
    _sweepAnimation = Tween<double>(
      begin: 0,
      end: 2 * math.pi,
    ).animate(_controller);

    if (widget.isScanning) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(RadarWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isScanning && !_controller.isAnimating) {
      _controller.repeat();
    } else if (!widget.isScanning && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: AnimatedBuilder(
        animation: _sweepAnimation,
        builder: (context, child) {
          return CustomPaint(
            painter: RadarPainter(
              sweepAngle: _sweepAnimation.value,
              isScanning: widget.isScanning,
              deviceCount: widget.deviceCount,
              lastRssi: widget.lastDetectedRssi,
            ),
          );
        },
      ),
    );
  }
}

class RadarPainter extends CustomPainter {
  final double sweepAngle;
  final bool isScanning;
  final int deviceCount;
  final int? lastRssi;

  RadarPainter({
    required this.sweepAngle,
    required this.isScanning,
    required this.deviceCount,
    this.lastRssi,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 16;

    // Draw background circles
    _drawRadarRings(canvas, center, radius);

    // Draw sweep line
    if (isScanning) {
      _drawSweepLine(canvas, center, radius);
    }

    // Draw center dot
    _drawCenterDot(canvas, center);

    // Draw device pings if any
    if (deviceCount > 0) {
      _drawDevicePings(canvas, center, radius);
    }
  }

  void _drawRadarRings(Canvas canvas, Offset center, double radius) {
    // Ring 1 (inner - strong signal)
    final paint1 = Paint()
      ..color = AppColors.radarRing1.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawCircle(center, radius * 0.3, paint1);

    // Ring 2 (medium signal)
    final paint2 = Paint()
      ..color = AppColors.radarRing2.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawCircle(center, radius * 0.6, paint2);

    // Ring 3 (outer - weak signal)
    final paint3 = Paint()
      ..color = AppColors.radarRing3.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawCircle(center, radius, paint3);

    // Draw cross lines
    final linePaint = Paint()
      ..color = AppColors.textMuted.withOpacity(0.2)
      ..strokeWidth = 1;

    // Horizontal line
    canvas.drawLine(
      Offset(center.dx - radius, center.dy),
      Offset(center.dx + radius, center.dy),
      linePaint,
    );

    // Vertical line
    canvas.drawLine(
      Offset(center.dx, center.dy - radius),
      Offset(center.dx, center.dy + radius),
      linePaint,
    );
  }

  void _drawSweepLine(Canvas canvas, Offset center, double radius) {
    // Sweep arc
    final sweepPaint = Paint()
      ..shader = SweepGradient(
        center: center,
        startAngle: sweepAngle,
        endAngle: sweepAngle + 0.5,
        colors: [
          Colors.transparent,
          AppColors.primaryNeon.withOpacity(0.8),
          AppColors.primaryNeon.withOpacity(0.3),
          Colors.transparent,
        ],
        stops: const [0.0, 0.3, 0.5, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    final path = Path()
      ..moveTo(center.dx, center.dy)
      ..arcTo(
        Rect.fromCircle(center: center, radius: radius),
        sweepAngle,
        0.5,
        false,
      )
      ..close();

    canvas.drawPath(path, sweepPaint);

    // Sweep glow
    final glowPaint = Paint()
      ..color = AppColors.primaryNeon.withOpacity(0.1)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20);

    final glowPath = Path()
      ..moveTo(center.dx, center.dy)
      ..arcTo(
        Rect.fromCircle(center: center, radius: radius - 4),
        sweepAngle,
        0.5,
        false,
      )
      ..close();

    canvas.drawPath(glowPath, glowPaint);
  }

  void _drawCenterDot(Canvas canvas, Offset center) {
    // Outer glow
    final glowPaint = Paint()
      ..color = isScanning 
        ? AppColors.primaryNeon.withOpacity(0.3)
        : AppColors.textMuted.withOpacity(0.2)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawCircle(center, 8, glowPaint);

    // Center dot
    final dotPaint = Paint()
      ..color = isScanning ? AppColors.primaryNeon : AppColors.textMuted;
    canvas.drawCircle(center, 4, dotPaint);
  }

  void _drawDevicePings(Canvas canvas, Offset center, double radius) {
    // Ping at random position based on device count
    final random = math.Random(DateTime.now().millisecondsSinceEpoch);
    final angle = random.nextDouble() * 2 * math.pi;
    final distance = radius * (0.3 + random.nextDouble() * 0.5);
    
    final x = center.dx + math.cos(angle) * distance;
    final y = center.dy + math.sin(angle) * distance;

    // Ping color based on RSSI
    final color = lastRssi != null && lastRssi! > -60
        ? AppColors.success
        : AppColors.warning;

    // Ping glow
    final glowPaint = Paint()
      ..color = color.withOpacity(0.5)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
    canvas.drawCircle(Offset(x, y), 8, glowPaint);

    // Ping dot
    final paint = Paint()..color = color;
    canvas.drawCircle(Offset(x, y), 4, paint);
  }

  @override
  bool shouldRepaint(RadarPainter oldDelegate) {
    return sweepAngle != oldDelegate.sweepAngle ||
        isScanning != oldDelegate.isScanning ||
        deviceCount != oldDelegate.deviceCount;
  }
}