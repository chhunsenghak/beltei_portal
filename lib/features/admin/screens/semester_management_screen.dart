import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/providers/admin_providers.dart';
import '../../../core/services/admin_service.dart';

// ── Screen ────────────────────────────────────────────────────────────────────

class SemesterManagementScreen extends ConsumerStatefulWidget {
  const SemesterManagementScreen({super.key});

  @override
  ConsumerState<SemesterManagementScreen> createState() =>
      _SemesterManagementScreenState();
}

class _SemesterManagementScreenState
    extends ConsumerState<SemesterManagementScreen> {
  final Map<String, bool> _regToggles = {};

  @override
  Widget build(BuildContext context) {
    final semestersAsync = ref.watch(adminSemestersProvider);

    return Scaffold(
      backgroundColor: AppColors.bgPage,
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: AppColors.primaryBlue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: semestersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline,
                  color: AppColors.statusRed, size: 40),
              const SizedBox(height: 8),
              Text('Could not load semesters', style: AppTextStyles.bodyMedium),
              TextButton(
                onPressed: () => ref.invalidate(adminSemestersProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (semesters) {
          for (final s in semesters) {
            _regToggles.putIfAbsent(s.id, () => s.isCurrent);
          }

          final current = semesters.where((s) => s.isCurrent).firstOrNull;

          return ListView(
            padding: const EdgeInsets.all(AppSpacing.screenPadding),
            children: [
              Text('Semester Management',
                  style: AppTextStyles.h1
                      .copyWith(color: AppColors.primaryNavy)),
              const SizedBox(height: 4),
              Text(
                  'Configure and monitor academic periods and registration windows.',
                  style: AppTextStyles.caption),
              const SizedBox(height: 20),
              ...semesters.map((s) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _SemesterCard(
                      semester: s,
                      registrationOpen: _regToggles[s.id] ?? false,
                      onRegistrationToggle: (val) =>
                          setState(() => _regToggles[s.id] = val),
                    ),
                  )),
              const SizedBox(height: 16),
              if (current != null) _buildCurrentFocusCard(current),
              if (current != null) const SizedBox(height: 12),
              _buildRegistrationAnalyticsCard(semesters),
              const SizedBox(height: 80),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCurrentFocusCard(AdminSemester current) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.primaryNavy,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('CURRENT SEMESTER',
              style: AppTextStyles.label.copyWith(
                  color: Colors.white.withValues(alpha: 0.7), letterSpacing: 1)),
          const SizedBox(height: 4),
          Text(current.name,
              style: AppTextStyles.h2.copyWith(color: Colors.white)),
          const SizedBox(height: 4),
          Text('${current.fmtStart} – ${current.fmtEnd}',
              style: AppTextStyles.captionWhite),
        ],
      ),
    );
  }

  Widget _buildRegistrationAnalyticsCard(List<AdminSemester> semesters) {
    final total = semesters.length;
    final closed = semesters.where((s) => s.statusLabel == 'CLOSED').length;
    final completionPct = total > 0 ? closed / total : 0.0;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Semester Overview', style: AppTextStyles.h3),
                const SizedBox(height: 4),
                Text(
                    '$total total semesters • $closed completed',
                    style: AppTextStyles.caption),
              ],
            ),
          ),
          SizedBox(
            width: 44, height: 44,
            child: CircularProgressIndicator(
              value: completionPct,
              strokeWidth: 5,
              backgroundColor: AppColors.border,
              valueColor: const AlwaysStoppedAnimation<Color>(
                  AppColors.primaryBlue),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Semester card ─────────────────────────────────────────────────────────────

class _SemesterCard extends StatelessWidget {
  const _SemesterCard({
    required this.semester,
    required this.registrationOpen,
    required this.onRegistrationToggle,
  });

  final AdminSemester semester;
  final bool registrationOpen;
  final ValueChanged<bool> onRegistrationToggle;

  Color get _statusColor {
    switch (semester.statusLabel) {
      case 'ACTIVE': return AppColors.primaryBlue;
      case 'UPCOMING': return AppColors.statusAmber;
      default: return AppColors.statusGray;
    }
  }

  Color get _statusBg {
    switch (semester.statusLabel) {
      case 'ACTIVE': return AppColors.statusBlueBg;
      case 'UPCOMING': return AppColors.statusAmberBg;
      default: return AppColors.statusGrayBg;
    }
  }

  IconData get _icon {
    switch (semester.statusLabel) {
      case 'ACTIVE': return Icons.calendar_today_outlined;
      case 'UPCOMING': return Icons.access_time_outlined;
      default: return Icons.history_outlined;
    }
  }

  bool get _isClosed => semester.statusLabel == 'CLOSED';

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: _isClosed ? 0.7 : 1.0,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.cardPadding),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(
                    color: _statusBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(_icon, color: _statusColor, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(semester.name, style: AppTextStyles.bodyMedium),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(Icons.calendar_month_outlined,
                              size: 12, color: AppColors.textSecondary),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              '${semester.fmtStart} – ${semester.fmtEnd}',
                              style: AppTextStyles.caption.copyWith(fontSize: 11),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: _statusBg,
                    borderRadius:
                        BorderRadius.circular(AppSpacing.tagRadius),
                  ),
                  child: Text(semester.statusLabel,
                      style: AppTextStyles.label.copyWith(
                          color: _statusColor, fontSize: 9, letterSpacing: 0.5)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1, color: AppColors.divider),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text('Registration',
                        style: AppTextStyles.caption.copyWith(
                            color: _isClosed
                                ? AppColors.textLabel
                                : AppColors.textSecondary)),
                    const SizedBox(width: 8),
                    Switch(
                      value: registrationOpen,
                      onChanged: _isClosed ? null : onRegistrationToggle,
                      activeThumbColor: AppColors.primaryBlue,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ],
                ),
                const Icon(Icons.more_vert,
                    size: 18, color: AppColors.textSecondary),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
