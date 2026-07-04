import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/providers/teacher_providers.dart';
import '../../../core/services/teacher_service.dart';
import '../../../l10n/app_localizations.dart';

// ── Screen ────────────────────────────────────────────────────────────────────

class TeacherCourseListScreen extends ConsumerStatefulWidget {
  const TeacherCourseListScreen({super.key});

  @override
  ConsumerState<TeacherCourseListScreen> createState() =>
      _TeacherCourseListScreenState();
}

class _TeacherCourseListScreenState
    extends ConsumerState<TeacherCourseListScreen> {
  int _filterIndex = 0;
  String _search = '';
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<TeacherCourse> _applyFilter(List<TeacherCourse> courses) {
    var result = courses;
    switch (_filterIndex) {
      case 1:
        result = result.where((c) => c.isCurrentSemester).toList();
      case 2:
        result = result.where((c) => !c.isCurrentSemester).toList();
      default:
        break;
    }
    if (_search.isNotEmpty) {
      final q = _search.toLowerCase();
      result = result
          .where((c) =>
              c.name.toLowerCase().contains(q) ||
              c.code.toLowerCase().contains(q))
          .toList();
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final coursesAsync = ref.watch(teacherCoursesProvider);
    final filters = [
      l.courseListFilterAll,
      l.courseListFilterCurrent,
      l.teacherCourseListFilterPast,
    ];

    return Scaffold(
      backgroundColor: AppColors.bgPage,
      body: Column(
        children: [
          _buildTitle(coursesAsync.valueOrNull ?? const [], l),
          _buildSearchBar(l),
          _buildFilterChips(filters),
          Expanded(
            child: coursesAsync.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.error_outline,
                        color: AppColors.statusRed, size: 40),
                    const SizedBox(height: 8),
                    Text(l.courseListLoadError,
                        style: AppTextStyles.bodyMedium),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () =>
                          ref.invalidate(teacherCoursesProvider),
                      child: Text(l.retry),
                    ),
                  ],
                ),
              ),
              data: (courses) {
                final filtered = _applyFilter(courses);
                return RefreshIndicator(
                  onRefresh: () => ref.refresh(teacherCoursesProvider.future),
                  child: filtered.isEmpty
                      ? ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: [
                            SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 0.5,
                              child: _buildEmpty(l),
                            ),
                          ],
                        )
                      : ListView.separated(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(
                              AppSpacing.screenPadding,
                              0,
                              AppSpacing.screenPadding,
                              24),
                          itemCount: filtered.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: 12),
                          itemBuilder: (_, i) =>
                              _CourseCard(course: filtered[i], l: l),
                        ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitle(List<TeacherCourse> courses, AppLocalizations l) {
    final currentSemCourses =
        courses.where((c) => c.isCurrentSemester).toList();
    final semLabel = currentSemCourses.isNotEmpty
        ? '${currentSemCourses.first.semesterName ?? ''} ${currentSemCourses.first.semesterAcademicYear ?? ''}'
        : '';
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenPadding, AppSpacing.sm, AppSpacing.screenPadding, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l.teacherCourseListTitle, style: AppTextStyles.h1),
          Text(
            semLabel.trim().isNotEmpty
                ? l.teacherCourseListSubtitleWithSemester(semLabel)
                : l.teacherCourseListSubtitle,
            style: AppTextStyles.caption.copyWith(height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(AppLocalizations l) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.md, AppSpacing.sm, AppSpacing.md, 0),
      child: TextField(
        controller: _searchController,
        onChanged: (v) => setState(() => _search = v),
        decoration: InputDecoration(
          hintText: l.teacherCourseListSearchHint,
          prefixIcon:
              Icon(Icons.search, color: AppColors.textLabel, size: 20),
          fillColor: AppColors.bgCard,
          filled: true,
        ),
      ),
    );
  }

  Widget _buildFilterChips(List<String> filters) {
    return SizedBox(
      height: 52,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        itemCount: filters.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (_, i) => _buildFilterChip(i, filters[i]),
      ),
    );
  }

  Widget _buildFilterChip(int index, String label) {
    final isActive = _filterIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _filterIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primaryNavy : AppColors.bgCard,
          borderRadius: BorderRadius.circular(AppSpacing.chipRadius),
          border: Border.all(
            color: isActive ? AppColors.primaryNavy : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.bodySemiBold.copyWith(
            color: isActive ? Colors.white : AppColors.textSecondary,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildEmpty(AppLocalizations l) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.menu_book_outlined,
              color: AppColors.textLabel, size: 48),
          const SizedBox(height: 12),
          Text(l.teacherCourseListEmptyState,
              style: AppTextStyles.body
                  .copyWith(color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

// ── Course card ────────────────────────────────────────────────────────────────

class _CourseCard extends StatelessWidget {
  const _CourseCard({required this.course, required this.l});
  final TeacherCourse course;
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCardHeader(),
          const SizedBox(height: 10),
          _buildCardMeta(),
          const SizedBox(height: 14),
          Divider(color: AppColors.border, height: 1),
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
          child: Icon(Icons.menu_book_outlined,
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
            l.teacherCourseListStudentsEnrolled(course.studentCount)),
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
            label: Text(l.dashboardActionAttendance),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primaryNavy,
              side: BorderSide(color: AppColors.primaryNavy),
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
            label: Text(l.dashboardActionGrades),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primaryBlue,
              side: BorderSide(color: AppColors.primaryBlue),
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
  _CodeChip(this.label, {Color? color, Color? bg})
      : color = color ?? AppColors.primaryNavy,
        bg = bg ?? AppColors.statusBlueBg;
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
