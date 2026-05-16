import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../services/ble/ble_scanner_service.dart';
import '../../widgets/radar/radar_widget.dart';
import '../../widgets/device_card/device_card.dart';
import '../../widgets/signal_rings/signal_rings.dart';
import '../ble/ble_scanner_bloc.dart';

/// Main dashboard screen
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BleScannerBloc, BleScannerState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.backgroundDark,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  _buildHeader(context, state),
                  
                  const SizedBox(height: 24),
                  
                  // Radar
                  _buildRadar(state),
                  
                  const SizedBox(height: 24),
                  
                  // Stats
                  _buildStats(state),
                  
                  const SizedBox(height: 24),
                  
                  // Signal rings
                  _buildSignalRings(state),
                  
                  const SizedBox(height: 24),
                  
                  // Recent detections
                  _buildRecentDetections(context, state),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, BleScannerState state) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.appName,
              style: TextStyle(
                color: AppColors.primaryNeon,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                fontFamily: 'Orbitron',
              ),
            ),
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: state.isScanning 
                        ? AppColors.success 
                        : AppColors.textMuted,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  state.isScanning 
                      ? AppStrings.scanning 
                      : AppStrings.idle,
                  style: TextStyle(
                    color: state.isScanning 
                        ? AppColors.success 
                        : AppColors.textMuted,
                    fontSize: 14,
                    fontFamily: 'Orbitron',
                  ),
                ),
              ],
            ),
          ],
        ),
        _buildScanButton(context, state),
      ],
    );
  }

  Widget _buildScanButton(BuildContext context, BleScannerState state) {
    return GestureDetector(
      onTap: () {
        if (state.isScanning) {
          context.read<BleScannerBloc>().add(StopScan());
        } else {
          context.read<BleScannerBloc>().add(StartScan());
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: state.isScanning 
              ? AppColors.error.withOpacity(0.2) 
              : AppColors.primaryNeon.withOpacity(0.2),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: state.isScanning 
                ? AppColors.error 
                : AppColors.primaryNeon,
            width: 2,
          ),
        ),
        child: Text(
          state.isScanning 
              ? AppStrings.stopScan 
              : AppStrings.startScan,
          style: TextStyle(
            color: state.isScanning 
                ? AppColors.error 
                : AppColors.primaryNeon,
            fontSize: 14,
            fontWeight: FontWeight.bold,
            fontFamily: 'Orbitron',
          ),
        ),
      ),
    );
  }

  Widget _buildRadar(BleScannerState state) {
    return Center(
      child: SizedBox(
        width: 250,
        height: 250,
        child: RadarWidget(
          isScanning: state.isScanning,
          deviceCount: state.deviceCount,
          lastDetectedRssi: state.strongestRssi,
        ),
      ),
    );
  }

  Widget _buildStats(BleScannerState state) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            icon: Icons.devices,
            label: AppStrings.devicesFound,
            value: '${state.deviceCount}',
            color: AppColors.primaryNeon,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            icon: Icons.signal_cellular_alt,
            label: AppStrings.strongestSignal,
            value: state.strongestRssi > -100 
                ? '${state.strongestRssi} dBm' 
                : '--',
            color: AppColors.success,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontFamily: 'Orbitron',
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignalRings(BleScannerState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Signal Zones',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
            fontFamily: 'Orbitron',
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 120,
          child: SignalRingsWidget(
            rssi: state.strongestRssi,
          ),
        ),
      ],
    );
  }

  Widget _buildRecentDetections(BuildContext context, BleScannerState state) {
    if (state.recentDetections.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.radar,
                size: 48,
                color: AppColors.textMuted,
              ),
              const SizedBox(height: 16),
              Text(
                AppStrings.detectionLogEmpty,
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
            fontFamily: 'Orbitron',
          ),
        ),
        const SizedBox(height: 12),
        for (final detection in state.recentDetections.take(3))
          DeviceCard(detection: detection),
      ],
    );
  }
}