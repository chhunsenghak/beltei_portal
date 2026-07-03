import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/teacher_providers.dart';
import '../../../core/services/teacher_service.dart';

// ── Screen ────────────────────────────────────────────────────────────────────

class MarkAttendanceScreen extends ConsumerStatefulWidget {
  const MarkAttendanceScreen({super.key, required this.courseId});
  final String courseId;

  @override
  ConsumerState<MarkAttendanceScreen> createState() =>
      _MarkAttendanceScreenState();
}

class _MarkAttendanceScreenState
    extends ConsumerState<MarkAttendanceScreen> {
  // null = not marked, 'P' = present, 'A' = absent, 'L' = late, 'LV' = leave
  final Map<String, String?> _statuses = {};
  bool _saving = false;
  bool _saved = false;

  String get _today {
    final d = DateTime.now();
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }

  String get _todayDisplay =>
      DateFormat('MMM d, yyyy').format(DateTime.now());

  int get _markedCount =>
      _statuses.values.where((v) => v != null).length;

  void _selectAll(List<CourseStudent> students) => setState(() {
        for (final s in students) {
          _statuses[s.studentId] = 'P';
        }
      });

  void _clearAll(List<CourseStudent> students) => setState(() {
        for (final s in students) {
          _statuses[s.studentId] = null;
        }
      });

  Future<void> _saveAttendance(List<CourseStudent> students) async {
    if (_markedCount < students.length) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${students.length - _markedCount} students still unmarked.',
            style: AppTextStyles.body.copyWith(color: Colors.white),
          ),
          backgroundColor: AppColors.statusAmber,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    final user = ref.read(currentUserProvider).valueOrNull;
    if (user == null) return;

    setState(() => _saving = true);
    try {
      final nonNullStatuses = Map.fromEntries(
        _statuses.entries.where((e) => e.value != null).map(
              (e) => MapEntry(e.key, e.value!),
            ),
      );
      await ref.read(teacherServiceProvider).saveAttendance(
            teacherId: user.id,
            courseId: widget.courseId,
            date: _today,
            statuses: nonNullStatuses,
          );
      if (mounted) setState(() => _saved = true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save attendance.',
                style: AppTextStyles.body
                    .copyWith(color: Colors.white)),
            backgroundColor: AppColors.statusRed,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final studentsAsync =
        ref.watch(courseStudentsProvider(widget.courseId));
    final courseAsync =
        ref.watch(courseInfoProvider(widget.courseId));

    if (_saved) {
      return studentsAsync.when(
        loading: () => const Scaffold(
            body: Center(child: CircularProgressIndicator())),
        error: (_, _) =>
            _buildSuccessScreen(context, [], courseAsync.valueOrNull),
        data: (students) =>
            _buildSuccessScreen(context, students, courseAsync.valueOrNull),
      );
    }

    return studentsAsync.when(
      loading: () => Scaffold(
        appBar: _buildAppBar(context, null),
        backgroundColor: AppColors.bgPage,
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        appBar: _buildAppBar(context, null),
        backgroundColor: AppColors.bgPage,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline,
                  color: AppColors.statusRed, size: 40),
              const SizedBox(height: 8),
              Text('Could not load students',
                  style: AppTextStyles.bodyMedium),
              TextButton(
                onPressed: () =>
                    ref.invalidate(courseStudentsProvider(widget.courseId)),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
      data: (students) {
        // Lazily initialize statuses map
        for (final s in students) {
          _statuses.putIfAbsent(s.studentId, () => null);
        }
        final course = courseAsync.valueOrNull;
        return Scaffold(
          backgroundColor: AppColors.bgPage,
          appBar: _buildAppBar(context, course),
          body: Column(
            children: [
              _buildSessionInfo(course),
              _buildStudentListHeader(students),
              Expanded(
                child: students.isEmpty
                    ? Center(
                        child: Text('No students enrolled.',
                            style: AppTextStyles.body.copyWith(
                                color: AppColors.textSecondary)))
                    : ListView.separated(
                        padding: const EdgeInsets.all(
                            AppSpacing.screenPadding),
                        itemCount: students.length,
                        separatorBuilder: (_, _) =>
                            const SizedBox(height: 10),
                        itemBuilder: (_, i) =>
                            _StudentAttendanceCard(
                              student: students[i],
                              status: _statuses[students[i].studentId],
                              onChanged: (val) => setState(() =>
                                  _statuses[students[i].studentId] = val),
                            ),
                      ),
              ),
              _buildSaveButton(students),
            ],
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(
      BuildContext context, TeacherCourse? course) {
    return AppBar(
      backgroundColor: AppColors.bgPage,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, size: 18),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            course != null ? '${course.code} – ${course.name}' : 'Attendance',
            style: AppTextStyles.h3,
            overflow: TextOverflow.ellipsis,
          ),
          Text("Today's Session", style: AppTextStyles.caption),
        ],
      ),
    );
  }

  Widget _buildSessionInfo(TeacherCourse? course) {
    final slot = course?.todaySlot();
    final time = slot?['start'] as String? ?? '--:--';
    final room = slot?['room'] as String? ?? course?.room ?? '---';
    return Container(
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              _InfoChip(Icons.calendar_today_outlined, _todayDisplay),
              const SizedBox(width: 16),
              _InfoChip(Icons.access_time_outlined, time),
              const SizedBox(width: 16),
              _InfoChip(Icons.meeting_room_outlined, room),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: AppColors.statusGreen,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text('IN PROGRESS',
                  style: AppTextStyles.label
                      .copyWith(color: AppColors.statusGreen)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStudentListHeader(List<CourseStudent> students) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.screenPadding, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Text('Students\nList',
              style: AppTextStyles.bodyMedium.copyWith(height: 1.3)),
          const SizedBox(width: 8),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primaryNavy,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text('${students.length}\nTOTAL',
                style: AppTextStyles.label
                    .copyWith(color: Colors.white, fontSize: 10),
                textAlign: TextAlign.center),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () => _selectAll(students),
            child: Text('Select All\nPresent',
                style: AppTextStyles.link
                    .copyWith(fontSize: 12, height: 1.3),
                textAlign: TextAlign.center),
          ),
          const SizedBox(width: 16),
          GestureDetector(
            onTap: () => _clearAll(students),
            child: Text('Clear\nAll',
                style: AppTextStyles.body.copyWith(
                    color: AppColors.statusRed,
                    fontSize: 12,
                    height: 1.3),
                textAlign: TextAlign.center),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton(List<CourseStudent> students) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      color: AppColors.bgCard,
      child: SizedBox(
        width: double.infinity,
        height: AppSpacing.buttonHeight,
        child: ElevatedButton.icon(
          onPressed: _saving ? null : () => _saveAttendance(students),
          icon: _saving
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white))
              : const Icon(Icons.save_outlined, size: 18),
          label: Text(
              _saving
                  ? 'Saving...'
                  : 'Save Attendance ($_markedCount/${students.length})',
              style: AppTextStyles.button),
        ),
      ),
    );
  }

  Widget _buildSuccessScreen(BuildContext context,
      List<CourseStudent> students, TeacherCourse? course) {
    final present =
        _statuses.values.where((v) => v == 'P').length;
    final absent = _statuses.values.where((v) => v == 'A').length;
    final late = _statuses.values.where((v) => v == 'L').length;
    final leave = _statuses.values.where((v) => v == 'LV').length;

    return Scaffold(
      backgroundColor: AppColors.bgPage,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.statusGreenBg,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.check_circle_outline,
                    color: AppColors.statusGreen, size: 44),
              ),
              const SizedBox(height: 24),
              Text('Attendance Saved!', style: AppTextStyles.h1),
              const SizedBox(height: 8),
              Text(
                course != null
                    ? '${course.code} – ${course.name}'
                    : 'Session recorded',
                style: AppTextStyles.body
                    .copyWith(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),
              _buildSummaryRow(
                  'Present', present, AppColors.statusGreen),
              const SizedBox(height: 8),
              _buildSummaryRow('Absent', absent, AppColors.statusRed),
              const SizedBox(height: 8),
              _buildSummaryRow('Late', late, AppColors.statusAmber),
              const SizedBox(height: 8),
              _buildSummaryRow(
                  'Leave / Excused', leave, AppColors.primaryBlue),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: AppSpacing.buttonHeight,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Done', style: AppTextStyles.button),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, int count, Color color) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 10),
        Text(label, style: AppTextStyles.body),
        const Spacer(),
        Text('$count students',
            style:
                AppTextStyles.bodyMedium.copyWith(color: color)),
      ],
    );
  }
}

