import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/providers/admin_providers.dart';
import '../../../core/services/admin_service.dart';
import '../../../shared/widgets/app_toast.dart';

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
  String? _courseFilter;   // courseId
  String? _facultyFilter;  // facultyId
  String _search = '';

  List<AdminEnrollmentRecord> _applyFilters(List<AdminEnrollmentRecord> all) {
    return all.where((s) {
      if (_semesterFilter != null && s.semesterId != _semesterFilter) return false;
      if (_courseFilter != null && s.courseId != _courseFilter) return false;
      if (_facultyFilter != null && s.facultyId != _facultyFilter) return false;
      if (_search.isNotEmpty) {
        final q = _search.toLowerCase();
        if (!s.courseName.toLowerCase().contains(q) &&
            !s.courseCode.toLowerCase().contains(q) &&
            !s.classCode.toLowerCase().contains(q)) return false;
      }
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final classesAsync = ref.watch(adminEnrollmentProvider);
    final allSemesters = ref.watch(adminSemestersProvider).valueOrNull ?? [];
    final allCourses = ref.watch(adminCoursesProvider).valueOrNull ?? [];
    final allFaculties = ref.watch(adminFacultiesProvider).valueOrNull ?? [];

    return classesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.error_outline, color: AppColors.statusRed, size: 40),
          const SizedBox(height: 8),
          Text('Could not load classes', style: AppTextStyles.body),
          TextButton(
            onPressed: () => ref.invalidate(adminEnrollmentProvider),
            child: const Text('Retry'),
          ),
        ]),
      ),
      data: (all) {
        final filtered = _applyFilters(all);
        final totalEnrolled = filtered.fold(0, (s, r) => s + r.enrolled);
        final totalMax = filtered.fold(0, (s, r) => s + r.maxStudents);
        final fullCount = filtered.where((r) => r.pct >= 1.0).length;

        return Stack(children: [
          Column(children: [
            _buildFilters(allSemesters, allCourses, allFaculties, all),
            _buildFacultyCounts(allFaculties, all),
            _buildStats(filtered.length, totalEnrolled, totalMax - totalEnrolled, fullCount),
            Expanded(child: _buildList(context, filtered)),
          ]),
          Positioned(
            right: 16,
            bottom: 16,
            child: FloatingActionButton.extended(
              onPressed: () => _showClassSheet(context, null),
              backgroundColor: AppColors.primaryNavy,
              icon: const Icon(Icons.add, color: Colors.white),
              label: Text('Add Class',
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
    List<AdminCourse> courses,
    List<AdminFaculty> faculties,
    List<AdminEnrollmentRecord> all,
  ) {
    final sortedSemesters = semesters.toList()
      ..sort((a, b) {
        final y = b.academicYear.compareTo(a.academicYear);
        return y != 0 ? y : a.name.compareTo(b.name);
      });

    final sortedFaculties = faculties.toList()
      ..sort((a, b) => a.name.compareTo(b.name));

    // Only courses that have classes, narrowed to the selected faculty if any
    final courseIdsInClasses = all.map((s) => s.courseId).toSet();
    final filteredCourses = courses
        .where((c) => courseIdsInClasses.contains(c.courseId))
        .where((c) => _facultyFilter == null || c.facultyId == _facultyFilter)
        .toList()
      ..sort((a, b) => a.name.compareTo(b.name));

    return Container(
      color: Colors.white,
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
              hintText: 'Search course or class code…',
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
                _courseFilter = null;
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
                      child: Text(s.name, overflow: TextOverflow.ellipsis)))
                  .toList(),
              onChanged: (v) => setState(() => _semesterFilter = v),
            ),
          ),
        ]),
        const SizedBox(height: 8),
        Row(children: [
          Expanded(
            child: _Drop<String>(
              value: _courseFilter,
              hint: 'All Courses',
              items: filteredCourses
                  .map((c) => DropdownMenuItem(
                      value: c.courseId,
                      child: Text(c.name, overflow: TextOverflow.ellipsis)))
                  .toList(),
              onChanged: (v) => setState(() => _courseFilter = v),
            ),
          ),
          if (_facultyFilter != null ||
              _semesterFilter != null ||
              _courseFilter != null ||
              _search.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: GestureDetector(
                onTap: () => setState(() {
                  _facultyFilter = null;
                  _semesterFilter = null;
                  _courseFilter = null;
                  _search = '';
                }),
                child: Container(
                  padding: const EdgeInsets.all(6),
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

  Widget _buildFacultyCounts(List<AdminFaculty> faculties, List<AdminEnrollmentRecord> all) {
    if (faculties.isEmpty || all.isEmpty) return const SizedBox.shrink();

    final counts = <String, int>{};
    for (final s in all) {
      final name = s.facultyName ?? 'Unassigned';
      counts[name] = (counts[name] ?? 0) + 1;
    }
    if (counts.isEmpty) return const SizedBox.shrink();

    final entries = counts.entries.toList()..sort((a, b) => b.value.compareTo(a.value));

    return Container(
      color: Colors.white,
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
        _StatChip(label: 'Classes', value: '$total', color: AppColors.primaryNavy),
        _StatChip(label: 'Enrolled', value: '$enrolled', color: AppColors.primaryBlue),
        _StatChip(label: 'Available', value: '$available', color: AppColors.statusGreen),
        _StatChip(label: 'Full', value: '$full', color: AppColors.statusRed),
      ]),
    );
  }

  // ── list ───────────────────────────────────────────────────────────────────

  Widget _buildList(BuildContext context, List<AdminEnrollmentRecord> classes) {
    if (classes.isEmpty) {
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

    // Group by course
    final grouped = <String, List<AdminEnrollmentRecord>>{};
    final courseOrder = <String>[];
    for (final s in classes) {
      if (!grouped.containsKey(s.courseId)) {
        grouped[s.courseId] = [];
        courseOrder.add(s.courseId);
      }
      grouped[s.courseId]!.add(s);
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
      itemCount: courseOrder.length,
      itemBuilder: (_, i) {
        final courseId = courseOrder[i];
        final courseClasses = grouped[courseId]!;
        final first = courseClasses.first;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 6),
              child: Row(children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.primaryNavy.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(first.courseCode,
                      style: AppTextStyles.label.copyWith(
                          color: AppColors.primaryNavy, fontWeight: FontWeight.w700)),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(first.courseName,
                      style: AppTextStyles.bodyMedium.copyWith(fontSize: 13),
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                ),
                Text('${courseClasses.length} class${courseClasses.length > 1 ? 'es' : ''}',
                    style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
              ]),
            ),
            ...courseClasses.map((s) => _ClassCard(
              cls: s,
              onEdit: () => _showClassSheet(context, s),
              onDelete: () => _confirmDelete(context, s),
              onStudents: () => _showStudentsSheet(context, s),
            )),
          ],
        );
      },
    );
  }

  // ── actions ────────────────────────────────────────────────────────────────

  void _showClassSheet(BuildContext context, AdminEnrollmentRecord? existing) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ClassFormSheet(
        existing: existing,
        onSaved: () {
          ref.invalidate(adminEnrollmentProvider);
          ref.invalidate(adminCoursesProvider);
        },
      ),
    );
  }

  void _showStudentsSheet(BuildContext context, AdminEnrollmentRecord cls) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _StudentsSheet(cls: cls),
    );
  }

  void _confirmDelete(BuildContext context, AdminEnrollmentRecord cls) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Class'),
        content: Text(
            'Delete class ${cls.courseCode}-${cls.classCode}? '
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
                    .deleteClass(cls.classId);
                ref.invalidate(adminEnrollmentProvider);
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

// ── Class card ────────────────────────────────────────────────────────────────

class _ClassCard extends StatelessWidget {
  const _ClassCard({
    required this.cls,
    required this.onEdit,
    required this.onDelete,
    required this.onStudents,
  });
  final AdminEnrollmentRecord cls;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onStudents;

  Color get _shiftColor {
    switch (cls.shift) {
      case 'morning':   return const Color(0xFFF59E0B);
      case 'afternoon': return AppColors.primaryBlue;
      case 'evening':   return const Color(0xFF7C3AED);
      default:          return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final pct = cls.pct;
    final barColor = pct >= 1.0
        ? AppColors.statusRed
        : pct >= 0.8
            ? AppColors.statusAmber
            : AppColors.statusGreen;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Class code badge
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.primaryNavy.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(cls.classCode,
                    style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.primaryNavy, fontSize: 16,
                        fontWeight: FontWeight.w800)),
              ),
            ),
            const SizedBox(width: 10),
            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Shift + schedule + program chips
                  Wrap(spacing: 4, children: [
                    _Chip(label: cls.shiftLabel, color: _shiftColor),
                    _Chip(label: cls.scheduleLabel,
                        color: AppColors.textSecondary),
                    _Chip(label: cls.programLabel,
                        color: cls.programType == 'international'
                            ? AppColors.primaryBlue
                            : AppColors.textLabel),
                  ]),
                  if (cls.semesterName != null) ...[
                    const SizedBox(height: 4),
                    Text(cls.semesterName!,
                        style: AppTextStyles.caption
                            .copyWith(color: AppColors.textSecondary)),
                  ],
                  if (cls.teacherName != null) ...[
                    const SizedBox(height: 2),
                    Row(children: [
                      Icon(Icons.person_outline,
                          size: 12, color: AppColors.textSecondary),
                      const SizedBox(width: 3),
                      Text(cls.teacherName!,
                          style: AppTextStyles.caption
                              .copyWith(color: AppColors.textSecondary)),
                    ]),
                  ],
                  if (cls.room != null) ...[
                    const SizedBox(height: 2),
                    Row(children: [
                      Icon(Icons.room_outlined,
                          size: 12, color: AppColors.textSecondary),
                      const SizedBox(width: 3),
                      Text(cls.room!,
                          style: AppTextStyles.caption
                              .copyWith(color: AppColors.textSecondary)),
                    ]),
                  ],
                ],
              ),
            ),
            // Enrollment + actions
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text('${cls.enrolled}/${cls.maxStudents}',
                  style: AppTextStyles.bodyMedium.copyWith(
                      color: barColor, fontSize: 13)),
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
                _IconBtn(icon: Icons.edit_outlined,
                    color: AppColors.primaryBlue, onTap: onEdit),
                const SizedBox(width: 4),
                _IconBtn(icon: Icons.delete_outline,
                    color: AppColors.statusRed, onTap: onDelete),
              ]),
            ]),
          ]),
        ),
        // Students button
        InkWell(
          onTap: onStudents,
          borderRadius: const BorderRadius.vertical(bottom: Radius.circular(10)),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: Color(0xFFF8FAFF),
              border: Border(top: BorderSide(color: AppColors.border)),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(10)),
            ),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.people_outline,
                  size: 14, color: AppColors.primaryBlue),
              const SizedBox(width: 6),
              Text('View Students',
                  style: AppTextStyles.caption.copyWith(
                      color: AppColors.primaryBlue,
                      fontWeight: FontWeight.w600)),
            ]),
          ),
        ),
      ]),
    );
  }
}

