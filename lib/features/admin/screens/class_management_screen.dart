import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/providers/admin_providers.dart';
import '../../../core/services/admin_service.dart';
import '../../../shared/widgets/app_toast.dart';
import '../../../shared/widgets/class_schedule_sheet.dart';
import '../../../shared/widgets/enroll_student_sheet.dart';

// ─────────────────────────────────────────────────────────────────────────────
// A class is a stable cohort (e.g. "Batch 2025-A") that persists across
// years. Its per-semester offering is a class term (room/shift/year level),
// and each term has a curriculum of courses (course + teacher + schedule).
// This screen manages all three levels: Class -> Term -> Courses.
// ─────────────────────────────────────────────────────────────────────────────

class ClassManagementScreen extends ConsumerStatefulWidget {
  const ClassManagementScreen({super.key});

  @override
  ConsumerState<ClassManagementScreen> createState() =>
      _ClassManagementScreenState();
}

class _ClassManagementScreenState
    extends ConsumerState<ClassManagementScreen> {
  String? _semesterFilter; // semesterId
  String? _majorFilter;    // majorId
  String? _facultyFilter;  // facultyId
  String? _classFilter;    // classId
  String? _academicYearFilter; // academicYearId
  int? _yearLevelFilter; // yearLevel (1, 2, 3, 4)
  String _search = '';

  List<AdminClassTerm> _applyFilters(List<AdminClassTerm> all, List<AdminSemester> semesters) {
    return all.where((t) {
      if (_semesterFilter != null && t.semesterId != _semesterFilter) return false;
      if (_facultyFilter != null && t.facultyId != _facultyFilter) return false;
      if (_majorFilter != null && t.majorId != _majorFilter) return false;
      if (_classFilter != null && t.classId != _classFilter) return false;
      if (_yearLevelFilter != null && t.yearLevel != _yearLevelFilter) return false;
      if (_academicYearFilter != null) {
        final semList = semesters.where((s) => s.id == t.semesterId);
        if (semList.isEmpty || semList.first.academicYearId != _academicYearFilter) return false;
      }
      if (_search.isNotEmpty) {
        final q = _search.toLowerCase();
        final matchesCourse =
            t.courses.any((c) => c.courseName.toLowerCase().contains(q) || c.courseCode.toLowerCase().contains(q));
        if (!t.classCode.toLowerCase().contains(q) && !matchesCourse) return false;
      }
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final termsAsync = ref.watch(adminClassTermsProvider);
    final allSemesters = ref.watch(adminSemestersProvider).valueOrNull ?? [];
    final allMajors = ref.watch(adminMajorsProvider).valueOrNull ?? [];
    final allFaculties = ref.watch(adminFacultiesProvider).valueOrNull ?? [];
    final allAcademicYears = ref.watch(adminAcademicYearsProvider).valueOrNull ?? [];
    final allClasses = ref.watch(adminAllClassesProvider).valueOrNull ?? [];

    return termsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.error_outline, color: AppColors.statusRed, size: 40),
          const SizedBox(height: 8),
          Text('Could not load classes', style: AppTextStyles.body),
          TextButton(
            onPressed: () => ref.invalidate(adminClassTermsProvider),
            child: const Text('Retry'),
          ),
        ]),
      ),
      data: (all) {
        final filtered = _applyFilters(all, allSemesters);
        final totalEnrolled = filtered.fold(0, (s, r) => s + r.enrolledCount);
        final totalMax = filtered.fold(0, (s, r) => s + r.maxStudents);
        final fullCount = filtered.where((r) => r.pct >= 1.0).length;

        return Stack(children: [
          Column(children: [
            _buildFilters(allSemesters, allMajors, allFaculties, allAcademicYears, allClasses),
            _buildFacultyCounts(allFaculties, all),
            _buildStats(filtered.length, totalEnrolled, totalMax - totalEnrolled, fullCount),
            Expanded(child: _buildList(context, filtered)),
          ]),
          Positioned(
            right: 16,
            bottom: 16,
            child: FloatingActionButton.extended(
              onPressed: () => _showAddMenu(context, all),
              backgroundColor: AppColors.primaryNavy,
              icon: const Icon(Icons.add, color: Colors.white),
              label: Text('Add',
                  style: AppTextStyles.bodyMedium.copyWith(color: Colors.white)),
            ),
          ),
        ]);
      },
    );
  }

  // ── filter bar ─────────────────────────────────────────────────────────────

  Widget _buildFilters(
    List<AdminSemester> semesters,
    List<AdminMajor> majors,
    List<AdminFaculty> faculties,
    List<AdminAcademicYear> academicYears,
    List<AdminClass> classes,
  ) {
    final sortedSemesters = semesters.toList()
      ..sort((a, b) => a.name.compareTo(b.name));

    final sortedFaculties = faculties.toList()
      ..sort((a, b) => a.name.compareTo(b.name));

    // Majors narrowed to the selected faculty, if any.
    final filteredMajors = majors
        .where((m) => _facultyFilter == null || m.facultyId == _facultyFilter)
        .toList()
      ..sort((a, b) => a.name.compareTo(b.name));

    final sortedAcademicYears = academicYears.toList()
      ..sort((a, b) => b.name.compareTo(a.name)); // chronological descending

    final sortedClasses = classes.toList()
      ..sort((a, b) => a.classCode.compareTo(b.classCode));

    return Container(
      color: AppColors.bgPage,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Column(children: [
        // Search
        Container(
          height: 38,
          decoration: BoxDecoration(
            color: AppColors.bgInput,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.border),
          ),
          child: TextField(
            onChanged: (v) => setState(() => _search = v),
            style: AppTextStyles.body.copyWith(fontSize: 13),
            decoration: InputDecoration(
              hintText: 'Search class or course…',
              hintStyle: AppTextStyles.caption,
              prefixIcon:
                  Icon(Icons.search, size: 16, color: AppColors.textSecondary),
              prefixIconConstraints: const BoxConstraints(minWidth: 36),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(children: [
          Expanded(
            child: _Drop<String>(
              value: _facultyFilter,
              hint: 'All Faculties',
              items: sortedFaculties
                  .map((f) => DropdownMenuItem(
                      value: f.id,
                      child: Text(f.name, overflow: TextOverflow.ellipsis)))
                  .toList(),
              onChanged: (v) => setState(() {
                _facultyFilter = v;
                _majorFilter = null;
              }),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _Drop<String>(
              value: _semesterFilter,
              hint: 'All Semesters',
              items: sortedSemesters
                  .map((s) => DropdownMenuItem(
                      value: s.id,
                      child: Text('${s.name} (${s.academicYear})', overflow: TextOverflow.ellipsis)))
                  .toList(),
              onChanged: (v) => setState(() => _semesterFilter = v),
            ),
          ),
        ]),
        const SizedBox(height: 8),
        Row(children: [
          Expanded(
            child: _Drop<String>(
              value: _majorFilter,
              hint: 'All Majors',
              items: filteredMajors
                  .map((m) => DropdownMenuItem(
                      value: m.id,
                      child: Text(m.name, overflow: TextOverflow.ellipsis)))
                  .toList(),
              onChanged: (v) => setState(() => _majorFilter = v),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _Drop<String>(
              value: _academicYearFilter,
              hint: 'All Acad. Years',
              items: sortedAcademicYears
                  .map((ay) => DropdownMenuItem(
                      value: ay.id,
                      child: Text(ay.name, overflow: TextOverflow.ellipsis)))
                  .toList(),
              onChanged: (v) => setState(() => _academicYearFilter = v),
            ),
          ),
        ]),
        const SizedBox(height: 8),
        Row(children: [
          Expanded(
            child: _Drop<String>(
              value: _classFilter,
              hint: 'All Classes',
              items: sortedClasses
                  .map((c) => DropdownMenuItem(
                      value: c.id,
                      child: Text(c.classCode, overflow: TextOverflow.ellipsis)))
                  .toList(),
              onChanged: (v) => setState(() => _classFilter = v),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _Drop<int>(
              value: _yearLevelFilter,
              hint: 'All Years',
              items: [1, 2, 3, 4]
                  .map((yl) => DropdownMenuItem<int>(
                      value: yl,
                      child: Text('Year $yl')))
                  .toList(),
              onChanged: (v) => setState(() => _yearLevelFilter = v),
            ),
          ),
          if (_facultyFilter != null ||
              _semesterFilter != null ||
              _majorFilter != null ||
              _academicYearFilter != null ||
              _classFilter != null ||
              _yearLevelFilter != null ||
              _search.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: GestureDetector(
                onTap: () => setState(() {
                  _facultyFilter = null;
                  _semesterFilter = null;
                  _majorFilter = null;
                  _academicYearFilter = null;
                  _classFilter = null;
                  _yearLevelFilter = null;
                  _search = '';
                }),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.statusRed.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(Icons.close, size: 14, color: AppColors.statusRed),
                ),
              ),
            ),
        ]),
      ]),
    );
  }

  // ── per-faculty class counts ──────────────────────────────────────────────

  Widget _buildFacultyCounts(List<AdminFaculty> faculties, List<AdminClassTerm> all) {
    if (faculties.isEmpty || all.isEmpty) return const SizedBox.shrink();

    final counts = <String, int>{};
    for (final s in all) {
      final name = s.facultyName ?? 'Unassigned';
      counts[name] = (counts[name] ?? 0) + 1;
    }
    if (counts.isEmpty) return const SizedBox.shrink();

    final entries = counts.entries.toList()..sort((a, b) => b.value.compareTo(a.value));

    return Container(
      color: AppColors.bgPage,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      child: SizedBox(
        height: 28,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: entries.length,
          separatorBuilder: (_, _) => const SizedBox(width: 6),
          itemBuilder: (_, i) {
            final e = entries[i];
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.primaryNavy.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                '${e.key}: ${e.value}',
                style: AppTextStyles.caption
                    .copyWith(fontSize: 11, color: AppColors.primaryNavy, fontWeight: FontWeight.w600),
              ),
            );
          },
        ),
      ),
    );
  }

  // ── stats bar ──────────────────────────────────────────────────────────────

  Widget _buildStats(int total, int enrolled, int available, int full) {
    return Container(
      color: AppColors.bgCard,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(children: [
        _StatChip(label: 'Terms', value: '$total', color: AppColors.primaryNavy),
        _StatChip(label: 'Enrolled', value: '$enrolled', color: AppColors.primaryBlue),
        _StatChip(label: 'Available', value: '$available', color: AppColors.statusGreen),
        _StatChip(label: 'Full', value: '$full', color: AppColors.statusRed),
      ]),
    );
  }

  // ── list ───────────────────────────────────────────────────────────────────

  Widget _buildList(BuildContext context, List<AdminClassTerm> terms) {
    if (terms.isEmpty) {
      return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.class_outlined, size: 48,
              color: AppColors.textSecondary.withValues(alpha: 0.4)),
          const SizedBox(height: 12),
          Text('No classes found', style: AppTextStyles.bodyMedium),
          const SizedBox(height: 4),
          Text('Tap + Add Class to create one',
              style: AppTextStyles.caption),
        ]),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
      itemCount: terms.length,
      itemBuilder: (_, i) => _ClassTermCard(
        term: terms[i],
        onEditTerm: () => _showClassSheet(context, terms[i]),
        onDeleteTerm: () => _confirmDelete(context, terms[i]),
        onStudents: () => _showStudentsSheet(context, terms[i]),
        onAddCourse: () => _showAddCourseSheet(context, terms[i]),
        onEditCourse: (c) => _showEditCourseSheet(context, terms[i], c),
        onRemoveCourse: (c) => _confirmRemoveCourse(context, c),
        onScheduleCourse: (c) => showClassScheduleSheet(
          context,
          classTermCourseId: c.id,
          classLabel: '${terms[i].classCode}-${c.courseCode}',
          initialSchedule: c.schedule,
          scheduleType: terms[i].scheduleType,
          onSaved: () => ref.invalidate(adminClassTermsProvider),
        ),
      ),
    );
  }

  // ── actions ────────────────────────────────────────────────────────────────

  void _showAddMenu(BuildContext context, List<AdminClassTerm> allTerms) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.bgCard,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 36, height: 4,
              decoration: BoxDecoration(
                  color: AppColors.border, borderRadius: BorderRadius.circular(2)),
            ),
            ListTile(
              leading: Icon(Icons.add_circle_outline, color: AppColors.primaryNavy),
              title: const Text('New Class'),
              subtitle: const Text('Create a brand-new cohort'),
              onTap: () {
                Navigator.pop(ctx);
                _showClassSheet(context, null);
              },
            ),
            ListTile(
              leading: Icon(Icons.playlist_add, color: AppColors.primaryNavy),
              title: const Text('New Term for Existing Class'),
              subtitle: const Text('Carry an existing class into a new semester'),
              onTap: () {
                Navigator.pop(ctx);
                _showNewTermSheet(context, allTerms);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _showNewTermSheet(BuildContext context, List<AdminClassTerm> allTerms) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _NewTermFormSheet(
        allTerms: allTerms,
        onSaved: () => ref.invalidate(adminClassTermsProvider),
      ),
    );
  }

  void _showClassSheet(BuildContext context, AdminClassTerm? existing) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ClassFormSheet(
        existing: existing,
        onSaved: () => ref.invalidate(adminClassTermsProvider),
      ),
    );
  }

  void _showAddCourseSheet(BuildContext context, AdminClassTerm term) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ClassTermCourseFormSheet(
        classTermId: term.id,
        classFacultyId: term.facultyId,
        classMajorId: term.majorId,
        existing: null,
        onSaved: () => ref.invalidate(adminClassTermsProvider),
      ),
    );
  }

  void _showEditCourseSheet(
      BuildContext context, AdminClassTerm term, AdminClassTermCourse course) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ClassTermCourseFormSheet(
        classTermId: course.classTermId,
        classFacultyId: term.facultyId,
        classMajorId: term.majorId,
        existing: course,
        onSaved: () => ref.invalidate(adminClassTermsProvider),
      ),
    );
  }

  void _showStudentsSheet(BuildContext context, AdminClassTerm term) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _StudentsSheet(term: term),
    );
  }

  void _confirmRemoveCourse(BuildContext context, AdminClassTermCourse course) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Remove Course'),
        content: Text('Remove ${course.courseCode} from this class term? '
            'Enrolled students will no longer see it on their schedule.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.statusRed),
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await ref.read(adminServiceProvider).removeCourseFromClassTerm(course.id);
                ref.invalidate(adminClassTermsProvider);
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                }
              }
            },
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, AdminClassTerm term) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Class Term'),
        content: Text(
            'Delete ${term.classCode} for ${term.semesterName ?? 'this semester'}? '
            'Enrolled students will not be removed automatically.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.statusRed),
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await ref
                    .read(adminServiceProvider)
                    .deleteClassTerm(term.id);
                ref.invalidate(adminClassTermsProvider);
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')));
                }
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

