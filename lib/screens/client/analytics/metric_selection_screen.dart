import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/common/primary_button.dart';

class MetricSelectionScreen extends StatelessWidget {
  final String currentMetric;
  final Function(String) onMetricSelected;

  const MetricSelectionScreen({
    super.key,
    required this.currentMetric,
    required this.onMetricSelected,
  });

  @override
  Widget build(BuildContext context) {
    String selectedMetric = currentMetric;

    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: const BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: const Color(0xFF8E8E93),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Title
          Text(
            'Select Metric',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 24),
          // Metric Options
          StatefulBuilder(
            builder: (context, setState) {
              return Column(
                children: [
                  _buildMetricOption(
                    context,
                    'Max Weight Lifted',
                    'The heaviest weight successfully lifted.',
                    'Max Weight (lbs)',
                    selectedMetric,
                    () {
                      setState(() => selectedMetric = 'Max Weight (lbs)');
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildMetricOption(
                    context,
                    'Total Volume',
                    'The sum of Sets x Reps x Weight.',
                    'Total Volume',
                    selectedMetric,
                    () {
                      setState(() => selectedMetric = 'Total Volume');
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildMetricOption(
                    context,
                    'Estimated 1 Rep Max',
                    'Calculated maximum weight for a single rep.',
                    'Estimated 1RM',
                    selectedMetric,
                    () {
                      setState(() => selectedMetric = 'Estimated 1RM');
                    },
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 24),
          // Done Button
          SizedBox(
            width: double.infinity,
            child: PrimaryButton(
              text: 'Done',
              onPressed: () {
                onMetricSelected(selectedMetric);
                Navigator.pop(context);
              },
            ),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }

  Widget _buildMetricOption(
    BuildContext context,
    String title,
    String description,
    String value,
    String selectedMetric,
    VoidCallback onTap,
  ) {
    final isSelected = selectedMetric == value;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary20
              : AppColors.backgroundDark,
          borderRadius: BorderRadius.circular(AppTheme.radiusDefault),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
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
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: const Color(0xFF8E8E93),
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected
                    ? AppColors.primary
                    : Colors.transparent,
                border: Border.all(
                  color: isSelected
                      ? AppColors.primary
                      : Colors.white.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(
                      Icons.check,
                      color: AppColors.backgroundDark,
                      size: 16,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
