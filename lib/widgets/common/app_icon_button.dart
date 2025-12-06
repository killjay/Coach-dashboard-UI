import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../theme/app_colors.dart';

class AppIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final double size;
  final Color? backgroundColor;
  final Color? iconColor;
  final double iconSize;

  const AppIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.size = 40.0,
    this.backgroundColor,
    this.iconColor,
    this.iconSize = 24.0,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = backgroundColor ??
        (isDark ? AppColors.card : AppColors.backgroundLight);
    final icColor = iconColor ??
        (isDark ? AppColors.textPrimaryDark : AppColors.textZinc900);

    return SizedBox(
      width: size,
      height: size,
      child: Material(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(AppTheme.radiusFull),
          child: Icon(
            icon,
            color: icColor,
            size: iconSize,
          ),
        ),
      ),
    );
  }
}