// ── Class term card ──────────────────────────────────────────────────────────

class _ClassTermCard extends StatefulWidget {
  const _ClassTermCard({
    required this.term,
    required this.onEditTerm,
    required this.onDeleteTerm,
    required this.onStudents,
    required this.onAddCourse,
    required this.onEditCourse,
    required this.onRemoveCourse,
    required this.onScheduleCourse,
  });
  final AdminClassTerm term;
  final VoidCallback onEditTerm;
  final VoidCallback onDeleteTerm;
  final VoidCallback onStudents;
  final VoidCallback onAddCourse;
  final ValueChanged<AdminClassTermCourse> onEditCourse;
  final ValueChanged<AdminClassTermCourse> onRemoveCourse;
  final ValueChanged<AdminClassTermCourse> onScheduleCourse;

  @override
  State<_ClassTermCard> createState() => _ClassTermCardState();
}

class _ClassTermCardState extends State<_ClassTermCard> {
  bool _expanded = false;

  AdminClassTerm get term => widget.term;
  VoidCallback get onEditTerm => widget.onEditTerm;
  VoidCallback get onDeleteTerm => widget.onDeleteTerm;
  VoidCallback get onStudents => widget.onStudents;
  VoidCallback get onAddCourse => widget.onAddCourse;
  ValueChanged<AdminClassTermCourse> get onEditCourse => widget.onEditCourse;
  ValueChanged<AdminClassTermCourse> get onRemoveCourse => widget.onRemoveCourse;
  ValueChanged<AdminClassTermCourse> get onScheduleCourse => widget.onScheduleCourse;

