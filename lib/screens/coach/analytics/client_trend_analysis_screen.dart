import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/common/app_icon_button.dart';
import '../../../widgets/common/app_card.dart';
import '../../../services/workout_service.dart';
import '../../../models/workout_log_model.dart';
import '../../../models/exercise_log_model.dart';
import '../../../models/set_log_model.dart';

class ClientTrendAnalysisScreen extends StatefulWidget {
  final String clientName;
  final String clientId;

  const ClientTrendAnalysisScreen({
    super.key,
    this.clientName = 'Jane Doe',
    required this.clientId,
  });

  @override
  State<ClientTrendAnalysisScreen> createState() => _ClientTrendAnalysisScreenState();
}

class _ClientTrendAnalysisScreenState extends State<ClientTrendAnalysisScreen> {
  int _selectedTimeRange = 1; // 0 = 1M, 1 = 3M, 2 = 6M, 3 = All
  String? _selectedExercise;
  String _selectedMetric = 'Est. 1-Rep Max (lbs)';

  final List<String> _timeRanges = ['1M', '3M', '6M', 'All'];
  final WorkoutService _workoutService = WorkoutService();
  
  bool _isLoading = true;
  List<String> _exercises = [];
  List<WorkoutLogModel> _allWorkoutLogs = [];
  List<WorkoutHistoryEntry> _workoutHistory = [];
  
  double _currentValue = 0.0;
  double _percentageChange = 0.0;
  double _personalRecord = 0.0;
  double _adherence = 0.0;
  double _avgWeeklyVolume = 0.0;

  @override
  void initState() {
    super.initState();
    _loadWorkoutData();
  }

