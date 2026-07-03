import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/providers/student_providers.dart';
import '../../../core/supabase/database.types.dart';

// ── Screen ────────────────────────────────────────────────────────────────────

class AttendanceHistoryScreen extends ConsumerStatefulWidget {
  const AttendanceHistoryScreen({super.key});

  @override
  ConsumerState<AttendanceHistoryScreen> createState() =>
      _AttendanceHistoryScreenState();
}

class _AttendanceHistoryScreenState
    extends ConsumerState<AttendanceHistoryScreen> {
  late DateTime _focusedDay;
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
  }

  // ── build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final calendarAsync = ref.watch(studentAttendanceCalendarProvider);

    return Scaffold(
      backgroundColor: AppColors.bgPage,
      appBar: AppBar(
        backgroundColor: AppColors.bgPage,
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        toolbarHeight: 64,
        titleSpacing: 0,
        title: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Row(
            children: [
              Image.asset('assets/images/beltei_logo.png',
                  height: 48, fit: BoxFit.contain),
              const SizedBox(width: 10),
              Text('BELTEI Portal',
                  style: AppTextStyles.h3
                      .copyWith(color: AppColors.primaryNavy)),
            ],
          ),
        ),
      ),
      body: calendarAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline,
                  color: AppColors.statusRed, size: 40),
              const SizedBox(height: 8),
              Text('Could not load attendance', style: AppTextStyles.body),
              TextButton(
                onPressed: () =>
                    ref.invalidate(studentAttendanceCalendarProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (calendarMap) => SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStatsRow(calendarMap),
              const SizedBox(height: AppSpacing.sectionGap),
              _buildCalendar(calendarMap),
              const SizedBox(height: AppSpacing.sectionGap),
              _buildLegend(),
              if (_selectedDay != null) ...[
                const SizedBox(height: AppSpacing.sectionGap),
                _buildSelectedDayCard(calendarMap),
              ],
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // ── Stats row ──────────────────────────────────────────────────────────────

  Widget _buildStatsRow(Map<String, AttendanceStatus> map) {
    int present = 0, absent = 0;
    for (final s in map.values) {
      if (s == AttendanceStatus.present) present++;
      if (s == AttendanceStatus.absent) absent++;
    }
    final total = map.length;
    final pct =
        total > 0 ? (present / total * 100).toStringAsFixed(0) : '—';

    return Row(
      children: [
        _StatCard('Attendance', '$pct%', AppColors.primaryNavy, Icons.check_circle_outline),
        const SizedBox(width: 10),
        _StatCard('Present', '$present', AppColors.statusGreen, Icons.thumb_up_outlined),
        const SizedBox(width: 10),
        _StatCard('Absent', '$absent', AppColors.statusRed, Icons.cancel_outlined),
      ],
    );
  }

  // ── Calendar ───────────────────────────────────────────────────────────────

  Widget _buildCalendar(Map<String, AttendanceStatus> map) {
    final now = DateTime.now();
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
          Text('Attendance History', style: AppTextStyles.h2),
          const SizedBox(height: 4),
          TableCalendar(
            firstDay: DateTime(now.year - 1, 1),
            lastDay: DateTime(now.year + 1, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selected, focused) {
              setState(() {
                _selectedDay = selected;
                _focusedDay = focused;
              });
            },
            onPageChanged: (focused) =>
                setState(() => _focusedDay = focused),
            headerStyle: HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
              titleTextStyle: AppTextStyles.bodySemiBold,
              leftChevronIcon: Icon(Icons.chevron_left,
                  color: AppColors.textPrimary),
              rightChevronIcon: Icon(Icons.chevron_right,
                  color: AppColors.textPrimary),
            ),
            calendarStyle: CalendarStyle(
              outsideDaysVisible: true,
              todayDecoration: BoxDecoration(
                color: AppColors.primaryNavy.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              todayTextStyle:
                  AppTextStyles.body.copyWith(color: AppColors.primaryNavy),
              selectedDecoration: BoxDecoration(
                color: AppColors.primaryBlue,
                shape: BoxShape.circle,
              ),
              defaultTextStyle: AppTextStyles.body,
            ),
            calendarBuilders: CalendarBuilders(
              defaultBuilder: (context, day, _) =>
                  _dayBuilder(day, map),
              outsideBuilder: (context, day, _) =>
                  _dayBuilder(day, map, isOutside: true),
              todayBuilder: (context, day, _) =>
                  _dayBuilder(day, map, isToday: true),
              selectedBuilder: (context, day, _) =>
                  _dayBuilder(day, map, isSelected: true),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dayBuilder(
    DateTime day,
    Map<String, AttendanceStatus> map, {
    bool isOutside = false,
    bool isToday = false,
    bool isSelected = false,
  }) {
    final key =
        '${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';
    final status = map[key];

    Color? bg;
    Color textColor =
        isOutside ? AppColors.textLabel : AppColors.textPrimary;

    if (isSelected) {
      bg = AppColors.primaryBlue;
      textColor = Colors.white;
    } else if (status != null && !isOutside) {
      switch (status) {
        case AttendanceStatus.present:
          bg = AppColors.primaryNavy;
          textColor = Colors.white;
        case AttendanceStatus.absent:
          bg = AppColors.statusRed;
          textColor = Colors.white;
        case AttendanceStatus.late:
          bg = AppColors.statusAmber;
          textColor = Colors.white;
        case AttendanceStatus.excused:
          bg = AppColors.primaryBlue.withValues(alpha: 0.7);
          textColor = Colors.white;
      }
    } else if (isToday && status == null) {
      bg = AppColors.primaryNavy.withValues(alpha: 0.15);
      textColor = AppColors.primaryNavy;
    }

    return Center(
      child: Container(
        width: 32,
        height: 32,
        decoration: bg != null
            ? BoxDecoration(color: bg, shape: BoxShape.circle)
            : null,
        child: Center(
          child: Text(
            '${day.day}',
            style: AppTextStyles.body.copyWith(
              color: textColor,
              fontWeight:
                  bg != null ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  // ── Selected day card ──────────────────────────────────────────────────────

  Widget _buildSelectedDayCard(Map<String, AttendanceStatus> map) {
    if (_selectedDay == null) return const SizedBox.shrink();
    final d = _selectedDay!;
    final key =
        '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
    final status = map[key];

    return Container(
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline,
              size: 20, color: AppColors.textLabel),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${d.day} ${_kMonthNames[d.month]} ${d.year}',
                  style: AppTextStyles.bodyMedium,
                ),
                const SizedBox(height: 2),
                Text(
                  status == null
                      ? 'No attendance recorded'
                      : _statusLabel(status),
                  style: AppTextStyles.caption.copyWith(
                    color: status == null
                        ? AppColors.textSecondary
                        : _statusColor(status),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static String _statusLabel(AttendanceStatus s) => switch (s) {
        AttendanceStatus.present => 'Present',
        AttendanceStatus.absent => 'Absent',
        AttendanceStatus.late => 'Late',
        AttendanceStatus.excused => 'Excused Absence',
      };

  static Color _statusColor(AttendanceStatus s) => switch (s) {
        AttendanceStatus.present => AppColors.statusGreen,
        AttendanceStatus.absent => AppColors.statusRed,
        AttendanceStatus.late => AppColors.statusAmber,
        AttendanceStatus.excused => AppColors.primaryBlue,
      };

  static const _kMonthNames = [
    '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  // ── Legend ─────────────────────────────────────────────────────────────────

  Widget _buildLegend() {
    final items = [
      (color: AppColors.primaryNavy, label: 'Present'),
      (color: AppColors.statusRed, label: 'Absent'),
      (color: AppColors.statusAmber, label: 'Late'),
      (color: AppColors.primaryBlue.withValues(alpha: 0.7), label: 'Excused'),
      (color: AppColors.statusGrayBg, label: 'No Record'),
    ];

    return Wrap(
      spacing: 20,
      runSpacing: 8,
      children: items
          .map((item) => Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                        color: item.color, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 6),
                  Text(item.label, style: AppTextStyles.caption),
                ],
              ))
          .toList(),
    );
  }
}

// ── Stat card ──────────────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  const _StatCard(this.label, this.value, this.color, this.icon);
  final String label, value;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(height: 6),
            Text(value,
                style: AppTextStyles.metric
                    .copyWith(color: color, fontSize: 20)),
            Text(label, style: AppTextStyles.caption),
          ],
        ),
      ),
    );
  }
}