// ── Class form sheet ──────────────────────────────────────────────────────────

class _ClassFormSheet extends ConsumerStatefulWidget {
  const _ClassFormSheet({required this.existing, required this.onSaved});
  final AdminEnrollmentRecord? existing;
  final VoidCallback onSaved;

  @override
  ConsumerState<_ClassFormSheet> createState() => _ClassFormSheetState();
}

class _ClassFormSheetState extends ConsumerState<_ClassFormSheet> {
  final _codeCtrl = TextEditingController();
  final _maxCtrl  = TextEditingController(text: '30');
  final _roomCtrl = TextEditingController();

  String? _facultyId;
  String? _courseId;
  String? _semesterId;
  String? _teacherId;
  String _program  = 'national';
  String _schedule = 'weekday';
  String _shift    = 'morning';
  bool _saving = false;

  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    if (e != null) {
      _facultyId  = e.facultyId;
      _courseId   = e.courseId;
      _semesterId = e.semesterId;
      _teacherId  = e.teacherId;
      _program    = e.programType;
      _schedule   = e.scheduleType;
      _shift      = e.shift;
      _codeCtrl.text = e.classCode;
      _maxCtrl.text  = '${e.maxStudents}';
      _roomCtrl.text = e.room ?? '';
    }
  }

  @override
  void dispose() {
    _codeCtrl.dispose();
    _maxCtrl.dispose();
    _roomCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_courseId == null) {
      _snack('Please select a course'); return;
    }
    if (_semesterId == null) {
      _snack('Please select a semester'); return;
    }
    final code = _codeCtrl.text.trim();
    if (code.isEmpty) {
      _snack('Class code is required'); return;
    }
    final max = int.tryParse(_maxCtrl.text.trim()) ?? 0;
    if (max <= 0) {
      _snack('Max students must be greater than 0'); return;
    }

    setState(() => _saving = true);
    try {
      final svc = ref.read(adminServiceProvider);
      if (_isEdit) {
        await svc.updateClass(
          classId: widget.existing!.classId,
          semesterId: _semesterId!,
          teacherId: _teacherId,
          programType: _program,
          scheduleType: _schedule,
          shift: _shift,
          classCode: code,
          room: _roomCtrl.text.trim().isEmpty ? null : _roomCtrl.text.trim(),
          maxStudents: max,
        );
      } else {
        await svc.createClass(
          courseId: _courseId!,
          semesterId: _semesterId!,
          teacherId: _teacherId,
          programType: _program,
          scheduleType: _schedule,
          shift: _shift,
          classCode: code,
          room: _roomCtrl.text.trim().isEmpty ? null : _roomCtrl.text.trim(),
          maxStudents: max,
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
    final allCourses  = ref.watch(adminCoursesProvider).valueOrNull ?? [];
    final allSemesters = ref.watch(adminSemestersProvider).valueOrNull ?? [];
    final allTeachers  = ref.watch(adminTeachersProvider).valueOrNull ?? [];
    final allFaculties = ref.watch(adminFacultiesProvider).valueOrNull ?? [];

    final sortedSemesters = allSemesters.toList()
      ..sort((a, b) {
        final y = b.academicYear.compareTo(a.academicYear);
        return y != 0 ? y : a.name.compareTo(b.name);
      });

    final sortedFaculties = allFaculties.toList()
      ..sort((a, b) => a.name.compareTo(b.name));

    final sortedCourses = allCourses
        .where((c) => _facultyId == null || c.facultyId == _facultyId)
        .toList()
      ..sort((a, b) => a.name.compareTo(b.name));

    final sortedTeachers = allTeachers.toList()
      ..sort((a, b) => a.fullName.compareTo(b.fullName));

    return Padding(
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom),
      child: DraggableScrollableSheet(
        initialChildSize: 0.85,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        expand: false,
        builder: (_, sc) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(children: [
            // Handle + title
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
                  // Faculty (narrows the course list) + Course
                  if (!_isEdit) ...[
                    _FieldLabel('Faculty'),
                    _DropField<String>(
                      value: _facultyId,
                      hint: 'All Faculties',
                      items: [
                        const DropdownMenuItem(value: null, child: Text('All Faculties')),
                        ...sortedFaculties.map((f) => DropdownMenuItem(
                            value: f.id,
                            child: Text(f.name, overflow: TextOverflow.ellipsis))),
                      ],
                      onChanged: (v) => setState(() {
                        _facultyId = v;
                        _courseId = null;
                      }),
                    ),
                    const SizedBox(height: 16),
                    _FieldLabel('Course *'),
                    _DropField<String>(
                      value: _courseId,
                      hint: 'Select course',
                      items: sortedCourses
                          .map((c) => DropdownMenuItem(
                              value: c.courseId,
                              child: Text(
                                  '${c.code} — ${c.name}',
                                  overflow: TextOverflow.ellipsis)))
                          .toList(),
                      onChanged: (v) => setState(() => _courseId = v),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Semester
                  _FieldLabel('Semester *'),
                  _DropField<String>(
                    value: _semesterId,
                    hint: 'Select semester',
                    items: sortedSemesters
                        .map((s) => DropdownMenuItem(
                            value: s.id,
                            child: Text(
                                '${s.name} (${s.academicYear})',
                                overflow: TextOverflow.ellipsis)))
                        .toList(),
                    onChanged: (v) => setState(() => _semesterId = v),
                  ),
                  const SizedBox(height: 16),

                  // Program
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

                  // Schedule
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

                  // Shift
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

                  // Class code + max students
                  Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _FieldLabel('Class Code *'),
                          _TextField(
                            controller: _codeCtrl,
                            hint: 'e.g. A, B, C',
                            textCapitalization: TextCapitalization.characters,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
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

                  // Teacher
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
                  const SizedBox(height: 16),

                  // Room
                  _FieldLabel('Room (optional)'),
                  _TextField(
                    controller: _roomCtrl,
                    hint: 'e.g. Room 201, Lab 3',
                  ),
                  const SizedBox(height: 28),

                  // Save button
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

// ── Students sheet ────────────────────────────────────────────────────────────

class _StudentsSheet extends ConsumerWidget {
  const _StudentsSheet({required this.cls});
  final AdminEnrollmentRecord cls;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enrollmentsAsync =
        ref.watch(classEnrollmentsProvider(cls.classId));

    return DraggableScrollableSheet(
      initialChildSize: 0.65,
      maxChildSize: 0.9,
      minChildSize: 0.4,
      expand: false,
      builder: (_, sc) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
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
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('${cls.courseCode}-${cls.classCode}',
                  style: AppTextStyles.h2),
              Text('${cls.courseName} · ${cls.shiftLabel} · ${cls.programLabel}',
                  style: AppTextStyles.caption
                      .copyWith(color: AppColors.textSecondary)),
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
                  separatorBuilder: (_, __) =>
                      const Divider(height: 0, indent: 16, endIndent: 16),
                  itemBuilder: (_, i) {
                    final s = students[i];
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
                      trailing: Container(
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
                    );
                  },
                );
              },
            ),
          ),
        ]),
      ),
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
