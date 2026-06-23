import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';

// ── Mock data ──────────────────────────────────────────────────────────────────

class _EditStudent {
  _EditStudent({required this.id, required this.name, required this.studentId,
      required this.status, this.changed = false});
  final String id, name, studentId;
  String status; // 'P', 'L', 'A'
  bool changed;
}

final _kEditStudents = [
  _EditStudent(id: 'e1', name: 'Sok Cheat',   studentId: 'ID: BEL-001', status: 'P'),
  _EditStudent(id: 'e2', name: 'Keo Phalla',  studentId: 'ID: BEL-002', status: 'A', changed: true),
  _EditStudent(id: 'e3', name: 'Neth Ravy',   studentId: 'ID: BEL-003', status: 'P'),
  _EditStudent(id: 'e4', name: 'Vann Sy',     studentId: 'ID: BEL-004', status: 'L'),
  _EditStudent(id: 'e5', name: 'Chan Bopha',  studentId: 'ID: BEL-005', status: 'P'),
];

const _kEditSession = (
  course: 'G12-B Advanced English',
  session: 4,
  room: 'Room 402',
  date: 'Today, 08:30 AM',
);

// ── Screen ────────────────────────────────────────────────────────────────────

class EditAttendanceScreen extends StatefulWidget {
  const EditAttendanceScreen({super.key, required this.courseId});
  final String courseId;

  @override
  State<EditAttendanceScreen> createState() => _EditAttendanceScreenState();
}

class _EditAttendanceScreenState extends State<EditAttendanceScreen> {
  late final List<_EditStudent> _students =
      _kEditStudents.map((s) => _EditStudent(
            id: s.id,
            name: s.name,
            studentId: s.studentId,
            status: s.status,
            changed: s.changed,
          )).toList();

  // ── Computed ───────────────────────────────────────────────────────────────

  int get _present  => _students.where((s) => s.status == 'P').length;
  int get _late     => _students.where((s) => s.status == 'L').length;
  int get _absent   => _students.where((s) => s.status == 'A').length;

  void _setStatus(int index, String newStatus) {
    setState(() {
      _students[index].status = newStatus;
      _students[index].changed = true;
    });
  }

  void _update() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Attendance updated successfully.',
            style: AppTextStyles.body.copyWith(color: Colors.white)),
        backgroundColor: AppColors.statusGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      appBar: _buildAppBar(context),
      body: Column(
        children: [
          _buildSessionCard(),
          _buildStatsRow(),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.screenPadding),
              itemCount: _students.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (_, i) => _EditStudentCard(
                student: _students[i],
                onStatus: (val) => _setStatus(i, val),
              ),
            ),
          ),
          _buildUpdateButton(),
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
      title: Text('Edit Attendance', style: AppTextStyles.h3),
      actions: [
        IconButton(icon: const Icon(Icons.history), onPressed: () {}),
        IconButton(
            icon: const Icon(Icons.notifications_outlined), onPressed: () {}),
      ],
    );
  }

  // ── Session card ───────────────────────────────────────────────────────────

  Widget _buildSessionCard() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: const BoxDecoration(
        color: AppColors.bgCard,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_kEditSession.course,
                    style: AppTextStyles.h2
                        .copyWith(color: AppColors.primaryNavy)),
                const SizedBox(height: 4),
                Text('${_kEditSession.room} • ${_kEditSession.date}',
                    style: AppTextStyles.caption),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primaryNavy,
              borderRadius: BorderRadius.circular(AppSpacing.chipRadius),
            ),
            child: Text('SESSION\n${_kEditSession.session.toString().padLeft(2, '0')}',
                style: AppTextStyles.label.copyWith(
                    color: Colors.white, fontSize: 11),
                textAlign: TextAlign.center),
          ),
        ],
      ),
    );
  }

  // ── Stats row ──────────────────────────────────────────────────────────────

  Widget _buildStatsRow() {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.screenPadding, vertical: 10),
      color: AppColors.bgCard,
      child: Row(
        children: [
          _StatBadge('Total', '${_students.length}',
              AppColors.textPrimary),
          const SizedBox(width: 20),
          _StatBadge('Present', '$_present', AppColors.statusGreen),
          const SizedBox(width: 20),
          _StatBadge('Late', '$_late', AppColors.statusAmber),
          const SizedBox(width: 20),
          _StatBadge('Absent', '$_absent', AppColors.statusRed),
        ],
      ),
    );
  }

  // ── Update button ──────────────────────────────────────────────────────────

  Widget _buildUpdateButton() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      color: AppColors.bgCard,
      child: SizedBox(
        width: double.infinity,
        height: AppSpacing.buttonHeight,
        child: ElevatedButton.icon(
          onPressed: _update,
          icon: const Icon(Icons.save_outlined, size: 18),
          label: Text('Update Attendance', style: AppTextStyles.button),
        ),
      ),
    );
  }
}

// ── Edit student card ──────────────────────────────────────────────────────────

class _EditStudentCard extends StatelessWidget {
  const _EditStudentCard({required this.student, required this.onStatus});
  final _EditStudent student;
  final ValueChanged<String> onStatus;

  static const _opts = [
    (value: 'P', label: 'P', color: AppColors.statusGreen),
    (value: 'L', label: 'L', color: AppColors.statusAmber),
    (value: 'A', label: 'A', color: AppColors.statusRed),
  ];

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
              color: student.changed ? AppColors.statusAmber : AppColors.border,
              width: student.changed ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: AppColors.primaryNavy.withValues(alpha: 0.1),
                child: Text(student.name[0],
                    style: AppTextStyles.h3
                        .copyWith(color: AppColors.primaryNavy)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(student.name, style: AppTextStyles.bodyMedium),
                    Text(student.studentId, style: AppTextStyles.caption),
                  ],
                ),
              ),
              Row(
                children: _opts.map((opt) {
                  final selected = student.status == opt.value;
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
                          child: Text(opt.label,
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: selected ? opt.color : AppColors.textLabel,
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
        if (student.changed)
          Positioned(
            top: 8,
            left: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.statusAmber,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text('CHANGED',
                  style: AppTextStyles.label.copyWith(
                      color: Colors.white, fontSize: 8, letterSpacing: 0.5)),
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
            style: AppTextStyles.metric.copyWith(color: color, fontSize: 20)),
      ],
    );
  }
}
