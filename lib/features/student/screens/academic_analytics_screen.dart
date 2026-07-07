import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/providers/student_providers.dart';
import '../../../core/services/student_service.dart';
import '../../../l10n/app_localizations.dart';

// ── Screen ────────────────────────────────────────────────────────────────────

class AcademicAnalyticsScreen extends ConsumerWidget {
  const AcademicAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final asyncGrades = ref.watch(studentGradesProvider);
    final asyncProfile = ref.watch(studentProfileProvider);
    final asyncCourses = ref.watch(studentCoursesProvider);

    return Scaffold(
      backgroundColor: AppColors.bgPage,
      body: asyncGrades.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline,
                  color: AppColors.statusRed, size: 40),
              const SizedBox(height: 8),
              Text(l.loadErrorGrades, style: AppTextStyles.body),
              TextButton(
                onPressed: () => ref.invalidate(studentGradesProvider),
                child: Text(l.retry),
              ),
            ],
          ),
        ),
        data: (semesters) {
          final profile = asyncProfile.valueOrNull;
          final courses = asyncCourses.valueOrNull ?? [];

          // Sort semesters chronologically
          final sorted = [...semesters]
            ..sort((a, b) => a.startDate.compareTo(b.startDate));

          // CGPA & total earned credits across all semesters
          double totalPoints = 0;
          int totalWeightedCredits = 0;
          int totalEarned = 0;
          for (final s in sorted) {
            for (final c in s.courses) {
              if (c.credits <= 0) continue;
              if (c.gpaPoints != null) {
                totalPoints += c.gpaPoints! * c.credits;
                totalWeightedCredits += c.credits;
              }
              if (c.letterGrade != null && c.letterGrade != 'F') {
                totalEarned += c.credits;
              }
            }
          }
          final cgpa = totalWeightedCredits > 0
              ? totalPoints / totalWeightedCredits
              : 0.0;

          // GPA delta vs previous semester
          final validSems =
              sorted.where((s) => s.semesterGpa > 0).toList();
          final currentGpa =
              validSems.isNotEmpty ? validSems.last.semesterGpa : 0.0;
          final prevGpa = validSems.length > 1
              ? validSems[validSems.length - 2].semesterGpa
              : currentGpa;
          final delta = currentGpa - prevGpa;

          // GPA trend spots (indexed 1-based)
          final trendSpots = validSems
              .asMap()
              .entries
              .map((e) =>
                  FlSpot(e.key.toDouble() + 1, e.value.semesterGpa))
              .toList();

          // Degree progress
          const totalRequired = 120;
          final progressPct =
              (totalEarned / totalRequired).clamp(0.0, 1.0);
          final degreeName =
              profile?.majorName ?? l.analyticsDefaultDegreeName;

          // Current semester courses for performance table
          final currentCourses =
              courses.where((c) => c.isCurrentSemester).toList();

          return SingleChildScrollView(
            padding:
                const EdgeInsets.all(AppSpacing.screenPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTitle(l),
                const SizedBox(height: AppSpacing.md),
                _buildCGPACard(cgpa, delta, trendSpots, l),
                const SizedBox(height: AppSpacing.sectionGap),
                _buildDegreeProgress(
                    progressPct, totalEarned, totalRequired, degreeName, l),
                if (trendSpots.length >= 2) ...[
                  const SizedBox(height: AppSpacing.sectionGap),
                  _buildGPATrend(trendSpots, validSems, l),
                ],
                if (sorted.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.sectionGap),
                  _buildSemesterComparison(sorted, l),
                ],
                const SizedBox(height: AppSpacing.sectionGap),
                _buildCoursePerformance(currentCourses, l),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  // ── Title ──────────────────────────────────────────────────────────────────

  Widget _buildTitle(AppLocalizations l) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l.analyticsTitle, style: AppTextStyles.h1),
        Text(l.analyticsSubtitle, style: AppTextStyles.caption),
      ],
    );
  }

  // ── CGPA card ──────────────────────────────────────────────────────────────

  Widget _buildCGPACard(double cgpa, double delta, List<FlSpot> trendSpots,
      AppLocalizations l) {
    final hasData = trendSpots.isNotEmpty;
    final positive = delta >= 0;
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l.analyticsCurrentCgpaLabel, style: AppTextStyles.label),
          const SizedBox(height: 6),
          Row(
            children: [
              Text(
                cgpa > 0 ? cgpa.toStringAsFixed(2) : l.profileNa,
                style: AppTextStyles.metric.copyWith(
                    color: AppColors.primaryNavy, fontSize: 36),
              ),
              if (cgpa > 0 && delta.abs() > 0.001) ...[
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: positive
                        ? AppColors.statusGreenBg
                        : AppColors.statusRedBg,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        positive
                            ? Icons.trending_up
                            : Icons.trending_down,
                        color: positive
                            ? AppColors.statusGreen
                            : AppColors.statusRed,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        l.analyticsGpaDeltaLabel(
                            '${positive ? '+' : ''}${delta.toStringAsFixed(2)}'),
                        style: AppTextStyles.caption.copyWith(
                          color: positive
                              ? AppColors.statusGreen
                              : AppColors.statusRed,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          if (hasData) ...[
            const SizedBox(height: 16),
            SizedBox(
              height: 80,
              child: LineChart(_buildMiniChart(trendSpots)),
            ),
          ],
        ],
      ),
    );
  }

  LineChartData _buildMiniChart(List<FlSpot> spots) {
    return LineChartData(
      gridData: const FlGridData(show: false),
      titlesData: const FlTitlesData(show: false),
      borderData: FlBorderData(show: false),
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          color: AppColors.primaryNavy,
          barWidth: 2.5,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            color: AppColors.primaryNavy.withValues(alpha: 0.08),
          ),
        ),
      ],
    );
  }

  // ── Degree progress ────────────────────────────────────────────────────────

  Widget _buildDegreeProgress(double pct, int earned, int required,
      String degreeName, AppLocalizations l) {
    final remaining = (required - earned).clamp(0, required);
    final statusLabel = pct >= 1.0
        ? l.statusCompleted
        : pct >= 0.5
            ? l.analyticsStatusOnTrack
            : l.analyticsStatusInProgress;
    final statusColor = pct >= 1.0
        ? AppColors.statusGreen
        : pct >= 0.5
            ? AppColors.statusGreen
            : AppColors.statusAmber;

    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(l.analyticsDegreeProgressTitle, style: AppTextStyles.h2),
              Text(
                l.analyticsPercentComplete((pct * 100).round()),
                style: AppTextStyles.h3
                    .copyWith(color: AppColors.primaryNavy),
              ),
            ],
          ),
          Text(degreeName, style: AppTextStyles.caption),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: pct,
              minHeight: 10,
              backgroundColor: AppColors.border,
              valueColor: AlwaysStoppedAnimation<Color>(
                  AppColors.statusAmber),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildProgressStat(l.analyticsEarnedLabel,
                  l.analyticsEarnedValue(earned, required),
                  AppColors.primaryBlue),
              const SizedBox(width: 24),
              _buildProgressStat(l.analyticsRequiredLabel,
                  l.analyticsRemainingCreditsValue(remaining),
                  AppColors.textPrimary),
              const SizedBox(width: 24),
              _buildProgressStat(l.analyticsStatusLabel, statusLabel, statusColor),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressStat(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.label),
        Text(value,
            style: AppTextStyles.bodySemiBold.copyWith(color: color)),
      ],
    );
  }

  // ── GPA Trend chart ────────────────────────────────────────────────────────

  Widget _buildGPATrend(
      List<FlSpot> spots, List<SemesterGrades> semesters, AppLocalizations l) {
    final cgpaSpots =
        spots.map((s) => FlSpot(s.x, (s.y - 0.1).clamp(0.0, 4.0))).toList();
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(l.analyticsGpaTrendTitle, style: AppTextStyles.h2),
              const Spacer(),
              _buildLegendDot(AppColors.primaryNavy, l.analyticsLegendTermGpa),
              const SizedBox(width: 12),
              _buildLegendDot(AppColors.primaryBlue, l.analyticsLegendCgpa),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 160,
            child: LineChart(_buildTrendChart(spots, cgpaSpots, semesters)),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendDot(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
                color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(label, style: AppTextStyles.caption),
      ],
    );
  }

  LineChartData _buildTrendChart(List<FlSpot> termSpots,
      List<FlSpot> cgpaSpots, List<SemesterGrades> semesters) {
    final labels = semesters.map((s) => s.semesterName).toList();
    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        getDrawingHorizontalLine: (_) =>
            FlLine(color: AppColors.border, strokeWidth: 1),
      ),
      titlesData: FlTitlesData(
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 36,
            getTitlesWidget: (v, _) => Text(v.toStringAsFixed(1),
                style: AppTextStyles.caption.copyWith(fontSize: 10)),
          ),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (v, _) {
              final i = v.toInt() - 1;
              if (i < 0 || i >= labels.length) {
                return const SizedBox.shrink();
              }
              return Text(labels[i].length > 4
                  ? labels[i].substring(0, 4)
                  : labels[i],
                  style:
                      AppTextStyles.caption.copyWith(fontSize: 10));
            },
          ),
        ),
        topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false)),
      ),
      borderData: FlBorderData(show: false),
      lineBarsData: [
        LineChartBarData(
          spots: termSpots,
          isCurved: true,
          color: AppColors.primaryNavy,
          barWidth: 2.5,
          dotData: const FlDotData(show: false),
        ),
        LineChartBarData(
          spots: cgpaSpots,
          isCurved: true,
          color: AppColors.primaryBlue,
          barWidth: 2,
          dotData: const FlDotData(show: false),
          dashArray: [4, 4],
        ),
      ],
    );
  }

  // ── Semester comparison bar chart ──────────────────────────────────────────

  Widget _buildSemesterComparison(
      List<SemesterGrades> semesters, AppLocalizations l) {
    final labels = semesters.map((s) {
      final name = s.semesterName;
      final year = s.academicYear.length >= 4
          ? s.academicYear.substring(2, 4)
          : s.academicYear;
      return '${name.length > 4 ? name.substring(0, 4) : name}\n$year';
    }).toList();
    final gpas = semesters.map((s) => s.semesterGpa).toList();

    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l.analyticsSemesterComparisonTitle, style: AppTextStyles.h2),
          Text(l.analyticsSemesterComparisonSubtitle,
              style: AppTextStyles.caption),
          const SizedBox(height: 20),
          SizedBox(
            height: 140,
            child: BarChart(_buildBarChart(gpas, labels)),
          ),
        ],
      ),
    );
  }

  BarChartData _buildBarChart(List<double> gpas, List<String> labels) {
    return BarChartData(
      alignment: BarChartAlignment.spaceAround,
      maxY: 4.0,
      barTouchData: BarTouchData(enabled: false),
      titlesData: FlTitlesData(
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (v, _) {
              final i = v.toInt();
              if (i < 0 || i >= labels.length) {
                return const SizedBox.shrink();
              }
              return Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(labels[i],
                    textAlign: TextAlign.center,
                    style: AppTextStyles.caption.copyWith(fontSize: 9)),
              );
            },
          ),
        ),
        leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false)),
        topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false)),
      ),
      gridData: const FlGridData(show: false),
      borderData: FlBorderData(show: false),
      barGroups: List.generate(
          gpas.length,
          (i) => BarChartGroupData(
                x: i,
                barRods: [
                  BarChartRodData(
                    toY: gpas[i],
                    color: i == gpas.length - 1
                        ? AppColors.primaryNavy
                        : AppColors.primaryNavy.withValues(alpha: 0.3),
                    width: 28,
                    borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(4)),
                  ),
                ],
              )),
    );
  }

  // ── Course performance table ───────────────────────────────────────────────

  Widget _buildCoursePerformance(
      List<EnrolledCourse> courses, AppLocalizations l) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l.analyticsCurrentCoursesTitle, style: AppTextStyles.h2),
          const SizedBox(height: 4),
          if (courses.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text(l.analyticsNoCoursesMessage,
                  style: AppTextStyles.body
                      .copyWith(color: AppColors.textSecondary)),
            )
          else ...[
            Row(
              children: [l.analyticsCourseNameHeader, l.analyticsCourseCodeHeader]
                  .map((h) => Expanded(
                      child: Text(h, style: AppTextStyles.label)))
                  .toList(),
            ),
            Divider(color: AppColors.border, height: 20),
            ...courses.map((c) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppColors.statusGrayBg,
                          borderRadius:
                              BorderRadius.circular(8),
                        ),
                        child: Icon(
                            Icons.menu_book_outlined,
                            size: 18,
                            color: AppColors.primaryNavy),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                          child: Text(c.name,
                              style: AppTextStyles.bodyMedium)),
                      Text(c.code,
                          style: AppTextStyles.caption.copyWith(
                              color: AppColors.primaryBlue,
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                )),
          ],
        ],
      ),
    );
  }
}

// ── Shared card ────────────────────────────────────────────────────────────────

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
