import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';

// ── Mock data ──────────────────────────────────────────────────────────────────

final _kCourses = [
  (code: 'CS-101', title: 'Introduction to Computer Science',
   professor: 'Prof. Alan Turing', credits: 4, grade: 'A', points: 4.0, gradeColor: AppColors.primaryNavy),
  (code: 'MATH-202', title: 'Discrete Mathematics',
   professor: 'Dr. Katherine Johnson', credits: 3, grade: 'B', points: 3.0, gradeColor: AppColors.primaryBlue),
  (code: 'ENG-105', title: 'Technical Writing',
   professor: 'Prof. Maya Angelou', credits: 3, grade: 'C', points: 2.0, gradeColor: AppColors.statusAmber),
  (code: 'PHY-101', title: 'Quantum Mechanics I',
   professor: 'Dr. Richard Feynman', credits: 4, grade: 'F', points: 0.0, gradeColor: AppColors.statusRed),
];

// ── Screen ────────────────────────────────────────────────────────────────────

class SemesterGradeDetailScreen extends StatelessWidget {
  const SemesterGradeDetailScreen({super.key, required this.semesterId});
  final String semesterId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildGpaBanner(),
            const SizedBox(height: AppSpacing.sectionGap),
            Text('Enrolled Courses', style: AppTextStyles.h2),
            const SizedBox(height: 12),
            ..._kCourses.map((c) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _CourseGradeCard(course: c),
                )),
            const SizedBox(height: AppSpacing.sectionGap),
            _buildGradeKey(),
            const SizedBox(height: AppSpacing.sectionGap),
            _buildDegreeProgress(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // ── App bar ────────────────────────────────────────────────────────────────

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.primaryNavy,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, size: 18, color: Colors.white),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Text('Year 1 – Semester 1',
          style: AppTextStyles.h3White),
      actions: [
        IconButton(
          icon: const Icon(Icons.search, color: Colors.white),
          onPressed: () {},
        ),
      ],
    );
  }

  // ── GPA banner ─────────────────────────────────────────────────────────────

  Widget _buildGpaBanner() {
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
                Text('OVERALL SEMESTER GPA',
                    style: AppTextStyles.label.copyWith(color: Colors.white70)),
                const SizedBox(height: 6),
                Text('3.82',
                    style: AppTextStyles.metric.copyWith(color: Colors.white, fontSize: 36)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.trending_up, color: AppColors.accentGold, size: 16),
                    const SizedBox(width: 4),
                    Text('Dean\'s List Qualification',
                        style: AppTextStyles.caption.copyWith(color: AppColors.accentGold)),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                Text('Credits\nEarned',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.caption.copyWith(color: Colors.white70)),
                const SizedBox(height: 4),
                Text('18 / 18',
                    style: AppTextStyles.h2White),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Grade key ──────────────────────────────────────────────────────────────

  Widget _buildGradeKey() {
    final keys = [
      (grade: 'A', range: '4.0 (90-100)', color: AppColors.primaryNavy),
      (grade: 'B', range: '3.0 (80-89)', color: AppColors.primaryBlue),
      (grade: 'C', range: '2.0 (70-79)', color: AppColors.statusAmber),
      (grade: 'F', range: '0.0 (0-59)', color: AppColors.statusRed),
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
          Text('Grade Key', style: AppTextStyles.h3),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 3.5,
            children: keys.map((k) => Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                          color: k.color, borderRadius: BorderRadius.circular(6)),
                      child: Center(
                          child: Text(k.grade,
                              style: AppTextStyles.bodySemiBold
                                  .copyWith(color: Colors.white))),
                    ),
                    const SizedBox(width: 8),
                    Text(k.range, style: AppTextStyles.caption),
                  ],
                )).toList(),
          ),
        ],
      ),
    );
  }

  // ── Degree completion ──────────────────────────────────────────────────────

  Widget _buildDegreeProgress() {
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
              Text('Degree Completion', style: AppTextStyles.h3),
              Text('25%',
                  style: AppTextStyles.bodySemiBold.copyWith(
                      color: AppColors.primaryNavy)),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: const LinearProgressIndicator(
              value: 0.25,
              minHeight: 8,
              backgroundColor: AppColors.border,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryNavy),
            ),
          ),
          const SizedBox(height: 8),
          Text('32 of 128 credits completed total across all semesters.',
              style: AppTextStyles.caption.copyWith(height: 1.5)),
        ],
      ),
    );
  }
}

// ── Course grade card ─────────────────────────────────────────────────────────

class _CourseGradeCard extends StatelessWidget {
  const _CourseGradeCard({required this.course});
  final dynamic course;

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
        course.code as String,
        style: AppTextStyles.label.copyWith(color: AppColors.primaryBlue, fontSize: 10),
      ),
    );
  }

  Widget _buildInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(course.title as String,
            style: AppTextStyles.bodySemiBold.copyWith(color: AppColors.primaryNavy)),
        const SizedBox(height: 2),
        Text('${course.professor} • ${course.credits} Credits',
            style: AppTextStyles.caption),
        const SizedBox(height: 6),
        Text('GRADE POINTS', style: AppTextStyles.label),
        Text('${course.points}', style: AppTextStyles.h3),
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
            color: course.gradeColor as Color,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              course.grade as String,
              style: AppTextStyles.h2White,
            ),
          ),
        ),
        const SizedBox(height: 6),
        const Icon(Icons.expand_more, color: AppColors.textLabel, size: 20),
      ],
    );
  }
}
