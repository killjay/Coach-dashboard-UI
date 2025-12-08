import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/common/app_icon_button.dart';
import '../../../widgets/common/app_card.dart';
import '../../../widgets/common/primary_button.dart';
import '../../../providers/auth_provider.dart';
import '../../../services/diet_service.dart';
import '../../../services/firestore_service.dart';
import '../../../models/food_log_model.dart';
import 'daily_macro_goals_screen.dart';

class ManualFoodLoggingScreen extends StatefulWidget {
  const ManualFoodLoggingScreen({super.key});

  @override
  State<ManualFoodLoggingScreen> createState() => _ManualFoodLoggingScreenState();
}

class _ManualFoodLoggingScreenState extends State<ManualFoodLoggingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _foodNameController = TextEditingController();
  final _servingSizeController = TextEditingController();
  final _caloriesController = TextEditingController();
  final _proteinController = TextEditingController();
  final _carbsController = TextEditingController();
  final _fatController = TextEditingController();

  final DietService _dietService = DietService();
  bool _isLoading = false;

  String _selectedMeal = 'Breakfast';
  String _selectedUnit = 'g';

  final List<String> _meals = ['Breakfast', 'Lunch', 'Dinner', 'Snack'];
  final List<String> _units = ['g', 'oz', 'cup', 'piece', 'serving'];

  @override
  void dispose() {
    _foodNameController.dispose();
    _servingSizeController.dispose();
    _caloriesController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    _fatController.dispose();
    super.dispose();
  }

  Future<void> _handleLogFood() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    final clientId = authProvider.user?.uid;
    
    if (clientId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('User not authenticated'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final calories = double.tryParse(_caloriesController.text) ?? 0.0;
      final protein = double.tryParse(_proteinController.text) ?? 0.0;
      final carbs = double.tryParse(_carbsController.text) ?? 0.0;
      final fat = double.tryParse(_fatController.text) ?? 0.0;

      final meal = MealModel(
        name: '${_selectedMeal}: ${_foodNameController.text}',
        calories: calories,
        protein: protein,
        carbs: carbs,
        fat: fat,
      );

      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);

      final result = await _dietService.addMealToLog(clientId, startOfDay, meal);
      
      if (result.isSuccess) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Food logged successfully!'),
              backgroundColor: AppColors.primary,
            ),
          );
          Navigator.of(context).pop();
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${result.errorMessage}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error logging food: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundDark,
        elevation: 0,
        leading: AppIconButton(
          icon: Icons.arrow_back,
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Manual Food Logging',
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                color: Colors.white,
              ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 8),
              // Meal Selection
              Text(
                'Meal',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                    ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.black20,
                  borderRadius: BorderRadius.circular(AppTheme.radiusDefault),
                  border: Border.all(color: AppColors.borderWhite10),
                ),
                child: DropdownButtonFormField<String>(
                  value: _selectedMeal,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                  dropdownColor: AppColors.cardDark,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.white,
                      ),
                  items: _meals.map((meal) {
                    return DropdownMenuItem(
                      value: meal,
                      child: Text(meal),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedMeal = value;
                      });
                    }
                  },
                ),
              ),
              const SizedBox(height: 24),
              // Food Name
              Text(
                'Food Name',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                    ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _foodNameController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Enter food name',
                  hintStyle: TextStyle(color: AppColors.white40),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter food name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              // Serving Size
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Serving Size',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Colors.white,
                              ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _servingSizeController,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: '0',
                            hintStyle: TextStyle(color: AppColors.white40),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Required';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Unit',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Colors.white,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.black20,
                            borderRadius: BorderRadius.circular(AppTheme.radiusDefault),
                            border: Border.all(color: AppColors.borderWhite10),
                          ),
                          child: DropdownButtonFormField<String>(
                            value: _selectedUnit,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                            ),
                            dropdownColor: AppColors.cardDark,
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  color: Colors.white,
                                ),
                            items: _units.map((unit) {
                              return DropdownMenuItem(
                                value: unit,
                                child: Text(unit),
                              );
                            }).toList(),
                            onChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  _selectedUnit = value;
                                });
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              // Estimated Breakdown Section
              Text(
                'Estimated Breakdown',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                    ),
              ),
              const SizedBox(height: 16),
              // Calories
              _buildMacroInputField(
                context,
                label: 'Calories',
                controller: _caloriesController,
                unit: 'kcal',
              ),
              const SizedBox(height: 16),
              // Protein
              _buildMacroInputField(
                context,
                label: 'Protein',
                controller: _proteinController,
                unit: 'g',
              ),
              const SizedBox(height: 16),
              // Carbs
              _buildMacroInputField(
                context,
                label: 'Carbs',
                controller: _carbsController,
                unit: 'g',
              ),
              const SizedBox(height: 16),
              // Fat
              _buildMacroInputField(
                context,
                label: 'Fat',
                controller: _fatController,
                unit: 'g',
              ),
              const SizedBox(height: 32),
              // Log Food Item Button
              PrimaryButton(
                text: _isLoading ? 'Logging...' : 'Log Food Item',
                onPressed: _isLoading ? null : _handleLogFood,
                height: 56,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMacroInputField(
    BuildContext context, {
    required String label,
    required TextEditingController controller,
    required String unit,
  }) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.white,
                ),
          ),
        ),
        SizedBox(
          width: 120,
          child: TextFormField(
            controller: controller,
            keyboardType: TextInputType.number,
            style: const TextStyle(color: Colors.white),
            textAlign: TextAlign.right,
            decoration: InputDecoration(
              hintText: '0',
              hintStyle: TextStyle(color: AppColors.white40),
              suffixText: unit,
              suffixStyle: TextStyle(color: AppColors.textSecondaryDark),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Required';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }
}

