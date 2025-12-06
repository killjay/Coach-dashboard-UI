import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/common/app_icon_button.dart';
import '../../../widgets/common/app_card.dart';
import 'metric_selection_screen.dart';

class IndividualExerciseAnalyticsScreen extends StatefulWidget {
  final String exerciseName;

  const IndividualExerciseAnalyticsScreen({
    super.key,
    this.exerciseName = 'Bench Press',
  });

  @override
  State<IndividualExerciseAnalyticsScreen> createState() => _IndividualExerciseAnalyticsScreenState();
}

class _IndividualExerciseAnalyticsScreenState extends State<IndividualExerciseAnalyticsScreen> {
  int _selectedTimeRange = 1; // 0 = 1M, 1 = 3M, 2 = 6M, 3 = 1Y, 4 = All
  String _selectedMetric = 'Max Weight (lbs)';

  final List<String> _timeRanges = ['1M', '3M', '6M', '1Y', 'All'];

  // Mock data
  final double _personalBest = 225.0;
  final double _avgReps = 5.2;
  final double _totalVolume = 12000.0;
  final int _frequency = 6;

  final List<WorkoutHistoryEntry> _workoutHistory = [
    WorkoutHistoryEntry(
      date: DateTime(2023, 12, 1),
      sets: 3,
      reps: 5,
      weight: 225,
      isPR: true,
    ),
    WorkoutHistoryEntry(
      date: DateTime(2023, 11, 25),
      sets: 3,
      reps: 5,
      weight: 220,
      isPR: false,
    ),
    WorkoutHistoryEntry(
      date: DateTime(2023, 11, 18),
      sets: 3,
      reps: 5,
      weight: 215,
      isPR: false,
    ),
    WorkoutHistoryEntry(
      date: DateTime(2023, 11, 12),
      sets: 3,
      reps: 5,
      weight: 210,
      isPR: false,
    ),
  ];

  String _formatDate(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  void _showMetricSelection() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => MetricSelectionScreen(
        currentMetric: _selectedMetric,
        onMetricSelected: (metric) {
          setState(() => _selectedMetric = metric);
          Navigator.pop(context);
        },
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
                      widget.exerciseName,
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
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _selectedMetric,
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              GestureDetector(
                                onTap: _showMetricSelection,
                                child: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: AppColors.primary20,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.swap_horiz,
                                    color: AppColors.primary,
                                    size: 20,
                                  ),
                                ),
                              ),
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
                    // Key Performance Indicators
                    Row(
                      children: [
                        Expanded(
                          child: _buildKPICard(
                            'Personal Best',
                            '${_personalBest.toInt()} lbs',
                            Icons.emoji_events,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildKPICard(
                            'Avg. Reps',
                            _avgReps.toStringAsFixed(1),
                            Icons.repeat,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildKPICard(
                            'Total Volume',
                            '${(_totalVolume / 1000).toStringAsFixed(1)}K lbs',
                            Icons.stacked_bar_chart,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildKPICard(
                            'Frequency',
                            '$_frequency /mo',
                            Icons.calendar_today,
                          ),
                        ),
                      ],
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
                            child: Row(
                              children: [
                                Expanded(
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
                                      const SizedBox(height: 4),
                                      Text(
                                        '${entry.sets} sets x ${entry.reps} reps @ ${entry.weight} lbs',
                                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                              color: const Color(0xFF8E8E93),
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (entry.isPR)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary,
                                      borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                                    ),
                                    child: Text(
                                      'PR',
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                            color: AppColors.backgroundDark,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                    ),
                                  )
                                else
                                  const Icon(
                                    Icons.chevron_right,
                                    color: Color(0xFF8E8E93),
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
      painter: _LineGraphPainter(),
      child: Container(),
    );
  }
}

class _LineGraphPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final path = Path();
    final points = [
      Offset(0, size.height * 0.7),
      Offset(size.width * 0.25, size.height * 0.6),
      Offset(size.width * 0.5, size.height * 0.5),
      Offset(size.width * 0.75, size.height * 0.4),
      Offset(size.width, size.height * 0.3),
    ];

    path.moveTo(points[0].dx, points[0].dy);
    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }

    canvas.drawPath(path, paint);

    final pointPaint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.fill;
    for (final point in points) {
      canvas.drawCircle(point, 6, pointPaint);
    }

    // Y-axis labels
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );
    final yLabels = ['150', '175', '200', '225'];
    for (int i = 0; i < yLabels.length; i++) {
      textPainter.text = TextSpan(
        text: yLabels[i],
        style: const TextStyle(
          color: Color(0xFF8E8E93),
          fontSize: 10,
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          0,
          size.height - (size.height / (yLabels.length - 1)) * i - textPainter.height / 2,
        ),
      );
    }

    // X-axis labels
    final xLabels = ['Jul', 'Aug', 'Sep', 'Oct', 'Nov'];
    for (int i = 0; i < xLabels.length; i++) {
      textPainter.text = TextSpan(
        text: xLabels[i],
        style: const TextStyle(
          color: Color(0xFF8E8E93),
          fontSize: 10,
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          (size.width / (xLabels.length - 1)) * i - textPainter.width / 2,
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
  final int sets;
  final int reps;
  final double weight;
  final bool isPR;

  WorkoutHistoryEntry({
    required this.date,
    required this.sets,
    required this.reps,
    required this.weight,
    required this.isPR,
  });
}
