import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/common/app_icon_button.dart';
import '../../../widgets/common/app_card.dart';

class PersonalRecordsScreen extends StatefulWidget {
  const PersonalRecordsScreen({super.key});

  @override
  State<PersonalRecordsScreen> createState() => _PersonalRecordsScreenState();
}

class _PersonalRecordsScreenState extends State<PersonalRecordsScreen> {
  int _selectedFilter = 0; // 0 = All, 1 = PRs, 2 = Streaks, 3 = Badges

  final List<String> _filters = ['All', 'PRs', 'Streaks', 'Badges'];

  final List<Achievement> _newAchievements = [
    Achievement(
      type: AchievementType.pr,
      title: '100 kg',
      subtitle: 'Bench Press PR',
      date: DateTime(2023, 12, 1),
      icon: Icons.fitness_center,
      isNew: true,
    ),
    Achievement(
      type: AchievementType.streak,
      title: '7 Day Streak',
      subtitle: 'Workout Consistency',
      date: DateTime(2023, 12, 7),
      icon: Icons.local_fire_department,
      isNew: true,
    ),
  ];

  final List<Achievement> _allAchievements = [
    Achievement(
      type: AchievementType.pr,
      title: '140 kg',
      subtitle: 'Squat PR',
      date: DateTime(2023, 11, 25),
      icon: Icons.fitness_center,
      isNew: false,
    ),
    Achievement(
      type: AchievementType.milestone,
      title: 'First 10k Run',
      subtitle: 'Milestone',
      date: DateTime(2023, 11, 18),
      icon: Icons.directions_run,
      isNew: false,
    ),
    Achievement(
      type: AchievementType.pr,
      title: '180 kg',
      subtitle: 'Deadlift PR',
      date: DateTime(2023, 10, 30),
      icon: Icons.sports_gymnastics,
      isNew: false,
    ),
    Achievement(
      type: AchievementType.badge,
      title: '50 Workouts',
      subtitle: 'Completed',
      date: DateTime(2023, 10, 15),
      icon: Icons.check_circle,
      isNew: false,
    ),
  ];

  List<Achievement> get _filteredAchievements {
    if (_selectedFilter == 0) {
      return _allAchievements;
    } else if (_selectedFilter == 1) {
      return _allAchievements.where((a) => a.type == AchievementType.pr).toList();
    } else if (_selectedFilter == 2) {
      return _allAchievements.where((a) => a.type == AchievementType.streak).toList();
    } else {
      return _allAchievements.where((a) => a.type == AchievementType.badge).toList();
    }
  }

  String _formatDate(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final day = date.day;
    String suffix = 'th';
    if (day == 1 || day == 21 || day == 31) suffix = 'st';
    if (day == 2 || day == 22) suffix = 'nd';
    if (day == 3 || day == 23) suffix = 'rd';
    return '${months[date.month - 1]} ${day}$suffix, ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: SafeArea(
        child: Column(
          children: [
            // Top Header
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  AppIconButton(
                    icon: Icons.arrow_back_ios_new,
                    onPressed: () => Navigator.of(context).pop(),
                    iconColor: Colors.white,
                  ),
                  Expanded(
                    child: Text(
                      'Trophy Case',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  AppIconButton(
                    icon: Icons.share,
                    onPressed: () {
                      // Share achievements
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Share feature coming soon'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
                    iconColor: Colors.white,
                  ),
                ],
              ),
            ),
            // Filter Tabs
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                children: _filters.asMap().entries.map((entry) {
                  final index = entry.key;
                  final label = entry.value;
                  final isSelected = _selectedFilter == index;
                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(right: index < _filters.length - 1 ? 8 : 0),
                      child: GestureDetector(
                        onTap: () {
                          setState(() => _selectedFilter = index);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.cardDark,
                            borderRadius: BorderRadius.circular(AppTheme.radiusDefault),
                          ),
                          child: Text(
                            label,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: isSelected
                                      ? AppColors.backgroundDark
                                      : Colors.white,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            // Content
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  // New Achievements Section
                  if (_newAchievements.isNotEmpty) ...[
                    Text(
                      'New Achievements',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 12),
                    ..._newAchievements.map((achievement) => Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: _buildAchievementCard(achievement),
                        )),
                    const SizedBox(height: 32),
                  ],
                  // All Personal Records Section
                  Text(
                    'All Personal Records',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 12),
                  ..._filteredAchievements.map((achievement) => Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: _buildAchievementCard(achievement),
                      )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAchievementCard(Achievement achievement) {
    return GestureDetector(
      onTap: () {
        // Show achievement details
      },
      child: Container(
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          color: AppColors.cardDark,
          borderRadius: BorderRadius.circular(AppTheme.radiusDefault),
        ),
        child: Stack(
          children: [
            Row(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: AppColors.primary20,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    achievement.icon,
                    color: AppColors.primary,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        achievement.title,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        achievement.subtitle,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: const Color(0xFF8E8E93),
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatDate(achievement.date),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: const Color(0xFF8E8E93),
                              fontSize: 12,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (achievement.isNew)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                  ),
                  child: Text(
                    'NEW',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.backgroundDark,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

enum AchievementType {
  pr,
  streak,
  badge,
  milestone,
}

class Achievement {
  final AchievementType type;
  final String title;
  final String subtitle;
  final DateTime date;
  final IconData icon;
  final bool isNew;

  Achievement({
    required this.type,
    required this.title,
    required this.subtitle,
    required this.date,
    required this.icon,
    this.isNew = false,
  });
}
