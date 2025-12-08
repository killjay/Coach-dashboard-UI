import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/common/app_icon_button.dart';
import '../../../widgets/common/app_card.dart';
import '../../../widgets/common/primary_button.dart';
import '../plan_creation/workout_template_builder_screen.dart';
import '../plan_creation/diet_plan_builder_screen.dart';
import '../plan_creation/assign_plans_screen.dart';
import '../client_management/client_list_view_screen.dart';
import '../analytics/compliance_dashboard_screen.dart';
import '../community/community_highlights_screen.dart';
import '../../shared/general_settings_screen.dart';

class PlansOverviewScreen extends StatefulWidget {
  const PlansOverviewScreen({super.key});

  @override
  State<PlansOverviewScreen> createState() => _PlansOverviewScreenState();
}

class _PlansOverviewScreenState extends State<PlansOverviewScreen> {
  int _selectedTab = 0; // 0 = Workout Templates, 1 = Diet Plans
  final TextEditingController _searchController = TextEditingController();

  // Mock data for workout templates
  final List<WorkoutTemplate> _workoutTemplates = [
    WorkoutTemplate(
      name: 'Full Body Strength - Phase 1',
      description: '4-Week Program, 3 Workouts/Week',
      icon: Icons.fitness_center,
      exerciseCount: 5,
      duration: '30-45 min',
    ),
    WorkoutTemplate(
      name: 'Cardio Burn',
      description: '5-Week Program, 4 Workouts/Week',
      icon: Icons.directions_run,
      exerciseCount: 6,
      duration: '45-60 min',
    ),
    WorkoutTemplate(
      name: 'Upper Body Focus',
      description: '6-Week Program, 2 Workouts/Week',
      icon: Icons.sports_gymnastics,
      exerciseCount: 4,
      duration: '30-40 min',
    ),
  ];

