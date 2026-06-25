import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';

// ── Mock data ──────────────────────────────────────────────────────────────────

class _CourseData {
  const _CourseData({
    required this.id,
    required this.code,
    required this.name,
    required this.semester,
    required this.schedule,
    required this.students,
    required this.credits,
    required this.room,
  });
  final String id, code, name, semester, schedule, room;
  final int students, credits;
}

const _kCourses = [
  _CourseData(
    id: 'CS101',
    code: 'CS101',
    name: 'Introduction to Computer Science',
    semester: 'Fall 2024',
    schedule: 'Mon, Wed 08:30 – 10:00',
    students: 30,
    credits: 3,
    room: 'Room 402',
  ),
  _CourseData(
    id: 'CS301',
    code: 'CS301',
    name: 'Data Structures & Algorithms',
    semester: 'Fall 2024',
    schedule: 'Tue, Thu 10:10 – 11:40',
    students: 23,
    credits: 3,
    room: 'Lab 02',
  ),
  _CourseData(
    id: 'WD401',
    code: 'WD401',
    name: 'Advanced Web Development',
    semester: 'Fall 2024',
    schedule: 'Mon, Wed 13:00 – 14:30',
    students: 43,
    credits: 4,
    room: 'Room 208',
  ),
];

// ── Screen ────────────────────────────────────────────────────────────────────

class TeacherCourseListScreen extends StatelessWidget {
  const TeacherCourseListScreen({super.key});

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
            const SizedBox(height: AppSpacing.sectionGap),
            ..._kCourses.map((c) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _CourseCard(course: c),
                )),
            const SizedBox(height: 4),
            _buildUrgentTaskBanner(context),
            const SizedBox(height: 24),
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
        Text('My Courses', style: AppTextStyles.h1),
        Text('Manage your courses and student performance for Fall 2024.',
            style: AppTextStyles.caption.copyWith(height: 1.4)),
      ],
    );
  }

  // ── Urgent task banner ─────────────────────────────────────────────────────

  Widget _buildUrgentTaskBanner(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.statusAmberBg,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(color: AppColors.statusAmber.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded,
              color: AppColors.statusAmber, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('URGENT TASK',
                    style: AppTextStyles.label
                        .copyWith(color: AppColors.statusAmber)),
                const SizedBox(height: 2),
                Text('Final Exam Preparation',
                    style: AppTextStyles.bodyMedium),
                Text(
                    'Grade sheets for CS101 and DS204 are uploaded to the LMS by tomorrow.',
                    style: AppTextStyles.caption.copyWith(height: 1.4)),
                const SizedBox(height: 8),
                Text('Due: Oct 24, 2024',
                    style: AppTextStyles.caption.copyWith(
                        color: AppColors.statusAmber,
                        fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Course card ────────────────────────────────────────────────────────────────

class _CourseCard extends StatelessWidget {
  const _CourseCard({required this.course});
  final _CourseData course;

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
                  const SizedBox(width: 8),
                  _CodeChip(course.semester,
                      color: AppColors.statusAmber,
                      bg: AppColors.statusAmberBg),
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
        _MetaRow(Icons.calendar_today_outlined, course.schedule),
        const SizedBox(height: 4),
        _MetaRow(Icons.people_outline, '${course.students} Students Enrolled'),
        const SizedBox(height: 4),
        _MetaRow(Icons.meeting_room_outlined, course.room),
      ],
    );
  }

  Widget _buildCardActions(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () =>
                context.push('/teacher/courses/${course.id}/attendance'),
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
            onPressed: () =>
                context.push('/teacher/courses/${course.id}/grades'),
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
          style:
              AppTextStyles.label.copyWith(color: color, letterSpacing: 0.4)),
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
        Text(text,
            style:
                AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
      ],
    );
  }
}
