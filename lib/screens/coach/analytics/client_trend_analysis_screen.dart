import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/common/app_icon_button.dart';
import '../../../widgets/common/app_card.dart';

class ClientTrendAnalysisScreen extends StatefulWidget {
  final String clientName;
  final String? clientId;

  const ClientTrendAnalysisScreen({
    super.key,
    this.clientName = 'Jane Doe',
    this.clientId,
  });

  @override
  State<ClientTrendAnalysisScreen> createState() => _ClientTrendAnalysisScreenState();
}

class _ClientTrendAnalysisScreenState extends State<ClientTrendAnalysisScreen> {
  int _selectedTimeRange = 1; // 0 = 1M, 1 = 3M, 2 = 6M, 3 = All
  String _selectedExercise = 'Back Squat';
  String _selectedMetric = 'Est. 1-Rep Max (lbs)';

  final List<String> _timeRanges = ['1M', '3M', '6M', 'All'];
  final List<String> _exercises = ['Back Squat', 'Bench Press', 'Deadlift', 'Pull Ups'];

  // Mock data
  final double _currentValue = 245.0;
  final double _percentageChange = 12.0;
  final double _personalRecord = 245.0;
  final double _adherence = 92.0;
  final double _avgWeeklyVolume = 8450.0;

  final List<WorkoutHistoryEntry> _workoutHistory = [
    WorkoutHistoryEntry(
      date: DateTime(2024, 7, 22),
      logged: '3x5 @ 245 lbs',
      prescribed: '3x5 @ 240 lbs',
      isCompliant: true,
    ),
    WorkoutHistoryEntry(
      date: DateTime(2024, 7, 15),
      logged: '3x5 @ 240 lbs',
      prescribed: '3x5 @ 240 lbs',
      isCompliant: true,
    ),
    WorkoutHistoryEntry(
      date: DateTime(2024, 7, 8),
      logged: '3x5 @ 235 lbs',
      prescribed: '3x5 @ 235 lbs',
      isCompliant: true,
    ),
    WorkoutHistoryEntry(
      date: DateTime(2024, 7, 1),
      logged: '2x5, 1x3 @ 230 lbs',
      prescribed: '3x5 @ 230 lbs',
      isCompliant: false,
    ),
  ];

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
                    setState(() => _selectedExercise = exercise);
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
                    setState(() => _selectedMetric = metric);
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
                            _selectedExercise,
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
              child: SingleChildScrollView(
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
                                '${_currentValue.toInt()}',
                                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                                      color: Colors.white,
                                      fontSize: 48,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '+${_percentageChange.toStringAsFixed(0)}%',
                                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                          color: AppColors.primary,
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
                            child: _buildGraphPlaceholder(),
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

  Widget _buildGraphPlaceholder() {
    return CustomPaint(
      painter: _TrendGraphPainter(),
      child: Container(),
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
