import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/common/app_icon_button.dart';
import '../../../widgets/common/app_card.dart';
import '../../../widgets/common/primary_button.dart';
import '../../../providers/user_provider.dart';
import '../../../providers/diet_provider.dart';
import '../../../services/firestore_service.dart';
import '../../../models/diet_plan_model.dart';

class DietPlanBuilderScreen extends StatefulWidget {
  const DietPlanBuilderScreen({super.key});

  @override
  State<DietPlanBuilderScreen> createState() => _DietPlanBuilderScreenState();
}

class _DietPlanBuilderScreenState extends State<DietPlanBuilderScreen> {
  final TextEditingController _templateNameController = TextEditingController();
  final TextEditingController _caloriesController = TextEditingController(text: '2200');
  final TextEditingController _proteinController = TextEditingController(text: '180');
  final TextEditingController _carbsController = TextEditingController(text: '200');
  final TextEditingController _fatsController = TextEditingController(text: '71');
  final TextEditingController _generalNotesController = TextEditingController();
  final FirestoreService _firestoreService = FirestoreService();
  bool _isSaving = false;

  final List<MealData> _meals = [
    MealData(name: 'Meal 1: Breakfast', content: ''),
    MealData(name: 'Meal 2: Lunch', content: ''),
  ];

  @override
  void dispose() {
    _templateNameController.dispose();
    _caloriesController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    _fatsController.dispose();
    _generalNotesController.dispose();
    for (var meal in _meals) {
      meal.controller.dispose();
    }
    super.dispose();
  }

  void _addMeal() {
    setState(() {
      _meals.add(MealData(
        name: 'Meal ${_meals.length + 1}',
        content: '',
      ));
    });
  }

  Future<void> _saveTemplate() async {
    if (_templateNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a template name'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final calories = int.tryParse(_caloriesController.text) ?? 0;
    final protein = double.tryParse(_proteinController.text) ?? 0.0;
    final carbs = double.tryParse(_carbsController.text) ?? 0.0;
    final fat = double.tryParse(_fatsController.text) ?? 0.0;

    if (calories <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter valid calories'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Validate macro totals (approximate: 1g protein = 4 cal, 1g carbs = 4 cal, 1g fat = 9 cal)
    final calculatedCalories = (protein * 4) + (carbs * 4) + (fat * 9);
    final difference = (calculatedCalories - calories).abs();
    
    if (difference > 100) {
      // Warn if macros don't match calories (allow some tolerance)
      final shouldContinue = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: AppColors.cardDark,
          title: const Text('Macro Mismatch', style: TextStyle(color: Colors.white)),
          content: Text(
            'Macros calculate to ${calculatedCalories.toInt()} calories, but you entered $calories. Continue anyway?',
            style: const TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Continue', style: TextStyle(color: AppColors.primary)),
            ),
          ],
        ),
      );
      
      if (shouldContinue != true) return;
    }

    setState(() => _isSaving = true);

    try {
      final userProvider = context.read<UserProvider>();
      final dietProvider = context.read<DietProvider>();
      final coachId = userProvider.currentCoach?.id ?? userProvider.currentUser?.id;
      
      if (coachId == null) {
        throw Exception('Coach ID not found');
      }

      // Create DietPlanModel
      final plan = DietPlanModel(
        id: _firestoreService.generateId('diet_plans'),
        name: _templateNameController.text.trim(),
        calories: calories,
        protein: protein,
        carbs: carbs,
        fat: fat,
        createdBy: coachId,
        createdAt: DateTime.now(),
        description: _generalNotesController.text.trim().isEmpty 
            ? null 
            : _generalNotesController.text.trim(),
      );

      // Save via provider
      await dietProvider.createPlan(plan);

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Diet template saved successfully!'),
            backgroundColor: AppColors.primary,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving template: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: SafeArea(
        child: Column(
          children: [
            // Top Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.backgroundDark.withOpacity(0.8),
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
                    iconColor: Colors.white,
                  ),
                  Expanded(
                    child: Text(
                      'New Diet Template',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  GestureDetector(
                    onTap: _isSaving ? null : _saveTemplate,
                    child: _isSaving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                            ),
                          )
                        : Text(
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
                            hintText: 'e.g. High Protein - 2200 kcal',
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
                    // Daily Targets
                    AppCard(
                      backgroundColor: AppColors.cardDark,
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Daily Targets',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Set the total nutritional goals for the day.',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: const Color(0xFF8E8E93),
                                ),
                          ),
                          const SizedBox(height: 24),
                          GridView.count(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 20,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            childAspectRatio: 1.2,
                            children: [
                              _buildMacroInput('Calories', _caloriesController, 'kcal'),
                              _buildMacroInput('Protein', _proteinController, 'g'),
                              _buildMacroInput('Carbs', _carbsController, 'g'),
                              _buildMacroInput('Fats', _fatsController, 'g'),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Meal Breakdown
                    Text(
                      'Meal Breakdown',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 24),
                    ..._meals.asMap().entries.map((entry) {
                      final index = entry.key;
                      final meal = entry.value;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 24.0),
                        child: _buildMealCard(meal, index),
                      );
                    }),
                    // Add Meal Button
                    SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        onPressed: _addMeal,
                        style: TextButton.styleFrom(
                          backgroundColor: AppColors.primary20,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppTheme.radiusDefault),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.add,
                              color: AppColors.primary,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Add Meal',
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    // General Notes
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'General Notes',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: const Color(0xFF8E8E93),
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _generalNotesController,
                          maxLines: 5,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: Colors.white,
                              ),
                          decoration: InputDecoration(
                            hintText: 'Add any final instructions for the client...',
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
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMacroInput(String label, TextEditingController controller, String unit) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: const Color(0xFF8E8E93),
                fontWeight: FontWeight.w500,
              ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.white,
              ),
          decoration: InputDecoration(
            hintText: unit,
            hintStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: const Color(0xFF8E8E93),
                ),
            filled: true,
            fillColor: AppColors.backgroundDark,
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
    );
  }

  Widget _buildMealCard(MealData meal, int index) {
    return AppCard(
      backgroundColor: AppColors.cardDark,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                meal.name,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.more_vert,
                  color: Color(0xFF8E8E93),
                  size: 20,
                ),
                onPressed: () {
                  // Show meal options menu
                  _showMealOptions(index);
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: meal.controller,
            maxLines: 4,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.white,
                ),
            decoration: InputDecoration(
              hintText: 'Add guidelines or example foods...',
              hintStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: const Color(0xFF8E8E93),
                  ),
              filled: true,
              fillColor: AppColors.backgroundDark,
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
    );
  }

  void _showMealOptions(int index) {
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
              title: const Text('Rename Meal', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                // Show rename dialog
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete Meal', style: TextStyle(color: Colors.red)),
              onTap: () {
                setState(() {
                  _meals[index].controller.dispose();
                  _meals.removeAt(index);
                });
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class MealData {
  String name;
  String content;
  late final TextEditingController controller;

  MealData({
    required this.name,
    required this.content,
  }) {
    controller = TextEditingController(text: content);
  }
}
