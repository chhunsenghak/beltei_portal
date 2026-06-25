import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/router/app_router.dart';
import '../../../shared/widgets/section_header.dart';

// ── Mock data ──────────────────────────────────────────────────────────────────

const _kStats = (
  totalDays: 128,
  present: 112,
  absent: 8,
  leave: 6,
  late: 2,
  rate: 0.88,
);

final _kCourseBreakdown = [
  (name: 'Advanced Mathematics', rate: 0.94),
  (name: 'Global Economics', rate: 0.82),
  (name: 'Information Tech', rate: 0.75),
];

final _kRecentLogs = [
  (date: 'Feb 19, 2024', course: 'Advanced Mathematics', time: '08:00 AM', status: 'Present'),
  (date: 'Feb 18, 2024', course: 'Global Economics', time: '10:30 AM', status: 'Present'),
  (date: 'Feb 15, 2024', course: 'Information Tech', time: '01:45 PM', status: 'Absent'),
  (date: 'Feb 12, 2024', course: 'English Literature', time: '08:00 AM', status: 'Leave'),
];

// ── Screen ────────────────────────────────────────────────────────────────────

class AttendanceDashboardScreen extends StatelessWidget {
  const AttendanceDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTitle(),
            const SizedBox(height: AppSpacing.md),
            _buildStatCards(),
            const SizedBox(height: AppSpacing.sectionGap),
            _buildAttendanceRateCard(),
            const SizedBox(height: AppSpacing.sectionGap),
            _buildCourseBreakdown(),
            const SizedBox(height: AppSpacing.sectionGap),
            _buildRecentLogs(context),
          ],
        ),
      ),
    );
  }

  // ── Title ──────────────────────────────────────────────────────────────────

  Widget _buildTitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Attendance Overview', style: AppTextStyles.h1),
        const SizedBox(height: 4),
        Text('Academic Year 2023-2024 • Semester 2',
            style: AppTextStyles.caption),
      ],
    );
  }

  // ── Stat cards grid ────────────────────────────────────────────────────────

  Widget _buildStatCards() {
    final items = [
      (label: 'TOTAL DAYS', value: '${_kStats.totalDays}', color: AppColors.textPrimary),
      (label: 'PRESENT', value: '${_kStats.present}', color: AppColors.textPrimary),
      (label: 'ABSENT', value: '${_kStats.absent}', color: AppColors.statusRed),
      (label: 'LEAVE', value: '${_kStats.leave}', color: AppColors.statusAmber),
      (label: 'LATE', value: '${_kStats.late}', color: AppColors.statusAmber),
    ];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 1.8,
      children: items.map((item) => _StatCard(
        label: item.label,
        value: item.value,
        valueColor: item.color,
      )).toList(),
    );
  }

  // ── Circular rate card ─────────────────────────────────────────────────────

  Widget _buildAttendanceRateCard() {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Attendance Rate', style: AppTextStyles.h2),
          const SizedBox(height: 20),
          Center(
            child: CircularPercentIndicator(
              radius: 80,
              lineWidth: 10,
              percent: _kStats.rate,
              center: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${(_kStats.rate * 100).round()}%',
                    style: AppTextStyles.metric.copyWith(color: AppColors.statusRed),
                  ),
                  Text('Current Rate', style: AppTextStyles.caption),
                ],
              ),
              progressColor: AppColors.statusRed,
              backgroundColor: AppColors.border,
              circularStrokeCap: CircularStrokeCap.round,
            ),
          ),
        ],
      ),
    );
  }

  // ── Course breakdown bars ──────────────────────────────────────────────────

  Widget _buildCourseBreakdown() {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Course Breakdown', style: AppTextStyles.h2),
          const SizedBox(height: 16),
          ..._kCourseBreakdown.map((c) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _CourseBar(name: c.name, rate: c.rate),
              )),
        ],
      ),
    );
  }

  // ── Recent logs table ──────────────────────────────────────────────────────

  Widget _buildRecentLogs(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Recent Attendance Logs',
          actionLabel: 'View Full History',
          onAction: () => context.go(AppRoutes.attendanceHistory),
        ),
        const SizedBox(height: 12),
        _Card(
          child: Column(
            children: [
              _buildLogTableHeader(),
              const Divider(color: AppColors.border, height: 16),
              ..._kRecentLogs.map((log) => _buildLogRow(log)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLogTableHeader() {
    return Row(
      children: ['DATE', 'COURSE', 'TIME', 'STATUS']
          .map((h) => Expanded(
                child: Text(h, style: AppTextStyles.label),
              ))
          .toList(),
    );
  }

  Widget _buildLogRow(dynamic log) {
    Color statusColor;
    Color statusBg;
    if (log.status == 'Present') {
      statusColor = AppColors.statusGreen;
      statusBg = AppColors.statusGreenBg;
    } else if (log.status == 'Absent') {
      statusColor = AppColors.statusRed;
      statusBg = AppColors.statusRedBg;
    } else {
      statusColor = AppColors.statusAmber;
      statusBg = AppColors.statusAmberBg;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(child: Text(log.date as String, style: AppTextStyles.caption)),
          Expanded(child: Text(log.course as String, style: AppTextStyles.caption)),
          Expanded(child: Text(log.time as String, style: AppTextStyles.caption)),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: statusBg,
                borderRadius: BorderRadius.circular(AppSpacing.chipRadius),
              ),
              child: Text(
                log.status as String,
                style: AppTextStyles.caption.copyWith(
                    color: statusColor, fontWeight: FontWeight.w600, fontSize: 11),
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
  const _StatCard({required this.label, required this.value, required this.valueColor});
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
          Text(value, style: AppTextStyles.metricSmall.copyWith(color: valueColor, fontSize: 22)),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(name, style: AppTextStyles.bodyMedium),
            Text('${(rate * 100).round()}%',
                style: AppTextStyles.bodySemiBold.copyWith(color: AppColors.primaryNavy)),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: rate,
            minHeight: 6,
            backgroundColor: AppColors.border,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryNavy),
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