  // Mock data for diet plans
  final List<DietPlan> _dietPlans = [
    DietPlan(
      name: 'Muscle Gain Diet',
      description: 'Calorie Surplus, 3200 kcal/day',
      icon: Icons.restaurant,
      calories: 3200,
      protein: 200,
    ),
    DietPlan(
      name: 'Keto Phase 1',
      description: '2000 kcal, 150g Protein',
      icon: Icons.restaurant_menu,
      calories: 2000,
      protein: 150,
    ),
    DietPlan(
      name: 'Maintenance Phase',
      description: '2500 kcal, 180g Protein',
      icon: Icons.lunch_dining,
      calories: 2500,
      protein: 180,
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
                  const SizedBox(width: 40),
                  Expanded(
                    child: Text(
                      'Plans',
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
                      // TODO: Implement search functionality
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Search functionality coming soon'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
                    iconColor: Colors.white,
                  ),
                ],
              ),
            ),
            // Segmented Control (Tabs)
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
                            _selectedTab = 0;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: _selectedTab == 0
                                ? AppColors.primary
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(AppTheme.radiusDefault),
                          ),
                          child: Text(
                            'Workout Templates',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: _selectedTab == 0
                                      ? Colors.white
                                      : AppColors.textSecondaryDark,
                                  fontWeight: _selectedTab == 0
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
                            _selectedTab = 1;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: _selectedTab == 1
                                ? AppColors.primary
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(AppTheme.radiusDefault),
                          ),
                          child: Text(
                            'Diet Plans',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: _selectedTab == 1
                                      ? Colors.white
                                      : AppColors.textSecondaryDark,
                                  fontWeight: _selectedTab == 1
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
            const SizedBox(height: 12),
            // Content List
            Expanded(
              child: _selectedTab == 0
                  ? _buildWorkoutTemplatesList()
                  : _buildDietPlansList(),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_selectedTab == 0) {
            // Navigate to Workout Template Builder
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const WorkoutTemplateBuilderScreen(),
              ),
            );
          } else {
            // Navigate to Diet Plan Builder
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const DietPlanBuilderScreen(),
              ),
            );
          }
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: AppColors.backgroundDark),
      ),
      bottomNavigationBar: _buildBottomNavigation(context),
    );
  }

  Widget _buildWorkoutTemplatesList() {
    if (_workoutTemplates.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.cardDark,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.assignment,
                  size: 40,
                  color: AppColors.textSecondaryDark,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'No Workout Templates Yet',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Tap the \'+\' button to create your first reusable workout plan for your clients.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondaryDark,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: _workoutTemplates.length,
      itemBuilder: (context, index) {
        final template = _workoutTemplates[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: _buildWorkoutTemplateCard(template),
        );
      },
    );
  }

  Widget _buildWorkoutTemplateCard(WorkoutTemplate template) {
    return AppCard(
      backgroundColor: AppColors.cardDark,
      padding: const EdgeInsets.all(16.0),
      onTap: () {
        // Navigate to Workout Template Builder with template data
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => const WorkoutTemplateBuilderScreen(),
          ),
        );
      },
      child: Row(
        children: [
          // Icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primary20,
              borderRadius: BorderRadius.circular(AppTheme.radiusDefault),
            ),
            child: Icon(
              template.icon,
              color: AppColors.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          // Template Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  template.name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  template.description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondaryDark,
                      ),
                ),
              ],
            ),
          ),
          // Chevron
          Icon(
            Icons.chevron_right,
            color: AppColors.textSecondaryDark,
            size: 24,
          ),
        ],
      ),
    );
  }

  Widget _buildDietPlansList() {
    if (_dietPlans.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.cardDark,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.restaurant_menu,
                  size: 40,
                  color: AppColors.textSecondaryDark,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'No Diet Plans Yet',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Tap the \'+\' button to create your first diet plan template for your clients.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondaryDark,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: _dietPlans.length,
      itemBuilder: (context, index) {
        final plan = _dietPlans[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: _buildDietPlanCard(plan),
        );
      },
    );
  }

  Widget _buildDietPlanCard(DietPlan plan) {
    return AppCard(
      backgroundColor: AppColors.cardDark,
      padding: const EdgeInsets.all(16.0),
      onTap: () {
        // Navigate to Diet Plan Builder with plan data
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => const DietPlanBuilderScreen(),
          ),
        );
      },
      child: Row(
        children: [
          // Icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primary20,
              borderRadius: BorderRadius.circular(AppTheme.radiusDefault),
            ),
            child: Icon(
              plan.icon,
              color: AppColors.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          // Plan Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  plan.name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  plan.description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondaryDark,
                      ),
                ),
              ],
            ),
          ),
          // Chevron
          Icon(
            Icons.chevron_right,
            color: AppColors.textSecondaryDark,
            size: 24,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigation(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundDark.withOpacity(0.95),
        border: Border(
          top: BorderSide(color: Colors.white.withOpacity(0.1)),
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
              _buildNavItem(
                context,
                Icons.people,
                'Clients',
                onTap: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (_) => const ClientListViewScreen(),
                    ),
                  );
                },
              ),
              _buildNavItem(
                context,
                Icons.event_note,
                'Plans',
                isActive: true,
              ),
              _buildNavItem(
                context,
                Icons.analytics,
                'Analytics',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const ComplianceDashboardScreen(),
                    ),
                  );
                },
              ),
              _buildNavItem(
                context,
                Icons.people_outline,
                'Community',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const CommunityHighlightsScreen(),
                    ),
                  );
                },
              ),
              _buildNavItem(
                context,
                Icons.settings,
                'Settings',
                onTap: () {
                  // Navigate to General Settings
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

class WorkoutTemplate {
  final String name;
  final String description;
  final IconData icon;
  final int exerciseCount;
  final String duration;

  WorkoutTemplate({
    required this.name,
    required this.description,
    required this.icon,
    required this.exerciseCount,
    required this.duration,
  });
}

class DietPlan {
  final String name;
  final String description;
  final IconData icon;
  final int calories;
  final int protein;

  DietPlan({
    required this.name,
    required this.description,
    required this.icon,
    required this.calories,
    required this.protein,
  });
}

