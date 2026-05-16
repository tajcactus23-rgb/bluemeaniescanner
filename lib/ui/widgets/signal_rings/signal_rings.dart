import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/distance_estimator.dart';

/// Signal strength orbit rings widget
class SignalRingsWidget extends StatelessWidget {
  final int rssi;
  final double? estimatedDistance;

  const SignalRingsWidget({
    super.key,
    required this.rssi,
    this.estimatedDistance,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: AspectRatio(
        aspectRatio: 1,
        child: CustomPaint(
          painter: SignalRingsPainter(
            rssi: rssi,
            distance: estimatedDistance,
          ),
        ),
      ),
    );
  }
}

class SignalRingsPainter extends CustomPainter {
  final int rssi;
  final double? distance;

  SignalRingsPainter({
    required this.rssi,
    this.distance,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width / 2 - 8;

    // Determine strength
    final strength = distance != null 
        ? DistanceEstimator.getSignalStrength(distance!)
        : (rssi > -60 
            ? SignalStrength.strong 
            : (rssi > -80 ? SignalStrength.medium : SignalStrength.weak));

    // Draw rings based on strength
    final colors = _getColorsForStrength(strength);
    
    for (int i = 0; i < 3; i++) {
      final ringRadius = maxRadius * (0.3 + i * 0.3);
      final isActive = i <= strength.index;
      
      final paint = Paint()
        ..color = isActive 
            ? colors[i].withOpacity(0.6) 
            : colors[i].withOpacity(0.1)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      
      canvas.drawCircle(center, ringRadius, paint);

      if (isActive) {
        final glowPaint = Paint()
          ..color = colors[i].withOpacity(0.3)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
        canvas.drawCircle(center, ringRadius, glowPaint);
      }

      // Zone labels
      String label;
      switch (i) {
        case 0:
          label = '3m';
          break;
        case 1:
          label = '10m';
          break;
        case 2:
          label = '30m';
          break;
        default:
          label = '';
      }

      final textPainter = TextPainter(
        text: TextSpan(
          text: label,
          style: TextStyle(
            color: isActive ? colors[i] : AppColors.textMuted,
            fontSize: 10,
            fontFamily: 'Orbitron',
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      textPainter.paint(
        canvas,
        Offset(center.dx + ringRadius + 4, center.dy - textPainter.height / 2),
      );
    }
  }

  List<Color> _getColorsForStrength(SignalStrength strength) {
    switch (strength) {
      case SignalStrength.strong:
        return [
          AppColors.success,
          AppColors.success.withOpacity(0.5),
          AppColors.success.withOpacity(0.3),
        ];
      case SignalStrength.medium:
        return [
          AppColors.success,
          AppColors.accent,
          AppColors.accent.withOpacity(0.3),
        ];
      case SignalStrength.weak:
        return [
          AppColors.success,
          AppColors.accent,
          AppColors.warning,
        ];
    }
  }

  @override
  bool shouldRepaint(SignalRingsPainter oldDelegate) {
    return rssi != oldDelegate.rssi || distance != oldDelegate.distance;
  }
}