  Color get _shiftColor {
    switch (term.shift) {
      case 'morning':   return const Color(0xFFF59E0B);
      case 'afternoon': return AppColors.primaryBlue;
      case 'evening':   return const Color(0xFF7C3AED);
      default:          return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final pct = term.pct;
    final barColor = pct >= 1.0
        ? AppColors.statusRed
        : pct >= 0.8
            ? AppColors.statusAmber
            : AppColors.statusGreen;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.primaryNavy.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(term.classCode,
                    style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.primaryNavy, fontSize: 13,
                        fontWeight: FontWeight.w800),
                    textAlign: TextAlign.center,
                    maxLines: 2, overflow: TextOverflow.ellipsis),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(spacing: 4, runSpacing: 4, children: [
                    _Chip(label: 'Year ${term.yearLevel}', color: AppColors.primaryNavy),
                    _Chip(label: term.shiftLabel, color: _shiftColor),
                    _Chip(label: term.scheduleLabel, color: AppColors.textSecondary),
                  ]),
                  if (term.semesterName != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      '${term.semesterName}\n${term.fmtStart} – ${term.fmtEnd}',
                      style: AppTextStyles.caption
                          .copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                  if (term.facultyName != null) ...[
                    const SizedBox(height: 2),
                    Text(term.facultyName!,
                        style: AppTextStyles.caption
                            .copyWith(color: AppColors.textSecondary)),
                  ],
                  if (term.room != null) ...[
                    const SizedBox(height: 2),
                    Row(children: [
                      Icon(Icons.room_outlined, size: 12, color: AppColors.textSecondary),
                      const SizedBox(width: 3),
                      Text(term.room!,
                          style: AppTextStyles.caption
                              .copyWith(color: AppColors.textSecondary)),
                    ]),
                  ],
                ],
              ),
            ),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text('${term.enrolledCount}/${term.maxStudents}',
                  style: AppTextStyles.bodyMedium.copyWith(color: barColor, fontSize: 13)),
              const SizedBox(height: 4),
              SizedBox(
                width: 56,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: LinearProgressIndicator(
                    value: pct.clamp(0.0, 1.0),
                    backgroundColor: AppColors.border,
                    color: barColor,
                    minHeight: 4,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(children: [
                _IconBtn(icon: Icons.edit_outlined, color: AppColors.primaryBlue, onTap: onEditTerm),
                const SizedBox(width: 4),
                _IconBtn(icon: Icons.delete_outline, color: AppColors.statusRed, onTap: onDeleteTerm),
              ]),
            ]),
          ]),
        ),
        Divider(height: 1, color: AppColors.border),
        // Curriculum — collapsed by default since a class card is one
        // semester's offering, not the whole program; tap to see its courses.
        InkWell(
          onTap: () => setState(() => _expanded = !_expanded),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
            child: Row(children: [
              Icon(_expanded ? Icons.expand_less : Icons.expand_more,
                  size: 18, color: AppColors.textSecondary),
              const SizedBox(width: 6),
              Text(
                  'CURRICULUM (${term.courses.length} course${term.courses.length == 1 ? '' : 's'})',
                  style: AppTextStyles.label.copyWith(fontSize: 10)),
              const Spacer(),
              GestureDetector(
                onTap: onAddCourse,
                child: Row(children: [
                  Icon(Icons.add, size: 14, color: AppColors.primaryBlue),
                  const SizedBox(width: 2),
                  Text('Add Course',
                      style: AppTextStyles.caption.copyWith(
                          color: AppColors.primaryBlue, fontWeight: FontWeight.w600)),
                ]),
              ),
            ]),
          ),
        ),
        if (_expanded)
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (term.courses.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Text('No courses attached yet.', style: AppTextStyles.caption),
                  )
                else
                  ...term.courses.map((c) => _CourseRow(
                        course: c,
                        onEdit: () => onEditCourse(c),
                        onRemove: () => onRemoveCourse(c),
                        onSchedule: () => onScheduleCourse(c),
                      )),
              ],
            ),
          ),
        InkWell(
          onTap: onStudents,
          borderRadius: const BorderRadius.vertical(bottom: Radius.circular(10)),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.bgInput,
              border: Border(top: BorderSide(color: AppColors.border)),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(10)),
            ),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.people_outline, size: 14, color: AppColors.primaryBlue),
              const SizedBox(width: 6),
              Text('View Students',
                  style: AppTextStyles.caption.copyWith(
                      color: AppColors.primaryBlue, fontWeight: FontWeight.w600)),
            ]),
          ),
        ),
      ]),
    );
  }
}

