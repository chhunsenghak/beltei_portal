import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/providers/admin_providers.dart';
import '../../../core/services/admin_service.dart';
import '../../../shared/widgets/app_toast.dart';

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
  String _selectedFaculty = 'All Faculties';

  List<AdminCourse> _applyFilters(List<AdminCourse> all) {
    return all.where((c) {
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        if (!c.name.toLowerCase().contains(q) &&
            !c.code.toLowerCase().contains(q)) {
          return false;
        }
      }
      if (_selectedFaculty != 'All Faculties' &&
          c.facultyName != _selectedFaculty) {
        return false;
      }
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final coursesAsync = ref.watch(adminCoursesProvider);
    // Pre-load faculties/majors for the create sheet's Faculty → Major cascade
    ref.watch(adminFacultiesProvider);
    ref.watch(adminMajorsProvider);

    return Scaffold(
      backgroundColor: AppColors.bgPage,
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateCourseSheet(context),
        backgroundColor: AppColors.primaryBlue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: coursesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline,
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
          final allFacultiesAsync = ref.watch(adminFacultiesProvider);
          final facultyNamesFromProvider = allFacultiesAsync.valueOrNull?.map((f) => f.name).toSet() ?? {};
          final facultyNamesFromCourses = all.map((c) => c.facultyName ?? '').where((s) => s.isNotEmpty).toSet();
          final mergedFaculties = {...facultyNamesFromProvider, ...facultyNamesFromCourses}.toList()..sort();
          final faculties = ['All Faculties', ...mergedFaculties];

          if (!faculties.contains(_selectedFaculty)) _selectedFaculty = 'All Faculties';

          final filtered = _applyFilters(all);

          return Column(
            children: [
              _buildFilters(faculties),
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

  Widget _buildFilters(List<String> faculties) {
    return Container(
      color: AppColors.bgPage,
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
                  Icon(Icons.search, color: AppColors.textLabel, size: 20),
              filled: true,
              fillColor: AppColors.bgInput,
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
                borderSide: BorderSide(color: AppColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
                borderSide: BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
                borderSide: BorderSide(color: AppColors.primaryNavy),
              ),
            ),
          ),
          const SizedBox(height: 12),
          _FilterDropdown(
            label: 'Faculty',
            value: _selectedFaculty,
            items: faculties,
            onChanged: (v) => setState(() => _selectedFaculty = v!),
          ),
        ],
      ),
    );
  }

  // ── Create course sheet ───────────────────────────────────────────────────

  Future<void> _showCreateCourseSheet(BuildContext context) async {
    final faculties = ref.read(adminFacultiesProvider).valueOrNull ?? [];
    final allMajors = ref.read(adminMajorsProvider).valueOrNull ?? [];

    final codeCtrl    = TextEditingController();
    final nameCtrl    = TextEditingController();
    final descCtrl    = TextEditingController();
    final creditsCtrl = TextEditingController(text: '3');

    String? selectedFacultyId;
    String? selectedMajorId;
    bool saving = false;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.bgCard,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) {
          final filteredMajors = selectedFacultyId == null
              ? allMajors
              : allMajors.where((m) => m.facultyId == selectedFacultyId).toList();
          return Padding(
          padding: EdgeInsets.fromLTRB(
              16, 20, 16, MediaQuery.of(ctx).viewInsets.bottom + 24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('New Course',
                    style: AppTextStyles.h3.copyWith(color: AppColors.primaryNavy)),
                const SizedBox(height: 4),
                Text('Assign teachers and shifts by adding classes after creation.',
                    style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
                const SizedBox(height: 16),
                _SheetField(label: 'Course Code *', controller: codeCtrl,
                    hint: 'e.g. CS101'),
                const SizedBox(height: 12),
                _SheetField(label: 'Course Name *', controller: nameCtrl,
                    hint: 'e.g. Introduction to Programming'),
                const SizedBox(height: 12),
                _SheetField(label: 'Description', controller: descCtrl,
                    hint: 'Optional', maxLines: 3),
                const SizedBox(height: 12),
                _SheetField(
                    label: 'Credits *', controller: creditsCtrl,
                    hint: '3', keyboardType: TextInputType.number),
                const SizedBox(height: 12),
                _SheetDropdown<String?>(
                  label: 'Faculty',
                  value: selectedFacultyId,
                  hint: 'Select faculty',
                  items: faculties
                      .map((f) => DropdownMenuItem<String?>(
                            value: f.id,
                            child: Text(f.name, overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.body),
                          ))
                      .toList(),
                  onChanged: (v) => setSheet(() {
                    selectedFacultyId = v;
                    selectedMajorId = null;
                  }),
                ),
                const SizedBox(height: 12),
                _SheetDropdown<String?>(
                  label: 'Major',
                  value: selectedMajorId,
                  hint: 'Select major',
                  items: filteredMajors
                      .map((m) => DropdownMenuItem<String?>(
                            value: m.id,
                            child: Text(m.name, overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.body),
                          ))
                      .toList(),
                  onChanged: (v) => setSheet(() => selectedMajorId = v),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryNavy,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: saving
                        ? null
                        : () async {
                            final code    = codeCtrl.text.trim();
                            final name    = nameCtrl.text.trim();
                            final credits = int.tryParse(creditsCtrl.text.trim()) ?? 3;
                            if (code.isEmpty || name.isEmpty) {
                              ScaffoldMessenger.of(ctx).showSnackBar(
                                const SnackBar(
                                    content: Text('Course code and name are required')),
                              );
                              return;
                            }
                            setSheet(() => saving = true);
                            try {
                              await ref.read(adminServiceProvider).createCourse(
                                    code: code,
                                    name: name,
                                    description: descCtrl.text,
                                    credits: credits,
                                    majorId: selectedMajorId,
                                  );
                              ref.invalidate(adminCoursesProvider);
                              if (ctx.mounted) Navigator.pop(ctx);
                              if (context.mounted) showSuccessToast(context, 'Course created.');
                            } catch (e) {
                              setSheet(() => saving = false);
                              if (ctx.mounted) {
                                final msg = e.toString().contains('unique')
                                    ? 'A course with that code already exists.'
                                    : 'Error: $e';
                                ScaffoldMessenger.of(ctx).showSnackBar(
                                  SnackBar(
                                      content: Text(msg),
                                      backgroundColor: AppColors.statusRed),
                                );
                              }
                            }
                          },
                    child: saving
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : const Text('Create Course'),
                  ),
                ),
              ],
            ),
          ),
        );
        },
      ),
    );

    codeCtrl.dispose();
    nameCtrl.dispose();
    descCtrl.dispose();
    creditsCtrl.dispose();
  }
}

