import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/common/app_icon_button.dart';
import '../../../widgets/common/progress_ring.dart';
import '../../../widgets/common/app_card.dart';
import '../../../providers/auth_provider.dart';
import '../../../services/metrics_service.dart';
import '../../../models/water_log_model.dart';

class WaterTrackerScreen extends StatefulWidget {
  const WaterTrackerScreen({super.key});

  @override
  State<WaterTrackerScreen> createState() => _WaterTrackerScreenState();
}

class _WaterTrackerScreenState extends State<WaterTrackerScreen> {
  DateTime _selectedDate = DateTime.now();
  final MetricsService _metricsService = MetricsService();
  
  double _currentAmount = 0.0; // ml
  double _goalAmount = 3500.0; // ml (default 3.5L)
  List<WaterEntry> _entries = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadWaterData();
  }

  Future<void> _loadWaterData() async {
    final authProvider = context.read<AuthProvider>();
    final clientId = authProvider.user?.uid;
    
    if (clientId == null) {
      setState(() => _isLoading = false);
      return;
    }

    final startOfDay = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);

    try {
      final result = await _metricsService.getWaterLog(clientId, startOfDay);
      if (result.isSuccess && result.dataOrNull != null) {
        final waterLog = result.dataOrNull!;
        setState(() {
          _currentAmount = waterLog.amount;
          _goalAmount = waterLog.goal;
          // Create entries from log (simplified - in production, you'd track individual entries)
          _entries = [
            WaterEntry(amount: waterLog.amount, timestamp: waterLog.loggedAt),
          ];
        });
      } else {
        // No log for this date, use defaults
        setState(() {
          _currentAmount = 0.0;
          _goalAmount = 3500.0;
          _entries = [];
        });
      }
    } catch (e) {
      print('Error loading water data: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  double get progress => _goalAmount > 0 ? (_currentAmount / _goalAmount).clamp(0.0, 1.0) : 0.0;

  bool get isToday {
    final now = DateTime.now();
    return _selectedDate.year == now.year &&
        _selectedDate.month == now.month &&
        _selectedDate.day == now.day;
  }

  Future<void> _addWater(double amount) async {
    final authProvider = context.read<AuthProvider>();
    final clientId = authProvider.user?.uid;
    
    if (clientId == null) return;

    final startOfDay = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);

    try {
      final result = await _metricsService.addWaterToLog(clientId, startOfDay, amount);
      if (result.isSuccess && result.dataOrNull != null) {
        final waterLog = result.dataOrNull!;
        setState(() {
          _currentAmount = waterLog.amount;
          _goalAmount = waterLog.goal;
          _entries.insert(0, WaterEntry(amount: amount, timestamp: DateTime.now()));
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${result.errorMessage}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error adding water: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _addCustomWater() {
    showDialog(
      context: context,
      builder: (context) {
        final controller = TextEditingController();
        return AlertDialog(
          backgroundColor: AppColors.cardDark,
          title: const Text('Custom Amount', style: TextStyle(color: Colors.white)),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Enter amount in ml',
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
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
                final amount = double.tryParse(controller.text);
                if (amount != null && amount > 0) {
                  Navigator.pop(context);
                  _addWater(amount);
                }
              },
              child: const Text('Add', style: TextStyle(color: AppColors.primary)),
            ),
          ],
        );
      },
    );
  }

  void _navigateDate(int days) {
    setState(() {
      _selectedDate = _selectedDate.add(Duration(days: days));
    });
    _loadWaterData();
  }

  void _goToToday() {
    setState(() {
      _selectedDate = DateTime.now();
    });
    _loadWaterData();
  }

  String _formatTime(DateTime time) {
    final hour = time.hour;
    final minute = time.minute;
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '${displayHour}:${minute.toString().padLeft(2, '0')} $period';
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.backgroundDark,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

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
                      'Water Intake',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  AppIconButton(
                    icon: Icons.history,
                    onPressed: () {
                      // Navigate to history
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Water intake history coming soon'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
                    iconColor: Colors.white,
                  ),
                ],
              ),
            ),
            // Date Navigator
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left, color: Colors.white),
                    onPressed: () => _navigateDate(-1),
                  ),
                  GestureDetector(
                    onTap: _goToToday,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: isToday ? AppColors.primary : AppColors.cardDark,
                        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                      ),
                      child: Text(
                        isToday ? 'Today' : '${_selectedDate.month}/${_selectedDate.day}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: isToday ? AppColors.backgroundDark : Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right, color: Colors.white),
                    onPressed: () => _navigateDate(1),
                  ),
                ],
              ),
            ),
            // Progress Ring
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24.0),
              child: ProgressRing(
                progress: progress,
                size: 280,
                child: Column(
                  children: [
                    Text(
                      '${_currentAmount.toInt()} ml',
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                            color: Colors.white,
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    Text(
                      'of ${_goalAmount.toInt()} ml',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: const Color(0xFF8E8E93),
                            fontSize: 16,
                          ),
                    ),
                  ],
                ),
              ),
            ),
            // Quick Add Buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildQuickAddButton('250 ml', () => _addWater(250)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildQuickAddButton('500 ml', () => _addWater(500)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildQuickAddButton('750 ml', () => _addWater(750)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildQuickAddButton('+ Custom', _addCustomWater, isCustom: true),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Recent Entries List
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      'Recent Entries',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: _entries.isEmpty
                        ? Center(
                            child: Text(
                              'No entries yet',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: const Color(0xFF8E8E93),
                                  ),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            itemCount: _entries.length,
                            itemBuilder: (context, index) {
                              final entry = _entries[index];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12.0),
                                child: AppCard(
                                  backgroundColor: AppColors.cardDark,
                                  padding: const EdgeInsets.all(16.0),
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
                                          Icons.water_drop,
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
                                              '${entry.amount.toInt()} ml',
                                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                            ),
                                            Text(
                                              _formatTime(entry.timestamp),
                                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                    color: const Color(0xFF8E8E93),
                                                  ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.more_vert, color: Color(0xFF8E8E93)),
                                        onPressed: () {
                                          // Show edit/delete menu
                                          showModalBottomSheet(
                                            context: context,
                                            backgroundColor: AppColors.cardDark,
                                            builder: (context) => Container(
                                              padding: const EdgeInsets.all(24.0),
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  ListTile(
                                                    leading: const Icon(Icons.edit, color: Colors.white),
                                                    title: const Text('Edit', style: TextStyle(color: Colors.white)),
                                                    onTap: () {
                                                      Navigator.pop(context);
                                                      // Edit entry
                                                    },
                                                  ),
                                                  ListTile(
                                                    leading: const Icon(Icons.delete, color: Colors.red),
                                                    title: const Text('Delete', style: TextStyle(color: Colors.red)),
                                                    onTap: () {
                                                      setState(() {
                                                        _entries.removeAt(index);
                                                        _currentAmount -= entry.amount;
                                                      });
                                                      Navigator.pop(context);
                                                    },
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAddButton(String label, VoidCallback onPressed, {bool isCustom = false}) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: isCustom ? AppColors.primary : const Color(0xFF38383A),
        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
      ),
      child: TextButton(
        onPressed: onPressed,
        child: Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: isCustom ? AppColors.backgroundDark : Colors.white,
                fontWeight: FontWeight.w600,
              ),
        ),
      ),
    );
  }
}

class WaterEntry {
  final double amount;
  final DateTime timestamp;

  WaterEntry({
    required this.amount,
    required this.timestamp,
  });
}
