import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/providers/student_providers.dart';
import '../../../core/services/student_service.dart';
import '../../../l10n/app_localizations.dart';

class SemesterGradeDetailScreen extends ConsumerWidget {
  const SemesterGradeDetailScreen(
      {super.key, required this.semesterId});
  final String semesterId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final asyncGrades = ref.watch(studentGradesProvider);

    return Scaffold(
      backgroundColor: AppColors.bgPage,
      appBar: AppBar(
        backgroundColor: AppColors.primaryNavy,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios,
              size: 18, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: asyncGrades.when(
          data: (semesters) {
            final sem = semesters
                .where((s) => s.semesterId == semesterId)
                .firstOrNull;
            return Text(
              sem != null
                  ? '${sem.semesterName} ${sem.academicYear}'
                  : l.semesterGradeDefaultTitle,
              style: AppTextStyles.h3White,
            );
          },
          loading: () =>
              Text(l.semesterGradeDefaultTitle, style: AppTextStyles.h3White),
          error: (_, _) =>
              Text(l.semesterGradeDefaultTitle, style: AppTextStyles.h3White),
        ),
      ),
      body: asyncGrades.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline,
                  color: AppColors.statusRed, size: 40),
              const SizedBox(height: 8),
              Text(l.loadErrorGrades, style: AppTextStyles.bodyMedium),
              TextButton(
                onPressed: () => ref.invalidate(studentGradesProvider),
                child: Text(l.retry),
              ),
            ],
          ),
        ),
        data: (semesters) {
          final semester = semesters
              .where((s) => s.semesterId == semesterId)
              .firstOrNull;
          if (semester == null) {
            return Center(child: Text(l.semesterGradeNotFound));
          }
          return _SemesterBody(
              semester: semester, allSemesters: semesters, l: l);
        },
      ),
    );
  }
}

// ── Body ──────────────────────────────────────────────────────────────────────

class _SemesterBody extends StatelessWidget {
  const _SemesterBody(
      {required this.semester, required this.allSemesters, required this.l});
  final SemesterGrades semester;
  final List<SemesterGrades> allSemesters;
  final AppLocalizations l;

  int get _totalCreditsEarned {
    int total = 0;
    for (final s in allSemesters) {
      for (final c in s.courses) {
        final grade = c.letterGrade;
        if (grade != null && grade != 'F' && c.credits > 0) {
          total += c.credits;
        }
      }
    }
    return total;
  }

