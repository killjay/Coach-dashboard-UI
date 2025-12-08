import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/common/app_icon_button.dart';
import '../../../widgets/common/app_card.dart';
import '../../../widgets/common/primary_button.dart';
import '../../../providers/user_provider.dart';
import '../../../providers/workout_provider.dart';
import '../../../providers/diet_provider.dart';
import '../../../services/workout_service.dart';
import '../../../services/diet_service.dart';
import '../../../services/firestore_service.dart';
import '../../../services/user_service.dart';
import '../../../models/client_model.dart';
import '../../../models/assigned_workout_model.dart';
import '../../../models/assigned_diet_model.dart';

class AssignPlansScreen extends StatefulWidget {
  final String? preSelectedClientId;

  const AssignPlansScreen({
    super.key,
    this.preSelectedClientId,
  });

  @override
  State<AssignPlansScreen> createState() => _AssignPlansScreenState();
}

class _AssignPlansScreenState extends State<AssignPlansScreen> {
  final TextEditingController _searchController = TextEditingController();
  DateTime _startDate = DateTime.now().add(const Duration(days: 1));
  String? _selectedWorkoutTemplate;
  String? _selectedDietPlan;
  
  final WorkoutService _workoutService = WorkoutService();
  final DietService _dietService = DietService();
  final FirestoreService _firestoreService = FirestoreService();
  
  List<ClientModel> _allClients = [];
  Map<String, bool> _selectedClients = {};
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadClients();
    _loadPlans();
    
