import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/providers/admin_providers.dart';
import '../../../core/services/admin_service.dart';
import '../../../shared/widgets/app_toast.dart';

// ── File-level helpers ─────────────────────────────────────────────────────────

Color _shiftColor(String shift) {
  switch (shift) {
    case 'morning':   return const Color(0xFFD97706);
    case 'afternoon': return AppColors.primaryBlue;
    case 'evening':   return const Color(0xFF7C3AED);
    default:          return AppColors.primaryNavy;
  }
}

String _shiftLabel(String shift) {
  switch (shift) {
    case 'morning':   return 'Morning';
    case 'afternoon': return 'Afternoon';
    case 'evening':   return 'Evening';
    default:          return shift;
  }
}

const _kScheduleDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

String _fmtTime(TimeOfDay t) =>
    '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

int _parseTimeToMinutes(String hhmm) {
  final parts = hhmm.split(':');
  if (parts.length != 2) return 0;
  final h = int.tryParse(parts[0]) ?? 0;
  final m = int.tryParse(parts[1]) ?? 0;
  return h * 60 + m;
}

// ── Screen ─────────────────────────────────────────────────────────────────────

class CourseDetailScreen extends ConsumerStatefulWidget {
  const CourseDetailScreen({super.key, required this.courseId});
  final String courseId;

  @override
  ConsumerState<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends ConsumerState<CourseDetailScreen> {
  bool _populated = false;
  bool _saving = false;
  bool _hasUnsavedChanges = false;

  final _codeCtrl    = TextEditingController();
  final _nameCtrl    = TextEditingController();
  final _descCtrl    = TextEditingController();
  final _creditsCtrl = TextEditingController();

  String? _facultyId;
  String? _majorId;

  @override
  void initState() {
    super.initState();
    for (final c in [_codeCtrl, _nameCtrl, _descCtrl, _creditsCtrl]) {
      c.addListener(_markDirty);
    }
  }

  void _markDirty() => setState(() => _hasUnsavedChanges = true);

  @override
  void dispose() {
    for (final c in [_codeCtrl, _nameCtrl, _descCtrl, _creditsCtrl]) {
      c.removeListener(_markDirty);
      c.dispose();
    }
    super.dispose();
  }

  void _populate(AdminCourseDetail d) {
    if (_populated) return;
    _populated = true;
    _codeCtrl.text    = d.code;
    _nameCtrl.text    = d.name;
    _descCtrl.text    = d.description ?? '';
    _creditsCtrl.text = '${d.credits}';
    _facultyId        = d.facultyId;
    _majorId          = d.majorId;
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => setState(() => _hasUnsavedChanges = false));
  }

  @override
  Widget build(BuildContext context) {
    final detailAsync  = ref.watch(courseDetailProvider(widget.courseId));
    final faculties    = ref.watch(adminFacultiesProvider).valueOrNull ?? [];
    final allMajors    = ref.watch(adminMajorsProvider).valueOrNull ?? [];
    // Pre-load for class sheet
    ref.watch(adminSemestersProvider);
    ref.watch(adminTeachersProvider);

    detailAsync.whenData((d) { if (d != null) _populate(d); });

    return Scaffold(
      backgroundColor: AppColors.bgPage,
      body: Column(
        children: [
          _buildNavRow(context),
          Expanded(
            child: detailAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.error_outline, color: AppColors.statusRed, size: 40),
                    const SizedBox(height: 8),
                    Text('Could not load course', style: AppTextStyles.bodyMedium),
                    TextButton(
                      onPressed: () => ref.invalidate(courseDetailProvider(widget.courseId)),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
              data: (detail) {
                if (detail == null) {
                  return Center(child: Text('Course not found', style: AppTextStyles.bodyMedium));
                }
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSpacing.screenPadding),
                  child: Column(
                    children: [
                      _buildGeneralSection(faculties, allMajors),
                      const SizedBox(height: 16),
                      _buildClassesSection(),
                      const SizedBox(height: 16),
                      _buildScheduleSection(detail),
                      const SizedBox(height: 16),
                      if (_hasUnsavedChanges) ...[
                        _buildUnsavedBanner(),
                        const SizedBox(height: 16),
                      ],
                      _buildActions(context),
                      const SizedBox(height: 24),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ── Nav ───────────────────────────────────────────────────────────────────

  Widget _buildNavRow(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back, color: AppColors.primaryNavy),
            onPressed: () => context.pop(),
          ),
          Text('Edit Course', style: AppTextStyles.h3.copyWith(color: AppColors.primaryNavy)),
          if (_saving) ...[
            const Spacer(),
            const Padding(
              padding: EdgeInsets.only(right: 16),
              child: SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)),
            ),
          ],
        ],
      ),
    );
  }

