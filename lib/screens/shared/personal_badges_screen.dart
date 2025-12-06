import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common/app_icon_button.dart';
import '../../widgets/common/app_card.dart';

class PersonalBadgesScreen extends StatelessWidget {
  const PersonalBadgesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final badges = [
      {'name': '7 Day Streak', 'icon': Icons.local_fire_department, 'earned': true},
      {'name': '100k Steps Club', 'icon': Icons.directions_walk, 'earned': true},
      {'name': 'Perfect Week', 'icon': Icons.star, 'earned': false},
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
                      'Badges',
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
            // Badge Grid
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(16.0),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: badges.length,
                itemBuilder: (context, index) {
                  final badge = badges[index];
                  final isEarned = badge['earned'] as bool;

                  return AppCard(
                    backgroundColor: isDark ? Colors.white.withOpacity(0.1) : Colors.grey[100],
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          badge['icon'] as IconData,
                          size: 48,
                          color: isEarned ? AppColors.primary : Colors.grey[400],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          badge['name'] as String,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: isEarned
                                    ? (isDark ? Colors.white : Colors.black)
                                    : Colors.grey[400],
                                fontWeight: isEarned ? FontWeight.bold : FontWeight.normal,
                              ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}




