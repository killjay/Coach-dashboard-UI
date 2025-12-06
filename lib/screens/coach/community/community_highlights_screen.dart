import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/common/app_icon_button.dart';
import '../../../widgets/common/app_card.dart';

class CommunityHighlightsScreen extends StatelessWidget {
  const CommunityHighlightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final topPerformers = [
      {'name': 'Alex Johnson', 'score': 95, 'metric': 'Workout Consistency'},
      {'name': 'Sarah Williams', 'score': 92, 'metric': 'Diet Adherence'},
      {'name': 'Mike Chen', 'score': 88, 'metric': 'Monthly Steps'},
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
                      'Community Highlights',
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
            // Content
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  Text(
                    'Top Performers This Week',
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          color: isDark ? Colors.white : Colors.black,
                        ),
                  ),
                  const SizedBox(height: 16),
                  ...topPerformers.asMap().entries.map((entry) {
                    final index = entry.key;
                    final performer = entry.value;
                    return Padding(
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
                                  '${index + 1}',
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    performer['name'] as String,
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                          color: isDark ? Colors.white : Colors.black,
                                        ),
                                  ),
                                  Text(
                                    performer['metric'] as String,
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                                        ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              '${performer['score']}%',
                              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}




