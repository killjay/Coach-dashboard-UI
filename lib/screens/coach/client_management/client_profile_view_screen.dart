import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/common/app_icon_button.dart';
import '../../../widgets/common/app_card.dart';
import '../../../widgets/common/primary_button.dart';
import '../../../services/user_service.dart';
import '../../../services/workout_service.dart';
import '../../../services/diet_service.dart';
import '../../../services/metrics_service.dart';
import '../../../services/compliance_service.dart';
import '../../../models/client_model.dart';
import '../../../models/workout_log_model.dart';
import '../../../models/food_log_model.dart';
import '../../../models/body_metrics_model.dart';
import '../plan_creation/assign_plans_screen.dart';
import '../analytics/client_trend_analysis_screen.dart';
import '../analytics/progress_photos_screen.dart';

class ClientProfileViewScreen extends StatefulWidget {
  final String clientId;

  const ClientProfileViewScreen({
    super.key,
    required this.clientId,
  });

  @override
  State<ClientProfileViewScreen> createState() => _ClientProfileViewScreenState();
}

class _ClientProfileViewScreenState extends State<ClientProfileViewScreen> {
  int _selectedTab = 0;
  final List<String> _tabs = ['Overview', 'Plans', 'Logs', 'Data', 'Chat'];
  
  final UserService _userService = UserService();
  final WorkoutService _workoutService = WorkoutService();
  final DietService _dietService = DietService();
  final MetricsService _metricsService = MetricsService();
  final ComplianceService _complianceService = ComplianceService();

  bool _isLoading = true;
  ClientModel? _client;
  double _adherence = 0.0;
  int _workoutsThisWeek = 0;
  int _workoutsGoal = 0;
  double? _currentWeight;
  double _weightChange = 0.0;
  List<WorkoutLogModel> _recentWorkouts = [];
  List<FoodLogModel> _recentFoodLogs = [];
  List<BodyMetricsModel> _recentMetrics = [];

  @override
  void initState() {
    super.initState();
    _loadClientData();
  }

