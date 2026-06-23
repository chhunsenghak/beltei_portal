import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';

// ── Mock data ──────────────────────────────────────────────────────────────────

class _ClassSlot {
  const _ClassSlot({
    required this.course,
    required this.room,
    required this.students,
    required this.startHour,
    required this.endHour,
    required this.day, // 0=Mon, 1=Tue
    required this.color,
  });
  final String course, room;
  final int students, startHour, endHour, day;
  final Color color;
}

final _kSlots = [
  _ClassSlot(
    course: 'Advanced Algebra',
    room: 'Room 402',
    students: 32,
    startHour: 8,
    endHour: 10,
    day: 0,
    color: AppColors.primaryNavy,
  ),
  _ClassSlot(
    course: 'Math Methods',
    room: 'Lab 02',
    students: 28,
    startHour: 8,
    endHour: 9,
    day: 1,
    color: AppColors.primaryBlue,
  ),
  _ClassSlot(
    course: 'Advanced Algebra',
    room: 'Room 402',
    students: 32,
    startHour: 10,
    endHour: 12,
    day: 1,
    color: AppColors.primaryNavy,
  ),
  _ClassSlot(
    course: 'Research Mentoring',
    room: 'Library Hub',
    students: 5,
    startHour: 13,
    endHour: 14,
    day: 0,
    color: const Color(0xFF0EA5E9),
  ),
];

const _kWeeklyHours = '24.5';
const _kTotalStudents = 184;

// ── Screen ────────────────────────────────────────────────────────────────────

class TeacherScheduleScreen extends StatefulWidget {
  const TeacherScheduleScreen({super.key});

  @override
  State<TeacherScheduleScreen> createState() => _TeacherScheduleScreenState();
}

class _TeacherScheduleScreenState extends State<TeacherScheduleScreen> {
  int _weekOffset = 0;
  bool _isWeekly = true;

