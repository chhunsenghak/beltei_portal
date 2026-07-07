import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/providers/teacher_providers.dart';
import '../../../core/services/teacher_service.dart';
import '../../../l10n/app_localizations.dart';

final _kGradeColors = [
  AppColors.primaryNavy,
  Color(0xFF67C8F5),
  AppColors.statusAmber,
  AppColors.statusRed,
  AppColors.statusGray,
];

// ── Screen ────────────────────────────────────────────────────────────────────

class TeacherStudentAnalyticsScreen extends ConsumerStatefulWidget {
  const TeacherStudentAnalyticsScreen({super.key});

  @override
  ConsumerState<TeacherStudentAnalyticsScreen> createState() =>
      _TeacherStudentAnalyticsScreenState();
}

class _TeacherStudentAnalyticsScreenState
    extends ConsumerState<TeacherStudentAnalyticsScreen> {
  String? _selectedCourseId;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final coursesAsync = ref.watch(teacherCoursesProvider);
    final courses = coursesAsync.valueOrNull ?? [];
    final currentCourses =
        courses.where((c) => c.isCurrentSemester).toList();

    // Default to first current course if none selected
    if (_selectedCourseId == null && currentCourses.isNotEmpty) {
      _selectedCourseId = currentCourses.first.classTermCourseId;
    }

    final selectedCourse = currentCourses
        .where((c) => c.classTermCourseId == _selectedCourseId)
        .firstOrNull;

    final analyticsAsync = _selectedCourseId != null
        ? ref.watch(courseAnalyticsProvider(_selectedCourseId!))
        : null;

    return Scaffold(
      backgroundColor: AppColors.bgPage,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTitle(l),
            const SizedBox(height: AppSpacing.md),
            _buildCourseDropdown(currentCourses, selectedCourse, l),
            const SizedBox(height: AppSpacing.sectionGap),
            if (analyticsAsync == null)
              const Center(child: CircularProgressIndicator())
            else
              analyticsAsync.when(
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.error_outline,
                          color: AppColors.statusRed, size: 40),
                      const SizedBox(height: 8),
                      Text(l.teacherAnalyticsLoadError,
                          style: AppTextStyles.body),
                      TextButton(
                        onPressed: () => ref.invalidate(
                            courseAnalyticsProvider(_selectedCourseId!)),
                        child: Text(l.retry),
                      ),
                    ],
                  ),
                ),
                data: (analytics) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildPerformanceRanking(analytics, l),
                    const SizedBox(height: AppSpacing.sectionGap),
                    _buildGradeDistribution(analytics, l),
                    const SizedBox(height: AppSpacing.sectionGap),
                    _buildAttendanceTrend(analytics, l),
                    const SizedBox(height: AppSpacing.sectionGap),
                    _buildAtRiskSection(analytics, l),
                  ],
                ),
              ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // ── Title ──────────────────────────────────────────────────────────────────

  Widget _buildTitle(AppLocalizations l) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l.teacherAnalyticsTitle, style: AppTextStyles.h1),
        Text(l.teacherAnalyticsSubtitle,
            style: AppTextStyles.caption),
      ],
    );
  }

  // ── Course dropdown ────────────────────────────────────────────────────────

  Widget _buildCourseDropdown(List<TeacherCourse> courses,
      TeacherCourse? selected, AppLocalizations l) {
    if (courses.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
          border: Border.all(color: AppColors.border),
        ),
        child: Text(l.teacherAnalyticsNoCurrentCourses,
            style:
                AppTextStyles.body.copyWith(color: AppColors.textSecondary)),
      );
    }

    return GestureDetector(
      onTap: () => showModalBottomSheet(
        context: context,
        backgroundColor: AppColors.bgCard,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        builder: (_) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            ...courses.map((c) => ListTile(
                  title: Text(
                      l.teacherAnalyticsCourseNameWithCode(c.name, c.code),
                      style: AppTextStyles.body),
                  trailing: c.classTermCourseId == _selectedCourseId
                      ? Icon(Icons.check, color: AppColors.primaryNavy)
                      : null,
                  onTap: () {
                    setState(() => _selectedCourseId = c.classTermCourseId);
                    Navigator.pop(context);
                  },
                )),
            const SizedBox(height: 16),
          ],
        ),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                selected != null
                    ? l.teacherAnalyticsCourseNameWithCode(
                        selected.name, selected.code)
                    : l.teacherAnalyticsSelectCourse,
                style: AppTextStyles.body,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(Icons.keyboard_arrow_down,
                color: AppColors.textLabel),
          ],
        ),
      ),
    );
  }

  // ── Performance ranking ────────────────────────────────────────────────────

  Widget _buildPerformanceRanking(
      CourseAnalyticsData analytics, AppLocalizations l) {
    return _Card(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(l.teacherAnalyticsPerformanceRankingTitle,
                  style: AppTextStyles.h2.copyWith(height: 1.3)),
            ],
          ),
          const SizedBox(height: 12),
          if (analytics.ranking.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(l.teacherAnalyticsNoGradeData,
                  style: AppTextStyles.body
                      .copyWith(color: AppColors.textSecondary)),
            )
          else
            ...analytics.ranking.map((r) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: [
                      SizedBox(
                          width: 100,
                          child: Text(r.name,
                              style: AppTextStyles.body,
                              overflow: TextOverflow.ellipsis)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: (r.score / 100).clamp(0, 1),
                            minHeight: 10,
                            backgroundColor: AppColors.border,
                            valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.primaryNavy),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 36,
                        child: Text('${r.score.toInt()}',
                            style: AppTextStyles.bodyMedium
                                .copyWith(color: AppColors.primaryNavy),
                            textAlign: TextAlign.right),
                      ),
                    ],
                  ),
                )),
        ],
      ),
    );
  }

  // ── Grade distribution ─────────────────────────────────────────────────────

  Widget _buildGradeDistribution(
      CourseAnalyticsData analytics, AppLocalizations l) {
    final grades = analytics.gradeDistribution;
    final total = grades.fold<int>(1, (s, g) => s + g.count);

    final sections = grades.isEmpty
        ? [
            PieChartSectionData(
                value: 1,
                color: AppColors.border,
                radius: 36,
                showTitle: false)
          ]
        : grades
            .asMap()
            .entries
            .map((e) => PieChartSectionData(
                  value: e.value.count.toDouble(),
                  color: _kGradeColors[e.key % _kGradeColors.length],
                  radius: 36 + (10 - e.key * 2.0).clamp(0, 10),
                  showTitle: false,
                ))
            .toList();

    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l.teacherAnalyticsGradeDistributionTitle, style: AppTextStyles.h2),
          const SizedBox(height: 16),
          SizedBox(
            height: 180,
            child: PieChart(PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 50,
              sections: sections,
            )),
          ),
          const SizedBox(height: 16),
          if (grades.isEmpty)
            Text(l.courseDetailNoGradesRecorded,
                style: AppTextStyles.body
                    .copyWith(color: AppColors.textSecondary))
          else
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: grades
                  .asMap()
                  .entries
                  .map((e) => _LegendDot(
                        _kGradeColors[e.key % _kGradeColors.length],
                        l.teacherAnalyticsGradeLegendLabel(e.value.grade,
                            (e.value.count / total * 100).toInt()),
                      ))
                  .toList(),
            ),
        ],
      ),
    );
  }

  // ── Attendance trend ───────────────────────────────────────────────────────

  Widget _buildAttendanceTrend(
      CourseAnalyticsData analytics, AppLocalizations l) {
    final monthly = analytics.monthlyAttendance;
    final spots = monthly.isEmpty
        ? [const FlSpot(0, 0)]
        : monthly
            .asMap()
            .entries
            .map((e) => FlSpot(
                e.key.toDouble(), (e.value.avgPct * 100).clamp(0, 100)))
            .toList();

    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(l.teacherAnalyticsAttendanceTrendsTitle, style: AppTextStyles.h2),
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(l.teacherAnalyticsAveragePercentLegend, style: AppTextStyles.caption),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 150,
            child: LineChart(LineChartData(
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                getDrawingHorizontalLine: (_) => FlLine(
                    color: AppColors.border, strokeWidth: 1),
              ),
              titlesData: FlTitlesData(
                leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false)),
                topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (v, _) {
                      final i = v.toInt();
                      if (i < 0 || i >= monthly.length) {
                        return const SizedBox.shrink();
                      }
                      return Text(monthly[i].month,
                          style: AppTextStyles.caption
                              .copyWith(fontSize: 10));
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(show: false),
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  color: AppColors.primaryBlue,
                  barWidth: 2.5,
                  dotData: const FlDotData(show: false),
                  belowBarData: BarAreaData(
                    show: true,
                    color: AppColors.primaryBlue.withValues(alpha: 0.08),
                  ),
                ),
              ],
            )),
          ),
        ],
      ),
    );
  }

  // ── At-risk students ───────────────────────────────────────────────────────

  Widget _buildAtRiskSection(CourseAnalyticsData analytics, AppLocalizations l) {
    final atRisk = analytics.atRiskStudents;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.warning_amber_rounded,
                color: AppColors.statusRed, size: 20),
            const SizedBox(width: 6),
            Text(l.teacherAnalyticsAtRiskStudentsTitle,
                style:
                    AppTextStyles.h2.copyWith(color: AppColors.statusRed)),
          ],
        ),
        const SizedBox(height: 12),
        if (atRisk.isEmpty)
          Container(
            padding: const EdgeInsets.all(AppSpacing.cardPadding),
            decoration: BoxDecoration(
              color: AppColors.statusGreenBg,
              borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
              border: Border.all(
                  color: AppColors.statusGreen.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.check_circle_outline,
                    color: AppColors.statusGreen),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(l.teacherAnalyticsAllStudentsAboveThreshold,
                      style: AppTextStyles.body
                          .copyWith(color: AppColors.statusGreen)),
                ),
              ],
            ),
          )
        else ...[
          ...atRisk.map((s) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _AtRiskCard(
                  name: s.name,
                  attendancePct: s.attendancePct,
                  letterGrade: s.letterGrade,
                  l: l,
                ),
              )),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton.icon(
              onPressed: () {},
              icon: Icon(Icons.send_outlined,
                  size: 16, color: AppColors.statusRed),
              label: Text(l.teacherAnalyticsSendAlertButton,
                  style: AppTextStyles.button
                      .copyWith(color: AppColors.statusRed)),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: AppColors.statusRed),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

