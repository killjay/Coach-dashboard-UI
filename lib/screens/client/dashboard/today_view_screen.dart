import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/common/progress_ring.dart';
import '../../../widgets/common/primary_button.dart';
import '../../../widgets/common/app_card.dart';
import '../workouts/workout_logging_screen.dart';
import '../workouts/assigned_workouts_list_screen.dart';
import '../tracking/water_tracker_screen.dart';
import '../tracking/steps_logging_screen.dart';
import '../nutrition/daily_macro_goals_screen.dart';
import '../analytics/overall_body_analytics_screen.dart';
import '../analytics/personal_records_screen.dart';
import '../community/community_leaderboards_screen.dart';
import '../community/personal_badges_screen.dart';
import '../../shared/general_settings_screen.dart';

class TodayViewScreen extends StatelessWidget {
  const TodayViewScreen({super.key});

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning';
    } else if (hour < 17) {
      return 'Good Afternoon';
    } else {
      return 'Good Evening';
    }
  }

  String _getFormattedDate() {
    final now = DateTime.now();
    final weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    
    return '${weekdays[now.weekday - 1]}, ${months[now.month - 1]} ${now.day}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: SafeArea(
        child: Column(
          children: [
            // Top App Bar
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${_getGreeting()}, Alex',
                          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                letterSpacing: -0.015,
                              ),
                        ),
                        Text(
                          _getFormattedDate(),
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: AppColors.textSecondaryDark,
                              ),
                        ),
                      ],
                    ),
                  ),
                  // Profile Picture - Tappable (shows menu with options)
                  GestureDetector(
                    onTap: () {
                      _showProfileMenu(context);
                    },
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          image: NetworkImage(
                            'https://lh3.googleusercontent.com/aida-public/AB6AXuCzILWL8itsIzTYKKulzJ2pJdGk5pmwUHSI7IBPo9ZxgsCjIugdizG1yjwxjktsdmJEomg9AcO2Vx46unRKNXx8BpaWTX0c9NHW_UW1oyky1VUri9RYQnDvVJs-lsYCc9adTuXv8pjjE2axXud0XYZgg1g2K5LVqH_sw2nBHZqU0RFeyMq_B8fZBlOmM2KDQZIzIcbVjrbaQAQ55v-ESCZ08xvcIztNdrSHZs4jus_aLWaoLu6ARnwSJVL7O-zZMYevLY8vV7gns8Y',
                          ),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  children: [
                    const SizedBox(height: 24),
                    // Progress Ring
                    ProgressRing(
                      progress: 0.75,
                      size: 224,
                      child: Column(
                        children: [
                          Text(
                            '75%',
                            style: Theme.of(context).textTheme.displayLarge?.copyWith(
                                  color: Colors.white,
                                  fontSize: 48,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          Text(
                            'DONE',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppColors.textSecondaryDark,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 2,
                                ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Section Header
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Today's Focus",
                        style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                              color: Colors.white,
                            ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Task List
                    _buildTaskItem(
                      context,
                      icon: Icons.fitness_center,
                      title: 'Upper Body Strength',
                      subtitle: 'Assigned Workout',
                      actionButton: PrimaryButton(
                        text: 'Start',
                        height: 40,
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        onPressed: () {
                          // Navigate to Workout Details & Logging screen
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => WorkoutLoggingScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildTaskItem(
                      context,
                      icon: Icons.local_fire_department,
                      title: 'Calorie Goal',
                      subtitle: '1,800 / 2,500 kcal',
                      actionButton: IconButton(
                        icon: Icon(
                          Icons.add_circle,
                          color: AppColors.primary,
                          size: 28,
                        ),
                        onPressed: () {
                          // Navigate to Daily Macro/Calorie Goals screen
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const DailyMacroGoalsScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildTaskItem(
                      context,
                      icon: Icons.water_drop,
                      title: 'Water Goal',
                      subtitle: '2.1 / 3.5 L',
                      actionButton: IconButton(
                        icon: Icon(
                          Icons.add_circle,
                          color: AppColors.primary,
                          size: 28,
                        ),
                        onPressed: () {
                          // Navigate to Water Tracker screen
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => WaterTrackerScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildTaskItem(
                      context,
                      icon: Icons.directions_walk,
                      title: 'Daily Steps',
                      subtitle: '8,204 / 10,000',
                      actionButton: IconButton(
                        icon: Icon(
                          Icons.add_circle,
                          color: AppColors.primary,
                          size: 28,
                        ),
                        onPressed: () {
                          // Navigate to Steps Logging screen
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const StepsLoggingScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
            // Bottom Navigation
            Container(
              decoration: BoxDecoration(
                color: AppColors.backgroundDark.withOpacity(0.95),
                border: Border(
                  top: BorderSide(
                    color: Colors.white.withOpacity(0.1),
                  ),
                ),
              ),
              child: SafeArea(
                top: false,
                child: Container(
                  height: 80,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildNavItem(context, Icons.home, 'Today', isActive: true),
                      _buildNavItem(context, Icons.event_note, 'Plan', onTap: () {
                        // Navigate to Assigned Workouts List
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const AssignedWorkoutsListScreen(),
                          ),
                        );
                      }),
                      _buildNavItem(context, Icons.analytics, 'Analytics', onTap: () {
                        // Navigate to Overall Body Analytics
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const OverallBodyAnalyticsScreen(),
                          ),
                        );
                      }),
                      _buildNavItem(context, Icons.person, 'Profile', onTap: () {
                        // Show profile menu with options
                        _showProfileMenu(context);
                      }),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget actionButton,
  }) {
    return AppCard(
      backgroundColor: AppColors.cardDark,
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primary20,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: AppColors.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                      ),
                ),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondaryDark,
                      ),
                ),
              ],
            ),
          ),
          actionButton,
        ],
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    IconData icon,
    String label, {
    bool isActive = false,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: isActive
                ? AppColors.primary
                : Colors.grey[500],
            size: 28,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: isActive
                      ? AppColors.primary
                      : Colors.grey[500],
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                ),
          ),
        ],
      ),
    );
  }

  void _showProfileMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.trending_up, color: AppColors.primary),
              title: const Text('Body Analytics', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const OverallBodyAnalyticsScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.emoji_events, color: AppColors.primary),
              title: const Text('Trophy Case', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const PersonalRecordsScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.people, color: AppColors.primary),
              title: const Text('Leaderboards', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const CommunityLeaderboardsScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.workspace_premium, color: AppColors.primary),
              title: const Text('Badges', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const PersonalBadgesScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings, color: AppColors.primary),
              title: const Text('Settings', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const GeneralSettingsScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
