import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/teacher_providers.dart';
import '../../../l10n/app_localizations.dart';

// Maps DB status values ↔ display abbreviations
const _kStatusToLabel = {
  'present':  'P',
  'late':     'L',
  'absent':   'A',
  'excused':  'E',
};

final _kOpts = [
  (value: 'P', color: AppColors.statusGreen),
  (value: 'L', color: AppColors.statusAmber),
  (value: 'A', color: AppColors.statusRed),
  (value: 'E', color: AppColors.primaryBlue),
];

// ── Screen ────────────────────────────────────────────────────────────────────

class EditAttendanceScreen extends ConsumerStatefulWidget {
  const EditAttendanceScreen({
    super.key,
    required this.courseId,
    this.date,
  });
  final String courseId;

  /// ISO date string 'yyyy-MM-dd'; defaults to today when null
  final String? date;

  @override
  ConsumerState<EditAttendanceScreen> createState() =>
      _EditAttendanceScreenState();
}

class _EditAttendanceScreenState
    extends ConsumerState<EditAttendanceScreen> {
  late final String _date;

  /// studentId → current label ('P'/'L'/'A'/'E')
  final Map<String, String> _statuses = {};

  /// studentIds that were changed from their loaded value
  final Set<String> _changed = {};

  bool _saving = false;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _date = widget.date ??
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  void _initStatuses(List<dynamic> students, Map<String, String> existing) {
    if (_initialized) return;
    _initialized = true;
    for (final s in students) {
      final dbStatus = existing[s.studentId as String] ?? 'present';
      _statuses[s.studentId as String] = _kStatusToLabel[dbStatus] ?? 'P';
    }
    _changed.clear();
  }

  void _setStatus(String studentId, String label) {
    setState(() {
      _statuses[studentId] = label;
      _changed.add(studentId);
    });
  }

  Future<void> _save(List<dynamic> students) async {
    setState(() => _saving = true);
    try {
      final user = await ref.read(currentUserProvider.future);
      if (user == null) throw Exception('Not authenticated');

      await ref.read(teacherServiceProvider).saveAttendance(
            teacherId: user.id,
            courseId: widget.courseId,
            date: _date,
            statuses: Map.fromEntries(students.map((s) =>
                MapEntry(s.studentId as String, _statuses[s.studentId] ?? 'P'))),
          );

      ref.invalidate(attendanceSummaryProvider(widget.courseId));
      ref.invalidate(attendanceForDateProvider(
          (courseId: widget.courseId, date: _date)));

      if (mounted) {
        final l = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(l.editAttendanceUpdatedMessage,
              style: AppTextStyles.body.copyWith(color: Colors.white)),
          backgroundColor: AppColors.statusGreen,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)),
        ));
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        final l = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(l.editAttendanceSaveFailedError(e),
              style: AppTextStyles.body.copyWith(color: Colors.white)),
          backgroundColor: AppColors.statusRed,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)),
        ));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  int _count(String label) =>
      _statuses.values.where((v) => v == label).length;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final courseAsync = ref.watch(courseInfoProvider(widget.courseId));
    final studentsAsync = ref.watch(courseStudentsProvider(widget.courseId));
    final existingAsync = ref.watch(
        attendanceForDateProvider((courseId: widget.courseId, date: _date)));

    return Scaffold(
      backgroundColor: AppColors.bgPage,
      appBar: _buildAppBar(l),
      body: studentsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline,
                  color: AppColors.statusRed, size: 40),
              const SizedBox(height: 8),
              Text(l.loadErrorStudents, style: AppTextStyles.body),
              TextButton(
                onPressed: () =>
                    ref.invalidate(courseStudentsProvider(widget.courseId)),
                child: Text(l.retry),
              ),
            ],
          ),
        ),
        data: (students) {
          final existing = existingAsync.valueOrNull ?? {};
          if (!_initialized && students.isNotEmpty) {
            WidgetsBinding.instance.addPostFrameCallback(
                (_) => setState(() => _initStatuses(students, existing)));
          }
          return Column(
            children: [
              _buildSessionCard(courseAsync.valueOrNull, l),
              _buildStatsRow(students.length, l),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(AppSpacing.screenPadding),
                  itemCount: students.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (_, i) {
                    final s = students[i];
                    final label = _statuses[s.studentId] ?? 'P';
                    return _EditStudentCard(
                      name: s.fullName,
                      code: s.studentCode,
                      status: label,
                      changed: _changed.contains(s.studentId),
                      onStatus: (v) => _setStatus(s.studentId, v),
                      changedLabel: l.editAttendanceChangedBadge,
                    );
                  },
                ),
              ),
              _buildUpdateButton(students, l),
            ],
          );
        },
      ),
    );
  }

  // ── App bar ────────────────────────────────────────────────────────────────

  PreferredSizeWidget _buildAppBar(AppLocalizations l) {
    return AppBar(
      backgroundColor: AppColors.bgPage,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, size: 18),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Text(l.editAttendanceAppBarTitle, style: AppTextStyles.h3),
    );
  }

  // ── Session card ───────────────────────────────────────────────────────────

  Widget _buildSessionCard(dynamic course, AppLocalizations l) {
    final courseName = course?.name as String? ?? l.editAttendanceLoadingCourseName;
    final room = course?.room as String? ?? '';
    final parts = _date.split('-');
    final dateLabel = parts.length == 3
        ? '${parts[2]}/${parts[1]}/${parts[0]}'
        : _date;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(courseName,
                    style: AppTextStyles.h2
                        .copyWith(color: AppColors.primaryNavy)),
                const SizedBox(height: 4),
                Text(
                  [if (room.isNotEmpty) room, dateLabel].join(' • '),
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primaryNavy,
              borderRadius: BorderRadius.circular(AppSpacing.chipRadius),
            ),
            child: Text(_date,
                style: AppTextStyles.label
                    .copyWith(color: Colors.white, fontSize: 10)),
          ),
        ],
      ),
    );
  }

  // ── Stats row ──────────────────────────────────────────────────────────────

  Widget _buildStatsRow(int total, AppLocalizations l) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.screenPadding, vertical: 10),
      color: AppColors.bgCard,
      child: Row(
        children: [
          _StatBadge(l.courseDetailTotalLabel, '$total', AppColors.textPrimary),
          const SizedBox(width: 20),
          _StatBadge(
              l.statusPresent, '${_count('P')}', AppColors.statusGreen),
          const SizedBox(width: 20),
          _StatBadge(l.statusLate, '${_count('L')}', AppColors.statusAmber),
          const SizedBox(width: 20),
          _StatBadge(l.statusAbsent, '${_count('A')}', AppColors.statusRed),
        ],
      ),
    );
  }

  // ── Update button ──────────────────────────────────────────────────────────

  Widget _buildUpdateButton(List<dynamic> students, AppLocalizations l) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      color: AppColors.bgCard,
      child: SizedBox(
        width: double.infinity,
        height: AppSpacing.buttonHeight,
        child: ElevatedButton.icon(
          onPressed: _saving ? null : () => _save(students),
          icon: _saving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white))
              : const Icon(Icons.save_outlined, size: 18),
          label: Text(l.editAttendanceUpdateButton, style: AppTextStyles.button),
        ),
      ),
    );
  }
}

