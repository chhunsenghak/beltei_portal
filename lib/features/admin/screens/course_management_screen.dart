import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';

// ── Mock data ──────────────────────────────────────────────────────────────────

final _kCourses = [
  (id: 'CS101', code: 'CS101', title: 'Introduction to Programming',   teacher: 'Dr. Sam Sokha',   credits: 4, enrolled: 45),
  (id: 'BA305', code: 'BA305', title: 'Marketing Strategy',            teacher: 'Prof. Linda Smith',credits: 3, enrolled: 32),
  (id: 'ENG202',code: 'ENG202',title: 'Advanced Business English',     teacher: 'Mr. Chan Dara',   credits: 2, enrolled: 28),
  (id: 'CS402', code: 'CS402', title: 'Cybersecurity Principles',      teacher: 'Dr. Sam Sokha',   credits: 4, enrolled: 18),
  (id: 'IT205', code: 'IT205', title: 'Database Management',           teacher: 'Mr. Chan Dara',   credits: 3, enrolled: 40),
  (id: 'MT101', code: 'MT101', title: 'College Mathematics',           teacher: 'Prof. Linda Smith',credits: 4, enrolled: 50),
  (id: 'CS301', code: 'CS301', title: 'Advanced Database Systems',     teacher: 'Dr. Samnang Chea', credits: 3, enrolled: 124),
  (id: 'LAW101',code: 'LAW101',title: 'Introduction to Law',           teacher: 'Mr. Ratha Tep',   credits: 3, enrolled: 30),
];

const _kDepartments = ['All Departments', 'Computer Science', 'Business Admin', 'Engineering', 'Languages', 'Mathematics', 'Law'];
const _kSemesters   = ['Fall 2024', 'Spring 2024', 'Fall 2023', 'Spring 2023'];
const _kTeachers    = ['All Teachers', 'Dr. Sam Sokha', 'Prof. Linda Smith', 'Mr. Chan Dara', 'Dr. Samnang Chea', 'Mr. Ratha Tep'];

// ── Screen ────────────────────────────────────────────────────────────────────

class CourseManagementScreen extends StatefulWidget {
  const CourseManagementScreen({super.key});

  @override
  State<CourseManagementScreen> createState() => _CourseManagementScreenState();
}

class _CourseManagementScreenState extends State<CourseManagementScreen> {
  String _searchQuery = '';
  String _selectedDept     = 'All Departments';
  String _selectedSemester = 'Fall 2024';
  String _selectedTeacher  = 'All Teachers';

  List<dynamic> get _filtered {
    if (_searchQuery.isEmpty) return _kCourses;
    return _kCourses.where((c) =>
        c.title.toLowerCase().contains(_searchQuery) ||
        c.code.toLowerCase().contains(_searchQuery)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: AppColors.primaryBlue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Column(
        children: [
          _buildSearchAndFilters(),
          Expanded(child: _buildCourseList(context)),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters() {
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
              prefixIcon: const Icon(Icons.search, color: AppColors.textLabel, size: 20),
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
            items: _kDepartments,
            onChanged: (v) => setState(() => _selectedDept = v!),
          ),
          const SizedBox(height: 8),
          _FilterDropdown(
            label: 'Semester',
            value: _selectedSemester,
            items: _kSemesters,
            onChanged: (v) => setState(() => _selectedSemester = v!),
          ),
          const SizedBox(height: 8),
          _FilterDropdown(
            label: 'Teacher',
            value: _selectedTeacher,
            items: _kTeachers,
            onChanged: (v) => setState(() => _selectedTeacher = v!),
          ),
        ],
      ),
    );
  }

  Widget _buildCourseList(BuildContext context) {
    final courses = _filtered;
    if (courses.isEmpty) {
      return Center(child: Text('No courses found', style: AppTextStyles.caption));
    }
    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      itemCount: courses.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (_, i) => _CourseCard(
        course: courses[i],
        onTap: () => context.push('/admin/academic/courses/${courses[i].id}'),
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
            style: AppTextStyles.caption.copyWith(
                fontSize: 11, color: AppColors.textSecondary)),
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
  final dynamic course;
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
    final code = course.code as String;
    final color = _codeColor(code);
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
                  child: Text(code,
                      style: AppTextStyles.label.copyWith(
                          color: color, letterSpacing: 0.6)),
                ),
                GestureDetector(
                  onTap: () {},
                  child: const Icon(Icons.more_vert,
                      size: 18, color: AppColors.textLabel),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(course.title as String, style: AppTextStyles.bodyMedium),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.person_outline,
                    size: 13, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Text(course.teacher as String, style: AppTextStyles.caption),
              ],
            ),
            const Divider(height: 20, color: AppColors.divider),
            Row(
              children: [
                const Icon(Icons.school_outlined,
                    size: 13, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Text('${course.credits} Credits',
                    style: AppTextStyles.caption),
                const Spacer(),
                const Icon(Icons.people_outline,
                    size: 13, color: AppColors.statusAmber),
                const SizedBox(width: 4),
                Text('${course.enrolled} Enrolled',
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
