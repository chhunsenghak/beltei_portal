import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/providers/teacher_providers.dart';
import '../../../core/services/teacher_service.dart';

// ── Screen ────────────────────────────────────────────────────────────────────

class AttendanceReportScreen extends ConsumerWidget {
  const AttendanceReportScreen({super.key, required this.courseId});
  final String courseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final courseAsync = ref.watch(courseInfoProvider(courseId));
    final summaryAsync = ref.watch(attendanceSummaryProvider(courseId));

    return Scaffold(
      backgroundColor: AppColors.bgPage,
      body: summaryAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline,
                  color: AppColors.statusRed, size: 40),
              const SizedBox(height: 8),
              Text('Could not load report', style: AppTextStyles.body),
              TextButton(
                onPressed: () =>
                    ref.invalidate(attendanceSummaryProvider(courseId)),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (summary) {
          final course = courseAsync.valueOrNull;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.screenPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTitle(course?.name),
                const SizedBox(height: AppSpacing.md),
                _buildExportButton(),
                const SizedBox(height: AppSpacing.sectionGap),
                _buildStatCards(summary),
                const SizedBox(height: AppSpacing.sectionGap),
                _buildStudentRecords(summary),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  // ── Title ──────────────────────────────────────────────────────────────────

  Widget _buildTitle(String? courseName) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Attendance Report', style: AppTextStyles.h1),
        if (courseName != null)
          Text(courseName,
              style: AppTextStyles.caption
                  .copyWith(color: AppColors.primaryNavy)),
        if (courseName == null)
          Text('Analyze student participation and attendance patterns.',
              style: AppTextStyles.caption.copyWith(height: 1.4)),
      ],
    );
  }

  // ── Export button ──────────────────────────────────────────────────────────

  Widget _buildExportButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {},
        icon: const Icon(Icons.download_outlined, size: 18),
        label: Text('Export Report', style: AppTextStyles.button),
      ),
    );
  }

  // ── Stat cards ─────────────────────────────────────────────────────────────

  Widget _buildStatCards(AttendanceSummaryData summary) {
    final presentRate = summary.avgPresentRate;
    final absentRate =
        summary.students.isNotEmpty && summary.totalSessions > 0
            ? summary.totalAbsent /
                (summary.students.length * summary.totalSessions)
            : 0.0;

    return Column(
      children: [
        _AccentCard(
          accentColor: AppColors.primaryNavy,
          label: 'TOTAL SESSIONS',
          value: '${summary.totalSessions} Sessions',
          subLabel: '${summary.students.length} Students',
          subIcon: Icons.people_outline,
        ),
        const SizedBox(height: 10),
        _AccentCard(
          accentColor: AppColors.statusGreen,
          label: 'PRESENT AVG',
          value: '${(presentRate * 100).toStringAsFixed(1)}%',
          progress: presentRate.clamp(0, 1),
          progressColor: AppColors.statusGreen,
        ),
        const SizedBox(height: 10),
        _AccentCard(
          accentColor: AppColors.statusRed,
          label: 'ABSENT AVG',
          value: '${(absentRate * 100).toStringAsFixed(1)}%',
          progress: absentRate.clamp(0, 1),
          progressColor: AppColors.statusRed,
        ),
      ],
    );
  }

  // ── Student records ────────────────────────────────────────────────────────

  Widget _buildStudentRecords(AttendanceSummaryData summary) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Student Records', style: AppTextStyles.h2),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: AppColors.bgCard,
            borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: [
              _buildTableHeader(),
              Divider(height: 1, color: AppColors.border),
              if (summary.students.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Center(
                    child: Text('No attendance data yet.',
                        style: AppTextStyles.body.copyWith(
                            color: AppColors.textSecondary)),
                  ),
                )
              else
                ...summary.students.asMap().entries.map((e) => Column(
                      children: [
                        _buildRecordRow(e.value),
                        if (e.key < summary.students.length - 1)
                          Divider(
                              height: 1, color: AppColors.divider),
                      ],
                    )),
              if (summary.students.isNotEmpty) ...[
                Divider(height: 1, color: AppColors.border),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    'Showing all ${summary.students.length} students',
                    style: AppTextStyles.caption,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTableHeader() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Expanded(
              flex: 3,
              child: Text('STUDENT\nNAME',
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textLabel,
                      letterSpacing: 0.5))),
          ...['PRESENT', 'ABSENT'].map((h) => Expanded(
                child: Text(h,
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textLabel,
                        letterSpacing: 0.5),
                    textAlign: TextAlign.center),
              )),
        ],
      ),
    );
  }

  Widget _buildRecordRow(
      ({String studentId, String fullName, int presentCount, int absentCount})
          r) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor:
                      AppColors.primaryNavy.withValues(alpha: 0.1),
                  child: Text(
                      r.fullName.isNotEmpty ? r.fullName[0].toUpperCase() : '?',
                      style: AppTextStyles.caption.copyWith(
                          color: AppColors.primaryNavy,
                          fontWeight: FontWeight.w700)),
                ),
                const SizedBox(width: 8),
                Expanded(
                    child: Text(r.fullName,
                        style: AppTextStyles.body,
                        overflow: TextOverflow.ellipsis)),
              ],
            ),
          ),
          Expanded(
            child: Text('${r.presentCount}',
                style: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.statusGreen),
                textAlign: TextAlign.center),
          ),
          Expanded(
            child: Text('${r.absentCount}',
                style: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.statusRed),
                textAlign: TextAlign.center),
          ),
        ],
      ),
    );
  }
}

// ── Accent stat card ───────────────────────────────────────────────────────────

class _AccentCard extends StatelessWidget {
  const _AccentCard({
    required this.accentColor,
    required this.label,
    required this.value,
    this.subLabel,
    this.subIcon,
    this.progress,
    this.progressColor,
  });

  final Color accentColor;
  final String label, value;
  final String? subLabel;
  final IconData? subIcon;
  final double? progress;
  final Color? progressColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 50,
            decoration: BoxDecoration(
              color: accentColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTextStyles.label),
                const SizedBox(height: 4),
                Text(value,
                    style: AppTextStyles.metric
                        .copyWith(color: accentColor, fontSize: 24)),
                if (subLabel != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (subIcon != null)
                        Icon(subIcon!,
                            size: 12, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Text(subLabel!, style: AppTextStyles.caption),
                    ],
                  ),
                ],
                if (progress != null) ...[
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 6,
                      backgroundColor: AppColors.border,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(progressColor!),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
