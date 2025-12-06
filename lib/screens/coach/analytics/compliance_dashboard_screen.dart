import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/common/app_icon_button.dart';
import '../../../widgets/common/app_card.dart';
import '../client_management/client_profile_view_screen.dart';

class ComplianceDashboardScreen extends StatefulWidget {
  const ComplianceDashboardScreen({super.key});

  @override
  State<ComplianceDashboardScreen> createState() => _ComplianceDashboardScreenState();
}

class _ComplianceDashboardScreenState extends State<ComplianceDashboardScreen> {
  int _selectedFilter = 0; // 0 = Top Performers, 1 = At-Risk Clients
  String _selectedTimePeriod = 'Last 7 Days';

  final List<String> _timePeriods = ['Last 7 Days', 'Last 30 Days', 'This Month', 'Last Month', 'All Time'];

  // Mock data
  final double _overallCompliance = 82.0;
  final double _overallChange = 2.5;
  final double _workoutsLogged = 75.0;
  final double _workoutsChange = -1.2;
  final double _nutritionCompliance = 68.0;

  final List<ClientComplianceData> _topPerformers = [
    ClientComplianceData(name: 'Jessica Miller', compliance: 95.0),
    ClientComplianceData(name: 'David Chen', compliance: 92.0),
    ClientComplianceData(name: 'Emily Rodriguez', compliance: 88.0),
    ClientComplianceData(name: 'Michael Brown', compliance: 85.0),
  ];

  final List<ClientComplianceData> _atRiskClients = [
    ClientComplianceData(name: 'Sarah Johnson', compliance: 32.0),
    ClientComplianceData(name: 'Tom Wilson', compliance: 45.0),
    ClientComplianceData(name: 'Lisa Anderson', compliance: 51.0),
    ClientComplianceData(name: 'Chris Martinez', compliance: 58.0),
  ];

  List<ClientComplianceData> get _displayedClients {
    return _selectedFilter == 0 ? _topPerformers : _atRiskClients;
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
                    icon: Icons.menu,
                    onPressed: () {
                      // Open navigation drawer
                    },
                    iconColor: Colors.white,
                  ),
                  Expanded(
                    child: Text(
                      'Compliance',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
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
                            children: _timePeriods.map((period) => ListTile(
                                  title: Text(period, style: const TextStyle(color: Colors.white)),
                                  trailing: _selectedTimePeriod == period
                                      ? const Icon(Icons.check, color: AppColors.primary)
                                      : null,
                                  onTap: () {
                                    setState(() => _selectedTimePeriod = period);
                                    Navigator.pop(context);
                                  },
                                )).toList(),
                          ),
                        ),
                      );
                    },
              child: Row(
                      mainAxisSize: MainAxisSize.min,
                children: [
                        Text(
                          _selectedTimePeriod,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.arrow_drop_down, color: Colors.white, size: 20),
                      ],
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
                    // Overall Compliance Summary Cards
                    Row(
                      children: [
                        Expanded(
                          child: _buildSummaryCard(
                            'Overall Compliance',
                            '${_overallCompliance.toInt()}%',
                            _overallChange,
                            isPositive: true,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildSummaryCard(
                            'Workouts Logged',
                            '${_workoutsLogged.toInt()}%',
                            _workoutsChange,
                            isPositive: false,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Daily Compliance Trend
                    Text(
                      'Daily Compliance Trend',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 16),
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
                                '${_overallCompliance.toInt()}%',
                                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '+${_overallChange.toStringAsFixed(1)}%',
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                  Text(
                                    _selectedTimePeriod,
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          color: const Color(0xFF8E8E93),
                                        ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            height: 150,
                            child: _buildBarChart(),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Compliance by Category
                    Text(
                      'Compliance by Category',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 16),
                    _buildCategoryProgressBar('Workouts', _workoutsLogged, 150, 200),
                    const SizedBox(height: 12),
                    _buildCategoryProgressBar('Nutrition', _nutritionCompliance, 136, 200),
                    const SizedBox(height: 24),
                    // Client List Filters
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _selectedFilter = 0),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: _selectedFilter == 0
                                    ? AppColors.primary
                                    : AppColors.cardDark,
                                borderRadius: BorderRadius.circular(AppTheme.radiusDefault),
                              ),
                              child: Text(
                                'Top Performers',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: _selectedFilter == 0
                                          ? AppColors.backgroundDark
                                          : Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _selectedFilter = 1),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: _selectedFilter == 1
                                    ? AppColors.primary
                                    : AppColors.cardDark,
                                borderRadius: BorderRadius.circular(AppTheme.radiusDefault),
                              ),
                              child: Text(
                                'At-Risk Clients',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: _selectedFilter == 1
                                          ? AppColors.backgroundDark
                                          : Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Individual Client Compliance List
                    ..._displayedClients.map((client) => Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: AppCard(
                            backgroundColor: AppColors.cardDark,
                            padding: const EdgeInsets.all(16.0),
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => ClientProfileViewScreen(clientName: client.name),
                                ),
                              );
                            },
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 24,
                                  backgroundColor: AppColors.primary20,
                                  child: Text(
                                    client.name[0],
                                    style: const TextStyle(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        client.name,
                                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Compliance: ${client.compliance.toInt()}%',
                                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                              color: const Color(0xFF8E8E93),
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: _getComplianceColor(client.compliance).withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                                  ),
                                  child: Text(
                                    '${client.compliance.toInt()}%',
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                          color: _getComplianceColor(client.compliance),
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
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

  Widget _buildSummaryCard(String title, String value, double change, {required bool isPositive}) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(AppTheme.radiusDefault),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: const Color(0xFF8E8E93),
                ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                color: isPositive ? AppColors.primary : Colors.red,
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                '${change.abs().toStringAsFixed(1)}%',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: isPositive ? AppColors.primary : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryProgressBar(String label, double percentage, int count, int total) {
    return Container(
      padding: const EdgeInsets.all(16.0),
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
                label,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              Text(
                '${percentage.toInt()}%',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percentage / 100,
              backgroundColor: Colors.white.withOpacity(0.1),
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$count/$total clients ${label == 'Workouts' ? 'logged' : 'tracked'}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: const Color(0xFF8E8E93),
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildBarChart() {
    return CustomPaint(
      painter: _BarChartPainter(),
      child: Container(),
    );
  }

  Color _getComplianceColor(double compliance) {
    if (compliance >= 80) return AppColors.primary;
    if (compliance >= 60) return Colors.orange;
    return Colors.red;
  }
}

class _BarChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final barWidth = size.width / 7;
    final maxHeight = size.height - 30;
    final values = [75.0, 80.0, 78.0, 82.0, 85.0, 83.0, 82.0];

    final paint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.fill;

    for (int i = 0; i < values.length; i++) {
      final barHeight = (values[i] / 100) * maxHeight;
      final x = i * barWidth + barWidth / 2 - 8;
      final y = size.height - barHeight - 20;

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, y, 16, barHeight),
          const Radius.circular(4),
        ),
        paint,
      );
    }

    // Day labels
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );
    final labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
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
          i * barWidth + barWidth / 2 - textPainter.width / 2,
          size.height - 15,
        ),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class ClientComplianceData {
  final String name;
  final double compliance;

  ClientComplianceData({
    required this.name,
    required this.compliance,
  });
}