// ── Edit student card ──────────────────────────────────────────────────────────

class _EditStudentCard extends StatelessWidget {
  const _EditStudentCard({
    required this.name,
    required this.code,
    required this.status,
    required this.changed,
    required this.onStatus,
    required this.changedLabel,
  });
  final String name, code, status;
  final bool changed;
  final ValueChanged<String> onStatus;
  final String changedLabel;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.cardPadding),
          decoration: BoxDecoration(
            color: AppColors.bgCard,
            borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
            border: Border.all(
              color: changed ? AppColors.statusAmber : AppColors.border,
              width: changed ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor:
                    AppColors.primaryNavy.withValues(alpha: 0.1),
                child: Text(
                    name.isNotEmpty ? name[0].toUpperCase() : '?',
                    style: AppTextStyles.h3
                        .copyWith(color: AppColors.primaryNavy)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: AppTextStyles.bodyMedium),
                    Text(code, style: AppTextStyles.caption),
                  ],
                ),
              ),
              Row(
                children: _kOpts.map((opt) {
                  final selected = status == opt.value;
                  return Padding(
                    padding: const EdgeInsets.only(left: 6),
                    child: GestureDetector(
                      onTap: () => onStatus(opt.value),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: selected
                              ? opt.color.withValues(alpha: 0.15)
                              : AppColors.bgPage,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: selected ? opt.color : AppColors.border,
                            width: selected ? 2 : 1,
                          ),
                        ),
                        child: Center(
                          child: Text(opt.value,
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: selected
                                    ? opt.color
                                    : AppColors.textLabel,
                                fontSize: 13,
                              )),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        if (changed)
          Positioned(
            top: 8,
            left: 8,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.statusAmber,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(changedLabel,
                  style: AppTextStyles.label.copyWith(
                      color: Colors.white,
                      fontSize: 8,
                      letterSpacing: 0.5)),
            ),
          ),
      ],
    );
  }
}

// ── Stat badge ─────────────────────────────────────────────────────────────────

class _StatBadge extends StatelessWidget {
  const _StatBadge(this.label, this.value, this.color);
  final String label, value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: AppTextStyles.label),
        Text(value,
            style:
                AppTextStyles.metric.copyWith(color: color, fontSize: 20)),
      ],
    );
  }
}