  Future<void> _loadClientData() async {
    setState(() => _isLoading = true);

    try {
      // Load client
      final clientResult = await _userService.getClient(widget.clientId);
      if (clientResult.isFailure) {
        setState(() => _isLoading = false);
        return;
      }
      _client = clientResult.dataOrNull;

      // Calculate weekly snapshot
      final now = DateTime.now();
      final weekStart = now.subtract(Duration(days: now.weekday - 1));
      
      // Get workouts this week
      final workoutsResult = await _workoutService.getWorkoutHistory(
        widget.clientId,
        startDate: weekStart,
        endDate: now,
      );
      if (workoutsResult.isSuccess) {
        _recentWorkouts = workoutsResult.dataOrNull ?? [];
        _workoutsThisWeek = _recentWorkouts.where((w) => w.completed).length;
      }

      // Get assigned workouts to determine goal
      final assignedResult = await _workoutService.getAssignedWorkouts(widget.clientId);
      if (assignedResult.isSuccess) {
        final assigned = assignedResult.dataOrNull ?? [];
        _workoutsGoal = assigned.length; // Simplified: assume one workout per day
      }

      // Calculate adherence (weekly compliance)
      final adherenceResult = await _complianceService.calculateWeeklyCompliance(
        widget.clientId,
        weekStart,
      );
      if (adherenceResult.isSuccess) {
        _adherence = adherenceResult.dataOrNull ?? 0.0;
      }

      // Get latest body metrics
      final metricsResult = await _metricsService.getLatestMetrics(widget.clientId);
      if (metricsResult.isSuccess && metricsResult.dataOrNull != null) {
        final latest = metricsResult.dataOrNull!;
        _currentWeight = latest.weight;
        
        // Get previous weight for change calculation
        final historyResult = await _metricsService.getMetricsHistory(widget.clientId);
        if (historyResult.isSuccess) {
          final history = historyResult.dataOrNull ?? [];
          if (history.length > 1) {
            final previous = history[1];
            if (previous.weight != null && latest.weight != null) {
              _weightChange = latest.weight! - previous.weight!;
            }
          }
        }
      }

      // Get recent food logs
      final foodLogsResult = await _dietService.getDietHistory(
        widget.clientId,
        startDate: now.subtract(const Duration(days: 7)),
        endDate: now,
      );
      if (foodLogsResult.isSuccess) {
        _recentFoodLogs = foodLogsResult.dataOrNull ?? [];
      }

      setState(() => _isLoading = false);
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading client data: $e'),
            backgroundColor: Colors.red,
          ),
        );
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
                      _client?.name ?? 'Loading...',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  AppIconButton(
                    icon: Icons.more_horiz,
                    onPressed: () {
                      _showMoreOptions(context);
                    },
                    iconColor: Colors.white,
                  ),
                ],
              ),
            ),
            // Profile Info Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  // Profile Picture
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primary20,
                    ),
                    child: Center(
                      child: Text(
                        (_client?.name ?? '?')[0],
                        style: Theme.of(context).textTheme.displaySmall?.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Client Name
                  Text(
                    _client?.name ?? 'Loading...',
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  // Goal
                  Text(
                    _client?.lifestyleGoals?.fitnessGoal?.toString().split('.').last.replaceAll(RegExp(r'([A-Z])'), r' $1').trim() ?? 'No goal set',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.textSecondaryDark,
                        ),
                  ),
                  const SizedBox(height: 8),
                  // Status Tags
                  Wrap(
                    spacing: 8,
                    children: [
                      if (_client != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.primary20,
                            borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                          ),
                          child: Text(
                            'Active',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ),
                      if (_client?.onboardingCompleted == false)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.cardDark,
                            borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                          ),
                          child: Text(
                            'Onboarding',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.orange,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Quick Action Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildActionButton(
                        context,
                        icon: Icons.chat,
                        label: 'Message',
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Chat feature coming soon'),
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 16),
                      _buildActionButton(
                        context,
                        icon: Icons.assignment,
                        label: 'Assign Plan',
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => AssignPlansScreen(preSelectedClientId: widget.clientId),
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 16),
                      _buildActionButton(
                        context,
                        icon: Icons.note_add,
                        label: 'Add Note',
                        onTap: () {
                          _showAddNoteDialog(context);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Data Navigation Tabs
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: _tabs.asMap().entries.map((entry) {
                  final index = entry.key;
                  final label = entry.value;
                  final isSelected = _selectedTab == index;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedTab = index;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: isSelected
                                  ? AppColors.primary
                                  : Colors.transparent,
                              width: 2,
                            ),
                          ),
                        ),
                        child: Text(
                          label,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: isSelected
                                    ? AppColors.primary
                                    : AppColors.textSecondaryDark,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            // Tab Content
            Expanded(
              child: _buildTabContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 70,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.cardDark,
          shape: BoxShape.circle,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: AppColors.primary,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white,
                    fontSize: 10,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_selectedTab) {
      case 0: // Overview
        return _buildOverviewTab();
      case 1: // Plans
        return _buildPlansTab();
      case 2: // Logs
        return _buildLogsTab();
      case 3: // Data
        return _buildDataTab();
      case 4: // Chat
        return _buildChatTab();
      default:
        return const SizedBox();
    }
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // This Week's Snapshot
          Text(
            "This Week's Snapshot",
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: AppCard(
                  backgroundColor: AppColors.cardDark,
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Adherence',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondaryDark,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${_adherence.toInt()}%',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AppCard(
                  backgroundColor: AppColors.cardDark,
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Workouts',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondaryDark,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$_workoutsThisWeek/$_workoutsGoal',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Progress Section
          Text(
            'Progress',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          AppCard(
            backgroundColor: AppColors.cardDark,
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Bodyweight',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.textSecondaryDark,
                              ),
                        ),
                        Text(
                          _currentWeight != null
                              ? '${_currentWeight!.toStringAsFixed(1)} lbs'
                              : 'No data',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                    Text(
                      '${_weightChange > 0 ? '+' : ''}${_weightChange.toStringAsFixed(1)} lbs',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: _weightChange < 0
                                ? AppColors.primary
                                : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Simple graph placeholder
                Container(
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppColors.backgroundDark,
                    borderRadius: BorderRadius.circular(AppTheme.radiusDefault),
                  ),
                  child: Center(
                    child: Text(
                      'Weight Trend Graph',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondaryDark,
                          ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _selectedTab = 3; // Switch to Data tab
                    });
                    // Navigate to detailed analytics
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ClientTrendAnalysisScreen(
                          clientId: widget.clientId,
                          clientName: _client?.name ?? 'Client',
                        ),
                      ),
                    );
                  },
                  child: Text(
                    'View All',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Recent Activity
          Text(
            'Recent Activity',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            )
          else ...[
            // Show recent workouts
            ..._recentWorkouts.take(3).map((workout) {
              final daysAgo = DateTime.now().difference(workout.date).inDays;
              String timeText;
              if (daysAgo == 0) {
                timeText = 'Today';
              } else if (daysAgo == 1) {
                timeText = 'Yesterday';
              } else {
                timeText = '$daysAgo days ago';
              }
              
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: _buildActivityItem(
                  'Workout Logged',
                  timeText,
                  Icons.fitness_center,
                ),
              );
            }),
            // Show recent food logs
            ..._recentFoodLogs.take(2).map((log) {
              final daysAgo = DateTime.now().difference(log.date).inDays;
              String timeText;
              if (daysAgo == 0) {
                timeText = 'Today';
              } else if (daysAgo == 1) {
                timeText = 'Yesterday';
              } else {
                timeText = '$daysAgo days ago';
              }
              
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: _buildActivityItem(
                  'Food Logged',
                  timeText,
                  Icons.restaurant,
                ),
              );
            }),
            // Progress photos option
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: _buildActivityItem(
                'Progress Photos',
                'View all',
                Icons.camera_alt,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ProgressPhotosScreen(
                        clientId: widget.clientId,
                        clientName: _client?.name ?? 'Client',
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
          const SizedBox(height: 12),
          TextButton(
            onPressed: () {
              setState(() {
                _selectedTab = 2; // Switch to Logs tab
              });
            },
            child: Text(
              'See Logs',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem(
    String title,
    String time,
    IconData icon, {
    VoidCallback? onTap,
  }) {
    return AppCard(
      backgroundColor: AppColors.cardDark,
      padding: const EdgeInsets.all(16.0),
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary20,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: AppColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                Text(
                  time,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondaryDark,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlansTab() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_note,
              size: 64,
              color: AppColors.textSecondaryDark,
            ),
            const SizedBox(height: 16),
            Text(
              'Assigned Plans',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'View and manage assigned workout and diet plans',
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

  Widget _buildLogsTab() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history,
              size: 64,
              color: AppColors.textSecondaryDark,
            ),
            const SizedBox(height: 16),
            Text(
              'Workout & Nutrition Logs',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'View complete history of client logs',
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

  Widget _buildDataTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Analytics & Data',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          _buildDataOption(
            'Trend Analysis',
            'View performance trends over time',
            Icons.trending_up,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ClientTrendAnalysisScreen(clientId: widget.clientId),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          _buildDataOption(
            'Progress Photos',
            'Compare visual progress over time',
            Icons.camera_alt,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ProgressPhotosScreen(
                    clientId: widget.clientId,
                    clientName: _client?.name ?? 'Client',
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDataOption(
    String title,
    String subtitle,
    IconData icon, {
    required VoidCallback onTap,
  }) {
    return AppCard(
      backgroundColor: AppColors.cardDark,
      padding: const EdgeInsets.all(16.0),
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primary20,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: AppColors.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondaryDark,
                      ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right,
            color: AppColors.textSecondaryDark,
          ),
        ],
      ),
    );
  }

  Widget _buildChatTab() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat,
              size: 64,
              color: AppColors.textSecondaryDark,
            ),
            const SizedBox(height: 16),
            Text(
              'Messages',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Chat with your client',
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

  void _showMoreOptions(BuildContext context) {
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
              title: const Text('Edit Client Profile', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Edit profile feature coming soon'),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.archive, color: Colors.white),
              title: const Text('Archive Client', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Archive feature coming soon'),
                  ),
                );
              },
            ),
            SizedBox(height: MediaQuery.of(context).padding.bottom),
          ],
        ),
      ),
    );
  }

  void _showAddNoteDialog(BuildContext context) {
    final noteController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardDark,
        title: const Text('Add Note', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: noteController,
          maxLines: 5,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Enter your note...',
            hintStyle: TextStyle(color: AppColors.white40),
            filled: true,
            fillColor: AppColors.backgroundDark,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusDefault),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
          ),
          TextButton(
            onPressed: () {
              // TODO: Save note
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Note saved'),
                  backgroundColor: AppColors.primary,
                ),
              );
            },
            child: const Text('Save', style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }
}
