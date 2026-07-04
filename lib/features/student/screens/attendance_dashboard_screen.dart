import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/providers/student_providers.dart';
import '../../../core/services/student_service.dart';
import '../../../core/supabase/database.types.dart';
import '../../../core/router/app_router.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/section_header.dart';

// ── Screen ────────────────────────────────────────────────────────────────────

class AttendanceDashboardScreen extends ConsumerWidget {
  const AttendanceDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final attendanceAsync = ref.watch(studentAttendanceProvider);

    return Scaffold(
      backgroundColor: AppColors.bgPage,
      body: attendanceAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline,
                  color: AppColors.statusRed, size: 40),
              const SizedBox(height: 8),
              Text(l.loadErrorAttendance,
                  style: AppTextStyles.bodyMedium),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () =>
                    ref.invalidate(studentAttendanceProvider),
                child: Text(l.retry),
              ),
            ],
          ),
        ),
        data: (att) => SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTitle(l),
              const SizedBox(height: AppSpacing.md),
              _buildStatCards(att, l),
              const SizedBox(height: AppSpacing.sectionGap),
              _buildAttendanceRateCard(att, l),
              const SizedBox(height: AppSpacing.sectionGap),
              if (att.courseBreakdown.isNotEmpty)
                _buildCourseBreakdown(att.courseBreakdown, l),
              if (att.courseBreakdown.isNotEmpty)
                const SizedBox(height: AppSpacing.sectionGap),
              _buildRecentLogs(context, att.recentRecords, l),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTitle(AppLocalizations l) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l.attendanceDashboardTitle, style: AppTextStyles.h1),
        const SizedBox(height: 4),
        Text(l.attendanceDashboardSubtitle,
            style: AppTextStyles.caption),
      ],
    );
  }

  Widget _buildStatCards(AttendanceSummary att, AppLocalizations l) {
    final items = [
      (label: l.attendanceDashboardTotalDaysLabel, value: '${att.totalDays}', color: AppColors.textPrimary),
      (label: l.statusPresent, value: '${att.present}', color: AppColors.textPrimary),
      (label: l.statusAbsent, value: '${att.absent}', color: AppColors.statusRed),
      (label: l.attendanceDashboardLeaveLabel, value: '${att.excused}', color: AppColors.statusAmber),
      (label: l.statusLate, value: '${att.late}', color: AppColors.statusAmber),
    ];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 1.8,
      children: items
          .map((item) => _StatCard(
                label: item.label,
                value: item.value,
                valueColor: item.color,
              ))
          .toList(),
    );
  }

  Widget _buildAttendanceRateCard(AttendanceSummary att, AppLocalizations l) {
    final rate = att.overallRate;
    final color = rate >= 0.85
        ? AppColors.statusGreen
        : rate >= 0.70
            ? AppColors.statusAmber
            : AppColors.statusRed;

    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l.attendanceDashboardRateTitle, style: AppTextStyles.h2),
          const SizedBox(height: 20),
          Center(
            child: CircularPercentIndicator(
              radius: 80,
              lineWidth: 10,
              percent: rate,
              center: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${(rate * 100).toStringAsFixed(1)}%',
                    style:
                        AppTextStyles.metric.copyWith(color: color),
                  ),
                  Text(l.attendanceDashboardCurrentRateLabel, style: AppTextStyles.caption),
                ],
              ),
              progressColor: color,
              backgroundColor: AppColors.border,
              circularStrokeCap: CircularStrokeCap.round,
            ),
          ),
          if (rate < 0.75) ...[
            const SizedBox(height: 16),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.statusRedBg,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_amber_outlined,
                      color: AppColors.statusRed, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l.attendanceDashboardLowAttendanceWarning,
                      style: AppTextStyles.caption.copyWith(
                          color: AppColors.statusRed),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCourseBreakdown(List<CourseAttendance> courses, AppLocalizations l) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l.attendanceDashboardCourseBreakdownTitle, style: AppTextStyles.h2),
          const SizedBox(height: 16),
          ...courses.map((c) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _CourseBar(name: c.courseName, rate: c.rate),
              )),
        ],
      ),
    );
  }

  Widget _buildRecentLogs(
      BuildContext context, List<AttendanceRecord> records, AppLocalizations l) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: l.attendanceDashboardRecentLogsTitle,
          actionLabel: l.attendanceDashboardViewFullHistory,
          onAction: () => context.go(AppRoutes.attendanceHistory),
        ),
        const SizedBox(height: 12),
        _Card(
          child: Column(
            children: [
              _buildLogTableHeader(l),
              Divider(color: AppColors.border, height: 16),
              if (records.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Center(child: Text(l.attendanceDashboardNoRecords)),
                )
              else
                ...records.map((log) => _buildLogRow(log, l)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLogTableHeader(AppLocalizations l) {
    return Row(
      children: [
        l.attendanceDashboardDateColumn,
        l.attendanceDashboardCourseColumn,
        l.attendanceDashboardStatusColumn
      ]
          .map((h) => Expanded(child: Text(h, style: AppTextStyles.label)))
          .toList(),
    );
  }

  Widget _buildLogRow(AttendanceRecord log, AppLocalizations l) {
    final Color statusColor;
    final Color statusBg;
    final String statusLabel;

    switch (log.status) {
      case AttendanceStatus.present:
        statusColor = AppColors.statusGreen;
        statusBg = AppColors.statusGreenBg;
        statusLabel = l.statusPresent;
      case AttendanceStatus.absent:
        statusColor = AppColors.statusRed;
        statusBg = AppColors.statusRedBg;
        statusLabel = l.statusAbsent;
      case AttendanceStatus.late:
        statusColor = AppColors.statusAmber;
        statusBg = AppColors.statusAmberBg;
        statusLabel = l.statusLate;
      case AttendanceStatus.excused:
        statusColor = AppColors.statusAmber;
        statusBg = AppColors.statusAmberBg;
        statusLabel = l.statusExcused;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
              child: Text(log.date, style: AppTextStyles.caption)),
          Expanded(
              child: Text(log.courseName,
                  style: AppTextStyles.caption,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis)),
          Expanded(
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: statusBg,
                borderRadius:
                    BorderRadius.circular(AppSpacing.chipRadius),
              ),
              child: Text(
                statusLabel,
                style: AppTextStyles.caption.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 11),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Reusable widgets ───────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  const _StatCard(
      {required this.label,
      required this.value,
      required this.valueColor});
  final String label;
  final String value;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label, style: AppTextStyles.label),
          const SizedBox(height: 4),
          Text(value,
              style: AppTextStyles.metricSmall
                  .copyWith(color: valueColor, fontSize: 22)),
        ],
      ),
    );
  }
}

class _CourseBar extends StatelessWidget {
  const _CourseBar({required this.name, required this.rate});
  final String name;
  final double rate;

  @override
  Widget build(BuildContext context) {
    final color = rate >= 0.85
        ? AppColors.primaryNavy
        : rate >= 0.70
            ? AppColors.statusAmber
            : AppColors.statusRed;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(name,
                  style: AppTextStyles.bodyMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
            ),
            Text('${(rate * 100).round()}%',
                style: AppTextStyles.bodySemiBold
                    .copyWith(color: color)),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: rate,
            minHeight: 6,
            backgroundColor: AppColors.border,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(color: AppColors.border),
      ),
      child: child,
    );
  }
}