  Future<void> _loadWorkoutData() async {
    setState(() => _isLoading = true);

    try {
      // Determine date range
      DateTime? startDate;
      switch (_selectedTimeRange) {
        case 0: // 1M
          startDate = DateTime.now().subtract(const Duration(days: 30));
          break;
        case 1: // 3M
          startDate = DateTime.now().subtract(const Duration(days: 90));
          break;
        case 2: // 6M
          startDate = DateTime.now().subtract(const Duration(days: 180));
          break;
        case 3: // All
          startDate = null;
          break;
      }

      // Load workout logs
      final logsResult = await _workoutService.getWorkoutHistory(
        widget.clientId,
        startDate: startDate,
      );

      if (logsResult.isSuccess) {
        _allWorkoutLogs = logsResult.dataOrNull ?? [];
        
        // Extract unique exercises
        final exerciseSet = <String>{};
        for (final log in _allWorkoutLogs) {
          for (final exercise in log.exercises) {
            exerciseSet.add(exercise.exerciseName);
          }
        }
        _exercises = exerciseSet.toList()..sort();
        
        // Select first exercise if available
        if (_exercises.isNotEmpty && _selectedExercise == null) {
          _selectedExercise = _exercises.first;
        }

        // Update metrics if exercise is selected
        if (_selectedExercise != null) {
          _updateMetrics();
        }
      }

      setState(() => _isLoading = false);
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading workout data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _updateMetrics() {
    if (_selectedExercise == null) return;

    // Filter logs for selected exercise
    final exerciseLogs = <ExerciseLogModel>[];
    for (final workoutLog in _allWorkoutLogs) {
      for (final exercise in workoutLog.exercises) {
        if (exercise.exerciseName == _selectedExercise) {
          exerciseLogs.add(exercise);
        }
      }
    }

    if (exerciseLogs.isEmpty) {
      _currentValue = 0.0;
      _percentageChange = 0.0;
      _personalRecord = 0.0;
      _adherence = 0.0;
      _avgWeeklyVolume = 0.0;
      _workoutHistory = [];
      return;
    }

    // Calculate metrics based on selected metric
    switch (_selectedMetric) {
      case 'Est. 1-Rep Max (lbs)':
        _calculate1RM(exerciseLogs);
        break;
      case 'Max Weight (lbs)':
        _calculateMaxWeight(exerciseLogs);
        break;
      case 'Total Volume (lbs)':
        _calculateTotalVolume(exerciseLogs);
        break;
      case 'Average Weight (lbs)':
        _calculateAverageWeight(exerciseLogs);
        break;
    }

    // Calculate adherence (simplified: percentage of completed workouts)
    final totalWorkouts = _allWorkoutLogs.length;
    final completedWorkouts = _allWorkoutLogs.where((w) => w.completed).length;
    _adherence = totalWorkouts > 0 ? (completedWorkouts / totalWorkouts * 100) : 0.0;

    // Calculate average weekly volume
    _calculateWeeklyVolume(exerciseLogs);

    // Build workout history
    _buildWorkoutHistory();
  }

  void _calculate1RM(List<ExerciseLogModel> exerciseLogs) {
    double max1RM = 0.0;
    double? previous1RM;

    for (final exercise in exerciseLogs.reversed) {
      for (final set in exercise.sets) {
        if (set.weight != null && set.reps != null && set.reps! > 0) {
          // Epley formula: 1RM = weight * (1 + reps/30)
          final estimated1RM = set.weight! * (1 + set.reps! / 30);
          if (estimated1RM > max1RM) {
            max1RM = estimated1RM;
          }
        }
      }
    }

    _currentValue = max1RM;
    _personalRecord = max1RM;

    // Find previous value for percentage change
    if (exerciseLogs.length > 1) {
      final previousExercise = exerciseLogs[exerciseLogs.length - 2];
      for (final set in previousExercise.sets) {
        if (set.weight != null && set.reps != null && set.reps! > 0) {
          previous1RM = set.weight! * (1 + set.reps! / 30);
          break;
        }
      }
    }

    if (previous1RM != null && previous1RM > 0) {
      _percentageChange = ((max1RM - previous1RM) / previous1RM) * 100;
    }
  }

  void _calculateMaxWeight(List<ExerciseLogModel> exerciseLogs) {
    double maxWeight = 0.0;
    double? previousMax;

    for (final exercise in exerciseLogs.reversed) {
      for (final set in exercise.sets) {
        if (set.weight != null && set.weight! > maxWeight) {
          maxWeight = set.weight!;
        }
      }
    }

    _currentValue = maxWeight;
    _personalRecord = maxWeight;

    if (exerciseLogs.length > 1) {
      final previousExercise = exerciseLogs[exerciseLogs.length - 2];
      for (final set in previousExercise.sets) {
        if (set.weight != null) {
          previousMax = set.weight!;
          break;
        }
      }
    }

    if (previousMax != null && previousMax > 0) {
      _percentageChange = ((maxWeight - previousMax) / previousMax) * 100;
    }
  }

  void _calculateTotalVolume(List<ExerciseLogModel> exerciseLogs) {
    double totalVolume = 0.0;
    double? previousVolume;

    for (final exercise in exerciseLogs) {
      for (final set in exercise.sets) {
        if (set.weight != null && set.reps != null) {
          totalVolume += set.weight! * set.reps!;
        }
      }
    }

    _currentValue = totalVolume;

    if (exerciseLogs.length > 1) {
      final previousExercise = exerciseLogs[exerciseLogs.length - 2];
      for (final set in previousExercise.sets) {
        if (set.weight != null && set.reps != null) {
          previousVolume = (previousVolume ?? 0) + (set.weight! * set.reps!);
        }
      }
    }

    if (previousVolume != null && previousVolume > 0) {
      _percentageChange = ((totalVolume - previousVolume) / previousVolume) * 100;
    }
  }

  void _calculateAverageWeight(List<ExerciseLogModel> exerciseLogs) {
    double totalWeight = 0.0;
    int count = 0;

    for (final exercise in exerciseLogs) {
      for (final set in exercise.sets) {
        if (set.weight != null) {
          totalWeight += set.weight!;
          count++;
        }
      }
    }

    _currentValue = count > 0 ? totalWeight / count : 0.0;
  }

  void _calculateWeeklyVolume(List<ExerciseLogModel> exerciseLogs) {
    double totalVolume = 0.0;
    int weekCount = 0;

    final weekMap = <int, double>{};
    for (final workoutLog in _allWorkoutLogs) {
      final week = workoutLog.date.difference(DateTime(2024, 1, 1)).inDays ~/ 7;
      for (final exercise in workoutLog.exercises) {
        if (exercise.exerciseName == _selectedExercise) {
          for (final set in exercise.sets) {
            if (set.weight != null && set.reps != null) {
              weekMap[week] = (weekMap[week] ?? 0.0) + (set.weight! * set.reps!);
            }
          }
        }
      }
    }

    if (weekMap.isNotEmpty) {
      totalVolume = weekMap.values.reduce((a, b) => a + b);
      weekCount = weekMap.length;
      _avgWeeklyVolume = totalVolume / weekCount;
    }
  }

  void _buildWorkoutHistory() {
    _workoutHistory = [];
    
    // Get workout logs containing the selected exercise
    for (final workoutLog in _allWorkoutLogs.reversed.take(10)) {
      for (final exercise in workoutLog.exercises) {
        if (exercise.exerciseName == _selectedExercise) {
          // Build logged string
          final loggedSets = exercise.sets
              .where((s) => s.weight != null && s.reps != null)
              .map((s) => '${s.reps}x${s.weight!.toInt()} lbs')
              .join(', ');
          
          // Build prescribed string (simplified - would need template data)
          final prescribed = '${exercise.sets.length} sets';
          
          _workoutHistory.add(WorkoutHistoryEntry(
            date: workoutLog.date,
            logged: loggedSets.isEmpty ? 'No data' : loggedSets,
            prescribed: prescribed,
            isCompliant: exercise.completed,
          ));
          break; // Only add once per workout
        }
      }
    }
  }

  String _formatDate(DateTime date) {
    final months = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  void _showExerciseSelector() {
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
            Text(
              'Select Exercise',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            ..._exercises.map((exercise) => ListTile(
                  title: Text(exercise, style: const TextStyle(color: Colors.white)),
                  trailing: _selectedExercise == exercise
                      ? const Icon(Icons.check, color: AppColors.primary)
                      : null,
                  onTap: () {
                    setState(() {
                      _selectedExercise = exercise;
                      _updateMetrics();
                    });
                    Navigator.pop(context);
                  },
                )),
          ],
        ),
      ),
    );
  }