  String get _weekLabel {
    const base = 'May 20 – 24, 2024';
    if (_weekOffset == 0) return base;
    if (_weekOffset == 1) return 'May 27 – 31, 2024';
    if (_weekOffset == -1) return 'May 13 – 17, 2024';
    return base;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTitle(),
            const SizedBox(height: AppSpacing.sectionGap),
            _buildWeekNav(),
            const SizedBox(height: 12),
            _buildViewToggle(),
            const SizedBox(height: 16),
            _buildTimetable(),
            const SizedBox(height: AppSpacing.sectionGap),
            _buildStatCards(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // ── App bar ────────────────────────────────────────────────────────────────

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.bgPage,
      elevation: 0,
      scrolledUnderElevation: 0,
      toolbarHeight: 64,
      titleSpacing: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, size: 18),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Row(
        children: [
          Image.asset('assets/images/beltei_logo.png', height: 48, fit: BoxFit.contain),
          const SizedBox(width: 10),
          Text('BELTEI Portal', style: AppTextStyles.h3),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined),
          onPressed: () {},
        ),
        const CircleAvatar(
          radius: 16,
          backgroundColor: AppColors.primaryNavy,
          child: Text('JD',
              style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
        ),
        const SizedBox(width: 12),
      ],
    );
  }

  // ── Title ──────────────────────────────────────────────────────────────────

  Widget _buildTitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Academic Weekly Schedule',
            style: AppTextStyles.h1.copyWith(color: AppColors.primaryNavy)),
        Text('Semester II, Academic Year 2023-2024',
            style: AppTextStyles.caption),
      ],
    );
  }

  // ── Week navigator ─────────────────────────────────────────────────────────

  Widget _buildWeekNav() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left, size: 20),
            onPressed: () => setState(() => _weekOffset--),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          Expanded(
            child: Text(
              _weekLabel,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right, size: 20),
            onPressed: () => setState(() => _weekOffset++),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  // ── View toggle ────────────────────────────────────────────────────────────

  Widget _buildViewToggle() {
    return Row(
      children: [
        _ViewChip(
          label: 'Weekly',
          icon: Icons.grid_view_outlined,
          selected: _isWeekly,
          onTap: () => setState(() => _isWeekly = true),
        ),
        const SizedBox(width: 8),
        _ViewChip(
          label: 'Daily',
          icon: Icons.view_day_outlined,
          selected: !_isWeekly,
          onTap: () => setState(() => _isWeekly = false),
        ),
        const Spacer(),
        OutlinedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.print_outlined, size: 14),
          label: const Text('Print'),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            textStyle: AppTextStyles.caption,
          ),
        ),
      ],
    );
  }

  // ── Timetable ──────────────────────────────────────────────────────────────

  Widget _buildTimetable() {
    const hours = [8, 10, 13];
    const double rowH = 100;
    const cols = ['MON\n20 May', 'TUE\n21 May'];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          // Header row
          IntrinsicHeight(
            child: Row(
              children: [
                SizedBox(
                  width: 56,
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Text('TIME',
                        style: AppTextStyles.label.copyWith(fontSize: 10)),
                  ),
                ),
                const VerticalDivider(width: 1, color: AppColors.border),
                ...cols.map((c) => Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        child: Text(c,
                            style: AppTextStyles.label.copyWith(fontSize: 11),
                            textAlign: TextAlign.center),
                      ),
                    )),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.border),
          // Time rows
          ...hours.map((h) {
            final slots =
                _kSlots.where((s) => s.startHour == h).toList();
            return Column(
              children: [
                SizedBox(
                  height: rowH,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(
                        width: 56,
                        child: Center(
                          child: Text(
                            '${h.toString().padLeft(2, '0')}:00',
                            style: AppTextStyles.caption
                                .copyWith(color: AppColors.textSecondary),
                          ),
                        ),
                      ),
                      const VerticalDivider(width: 1, color: AppColors.border),
                      ...List.generate(2, (dayIdx) {
                        final slot = slots.where((s) => s.day == dayIdx).firstOrNull;
                        return Expanded(
                          child: Container(
                            margin: const EdgeInsets.all(4),
                            child: slot != null
                                ? _SlotCard(slot: slot)
                                : const SizedBox.shrink(),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
                const Divider(height: 1, color: AppColors.border),
              ],
            );
          }),
        ],
      ),
    );
  }

  // ── Stat cards ─────────────────────────────────────────────────────────────

  Widget _buildStatCards() {
    final items = [
      (icon: Icons.hourglass_empty_outlined, iconBg: AppColors.primaryNavy,
       label: 'WEEKLY HOURS', value: '$_kWeeklyHours Hours'),
      (icon: Icons.people_outline, iconBg: AppColors.primaryBlue,
       label: 'TOTAL STUDENTS', value: '$_kTotalStudents Total'),
      (icon: Icons.check_circle_outline, iconBg: AppColors.statusAmber,
       label: 'COMPLETED TODAY', value: '2 / 3 Classes'),
    ];
    return Column(
      children: items.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.cardPadding),
              decoration: BoxDecoration(
                color: AppColors.bgCard,
                borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: item.iconBg.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(item.icon, color: item.iconBg, size: 24),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.label, style: AppTextStyles.label),
                      Text(item.value,
                          style: AppTextStyles.metric
                              .copyWith(color: AppColors.textPrimary, fontSize: 20)),
                    ],
                  ),
                ],
              ),
            ),
          )).toList(),
    );
  }
}

// ── Slot card ──────────────────────────────────────────────────────────────────

class _SlotCard extends StatelessWidget {
  const _SlotCard({required this.slot});
  final _ClassSlot slot;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: slot.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border(left: BorderSide(color: slot.color, width: 3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(slot.course,
              style: AppTextStyles.caption.copyWith(
                  fontWeight: FontWeight.w600, color: slot.color, fontSize: 11),
              maxLines: 2,
              overflow: TextOverflow.ellipsis),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.meeting_room_outlined, size: 10, color: AppColors.textSecondary),
              const SizedBox(width: 2),
              Text(slot.room,
                  style: AppTextStyles.caption.copyWith(fontSize: 10),
                  overflow: TextOverflow.ellipsis),
            ],
          ),
          const SizedBox(height: 2),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: slot.color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text('${slot.students} Students',
                style: AppTextStyles.caption
                    .copyWith(color: slot.color, fontSize: 10)),
          ),
        ],
      ),
    );
  }
}

// ── View chip ──────────────────────────────────────────────────────────────────

class _ViewChip extends StatelessWidget {
  const _ViewChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryNavy : AppColors.bgCard,
          borderRadius: BorderRadius.circular(AppSpacing.chipRadius),
          border: Border.all(
              color: selected ? AppColors.primaryNavy : AppColors.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                size: 14,
                color: selected ? Colors.white : AppColors.textSecondary),
            const SizedBox(width: 6),
            Text(label,
                style: AppTextStyles.caption.copyWith(
                    color: selected ? Colors.white : AppColors.textSecondary,
                    fontWeight:
                        selected ? FontWeight.w600 : FontWeight.normal)),
          ],
        ),
      ),
    );
  }
}