    // Pre-select client if provided
    if (widget.preSelectedClientId != null) {
      _selectedClients[widget.preSelectedClientId!] = true;
    }
  }

  Future<void> _loadClients() async {
    final userProvider = context.read<UserProvider>();
    final coachId = userProvider.currentCoach?.id ?? userProvider.currentUser?.id;
    
    if (coachId != null) {
      final userService = UserService();
      final result = await userService.getClientList(coachId);
      if (result.isSuccess && mounted) {
        setState(() {
          _allClients = result.dataOrNull ?? [];
          // Initialize selection map
          for (var client in _allClients) {
            if (!_selectedClients.containsKey(client.id)) {
              _selectedClients[client.id] = false;
            }
          }
        });
      }
    }
  }

  Future<void> _loadPlans() async {
    final userProvider = context.read<UserProvider>();
    final workoutProvider = context.read<WorkoutProvider>();
    final dietProvider = context.read<DietProvider>();
    
    final coachId = userProvider.currentCoach?.id ?? userProvider.currentUser?.id;
    if (coachId != null) {
      await workoutProvider.loadTemplates(coachId);
      await dietProvider.loadPlans(coachId);
    }
  }

  List<ClientModel> get _filteredClients {
    if (_searchController.text.isEmpty) {
      return _allClients;
    }
    return _allClients
        .where((client) => client.name.toLowerCase().contains(_searchController.text.toLowerCase()))
        .toList();
  }

  bool get _isAllSelected {
    final filtered = _filteredClients;
    if (filtered.isEmpty) return false;
    return filtered.every((client) => _selectedClients[client.id] == true);
  }

  void _toggleSelectAll() {
    final allSelected = _isAllSelected;
    setState(() {
      for (var client in _filteredClients) {
        _selectedClients[client.id] = !allSelected;
      }
    });
  }

  int get _selectedCount => _selectedClients.values.where((selected) => selected == true).length;

  Future<void> _assignPlans() async {
    if (_selectedCount == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one client'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_selectedWorkoutTemplate == null && _selectedDietPlan == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one plan'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final userProvider = context.read<UserProvider>();
      final coachId = userProvider.currentCoach?.id ?? userProvider.currentUser?.id;
      
      if (coachId == null) {
        throw Exception('Coach ID not found');
      }

      final selectedClientIds = _selectedClients.entries
          .where((entry) => entry.value == true)
          .map((entry) => entry.key)
          .toList();

      // Assign workout template if selected
      if (_selectedWorkoutTemplate != null) {
        for (final clientId in selectedClientIds) {
          final assignment = AssignedWorkoutModel(
            id: _firestoreService.generateId('assigned_workouts'),
            templateId: _selectedWorkoutTemplate!,
            clientId: clientId,
            coachId: coachId,
            startDate: _startDate,
            status: WorkoutStatus.pending,
            assignedAt: DateTime.now(),
          );
          
          final result = await _workoutService.assignWorkout(assignment);
          if (!result.isSuccess) {
            throw Exception('Failed to assign workout: ${result.errorMessage}');
          }
        }
      }

      // Assign diet plan if selected
      if (_selectedDietPlan != null) {
        for (final clientId in selectedClientIds) {
          final assignment = AssignedDietModel(
            id: _firestoreService.generateId('assigned_diets'),
            planId: _selectedDietPlan!,
            clientId: clientId,
            coachId: coachId,
            startDate: _startDate,
            assignedAt: DateTime.now(),
          );
          
          final result = await _dietService.assignDiet(assignment);
          if (!result.isSuccess) {
            throw Exception('Failed to assign diet: ${result.errorMessage}');
          }
        }
      }

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Plans assigned to $_selectedCount client(s)!'),
            backgroundColor: AppColors.primary,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error assigning plans: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _formatDate(DateTime date) {
    final months = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

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
                  AppIconButton(
                    icon: Icons.arrow_back_ios_new,
                    onPressed: () => Navigator.of(context).pop(),
                    iconColor: Colors.white,
                  ),
                  Expanded(
                    child: Text(
                      'Assign Plan',
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
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Search Bar
                    TextField(
                      controller: _searchController,
                      onChanged: (_) => setState(() {}),
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.white,
                          ),
                      decoration: InputDecoration(
                        hintText: 'Search by client name...',
                        hintStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: const Color(0xFF8E8E93),
                            ),
                        prefixIcon: const Icon(Icons.search, color: Color(0xFF8E8E93)),
                        filled: true,
                        fillColor: AppColors.cardDark,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppTheme.radiusDefault),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.all(16.0),
                      ),
                    ),
                    const SizedBox(height: 32),
                    // SELECT CLIENTS Section
                    Text(
                      'SELECT CLIENTS',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 16),
                    // Select All
                    AppCard(
                      backgroundColor: AppColors.cardDark,
                      padding: const EdgeInsets.all(16.0),
                      onTap: _toggleSelectAll,
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: AppColors.primary20,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.people,
                              color: AppColors.primary,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              'Select All',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ),
                          Checkbox(
                            value: _isAllSelected,
                            onChanged: (_) => _toggleSelectAll(),
                            activeColor: AppColors.primary,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Individual Clients
                    ..._filteredClients.map((client) => Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: AppCard(
                            backgroundColor: AppColors.cardDark,
                            padding: const EdgeInsets.all(16.0),
                            onTap: () {
                              setState(() {
                                _selectedClients[client.id] = !(_selectedClients[client.id] ?? false);
                              });
                            },
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 20,
                                  backgroundColor: AppColors.primary20,
                                  child: Text(
                                    client.name.isNotEmpty ? client.name[0].toUpperCase() : '?',
                                    style: const TextStyle(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Text(
                                    client.name,
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                ),
                                Checkbox(
                                  value: _selectedClients[client.id] ?? false,
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedClients[client.id] = value ?? false;
                                    });
                                  },
                                  activeColor: AppColors.primary,
                                ),
                              ],
                            ),
                          ),
                        )),
                    const SizedBox(height: 32),
                    // SELECT PLAN & DATE Section
                    Text(
                      'SELECT PLAN & DATE',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 16),
                    // Workout Template
                    AppCard(
                      backgroundColor: AppColors.cardDark,
                      padding: const EdgeInsets.all(16.0),
                      onTap: () => _showWorkoutTemplateSelector(),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: AppColors.primary20,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.fitness_center,
                              color: AppColors.primary,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Workout Template',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: const Color(0xFF8E8E93),
                                      ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _getWorkoutTemplateName() ?? 'Choose a workout template',
                                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                        color: _selectedWorkoutTemplate != null
                                            ? Colors.white
                                            : const Color(0xFF8E8E93),
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right, color: Color(0xFF8E8E93)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Diet Plan
                    AppCard(
                      backgroundColor: AppColors.cardDark,
                      padding: const EdgeInsets.all(16.0),
                      onTap: () => _showDietPlanSelector(),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: AppColors.primary20,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.restaurant,
                              color: AppColors.primary,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Diet Plan',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: const Color(0xFF8E8E93),
                                      ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _getDietPlanName() ?? 'Choose a diet plan',
                                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                        color: _selectedDietPlan != null
                                            ? Colors.white
                                            : const Color(0xFF8E8E93),
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right, color: Color(0xFF8E8E93)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Start Date
                    AppCard(
                      backgroundColor: AppColors.cardDark,
                      padding: const EdgeInsets.all(16.0),
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: _startDate,
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                          builder: (context, child) {
                            return Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme: const ColorScheme.dark(
                                  primary: AppColors.primary,
                                  onPrimary: AppColors.backgroundDark,
                                  surface: AppColors.cardDark,
                                  onSurface: Colors.white,
                                ),
                              ),
                              child: child!,
                            );
                          },
                        );
                        if (date != null) {
                          setState(() {
                            _startDate = date;
                          });
                        }
                      },
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: AppColors.primary20,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.calendar_today,
                              color: AppColors.primary,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Start Date',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: const Color(0xFF8E8E93),
                                      ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _formatDate(_startDate),
                                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right, color: Color(0xFF8E8E93)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            // Assign Button
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: AppColors.backgroundDark,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                child: PrimaryButton(
                  text: _isLoading
                      ? 'Assigning...'
                      : (_selectedCount > 0
                          ? 'Assign to $_selectedCount Client${_selectedCount > 1 ? 's' : ''}'
                          : 'Assign Plan'),
                  onPressed: _isLoading ? null : _assignPlans,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String? _getWorkoutTemplateName() {
    if (_selectedWorkoutTemplate == null) return null;
    final workoutProvider = context.read<WorkoutProvider>();
    final template = workoutProvider.templates.firstWhere(
      (t) => t.id == _selectedWorkoutTemplate,
      orElse: () => throw StateError('Template not found'),
    );
    return template.name;
  }

  String? _getDietPlanName() {
    if (_selectedDietPlan == null) return null;
    final dietProvider = context.read<DietProvider>();
    final plan = dietProvider.plans.firstWhere(
      (p) => p.id == _selectedDietPlan,
      orElse: () => throw StateError('Plan not found'),
    );
    return plan.name;
  }

  void _showWorkoutTemplateSelector() {
    final workoutProvider = context.read<WorkoutProvider>();
    final templates = workoutProvider.templates;
    
    if (templates.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No workout templates available. Create one first.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardDark,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Select Workout Template',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              ...templates.map((template) => ListTile(
                    title: Text(
                      template.name,
                      style: const TextStyle(color: Colors.white),
                    ),
                    subtitle: template.description != null
                        ? Text(
                            template.description!,
                            style: TextStyle(color: Colors.grey[400]),
                          )
                        : null,
                    onTap: () {
                      setState(() {
                        _selectedWorkoutTemplate = template.id;
                      });
                      Navigator.pop(context);
                    },
                  )),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  setState(() {
                    _selectedWorkoutTemplate = null;
                  });
                  Navigator.pop(context);
                },
                child: const Text('Clear Selection', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showDietPlanSelector() {
    final dietProvider = context.read<DietProvider>();
    final plans = dietProvider.plans;
    
    if (plans.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No diet plans available. Create one first.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardDark,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Select Diet Plan',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              ...plans.map((plan) => ListTile(
                    title: Text(
                      plan.name,
                      style: const TextStyle(color: Colors.white),
                    ),
                    subtitle: Text(
                      '${plan.calories} kcal, ${plan.protein}g Protein',
                      style: TextStyle(color: Colors.grey[400]),
                    ),
                    onTap: () {
                      setState(() {
                        _selectedDietPlan = plan.id;
                      });
                      Navigator.pop(context);
                    },
                  )),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  setState(() {
                    _selectedDietPlan = null;
                  });
                  Navigator.pop(context);
                },
                child: const Text('Clear Selection', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        );
      },
    );
  }
}
