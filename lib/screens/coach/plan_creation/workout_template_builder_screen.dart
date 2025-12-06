import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/common/app_icon_button.dart';
import '../../../widgets/common/app_card.dart';
import 'custom_exercise_creation_screen.dart';

class WorkoutTemplateBuilderScreen extends StatefulWidget {
  const WorkoutTemplateBuilderScreen({super.key});

  @override
  State<WorkoutTemplateBuilderScreen> createState() => _WorkoutTemplateBuilderScreenState();
}

class _WorkoutTemplateBuilderScreenState extends State<WorkoutTemplateBuilderScreen> {
  final TextEditingController _templateNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final List<ExerciseData> _exercises = [];

  @override
  void dispose() {
    _templateNameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _saveTemplate() {
    if (_templateNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a template name'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_exercises.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least one exercise'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Workout template saved successfully!'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  void _addExercise() {
    // Navigate to exercise selection or custom exercise creation
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
              leading: const Icon(Icons.fitness_center, color: Colors.white),
              title: const Text('Select from Library', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                // Navigate to exercise library
                _selectFromLibrary();
              },
            ),
            ListTile(
              leading: const Icon(Icons.add_circle, color: AppColors.primary),
              title: const Text('Create Custom Exercise', style: TextStyle(color: AppColors.primary)),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const CustomExerciseCreationScreen(),
                  ),
                ).then((exercise) {
                  if (exercise != null) {
                    setState(() {
                      _exercises.add(ExerciseData(
                        name: exercise['name'] as String,
                        sets: 3,
                        reps: '8-10',
                        weight: null,
                        rpe: null,
                        notes: '',
                      ));
                    });
                  }
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  void _selectFromLibrary() {
    // Mock exercise selection
    setState(() {
      _exercises.add(ExerciseData(
        name: 'Barbell Bench Press',
        sets: 3,
        reps: '8-10',
        weight: null,
        rpe: null,
        notes: '',
      ));
    });
  }

  void _showExerciseOptions(int index) {
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
              leading: const Icon(Icons.edit, color: Colors.white),
              title: const Text('Edit Exercise', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                // Show edit dialog
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Remove Exercise', style: TextStyle(color: Colors.red)),
              onTap: () {
                setState(() {
                  _exercises.removeAt(index);
                });
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
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
                    onPressed: () {
                      if (_templateNameController.text.isNotEmpty || _exercises.isNotEmpty) {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            backgroundColor: AppColors.cardDark,
                            title: const Text('Discard Changes?', style: TextStyle(color: Colors.white)),
                            content: const Text(
                              'You have unsaved changes. Are you sure you want to leave?',
                              style: TextStyle(color: Colors.white70),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  Navigator.pop(context);
                                },
                                child: const Text('Discard', style: TextStyle(color: Colors.red)),
                              ),
                            ],
                          ),
                        );
                      } else {
                        Navigator.of(context).pop();
                      }
                    },
                    iconColor: Colors.white,
                  ),
                  Expanded(
                    child: Text(
                      'New Template',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  GestureDetector(
                    onTap: _saveTemplate,
                    child: Text(
                      'Save',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                ],
              ),
            ),
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Template Name
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Template Name',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: const Color(0xFF8E8E93),
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _templateNameController,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: Colors.white,
                              ),
                          decoration: InputDecoration(
                            hintText: 'e.g., Lower Body Strength - Day 1',
                            hintStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  color: const Color(0xFF8E8E93),
                                ),
                            filled: true,
                            fillColor: AppColors.cardDark,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(AppTheme.radiusDefault),
                              borderSide: const BorderSide(
                                color: Color(0xFF38383A),
                                width: 1,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(AppTheme.radiusDefault),
                              borderSide: const BorderSide(
                                color: AppColors.primary,
                                width: 1,
                              ),
                            ),
                            contentPadding: const EdgeInsets.all(16.0),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Description
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Description',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: const Color(0xFF8E8E93),
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _descriptionController,
                          maxLines: 3,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: Colors.white,
                              ),
                          decoration: InputDecoration(
                            hintText: 'Add a short description or goal for this workout...',
                            hintStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  color: const Color(0xFF8E8E93),
                                ),
                            filled: true,
                            fillColor: AppColors.cardDark,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(AppTheme.radiusDefault),
                              borderSide: const BorderSide(
                                color: Color(0xFF38383A),
                                width: 1,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(AppTheme.radiusDefault),
                              borderSide: const BorderSide(
                                color: AppColors.primary,
                                width: 1,
                              ),
                            ),
                            contentPadding: const EdgeInsets.all(16.0),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    // Exercises Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Exercises',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        if (_exercises.isNotEmpty)
                          IconButton(
                            icon: const Icon(Icons.more_vert, color: Color(0xFF8E8E93)),
                            onPressed: () {
                              // Show rearrange/delete all options
                            },
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Exercises List or Empty State
                    if (_exercises.isEmpty)
                      _buildEmptyState()
                    else
                      ..._exercises.asMap().entries.map((entry) {
                        final index = entry.key;
                        final exercise = entry.value;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: _buildExerciseCard(exercise, index),
                        );
                      }),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addExercise,
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: AppColors.backgroundDark),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(48.0),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.primary20,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.fitness_center,
              color: AppColors.primary,
              size: 40,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Start Building Your Template',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'Tap the \'+\' button below to add your first exercise to this workout template.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF8E8E93),
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseCard(ExerciseData exercise, int index) {
    return AppCard(
      backgroundColor: AppColors.cardDark,
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Icon(Icons.fitness_center, color: AppColors.primary, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  exercise.name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${exercise.sets} Sets × ${exercise.reps} Reps',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: const Color(0xFF8E8E93),
                      ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: Color(0xFF8E8E93)),
            onPressed: () => _showExerciseOptions(index),
          ),
        ],
      ),
    );
  }
}

class ExerciseData {
  final String name;
  final int sets;
  final String reps;
  final double? weight;
  final int? rpe;
  final String notes;

  ExerciseData({
    required this.name,
    required this.sets,
    required this.reps,
    this.weight,
    this.rpe,
    required this.notes,
  });
}
