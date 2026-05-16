import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// Compass heading widget
class CompassWidget extends StatelessWidget {
  final int? bearing;
  final List<DetectionBearing> detectedDevices;

  const CompassWidget({
    super.key,
    this.bearing,
    this.detectedDevices = const [],
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: AspectRatio(
        aspectRatio: 1,
        child: CustomPaint(
          painter: CompassPainter(
            heading: bearing ?? 0,
            devices: detectedDevices,
          ),
        ),
      ),
    );
  }
}

/// Simple bearing data for detected devices
class DetectionBearing {
  final int bearing;
  final int rssi;

  DetectionBearing({required this.bearing, required this.rssi});
}

class CompassPainter extends CustomPainter {
  final int heading;
  final List<DetectionBearing> devices;

  CompassPainter({required this.heading, required this.devices});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 16;

    // Draw background circle
    final bgPaint = Paint()
      ..color = AppColors.backgroundCard
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, bgPaint);

    // Draw compass ring
    final ringPaint = Paint()
      ..color = AppColors.textMuted.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(center, radius, ringPaint);

    // Draw cardinal directions
    _drawCardinalDirections(canvas, center, radius);

    // Draw heading indicator
    _drawHeadingIndicator(canvas, center, radius);

    // Draw device markers
    for (final device in devices) {
      _drawDeviceMarker(canvas, center, radius, device);
    }
  }

  void _drawCardinalDirections(Canvas canvas, Offset center, double radius) {
    final directions = ['N', 'E', 'S', 'W'];
    final angles = [0.0, math.pi / 2, math.pi, 3 * math.pi / 2];

    for (int i = 0; i < directions.length; i++) {
      final angle = angles[i];
      final x = center.dx + math.cos(angle) * (radius - 16);
      final y = center.dy + math.sin(angle) * (radius - 16);

      final color = directions[i] == 'N' 
          ? AppColors.error 
          : AppColors.textSecondary;

      final textPainter = TextPainter(
        text: TextSpan(
          text: directions[i],
          style: TextStyle(
            color: color,
            fontSize: 14,
            fontWeight: FontWeight.bold,
            fontFamily: 'Orbitron',
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      textPainter.paint(
        canvas,
        Offset(x - textPainter.width / 2, y - textPainter.height / 2),
      );
    }

    // Draw tick marks for degrees
    for (int d = 0; d < 360; d += 30) {
      final angle = d * math.pi / 180;
      final isCardinal = d % 90 == 0;
      final innerR = radius - (isCardinal ? 20 : 14);
      final outerR = radius - 8;

      final x1 = center.dx + math.cos(angle) * innerR;
      final y1 = center.dy + math.sin(angle) * innerR;
      final x2 = center.dx + math.cos(angle) * outerR;
      final y2 = center.dy + math.sin(angle) * outerR;

      final paint = Paint()
        ..color = AppColors.textMuted.withOpacity(isCardinal ? 0.5 : 0.2)
        ..strokeWidth = isCardinal ? 2 : 1;

      canvas.drawLine(Offset(x1, y1), Offset(x2, y2), paint);
    }
  }

  void _drawHeadingIndicator(Canvas canvas, Offset center, double radius) {
    final angle = heading * math.pi / 180;
    final arrowLength = radius * 0.7;
    
    final tipX = center.dx + math.cos(angle) * arrowLength;
    final tipY = center.dy + math.sin(angle) * arrowLength;
    
    final backAngle = angle + math.pi;
    final leftX = center.dx + math.cos(backAngle) * (arrowLength * 0.6);
    final leftY = center.dy + math.sin(backAngle) * (arrowLength * 0.6);
    final rightX = center.dx + math.cos(backAngle - 0.3) * (arrowLength * 0.6);
    final rightY = center.dy + math.sin(backAngle - 0.3) * (arrowLength * 0.6);

    final path = Path()
      ..moveTo(tipX, tipY)
      ..lineTo(leftX, leftY)
      ..lineTo(rightX, rightY)
      ..close();

    final fillPaint = Paint()
      ..color = AppColors.primaryNeon
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, fillPaint);

    final glowPaint = Paint()
      ..color = AppColors.primaryNeon.withOpacity(0.5)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawPath(path, glowPaint);

    // Center dot
    final dotPaint = Paint()..color = AppColors.primaryNeon;
    canvas.drawCircle(center, 4, dotPaint);
  }

  void _drawDeviceMarker(
    Canvas canvas, 
    Offset center, 
    double radius,
    DetectionBearing device,
  ) {
    final angle = device.bearing * math.pi / 180;
    final distance = radius * 0.7;
    
    final x = center.dx + math.cos(angle) * distance;
    final y = center.dy + math.sin(angle) * distance;

    final color = device.rssi > -60 
        ? AppColors.success 
        : AppColors.warning;

    final glowPaint = Paint()
      ..color = color.withOpacity(0.5)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawCircle(Offset(x, y), 8, glowPaint);

    final paint = Paint()..color = color;
    canvas.drawCircle(Offset(x, y), 4, paint);
  }

  @override
  bool shouldRepaint(CompassPainter oldDelegate) {
    return heading != oldDelegate.heading;
  }
}