// ── At-risk card ───────────────────────────────────────────────────────────────

class _AtRiskCard extends StatelessWidget {
  const _AtRiskCard({
    required this.name,
    required this.attendancePct,
    required this.letterGrade,
    required this.l,
  });
  final String name, letterGrade;
  final int attendancePct;
  final AppLocalizations l;

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
          CircleAvatar(
            radius: 22,
            backgroundColor: AppColors.statusRedBg,
            child: Text(name.isNotEmpty ? name[0].toUpperCase() : '?',
                style:
                    AppTextStyles.h3.copyWith(color: AppColors.statusRed)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: AppTextStyles.bodyMedium),
                Text(l.teacherAnalyticsAttendancePercentLabel(attendancePct),
                    style: AppTextStyles.caption
                        .copyWith(color: AppColors.statusRed)),
              ],
            ),
          ),
          Text(letterGrade,
              style: AppTextStyles.metric
                  .copyWith(color: AppColors.statusRed, fontSize: 22)),
          const SizedBox(width: 8),
          Icon(Icons.flag, color: AppColors.statusRed, size: 18),
        ],
      ),
    );
  }
}

// ── Helpers ────────────────────────────────────────────────────────────────────

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

class _LegendDot extends StatelessWidget {
  const _LegendDot(this.color, this.label);
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label, style: AppTextStyles.caption),
      ],
    );
  }
}
