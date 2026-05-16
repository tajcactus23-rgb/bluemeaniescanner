import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/constants/app_colors.dart';
import 'core/constants/app_strings.dart';
import 'data/database/database_helper.dart';
import 'data/models/theme_model.dart';

/// Main app entry point
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set system UI
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: AppColors.backgroundDark,
    systemNavigationBarIconBrightness: Brightness.light,
  ));

  // Initialize database
  await DatabaseHelper.instance.database;

  runApp(const AxonScoutApp());
}

/// Main app widget
class AxonScoutApp extends StatefulWidget {
  const AxonScoutApp({super.key});

  @override
  State<AxonScoutApp> createState() => _AxonScoutAppState();
}

class _AxonScoutAppState extends State<AxonScoutApp> {
  ThemeModel _currentTheme = Themes.cyberpunk;
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: _currentTheme.toThemeData(),
      home: Scaffold(
        body: _buildBody(),
        bottomNavigationBar: _buildBottomNav(),
      ),
    );
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return _DashboardView(
          onThemeChanged: _onThemeChanged,
        );
      case 1:
        return _DetectionLogView();
      case 2:
        return _SummaryView();
      case 3:
        return _ScoreboardView();
      case 4:
        return _SettingsView(
          currentTheme: _currentTheme,
          onThemeChanged: _onThemeChanged,
        );
      default:
        return _DashboardView(
          onThemeChanged: _onThemeChanged,
        );
    }
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        border: Border(
          top: BorderSide(
            color: AppColors.primaryNeon.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        backgroundColor: AppColors.backgroundCard,
        selectedItemColor: AppColors.primaryNeon,
        unselectedItemColor: AppColors.textMuted,
        selectedLabelStyle: const TextStyle(
          fontFamily: 'Orbitron',
          fontSize: 10,
        ),
        unselectedLabelStyle: const TextStyle(
          fontFamily: 'RobotoMono',
          fontSize: 10,
        ),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.radar),
            label: AppStrings.dashboard,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt),
            label: AppStrings.detectionLog,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: AppStrings.summary,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.emoji_events),
            label: AppStrings.scoreboard,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: AppStrings.settings,
          ),
        ],
      ),
    );
  }

  void _onThemeChanged(ThemeModel theme) {
    setState(() {
      _currentTheme = theme;
    });
  }
}

/// Dashboard view placeholder
class _DashboardView extends StatelessWidget {
  final Function(ThemeModel) onThemeChanged;

  const _DashboardView({required this.onThemeChanged});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'IDLE',
                    style: TextStyle(
                      color: AppColors.success,
                      fontSize: 12,
                      fontFamily: 'Orbitron',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Radar visualization placeholder
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.primaryNeon.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: Center(
                child: Icon(
                  Icons.radar,
                  size: 64,
                  color: AppColors.primaryNeon,
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Stats placeholder
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Devices Found',
                    '0',
                    Icons.devices,
                    AppColors.primaryNeon,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Strongest',
                    '--',
                    Icons.signal_cellular_alt,
                    AppColors.success,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Start scan button placeholder
            GestureDetector(
              onTap: () {
                // Would trigger BLE scan
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: AppColors.primaryNeon.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.primaryNeon,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    'START SCAN',
                    style: TextStyle(
                      color: AppColors.primaryNeon,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Orbitron',
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

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
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
}

/// Detection log view
class _DetectionLogView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppStrings.detectionLog,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Orbitron',
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.file_download, color: AppColors.primaryNeon),
                  onPressed: () {
                    // Export logs
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.list_alt, size: 48, color: AppColors.textMuted),
                  const SizedBox(height: 16),
                  Text(
                    AppStrings.detectionLogEmpty,
                    style: TextStyle(color: AppColors.textMuted),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Summary view
class _SummaryView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.summary,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: 'Orbitron',
              ),
            ),
            const SizedBox(height: 24),
            Center(
              child: Column(
                children: [
                  Icon(Icons.bar_chart, size: 64, color: AppColors.textMuted),
                  const SizedBox(height: 16),
                  Text(
                    'Summary graphs will appear here',
                    style: TextStyle(color: AppColors.textMuted),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Scoreboard view
class _ScoreboardView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.scoreboard,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: 'Orbitron',
              ),
            ),
            const SizedBox(height: 24),
            _buildScoreItem(AppStrings.longestSession, '0s', Icons.timer),
            _buildScoreItem(AppStrings.beaconsDetected, '0', Icons.radar),
            _buildScoreItem(AppStrings.totalDetections, '0', Icons.analytics),
            _buildScoreItem(AppStrings.calibrationAccuracy, '--', Icons.tune),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreItem(String label, String value, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primaryNeon),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: AppColors.primaryNeon,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: 'Orbitron',
            ),
          ),
        ],
      ),
    );
  }
}

/// Settings view
class _SettingsView extends StatelessWidget {
  final ThemeModel currentTheme;
  final Function(ThemeModel) onThemeChanged;

  const _SettingsView({
    required this.currentTheme,
    required this.onThemeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.settings,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: 'Orbitron',
              ),
            ),
            const SizedBox(height: 24),

            // Theme selector
            _buildSectionTitle('Theme'),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: Themes.all.map((theme) {
                final isSelected = theme.id == currentTheme.id;
                return GestureDetector(
                  onTap: () => onThemeChanged(theme),
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: theme.primaryColor,
                      borderRadius: BorderRadius.circular(8),
                      border: isSelected
                          ? Border.all(color: Colors.white, width: 2)
                          : null,
                    ),
                    child: isSelected
                        ? Icon(Icons.check, color: Colors.white, size: 20)
                        : null,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Calibration
            _buildMenuItem(
              icon: Icons.tune,
              title: AppStrings.calibrate,
              onTap: () {},
            ),

            // Export
            _buildMenuItem(
              icon: Icons.file_download,
              title: AppStrings.exportLogs,
              onTap: () {},
            ),

            // Audio alerts
            _buildMenuItem(
              icon: Icons.volume_up,
              title: AppStrings.audioAlerts,
              trailing: Switch(
                value: true,
                onChanged: (value) {},
                activeColor: AppColors.primaryNeon,
              ),
            ),

            // Reset
            _buildMenuItem(
              icon: Icons.delete_forever,
              title: AppStrings.resetData,
              titleColor: AppColors.error,
              onTap: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    backgroundColor: AppColors.backgroundCard,
                    title: Text(
                      'Reset All Data?',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontFamily: 'Orbitron',
                      ),
                    ),
                    content: Text(
                      'This will delete all detections, achievements, and statistics.',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: Text(
                          'Reset',
                          style: TextStyle(color: AppColors.error),
                        ),
                      ),
                    ],
                  ),
                );
                if (confirmed == true) {
                  await DatabaseHelper.instance.resetAllData();
                }
              },
            ),

            const SizedBox(height: 24),

            // About
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.backgroundCard,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.warning.withOpacity(0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.warning, color: AppColors.warning, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Authorized Use',
                        style: TextStyle(
                          color: AppColors.warning,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Orbitron',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppStrings.authorizedUse,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Version
            Center(
              child: Text(
                'v${AppStrings.appVersion}',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        color: AppColors.textSecondary,
        fontSize: 14,
        fontFamily: 'Orbitron',
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    Widget? trailing,
    Color? titleColor,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.backgroundCard,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: titleColor ?? AppColors.primaryNeon),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: titleColor ?? AppColors.textPrimary,
                  fontSize: 14,
                ),
              ),
            ),
            trailing ?? Icon(Icons.chevron_right, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }
}