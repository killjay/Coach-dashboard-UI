import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/common/primary_button.dart';
import '../../../widgets/common/app_icon_button.dart';
import '../../../widgets/common/app_card.dart';
import 'workout_logging_screen.dart';

class AssignedWorkoutsListScreen extends StatefulWidget {
  const AssignedWorkoutsListScreen({super.key});

  @override
  State<AssignedWorkoutsListScreen> createState() => _AssignedWorkoutsListScreenState();
}

class _AssignedWorkoutsListScreenState extends State<AssignedWorkoutsListScreen> {
  DateTime _selectedDate = DateTime.now();
  final ScrollController _dateScrollController = ScrollController();

  // Generate dates for the week (3 days before, today, 3 days after)
  List<DateTime> get _dateRange {
    final today = DateTime.now();
    final dates = <DateTime>[];
    for (int i = -3; i <= 3; i++) {
      dates.add(today.add(Duration(days: i)));
    }
    return dates;
  }

  String _getDayAbbreviation(DateTime date) {
    const days = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
    return days[date.weekday - 1];
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  bool _isTomorrow(DateTime date) {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return date.year == tomorrow.year &&
        date.month == tomorrow.month &&
        date.day == tomorrow.day;
  }

  List<WorkoutData> _getWorkoutsForDate(DateTime date) {
    // Mock data - in production, this would come from a provider/service
    if (_isToday(date)) {
      return [
        WorkoutData(
          name: 'Full Body Strength A',
          status: WorkoutStatus.dueToday,
          icon: Icons.fitness_center,
        ),
        WorkoutData(
          name: 'Morning Run - 5k',
          status: WorkoutStatus.completed,
          icon: Icons.directions_run,
        ),
      ];
    } else if (_isTomorrow(date)) {
      return [
        WorkoutData(
          name: 'Active Recovery & Stretch',
          status: WorkoutStatus.upcoming,
          icon: Icons.self_improvement,
        ),
      ];
    }
    return [];
  }

  @override
  void dispose() {
    _dateScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final workouts = _getWorkoutsForDate(_selectedDate);
    final todayWorkouts = workouts.where((w) => w.status == WorkoutStatus.dueToday || w.status == WorkoutStatus.completed).toList();
    final tomorrowWorkouts = workouts.where((w) => w.status == WorkoutStatus.upcoming).toList();

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
                      'Workouts',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  AppIconButton(
                    icon: Icons.account_circle,
                    onPressed: () {
                      // Navigate to profile
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Profile screen coming soon'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
                    iconColor: Colors.white,
                  ),
                ],
              ),
            ),
            // Horizontal Date Selector
            SizedBox(
              height: 80,
              child: ListView.builder(
                controller: _dateScrollController,
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                itemCount: _dateRange.length,
                itemBuilder: (context, index) {
                  final date = _dateRange[index];
                  final isSelected = date.year == _selectedDate.year &&
                      date.month == _selectedDate.month &&
                      date.day == _selectedDate.day;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedDate = date;
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 12),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.cardDark,
                        borderRadius: BorderRadius.circular(AppTheme.radiusDefault),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _getDayAbbreviation(date),
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: isSelected
                                      ? AppColors.backgroundDark
                                      : const Color(0xFF8E8E93),
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  fontSize: 12,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${date.day}',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: isSelected
                                      ? AppColors.backgroundDark
                                      : Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            // Workout List
            Expanded(
              child: workouts.isEmpty
                  ? _buildEmptyState()
                  : ListView(
                      padding: const EdgeInsets.all(16.0),
                      children: [
                        // Today Section
                        if (todayWorkouts.isNotEmpty) ...[
                          Text(
                            'Today',
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 12),
                          ...todayWorkouts.map((workout) => Padding(
                                padding: const EdgeInsets.only(bottom: 12.0),
                                child: _buildWorkoutCard(workout),
                              )),
                          const SizedBox(height: 32),
                        ],
                        // Tomorrow Section
                        if (tomorrowWorkouts.isNotEmpty) ...[
                          Text(
                            'Tomorrow',
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 12),
                          ...tomorrowWorkouts.map((workout) => Padding(
                                padding: const EdgeInsets.only(bottom: 12.0),
                                child: _buildWorkoutCard(workout),
                              )),
                        ],
                      ],
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Show options modal or navigate to exercise library
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
                  ListTile(
                    leading: const Icon(Icons.add_circle, color: AppColors.primary),
                    title: const Text('Add Custom Workout', style: TextStyle(color: Colors.white)),
                    onTap: () {
                      Navigator.pop(context);
                      // Navigate to add custom workout
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.library_books, color: AppColors.primary),
                    title: const Text('Browse Exercise Library', style: TextStyle(color: Colors.white)),
                    onTap: () {
                      Navigator.pop(context);
                      // Navigate to exercise library
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.flash_on, color: AppColors.primary),
                    title: const Text('Start Quick Workout', style: TextStyle(color: Colors.white)),
                    onTap: () {
                      Navigator.pop(context);
                      // Start quick workout
                    },
                  ),
                ],
              ),
            ),
          );
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: AppColors.backgroundDark),
      ),
    );
  }

  Widget _buildWorkoutCard(WorkoutData workout) {
    final isDue = workout.status == WorkoutStatus.dueToday;
    final isCompleted = workout.status == WorkoutStatus.completed;
    final isUpcoming = workout.status == WorkoutStatus.upcoming;

    return AppCard(
      backgroundColor: AppColors.cardDark,
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          // Icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isDue
                  ? AppColors.primary20
                  : Colors.white.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              workout.icon,
              color: isDue
                  ? AppColors.primary
                  : const Color(0xFF8E8E93),
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          // Title and Status
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  workout.name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        decoration: isCompleted ? TextDecoration.lineThrough : null,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  workout.status == WorkoutStatus.dueToday
                      ? 'Due Today'
                      : workout.status == WorkoutStatus.completed
                          ? 'Completed'
                          : 'Upcoming',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isDue
                            ? AppColors.primary
                            : const Color(0xFF8E8E93),
                        fontSize: 14,
                      ),
                ),
              ],
            ),
          ),
          // Action Button
          if (isDue)
            PrimaryButton(
              text: 'Start',
              height: 40,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => WorkoutLoggingScreen(workoutName: workout.name),
                  ),
                );
              },
            )
          else
            Container(
              height: 40,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(
                color: const Color(0xFF38383A),
                borderRadius: BorderRadius.circular(AppTheme.radiusFull),
              ),
              child: TextButton(
                onPressed: () {
                  if (isCompleted) {
                    // Navigate to completed workout summary
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Completed workout summary coming soon'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  } else {
                    // Navigate to preview mode
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Workout preview coming soon'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  }
                },
                child: Text(
                  isCompleted ? 'View Details' : 'Preview',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
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
              child: const Icon(
                Icons.event_busy,
                size: 40,
                color: Color(0xFF8E8E93),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No workouts scheduled',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Looks like this day is clear. Take a rest day or explore other workouts.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF8E8E93),
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

enum WorkoutStatus {
  dueToday,
  completed,
  upcoming,
}

class WorkoutData {
  final String name;
  final WorkoutStatus status;
  final IconData icon;

  WorkoutData({
    required this.name,
    required this.status,
    required this.icon,
  });
}
