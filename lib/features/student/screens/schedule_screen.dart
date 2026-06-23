import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';

// ── Mock data ──────────────────────────────────────────────────────────────────

class _ClassItem {
  const _ClassItem({
    required this.title,
    required this.room,
    required this.professor,
    required this.startHour,
    required this.endHour,
    required this.startMinute,
    required this.endMinute,
  });
  final String title, room, professor;
  final int startHour, endHour, startMinute, endMinute;

  String get startLabel =>
      '${startHour.toString().padLeft(2, '0')}:${startMinute.toString().padLeft(2, '0')} '
      '${startHour < 12 ? 'AM' : 'PM'}';
  String get endLabel =>
      '${endHour.toString().padLeft(2, '0')}:${endMinute.toString().padLeft(2, '0')} '
      '${endHour < 12 ? 'AM' : 'PM'}';
  String get rangeLabel =>
      '${startHour.toString().padLeft(2, '0')}:${startMinute.toString().padLeft(2, '0')}\n'
      '-\n'
      '${endHour.toString().padLeft(2, '0')}:${endMinute.toString().padLeft(2, '0')}';
}

final _kScheduleByDay = <String, List<_ClassItem>>{
  'Mon': [
    _ClassItem(
      title: 'Advanced Algorithms & Complexity',
      room: 'Room 402, Science Wing',
      professor: 'Dr. Sarah Jenkins',
      startHour: 8, startMinute: 30,
      endHour: 10, endMinute: 0,
    ),
    _ClassItem(
      title: 'Database Management Systems',
      room: 'Lab 12, Tech Center',
      professor: 'Prof. Michael Chen',
      startHour: 10, startMinute: 30,
      endHour: 12, endMinute: 0,
    ),
    _ClassItem(
      title: 'Software Engineering Principles',
      room: 'Auditorium B',
      professor: 'Dr. Elena Rodriguez',
      startHour: 13, startMinute: 30,
      endHour: 15, endMinute: 0,
    ),
  ],
  'Tue': [
    _ClassItem(
      title: 'Computer Networks',
      room: 'Room 305',
      professor: 'Prof. Alan Wu',
      startHour: 9, startMinute: 0,
      endHour: 10, endMinute: 30,
    ),
    _ClassItem(
      title: 'Operating Systems',
      room: 'Lab 8',
      professor: 'Dr. Mark Bloom',
      startHour: 14, startMinute: 0,
      endHour: 15, endMinute: 30,
    ),
  ],
  'Wed': [
    _ClassItem(
      title: 'Advanced Algorithms & Complexity',
      room: 'Room 402, Science Wing',
      professor: 'Dr. Sarah Jenkins',
      startHour: 8, startMinute: 30,
      endHour: 10, endMinute: 0,
    ),
  ],
  'Thu': [
    _ClassItem(
      title: 'Database Management Systems',
      room: 'Lab 12, Tech Center',
      professor: 'Prof. Michael Chen',
      startHour: 10, startMinute: 30,
      endHour: 12, endMinute: 0,
    ),
    _ClassItem(
      title: 'Software Engineering Principles',
      room: 'Auditorium B',
      professor: 'Dr. Elena Rodriguez',
      startHour: 13, startMinute: 30,
      endHour: 15, endMinute: 0,
    ),
  ],
  'Fri': [
    _ClassItem(
      title: 'Computer Networks',
      room: 'Room 305',
      professor: 'Prof. Alan Wu',
      startHour: 9, startMinute: 0,
      endHour: 10, endMinute: 30,
    ),
  ],
};

const _kDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'];
const _kTimeSlots = [8, 9, 10, 11, 12, 13, 14, 15];

