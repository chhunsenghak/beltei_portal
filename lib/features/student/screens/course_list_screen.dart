import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/providers/student_providers.dart';
import '../../../core/services/student_service.dart';
import '../../../core/supabase/database.types.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/status_badge.dart';

// ── Screen ────────────────────────────────────────────────────────────────────

class CourseListScreen extends ConsumerStatefulWidget {
  const CourseListScreen({super.key});

  @override
  ConsumerState<CourseListScreen> createState() => _CourseListScreenState();
}

class _CourseListScreenState extends ConsumerState<CourseListScreen> {
  int _filterIndex = 0;
  String _search = '';
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<EnrolledCourse> _applyFilter(List<EnrolledCourse> courses) {
    var result = courses;
    switch (_filterIndex) {
      case 1:
        result = result
            .where((c) => c.enrollmentStatus == EnrollmentStatus.enrolled)
            .toList();
      case 2:
        result = result
            .where((c) => c.enrollmentStatus == EnrollmentStatus.completed)
            .toList();
      default:
        break;
    }
    if (_search.isNotEmpty) {
      final q = _search.toLowerCase();
      result = result
          .where((c) =>
              c.name.toLowerCase().contains(q) ||
              c.code.toLowerCase().contains(q) ||
              (c.teacherName?.toLowerCase().contains(q) ?? false))
          .toList();
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final coursesAsync = ref.watch(studentCoursesProvider);
    final filters = [
      l.courseListFilterAll,
      l.statusActive,
      l.statusCompleted,
    ];

    return Scaffold(
      backgroundColor: AppColors.bgPage,
      body: Column(
        children: [
          _buildSearchBar(l),
          _buildFilterChips(filters),
          Expanded(
            child: coursesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
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
                          ref.invalidate(studentCoursesProvider),
                      child: Text(l.retry),
                    ),
                  ],
                ),
              ),
              data: (courses) {
                final filtered = _applyFilter(courses);
                return RefreshIndicator(
                  onRefresh: () => ref.refresh(studentCoursesProvider.future),
                  child: filtered.isEmpty
                      ? ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: [
                            SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 0.6,
                              child: Center(
                                child: Text(l.courseListEmptyState,
                                    style: AppTextStyles.caption),
                              ),
                            ),
                          ],
                        )
                      : _buildCourseList(courses: filtered, l: l),
                );
              },
            ),
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
          hintText: l.courseListSearchHint,
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

  Widget _buildCourseList({
    required List<EnrolledCourse> courses,
    required AppLocalizations l,
  }) {
    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: courses.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (_, i) => _CourseCard(
        course: courses[i],
        l: l,
        onTap: () => context.go('/student/courses/${courses[i].courseId}'),
      ),
    );
  }
}

// ── Course card ────────────────────────────────────────────────────────────────

class _CourseCard extends StatelessWidget {
  const _CourseCard({required this.course, required this.onTap, required this.l});

  final EnrolledCourse course;
  final VoidCallback onTap;
  final AppLocalizations l;

  BadgeType get _badgeType => switch (course.enrollmentStatus) {
        EnrollmentStatus.enrolled => course.isCurrentSemester
            ? BadgeType.active
            : BadgeType.enrolled,
        EnrollmentStatus.completed => BadgeType.completed,
        EnrollmentStatus.dropped => BadgeType.neutral,
      };

  String get _badgeLabel => switch (course.enrollmentStatus) {
        EnrollmentStatus.enrolled =>
          course.isCurrentSemester ? l.statusActive : l.statusEnrolled,
        EnrollmentStatus.completed => l.statusCompleted,
        EnrollmentStatus.dropped => l.statusDropped,
      };

  Color get _progressColor => switch (course.enrollmentStatus) {
        EnrollmentStatus.completed => AppColors.statusGreen,
        EnrollmentStatus.dropped => AppColors.statusGray,
        _ => AppColors.primaryNavy,
      };

  double get _completion {
    if (course.enrollmentStatus == EnrollmentStatus.completed) return 1.0;
    if (course.enrollmentStatus == EnrollmentStatus.dropped) return 0.0;
    return course.attendanceRate ?? 0.0;
  }

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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 8),
            Text(course.name, style: AppTextStyles.h3),
            const SizedBox(height: 12),
            _buildInfoGrid(),
            const SizedBox(height: 12),
            _buildProgressRow(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        _CodeChip(code: course.code),
        const Spacer(),
        Icon(Icons.chevron_right, color: AppColors.textLabel, size: 20),
      ],
    );
  }

  Widget _buildInfoGrid() {
    final semLabel = [
      course.semesterName,
      course.semesterAcademicYear,
    ].whereType<String>().join(' • ');

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _infoPair(l.courseListProfessorLabel, course.teacherName ?? l.profileNa),
              const SizedBox(height: 8),
              _infoPair(l.courseListSemesterLabel, semLabel.isEmpty ? l.profileNa : semLabel),
            ],
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _infoPair(l.courseListCreditsLabel,
                  l.courseListCreditsUnitsValue(course.credits)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(l.courseListStatusLabel, style: AppTextStyles.label),
                  const SizedBox(width: 6),
                  StatusBadge(label: _badgeLabel, type: _badgeType),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _infoPair(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.label),
        const SizedBox(height: 2),
        Text(value,
            style: AppTextStyles.bodySemiBold,
            maxLines: 1,
            overflow: TextOverflow.ellipsis),
      ],
    );
  }

  Widget _buildProgressRow() {
    final pct = (_completion * 100).round();
    final label = course.enrollmentStatus == EnrollmentStatus.completed
        ? l.courseListCourseCompletionLabel
        : l.courseListAttendanceRateLabel;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: AppTextStyles.bodyMedium),
            Text('$pct%',
                style: AppTextStyles.bodySemiBold
                    .copyWith(color: _progressColor)),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: _completion,
            minHeight: 6,
            backgroundColor: AppColors.border,
            valueColor: AlwaysStoppedAnimation<Color>(_progressColor),
          ),
        ),
      ],
    );
  }
}

// ── Code chip ──────────────────────────────────────────────────────────────────

class _CodeChip extends StatelessWidget {
  const _CodeChip({required this.code});
  final String code;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.statusBlueBg,
        borderRadius: BorderRadius.circular(AppSpacing.tagRadius),
      ),
      child: Text(
        code,
        style: AppTextStyles.label
            .copyWith(color: AppColors.primaryBlue, letterSpacing: 0.5),
      ),
    );
  }
}
