import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/common/progress_ring.dart';
import '../../../widgets/common/primary_button.dart';
import '../../../widgets/common/app_card.dart';
import '../workouts/workout_logging_screen.dart';
import '../tracking/water_tracker_screen.dart';

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
                  // Profile Picture - Tappable
                  GestureDetector(
                    onTap: () {
                      // Navigate to Profile screen
                      // TODO: Implement Profile screen navigation
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Profile screen coming soon'),
                          duration: Duration(seconds: 1),
                        ),
                      );
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
                          color: Colors.white,
                          size: 28,
                        ),
                        onPressed: () {
                          // Navigate to Manual Food Logging screen
                          // TODO: Implement Food Logging screen navigation
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Food logging screen coming soon'),
                              duration: Duration(seconds: 1),
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
                          color: Colors.white,
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
                          Icons.check_circle,
                          color: AppColors.primary,
                          size: 28,
                        ),
                        onPressed: null, // Non-interactive as steps are auto-tracked
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
                        // Navigate to Assigned Workouts List or Plans Overview
                        // TODO: Implement Plan screen navigation
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Plan screen coming soon'),
                            duration: Duration(seconds: 1),
                          ),
                        );
                      }),
                      _buildNavItem(context, Icons.chat, 'Chat', onTap: () {
                        // Navigate to Coach-Client Chat screen
                        // TODO: Implement Chat screen navigation
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Chat screen coming soon'),
                            duration: Duration(seconds: 1),
                          ),
                        );
                      }),
                      _buildNavItem(context, Icons.person, 'Profile', onTap: () {
                        // Navigate to Profile screen
                        // TODO: Implement Profile screen navigation
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Profile screen coming soon'),
                            duration: Duration(seconds: 1),
                          ),
                        );
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
}