  void _showMetricSelector() {
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
            Text(
              'Select Metric',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            ...['Est. 1-Rep Max (lbs)', 'Max Weight (lbs)', 'Total Volume (lbs)', 'Average Weight (lbs)'].map((metric) => ListTile(
                  title: Text(metric, style: const TextStyle(color: Colors.white)),
                  trailing: _selectedMetric == metric
                      ? const Icon(Icons.check, color: AppColors.primary)
                      : null,
                  onTap: () {
                    setState(() {
                      _selectedMetric = metric;
                      _updateMetrics();
                    });
                    Navigator.pop(context);
                  },
                )),
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
                    onPressed: () => Navigator.of(context).pop(),
                    iconColor: Colors.white,
                  ),
                  Expanded(
                    child: Text(
                      'Trend Analysis',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  AppIconButton(
                    icon: Icons.more_vert,
                    onPressed: () {
                      // Show options menu
                    },
                    iconColor: Colors.white,
                  ),
                ],
              ),
            ),
            // Client & Exercise Selector
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: AppColors.primary20,
                    child: Text(
                      widget.clientName[0],
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.clientName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  GestureDetector(
                    onTap: _showExerciseSelector,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.cardDark,
                        borderRadius: BorderRadius.circular(AppTheme.radiusDefault),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _selectedExercise ?? 'Select Exercise',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.swap_horiz, color: Color(0xFF8E8E93), size: 20),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Time Range Filters
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _timeRanges.asMap().entries.map((entry) {
                    final index = entry.key;
                    final label = entry.value;
                    final isSelected = _selectedTimeRange == index;
                    return Padding(
                      padding: EdgeInsets.only(right: index < _timeRanges.length - 1 ? 8 : 0),
                      child: GestureDetector(
                        onTap: () {
                          setState(() => _selectedTimeRange = index);
                          _loadWorkoutData(); // Reload data for new time range
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.cardDark,
                            borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                          ),
                          child: Text(
                            label,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: isSelected
                                      ? AppColors.backgroundDark
                                      : Colors.white,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            // Content
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                      ),
                    )
                  : _exercises.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.fitness_center,
                                size: 64,
                                color: AppColors.textSecondaryDark,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No workout data available',
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                      color: Colors.white,
                                    ),
                              ),
                            ],
                          ),
                        )
                      : SingleChildScrollView(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Performance Metric Display
                    Container(
                      padding: const EdgeInsets.all(20.0),
                      decoration: BoxDecoration(
                        color: AppColors.cardDark,
                        borderRadius: BorderRadius.circular(AppTheme.radiusDefault),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GestureDetector(
                            onTap: _showMetricSelector,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _selectedMetric,
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                const Icon(Icons.swap_horiz, color: AppColors.primary, size: 20),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                _currentValue > 0 ? _currentValue.toInt().toString() : '—',
                                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                                      color: Colors.white,
                                      fontSize: 48,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  if (_percentageChange != 0)
                                    Text(
                                      '${_percentageChange > 0 ? '+' : ''}${_percentageChange.toStringAsFixed(0)}%',
                                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                            color: _percentageChange > 0 ? AppColors.primary : Colors.red,
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Graph Section
                    Container(
                      padding: const EdgeInsets.all(20.0),
                      decoration: BoxDecoration(
                        color: AppColors.cardDark,
                        borderRadius: BorderRadius.circular(AppTheme.radiusDefault),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 12,
                                height: 2,
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: 8),
                              const Text('— Actual', style: TextStyle(color: Color(0xFF8E8E93), fontSize: 12)),
                              const SizedBox(width: 16),
                              Container(
                                width: 12,
                                height: 2,
                                decoration: BoxDecoration(
                                  border: Border.all(color: AppColors.primary, width: 2),
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Text('— Prescribed', style: TextStyle(color: Color(0xFF8E8E93), fontSize: 12)),
                            ],
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            height: 200,
                            child: _buildGraph(),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Key Performance Cards
                    Row(
                      children: [
                        Expanded(
                          child: _buildKPICard('Personal Record', '${_personalRecord.toInt()} lbs', Icons.emoji_events),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildKPICard('Adherence', '${_adherence.toInt()}%', Icons.check_circle),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: _buildKPICard('Avg Weekly Volume', '${(_avgWeeklyVolume / 1000).toStringAsFixed(1)}K lbs', Icons.stacked_bar_chart),
                    ),
                    const SizedBox(height: 24),
                    // Workout History
                    Text(
                      'Workout History',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 12),
                    ..._workoutHistory.map((entry) => Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: AppCard(
                            backgroundColor: AppColors.cardDark,
                            padding: const EdgeInsets.all(16.0),
                            onTap: () {
                              // Navigate to workout details
                            },
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _formatDate(entry.date),
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Logged:',
                                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                  color: const Color(0xFF8E8E93),
                                                ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            entry.logged,
                                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                                  color: entry.isCompliant ? Colors.white : Colors.red,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Prescribed:',
                                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                  color: const Color(0xFF8E8E93),
                                                ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            entry.prescribed,
                                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                          ),
                                        ],
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKPICard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(AppTheme.radiusDefault),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primary, size: 24),
          const SizedBox(height: 12),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: const Color(0xFF8E8E93),
                  fontSize: 12,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildGraph() {
    if (_workoutHistory.isEmpty) {
      return Center(
        child: Text(
          'No data to display',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondaryDark,
              ),
        ),
      );
    }

    // Prepare data points
    final spots = <FlSpot>[];
    for (int i = 0; i < _workoutHistory.length; i++) {
      final entry = _workoutHistory[i];
      // Extract max weight from logged string (simplified)
      final weightMatch = RegExp(r'(\d+) lbs').firstMatch(entry.logged);
      if (weightMatch != null) {
        final weight = double.tryParse(weightMatch.group(1) ?? '0') ?? 0.0;
        spots.add(FlSpot(i.toDouble(), weight));
      }
    }

    if (spots.isEmpty) {
      return Center(
        child: Text(
          'No weight data available',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondaryDark,
              ),
        ),
      );
    }

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 50,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Colors.white.withOpacity(0.1),
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                if (value.toInt() < _workoutHistory.length) {
                  final date = _workoutHistory[value.toInt()].date;
                  return Text(
                    '${date.month}/${date.day}',
                    style: const TextStyle(
                      color: Color(0xFF8E8E93),
                      fontSize: 10,
                    ),
                  );
                }
                return const Text('');
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: const TextStyle(
                    color: Color(0xFF8E8E93),
                    fontSize: 10,
                  ),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
        minX: 0,
        maxX: spots.length > 1 ? (spots.length - 1).toDouble() : 1,
        minY: 0,
        maxY: spots.map((s) => s.y).reduce((a, b) => a > b ? a : b) * 1.2,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: AppColors.primary,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 4,
                  color: AppColors.primary,
                  strokeWidth: 2,
                  strokeColor: AppColors.backgroundDark,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              color: AppColors.primary.withOpacity(0.1),
            ),
          ),
        ],
      ),
    );
  }
}