class _CourseRow extends StatelessWidget {
  const _CourseRow({
    required this.course,
    required this.onEdit,
    required this.onRemove,
    required this.onSchedule,
  });
  final AdminClassTermCourse course;
  final VoidCallback onEdit;
  final VoidCallback onRemove;
  final VoidCallback onSchedule;

  static const _dayOrder = {
    'Mon': 0, 'Tue': 1, 'Wed': 2, 'Thu': 3, 'Fri': 4, 'Sat': 5, 'Sun': 6
  };

  int _parseTimeToMinutes(String hhmm) {
    final parts = hhmm.split(':');
    if (parts.length != 2) return 0;
    final h = int.tryParse(parts[0]) ?? 0;
    final m = int.tryParse(parts[1]) ?? 0;
    return h * 60 + m;
  }

  String get _scheduleSummary {
    if (course.schedule.isEmpty) return 'No timeslot yet';
    final sorted = [...course.schedule]..sort((a, b) {
      final dayA = _dayOrder[a['day']] ?? 99;
      final dayB = _dayOrder[b['day']] ?? 99;
      if (dayA != dayB) return dayA.compareTo(dayB);
      final startA = _parseTimeToMinutes(a['start'] as String? ?? '');
      final startB = _parseTimeToMinutes(b['start'] as String? ?? '');
      return startA.compareTo(startB);
    });
    return sorted
        .map((s) => '${s['day']} ${s['start']}–${s['end']}')
        .join(', ');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.bgPage,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${course.courseCode} · ${course.courseName}',
                  style: AppTextStyles.body.copyWith(fontSize: 12, fontWeight: FontWeight.w600),
                  maxLines: 1, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 2),
              Text(course.teacherName ?? 'Unassigned teacher',
                  style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
              Text(_scheduleSummary,
                  style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary, fontSize: 10)),
            ],
          ),
        ),
        _IconBtn(icon: Icons.schedule_outlined, color: AppColors.textSecondary, onTap: onSchedule),
        const SizedBox(width: 4),
        _IconBtn(icon: Icons.edit_outlined, color: AppColors.primaryBlue, onTap: onEdit),
        const SizedBox(width: 4),
        _IconBtn(icon: Icons.close, color: AppColors.statusRed, onTap: onRemove),
      ]),
    );
  }
}

// ── Class + term form sheet ───────────────────────────────────────────────────

class _ClassFormSheet extends ConsumerStatefulWidget {
  const _ClassFormSheet({required this.existing, required this.onSaved});
  final AdminClassTerm? existing;
  final VoidCallback onSaved;

  @override
  ConsumerState<_ClassFormSheet> createState() => _ClassFormSheetState();
}

class _ClassFormSheetState extends ConsumerState<_ClassFormSheet> {
  final _codeCtrl = TextEditingController();
  final _maxCtrl  = TextEditingController(text: '30');
  final _roomCtrl = TextEditingController();
  final _yearCtrl = TextEditingController(text: '1');

