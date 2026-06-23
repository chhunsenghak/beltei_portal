import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';

// ── Mock calendar data ─────────────────────────────────────────────────────────

final _presentDays = {19, 12, 11, 10, 8, 5, 4, 3};
final _absentDays = {6, 15};
final _leaveDays = {9};

class AttendanceHistoryScreen extends StatefulWidget {
  const AttendanceHistoryScreen({super.key});

  @override
  State<AttendanceHistoryScreen> createState() => _AttendanceHistoryScreenState();
}

class _AttendanceHistoryScreenState extends State<AttendanceHistoryScreen> {
  DateTime _focusedDay = DateTime(2024, 2);
  DateTime? _selectedDay;

  // ── build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
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
              Image.asset('assets/images/beltei_logo.png', height: 48, fit: BoxFit.contain),
              const SizedBox(width: 10),
              Text('BELTEI Campus', style: AppTextStyles.h3.copyWith(color: AppColors.primaryNavy)),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCalendar(),
            const SizedBox(height: AppSpacing.sectionGap),
            _buildLegend(),
          ],
        ),
      ),
    );
  }

  // ── Calendar ───────────────────────────────────────────────────────────────

  Widget _buildCalendar() {
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
            firstDay: DateTime(2024, 1),
            lastDay: DateTime(2024, 12),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selected, focused) {
              setState(() {
                _selectedDay = selected;
                _focusedDay = focused;
              });
            },
            onPageChanged: (focused) => setState(() => _focusedDay = focused),
            headerStyle: HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
              titleTextStyle: AppTextStyles.bodySemiBold,
              leftChevronIcon:
                  const Icon(Icons.chevron_left, color: AppColors.textPrimary),
              rightChevronIcon:
                  const Icon(Icons.chevron_right, color: AppColors.textPrimary),
            ),
            calendarStyle: CalendarStyle(
              outsideDaysVisible: true,
              todayDecoration: BoxDecoration(
                color: AppColors.primaryNavy,
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: AppColors.primaryBlue,
                shape: BoxShape.circle,
              ),
              defaultTextStyle: AppTextStyles.body,
            ),
            calendarBuilders: CalendarBuilders(
              defaultBuilder: (context, day, focusedDay) =>
                  _dayBuilder(day),
              outsideBuilder: (context, day, focusedDay) =>
                  _dayBuilder(day, isOutside: true),
            ),
          ),
        ],
      ),
    );
  }

  Widget? _dayBuilder(DateTime day, {bool isOutside = false}) {
    final d = day.day;
    Color? bg;
    Color textColor =
        isOutside ? AppColors.textLabel : AppColors.textPrimary;

    if (!isOutside && _presentDays.contains(d) && day.month == 2) {
      bg = AppColors.primaryNavy;
      textColor = Colors.white;
    } else if (!isOutside && _absentDays.contains(d) && day.month == 2) {
      bg = AppColors.statusRed;
      textColor = Colors.white;
    } else if (!isOutside && _leaveDays.contains(d) && day.month == 2) {
      bg = AppColors.statusAmber;
      textColor = Colors.white;
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
                fontWeight: bg != null ? FontWeight.bold : FontWeight.normal),
          ),
        ),
      ),
    );
  }

  // ── Legend ─────────────────────────────────────────────────────────────────

  Widget _buildLegend() {
    final items = [
      (color: AppColors.primaryNavy, label: 'Present'),
      (color: AppColors.statusRed, label: 'Absent'),
      (color: AppColors.statusAmber, label: 'Leave'),
      (color: AppColors.statusGrayBg, label: 'No Class'),
    ];

    return Wrap(
      spacing: 20,
      runSpacing: 8,
      children: items.map((item) => Row(
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
          )).toList(),
    );
  }
}