// ── Screen ────────────────────────────────────────────────────────────────────

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  int _selectedDayIndex = 0;

  String get _selectedDay => _kDays[_selectedDayIndex];
  List<_ClassItem> get _classes => _kScheduleByDay[_selectedDay] ?? [];

  // ── build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      appBar: _buildAppBar(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          _buildDayTabs(),
          Expanded(child: _buildTimeline()),
        ],
      ),
    );
  }

  // ── App bar ────────────────────────────────────────────────────────────────

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
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
      actions: [
        IconButton(
          icon: const Icon(Icons.search, color: AppColors.textPrimary),
          onPressed: () {},
        ),
      ],
    );
  }

  // ── Header ─────────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.sm, AppSpacing.md, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('ACADEMIC YEAR 2024', style: AppTextStyles.label),
          const SizedBox(height: 4),
          Text('Weekly Schedule', style: AppTextStyles.h1),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.statusGrayBg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.filter_list, size: 16, color: AppColors.textSecondary),
                const SizedBox(width: 6),
                Text('Semester 1', style: AppTextStyles.bodyMedium),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
        ],
      ),
    );
  }

  // ── Day tabs ───────────────────────────────────────────────────────────────

  Widget _buildDayTabs() {
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        itemCount: _kDays.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final isActive = i == _selectedDayIndex;
          return GestureDetector(
            onTap: () => setState(() => _selectedDayIndex = i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: isActive ? AppColors.primaryNavy : AppColors.bgCard,
                borderRadius: BorderRadius.circular(AppSpacing.chipRadius),
                border: Border.all(
                  color: isActive ? AppColors.primaryNavy : AppColors.border,
                ),
              ),
              child: Text(
                _kDays[i],
                style: AppTextStyles.bodySemiBold.copyWith(
                  color: isActive ? Colors.white : AppColors.textSecondary,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Timeline ───────────────────────────────────────────────────────────────

  Widget _buildTimeline() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTimeColumn(),
          const SizedBox(width: 8),
          Expanded(child: _buildEventColumn()),
        ],
      ),
    );
  }

  Widget _buildTimeColumn() {
    return Column(
      children: _kTimeSlots.map((hour) {
        final label = hour < 12
            ? '${hour.toString().padLeft(2, '0')}:00 AM'
            : hour == 12
                ? '12:00 PM'
                : '${(hour - 12).toString().padLeft(2, '0')}:00 PM';
        return SizedBox(
          height: 72,
          child: Align(
            alignment: Alignment.topRight,
            child: Text(label,
                style: AppTextStyles.caption.copyWith(fontSize: 11)),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildEventColumn() {
    if (_classes.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.only(top: 60),
          child: Text('No classes today'),
        ),
      );
    }

    return Stack(
      children: [
        // Divider lines per time slot
        Column(
          children: _kTimeSlots.map((hour) {
            final isLunch = hour == 13;
            return SizedBox(
              height: 72,
              child: Column(
                children: [
                  if (isLunch)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          const Expanded(child: Divider(color: AppColors.border)),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Text('LUNCH BREAK', style: AppTextStyles.label),
                          ),
                          const Expanded(child: Divider(color: AppColors.border)),
                        ],
                      ),
                    )
                  else
                    const Divider(color: AppColors.border, height: 1),
                  const Spacer(),
                ],
              ),
            );
          }).toList(),
        ),
        // Class cards
        ..._classes.map((cls) => _buildClassCard(cls)),
      ],
    );
  }

  Widget _buildClassCard(_ClassItem cls) {
    final topOffset = (cls.startHour - _kTimeSlots.first) * 72.0 +
        cls.startMinute / 60 * 72.0;
    final durationHours =
        (cls.endHour - cls.startHour) + (cls.endMinute - cls.startMinute) / 60;
    final height = durationHours * 72.0;

    return Positioned(
      top: topOffset,
      left: 0,
      right: 0,
      height: height,
      child: Container(
        margin: const EdgeInsets.only(right: 4, bottom: 2),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          border: const Border(
            left: BorderSide(color: AppColors.primaryNavy, width: 3),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(cls.title,
                      style: AppTextStyles.h3,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.door_back_door_outlined,
                          size: 13, color: AppColors.textSecondary),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(cls.room,
                            style: AppTextStyles.caption,
                            overflow: TextOverflow.ellipsis),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(Icons.person_outline,
                          size: 13, color: AppColors.textSecondary),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(cls.professor,
                            style: AppTextStyles.caption,
                            overflow: TextOverflow.ellipsis),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Text(
                '${cls.startHour.toString().padLeft(2, '0')}:${cls.startMinute.toString().padLeft(2, '0')}\n-\n${cls.endHour.toString().padLeft(2, '0')}:${cls.endMinute.toString().padLeft(2, '0')}',
                textAlign: TextAlign.center,
                style: AppTextStyles.caption.copyWith(
                    color: AppColors.primaryBlue,
                    fontWeight: FontWeight.bold,
                    fontSize: 11),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
