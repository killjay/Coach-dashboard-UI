import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/common/app_icon_button.dart';
import '../../../widgets/common/app_card.dart';

class CommunityLeaderboardsScreen extends StatefulWidget {
  const CommunityLeaderboardsScreen({super.key});

  @override
  State<CommunityLeaderboardsScreen> createState() => _CommunityLeaderboardsScreenState();
}

class _CommunityLeaderboardsScreenState extends State<CommunityLeaderboardsScreen> {
  int _selectedCategory = 0; // 0 = Daily Steps, 1 = Monthly Steps, 2 = Workout Consistency
  final List<String> _categories = ['Daily Steps', 'Monthly Steps', 'Workout Consistency'];

  // Mock data
  final List<LeaderboardEntry> _entries = [
    LeaderboardEntry(
      rank: 1,
      name: 'Elara Vance',
      profilePicture: null,
      metric: '15,890 steps',
      progressScore: 98,
    ),
    LeaderboardEntry(
      rank: 2,
      name: 'Kenji Tanaka',
      profilePicture: null,
      metric: '14,500 steps',
      progressScore: 95,
    ),
    LeaderboardEntry(
      rank: 3,
      name: 'Maya Patel',
      profilePicture: null,
      metric: '13,200 steps',
      progressScore: 92,
    ),
    LeaderboardEntry(
      rank: 4,
      name: 'Alex Rivera',
      profilePicture: null,
      metric: '12,800 steps',
      progressScore: 88,
    ),
    LeaderboardEntry(
      rank: 5,
      name: 'Sam Chen',
      profilePicture: null,
      metric: '11,500 steps',
      progressScore: 85,
    ),
    LeaderboardEntry(
      rank: 6,
      name: 'Jordan Lee',
      profilePicture: null,
      metric: '10,200 steps',
      progressScore: 82,
    ),
    LeaderboardEntry(
      rank: 7,
      name: 'Taylor Kim',
      profilePicture: null,
      metric: '9,800 steps',
      progressScore: 80,
    ),
    LeaderboardEntry(
      rank: 8,
      name: 'Casey Brown',
      profilePicture: null,
      metric: '9,100 steps',
      progressScore: 78,
    ),
    LeaderboardEntry(
      rank: 9,
      name: 'Riley Davis',
      profilePicture: null,
      metric: '8,500 steps',
      progressScore: 76,
    ),
  ];

  final LeaderboardEntry _currentUser = LeaderboardEntry(
    rank: 10,
    name: 'You',
    profilePicture: null,
    metric: '8,230 steps',
    progressScore: 75,
  );

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
                      'Community Leaderboards',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  AppIconButton(
                    icon: Icons.search,
                    onPressed: () {
                      // Show search
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Search feature coming soon'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
                    iconColor: Colors.white,
                  ),
                ],
              ),
            ),
            // Category Tabs
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                children: _categories.asMap().entries.map((entry) {
                  final index = entry.key;
                  final label = entry.value;
                  final isSelected = _selectedCategory == index;
                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(right: index < _categories.length - 1 ? 8 : 0),
                      child: GestureDetector(
                        onTap: () {
                          setState(() => _selectedCategory = index);
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
                                  fontSize: 12,
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
            // Leaderboard List
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  ..._entries.map((entry) => Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: _buildLeaderboardEntry(entry, isCurrentUser: false),
                      )),
                  const SizedBox(height: 12),
                  // "You" Entry (sticky style)
                  _buildLeaderboardEntry(_currentUser, isCurrentUser: true),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeaderboardEntry(LeaderboardEntry entry, {required bool isCurrentUser}) {
    final isTopRank = entry.rank <= 3;

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: isCurrentUser
            ? AppColors.primary20
            : AppColors.cardDark,
        borderRadius: BorderRadius.circular(AppTheme.radiusDefault),
        border: isCurrentUser
            ? Border.all(color: AppColors.primary, width: 2)
            : null,
      ),
      child: Row(
        children: [
          // Rank Number
          Container(
            width: 40,
            alignment: Alignment.center,
            child: Text(
              '${entry.rank}',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: isTopRank
                        ? AppColors.primary
                        : Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
            ),
          ),
          const SizedBox(width: 12),
          // Profile Picture
          CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.primary20,
            child: entry.profilePicture != null
                ? ClipOval(child: Image.network(entry.profilePicture!))
                : Icon(
                    Icons.person,
                    color: AppColors.primary,
                    size: 24,
                  ),
          ),
          const SizedBox(width: 12),
          // Name and Metric
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  entry.metric,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: const Color(0xFF8E8E93),
                      ),
                ),
              ],
            ),
          ),
          // Progress Score
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '${entry.progressScore}',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppColors.backgroundDark,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class LeaderboardEntry {
  final int rank;
  final String name;
  final String? profilePicture;
  final String metric;
  final int progressScore;

  LeaderboardEntry({
    required this.rank,
    required this.name,
    this.profilePicture,
    required this.metric,
    required this.progressScore,
  });
}

