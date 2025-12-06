import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../theme/app_colors.dart';

class ToggleSwitch extends StatelessWidget {
  final List<String> options;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  const ToggleSwitch({
    super.key,
    required this.options,
    required this.selectedIndex,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: 48.0,
      padding: const EdgeInsets.all(2.0),
      decoration: BoxDecoration(
        color: isDark ? AppColors.black20 : Colors.transparent,
        border: Border.all(
          color: isDark ? AppColors.borderWhite10 : Colors.transparent,
        ),
        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
      ),
      child: Row(
        children: List.generate(
          options.length,
          (index) => Expanded(
            child: GestureDetector(
              onTap: () => onChanged(index),
              child: Container(
                height: double.infinity,
                decoration: BoxDecoration(
                  color: selectedIndex == index
                      ? (isDark ? AppColors.white10 : AppColors.primary20)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                ),
                child: Center(
                  child: Text(
                    options[index],
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: isDark
                              ? (selectedIndex == index
                                  ? AppColors.textPrimaryDark
                                  : AppColors.white60)
                              : (selectedIndex == index
                                  ? AppColors.textZinc900
                                  : AppColors.textZinc500),
                          fontWeight: selectedIndex == index
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

