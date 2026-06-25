import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../shared/widgets/status_badge.dart';

// ── Mock data ──────────────────────────────────────────────────────────────────

enum _CourseStatus { active, completed, enrolled }

class _CourseData {
  const _CourseData({
    required this.id,
    required this.code,
    required this.title,
    required this.professor,
    required this.credits,
    required this.semester,
    required this.status,
    required this.completion,
  });
  final String id;
  final String code;
  final String title;
  final String professor;
  final String credits;
  final String semester;
  final _CourseStatus status;
  final double completion;
}

const _kCourses = [
  _CourseData(
    id: '1',
    code: 'CS101',
    title: 'Introduction to Programming',
    professor: 'Dr. James Wilson',
    credits: '4.0 Units',
    semester: 'Fall 2024',
    status: _CourseStatus.active,
    completion: 0.75,
  ),
  _CourseData(
    id: '2',
    code: 'MATH204',
    title: 'Advanced Calculus II',
    professor: 'Sarah Jenkins',
    credits: '3.0 Units',
    semester: 'Fall 2024',
    status: _CourseStatus.active,
    completion: 0.42,
  ),
  _CourseData(
    id: '3',
    code: 'ENG102',
    title: 'Academic Writing & Research',
    professor: 'Robert Chen',
    credits: '2.0 Units',
    semester: 'Summer 2024',
    status: _CourseStatus.completed,
    completion: 1.0,
  ),
  _CourseData(
    id: '4',
    code: 'HIS105',
    title: 'World Civilization',
    professor: 'Dr. Anita S.',
    credits: '3.0 Units',
    semester: 'Next Semester',
    status: _CourseStatus.enrolled,
    completion: 0.0,
  ),
];

const _kFilters = ['All', 'Semester 1', 'Semester 2', 'Active', 'Completed'];

// ── Screen ────────────────────────────────────────────────────────────────────

class CourseListScreen extends StatefulWidget {
  const CourseListScreen({super.key});

  @override
  State<CourseListScreen> createState() => _CourseListScreenState();
}

class _CourseListScreenState extends State<CourseListScreen> {
  int _filterIndex = 0;
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<_CourseData> get _filtered {
    if (_filterIndex == 0) return _kCourses;
    if (_filterIndex == 3) {
      return _kCourses.where((c) => c.status == _CourseStatus.active).toList();
    }
    if (_filterIndex == 4) {
      return _kCourses.where((c) => c.status == _CourseStatus.completed).toList();
    }
    return _kCourses;
  }

  // ── build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      body: Column(
        children: [
          _buildSearchBar(),
          _buildFilterChips(),
          Expanded(child: _buildCourseList()),
        ],
      ),
    );
  }

  // ── sections ───────────────────────────────────────────────────────────────

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.md, AppSpacing.sm, AppSpacing.md, 0),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search courses, professors, or codes...',
          prefixIcon:
              const Icon(Icons.search, color: AppColors.textLabel, size: 20),
          fillColor: AppColors.bgCard,
          filled: true,
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return SizedBox(
      height: 52,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        itemCount: _kFilters.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (_, i) => _buildFilterChip(i),
      ),
    );
  }

  Widget _buildFilterChip(int index) {
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
          _kFilters[index],
          style: AppTextStyles.bodySemiBold.copyWith(
            color: isActive ? Colors.white : AppColors.textSecondary,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildCourseList() {
    final courses = _filtered;
    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: courses.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (_, i) => _CourseCard(
        course: courses[i],
        onTap: () => context.go('/student/courses/${courses[i].id}'),
      ),
    );
  }
}

// ── Course card ────────────────────────────────────────────────────────────────

class _CourseCard extends StatelessWidget {
  const _CourseCard({required this.course, required this.onTap});

  final _CourseData course;
  final VoidCallback onTap;

  BadgeType get _badgeType => switch (course.status) {
        _CourseStatus.active => BadgeType.active,
        _CourseStatus.completed => BadgeType.completed,
        _CourseStatus.enrolled => BadgeType.enrolled,
      };

  String get _badgeLabel => switch (course.status) {
        _CourseStatus.active => 'Active',
        _CourseStatus.completed => 'Completed',
        _CourseStatus.enrolled => 'Enrolled',
      };

  Color get _progressColor => switch (course.status) {
        _CourseStatus.active => AppColors.primaryNavy,
        _CourseStatus.completed => AppColors.statusGreen,
        _CourseStatus.enrolled => AppColors.statusGray,
      };

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
            _buildTitle(),
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
        const Icon(Icons.chevron_right, color: AppColors.textLabel, size: 20),
      ],
    );
  }

  Widget _buildTitle() {
    return Text(course.title, style: AppTextStyles.h3);
  }

  Widget _buildInfoGrid() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoPair('PROFESSOR', course.professor),
              const SizedBox(height: 8),
              _buildInfoPair('SEMESTER', course.semester),
            ],
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoPair('CREDITS', course.credits),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text('STATUS', style: AppTextStyles.label),
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

  Widget _buildInfoPair(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.label),
        const SizedBox(height: 2),
        Text(value, style: AppTextStyles.bodySemiBold),
      ],
    );
  }

  Widget _buildProgressRow() {
    final pct = (course.completion * 100).round();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Course Completion', style: AppTextStyles.bodyMedium),
            Text(
              '$pct%',
              style: AppTextStyles.bodySemiBold.copyWith(color: _progressColor),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: course.completion,
            minHeight: 6,
            backgroundColor: AppColors.border,
            valueColor: AlwaysStoppedAnimation<Color>(_progressColor),
          ),
        ),
      ],
    );
  }
}

// ── Code chip widget ───────────────────────────────────────────────────────────

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
        style: AppTextStyles.label.copyWith(
            color: AppColors.primaryBlue, letterSpacing: 0.5),
      ),
    );
  }
}
