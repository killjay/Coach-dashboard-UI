import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/common/primary_button.dart';
import '../../../widgets/common/app_icon_button.dart';

class WorkoutLoggingScreen extends StatefulWidget {
  final String workoutName;

  const WorkoutLoggingScreen({
    super.key,
    this.workoutName = 'Upper Body Strength',
  });

  @override
  State<WorkoutLoggingScreen> createState() => _WorkoutLoggingScreenState();
}

class _WorkoutLoggingScreenState extends State<WorkoutLoggingScreen> {
  int _activeExerciseIndex = 0;

  final List<ExerciseData> _exercises = [
    ExerciseData(
      name: 'Barbell Bench Press',
      prescription: '3 Sets / 8-10 Reps',
      sets: [
        SetData(setNumber: 1, previousWeight: 220, previousReps: 8, weight: 225, reps: 8, completed: true),
        SetData(setNumber: 2, previousWeight: 220, previousReps: 8, weight: null, reps: null, completed: false),
        SetData(setNumber: 3, previousWeight: 220, previousReps: 8, weight: null, reps: null, completed: false),
      ],
    ),
    ExerciseData(
      name: 'Pull Ups',
      prescription: '3 Sets / 8-10 Reps',
      sets: [
        SetData(setNumber: 1, previousWeight: 0, previousReps: 10, weight: null, reps: null, completed: false),
        SetData(setNumber: 2, previousWeight: 0, previousReps: 10, weight: null, reps: null, completed: false),
        SetData(setNumber: 3, previousWeight: 0, previousReps: 10, weight: null, reps: null, completed: false),
      ],
    ),
    ExerciseData(
      name: 'Dumbbell Shoulder Press',
      prescription: '3 Sets / 10-12 Reps',
      sets: [
        SetData(setNumber: 1, previousWeight: 50, previousReps: 12, weight: null, reps: null, completed: false),
        SetData(setNumber: 2, previousWeight: 50, previousReps: 12, weight: null, reps: null, completed: false),
        SetData(setNumber: 3, previousWeight: 50, previousReps: 12, weight: null, reps: null, completed: false),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111111), // background-dark
      body: SafeArea(
        child: Column(
          children: [
            // Sticky Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF111111).withOpacity(0.8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Row(
                children: [
                  AppIconButton(
                    icon: Icons.arrow_back_ios_new,
                    onPressed: () => Navigator.of(context).pop(),
                    backgroundColor: const Color(0xFF1C1C1E), // surface-dark
                    iconColor: Colors.white,
                  ),
                  Expanded(
                    child: Text(
                      widget.workoutName,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  AppIconButton(
                    icon: Icons.more_horiz,
                    onPressed: () {
                      // Show menu
                    },
                    backgroundColor: const Color(0xFF1C1C1E), // surface-dark
                    iconColor: Colors.white,
                  ),
                ],
              ),
            ),
            // Content
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  ..._exercises.asMap().entries.map((entry) {
                    final index = entry.key;
                    final exercise = entry.value;
                    final isActive = index == _activeExerciseIndex;
                    
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 24.0),
                      child: Opacity(
                        opacity: isActive ? 1.0 : 0.5,
                        child: _buildExerciseCard(exercise, index),
                      ),
                    );
                  }),
                  const SizedBox(height: 100), // Space for bottom button
                ],
              ),
            ),
            // Fixed Footer
            Container(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFF111111).withOpacity(0),
                    const Color(0xFF111111).withOpacity(0.8),
                    const Color(0xFF111111),
                  ],
                ),
              ),
              child: SizedBox(
                width: double.infinity,
                child: PrimaryButton(
                  text: 'Mark Workout as Complete',
                  onPressed: () {
                    // Mark workout as complete
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Workout marked as complete!'),
                        backgroundColor: Color(0xFF39E079),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExerciseCard(ExerciseData exercise, int exerciseIndex) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E), // surface-dark
        borderRadius: BorderRadius.circular(AppTheme.radiusDefault),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Exercise Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'EXERCISE ${(exerciseIndex + 1).toString().padLeft(2, '0')}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: exerciseIndex == _activeExerciseIndex
                                ? const Color(0xFF39E079) // accent
                                : const Color(0xFF8E8E93), // text-secondary
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                            letterSpacing: 1.2,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      exercise.name,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      exercise.prescription,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: const Color(0xFF8E8E93), // text-secondary
                            fontSize: 14,
                          ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFF38383A), // border-dark
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.info_outline, size: 16),
                  color: Colors.white,
                  onPressed: () {
                    // Show exercise info
                  },
                  padding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
          if (exerciseIndex == _activeExerciseIndex) ...[
            const SizedBox(height: 16),
            // Table Header
            Row(
              children: [
                const SizedBox(width: 24), // Checkbox column
                Expanded(
                  flex: 2,
                  child: Center(
                    child: Text(
                      'SET',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: const Color(0xFF8E8E93),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Center(
                    child: Text(
                      'PREVIOUS',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: const Color(0xFF8E8E93),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Center(
                    child: Text(
                      'WEIGHT',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: const Color(0xFF8E8E93),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Center(
                    child: Text(
                      'REPS',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: const Color(0xFF8E8E93),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Sets
            ...exercise.sets.map((set) => _buildSetRow(set)),
            const SizedBox(height: 12),
            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      setState(() {
                        exercise.sets.add(SetData(
                          setNumber: exercise.sets.length + 1,
                          previousWeight: exercise.sets.last.previousWeight,
                          previousReps: exercise.sets.last.previousReps,
                          weight: null,
                          reps: null,
                          completed: false,
                        ));
                      });
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: const Color(0xFF38383A), // border-dark
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                      ),
                    ),
                    child: Text(
                      'Add Set',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      // Show notes/RPE dialog
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: const Color(0xFF38383A), // border-dark
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                      ),
                    ),
                    child: Text(
                      'Notes / RPE',
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
          ],
        ],
      ),
    );
  }

  Widget _buildSetRow(SetData set) {
    final weightController = TextEditingController(
      text: set.weight?.toString() ?? '',
    );
    final repsController = TextEditingController(
      text: set.reps?.toString() ?? '',
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Container(
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: const Color(0xFF111111), // background-dark
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            // Checkbox
            SizedBox(
              width: 24,
              child: Center(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      set.completed = !set.completed;
                    });
                  },
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: set.completed
                            ? const Color(0xFF39E079) // accent
                            : const Color(0xFF38383A), // border-dark
                        width: 2,
                      ),
                      color: set.completed
                          ? const Color(0xFF39E079) // accent
                          : Colors.transparent,
                    ),
                    child: set.completed
                        ? const Center(
                            child: Text(
                              '✔',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                        : null,
                  ),
                ),
              ),
            ),
            // Set Number
            Expanded(
              flex: 2,
              child: Center(
                child: Text(
                  '${set.setNumber}',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                ),
              ),
            ),
            // Previous
            Expanded(
              flex: 3,
              child: Center(
                child: Text(
                  set.previousWeight > 0
                      ? '${set.previousWeight} lbs x ${set.previousReps}'
                      : '${set.previousReps} reps',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: const Color(0xFF8E8E93), // text-secondary
                        fontSize: 14,
                      ),
                ),
              ),
            ),
            // Weight Input
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: TextField(
                  controller: weightController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                  decoration: InputDecoration(
                    hintText: set.previousWeight > 0 ? set.previousWeight.toString() : '',
                    hintStyle: const TextStyle(
                      color: Color(0xFF8E8E93), // text-secondary
                    ),
                    filled: true,
                    fillColor: const Color(0xFF38383A), // border-dark
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: const BorderSide(
                        color: Color(0xFF39E079), // accent
                        width: 2,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onChanged: (value) {
                    setState(() {
                      set.weight = value.isEmpty ? null : int.tryParse(value);
                    });
                  },
                ),
              ),
            ),
            // Reps Input
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: TextField(
                  controller: repsController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                  decoration: InputDecoration(
                    hintText: set.previousReps.toString(),
                    hintStyle: const TextStyle(
                      color: Color(0xFF8E8E93), // text-secondary
                    ),
                    filled: true,
                    fillColor: const Color(0xFF38383A), // border-dark
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: const BorderSide(
                        color: Color(0xFF39E079), // accent
                        width: 2,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onChanged: (value) {
                    setState(() {
                      set.reps = value.isEmpty ? null : int.tryParse(value);
                    });
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ExerciseData {
  final String name;
  final String prescription;
  final List<SetData> sets;

  ExerciseData({
    required this.name,
    required this.prescription,
    required this.sets,
  });
}

class SetData {
  int setNumber;
  int previousWeight;
  int previousReps;
  int? weight;
  int? reps;
  bool completed;

  SetData({
    required this.setNumber,
    required this.previousWeight,
    required this.previousReps,
    this.weight,
    this.reps,
    this.completed = false,
  });
}
