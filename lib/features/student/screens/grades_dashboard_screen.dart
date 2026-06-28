import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/providers/student_providers.dart';
import '../../../core/services/student_service.dart';

// ── Helpers ───────────────────────────────────────────────────────────────────

double _computeCgpa(List<SemesterGrades> semesters) {
  double totalPoints = 0;
  int totalCredits = 0;
  for (final sem in semesters) {
    for (final c in sem.courses) {
      if (c.gpaPoints != null) {
        totalPoints += c.gpaPoints! * c.credits;
        totalCredits += c.credits;
      }
    }
  }
  return totalCredits > 0 ? totalPoints / totalCredits : 0;
}

int _totalCreditsEarned(List<SemesterGrades> semesters) =>
    semesters.fold(0, (sum, s) => sum + s.totalCredits);

// ── Screen ────────────────────────────────────────────────────────────────────

class GradesDashboardScreen extends ConsumerWidget {
  const GradesDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gradesAsync = ref.watch(studentGradesProvider);
    final profileAsync = ref.watch(studentProfileProvider);

    return Scaffold(
      backgroundColor: AppColors.bgPage,
      body: gradesAsync.when(
        loading: () =>
            const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline,
                  color: AppColors.statusRed, size: 40),
              const SizedBox(height: 8),
              Text('Could not load grades',
                  style: AppTextStyles.bodyMedium),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => ref.invalidate(studentGradesProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (semesters) {
          final current = semesters
                  .where((s) => s.isCurrent)
                  .firstOrNull ??
              (semesters.isNotEmpty ? semesters.first : null);
          final gpa = current?.semesterGpa ?? 0;
          final cgpa = _computeCgpa(semesters);
          final creditsEarned = _totalCreditsEarned(semesters);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.screenPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(profileAsync.valueOrNull, current, creditsEarned),
                const SizedBox(height: AppSpacing.md),
                _buildGradeOverviewCard(gpa, cgpa),
                const SizedBox(height: AppSpacing.sectionGap),
                _buildDegreeProgressCard(creditsEarned, semesters),
                const SizedBox(height: AppSpacing.sectionGap),
                _buildSemesterHistory(context, semesters),
                const SizedBox(height: AppSpacing.sectionGap),
                _buildHonorsBanner(cgpa),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  // ── Header ─────────────────────────────────────────────────────────────────

  Widget _buildHeader(
    StudentProfile? profile,
    SemesterGrades? current,
    int creditsEarned,
  ) {
    final studentCode = profile?.studentCode ?? '—';
    final yearLevel = profile != null ? 'Year ${profile.yearLevel}' : '';
    final standing = creditsEarned >= 0 ? 'GOOD STANDING' : 'AT RISK';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Academic Performance', style: AppTextStyles.h1),
        const SizedBox(height: 4),
        Text('Student ID: $studentCode${yearLevel.isNotEmpty ? ' • $yearLevel' : ''}',
            style: AppTextStyles.caption),
        const SizedBox(height: 8),
        Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: AppColors.statusAmberBg,
            borderRadius:
                BorderRadius.circular(AppSpacing.chipRadius),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.shield_outlined,
                  color: AppColors.statusAmber, size: 14),
              const SizedBox(width: 4),
              Text(standing,
                  style: AppTextStyles.label
                      .copyWith(color: AppColors.statusAmber)),
            ],
          ),
        ),
      ],
    );
  }

  // ── GPA circles ────────────────────────────────────────────────────────────

  Widget _buildGradeOverviewCard(double gpa, double cgpa) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Grade Overview', style: AppTextStyles.h2),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _GpaCircle(
                value: gpa,
                label: 'GPA',
                subtitle: 'Current Term',
                color: AppColors.primaryNavy,
              ),
              _GpaCircle(
                value: cgpa,
                label: 'CGPA',
                subtitle: 'Cumulative',
                color: AppColors.primaryBlue,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Degree progress ────────────────────────────────────────────────────────

  Widget _buildDegreeProgressCard(
      int creditsEarned, List<SemesterGrades> semesters) {
    const creditsTotal = 120;
    final progress = (creditsEarned / creditsTotal).clamp(0.0, 1.0);

    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Degree Progress', style: AppTextStyles.h2),
          const SizedBox(height: 4),
          Text('Bachelor\'s Degree Program',
              style: AppTextStyles.caption),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total Credits', style: AppTextStyles.bodyMedium),
              Text('$creditsEarned / $creditsTotal',
                  style: AppTextStyles.bodySemiBold
                      .copyWith(color: AppColors.primaryBlue)),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: AppColors.border,
              valueColor: const AlwaysStoppedAnimation<Color>(
                  AppColors.primaryNavy),
            ),
          ),
          const SizedBox(height: 6),
          Text('${(progress * 100).round()}% completed',
              style: AppTextStyles.caption),
        ],
      ),
    );
  }

  // ── Semester history ───────────────────────────────────────────────────────

  Widget _buildSemesterHistory(
      BuildContext context, List<SemesterGrades> semesters) {
    if (semesters.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Semester History', style: AppTextStyles.h2),
        const SizedBox(height: 12),
        ...semesters.map((s) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _SemesterRow(
                semester: s,
                onTap: () =>
                    context.go('/student/grades/${s.semesterId}'),
              ),
            )),
      ],
    );
  }

  // ── Honors banner ──────────────────────────────────────────────────────────

  Widget _buildHonorsBanner(double cgpa) {
    final onTrack = cgpa >= 3.5;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primaryNavy,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Honors Eligibility', style: AppTextStyles.h2White),
          const SizedBox(height: 8),
          Text(
            onTrack
                ? 'You are on track for the Dean\'s List! Maintain a CGPA above 3.50 for the upcoming graduation.'
                : 'Maintain a CGPA above 3.50 to qualify for the Dean\'s List for the upcoming graduation.',
            style: AppTextStyles.bodyWhite.copyWith(height: 1.5),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                onTrack
                    ? Icons.check_circle_outline
                    : Icons.info_outline,
                color: AppColors.accentGold,
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                onTrack
                    ? 'Current CGPA: ${cgpa.toStringAsFixed(2)} ✓'
                    : 'Current CGPA: ${cgpa.toStringAsFixed(2)}',
                style:
                    AppTextStyles.link.copyWith(color: AppColors.accentGold),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── GPA circle ─────────────────────────────────────────────────────────────────

class _GpaCircle extends StatelessWidget {
  const _GpaCircle({
    required this.value,
    required this.label,
    required this.subtitle,
    required this.color,
  });

  final double value;
  final String label;
  final String subtitle;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final display = value.toStringAsFixed(2);
    final percent = (value / 4.0).clamp(0.0, 1.0);
    return Column(
      children: [
        CircularPercentIndicator(
          radius: 60,
          lineWidth: 8,
          percent: percent,
          center: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(display,
                  style: AppTextStyles.metric
                      .copyWith(color: color, fontSize: 22)),
              Text(label, style: AppTextStyles.caption),
            ],
          ),
          progressColor: color,
          backgroundColor: AppColors.border,
          circularStrokeCap: CircularStrokeCap.round,
        ),
        const SizedBox(height: 8),
        Text(subtitle, style: AppTextStyles.caption),
      ],
    );
  }
}

// ── Semester row ───────────────────────────────────────────────────────────────

class _SemesterRow extends StatelessWidget {
  const _SemesterRow({required this.semester, required this.onTap});

  final SemesterGrades semester;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = semester.isCurrent
        ? AppColors.primaryNavy
        : AppColors.primaryBlue;
    final label = semester.isCurrent ? 'NOW' : 'Y${semester.startDate.substring(2, 4)}';
    final gpaText = semester.semesterGpa > 0
        ? 'GPA ${semester.semesterGpa.toStringAsFixed(2)}'
        : 'No grades yet';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.cardPadding),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(label,
                    style: AppTextStyles.bodySemiBold
                        .copyWith(color: color, fontSize: 11)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(semester.semesterName,
                      style: AppTextStyles.bodyMedium),
                  Text(
                      '${semester.academicYear} • $gpaText',
                      style: AppTextStyles.caption),
                ],
              ),
            ),
            const Icon(Icons.expand_more, color: AppColors.textLabel),
          ],
        ),
      ),
    );
  }
}

// ── Card wrapper ───────────────────────────────────────────────────────────────

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
