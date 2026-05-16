import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/distance_estimator.dart';
import '../../../data/models/detection.dart';

/// Device card with glow effect based on RSSI
class DeviceCard extends StatelessWidget {
  final Detection detection;
  final Color? glowColor;

  const DeviceCard({
    super.key,
    required this.detection,
    this.glowColor,
  });

  @override
  Widget build(BuildContext context) {
    final strength = DistanceEstimator.getSignalStrength(detection.estimatedDistance);
    final color = _getStrengthColor(strength);
    final glow = glowColor ?? color;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: glow.withOpacity(0.2),
            blurRadius: 12,
            spreadRadius: 0,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            // Glow overlay
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      glow.withOpacity(0.1),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            
            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: color.withOpacity(0.8),
                                  blurRadius: 6,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            detection.deviceId,
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 14,
                              fontFamily: 'RobotoMono',
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      _buildSignalBadge(strength, color),
                    ],
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Stats row
                  Row(
                    children: [
                      _buildStat(
                        icon: Icons.signal_cellular_alt,
                        value: '${detection.rssi} dBm',
                        label: 'RSSI',
                        color: color,
                      ),
                      const SizedBox(width: 16),
                      _buildStat(
                        icon: Icons.straighten,
                        value: formatDistance(detection.estimatedDistance),
                        label: 'Distance',
                        color: color,
                      ),
                      if (detection.bearing != null) ...[
                        const SizedBox(width: 16),
                        _buildStat(
                          icon: Icons.explore,
                          value: '${detection.bearing}°',
                          label: 'Bearing',
                          color: color,
                        ),
                      ],
                    ],
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Timestamp
                  Text(
                    _formatTimestamp(detection.timestamp),
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStat({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Text(
              value,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.bold,
                fontFamily: 'RobotoMono',
              ),
            ),
          ],
        ),
        Text(
          label,
          style: TextStyle(
            color: AppColors.textMuted,
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Widget _buildSignalBadge(SignalStrength strength, Color color) {
    String label;
    switch (strength) {
      case SignalStrength.strong:
        label = 'STRONG';
        break;
      case SignalStrength.medium:
        label = 'MEDIUM';
        break;
      case SignalStrength.weak:
        label = 'WEAK';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
          fontFamily: 'Orbitron',
        ),
      ),
    );
  }

  Color _getStrengthColor(SignalStrength strength) {
    switch (strength) {
      case SignalStrength.strong:
        return AppColors.success;
      case SignalStrength.medium:
        return AppColors.accent;
      case SignalStrength.weak:
        return AppColors.warning;
    }
  }

  String _formatTimestamp(DateTime dt) {
    return '${dt.hour.toString().padLeft(2, '0')}:'
        '${dt.minute.toString().padLeft(2, '0')}:'
        '${dt.second.toString().padLeft(2, '0')}';
  }
}