// ── Sheet helpers ─────────────────────────────────────────────────────────────

class _SheetField extends StatelessWidget {
  const _SheetField({
    required this.label,
    required this.controller,
    this.hint,
    this.maxLines = 1,
    this.keyboardType,
  });
  final String label;
  final TextEditingController controller;
  final String? hint;
  final int maxLines;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: AppTextStyles.caption
                .copyWith(fontSize: 11, color: AppColors.textSecondary)),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          style: AppTextStyles.body,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle:
                AppTextStyles.caption.copyWith(color: AppColors.textLabel),
            filled: true,
            fillColor: AppColors.bgInput,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
              borderSide: BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
              borderSide: BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
              borderSide: BorderSide(color: AppColors.primaryNavy),
            ),
          ),
        ),
      ],
    );
  }
}

class _SheetDropdown<T> extends StatelessWidget {
  const _SheetDropdown({
    required this.label,
    required this.value,
    required this.hint,
    required this.items,
    required this.onChanged,
  });
  final String label;
  final T value;
  final String hint;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;

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
            child: DropdownButton<T>(
              value: value,
              isExpanded: true,
              hint: Text(hint,
                  style: AppTextStyles.caption
                      .copyWith(color: AppColors.textLabel)),
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
              items: items,
              onChanged: onChanged,
            ),
          ),
        ),
      ],
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
                if (course.majorName != null)
                  Text(course.majorName!,
                      style: AppTextStyles.caption.copyWith(fontSize: 10)),
              ],
            ),
            const SizedBox(height: 8),
            Text(course.name, style: AppTextStyles.bodyMedium),
            Divider(height: 20, color: AppColors.divider),
            Row(
              children: [
                Icon(Icons.school_outlined,
                    size: 13, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Text('${course.credits} Credits', style: AppTextStyles.caption),
                const Spacer(),
                Icon(Icons.people_outline,
                    size: 13, color: AppColors.statusAmber),
                const SizedBox(width: 4),
                Text('${course.enrolledCount} enrolled',
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
