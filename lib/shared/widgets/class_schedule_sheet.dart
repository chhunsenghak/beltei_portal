import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/providers/admin_providers.dart';
import 'app_toast.dart';

const _kWeekdayScheduleDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'];
const _kWeekendScheduleDays = ['Sat', 'Sun'];

List<String> _scheduleDaysFor(String scheduleType) =>
    scheduleType == 'weekend' ? _kWeekendScheduleDays : _kWeekdayScheduleDays;

String _fmtTime(TimeOfDay t) =>
    '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

int _parseTimeToMinutes(String hhmm) {
  final parts = hhmm.split(':');
  if (parts.length != 2) return 0;
  final h = int.tryParse(parts[0]) ?? 0;
  final m = int.tryParse(parts[1]) ?? 0;
  return h * 60 + m;
}

/// Opens a bottom sheet for viewing/editing a single class's weekly
/// schedule (day/start/end/room slots). Schedule lives on `classes`, not
/// `courses` — different classes (sections) of the same course can meet at
/// different days/times, so each class manages its own slot list here.
Future<void> showClassScheduleSheet(
  BuildContext context, {
  required String classTermCourseId,
  required String classLabel,
  required List<Map<String, dynamic>> initialSchedule,
  required String scheduleType,
  required VoidCallback onSaved,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.bgCard,
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
    builder: (ctx) => _ClassScheduleSheet(
      classTermCourseId: classTermCourseId,
      classLabel: classLabel,
      initialSchedule: initialSchedule,
      scheduleType: scheduleType,
      onSaved: onSaved,
    ),
  );
}

class _ClassScheduleSheet extends ConsumerStatefulWidget {
  const _ClassScheduleSheet({
    required this.classTermCourseId,
    required this.classLabel,
    required this.initialSchedule,
    required this.scheduleType,
    required this.onSaved,
  });
  final String classTermCourseId;
  final String classLabel;
  final List<Map<String, dynamic>> initialSchedule;
  final String scheduleType;
  final VoidCallback onSaved;

  @override
  ConsumerState<_ClassScheduleSheet> createState() => _ClassScheduleSheetState();
}

class _ClassScheduleSheetState extends ConsumerState<_ClassScheduleSheet> {
  late List<Map<String, dynamic>> _schedule;
  late List<String> _allowedDays;
  bool _saving = false;

