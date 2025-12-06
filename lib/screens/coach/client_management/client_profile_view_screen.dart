import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/common/app_icon_button.dart';

class ClientProfileViewScreen extends StatelessWidget {
  const ClientProfileViewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            // Top App Bar
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  AppIconButton(
                    icon: Icons.arrow_back,
                    onPressed: () => Navigator.of(context).pop(),
                    iconColor: isDark ? Colors.white : Colors.black,
                  ),
                  Expanded(
                    child: Text(
                      'Client Profile',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: isDark ? Colors.white : Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  AppIconButton(
                    icon: Icons.more_vert,
                    onPressed: () {},
                    iconColor: isDark ? Colors.white : Colors.black,
                  ),
                ],
              ),
            ),
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Profile Header
                    CircleAvatar(
                      radius: 48,
                      backgroundColor: AppColors.primary20,
                      child: Text(
                        'AJ',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Alex Johnson',
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                            color: isDark ? Colors.white : Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Joined: Oct 15, 2024',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                          ),
                    ),
                    const SizedBox(height: 32),
                    // Stats
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(context, 'Compliance', '85%'),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(context, 'Workouts', '24'),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(context, 'Days Active', '18'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Sections
                    _buildSection(context, 'Assigned Plans', Icons.fitness_center),
                    const SizedBox(height: 12),
                    _buildSection(context, 'Workout History', Icons.history),
                    const SizedBox(height: 12),
                    _buildSection(context, 'Health Data', Icons.favorite),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String label, String value) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey[100],
        borderRadius: BorderRadius.circular(AppTheme.radiusDefault),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, IconData icon) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey[100],
        borderRadius: BorderRadius.circular(AppTheme.radiusDefault),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: isDark ? Colors.white : Colors.black,
                  ),
            ),
          ),
          Icon(Icons.chevron_right, color: isDark ? Colors.grey[400] : Colors.grey[600]),
        ],
      ),
    );
  }
}




