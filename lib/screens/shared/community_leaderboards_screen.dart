import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common/app_icon_button.dart';
import '../../widgets/common/app_card.dart';

class CommunityLeaderboardsScreen extends StatelessWidget {
  const CommunityLeaderboardsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final leaderboard = [
      {'rank': 1, 'name': 'Alex Johnson', 'score': 95},
      {'rank': 2, 'name': 'Sarah Williams', 'score': 92},
      {'rank': 3, 'name': 'Mike Chen', 'score': 88},
    ];

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
                      'Leaderboard',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: isDark ? Colors.white : Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(width: 40),
                ],
              ),
            ),
            // Leaderboard List
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  ...leaderboard.map((entry) => Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: AppCard(
                          backgroundColor: isDark ? Colors.white.withOpacity(0.1) : Colors.grey[100],
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: AppColors.primary20,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Center(
                                  child: Text(
                                    '${entry['rank']}',
                                    style: TextStyle(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  entry['name'] as String,
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        color: isDark ? Colors.white : Colors.black,
                                      ),
                                ),
                              ),
                              Text(
                                '${entry['score']}%',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}