  // ── General section ───────────────────────────────────────────────────────

  Widget _buildGeneralSection(List<AdminFaculty> faculties, List<AdminMajor> allMajors) {
    final facultyId = faculties.any((f) => f.id == _facultyId) ? _facultyId : null;
    final filteredMajors = facultyId == null
        ? allMajors
        : allMajors.where((m) => m.facultyId == facultyId).toList();
    final majorId = filteredMajors.any((m) => m.id == _majorId) ? _majorId : null;
    return _Section(
      title: 'General Information',
      children: [
        _LabelField(label: 'Course Code', controller: _codeCtrl),
        const SizedBox(height: 12),
        _LabelField(label: 'Course Name', controller: _nameCtrl),
        const SizedBox(height: 12),
        _LabelField(label: 'Description', controller: _descCtrl, maxLines: 3),
        const SizedBox(height: 12),
        _LabelField(
          label: 'Credits',
          controller: _creditsCtrl,
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 12),
        _LabelIdDropdown<String?>(
          label: 'Faculty',
          value: facultyId,
          hint: 'Select faculty',
          items: faculties
              .map((f) => DropdownMenuItem<String?>(
                    value: f.id,
                    child: Text(f.name, overflow: TextOverflow.ellipsis, style: AppTextStyles.body),
                  ))
              .toList(),
          onChanged: (v) => setState(() {
            _facultyId = v;
            _majorId = null;
            _hasUnsavedChanges = true;
          }),
        ),
        const SizedBox(height: 12),
        _LabelIdDropdown<String?>(
          label: 'Major',
          value: majorId,
          hint: 'Select major',
          items: filteredMajors
              .map((m) => DropdownMenuItem<String?>(
                    value: m.id,
                    child: Text(m.name, overflow: TextOverflow.ellipsis, style: AppTextStyles.body),
                  ))
              .toList(),
          onChanged: (v) => setState(() {
            _majorId = v;
            _hasUnsavedChanges = true;
          }),
        ),
      ],
    );
  }

  // ── Classes card ───────────────────────────────────────────────────────────

