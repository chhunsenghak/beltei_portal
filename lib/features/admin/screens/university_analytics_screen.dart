import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/providers/admin_providers.dart';
import '../../../core/services/admin_service.dart';

const _kMonths = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

final _kGradeColors = [
  AppColors.statusGreen,
  AppColors.primaryBlue,
  AppColors.statusAmber,
  AppColors.statusRed,
  AppColors.primaryNavy,
];

final _kAttendanceColors = [
  AppColors.primaryNavy,
  AppColors.primaryBlue,
  Color(0xFF7C3AED),
  AppColors.statusAmber,
  AppColors.statusRed,
];

class UniversityAnalyticsScreen extends ConsumerStatefulWidget {
  const UniversityAnalyticsScreen({super.key});

  @override
  ConsumerState<UniversityAnalyticsScreen> createState() =>
      _UniversityAnalyticsScreenState();
}

class _UniversityAnalyticsScreenState
    extends ConsumerState<UniversityAnalyticsScreen> {
  String _semester = 'Fall Semester 2023 — 2024';

  @override
  Widget build(BuildContext context) {
    final statsAsync = ref.watch(adminStatsProvider);
    final analyticsAsync = ref.watch(adminAnalyticsProvider);
    final stats = statsAsync.valueOrNull;
    final analytics = analyticsAsync.valueOrNull;
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        children: [
          _buildHeader(),
          const SizedBox(height: 16),
          _buildKpiCards(stats, analytics),
          const SizedBox(height: 20),
          _buildEnrollmentTrend(analytics),
          const SizedBox(height: 16),
          _buildGradeDistribution(analytics),
          const SizedBox(height: 16),
          _buildDeptAttendance(analytics),
          const SizedBox(height: 16),
          _buildAtRiskCard(analytics),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('University Analytics',
            style: AppTextStyles.h1.copyWith(color: AppColors.primaryNavy)),
        const SizedBox(height: 4),
        Text('Key performance metrics across all departments.',
            style: AppTextStyles.caption),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Container(
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.bgCard,
                  borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
                  border: Border.all(color: AppColors.border),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _semester,
                    isExpanded: true,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    items: [
                      'Fall Semester 2023 — 2024',
                      'Spring Semester 2023 — 2024',
                      'Fall Semester 2022 — 2023',
                    ]
                        .map((e) => DropdownMenuItem(
                            value: e,
                            child: Text(e, style: AppTextStyles.caption)))
                        .toList(),
                    onChanged: (v) => setState(() => _semester = v!),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.download_outlined,
                  size: 14, color: Colors.white),
              label:
                  Text('Export', style: AppTextStyles.button.copyWith(fontSize: 13)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryNavy,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.buttonRadius)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildKpiCards(AdminStats? stats, AdminAnalyticsData? analytics) {
    // Compute weighted average attendance from faculty data
    String attendanceLabel = '—';
    if (analytics != null && analytics.facultyAttendance.isNotEmpty) {
      final avg = analytics.facultyAttendance
              .fold<double>(0, (s, f) => s + f.attendancePct) /
          analytics.facultyAttendance.length;
      attendanceLabel = '${(avg * 100).toStringAsFixed(1)}%';
    }

    final kpis = [
      (
        label: 'Active Students',
        value: stats != null ? '${stats.studentCount}' : '—',
        sub: 'enrolled',
        color: AppColors.primaryNavy
      ),
      (
        label: 'Active Courses',
        value: stats != null ? '${stats.courseCount}' : '—',
        sub: 'this semester',
        color: AppColors.primaryBlue
      ),
      (
        label: 'Attendance Rate',
        value: attendanceLabel,
        sub: 'avg rate',
        color: AppColors.statusGreen
      ),
      (
        label: 'Revenue Collected',
        value: stats?.fmtCollected ?? '—',
        sub: 'this year',
        color: AppColors.statusAmber
      ),
    ];
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 1.7,
      children: kpis.map((k) {
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
              Text(k.label, style: AppTextStyles.label.copyWith(fontSize: 9)),
              Text(k.value,
                  style: AppTextStyles.metric
                      .copyWith(color: k.color, fontSize: 20)),
              Text(k.sub,
                  style: AppTextStyles.caption
                      .copyWith(color: AppColors.statusGreen, fontSize: 11)),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildEnrollmentTrend(AdminAnalyticsData? analytics) {
    // Pad/truncate to 12 months; align to _kMonths labels
    final data = analytics?.monthlyEnrollments ?? [];
    final maxCount = data.fold<int>(1, (m, e) => e.count > m ? e.count : m);

    return _AnalyticsCard(
      title: 'Student Enrollment Trend',
      subtitle: 'Total Enrollment',
      child: SizedBox(
        height: 80,
        child: data.isEmpty
            ? const Center(
                child: CircularProgressIndicator(strokeWidth: 2))
            : Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(data.length, (i) {
                  final norm = data[i].count / maxCount;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 1),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            height: (norm * 70).clamp(2.0, 70.0),
                            decoration: BoxDecoration(
                              color: AppColors.primaryBlue
                                  .withValues(alpha: 0.2 + norm * 0.5),
                              borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(3)),
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            data[i].month.isNotEmpty
                                ? data[i].month
                                : (i < _kMonths.length ? _kMonths[i] : ''),
                            style: AppTextStyles.label.copyWith(fontSize: 7),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
      ),
    );
  }

  Widget _buildGradeDistribution(AdminAnalyticsData? analytics) {
    final grades = analytics?.gradeDistribution ?? [];
    final total =
        grades.fold<int>(1, (s, g) => s + g.count);

    return _AnalyticsCard(
      title: 'Grade Distribution',
      child: grades.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: CircularProgressIndicator(strokeWidth: 2),
              ))
          : Column(
              children: List.generate(grades.length, (i) {
                final pct = grades[i].count / total;
                final color =
                    _kGradeColors[i % _kGradeColors.length];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 80,
                        child: Text(
                          grades[i].grade,
                          style: AppTextStyles.label
                              .copyWith(fontSize: 9, letterSpacing: 0),
                        ),
                      ),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(3),
                          child: LinearProgressIndicator(
                            value: pct,
                            minHeight: 12,
                            backgroundColor: AppColors.border,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(color),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 30,
                        child: Text(
                          '${(pct * 100).toInt()}%',
                          style: AppTextStyles.label.copyWith(
                              fontSize: 9,
                              letterSpacing: 0,
                              color: AppColors.textSecondary),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
    );
  }

  Widget _buildDeptAttendance(AdminAnalyticsData? analytics) {
    final depts = analytics?.facultyAttendance ?? [];

    return _AnalyticsCard(
      title: 'Department Attendance (%)',
      child: depts.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: CircularProgressIndicator(strokeWidth: 2),
              ))
          : Column(
              children: List.generate(depts.length, (i) {
                final color =
                    _kAttendanceColors[i % _kAttendanceColors.length];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 80,
                        child: Text(
                          depts[i].name,
                          style: AppTextStyles.label
                              .copyWith(fontSize: 9, letterSpacing: 0),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(3),
                          child: LinearProgressIndicator(
                            value: depts[i].attendancePct,
                            minHeight: 10,
                            backgroundColor: AppColors.border,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(color),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${(depts[i].attendancePct * 100).toInt()}%',
                        style: AppTextStyles.label.copyWith(
                            fontSize: 9,
                            letterSpacing: 0,
                            color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                );
              }),
            ),
    );
  }

  Widget _buildAtRiskCard(AdminAnalyticsData? analytics) {
    final label = analytics != null
        ? '${analytics.atRiskCount} Students'
        : '— Students';

    return Container(
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.statusRedBg,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border:
            Border.all(color: AppColors.statusRed.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('At-Risk Students',
                  style:
                      AppTextStyles.h3.copyWith(color: AppColors.statusRed)),
              const SizedBox(height: 4),
              Text('Attendance < 75%', style: AppTextStyles.caption),
            ],
          ),
          const Spacer(),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.statusRed,
              borderRadius: BorderRadius.circular(AppSpacing.chipRadius),
            ),
            child: Text(label,
                style: AppTextStyles.label
                    .copyWith(color: Colors.white, letterSpacing: 0.3)),
          ),
        ],
      ),
    );
  }
}

class _AnalyticsCard extends StatelessWidget {
  const _AnalyticsCard(
      {required this.title, this.subtitle, required this.child});
  final String title;
  final String? subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: AppTextStyles.h3),
              if (subtitle != null)
                Text(subtitle!, style: AppTextStyles.caption),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}