  String? _facultyId;
  String? _majorId;
  String? _semesterId;
  String _program  = 'national';
  String _schedule = 'weekday';
  String _shift    = 'morning';
  DateTime? _customStartDate;
  DateTime? _customEndDate;
  bool _saving = false;

  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    if (e != null) {
      _facultyId  = e.facultyId;
      _majorId    = e.majorId;
      _semesterId = e.semesterId;
      _program    = 'national';
      _schedule   = e.scheduleType;
      _shift      = e.shift;
      _codeCtrl.text = e.classCode;
      _maxCtrl.text  = '${e.maxStudents}';
      _roomCtrl.text = e.room ?? '';
      _yearCtrl.text = '${e.yearLevel}';
      _customStartDate = DateTime.tryParse(e.startDate);
      _customEndDate = DateTime.tryParse(e.endDate);
    }
  }

  @override
  void dispose() {
    _codeCtrl.dispose();
    _maxCtrl.dispose();
    _roomCtrl.dispose();
    _yearCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_semesterId == null) {
      _snack('Please select a semester'); return;
    }
    if (_customStartDate == null || _customEndDate == null) {
      _snack('Start and End dates are required'); return;
    }
    final code = _codeCtrl.text.trim();
    if (code.isEmpty) {
      _snack('Class code is required'); return;
    }
    final max = int.tryParse(_maxCtrl.text.trim()) ?? 0;
    if (max <= 0) {
      _snack('Max students must be greater than 0'); return;
    }
    final year = int.tryParse(_yearCtrl.text.trim()) ?? 0;
    if (year <= 0) {
      _snack('Year level must be greater than 0'); return;
    }

    setState(() => _saving = true);
    try {
      final svc = ref.read(adminServiceProvider);
      final startStr = DateFormat('yyyy-MM-dd').format(_customStartDate!);
      final endStr = DateFormat('yyyy-MM-dd').format(_customEndDate!);

      if (_isEdit) {
        await svc.updateClass(
          classId: widget.existing!.classId,
          classCode: code,
          facultyId: _facultyId,
          majorId: _majorId,
          programType: _program,
        );
        await svc.updateClassTerm(
          classTermId: widget.existing!.id,
          semesterId: _semesterId!,
          yearLevel: year,
          scheduleType: _schedule,
          shift: _shift,
          room: _roomCtrl.text.trim().isEmpty ? null : _roomCtrl.text.trim(),
          maxStudents: max,
          startDate: startStr,
          endDate: endStr,
        );
      } else {
        final classId = await svc.createClass(
          classCode: code,
          facultyId: _facultyId,
          majorId: _majorId,
          programType: _program,
        );
        await svc.createClassTerm(
          classId: classId,
          semesterId: _semesterId!,
          yearLevel: year,
          scheduleType: _schedule,
          shift: _shift,
          room: _roomCtrl.text.trim().isEmpty ? null : _roomCtrl.text.trim(),
          maxStudents: max,
          startDate: startStr,
          endDate: endStr,
        );
      }
      widget.onSaved();
      if (mounted) {
        showSuccessToast(context, _isEdit ? 'Class updated.' : 'Class created.');
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _saving = false);
        _snack('Error: $e');
      }
    }
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final allSemesters = ref.watch(adminSemestersProvider).valueOrNull ?? [];
    final allFaculties = ref.watch(adminFacultiesProvider).valueOrNull ?? [];
    final allMajors = ref.watch(adminMajorsProvider).valueOrNull ?? [];

    final sortedSemesters = allSemesters.toList()
      ..sort((a, b) => a.name.compareTo(b.name));

    final sortedFaculties = allFaculties.toList()
      ..sort((a, b) => a.name.compareTo(b.name));

    final filteredMajors = allMajors
        .where((m) => _facultyId == null || m.facultyId == _facultyId)
        .toList()
      ..sort((a, b) => a.name.compareTo(b.name));

    return Padding(
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom),
      child: DraggableScrollableSheet(
        initialChildSize: 0.85,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        expand: false,
        builder: (_, sc) => Container(
          decoration: BoxDecoration(
            color: AppColors.bgCard,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 10),
              width: 36, height: 4,
              decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2)),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: Row(children: [
                Text(_isEdit ? 'Edit Class' : 'New Class',
                    style: AppTextStyles.h2),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ]),
            ),
            Divider(height: 0, color: AppColors.divider),
            Expanded(
              child: ListView(
                controller: sc,
                padding: const EdgeInsets.all(20),
                children: [
                  _FieldLabel('Faculty'),
                  _DropField<String>(
                    value: _facultyId,
                    hint: 'All Faculties',
                    items: [
                      const DropdownMenuItem(value: null, child: Text('Unassigned')),
                      ...sortedFaculties.map((f) => DropdownMenuItem(
                          value: f.id,
                          child: Text(f.name, overflow: TextOverflow.ellipsis))),
                    ],
                    onChanged: (v) => setState(() {
                      _facultyId = v;
                      _majorId = null;
                    }),
                  ),
                  const SizedBox(height: 16),

                  _FieldLabel('Major'),
                  _DropField<String>(
                    value: _majorId,
                    hint: 'Unassigned',
                    items: [
                      const DropdownMenuItem(value: null, child: Text('Unassigned')),
                      ...filteredMajors.map((m) => DropdownMenuItem(
                          value: m.id,
                          child: Text(m.name, overflow: TextOverflow.ellipsis))),
                    ],
                    onChanged: (v) => setState(() => _majorId = v),
                  ),
                  const SizedBox(height: 16),

                  _FieldLabel('Class Code *'),
                  _TextField(
                    controller: _codeCtrl,
                    hint: 'e.g. BATCH-2025-A',
                    textCapitalization: TextCapitalization.characters,
                  ),
                  const SizedBox(height: 16),

                  _FieldLabel('Program'),
                  _SegmentRow(
                    options: const [
                      ('national', 'National'),
                      ('international', 'International'),
                    ],
                    selected: _program,
                    onSelected: (v) => setState(() => _program = v),
                  ),
                  const SizedBox(height: 16),

                  _FieldLabel('Semester *'),
                  _DropField<String>(
                    value: _semesterId,
                    hint: 'Select semester',
                    items: sortedSemesters
                        .map((s) => DropdownMenuItem(
                            value: s.id,
                            child: Text('${s.name} (${s.academicYear})', overflow: TextOverflow.ellipsis)))
                        .toList(),
                    onChanged: (v) {
                      setState(() {
                        _semesterId = v;
                        if (v != null) {
                          final sem = sortedSemesters.firstWhere((s) => s.id == v);
                          _customStartDate = DateTime.tryParse(sem.startDate);
                          _customEndDate = DateTime.tryParse(sem.endDate);
                        }
                      });
                    },
                  ),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _FieldLabel('Start Date *'),
                            _DatePickerField(
                              date: _customStartDate,
                              hint: 'Select start date',
                              onPick: () async {
                                final d = await showDatePicker(
                                  context: context,
                                  initialDate: _customStartDate ?? DateTime.now(),
                                  firstDate: DateTime(2020),
                                  lastDate: DateTime(2035),
                                );
                                if (d != null) {
                                  setState(() {
                                    _customStartDate = d;
                                    if (_customEndDate == null || _customEndDate!.isBefore(d)) {
                                      _customEndDate = d.add(const Duration(days: 120));
                                    }
                                  });
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _FieldLabel('End Date *'),
                            _DatePickerField(
                              date: _customEndDate,
                              hint: 'Select end date',
                              onPick: () async {
                                final d = await showDatePicker(
                                  context: context,
                                  initialDate: _customEndDate ?? (_customStartDate ?? DateTime.now()),
                                  firstDate: _customStartDate ?? DateTime(2020),
                                  lastDate: DateTime(2035),
                                );
                                if (d != null) {
                                  setState(() => _customEndDate = d);
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _FieldLabel('Year Level *'),
                          _TextField(
                            controller: _yearCtrl,
                            hint: '1',
                            keyboardType: TextInputType.number,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _FieldLabel('Max Students *'),
                          _TextField(
                            controller: _maxCtrl,
                            hint: '30',
                            keyboardType: TextInputType.number,
                          ),
                        ],
                      ),
                    ),
                  ]),
                  const SizedBox(height: 16),

                  _FieldLabel('Schedule'),
                  _SegmentRow(
                    options: const [
                      ('weekday', 'Weekday'),
                      ('weekend', 'Weekend'),
                    ],
                    selected: _schedule,
                    onSelected: (v) => setState(() => _schedule = v),
                  ),
                  const SizedBox(height: 16),

                  _FieldLabel('Shift'),
                  _SegmentRow(
                    options: const [
                      ('morning', 'Morning'),
                      ('afternoon', 'Afternoon'),
                      ('evening', 'Evening'),
                    ],
                    selected: _shift,
                    onSelected: (v) => setState(() => _shift = v),
                  ),
                  const SizedBox(height: 16),

                  _FieldLabel('Room (optional)'),
                  _TextField(
                    controller: _roomCtrl,
                    hint: 'e.g. Room 201, Lab 3',
                  ),
                  const SizedBox(height: 28),

                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: FilledButton(
                      onPressed: _saving ? null : _save,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primaryNavy,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      child: _saving
                          ? const SizedBox(
                              width: 20, height: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white))
                          : Text(_isEdit ? 'Save Changes' : 'Create Class',
                              style: AppTextStyles.bodyMedium
                                  .copyWith(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

// ── New term for an existing class ────────────────────────────────────────────
// Carries an existing class into a new semester without recreating it — the
// class's identity/faculty/major stay put, only the term-level facts change.

class _NewTermFormSheet extends ConsumerStatefulWidget {
  const _NewTermFormSheet({required this.allTerms, required this.onSaved});
  final List<AdminClassTerm> allTerms;
  final VoidCallback onSaved;

  @override
  ConsumerState<_NewTermFormSheet> createState() => _NewTermFormSheetState();
}

class _NewTermFormSheetState extends ConsumerState<_NewTermFormSheet> {
  final _maxCtrl  = TextEditingController(text: '30');
  final _roomCtrl = TextEditingController();
  final _yearCtrl = TextEditingController(text: '1');

  String? _classId;
  String? _semesterId;
  String _schedule = 'weekday';
  String _shift    = 'morning';
  DateTime? _customStartDate;
  DateTime? _customEndDate;
  bool _saving = false;

  // The class's most recent prior term (if any), offered as a one-tap way to
  // carry its roster forward instead of re-inviting everyone by hand.
  String? _priorTermId;
  int _priorStudentCount = 0;
  bool _copyRoster = false;

  @override
  void dispose() {
    _maxCtrl.dispose();
    _roomCtrl.dispose();
    _yearCtrl.dispose();
    super.dispose();
  }

  // Pre-fill from the class's most recent term, if it has one, so admins
  // aren't retyping room/shift/schedule every semester.
  void _onClassSelected(String classId) {
    final priorTerms = widget.allTerms.where((t) => t.classId == classId).toList()
      ..sort((a, b) => b.yearLevel.compareTo(a.yearLevel));
    setState(() {
      _classId = classId;
      if (priorTerms.isNotEmpty) {
        final last = priorTerms.first;
        _yearCtrl.text = '${last.yearLevel + 1}';
        _schedule = last.scheduleType;
        _shift = last.shift;
        _roomCtrl.text = last.room ?? '';
        _maxCtrl.text = '${last.maxStudents}';
        _priorTermId = last.id;
        _priorStudentCount = last.enrolledCount;
        _copyRoster = _priorStudentCount > 0;
      } else {
        _yearCtrl.text = '1';
        _priorTermId = null;
        _priorStudentCount = 0;
        _copyRoster = false;
      }
    });
  }

  Future<void> _save() async {
    if (_classId == null) {
      _snack('Please select a class'); return;
    }
    if (_semesterId == null) {
      _snack('Please select a semester'); return;
    }
    if (_customStartDate == null || _customEndDate == null) {
      _snack('Start and End dates are required'); return;
    }
    final max = int.tryParse(_maxCtrl.text.trim()) ?? 0;
    if (max <= 0) {
      _snack('Max students must be greater than 0'); return;
    }
    final year = int.tryParse(_yearCtrl.text.trim()) ?? 0;
    if (year <= 0) {
      _snack('Year level must be greater than 0'); return;
    }

    setState(() => _saving = true);
    try {
      final svc = ref.read(adminServiceProvider);
      final startStr = DateFormat('yyyy-MM-dd').format(_customStartDate!);
      final endStr = DateFormat('yyyy-MM-dd').format(_customEndDate!);

      final newTermId = await svc.createClassTerm(
        classId: _classId!,
        semesterId: _semesterId!,
        yearLevel: year,
        scheduleType: _schedule,
        shift: _shift,
        room: _roomCtrl.text.trim().isEmpty ? null : _roomCtrl.text.trim(),
        maxStudents: max,
        startDate: startStr,
        endDate: endStr,
      );

      var copied = 0;
      if (_copyRoster && _priorTermId != null) {
        copied = await svc.copyEnrollments(
          fromClassTermId: _priorTermId!,
          toClassTermId: newTermId,
        );
      }

      widget.onSaved();
      if (mounted) {
        showSuccessToast(
          context,
          copied > 0
              ? 'Term created — copied $copied student${copied == 1 ? '' : 's'} from the previous term.'
              : 'Term created — now add its courses and enroll students.',
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _saving = false);
        final msg = e.toString().contains('unique')
            ? 'This class already has a term for that semester.'
            : 'Error: $e';
        _snack(msg);
      }
    }
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final allClasses = ref.watch(adminAllClassesProvider).valueOrNull ?? [];
    final allSemesters = ref.watch(adminSemestersProvider).valueOrNull ?? [];

    final sortedClasses = allClasses.toList()..sort((a, b) => a.classCode.compareTo(b.classCode));
    final sortedSemesters = allSemesters.toList()..sort((a, b) => a.name.compareTo(b.name));

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: DraggableScrollableSheet(
        initialChildSize: 0.75,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        expand: false,
        builder: (_, sc) => Container(
          decoration: BoxDecoration(
            color: AppColors.bgCard,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 10),
              width: 36, height: 4,
              decoration: BoxDecoration(
                  color: AppColors.border, borderRadius: BorderRadius.circular(2)),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: Row(children: [
                Text('New Term for Existing Class', style: AppTextStyles.h2),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ]),
            ),
            Divider(height: 0, color: AppColors.divider),
            Expanded(
              child: ListView(
                controller: sc,
                padding: const EdgeInsets.all(20),
                children: [
                  _FieldLabel('Class *'),
                  _DropField<String>(
                    value: _classId,
                    hint: 'Select class',
                    items: sortedClasses
                        .map((c) => DropdownMenuItem(
                            value: c.id,
                            child: Text(
                                '${c.classCode}${c.majorName != null ? ' — ${c.majorName}' : ''}',
                                overflow: TextOverflow.ellipsis)))
                        .toList(),
                    onChanged: (v) {
                      if (v != null) _onClassSelected(v);
                    },
                  ),
                  if (_priorStudentCount > 0) ...[
                    const SizedBox(height: 8),
                    CheckboxListTile(
                      value: _copyRoster,
                      onChanged: (v) => setState(() => _copyRoster = v ?? false),
                      controlAffinity: ListTileControlAffinity.leading,
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                      title: Text(
                        'Copy $_priorStudentCount student${_priorStudentCount == 1 ? '' : 's'} from previous term',
                        style: AppTextStyles.body.copyWith(fontSize: 13),
                      ),
                      subtitle: Text(
                        'Enrolls each continuing student into this new term automatically.',
                        style: AppTextStyles.caption,
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),

                  _FieldLabel('Semester *'),
                  _DropField<String>(
                    value: _semesterId,
                    hint: 'Select semester',
                    items: sortedSemesters
                        .map((s) => DropdownMenuItem(
                            value: s.id,
                            child: Text('${s.name} (${s.academicYear})', overflow: TextOverflow.ellipsis)))
                        .toList(),
                    onChanged: (v) {
                      setState(() {
                        _semesterId = v;
                        if (v != null) {
                          final sem = sortedSemesters.firstWhere((s) => s.id == v);
                          _customStartDate = DateTime.tryParse(sem.startDate);
                          _customEndDate = DateTime.tryParse(sem.endDate);
                        }
                      });
                    },
                  ),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _FieldLabel('Start Date *'),
                            _DatePickerField(
                              date: _customStartDate,
                              hint: 'Select start date',
                              onPick: () async {
                                final d = await showDatePicker(
                                  context: context,
                                  initialDate: _customStartDate ?? DateTime.now(),
                                  firstDate: DateTime(2020),
                                  lastDate: DateTime(2035),
                                );
                                if (d != null) {
                                  setState(() {
                                    _customStartDate = d;
                                    if (_customEndDate == null || _customEndDate!.isBefore(d)) {
                                      _customEndDate = d.add(const Duration(days: 120));
                                    }
                                  });
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _FieldLabel('End Date *'),
                            _DatePickerField(
                              date: _customEndDate,
                              hint: 'Select end date',
                              onPick: () async {
                                final d = await showDatePicker(
                                  context: context,
                                  initialDate: _customEndDate ?? (_customStartDate ?? DateTime.now()),
                                  firstDate: _customStartDate ?? DateTime(2020),
                                  lastDate: DateTime(2035),
                                );
                                if (d != null) {
                                  setState(() => _customEndDate = d);
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _FieldLabel('Year Level *'),
                          _TextField(
                            controller: _yearCtrl,
                            hint: '1',
                            keyboardType: TextInputType.number,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _FieldLabel('Max Students *'),
                          _TextField(
                            controller: _maxCtrl,
                            hint: '30',
                            keyboardType: TextInputType.number,
                          ),
                        ],
                      ),
                    ),
                  ]),
                  const SizedBox(height: 16),

                  _FieldLabel('Schedule'),
                  _SegmentRow(
                    options: const [
                      ('weekday', 'Weekday'),
                      ('weekend', 'Weekend'),
                    ],
                    selected: _schedule,
                    onSelected: (v) => setState(() => _schedule = v),
                  ),
                  const SizedBox(height: 16),

                  _FieldLabel('Shift'),
                  _SegmentRow(
                    options: const [
                      ('morning', 'Morning'),
                      ('afternoon', 'Afternoon'),
                      ('evening', 'Evening'),
                    ],
                    selected: _shift,
                    onSelected: (v) => setState(() => _shift = v),
                  ),
                  const SizedBox(height: 16),

                  _FieldLabel('Room (optional)'),
                  _TextField(
                    controller: _roomCtrl,
                    hint: 'e.g. Room 201, Lab 3',
                  ),
                  const SizedBox(height: 28),

                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: FilledButton(
                      onPressed: _saving ? null : _save,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primaryNavy,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      child: _saving
                          ? const SizedBox(
                              width: 20, height: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white))
                          : Text('Create Term',
                              style: AppTextStyles.bodyMedium.copyWith(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

// ── Class term course form sheet (add/edit a course in the curriculum) ──────

class _ClassTermCourseFormSheet extends ConsumerStatefulWidget {
  const _ClassTermCourseFormSheet({
    required this.classTermId,
    required this.classFacultyId,
    required this.classMajorId,
    required this.existing,
    required this.onSaved,
  });
  final String classTermId;
  // The class's own faculty/major — courses offered here are scoped to match,
  // since a class's whole curriculum should belong to the major it was
  // created for (e.g. a Software Engineering class shouldn't pull in courses
  // tagged under a different faculty/major).
  final String? classFacultyId;
  final String? classMajorId;
  final AdminClassTermCourse? existing;
  final VoidCallback onSaved;

  @override
  ConsumerState<_ClassTermCourseFormSheet> createState() => _ClassTermCourseFormSheetState();
}

class _ClassTermCourseFormSheetState extends ConsumerState<_ClassTermCourseFormSheet> {
  String? _courseId;
  String? _teacherId;
  bool _saving = false;

  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    if (e != null) {
      _courseId = e.courseId;
      _teacherId = e.teacherId;
    }
  }

  Future<void> _save() async {
    if (!_isEdit && _courseId == null) {
      _snack('Please select a course'); return;
    }
    setState(() => _saving = true);
    try {
      final svc = ref.read(adminServiceProvider);
      if (_isEdit) {
        await svc.updateClassTermCourse(
          classTermCourseId: widget.existing!.id,
          teacherId: _teacherId,
        );
      } else {
        await svc.addCourseToClassTerm(
          classTermId: widget.classTermId,
          courseId: _courseId!,
          teacherId: _teacherId,
        );
      }
      widget.onSaved();
      if (mounted) {
        showSuccessToast(context, _isEdit ? 'Course updated.' : 'Course added.');
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _saving = false);
        _snack('Error: $e');
      }
    }
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final allCourses = ref.watch(adminCoursesProvider).valueOrNull ?? [];
    final allTeachers = ref.watch(adminTeachersProvider).valueOrNull ?? [];
    final allClassTerms = ref.watch(adminClassTermsProvider).valueOrNull ?? [];

    final addedCourseIds = allClassTerms.any((t) => t.id == widget.classTermId)
        ? allClassTerms
            .firstWhere((t) => t.id == widget.classTermId)
            .courses
            .map((c) => c.courseId)
            .toSet()
        : <String>{};

    // Scope course choices to the class's own major (or faculty, if the
    // class has no major set) so a class's curriculum stays within the
    // program it was created for.
    final sortedCourses = allCourses.where((c) {
      if (addedCourseIds.contains(c.courseId) && widget.existing?.courseId != c.courseId) {
        return false;
      }
      if (widget.classMajorId != null) return c.majorId == widget.classMajorId;
      if (widget.classFacultyId != null) return c.facultyId == widget.classFacultyId;
      return true;
    }).toList()
      ..sort((a, b) => a.name.compareTo(b.name));
    final sortedTeachers = allTeachers.toList()..sort((a, b) => a.fullName.compareTo(b.fullName));

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36, height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                    color: AppColors.border, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            Text(_isEdit ? 'Edit Course' : 'Add Course', style: AppTextStyles.h2),
            const SizedBox(height: 16),
            if (!_isEdit) ...[
              _FieldLabel('Course *'),
              _DropField<String>(
                value: _courseId,
                hint: sortedCourses.isEmpty ? 'No matching courses' : 'Select course',
                items: sortedCourses
                    .map((c) => DropdownMenuItem(
                        value: c.courseId,
                        child: Text('${c.code} — ${c.name}', overflow: TextOverflow.ellipsis)))
                    .toList(),
                onChanged: (v) => setState(() => _courseId = v),
              ),
              if (sortedCourses.isEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  'No courses found for this class\'s major/faculty. '
                  'Add one in Course Management first, or change the class\'s major.',
                  style: AppTextStyles.caption.copyWith(color: AppColors.statusRed),
                ),
              ],
              const SizedBox(height: 16),
            ] else ...[
              _FieldLabel('Course'),
              Text('${widget.existing!.courseCode} — ${widget.existing!.courseName}',
                  style: AppTextStyles.bodyMedium),
              const SizedBox(height: 16),
            ],
            _FieldLabel('Teacher (optional)'),
            _DropField<String>(
              value: _teacherId,
              hint: 'Unassigned',
              items: [
                const DropdownMenuItem(value: null, child: Text('— Unassigned')),
                ...sortedTeachers.map((t) => DropdownMenuItem(
                    value: t.id,
                    child: Text(t.fullName, overflow: TextOverflow.ellipsis))),
              ],
              onChanged: (v) => setState(() => _teacherId = v),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton(
                onPressed: _saving ? null : _save,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primaryNavy,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: _saving
                    ? const SizedBox(
                        width: 20, height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : Text(_isEdit ? 'Save Changes' : 'Add Course',
                        style: AppTextStyles.bodyMedium.copyWith(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Students sheet ────────────────────────────────────────────────────────────

class _StudentsSheet extends StatefulWidget {
  const _StudentsSheet({required this.term});
  final AdminClassTerm term;

  @override
  State<_StudentsSheet> createState() => _StudentsSheetState();
}

class _StudentsSheetState extends State<_StudentsSheet> {
  final Set<String> _dropping = {};

  Future<void> _dropStudent(CourseEnrollmentEntry entry, WidgetRef ref) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Drop Student?'),
        content: Text(
          'Remove ${entry.studentName} from ${widget.term.classCode}?',
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: TextButton.styleFrom(foregroundColor: AppColors.statusRed),
              child: const Text('Drop')),
        ],
      ),
    );
    if (confirm != true) return;

    setState(() => _dropping.add(entry.enrollmentId));
    try {
      await ref.read(adminServiceProvider).dropEnrollment(entry.enrollmentId);
      ref.invalidate(classTermEnrollmentsProvider(widget.term.id));
      ref.invalidate(adminClassTermsProvider);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error: $e'),
          backgroundColor: AppColors.statusRed,
        ));
      }
    } finally {
      if (mounted) setState(() => _dropping.remove(entry.enrollmentId));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final enrollmentsAsync = ref.watch(classTermEnrollmentsProvider(widget.term.id));

        return DraggableScrollableSheet(
          initialChildSize: 0.65,
          maxChildSize: 0.9,
          minChildSize: 0.4,
          expand: false,
          builder: (_, sc) => Container(
            decoration: BoxDecoration(
              color: AppColors.bgCard,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(children: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: 10),
                width: 36, height: 4,
                decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2)),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 12, 12),
                child: Row(children: [
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(widget.term.classCode, style: AppTextStyles.h2),
                      Text('${widget.term.semesterName ?? ''} · ${widget.term.shiftLabel} · Year ${widget.term.yearLevel}',
                          style: AppTextStyles.caption
                              .copyWith(color: AppColors.textSecondary)),
                    ]),
                  ),
                  TextButton.icon(
                    onPressed: () => showEnrollStudentSheet(
                      context,
                      classTermId: widget.term.id,
                      onEnrolled: () {
                        ref.invalidate(classTermEnrollmentsProvider(widget.term.id));
                        ref.invalidate(adminClassTermsProvider);
                      },
                    ),
                    icon: Icon(Icons.person_add_outlined, size: 18, color: AppColors.primaryBlue),
                    label: Text('Add', style: AppTextStyles.caption.copyWith(color: AppColors.primaryBlue, fontWeight: FontWeight.w600)),
                  ),
                ]),
              ),
              const Divider(height: 0),
              Expanded(
                child: enrollmentsAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(child: Text('Error: $e')),
                  data: (students) {
                    if (students.isEmpty) {
                      return Center(
                        child: Column(mainAxisSize: MainAxisSize.min, children: [
                          Icon(Icons.people_outline,
                              size: 40, color: AppColors.textSecondary),
                          const SizedBox(height: 8),
                          Text('No students enrolled',
                              style: AppTextStyles.bodyMedium),
                        ]),
                      );
                    }
                    return ListView.separated(
                      controller: sc,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: students.length,
                      separatorBuilder: (context, index) =>
                          const Divider(height: 0, indent: 16, endIndent: 16),
                      itemBuilder: (_, i) {
                        final s = students[i];
                        final isDropping = _dropping.contains(s.enrollmentId);

                        return ListTile(
                          dense: true,
                          leading: CircleAvatar(
                            radius: 16,
                            backgroundColor: AppColors.primaryNavy.withValues(alpha: 0.1),
                            child: Text(s.initials,
                                style: AppTextStyles.caption.copyWith(
                                    color: AppColors.primaryNavy,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 11)),
                          ),
                          title: Text(s.studentName,
                              style: AppTextStyles.body.copyWith(fontSize: 13)),
                          subtitle: Text(s.studentCode,
                              style: AppTextStyles.caption),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppColors.statusGreen.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(s.status.toUpperCase(),
                                    style: AppTextStyles.label.copyWith(
                                        color: AppColors.statusGreen, fontSize: 9)),
                              ),
                              const SizedBox(width: 8),
                              if (isDropping)
                                const SizedBox(
                                  width: 20, height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              else
                                IconButton(
                                  icon: Icon(Icons.person_remove_outlined, color: AppColors.statusRed, size: 18),
                                  onPressed: () => _dropStudent(s, ref),
                                  tooltip: 'Drop Student',
                                ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ]),
          ),
        );
      },
    );
  }
}

// ── Small helpers ─────────────────────────────────────────────────────────────

class _StatChip extends StatelessWidget {
  const _StatChip(
      {required this.label, required this.value, required this.color});
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(children: [
        Text(value,
            style: AppTextStyles.bodyMedium
                .copyWith(color: color, fontWeight: FontWeight.w700)),
        Text(label,
            style: AppTextStyles.caption
                .copyWith(fontSize: 10, color: AppColors.textSecondary)),
      ]),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(label,
          style: AppTextStyles.label
              .copyWith(color: color, fontSize: 9, letterSpacing: 0)),
    );
  }
}

class _IconBtn extends StatelessWidget {
  const _IconBtn(
      {required this.icon, required this.color, required this.onTap});
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(icon, size: 14, color: color),
      ),
    );
  }
}

class _Drop<T> extends StatelessWidget {
  const _Drop({
    required this.value,
    required this.hint,
    required this.items,
    required this.onChanged,
  });
  final T? value;
  final String hint;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: AppColors.bgInput,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isExpanded: true,
          hint: Text(hint,
              style: AppTextStyles.caption.copyWith(fontSize: 11),
              overflow: TextOverflow.ellipsis),
          style: AppTextStyles.body.copyWith(fontSize: 12),
          items: [
            DropdownMenuItem<T>(
                value: null,
                child: Text(hint,
                    style: AppTextStyles.body.copyWith(fontSize: 12),
                    overflow: TextOverflow.ellipsis)),
            ...items,
          ],
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(text,
          style: AppTextStyles.caption
              .copyWith(color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
    );
  }
}

class _DropField<T> extends StatelessWidget {
  const _DropField({
    required this.value,
    required this.hint,
    required this.items,
    required this.onChanged,
  });
  final T? value;
  final String hint;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.bgInput,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isExpanded: true,
          hint: Text(hint, style: AppTextStyles.caption),
          style: AppTextStyles.body.copyWith(fontSize: 14),
          items: items,
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _TextField extends StatelessWidget {
  const _TextField({
    required this.controller,
    required this.hint,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.none,
  });
  final TextEditingController controller;
  final String hint;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: AppColors.bgInput,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        textCapitalization: textCapitalization,
        style: AppTextStyles.body.copyWith(fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: AppTextStyles.caption,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          isDense: true,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
        ),
      ),
    );
  }
}

class _SegmentRow extends StatelessWidget {
  const _SegmentRow({
    required this.options,
    required this.selected,
    required this.onSelected,
  });
  final List<(String, String)> options;
  final String selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: options.map((o) {
        final isActive = o.$1 == selected;
        return Expanded(
          child: GestureDetector(
            onTap: () => onSelected(o.$1),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              margin: const EdgeInsets.only(right: 6),
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: isActive
                    ? AppColors.primaryNavy
                    : AppColors.bgInput,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isActive ? AppColors.primaryNavy : AppColors.border,
                ),
              ),
              child: Text(
                o.$2,
                textAlign: TextAlign.center,
                style: AppTextStyles.caption.copyWith(
                  color: isActive ? Colors.white : AppColors.textSecondary,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _DatePickerField extends StatelessWidget {
  const _DatePickerField({
    required this.date,
    required this.hint,
    required this.onPick,
    this.onClear,
  });
  final DateTime? date;
  final String hint;
  final VoidCallback onPick;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    final fmtDate = date != null ? DateFormat('MMM d, yyyy').format(date!) : hint;
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: AppColors.bgInput,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: onPick,
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    Icon(Icons.calendar_month_outlined, size: 16, color: AppColors.textSecondary),
                    const SizedBox(width: 8),
                    Text(
                      fmtDate,
                      style: AppTextStyles.body.copyWith(
                        fontSize: 14,
                        color: date != null ? AppColors.textPrimary : AppColors.textLabel,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (date != null && onClear != null)
            IconButton(
              icon: Icon(Icons.clear, size: 16, color: AppColors.textSecondary),
              onPressed: onClear,
            ),
        ],
      ),
    );
  }
}
