import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';

// ── Mock data ──────────────────────────────────────────────────────────────────

class _Student {
  const _Student({required this.id, required this.name, required this.studentId});
  final String id, name, studentId;
}

const _kSession = (
  course: 'CS101 - Introduction to Programming',
  session: 'Session 12',
  date: 'Oct 25, 2024',
  time: '08:30 AM',
  room: 'Room 402',
);

const _kStudents = [
  _Student(id: 's1', name: 'Sophal Rattanak',  studentId: 'ID: BEL-2024-001'),
  _Student(id: 's2', name: 'Vibol Sophea',     studentId: 'ID: BEL-2024-042'),
  _Student(id: 's3', name: 'Kosal Dara',       studentId: 'ID: BEL-2024-115'),
  _Student(id: 's4', name: 'Chan Veasna',      studentId: 'ID: BEL-2024-089'),
  _Student(id: 's5', name: 'Ratha Pov',        studentId: 'ID: BEL-2024-033'),
  _Student(id: 's6', name: 'Sreymom Keo',      studentId: 'ID: BEL-2024-072'),
];

// ── Screen ────────────────────────────────────────────────────────────────────

class MarkAttendanceScreen extends StatefulWidget {
  const MarkAttendanceScreen({super.key, required this.courseId});
  final String courseId;

  @override
  State<MarkAttendanceScreen> createState() => _MarkAttendanceScreenState();
}

class _MarkAttendanceScreenState extends State<MarkAttendanceScreen> {
  // null = not marked, 'P' = present, 'A' = absent, 'L' = late, 'LV' = leave
  final Map<String, String?> _statuses = {
    for (final s in _kStudents) s.id: null,
  };

  bool _saved = false;

  // ── Computed ───────────────────────────────────────────────────────────────

  int get _markedCount => _statuses.values.where((v) => v != null).length;

  // ── Actions ────────────────────────────────────────────────────────────────

  void _selectAll() => setState(() {
        for (final k in _statuses.keys) {
          _statuses[k] = 'P';
        }
      });

  void _clearAll() => setState(() {
        for (final k in _statuses.keys) {
          _statuses[k] = null;
        }
      });

