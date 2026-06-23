import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/constants/app_spacing.dart';

enum BadgeType { present, absent, leave, completed, active, enrolled, partial, neutral }

class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.label, required this.type});

  final String label;
  final BadgeType type;

  Color get _bg {
    return switch (type) {
      BadgeType.present || BadgeType.completed || BadgeType.active => AppColors.statusGreenBg,
      BadgeType.absent => AppColors.statusRedBg,
      BadgeType.leave || BadgeType.partial => AppColors.statusAmberBg,
      BadgeType.enrolled => AppColors.statusBlueBg,
      BadgeType.neutral => AppColors.statusGrayBg,
    };
  }

  Color get _fg {
    return switch (type) {
      BadgeType.present || BadgeType.completed || BadgeType.active => AppColors.statusGreen,
      BadgeType.absent => AppColors.statusRed,
      BadgeType.leave || BadgeType.partial => AppColors.statusAmber,
      BadgeType.enrolled => AppColors.primaryBlue,
      BadgeType.neutral => AppColors.textSecondary,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _bg,
        borderRadius: BorderRadius.circular(AppSpacing.chipRadius),
      ),
      child: Text(
        label,
        style: AppTextStyles.caption.copyWith(color: _fg, fontWeight: FontWeight.w600),
      ),
    );
  }
}
