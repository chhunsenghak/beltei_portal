import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/providers/teacher_providers.dart';
import '../../../core/services/teacher_service.dart';

// ── Screen ────────────────────────────────────────────────────────────────────

class TeacherCourseListScreen extends ConsumerWidget {
  const TeacherCourseListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coursesAsync = ref.watch(teacherCoursesProvider);

    return Scaffold(
      backgroundColor: AppColors.bgPage,
      body: coursesAsync.when(
        loading: () =>
            const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline,
                  color: AppColors.statusRed, size: 40),
              const SizedBox(height: 8),
              Text('Could not load courses',
                  style: AppTextStyles.bodyMedium),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () =>
                    ref.invalidate(teacherCoursesProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (courses) => SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTitle(courses),
              const SizedBox(height: AppSpacing.sectionGap),
              if (courses.isEmpty)
                _buildEmpty()
              else
                ...courses.map((c) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _CourseCard(course: c),
                    )),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTitle(List<TeacherCourse> courses) {
    final currentSemCourses =
        courses.where((c) => c.isCurrentSemester).toList();
    final semLabel = currentSemCourses.isNotEmpty
        ? '${currentSemCourses.first.semesterName ?? ''} ${currentSemCourses.first.semesterAcademicYear ?? ''}'
        : '';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('My Courses', style: AppTextStyles.h1),
        Text(
          'Manage your assigned courses${semLabel.trim().isNotEmpty ? ' for $semLabel' : ''}.',
          style: AppTextStyles.caption.copyWith(height: 1.4),
        ),
      ],
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 60),
        child: Column(
          children: [
            const Icon(Icons.menu_book_outlined,
                color: AppColors.textLabel, size: 48),
            const SizedBox(height: 12),
            Text('No courses assigned yet.',
                style: AppTextStyles.body
                    .copyWith(color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}

// ── Course card ────────────────────────────────────────────────────────────────

class _CourseCard extends StatelessWidget {
  const _CourseCard({required this.course});
  final TeacherCourse course;

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
          _buildCardHeader(),
          const SizedBox(height: 10),
          _buildCardMeta(),
          const SizedBox(height: 14),
          const Divider(color: AppColors.border, height: 1),
          const SizedBox(height: 12),
          _buildCardActions(context),
        ],
      ),
    );
  }

  Widget _buildCardHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.primaryNavy.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.menu_book_outlined,
              color: AppColors.primaryNavy, size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(course.name,
                  style: AppTextStyles.bodyMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis),
              const SizedBox(height: 4),
              Row(
                children: [
                  _CodeChip(course.code),
                  if (course.semesterName != null) ...[
                    const SizedBox(width: 8),
                    _CodeChip(
                      course.semesterName!,
                      color: AppColors.statusAmber,
                      bg: AppColors.statusAmberBg,
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCardMeta() {
    return Column(
      children: [
        _MetaRow(Icons.calendar_today_outlined, course.scheduleDisplay),
        const SizedBox(height: 4),
        _MetaRow(Icons.people_outline,
            '${course.studentCount} Students Enrolled'),
        if (course.room != null) ...[
          const SizedBox(height: 4),
          _MetaRow(Icons.meeting_room_outlined, course.room!),
        ],
      ],
    );
  }

  Widget _buildCardActions(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => context
                .push('/teacher/courses/${course.courseId}/attendance'),
            icon: const Icon(Icons.how_to_reg_outlined, size: 16),
            label: const Text('Attendance'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primaryNavy,
              side: const BorderSide(color: AppColors.primaryNavy),
              padding: const EdgeInsets.symmetric(vertical: 10),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => context
                .push('/teacher/courses/${course.courseId}/grades'),
            icon: const Icon(Icons.grade_outlined, size: 16),
            label: const Text('Grades'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primaryBlue,
              side: const BorderSide(color: AppColors.primaryBlue),
              padding: const EdgeInsets.symmetric(vertical: 10),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Small helpers ──────────────────────────────────────────────────────────────

class _CodeChip extends StatelessWidget {
  const _CodeChip(this.label,
      {this.color = AppColors.primaryNavy,
      this.bg = AppColors.statusBlueBg});
  final String label;
  final Color color;
  final Color bg;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppSpacing.chipRadius),
      ),
      child: Text(label,
          style: AppTextStyles.label
              .copyWith(color: color, letterSpacing: 0.4)),
    );
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow(this.icon, this.text);
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppColors.textSecondary),
        const SizedBox(width: 6),
        Expanded(
          child: Text(text,
              style: AppTextStyles.caption
                  .copyWith(color: AppColors.textSecondary),
              overflow: TextOverflow.ellipsis),
        ),
      ],
    );
  }
}
