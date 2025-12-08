import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common/app_icon_button.dart';
import '../../widgets/common/app_card.dart';
import '../client/dashboard/today_view_screen.dart';
import '../client/workouts/assigned_workouts_list_screen.dart';

class ExerciseLibraryScreen extends StatefulWidget {
  const ExerciseLibraryScreen({super.key});

  @override
  State<ExerciseLibraryScreen> createState() => _ExerciseLibraryScreenState();
}

class _ExerciseLibraryScreenState extends State<ExerciseLibraryScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'All';
  String _searchQuery = '';

  final List<String> _categories = [
    'All',
    'Chest',
    'Legs',
    'Back',
    'Shoulders',
    'Arms',
    'Core',
    'Cardio',
  ];

  final List<ExerciseData> _allExercises = [
    ExerciseData(name: 'Barbell Bench Press', category: 'Chest'),
    ExerciseData(name: 'Dumbbell Bicep Curl', category: 'Arms'),
    ExerciseData(name: 'Squat', category: 'Legs'),
    ExerciseData(name: 'Deadlift', category: 'Back'),
    ExerciseData(name: 'Pull Ups', category: 'Back'),
    ExerciseData(name: 'Shoulder Press', category: 'Shoulders'),
    ExerciseData(name: 'Leg Press', category: 'Legs'),
    ExerciseData(name: 'Chest Fly', category: 'Chest'),
    ExerciseData(name: 'Tricep Extension', category: 'Arms'),
    ExerciseData(name: 'Plank', category: 'Core'),
    ExerciseData(name: 'Running', category: 'Cardio'),
    ExerciseData(name: 'Cycling', category: 'Cardio'),
  ];

  List<ExerciseData> get _filteredExercises {
    var exercises = _allExercises;
    
    // Filter by category
    if (_selectedCategory != 'All') {
      exercises = exercises.where((e) => e.category == _selectedCategory).toList();
    }
    
    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      exercises = exercises
          .where((e) => e.name.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }
    
    return exercises;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredExercises = _filteredExercises;

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
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
                    iconColor: Colors.white,
                  ),
                  Expanded(
                    child: Text(
                      'Exercise Library',
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
            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextField(
                controller: _searchController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Search exercises...',
                  hintStyle: TextStyle(color: AppColors.white40),
                  prefixIcon: const Icon(Icons.search, color: AppColors.textSecondaryDark),
                  filled: true,
                  fillColor: AppColors.black20,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusDefault),
                    borderSide: BorderSide(color: AppColors.borderWhite10),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusDefault),
                    borderSide: BorderSide(color: AppColors.borderWhite10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusDefault),
                    borderSide: const BorderSide(color: AppColors.primary, width: 2),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              ),
            ),
            const SizedBox(height: 12),
            // Category Filter Tabs
            SizedBox(
              height: 50,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final category = _categories[index];
                  final isSelected = _selectedCategory == category;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedCategory = category;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.cardDark,
                          borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                        ),
                        child: Center(
                          child: Text(
                            category,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: isSelected
                                      ? AppColors.backgroundDark
                                      : Colors.white,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            // Exercise Grid
            Expanded(
              child: filteredExercises.isEmpty
                  ? Center(
                      child: Text(
                        'No exercises found',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: AppColors.textSecondaryDark,
                            ),
                      ),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.all(16.0),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.85,
                      ),
                      itemCount: filteredExercises.length,
                      itemBuilder: (context, index) {
                        final exercise = filteredExercises[index];
                        return _buildExerciseCard(exercise);
                      },
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
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
                _buildNavItem(context, Icons.home, 'Home', onTap: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const TodayViewScreen()),
                  );
                }),
                _buildNavItem(context, Icons.fitness_center, 'Workouts', onTap: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const AssignedWorkoutsListScreen()),
                  );
                }),
                _buildNavItem(context, Icons.library_books, 'Library', isActive: true),
                _buildNavItem(context, Icons.people, 'Community', onTap: () {
                  // Navigate to Community
                }),
                _buildNavItem(context, Icons.person, 'Profile', onTap: () {
                  // Navigate to Profile
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildExerciseCard(ExerciseData exercise) {
    return AppCard(
      backgroundColor: AppColors.cardDark,
      padding: const EdgeInsets.all(12.0),
      onTap: () {
        // Navigate to exercise details
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${exercise.name} details coming soon'),
          ),
        );
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.primary20,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.fitness_center,
              color: AppColors.primary,
              size: 30,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            exercise.name,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
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

class ExerciseData {
  final String name;
  final String category;

  ExerciseData({
    required this.name,
    required this.category,
  });
}