  Widget _buildClassesSection() {
    final classesAsync = ref.watch(classesForCourseProvider(widget.courseId));
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
          Row(
            children: [
              Text('Classes', style: AppTextStyles.h3),
              const Spacer(),
              GestureDetector(
                onTap: () => _showClassSheet(context),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add_circle_outline, size: 16, color: AppColors.primaryBlue),
                    const SizedBox(width: 4),
                    Text('Add Class',
                        style: AppTextStyles.caption
                            .copyWith(color: AppColors.primaryBlue, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          classesAsync.when(
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: CircularProgressIndicator(),
              ),
            ),
            error: (e, _) => Text('Could not load classes',
                style: AppTextStyles.caption.copyWith(color: AppColors.statusRed)),
            data: (classes) {
              if (classes.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Column(
                      children: [
                        Icon(Icons.group_work_outlined, size: 40, color: AppColors.textLabel),
                        const SizedBox(height: 8),
                        Text('No classes yet', style: AppTextStyles.bodyMedium),
                        const SizedBox(height: 4),
                        Text(
                          'Add classes to assign shifts, teachers, and capacity.',
                          style: AppTextStyles.caption,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              }
              return Column(
                children: classes
                    .map((s) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _ClassRow(
                            cls: s,
                            onEdit: () => _showClassSheet(context, cls: s),
                          ),
                        ))
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  // ── Weekly schedule card ──────────────────────────────────────────────────

  Widget _buildScheduleSection(AdminCourseDetail detail) {
    final schedule = detail.schedule;
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
          Row(
            children: [
              Text('Weekly Schedule', style: AppTextStyles.h3),
              const Spacer(),
              GestureDetector(
                onTap: () => _showAddSlotSheet(context, schedule),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add_circle_outline, size: 16, color: AppColors.primaryBlue),
                    const SizedBox(width: 4),
                    Text('Add Time Slot',
                        style: AppTextStyles.caption
                            .copyWith(color: AppColors.primaryBlue, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (schedule.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Column(
                  children: [
                    Icon(Icons.schedule_outlined, size: 40, color: AppColors.textLabel),
                    const SizedBox(height: 8),
                    Text('No weekly schedule set', style: AppTextStyles.bodyMedium),
                    const SizedBox(height: 4),
                    Text(
                      'Add time slots so students and teachers see this on their timetable.',
                      style: AppTextStyles.caption,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          else
            Column(
              children: List.generate(schedule.length, (i) {
                final slot = schedule[i];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _ScheduleSlotRow(
                    day: slot['day'] as String? ?? '',
                    start: slot['start'] as String? ?? '',
                    end: slot['end'] as String? ?? '',
                    room: slot['room'] as String?,
                    onDelete: () => _deleteScheduleSlot(schedule, i),
                  ),
                );
              }),
            ),
        ],
      ),
    );
  }

  Future<void> _showAddSlotSheet(
      BuildContext context, List<Map<String, dynamic>> schedule) async {
    String day = 'Mon';
    TimeOfDay? start;
    TimeOfDay? end;
    final roomCtrl = TextEditingController();
    bool saving = false;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) => Padding(
          padding: EdgeInsets.fromLTRB(16, 20, 16, MediaQuery.of(ctx).viewInsets.bottom + 24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Add Time Slot',
                    style: AppTextStyles.h3.copyWith(color: AppColors.primaryNavy)),
                const SizedBox(height: 16),
                Text('Day',
                    style: AppTextStyles.caption
                        .copyWith(fontSize: 11, color: AppColors.textSecondary)),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _kScheduleDays.map((d) {
                    final selected = day == d;
                    return GestureDetector(
                      onTap: () => setSheet(() => day = d),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: selected ? AppColors.primaryNavy : Colors.transparent,
                          borderRadius: BorderRadius.circular(AppSpacing.chipRadius),
                          border: Border.all(
                              color: selected ? AppColors.primaryNavy : AppColors.border),
                        ),
                        child: Text(d,
                            style: AppTextStyles.caption.copyWith(
                                color: selected ? Colors.white : AppColors.textSecondary,
                                fontWeight: selected ? FontWeight.w600 : FontWeight.normal)),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(
                    child: _TimePickerField(
                      label: 'Start Time',
                      time: start,
                      onPick: () async {
                        final t = await showTimePicker(
                          context: ctx,
                          initialTime: start ?? const TimeOfDay(hour: 8, minute: 0),
                        );
                        if (t != null) setSheet(() => start = t);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _TimePickerField(
                      label: 'End Time',
                      time: end,
                      onPick: () async {
                        final t = await showTimePicker(
                          context: ctx,
                          initialTime: end ?? const TimeOfDay(hour: 9, minute: 30),
                        );
                        if (t != null) setSheet(() => end = t);
                      },
                    ),
                  ),
                ]),
                const SizedBox(height: 12),
                _SheetField(label: 'Room', controller: roomCtrl, hint: 'e.g. A101 (optional)'),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryNavy,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: saving
                        ? null
                        : () async {
                            if (start == null || end == null) {
                              ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(
                                  content: Text('Please select start and end time')));
                              return;
                            }
                            final startMin = start!.hour * 60 + start!.minute;
                            final endMin = end!.hour * 60 + end!.minute;
                            if (endMin <= startMin) {
                              ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(
                                  content: Text('End time must be after start time')));
                              return;
                            }
                            final overlap = schedule.any((s) {
                              if (s['day'] != day) return false;
                              final sStart = _parseTimeToMinutes(s['start'] as String? ?? '');
                              final sEnd = _parseTimeToMinutes(s['end'] as String? ?? '');
                              return startMin < sEnd && endMin > sStart;
                            });
                            if (overlap) {
                              ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(
                                  content:
                                      Text('This overlaps with an existing slot on the same day')));
                              return;
                            }
                            setSheet(() => saving = true);
                            final newSlot = {
                              'day': day,
                              'start': _fmtTime(start!),
                              'end': _fmtTime(end!),
                              if (roomCtrl.text.trim().isNotEmpty) 'room': roomCtrl.text.trim(),
                            };
                            try {
                              await ref.read(adminServiceProvider).updateCourseSchedule(
                                    courseId: widget.courseId,
                                    schedule: [...schedule, newSlot],
                                  );
                              ref.invalidate(courseDetailProvider(widget.courseId));
                              if (ctx.mounted) Navigator.pop(ctx);
                              if (mounted) showSuccessToast(context, 'Time slot added.');
                            } catch (e) {
                              setSheet(() => saving = false);
                              if (ctx.mounted) {
                                ScaffoldMessenger.of(ctx).showSnackBar(
                                  SnackBar(
                                      content: Text('Error: $e'),
                                      backgroundColor: AppColors.statusRed),
                                );
                              }
                            }
                          },
                    child: saving
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Text('Add Slot'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    roomCtrl.dispose();
  }

  Future<void> _deleteScheduleSlot(List<Map<String, dynamic>> schedule, int index) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Remove Time Slot?'),
        content: const Text(
            'This slot will no longer appear on student and teacher timetables.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(c, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.statusRed),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (confirm != true || !mounted) return;
    final updated = [...schedule]..removeAt(index);
    try {
      await ref
          .read(adminServiceProvider)
          .updateCourseSchedule(courseId: widget.courseId, schedule: updated);
      ref.invalidate(courseDetailProvider(widget.courseId));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.statusRed),
        );
      }
    }
  }

  // ── Class sheet ────────────────────────────────────────────────────────────

  Future<void> _showClassSheet(BuildContext context, {AdminClass? cls}) async {
    final semesters = ref.read(adminSemestersProvider).valueOrNull ?? [];
    final teachers  = ref.read(adminTeachersProvider).valueOrNull ?? [];
    final isEdit    = cls != null;

    String? semId       = cls?.semesterId;
    String programType  = cls?.programType  ?? 'national';
    String scheduleType = cls?.scheduleType ?? 'weekday';
    String shift        = cls?.shift        ?? 'morning';
    String? teacherId   = cls?.teacherId;
    final codeCtrl      = TextEditingController(text: cls?.classCode ?? 'A');
    final roomCtrl      = TextEditingController(text: cls?.room ?? '');
    final maxCtrl       = TextEditingController(text: '${cls?.maxStudents ?? 30}');
    bool saving         = false;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) => Padding(
          padding: EdgeInsets.fromLTRB(16, 20, 16, MediaQuery.of(ctx).viewInsets.bottom + 24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(isEdit ? 'Edit Class' : 'New Class',
                    style: AppTextStyles.h3.copyWith(color: AppColors.primaryNavy)),
                const SizedBox(height: 16),

                // Program type chips
                Text('Program',
                    style: AppTextStyles.caption
                        .copyWith(fontSize: 11, color: AppColors.textSecondary)),
                const SizedBox(height: 6),
                Row(
                  children: [
                    ('national',       'National',       const Color(0xFF2E7D32)),
                    ('international',  'International',  AppColors.primaryBlue),
                  ].map(((String, String, Color) opt) {
                    final selected = programType == opt.$1;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () => setSheet(() => programType = opt.$1),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: selected ? opt.$3 : Colors.transparent,
                            borderRadius: BorderRadius.circular(AppSpacing.chipRadius),
                            border: Border.all(color: selected ? opt.$3 : AppColors.border),
                          ),
                          child: Text(opt.$2,
                              style: AppTextStyles.caption.copyWith(
                                  color: selected ? Colors.white : AppColors.textSecondary,
                                  fontWeight: selected ? FontWeight.w600 : FontWeight.normal)),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),

                // Schedule type chips
                Text('Schedule',
                    style: AppTextStyles.caption
                        .copyWith(fontSize: 11, color: AppColors.textSecondary)),
                const SizedBox(height: 6),
                Row(
                  children: [
                    ('weekday', 'Weekday', AppColors.primaryNavy),
                    ('weekend', 'Weekend', const Color(0xFFD97706)),
                  ].map(((String, String, Color) opt) {
                    final selected = scheduleType == opt.$1;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () => setSheet(() => scheduleType = opt.$1),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: selected ? opt.$3 : Colors.transparent,
                            borderRadius: BorderRadius.circular(AppSpacing.chipRadius),
                            border: Border.all(color: selected ? opt.$3 : AppColors.border),
                          ),
                          child: Text(opt.$2,
                              style: AppTextStyles.caption.copyWith(
                                  color: selected ? Colors.white : AppColors.textSecondary,
                                  fontWeight: selected ? FontWeight.w600 : FontWeight.normal)),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),

                // Shift chips
                Text('Shift',
                    style: AppTextStyles.caption
                        .copyWith(fontSize: 11, color: AppColors.textSecondary)),
                const SizedBox(height: 6),
                Row(
                  children: ['morning', 'afternoon', 'evening'].map((s) {
                    final selected = shift == s;
                    final color = _shiftColor(s);
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () => setSheet(() => shift = s),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: selected ? color : Colors.transparent,
                            borderRadius: BorderRadius.circular(AppSpacing.chipRadius),
                            border: Border.all(
                                color: selected ? color : AppColors.border),
                          ),
                          child: Text(_shiftLabel(s),
                              style: AppTextStyles.caption.copyWith(
                                  color: selected ? Colors.white : AppColors.textSecondary,
                                  fontWeight: selected ? FontWeight.w600 : FontWeight.normal)),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),

                Row(children: [
                  Expanded(
                    child: _SheetField(
                        label: 'Class Code *', controller: codeCtrl, hint: 'A'),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _SheetField(
                        label: 'Max Students *',
                        controller: maxCtrl,
                        hint: '30',
                        keyboardType: TextInputType.number),
                  ),
                ]),
                const SizedBox(height: 12),

                _SheetDropdown<String?>(
                  label: 'Semester *',
                  value: semesters.any((s) => s.id == semId) ? semId : null,
                  hint: 'Select semester',
                  items: semesters
                      .map((s) => DropdownMenuItem<String?>(
                            value: s.id,
                            child: Text('${s.name} (${s.academicYear})',
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.body),
                          ))
                      .toList(),
                  onChanged: (v) => setSheet(() => semId = v),
                ),
                const SizedBox(height: 12),

                _SheetDropdown<String?>(
                  label: 'Teacher',
                  value: teachers.any((t) => t.id == teacherId) ? teacherId : null,
                  hint: 'Select teacher (optional)',
                  items: teachers
                      .map((t) => DropdownMenuItem<String?>(
                            value: t.id,
                            child: Text('${t.fullName} (${t.employeeCode})',
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.body),
                          ))
                      .toList(),
                  onChanged: (v) => setSheet(() => teacherId = v),
                ),
                const SizedBox(height: 12),

                _SheetField(label: 'Room', controller: roomCtrl, hint: 'e.g. Room 101 (optional)'),
                const SizedBox(height: 20),

                Row(children: [
                  if (isEdit) ...[
                    Expanded(
                      child: OutlinedButton(
                        onPressed: saving ? null : () => _deleteClass(ctx, cls),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.statusRed,
                          side: BorderSide(color: AppColors.statusRed),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text('Delete'),
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryNavy,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: saving
                          ? null
                          : () async {
                              final code = codeCtrl.text.trim().toUpperCase();
                              final max  = int.tryParse(maxCtrl.text.trim()) ?? 30;
                              if (code.isEmpty || semId == null) {
                                ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(
                                    content: Text('Class code and semester are required')));
                                return;
                              }
                              setSheet(() => saving = true);
                              try {
                                if (isEdit) {
                                  await ref.read(adminServiceProvider).updateClass(
                                    classId:      cls.id,
                                    semesterId:   semId!,
                                    teacherId:    teacherId,
                                    programType:  programType,
                                    scheduleType: scheduleType,
                                    shift:        shift,
                                    classCode:    code,
                                    room:         roomCtrl.text.trim(),
                                    maxStudents:  max,
                                  );
                                } else {
                                  await ref.read(adminServiceProvider).createClass(
                                    courseId:     widget.courseId,
                                    semesterId:   semId!,
                                    teacherId:    teacherId,
                                    programType:  programType,
                                    scheduleType: scheduleType,
                                    shift:        shift,
                                    classCode:    code,
                                    room:         roomCtrl.text.trim(),
                                    maxStudents:  max,
                                  );
                                }
                                ref.invalidate(classesForCourseProvider(widget.courseId));
                                if (ctx.mounted) Navigator.pop(ctx);
                                if (mounted) {
                                  showSuccessToast(
                                      context, isEdit ? 'Class updated.' : 'Class created.');
                                }
                              } catch (e) {
                                setSheet(() => saving = false);
                                if (ctx.mounted) {
                                  final msg = e.toString().contains('unique')
                                      ? 'A class with that combination already exists.'
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
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : Text(isEdit ? 'Update Class' : 'Create Class'),
                    ),
                  ),
                ]),
              ],
            ),
          ),
        ),
      ),
    );

    codeCtrl.dispose();
    roomCtrl.dispose();
    maxCtrl.dispose();
  }

  Future<void> _deleteClass(BuildContext ctx, AdminClass cls) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Delete Class?'),
        content: Text(
          'Delete ${cls.shiftLabel} Class ${cls.classCode}? '
          'Enrolled students will lose their enrollment in this class.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(c, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.statusRed),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirm != true || !mounted) return;
    try {
      await ref.read(adminServiceProvider).deleteClass(cls.id);
      ref.invalidate(classesForCourseProvider(widget.courseId));
      if (ctx.mounted) Navigator.pop(ctx);
    } catch (e) {
      if (ctx.mounted) {
        ScaffoldMessenger.of(ctx).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.statusRed),
        );
      }
    }
  }

  // ── Unsaved banner + actions ───────────────────────────────────────────────

  Widget _buildUnsavedBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF9C4),
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(color: const Color(0xFFF9A825)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, size: 16, color: Color(0xFFF9A825)),
          const SizedBox(width: 8),
          Expanded(
            child: Text('You have unsaved changes.',
                style: AppTextStyles.caption.copyWith(color: const Color(0xFF5D4037))),
          ),
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: _saving ? null : () => _save(context),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 50),
            backgroundColor: AppColors.primaryNavy,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSpacing.buttonRadius)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.save_outlined, size: 18, color: Colors.white),
              const SizedBox(width: 8),
              Text('Save Changes', style: AppTextStyles.button),
            ],
          ),
        ),
        const SizedBox(height: 10),
        OutlinedButton(
          onPressed: _saving ? null : () => _showDeleteDialog(context),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(double.infinity, 50),
            side: BorderSide(color: AppColors.statusRed),
            foregroundColor: AppColors.statusRed,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSpacing.buttonRadius)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.delete_outline, size: 18),
              const SizedBox(width: 8),
              Text('Delete Course',
                  style: AppTextStyles.button.copyWith(color: AppColors.statusRed)),
            ],
          ),
        ),
      ],
    );
  }

  // ── Save / delete course ──────────────────────────────────────────────────

  Future<void> _save(BuildContext context) async {
    final code    = _codeCtrl.text.trim();
    final name    = _nameCtrl.text.trim();
    final credits = int.tryParse(_creditsCtrl.text.trim()) ?? 3;

    if (code.isEmpty || name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Course code and name are required')),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      await ref.read(adminServiceProvider).updateCourse(
        courseId:    widget.courseId,
        code:        code,
        name:        name,
        description: _descCtrl.text,
        credits:     credits,
        majorId: _majorId,
      );
      ref.invalidate(courseDetailProvider(widget.courseId));
      ref.invalidate(adminCoursesProvider);
      setState(() {
        _saving = false;
        _hasUnsavedChanges = false;
        _populated = false;
      });
      if (context.mounted) {
        showSuccessToast(context, 'Course saved.');
      }
    } catch (e) {
      setState(() => _saving = false);
      if (context.mounted) {
        final msg = e.toString().contains('unique')
            ? 'A course with that code already exists.'
            : 'Error: $e';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg), backgroundColor: AppColors.statusRed),
        );
      }
    }
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Delete Course', style: AppTextStyles.h3),
        content: Text(
          'This will mark the course as inactive and remove it from listings. '
          'Enrolled students will keep their records.',
          style: AppTextStyles.body,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              setState(() => _saving = true);
              try {
                await ref.read(adminServiceProvider).deleteCourse(widget.courseId);
                ref.invalidate(adminCoursesProvider);
                ref.invalidate(adminEnrollmentProvider);
                if (context.mounted) context.pop();
              } catch (e) {
                setState(() => _saving = false);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text('Error: $e'),
                        backgroundColor: AppColors.statusRed),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.statusRed),
            child: Text('Delete', style: AppTextStyles.button),
          ),
        ],
      ),
    );
  }
}

