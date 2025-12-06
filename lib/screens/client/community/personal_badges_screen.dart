import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/common/app_icon_button.dart';
import '../../../widgets/common/app_card.dart';
import '../dashboard/today_view_screen.dart';
import 'community_leaderboards_screen.dart';

class PersonalBadgesScreen extends StatefulWidget {
  const PersonalBadgesScreen({super.key});

  @override
  State<PersonalBadgesScreen> createState() => _PersonalBadgesScreenState();
}

class _PersonalBadgesScreenState extends State<PersonalBadgesScreen> {
  int _selectedFilter = 0; // 0 = Earned, 1 = Locked
  final List<String> _filters = ['Earned', 'Locked'];

  final int _earnedBadges = 12;
  final int _totalBadges = 50;

  final List<Badge> _earnedBadgesList = [
    Badge(
      name: '7 Day Streak',
      icon: '7',
      isEarned: true,
      dateEarned: DateTime(2023, 12, 7),
    ),
    Badge(
      name: '100k Steps Club',
      icon: '100K',
      isEarned: true,
      dateEarned: DateTime(2023, 11, 28),
    ),
    Badge(
      name: 'Perfect Week',
      icon: '✓',
      isEarned: true,
      dateEarned: DateTime(2023, 11, 20),
    ),
    Badge(
      name: 'First 5k',
      icon: '5K',
      isEarned: true,
      dateEarned: DateTime(2023, 11, 15),
    ),
    Badge(
      name: 'Early Riser',
      icon: '🌅',
      isEarned: true,
      dateEarned: DateTime(2023, 11, 10),
    ),
    Badge(
      name: 'Mountain Climber',
      icon: '⛰️',
      isEarned: true,
      dateEarned: DateTime(2023, 11, 5),
    ),
    Badge(
      name: 'Consistency King',
      icon: '👑',
      isEarned: true,
      dateEarned: DateTime(2023, 10, 30),
    ),
    Badge(
      name: 'Weekend Warrior',
      icon: '⚔️',
      isEarned: true,
      dateEarned: DateTime(2023, 10, 25),
    ),
    Badge(
      name: 'Speed Demon',
      icon: '💨',
      isEarned: true,
      dateEarned: DateTime(2023, 10, 20),
    ),
    Badge(
      name: 'Iron Will',
      icon: '💪',
      isEarned: true,
      dateEarned: DateTime(2023, 10, 15),
    ),
    Badge(
      name: 'Night Owl',
      icon: '🦉',
      isEarned: true,
      dateEarned: DateTime(2023, 10, 10),
    ),
    Badge(
      name: 'Marathon Runner',
      icon: '🏃',
      isEarned: true,
      dateEarned: DateTime(2023, 10, 5),
    ),
  ];

  final List<Badge> _lockedBadgesList = [
    Badge(
      name: 'Hydration Hero',
      icon: '💧',
      isEarned: false,
      unlockCriteria: 'Log 7 consecutive days of water goals',
    ),
    Badge(
      name: 'Workout Warrior',
      icon: '⚔️',
      isEarned: false,
      unlockCriteria: 'Complete 100 workouts',
    ),
    Badge(
      name: 'Century Club',
      icon: '100',
      isEarned: false,
      unlockCriteria: 'Reach 100 days of activity',
    ),
    Badge(
      name: 'Perfect Month',
      icon: '📅',
      isEarned: false,
      unlockCriteria: 'Complete all workouts in a month',
    ),
  ];

  List<Badge> get _displayedBadges {
    return _selectedFilter == 0 ? _earnedBadgesList : _lockedBadgesList;
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
                      'Personal Badges',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(width: 40),
                ],
              ),
            ),
            // Badge Count & Filter Tabs
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Column(
                children: [
                  Text(
                    '$_earnedBadges / $_totalBadges Badges Collected',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 12),
                  Row(
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
                ],
              ),
            ),
            // Badge Gallery
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(16.0),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: _displayedBadges.length,
                itemBuilder: (context, index) {
                  final badge = _displayedBadges[index];
                  return _buildBadgeCard(badge);
                },
              ),
            ),
            // Bottom Navigation Bar
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              decoration: BoxDecoration(
                color: AppColors.backgroundDark,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(Icons.home, 'Home', () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => const TodayViewScreen()),
                    );
                  }, false),
                  _buildNavItem(Icons.fitness_center, 'Workouts', () {
                    // Navigate to workouts
                  }, false),
                  _buildNavItem(Icons.emoji_events, 'Badges', () {}, true),
                  _buildNavItem(Icons.people, 'Community', () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const CommunityLeaderboardsScreen()),
                    );
                  }, false),
                  _buildNavItem(Icons.person, 'Profile', () {
                    // Navigate to profile
                  }, false),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadgeCard(Badge badge) {
    return GestureDetector(
      onTap: () {
        _showBadgeDetails(badge);
      },
      child: Container(
        decoration: BoxDecoration(
          color: badge.isEarned
              ? AppColors.cardDark
              : AppColors.cardDark.withOpacity(0.5),
          borderRadius: BorderRadius.circular(AppTheme.radiusDefault),
          border: badge.isEarned
              ? Border.all(color: AppColors.primary.withOpacity(0.3), width: 1)
              : null,
        ),
        child: Stack(
          children: [
            // Background decoration for earned badges
            if (badge.isEarned)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppTheme.radiusDefault),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.primary20.withOpacity(0.3),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            // Content
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: badge.isEarned
                          ? AppColors.primary20
                          : Colors.white.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        badge.icon,
                        style: TextStyle(
                          color: badge.isEarned
                              ? AppColors.primary
                              : const Color(0xFF8E8E93),
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    badge.name,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: badge.isEarned
                              ? Colors.white
                              : const Color(0xFF8E8E93),
                          fontWeight: FontWeight.bold,
                        ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, VoidCallback onTap, bool isActive) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isActive ? AppColors.primary : const Color(0xFF8E8E93),
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: isActive ? AppColors.primary : const Color(0xFF8E8E93),
                  fontSize: 10,
                ),
          ),
        ],
      ),
    );
  }

  void _showBadgeDetails(Badge badge) {
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
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: badge.isEarned
                    ? AppColors.primary20
                    : Colors.white.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  badge.icon,
                  style: TextStyle(
                    color: badge.isEarned
                        ? AppColors.primary
                        : const Color(0xFF8E8E93),
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              badge.name,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            if (badge.isEarned && badge.dateEarned != null)
              Text(
                'Earned on ${_formatDate(badge.dateEarned!)}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF8E8E93),
                    ),
              )
            else if (badge.unlockCriteria != null)
              Text(
                badge.unlockCriteria!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF8E8E93),
                    ),
                textAlign: TextAlign.center,
              ),
            const SizedBox(height: 24),
            if (badge.isEarned)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    // Share badge
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                    ),
                  ),
                  child: const Text(
                    'Share Achievement',
                    style: TextStyle(
                      color: AppColors.backgroundDark,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}

class Badge {
  final String name;
  final String icon;
  final bool isEarned;
  final DateTime? dateEarned;
  final String? unlockCriteria;

  Badge({
    required this.name,
    required this.icon,
    required this.isEarned,
    this.dateEarned,
    this.unlockCriteria,
  });
}