  int get _semesterCreditsEnrolled =>
      semester.courses.fold(0, (sum, c) => sum + c.credits);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildGpaBanner(),
          const SizedBox(height: AppSpacing.sectionGap),
          Text(l.semesterGradeEnrolledCoursesTitle, style: AppTextStyles.h2),
          const SizedBox(height: 12),
          if (semester.courses.isEmpty)
            _buildEmpty()
          else
            ...semester.courses.map((c) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _CourseGradeCard(course: c, l: l),
                )),
          const SizedBox(height: AppSpacing.sectionGap),
          _buildGradeKey(),
          const SizedBox(height: AppSpacing.sectionGap),
          _buildDegreeProgress(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildGpaBanner() {
    final gpa = semester.semesterGpa;
    final creditsEarned = semester.courses
        .where((c) =>
            c.letterGrade != null &&
            c.letterGrade != 'F' &&
            c.credits > 0)
        .fold(0, (sum, c) => sum + c.credits);
    final qualifies = gpa >= 3.5;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primaryNavy,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l.semesterGradeGpaLabel,
                    style: AppTextStyles.label
                        .copyWith(color: Colors.white70)),
                const SizedBox(height: 6),
                Text(
                  gpa > 0 ? gpa.toStringAsFixed(2) : l.profileNa,
                  style: AppTextStyles.metric
                      .copyWith(color: Colors.white, fontSize: 36),
                ),
                if (qualifies) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.trending_up,
                          color: AppColors.accentGold, size: 16),
                      const SizedBox(width: 4),
                      Text(l.semesterGradeDeansListQualification,
                          style: AppTextStyles.caption
                              .copyWith(color: AppColors.accentGold)),
                    ],
                  ),
                ],
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                Text(l.semesterGradeCreditsEarnedLabel,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.caption
                        .copyWith(color: Colors.white70)),
                const SizedBox(height: 4),
                Text(
                  l.semesterGradeCreditsRatio(
                      creditsEarned, _semesterCreditsEnrolled),
                  style: AppTextStyles.h2White,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24),
      alignment: Alignment.center,
      child: Text(l.semesterGradeNoGradesRecorded,
          style: AppTextStyles.body
              .copyWith(color: AppColors.textSecondary)),
    );
  }

  Widget _buildGradeKey() {
    final keys = [
      (grade: 'A', range: l.semesterGradeRangeA, color: AppColors.primaryNavy),
      (grade: 'B', range: l.semesterGradeRangeB, color: AppColors.primaryBlue),
      (grade: 'C', range: l.semesterGradeRangeC, color: AppColors.statusAmber),
      (grade: 'F', range: l.semesterGradeRangeF, color: AppColors.statusRed),
    ];

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
          Text(l.semesterGradeKeyTitle, style: AppTextStyles.h3),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 3.5,
            children: keys
                .map((k) => Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                              color: k.color,
                              borderRadius: BorderRadius.circular(6)),
                          child: Center(
                            child: Text(k.grade,
                                style: AppTextStyles.bodySemiBold
                                    .copyWith(color: Colors.white)),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(k.range, style: AppTextStyles.caption),
                      ],
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildDegreeProgress() {
    const totalRequired = 120;
    final earned = _totalCreditsEarned;
    final pct = (earned / totalRequired).clamp(0.0, 1.0);

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
              Text(l.semesterGradeDegreeCompletionTitle, style: AppTextStyles.h3),
              Text(
                l.semesterGradePercentComplete((pct * 100).round()),
                style: AppTextStyles.bodySemiBold
                    .copyWith(color: AppColors.primaryNavy),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: pct,
              minHeight: 8,
              backgroundColor: AppColors.border,
              valueColor: AlwaysStoppedAnimation<Color>(
                  AppColors.primaryNavy),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l.semesterGradeCreditsCompletedSummary(earned, totalRequired),
            style: AppTextStyles.caption.copyWith(height: 1.5),
          ),
        ],
      ),
    );
  }
}

// ── Course grade card ─────────────────────────────────────────────────────────

class _CourseGradeCard extends StatelessWidget {
  const _CourseGradeCard({required this.course, required this.l});
  final CourseGrade course;
  final AppLocalizations l;

  Color get _gradeColor {
    final g = course.letterGrade?.toUpperCase() ?? '';
    if (g.startsWith('A')) return AppColors.primaryNavy;
    if (g.startsWith('B')) return AppColors.primaryBlue;
    if (g.startsWith('C')) return AppColors.statusAmber;
    if (g.startsWith('D')) return AppColors.statusAmber;
    if (g == 'F') return AppColors.statusRed;
    return AppColors.border;
  }

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCode(),
          const SizedBox(width: 12),
          Expanded(child: _buildInfo()),
          _buildGradeBadge(),
        ],
      ),
    );
  }

  Widget _buildCode() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.statusBlueBg,
        borderRadius: BorderRadius.circular(AppSpacing.tagRadius),
      ),
      child: Text(
        course.courseCode,
        style: AppTextStyles.label
            .copyWith(color: AppColors.primaryBlue, fontSize: 10),
      ),
    );
  }

  Widget _buildInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(course.courseName,
            style: AppTextStyles.bodySemiBold
                .copyWith(color: AppColors.primaryNavy)),
        const SizedBox(height: 2),
        Text(l.semesterGradeCreditsCount(course.credits),
            style: AppTextStyles.caption),
        const SizedBox(height: 6),
        Text(l.semesterGradeGradePointsLabel, style: AppTextStyles.label),
        Text(
          course.gpaPoints != null
              ? course.gpaPoints!.toStringAsFixed(1)
              : '—',
          style: AppTextStyles.h3,
        ),
      ],
    );
  }

  Widget _buildGradeBadge() {
    return Column(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: _gradeColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              course.letterGrade ?? '—',
              style: AppTextStyles.h2White,
            ),
          ),
        ),
      ],
    );
  }
}