// ── Class row ──────────────────────────────────────────────────────────────────

class _ClassRow extends StatelessWidget {
  const _ClassRow({required this.cls, required this.onEdit});
  final AdminClass cls;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final color = _shiftColor(cls.shift);
    final pct   = cls.pct.clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.bgPage,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          // Left badge column
          Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppSpacing.tagRadius),
                ),
                child: Text(cls.shiftLabel,
                    style: AppTextStyles.label.copyWith(color: color, fontSize: 10)),
              ),
              const SizedBox(height: 4),
              Container(
                width: 34,
                height: 26,
                decoration: BoxDecoration(
                  color: AppColors.primaryNavy.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Center(
                  child: Text(cls.classCode,
                      style: AppTextStyles.label
                          .copyWith(color: AppColors.primaryNavy, fontSize: 12)),
                ),
              ),
            ],
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cls.teacherName ?? 'Unassigned',
                  style: AppTextStyles.body.copyWith(fontSize: 13),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Text('${cls.enrolledCount}/${cls.maxStudents}',
                        style: AppTextStyles.caption.copyWith(fontSize: 10)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(3),
                        child: LinearProgressIndicator(
                          value: pct,
                          minHeight: 4,
                          backgroundColor: AppColors.border,
                          valueColor: AlwaysStoppedAnimation<Color>(
                              pct >= 1.0 ? AppColors.statusRed : AppColors.primaryBlue),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 4,
                  children: [
                    _MiniChip(
                      label: cls.programLabel,
                      color: cls.programType == 'international'
                          ? AppColors.primaryBlue
                          : const Color(0xFF2E7D32),
                    ),
                    _MiniChip(
                      label: cls.scheduleLabel,
                      color: cls.scheduleType == 'weekend'
                          ? const Color(0xFFD97706)
                          : AppColors.primaryNavy,
                    ),
                    if (cls.semesterName != null)
                      _MiniChip(label: cls.semesterName!, color: AppColors.textLabel),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.edit_outlined, size: 18, color: AppColors.textSecondary),
            onPressed: onEdit,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
        ],
      ),
    );
  }
}

