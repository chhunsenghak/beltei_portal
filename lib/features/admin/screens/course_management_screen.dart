import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/providers/admin_providers.dart';
import '../../../core/services/admin_service.dart';

// ── Screen ────────────────────────────────────────────────────────────────────

class CourseManagementScreen extends ConsumerStatefulWidget {
  const CourseManagementScreen({super.key});

  @override
  ConsumerState<CourseManagementScreen> createState() =>
      _CourseManagementScreenState();
}

class _CourseManagementScreenState
    extends ConsumerState<CourseManagementScreen> {
  String _searchQuery = '';
  String _selectedDept = 'All Departments';
  String _selectedSemester = 'All Semesters';
  String _selectedTeacher = 'All Teachers';

  List<AdminCourse> _applyFilters(List<AdminCourse> all) {
    return all.where((c) {
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        if (!c.name.toLowerCase().contains(q) &&
            !c.code.toLowerCase().contains(q)) return false;
      }
      if (_selectedDept != 'All Departments' &&
          c.departmentName != _selectedDept) return false;
      if (_selectedSemester != 'All Semesters' &&
          c.semesterName != _selectedSemester) return false;
      if (_selectedTeacher != 'All Teachers' &&
          c.teacherName != _selectedTeacher) return false;
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final coursesAsync = ref.watch(adminCoursesProvider);

    return Scaffold(
      backgroundColor: AppColors.bgPage,
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: AppColors.primaryBlue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: coursesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline,
                  color: AppColors.statusRed, size: 40),
              const SizedBox(height: 8),
              Text('Could not load courses', style: AppTextStyles.bodyMedium),
              TextButton(
                onPressed: () => ref.invalidate(adminCoursesProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (all) {
          final depts = ['All Departments'] +
              all.map((c) => c.departmentName ?? '').where((s) => s.isNotEmpty).toSet().toList()..sort();
          final semesters = ['All Semesters'] +
              all.map((c) => c.semesterName ?? '').where((s) => s.isNotEmpty).toSet().toList()..sort();
          final teachers = ['All Teachers'] +
              all.map((c) => c.teacherName ?? '').where((s) => s.isNotEmpty).toSet().toList()..sort();

          if (!depts.contains(_selectedDept)) _selectedDept = 'All Departments';
          if (!semesters.contains(_selectedSemester)) _selectedSemester = 'All Semesters';
          if (!teachers.contains(_selectedTeacher)) _selectedTeacher = 'All Teachers';

          final filtered = _applyFilters(all);

          return Column(
            children: [
              _buildFilters(depts, semesters, teachers),
              Expanded(
                child: filtered.isEmpty
                    ? Center(
                        child: Text('No courses found',
                            style: AppTextStyles.caption))
                    : ListView.separated(
                        padding: const EdgeInsets.all(AppSpacing.screenPadding),
                        itemCount: filtered.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 12),
                        itemBuilder: (_, i) => _CourseCard(
                          course: filtered[i],
                          onTap: () => context.push(
                              '/admin/academic/courses/${filtered[i].courseId}'),
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFilters(
      List<String> depts, List<String> semesters, List<String> teachers) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
            decoration: InputDecoration(
              hintText: 'Search courses by name or code...',
              hintStyle: AppTextStyles.caption,
              prefixIcon:
                  const Icon(Icons.search, color: AppColors.textLabel, size: 20),
              filled: true,
              fillColor: AppColors.bgInput,
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
                borderSide: const BorderSide(color: AppColors.primaryNavy),
              ),
            ),
          ),
          const SizedBox(height: 12),
          _FilterDropdown(
            label: 'Department',
            value: _selectedDept,
            items: depts,
            onChanged: (v) => setState(() => _selectedDept = v!),
          ),
          const SizedBox(height: 8),
          _FilterDropdown(
            label: 'Semester',
            value: _selectedSemester,
            items: semesters,
            onChanged: (v) => setState(() => _selectedSemester = v!),
          ),
          const SizedBox(height: 8),
          _FilterDropdown(
            label: 'Teacher',
            value: _selectedTeacher,
            items: teachers,
            onChanged: (v) => setState(() => _selectedTeacher = v!),
          ),
        ],
      ),
    );
  }
}

// ── Filter dropdown ────────────────────────────────────────────────────────────

class _FilterDropdown extends StatelessWidget {
  const _FilterDropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final String label;
  final String value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: AppTextStyles.caption
                .copyWith(fontSize: 11, color: AppColors.textSecondary)),
        const SizedBox(height: 4),
        Container(
          decoration: BoxDecoration(
            color: AppColors.bgInput,
            borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
            border: Border.all(color: AppColors.border),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
              items: items
                  .map((e) => DropdownMenuItem(
                      value: e, child: Text(e, style: AppTextStyles.body)))
                  .toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}

// ── Course card ────────────────────────────────────────────────────────────────

class _CourseCard extends StatelessWidget {
  const _CourseCard({required this.course, required this.onTap});
  final AdminCourse course;
  final VoidCallback onTap;

  Color _codeColor(String code) {
    if (code.startsWith('CS') || code.startsWith('IT')) return AppColors.primaryBlue;
    if (code.startsWith('BA') || code.startsWith('BUS')) return const Color(0xFFD97706);
    if (code.startsWith('ENG')) return AppColors.statusGreen;
    if (code.startsWith('MT')) return const Color(0xFF7C3AED);
    if (code.startsWith('LAW')) return AppColors.statusRed;
    return AppColors.primaryNavy;
  }

  @override
  Widget build(BuildContext context) {
    final color = _codeColor(course.code);
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppSpacing.tagRadius),
                  ),
                  child: Text(course.code,
                      style: AppTextStyles.label
                          .copyWith(color: color, letterSpacing: 0.6)),
                ),
                if (course.semesterName != null)
                  Text(course.semesterName!,
                      style: AppTextStyles.caption.copyWith(fontSize: 10)),
              ],
            ),
            const SizedBox(height: 8),
            Text(course.name, style: AppTextStyles.bodyMedium),
            if (course.teacherName != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.person_outline,
                      size: 13, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Text(course.teacherName!, style: AppTextStyles.caption),
                ],
              ),
            ],
            const Divider(height: 20, color: AppColors.divider),
            Row(
              children: [
                const Icon(Icons.school_outlined,
                    size: 13, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Text('${course.credits} Credits', style: AppTextStyles.caption),
                const Spacer(),
                const Icon(Icons.people_outline,
                    size: 13, color: AppColors.statusAmber),
                const SizedBox(width: 4),
                Text('${course.enrolledCount} / ${course.maxStudents}',
                    style: AppTextStyles.caption.copyWith(
                        color: AppColors.statusAmber,
                        fontWeight: FontWeight.w600)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