  void _saveAttendance() {
    if (_markedCount < _kStudents.length) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${_kStudents.length - _markedCount} students still unmarked.',
            style: AppTextStyles.body.copyWith(color: Colors.white),
          ),
          backgroundColor: AppColors.statusAmber,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }
    setState(() => _saved = true);
  }

  // ── build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    if (_saved) return _buildSuccessScreen(context);

    return Scaffold(
      backgroundColor: AppColors.bgPage,
      appBar: _buildAppBar(context),
      body: Column(
        children: [
          _buildSessionInfo(),
          _buildStudentListHeader(),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.screenPadding),
              itemCount: _kStudents.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (_, i) =>
                  _StudentAttendanceCard(
                    student: _kStudents[i],
                    status: _statuses[_kStudents[i].id],
                    onChanged: (val) =>
                        setState(() => _statuses[_kStudents[i].id] = val),
                  ),
            ),
          ),
          _buildSaveButton(),
        ],
      ),
    );
  }

  // ── App bar ────────────────────────────────────────────────────────────────

  PreferredSizeWidget _buildAppBar(BuildContext context) {
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
          Text(_kSession.course,
              style: AppTextStyles.h3,
              overflow: TextOverflow.ellipsis),
          Text(_kSession.session, style: AppTextStyles.caption),
        ],
      ),
      actions: [
        IconButton(
            icon: const Icon(Icons.notifications_outlined), onPressed: () {}),
      ],
    );
  }

  // ── Session info ───────────────────────────────────────────────────────────

  Widget _buildSessionInfo() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: const BoxDecoration(
        color: AppColors.bgCard,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              _InfoChip(Icons.calendar_today_outlined, _kSession.date),
              const SizedBox(width: 16),
              _InfoChip(Icons.access_time_outlined, _kSession.time),
              const SizedBox(width: 16),
              _InfoChip(Icons.meeting_room_outlined, _kSession.room),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
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

  // ── Student list header ────────────────────────────────────────────────────

  Widget _buildStudentListHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.screenPadding, vertical: 10),
      decoration: const BoxDecoration(
        color: AppColors.bgCard,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Text('Students\nList',
              style: AppTextStyles.bodyMedium.copyWith(height: 1.3)),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primaryNavy,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text('${_kStudents.length}\nTOTAL',
                style: AppTextStyles.label
                    .copyWith(color: Colors.white, fontSize: 10),
                textAlign: TextAlign.center),
          ),
          const Spacer(),
          GestureDetector(
            onTap: _selectAll,
            child: Text('Select All\nPresent',
                style: AppTextStyles.link.copyWith(fontSize: 12, height: 1.3),
                textAlign: TextAlign.center),
          ),
          const SizedBox(width: 16),
          GestureDetector(
            onTap: _clearAll,
            child: Text('Clear\nAll',
                style: AppTextStyles.body.copyWith(
                    color: AppColors.statusRed, fontSize: 12, height: 1.3),
                textAlign: TextAlign.center),
          ),
        ],
      ),
    );
  }

  // ── Save button ────────────────────────────────────────────────────────────

  Widget _buildSaveButton() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      color: AppColors.bgCard,
      child: SizedBox(
        width: double.infinity,
        height: AppSpacing.buttonHeight,
        child: ElevatedButton.icon(
          onPressed: _saveAttendance,
          icon: const Icon(Icons.save_outlined, size: 18),
          label: Text('Save Attendance ($_markedCount/${_kStudents.length})',
              style: AppTextStyles.button),
        ),
      ),
    );
  }

  // ── Success screen ─────────────────────────────────────────────────────────

  Widget _buildSuccessScreen(BuildContext context) {
    final present = _statuses.values.where((v) => v == 'P').length;
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
                decoration: const BoxDecoration(
                  color: AppColors.statusGreenBg,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle_outline,
                    color: AppColors.statusGreen, size: 44),
              ),
              const SizedBox(height: 24),
              Text('Attendance Saved!', style: AppTextStyles.h1),
              const SizedBox(height: 8),
              Text('${_kSession.course} – ${_kSession.session}',
                  style: AppTextStyles.body
                      .copyWith(color: AppColors.textSecondary),
                  textAlign: TextAlign.center),
              const SizedBox(height: 28),
              _buildSummaryRow('Present', present, AppColors.statusGreen),
              const SizedBox(height: 8),
              _buildSummaryRow('Absent', absent, AppColors.statusRed),
              const SizedBox(height: 8),
              _buildSummaryRow('Late', late, AppColors.statusAmber),
              const SizedBox(height: 8),
              _buildSummaryRow('Leave', leave, AppColors.primaryBlue),
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
            style: AppTextStyles.bodyMedium.copyWith(color: color)),
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

  final _Student student;
  final String? status;
  final ValueChanged<String?> onChanged;

  static const _options = [
    (value: 'P',  label: 'Present', icon: Icons.check_circle_outline, color: AppColors.statusGreen),
    (value: 'A',  label: 'Absent',  icon: Icons.cancel_outlined,       color: AppColors.statusRed),
    (value: 'L',  label: 'Late',    icon: Icons.schedule_outlined,     color: AppColors.statusAmber),
    (value: 'LV', label: 'Leave',   icon: Icons.event_note_outlined,   color: AppColors.primaryBlue),
  ];

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
                backgroundColor: AppColors.primaryNavy.withValues(alpha: 0.1),
                child: Text(
                  student.name.substring(0, 1),
                  style: AppTextStyles.h3.copyWith(color: AppColors.primaryNavy),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(student.name, style: AppTextStyles.bodyMedium),
                  Text(student.studentId, style: AppTextStyles.caption),
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
                    onTap: () => onChanged(isSelected ? null : opt.value),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 7),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? opt.color.withValues(alpha: 0.12)
                            : AppColors.bgPage,
                        borderRadius:
                            BorderRadius.circular(AppSpacing.chipRadius),
                        border: Border.all(
                          color: isSelected ? opt.color : AppColors.border,
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

  Color _colorFor(String val) {
    switch (val) {
      case 'P': return AppColors.statusGreen;
      case 'A': return AppColors.statusRed;
      case 'L': return AppColors.statusAmber;
      default:  return AppColors.primaryBlue;
    }
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