  late String _day;
  TimeOfDay? _start;
  TimeOfDay? _end;
  final _roomCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _allowedDays = _scheduleDaysFor(widget.scheduleType);
    _day = _allowedDays.first;
    _schedule = [...widget.initialSchedule];
    _sortSchedule(_schedule);
  }

  void _sortSchedule(List<Map<String, dynamic>> list) {
    final dayOrder = {
      for (int i = 0; i < _allowedDays.length; i++) _allowedDays[i]: i
    };
    list.sort((a, b) {
      final dayA = dayOrder[a['day']] ?? 99;
      final dayB = dayOrder[b['day']] ?? 99;
      if (dayA != dayB) return dayA.compareTo(dayB);

      final startA = _parseTimeToMinutes(a['start'] as String? ?? '');
      final startB = _parseTimeToMinutes(b['start'] as String? ?? '');
      return startA.compareTo(startB);
    });
  }

  @override
  void dispose() {
    _roomCtrl.dispose();
    super.dispose();
  }

  Future<void> _persist(List<Map<String, dynamic>> updated) async {
    final sorted = [...updated];
    _sortSchedule(sorted);

    setState(() => _saving = true);
    try {
      await ref
          .read(adminServiceProvider)
          .updateClassTermCourseSchedule(classTermCourseId: widget.classTermCourseId, schedule: sorted);
      setState(() {
        _schedule = sorted;
        _saving = false;
      });
      widget.onSaved();
    } catch (e) {
      setState(() => _saving = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.statusRed),
        );
      }
    }
  }

  Future<void> _addSlot() async {
    if (_start == null || _end == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Please select start and end time')));
      return;
    }
    final startMin = _start!.hour * 60 + _start!.minute;
    final endMin = _end!.hour * 60 + _end!.minute;
    if (endMin <= startMin) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('End time must be after start time')));
      return;
    }
    final overlap = _schedule.any((s) {
      if (s['day'] != _day) return false;
      final sStart = _parseTimeToMinutes(s['start'] as String? ?? '');
      final sEnd = _parseTimeToMinutes(s['end'] as String? ?? '');
      return startMin < sEnd && endMin > sStart;
    });
    if (overlap) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('This overlaps with an existing slot on the same day')));
      return;
    }
    final newSlot = {
      'day': _day,
      'start': _fmtTime(_start!),
      'end': _fmtTime(_end!),
      if (_roomCtrl.text.trim().isNotEmpty) 'room': _roomCtrl.text.trim(),
    };
    await _persist([..._schedule, newSlot]);
    if (mounted) {
      setState(() {
        _start = null;
        _end = null;
        _roomCtrl.clear();
      });
      showSuccessToast(context, 'Time slot added.');
    }
  }

  Future<void> _deleteSlot(int index) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Remove Time Slot?'),
        content: const Text('This slot will no longer appear on student and teacher timetables.'),
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
    if (confirm != true) return;
    final updated = [..._schedule]..removeAt(index);
    await _persist(updated);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 20, 16, MediaQuery.of(context).viewInsets.bottom + 24),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${widget.classLabel} Schedule',
                style: AppTextStyles.h3.copyWith(color: AppColors.primaryNavy)),
            const SizedBox(height: 16),
            if (_schedule.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text('No time slots yet.',
                    style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
              )
            else
              Column(
                children: List.generate(_schedule.length, (i) {
                  final slot = _schedule[i];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _ScheduleSlotRow(
                      day: slot['day'] as String? ?? '',
                      start: slot['start'] as String? ?? '',
                      end: slot['end'] as String? ?? '',
                      room: slot['room'] as String?,
                      onDelete: _saving ? null : () => _deleteSlot(i),
                    ),
                  );
                }),
              ),
            const SizedBox(height: 16),
            Divider(color: AppColors.border),
            const SizedBox(height: 16),
            Text('Add Time Slot', style: AppTextStyles.bodyMedium),
            const SizedBox(height: 10),
            Text('Day',
                style:
                    AppTextStyles.caption.copyWith(fontSize: 11, color: AppColors.textSecondary)),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _allowedDays.map((d) {
                final selected = _day == d;
                return GestureDetector(
                  onTap: () => setState(() => _day = d),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: selected ? AppColors.primaryNavy : Colors.transparent,
                      borderRadius: BorderRadius.circular(AppSpacing.chipRadius),
                      border:
                          Border.all(color: selected ? AppColors.primaryNavy : AppColors.border),
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
                  time: _start,
                  onPick: () async {
                    final t = await showTimePicker(
                      context: context,
                      initialTime: _start ?? const TimeOfDay(hour: 8, minute: 0),
                    );
                    if (t != null) setState(() => _start = t);
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _TimePickerField(
                  label: 'End Time',
                  time: _end,
                  onPick: () async {
                    final t = await showTimePicker(
                      context: context,
                      initialTime: _end ?? const TimeOfDay(hour: 9, minute: 30),
                    );
                    if (t != null) setState(() => _end = t);
                  },
                ),
              ),
            ]),
            const SizedBox(height: 12),
            TextField(
              controller: _roomCtrl,
              decoration: const InputDecoration(
                labelText: 'Room',
                hintText: 'e.g. A101 (optional)',
              ),
            ),
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
                onPressed: _saving ? null : _addSlot,
                child: _saving
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
    );
  }
}

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
  final VoidCallback? onDelete;

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
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.statusBlueBg,
              borderRadius: BorderRadius.circular(AppSpacing.tagRadius),
            ),
            child: Text(day,
                style: AppTextStyles.label.copyWith(color: AppColors.primaryBlue, fontSize: 10)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$start – $end', style: AppTextStyles.bodyMedium),
                if (room != null && room!.isNotEmpty)
                  Text(room!, style: AppTextStyles.caption),
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
    return GestureDetector(
      onTap: onPick,
      child: InputDecorator(
        decoration: InputDecoration(labelText: label),
        child: Text(time != null ? time!.format(context) : 'Select time',
            style: AppTextStyles.body.copyWith(
                color: time != null ? AppColors.textPrimary : AppColors.textLabel)),
      ),
    );
  }
}
