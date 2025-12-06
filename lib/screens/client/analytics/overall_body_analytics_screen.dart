import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/common/app_icon_button.dart';
import '../../../widgets/common/primary_button.dart';
import '../tracking/body_metrics_tracker_screen.dart';

class OverallBodyAnalyticsScreen extends StatefulWidget {
  const OverallBodyAnalyticsScreen({super.key});

  @override
  State<OverallBodyAnalyticsScreen> createState() => _OverallBodyAnalyticsScreenState();
}

class _OverallBodyAnalyticsScreenState extends State<OverallBodyAnalyticsScreen> {
  int _selectedMetric = 0; // 0 = Weight, 1 = BMI, 2 = Body Fat
  int _selectedTimeRange = 1; // 0 = 1M, 1 = 3M, 2 = 6M, 3 = 1Y, 4 = All

  final List<String> _metrics = ['Weight', 'BMI', 'Body Fat %'];
  final List<String> _timeRanges = ['1M', '3M', '6M', '1Y', 'All'];

  // Mock data
  final double _currentWeight = 155.2;
  final double _currentBMI = 22.5;
  final double _currentBodyFat = 15.0;
  final double _weightChange = -5.8;
  final double _bmiChange = -0.8;
  final double _bodyFatChange = -2.5;

  String get _currentValue {
    switch (_selectedMetric) {
      case 0:
        return '$_currentWeight lbs';
      case 1:
        return _currentBMI.toStringAsFixed(1);
      case 2:
        return '$_currentBodyFat %';
      default:
        return '';
    }
  }

  String get _changeValue {
    switch (_selectedMetric) {
      case 0:
        return '${_weightChange > 0 ? '+' : ''}${_weightChange.toStringAsFixed(1)} lbs';
      case 1:
        return '${_bmiChange > 0 ? '+' : ''}${_bmiChange.toStringAsFixed(1)}';
      case 2:
        return '${_bodyFatChange > 0 ? '+' : ''}${_bodyFatChange.toStringAsFixed(1)} %';
      default:
        return '';
    }
  }

  String get _metricLabel {
    switch (_selectedMetric) {
      case 0:
        return 'Body Weight';
      case 1:
        return 'BMI';
      case 2:
        return 'Body Fat %';
      default:
        return '';
    }
  }

  String get _timeRangeLabel {
    switch (_selectedTimeRange) {
      case 0:
        return 'Last 1 Month';
      case 1:
        return 'Last 3 Months';
      case 2:
        return 'Last 6 Months';
      case 3:
        return 'Last 1 Year';
      case 4:
        return 'All Time';
      default:
        return '';
    }
  }

  String get _summaryText {
    switch (_selectedMetric) {
      case 0:
        return 'Your current weight is $_currentWeight lbs. This reflects a ${_weightChange > 0 ? '+' : ''}${_weightChange.toStringAsFixed(1)} lbs change in the last 3 months.';
      case 1:
        return 'Your current BMI is ${_currentBMI.toStringAsFixed(1)}. This reflects a ${_bmiChange > 0 ? '+' : ''}${_bmiChange.toStringAsFixed(1)} change in the last 3 months.';
      case 2:
        return 'Your current body fat percentage is $_currentBodyFat%. This reflects a ${_bodyFatChange > 0 ? '+' : ''}${_bodyFatChange.toStringAsFixed(1)}% change in the last 3 months.';
      default:
        return '';
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
                      'Body Analytics',
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
            // Metric Selection Tabs
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                children: _metrics.asMap().entries.map((entry) {
                  final index = entry.key;
                  final label = entry.value;
                  final isSelected = _selectedMetric == index;
                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(right: index < _metrics.length - 1 ? 8 : 0),
                      child: GestureDetector(
                        onTap: () {
                          setState(() => _selectedMetric = index);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.cardDark,
                            borderRadius: BorderRadius.circular(AppTheme.radiusDefault),
                          ),
                          child: Text(
                            label,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: isSelected
                                      ? AppColors.backgroundDark
                                      : Colors.white,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
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
                    // Current Metric Data & Change
                    Container(
                      padding: const EdgeInsets.all(20.0),
                      decoration: BoxDecoration(
                        color: AppColors.cardDark,
                        borderRadius: BorderRadius.circular(AppTheme.radiusDefault),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _metricLabel,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: const Color(0xFF8E8E93),
                                ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                _currentValue,
                                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                                      color: Colors.white,
                                      fontSize: 36,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    _timeRangeLabel,
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          color: const Color(0xFF8E8E93),
                                        ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _changeValue,
                                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                          color: _weightChange < 0
                                              ? Colors.red
                                              : AppColors.primary,
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
                      height: 250,
                      padding: const EdgeInsets.all(20.0),
                      decoration: BoxDecoration(
                        color: AppColors.cardDark,
                        borderRadius: BorderRadius.circular(AppTheme.radiusDefault),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Trend Over Time',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                    ),
                    const SizedBox(height: 16),
                          Expanded(
                            child: _buildGraphPlaceholder(),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Summary Section
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Summary',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Current ${_metricLabel} Analysis',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _summaryText,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: const Color(0xFF8E8E93),
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 100), // Space for FAB
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Container(
        margin: const EdgeInsets.all(16.0),
        width: double.infinity,
        child: PrimaryButton(
          text: '+ Log New Measurement',
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const BodyMetricsTrackerScreen(),
              ),
            );
          },
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
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

    // Draw a simple line graph
    final path = Path();
    final points = [
      Offset(0, size.height * 0.8),
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

    // Draw points
    final pointPaint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.fill;
    for (final point in points) {
      canvas.drawCircle(point, 6, pointPaint);
    }

    // Draw X-axis labels
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );
    final labels = ['Jan', 'Feb', 'Mar', 'Apr', 'May'];
    for (int i = 0; i < labels.length; i++) {
      textPainter.text = TextSpan(
        text: labels[i],
        style: const TextStyle(
          color: Color(0xFF8E8E93),
          fontSize: 12,
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