class _TrendGraphPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Draw Actual line (solid)
    final actualPaint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final actualPath = Path();
    final actualPoints = [
      Offset(0, size.height * 0.7),
      Offset(size.width * 0.25, size.height * 0.6),
      Offset(size.width * 0.5, size.height * 0.5),
      Offset(size.width * 0.75, size.height * 0.4),
      Offset(size.width, size.height * 0.3),
    ];

    actualPath.moveTo(actualPoints[0].dx, actualPoints[0].dy);
    for (int i = 1; i < actualPoints.length; i++) {
      actualPath.lineTo(actualPoints[i].dx, actualPoints[i].dy);
    }
    canvas.drawPath(actualPath, actualPaint);

    // Draw Prescribed line (dashed)
    final prescribedPaint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final prescribedPath = Path();
    final prescribedPoints = [
      Offset(0, size.height * 0.75),
      Offset(size.width * 0.25, size.height * 0.65),
      Offset(size.width * 0.5, size.height * 0.55),
      Offset(size.width * 0.75, size.height * 0.45),
      Offset(size.width, size.height * 0.35),
    ];

    prescribedPath.moveTo(prescribedPoints[0].dx, prescribedPoints[0].dy);
    for (int i = 1; i < prescribedPoints.length; i++) {
      prescribedPath.lineTo(prescribedPoints[i].dx, prescribedPoints[i].dy);
    }
    canvas.drawPath(prescribedPath, prescribedPaint);

    // Draw points
    final pointPaint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.fill;
    for (final point in actualPoints) {
      canvas.drawCircle(point, 6, pointPaint);
    }

    // X-axis labels
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );
    final labels = ['May', 'Jun', 'Jul', 'Aug', 'Sep'];
    for (int i = 0; i < labels.length; i++) {
      textPainter.text = TextSpan(
        text: labels[i],
        style: const TextStyle(
          color: Color(0xFF8E8E93),
          fontSize: 10,
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          (size.width / (labels.length - 1)) * i - textPainter.width / 2,
          size.height - 20,
        ),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class WorkoutHistoryEntry {
  final DateTime date;
  final String logged;
  final String prescribed;
  final bool isCompliant;

  WorkoutHistoryEntry({
    required this.date,
    required this.logged,
    required this.prescribed,
    required this.isCompliant,
  });
}