// ── Schedule slot row ──────────────────────────────────────────────────────────

class _ScheduleSlotRow extends StatelessWidget {
  const _ScheduleSlotRow({
    required this.day,
    required this.start,
    required this.end,
    this.room,
    required this.onDelete,
  });
  final String day;
  final String start;
  final String end;
  final String? room;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.bgPage,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 34,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.primaryNavy.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(day,
                style: AppTextStyles.label.copyWith(color: AppColors.primaryNavy, fontSize: 11)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$start – $end', style: AppTextStyles.body.copyWith(fontSize: 13)),
                if (room != null && room!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(room!, style: AppTextStyles.caption.copyWith(fontSize: 11)),
                ],
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.delete_outline, size: 18, color: AppColors.statusRed),
            onPressed: onDelete,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
        ],
      ),
    );
  }
}

class _TimePickerField extends StatelessWidget {
  const _TimePickerField({required this.label, required this.time, required this.onPick});
  final String label;
  final TimeOfDay? time;
  final VoidCallback onPick;

  @override
  Widget build(BuildContext context) {
    final display = time != null ? _fmtTime(time!) : 'Select time';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: AppTextStyles.caption
                .copyWith(fontSize: 11, color: AppColors.textSecondary)),
        const SizedBox(height: 4),
        GestureDetector(
          onTap: onPick,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
            decoration: BoxDecoration(
              color: AppColors.bgInput,
              borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Icon(Icons.access_time, size: 16, color: AppColors.textSecondary),
                const SizedBox(width: 8),
                Text(display,
                    style: time != null
                        ? AppTextStyles.body
                        : AppTextStyles.caption.copyWith(color: AppColors.textLabel)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ── Shared widgets ─────────────────────────────────────────────────────────────

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.children});
  final String title;
  final List<Widget> children;

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
          Text(title, style: AppTextStyles.h3),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }
}

class _LabelField extends StatelessWidget {
  const _LabelField({
    required this.label,
    required this.controller,
    this.maxLines = 1,
    this.keyboardType,
  });
  final String label;
  final TextEditingController controller;
  final int maxLines;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          style: AppTextStyles.body,
          decoration: InputDecoration(
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

class _LabelIdDropdown<T> extends StatelessWidget {
  const _LabelIdDropdown({
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
            style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
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
                  style: AppTextStyles.caption.copyWith(color: AppColors.textLabel)),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
              items: items,
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}

class _MiniChip extends StatelessWidget {
  const _MiniChip({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(label,
          style: AppTextStyles.caption.copyWith(color: color, fontSize: 9)),
    );
  }
}

class _SheetField extends StatelessWidget {
  const _SheetField({
    required this.label,
    required this.controller,
    this.hint,
    this.keyboardType,
  });
  final String label;
  final TextEditingController controller;
  final String? hint;
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
          keyboardType: keyboardType,
          style: AppTextStyles.body,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTextStyles.caption.copyWith(color: AppColors.textLabel),
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
                  style: AppTextStyles.caption.copyWith(color: AppColors.textLabel)),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
              items: items,
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}
