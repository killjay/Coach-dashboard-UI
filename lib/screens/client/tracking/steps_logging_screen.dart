import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/common/app_icon_button.dart';
import '../../../widgets/common/primary_button.dart';
import '../../../providers/auth_provider.dart';
import '../../../services/metrics_service.dart';
import '../../../services/firestore_service.dart';
import '../../../models/steps_log_model.dart';

class StepsLoggingScreen extends StatefulWidget {
  const StepsLoggingScreen({super.key});

  @override
  State<StepsLoggingScreen> createState() => _StepsLoggingScreenState();
}

class _StepsLoggingScreenState extends State<StepsLoggingScreen> {
  DateTime _selectedDate = DateTime.now();
  final TextEditingController _stepsController = TextEditingController();
  final MetricsService _metricsService = MetricsService();
  final FirestoreService _firestoreService = FirestoreService();
  bool _isLoading = false;
  int _currentSteps = 0;
  int _goalSteps = 10000;

  @override
  void initState() {
    super.initState();
    _loadStepsData();
  }

  Future<void> _loadStepsData() async {
    final authProvider = context.read<AuthProvider>();
    final clientId = authProvider.user?.uid;
    
    if (clientId == null) return;

    final startOfDay = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);

    try {
      final result = await _metricsService.getStepsLog(clientId, startOfDay);
      if (result.isSuccess && result.dataOrNull != null) {
        final stepsLog = result.dataOrNull!;
        setState(() {
          _currentSteps = stepsLog.steps;
          _goalSteps = stepsLog.goal;
          _stepsController.text = stepsLog.steps.toString();
        });
      }
    } catch (e) {
      print('Error loading steps data: $e');
    }
  }

  bool get isToday {
    final now = DateTime.now();
    return _selectedDate.year == now.year &&
        _selectedDate.month == now.month &&
        _selectedDate.day == now.day;
  }

  String _getFormattedDate() {
    final now = DateTime.now();
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    
    if (isToday) {
      return 'Today, ${months[_selectedDate.month - 1]} ${_selectedDate.day}';
    }
    return '${months[_selectedDate.month - 1]} ${_selectedDate.day}, ${_selectedDate.year}';
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
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
      setState(() => _selectedDate = date);
      _loadStepsData();
    }
  }

  Future<void> _handleLogSteps() async {
    final stepsText = _stepsController.text.trim();
    if (stepsText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your step count'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final steps = int.tryParse(stepsText.replaceAll(',', ''));
    if (steps == null || steps <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid step count'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

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
      final startOfDay = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);
      
      final stepsLog = StepsLogModel(
        id: _firestoreService.generateId('steps_logs'),
        clientId: clientId,
        date: startOfDay,
        steps: steps,
        goal: _goalSteps,
        loggedAt: DateTime.now(),
      );

      final result = await _metricsService.logSteps(stepsLog);
      
      if (result.isSuccess) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Steps logged successfully!'),
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
            content: Text('Error logging steps: $e'),
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
  void dispose() {
    _stepsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                    icon: Icons.arrow_back_ios_new,
                    onPressed: () => Navigator.of(context).pop(),
                    iconColor: Colors.white,
                  ),
                  Expanded(
                    child: Text(
                      'Log Steps',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(width: 40), // Balance the back button
                ],
              ),
            ),
            // Main Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        // Date Selector
                        GestureDetector(
                          onTap: _selectDate,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                            decoration: BoxDecoration(
                              color: AppColors.cardDark.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(AppTheme.radiusDefault),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: AppColors.cardDark,
                                    borderRadius: BorderRadius.circular(AppTheme.radiusDefault),
                                  ),
                                  child: const Icon(
                                    Icons.calendar_today,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Text(
                                    _getFormattedDate(),
                                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                ),
                                const Icon(
                                  Icons.expand_more,
                                  color: Colors.white,
                                  size: 28,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                        // Step Count Input
                        Text(
                          'Enter your step count',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: Colors.white.withOpacity(0.8),
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _stepsController,
                          keyboardType: TextInputType.number,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: Colors.white,
                              ),
                          decoration: InputDecoration(
                            hintText: 'e.g., 8,500',
                            hintStyle: TextStyle(color: AppColors.textSecondaryDark),
                            filled: true,
                            fillColor: AppColors.cardDark.withOpacity(0.5),
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
                              borderSide: const BorderSide(
                                color: AppColors.primary,
                                width: 2,
                              ),
                            ),
                            contentPadding: const EdgeInsets.all(16.0),
                          ),
                        ),
                      ],
                    ),
                    // Log Steps Button
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: PrimaryButton(
                        text: _isLoading ? 'Logging...' : 'Log Steps',
                        onPressed: _isLoading ? null : _handleLogSteps,
                        height: 56,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

