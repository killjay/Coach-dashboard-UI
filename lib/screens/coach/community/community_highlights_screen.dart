import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/common/app_icon_button.dart';
import '../../../widgets/common/app_card.dart';
import '../../../widgets/common/primary_button.dart';
import '../../client/community/community_leaderboards_screen.dart';

class CommunityHighlightsScreen extends StatefulWidget {
  const CommunityHighlightsScreen({super.key});

  @override
  State<CommunityHighlightsScreen> createState() => _CommunityHighlightsScreenState();
}

class _CommunityHighlightsScreenState extends State<CommunityHighlightsScreen> {
  int _selectedTimeframe = 0; // 0 = This Week, 1 = Last Week

  final List<PerformerData> _thisWeekPerformers = [
    PerformerData(
      name: 'Eleanor Pena',
      achievement: 'Highest Progress Score',
      score: 98,
      rank: 1,
    ),
    PerformerData(
      name: 'Alex Morgan',
      achievement: 'Most Workouts Completed',
      score: 95,
      rank: 2,
    ),
    PerformerData(
      name: 'Sarah Williams',
      achievement: 'Best Diet Adherence',
      score: 92,
      rank: 3,
    ),
  ];

  final List<PerformerData> _lastWeekPerformers = [
    PerformerData(
      name: 'Mike Chen',
      achievement: 'Highest Progress Score',
      score: 96,
      rank: 1,
    ),
    PerformerData(
      name: 'Emma Thompson',
      achievement: 'Most Workouts Completed',
      score: 94,
      rank: 2,
    ),
    PerformerData(
      name: 'James Anderson',
      achievement: 'Best Diet Adherence',
      score: 91,
      rank: 3,
    ),
  ];

  List<PerformerData> get _currentPerformers {
    return _selectedTimeframe == 0 ? _thisWeekPerformers : _lastWeekPerformers;
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
                      'Community Highlights',
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
            // Timeframe Segmented Control
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.cardDark,
                  borderRadius: BorderRadius.circular(AppTheme.radiusDefault),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedTimeframe = 0;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: _selectedTimeframe == 0
                                ? AppColors.primary
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(AppTheme.radiusDefault),
                          ),
                          child: Text(
                            'This Week',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: _selectedTimeframe == 0
                                      ? Colors.white
                                      : AppColors.textSecondaryDark,
                                  fontWeight: _selectedTimeframe == 0
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedTimeframe = 1;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: _selectedTimeframe == 1
                                ? AppColors.primary
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(AppTheme.radiusDefault),
                          ),
                          child: Text(
                            'Last Week',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: _selectedTimeframe == 1
                                      ? Colors.white
                                      : AppColors.textSecondaryDark,
                                  fontWeight: _selectedTimeframe == 1
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Top Performers List
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  ..._currentPerformers.map((performer) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: _buildPerformerCard(performer),
                    );
                  }),
                  const SizedBox(height: 24),
                  // See Full Leaderboard Link
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const CommunityLeaderboardsScreen(),
                        ),
                      );
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'See Full Leaderboard',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.arrow_forward,
                          color: AppColors.primary,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).padding.bottom),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformerCard(PerformerData performer) {
    return AppCard(
      backgroundColor: AppColors.cardDark,
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Rank Badge
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primary20,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${performer.rank}',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Profile Picture
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.primary20,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    performer.name[0],
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Client Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      performer.name,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      performer.achievement,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondaryDark,
                          ),
                    ),
                  ],
                ),
              ),
              // Performance Metric
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${performer.score}%',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Congratulate Button
          SizedBox(
            width: double.infinity,
            child: PrimaryButton(
              text: 'Congratulate',
              icon: Icons.celebration,
              onPressed: () {
                _sendCongratulation(performer.name);
              },
            ),
          ),
        ],
      ),
    );
  }

  void _sendCongratulation(String clientName) {
    // In production, this would open a chat composer pre-filled for the client
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening chat with $clientName...'),
        backgroundColor: AppColors.primary,
        duration: const Duration(seconds: 1),
      ),
    );
  }
}

class PerformerData {
  final String name;
  final String achievement;
  final int score;
  final int rank;

  PerformerData({
    required this.name,
    required this.achievement,
    required this.score,
    required this.rank,
  });
}
