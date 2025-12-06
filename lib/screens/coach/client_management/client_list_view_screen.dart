import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/common/app_icon_button.dart';
import '../../../widgets/common/app_card.dart';

class ClientListViewScreen extends StatelessWidget {
  const ClientListViewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final clients = [
      {'name': 'Alex Johnson', 'lastLogin': '2 hours ago', 'compliance': 85, 'status': 'active'},
      {'name': 'Sarah Williams', 'lastLogin': '1 day ago', 'compliance': 92, 'status': 'active'},
      {'name': 'Mike Chen', 'lastLogin': '3 days ago', 'compliance': 68, 'status': 'active'},
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
                  Expanded(
                    child: Text(
                      'Clients',
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                            color: isDark ? Colors.white : Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  AppIconButton(
                    icon: Icons.search,
                    onPressed: () {},
                    iconColor: isDark ? Colors.white : Colors.black,
                  ),
                ],
              ),
            ),
            // Client List
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  ...clients.map((client) => Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: AppCard(
                          backgroundColor: isDark ? Colors.white.withOpacity(0.1) : Colors.grey[100],
                          padding: const EdgeInsets.all(16.0),
                          onTap: () {
                            // Navigate to client profile
                          },
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 24,
                                backgroundColor: AppColors.primary20,
                                child: Text(
                                  (client['name'] as String)[0],
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      client['name'] as String,
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                            color: isDark ? Colors.white : Colors.black,
                                          ),
                                    ),
                                    Text(
                                      'Last login: ${client['lastLogin']}',
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '${client['compliance']}%',
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                  Text(
                                    'Compliance',
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                                        ),
                                  ),
                                ],
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