// ── Student attendance card ────────────────────────────────────────────────────

class _StudentAttendanceCard extends StatelessWidget {
  const _StudentAttendanceCard({
    required this.student,
    required this.status,
    required this.onChanged,
  });

  final CourseStudent student;
  final String? status;
  final ValueChanged<String?> onChanged;

  static final _options = [
    (
      value: 'P',
      label: 'Present',
      icon: Icons.check_circle_outline,
      color: AppColors.statusGreen
    ),
    (
      value: 'A',
      label: 'Absent',
      icon: Icons.cancel_outlined,
      color: AppColors.statusRed
    ),
    (
      value: 'L',
      label: 'Late',
      icon: Icons.schedule_outlined,
      color: AppColors.statusAmber
    ),
    (
      value: 'LV',
      label: 'Leave',
      icon: Icons.event_note_outlined,
      color: AppColors.primaryBlue
    ),
  ];

  Color _colorFor(String val) {
    switch (val) {
      case 'P':
        return AppColors.statusGreen;
      case 'A':
        return AppColors.statusRed;
      case 'L':
        return AppColors.statusAmber;
      default:
        return AppColors.primaryBlue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(
          color: status != null ? _colorFor(status!) : AppColors.border,
          width: status != null ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor:
                    AppColors.primaryNavy.withValues(alpha: 0.1),
                child: Text(
                  student.fullName.isNotEmpty
                      ? student.fullName[0].toUpperCase()
                      : '?',
                  style: AppTextStyles.h3
                      .copyWith(color: AppColors.primaryNavy),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(student.fullName,
                      style: AppTextStyles.bodyMedium),
                  Text('ID: ${student.studentCode}',
                      style: AppTextStyles.caption),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _options.map((opt) {
                final isSelected = status == opt.value;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () =>
                        onChanged(isSelected ? null : opt.value),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 7),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? opt.color.withValues(alpha: 0.12)
                            : AppColors.bgPage,
                        borderRadius: BorderRadius.circular(
                            AppSpacing.chipRadius),
                        border: Border.all(
                          color: isSelected
                              ? opt.color
                              : AppColors.border,
                          width: isSelected ? 1.5 : 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(opt.icon,
                              size: 14,
                              color: isSelected
                                  ? opt.color
                                  : AppColors.textSecondary),
                          const SizedBox(width: 5),
                          Text(opt.label,
                              style: AppTextStyles.caption.copyWith(
                                color: isSelected
                                    ? opt.color
                                    : AppColors.textSecondary,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                              )),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Info chip ──────────────────────────────────────────────────────────────────

class _InfoChip extends StatelessWidget {
  const _InfoChip(this.icon, this.label);
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: AppColors.textSecondary),
        const SizedBox(width: 4),
        Text(label, style: AppTextStyles.caption),
      ],
    );
  }
}
