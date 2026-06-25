import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';

// ── Mock data ──────────────────────────────────────────────────────────────────

const _kGPA = '3.52';
const _kCGPA = '3.68';
const _kDegree = 'Bachelor of Computer Science';
const _kCreditsEarned = 84;
const _kCreditsTotal = 120;
const _kDegreeProgress = 0.70;

final _kSemesters = [
  (id: 'y2s1', label: 'Y2', title: 'Year 2, Semester 1', period: 'Aug 2023 - Dec 2023', color: AppColors.primaryNavy),
  (id: 'y1s2', label: 'Y1', title: 'Year 1, Semester 2', period: 'Feb 2023 - Jun 2023', color: AppColors.primaryBlue),
  (id: 'y1s1', label: 'Y1', title: 'Year 1, Semester 1', period: 'Aug 2022 - Dec 2022', color: AppColors.primaryBlue),
];

// ── Screen ────────────────────────────────────────────────────────────────────

class GradesDashboardScreen extends StatelessWidget {
  const GradesDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: AppSpacing.md),
            _buildGradeOverviewCard(),
            const SizedBox(height: AppSpacing.sectionGap),
            _buildDegreeProgressCard(),
            const SizedBox(height: AppSpacing.sectionGap),
            _buildSemesterHistory(context),
            const SizedBox(height: AppSpacing.sectionGap),
            _buildPerformanceTrend(),
            const SizedBox(height: AppSpacing.sectionGap),
            _buildHonorsBanner(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // ── Header ─────────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Academic Performance', style: AppTextStyles.h1),
        const SizedBox(height: 4),
        Text('Student ID: B2-10942 • Year 2', style: AppTextStyles.caption),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: AppColors.statusAmberBg,
            borderRadius: BorderRadius.circular(AppSpacing.chipRadius),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.shield_outlined, color: AppColors.statusAmber, size: 14),
              const SizedBox(width: 4),
              Text('GOOD STANDING',
                  style: AppTextStyles.label.copyWith(color: AppColors.statusAmber)),
            ],
          ),
        ),
      ],
    );
  }

  // ── GPA circles ────────────────────────────────────────────────────────────

  Widget _buildGradeOverviewCard() {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Grade Overview', style: AppTextStyles.h2),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildGpaCircle(value: _kGPA, label: 'GPA', subtitle: 'Current Term',
                  color: AppColors.primaryNavy),
              _buildGpaCircle(value: _kCGPA, label: 'CGPA', subtitle: 'Cumulative',
                  color: AppColors.primaryBlue),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGpaCircle({
    required String value,
    required String label,
    required String subtitle,
    required Color color,
  }) {
    return Column(
      children: [
        CircularPercentIndicator(
          radius: 60,
          lineWidth: 8,
          percent: double.parse(value) / 4.0,
          center: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(value, style: AppTextStyles.metric.copyWith(color: color, fontSize: 22)),
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

  // ── Degree progress ────────────────────────────────────────────────────────

  Widget _buildDegreeProgressCard() {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Degree Progress', style: AppTextStyles.h2),
          const SizedBox(height: 4),
          Text(_kDegree, style: AppTextStyles.caption),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total Credits', style: AppTextStyles.bodyMedium),
              Text('$_kCreditsEarned / $_kCreditsTotal',
                  style: AppTextStyles.bodySemiBold.copyWith(color: AppColors.primaryBlue)),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: _kDegreeProgress,
              minHeight: 8,
              backgroundColor: AppColors.border,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryNavy),
            ),
          ),
          const SizedBox(height: 6),
          Text('${(_kDegreeProgress * 100).round()}% completed',
              style: AppTextStyles.caption),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.border),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.buttonRadius)),
              ),
              child: Text('View Requirements',
                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
            ),
          ),
        ],
      ),
    );
  }

  // ── Semester history ───────────────────────────────────────────────────────

  Widget _buildSemesterHistory(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Semester History', style: AppTextStyles.h2),
        const SizedBox(height: 12),
        ..._kSemesters.map((s) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _SemesterRow(
                id: s.id,
                label: s.label,
                title: s.title,
                period: s.period,
                color: s.color,
                onTap: () => context.go('/student/grades/${s.id}'),
              ),
            )),
      ],
    );
  }

  // ── Performance trend ──────────────────────────────────────────────────────

  Widget _buildPerformanceTrend() {
    return _Card(
      child: Row(
        children: [
          const Icon(Icons.trending_up, color: AppColors.primaryNavy, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Performance Trend', style: AppTextStyles.h3),
                const SizedBox(height: 4),
                Text(
                  'Your academic score has increased by 0.12% compared to last semester.',
                  style: AppTextStyles.body.copyWith(color: AppColors.textSecondary, height: 1.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Honors banner ──────────────────────────────────────────────────────────

  Widget _buildHonorsBanner() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primaryNavy,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Honors Eligibility", style: AppTextStyles.h2White),
          const SizedBox(height: 8),
          Text(
            "Maintain a CGPA above 3.50 to qualify for the Dean's List for the upcoming graduation.",
            style: AppTextStyles.bodyWhite.copyWith(height: 1.5),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () {},
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Check Criteria',
                    style: AppTextStyles.link.copyWith(color: AppColors.accentGold)),
                const SizedBox(width: 4),
                const Icon(Icons.arrow_forward, color: AppColors.accentGold, size: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Semester row ───────────────────────────────────────────────────────────────

class _SemesterRow extends StatelessWidget {
  const _SemesterRow({
    required this.id,
    required this.label,
    required this.title,
    required this.period,
    required this.color,
    required this.onTap,
  });

  final String id, label, title, period;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
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
                    style: AppTextStyles.bodySemiBold.copyWith(color: color)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.bodyMedium),
                  Text(period, style: AppTextStyles.caption),
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
