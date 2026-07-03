import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/providers/admin_providers.dart';
import '../../../core/services/admin_service.dart';

const _kExportOptions = [
  (
    icon: Icons.description_outlined,
    label: 'Enrollment Report',
    subtitle: 'PDF / Excel'
  ),
  (
    icon: Icons.account_balance_outlined,
    label: 'Finance Report',
    subtitle: 'PDF / Excel'
  ),
  (
    icon: Icons.how_to_reg_outlined,
    label: 'Attendance Report',
    subtitle: 'PDF / Excel'
  ),
  (
    icon: Icons.grade_outlined,
    label: 'Academic Report',
    subtitle: 'PDF / Excel'
  ),
];

// ── Screen ────────────────────────────────────────────────────────────────────

class AdminReportsScreen extends ConsumerWidget {
  const AdminReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(adminStatsProvider).valueOrNull;
    final analytics = ref.watch(adminAnalyticsProvider).valueOrNull;
    final courses = ref.watch(adminCoursesProvider).valueOrNull;

    return Scaffold(
      backgroundColor: AppColors.bgPage,
      appBar: AppBar(
        backgroundColor: AppColors.primaryNavy,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.go('/admin'),
        ),
        title: Text('Reports & Analytics', style: AppTextStyles.h3White),
        actions: [
          IconButton(
            icon: const Icon(Icons.download_outlined, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFinanceCards(stats),
            const SizedBox(height: AppSpacing.sectionGap),
            _buildEnrollmentChart(analytics),
            const SizedBox(height: AppSpacing.sectionGap),
            _buildTopCourses(courses),
            const SizedBox(height: AppSpacing.sectionGap),
            _buildAttendanceRates(analytics),
            const SizedBox(height: AppSpacing.sectionGap),
            _buildExportSection(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // ── Finance cards ──────────────────────────────────────────────────────────

  Widget _buildFinanceCards(AdminStats? stats) {
    final cards = [
      (
        label: 'Total Revenue',
        value: stats?.fmtRevenue ?? '—',
        icon: Icons.trending_up_outlined,
        color: AppColors.statusGreen
      ),
      (
        label: 'Collected',
        value: stats?.fmtCollected ?? '—',
        icon: Icons.check_circle_outline,
        color: AppColors.primaryBlue
      ),
      (
        label: 'Outstanding',
        value: stats?.fmtOutstanding ?? '—',
        icon: Icons.pending_actions_outlined,
        color: AppColors.statusAmber
      ),
      (
        label: 'At-Risk Students',
        value: stats != null ? '${stats.pendingLeaveCount} leaves' : '—',
        icon: Icons.warning_amber_outlined,
        color: AppColors.statusRed
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Financial Overview', style: AppTextStyles.h2),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 1.7,
          children: cards.map((f) {
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
                  Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: f.color.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(f.icon, color: f.color, size: 16),
                      ),
                      const Spacer(),
                      Icon(Icons.arrow_upward,
                          size: 12,
                          color: f.color == AppColors.statusRed ||
                                  f.color == AppColors.statusAmber
                              ? f.color
                              : AppColors.statusGreen),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(f.value,
                      style: AppTextStyles.metricSmall
                          .copyWith(color: f.color, fontSize: 17)),
                  Text(f.label,
                      style: AppTextStyles.label
                          .copyWith(fontSize: 9, letterSpacing: 0.3),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // ── Enrollment chart ───────────────────────────────────────────────────────

  Widget _buildEnrollmentChart(AdminAnalyticsData? analytics) {
    final data = analytics?.monthlyEnrollments ?? [];
    final maxCount =
        data.fold<int>(1, (m, e) => e.count > m ? e.count : m);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Monthly Enrollment', style: AppTextStyles.h2),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.fromLTRB(12, 16, 12, 12),
          decoration: BoxDecoration(
            color: AppColors.bgCard,
            borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
            border: Border.all(color: AppColors.border),
          ),
          child: data.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ))
              : Column(
                  children: [
                    SizedBox(
                      height: 120,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: data.map((e) {
                          final barH =
                              (e.count / maxCount * 110).clamp(2.0, 110.0);
                          return Expanded(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 2),
                              child: Tooltip(
                                message: '${e.count}',
                                child: Container(
                                  height: barH,
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryNavy
                                        .withValues(alpha: 0.75),
                                    borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(3)),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: data.map((e) {
                        return Expanded(
                          child: Text(e.month,
                              style: AppTextStyles.caption
                                  .copyWith(fontSize: 9),
                              textAlign: TextAlign.center),
                        );
                      }).toList(),
                    ),
                  ],
                ),
        ),
      ],
    );
  }

  // ── Top enrolled courses ───────────────────────────────────────────────────

  Widget _buildTopCourses(List<AdminCourse>? courses) {
    final top = courses != null
        ? ([...courses]
          ..sort((a, b) => b.enrolledCount.compareTo(a.enrolledCount)))
            .take(5)
            .toList()
        : <AdminCourse>[];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Top Enrolled Courses', style: AppTextStyles.h2),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(AppSpacing.cardPadding),
          decoration: BoxDecoration(
            color: AppColors.bgCard,
            borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
            border: Border.all(color: AppColors.border),
          ),
          child: top.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ))
              : Column(
                  children: top.asMap().entries.map((entry) {
                    final i = entry.key;
                    final c = entry.value;
                    final pct = c.maxStudents > 0
                        ? c.enrolledCount / c.maxStudents
                        : 0.0;
                    return Padding(
                      padding: EdgeInsets.only(
                          bottom: i < top.length - 1 ? 12 : 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 22,
                                height: 22,
                                decoration: BoxDecoration(
                                  color: i == 0
                                      ? AppColors.accentGold
                                          .withValues(alpha: 0.15)
                                      : AppColors.bgInput,
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text('${i + 1}',
                                      style: AppTextStyles.label.copyWith(
                                          color: i == 0
                                              ? AppColors.accentGold
                                              : AppColors.textSecondary,
                                          letterSpacing: 0)),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(c.name,
                                    style: AppTextStyles.bodyMedium
                                        .copyWith(fontSize: 13)),
                              ),
                              Text(
                                  '${c.enrolledCount}/${c.maxStudents}',
                                  style: AppTextStyles.caption
                                      .copyWith(fontSize: 11)),
                            ],
                          ),
                          const SizedBox(height: 6),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: pct,
                              minHeight: 5,
                              backgroundColor: AppColors.border,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                pct >= 0.9
                                    ? AppColors.statusGreen
                                    : pct >= 0.75
                                        ? AppColors.primaryBlue
                                        : AppColors.statusAmber,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
        ),
      ],
    );
  }

  // ── Attendance rates ───────────────────────────────────────────────────────

  Widget _buildAttendanceRates(AdminAnalyticsData? analytics) {
    final depts = analytics?.facultyAttendance ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Attendance Rates by Department', style: AppTextStyles.h2),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(AppSpacing.cardPadding),
          decoration: BoxDecoration(
            color: AppColors.bgCard,
            borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
            border: Border.all(color: AppColors.border),
          ),
          child: depts.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ))
              : Column(
                  children: depts.map((a) {
                    final rate = a.attendancePct;
                    final color = rate >= 0.85
                        ? AppColors.statusGreen
                        : rate >= 0.75
                            ? AppColors.statusAmber
                            : AppColors.statusRed;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 130,
                            child: Text(a.name,
                                style: AppTextStyles.caption,
                                overflow: TextOverflow.ellipsis),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: rate,
                                minHeight: 8,
                                backgroundColor: AppColors.border,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(color),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          SizedBox(
                            width: 34,
                            child: Text(
                                '${(rate * 100).toInt()}%',
                                style: AppTextStyles.caption.copyWith(
                                    color: color,
                                    fontWeight: FontWeight.w600),
                                textAlign: TextAlign.right),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
        ),
      ],
    );
  }

  // ── Export section ─────────────────────────────────────────────────────────

  Widget _buildExportSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Export Reports', style: AppTextStyles.h2),
        const SizedBox(height: 12),
        ...(_kExportOptions.map((opt) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.cardPadding),
                decoration: BoxDecoration(
                  color: AppColors.bgCard,
                  borderRadius:
                      BorderRadius.circular(AppSpacing.cardRadius),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.primaryNavy.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(opt.icon,
                          color: AppColors.primaryNavy, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(opt.label, style: AppTextStyles.bodyMedium),
                          Text(opt.subtitle, style: AppTextStyles.caption),
                        ],
                      ),
                    ),
                    Icon(Icons.download_outlined,
                        color: AppColors.primaryBlue, size: 20),
                  ],
                ),
              ),
            ))),
      ],
    );
  }
}
