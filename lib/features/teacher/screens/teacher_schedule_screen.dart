import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/providers/teacher_providers.dart';
import '../../../core/services/teacher_service.dart';

// Day order for sorting
const _kDayOrder = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

final _kSlotColors = [
  AppColors.primaryNavy,
  AppColors.primaryBlue,
  Color(0xFF0EA5E9),
  Color(0xFF7C3AED),
  AppColors.statusAmber,
  AppColors.statusGreen,
];

// Parses "08:30" → 8.5 (fractional hours)
double _parseHour(String time) {
  final parts = time.split(':');
  if (parts.length != 2) return 0;
  return double.parse(parts[0]) + double.parse(parts[1]) / 60;
}

// ── Screen ────────────────────────────────────────────────────────────────────

class TeacherScheduleScreen extends ConsumerStatefulWidget {
  const TeacherScheduleScreen({super.key});

  @override
  ConsumerState<TeacherScheduleScreen> createState() =>
      _TeacherScheduleScreenState();
}

class _TeacherScheduleScreenState
    extends ConsumerState<TeacherScheduleScreen> {
  int _weekOffset = 0;

  /// Returns the date of Monday for the current week + offset
  DateTime _weekStart() {
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    return monday.add(Duration(days: _weekOffset * 7));
  }

  String _weekLabel() {
    final monday = _weekStart();
    final friday = monday.add(const Duration(days: 4));
    final months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${monday.day} ${months[monday.month]} – '
        '${friday.day} ${months[friday.month]}, ${monday.year}';
  }

  String _dayDateLabel(String day, DateTime weekStart) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    final idx = days.indexOf(day);
    if (idx < 0) return day;
    final date = weekStart.add(Duration(days: idx));
    return '${day.toUpperCase()}\n${date.day}';
  }

  @override
  Widget build(BuildContext context) {
    final coursesAsync = ref.watch(teacherCoursesProvider);

    return Scaffold(
      backgroundColor: AppColors.bgPage,
      appBar: _buildAppBar(context),
      body: coursesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline,
                  color: AppColors.statusRed, size: 40),
              const SizedBox(height: 8),
              Text('Could not load schedule', style: AppTextStyles.body),
              TextButton(
                onPressed: () => ref.invalidate(teacherCoursesProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (courses) {
          final currentCourses =
              courses.where((c) => c.isCurrentSemester).toList();
          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.screenPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTitle(),
                const SizedBox(height: AppSpacing.sectionGap),
                _buildWeekNav(),
                const SizedBox(height: 16),
                _buildTimetable(currentCourses),
                const SizedBox(height: AppSpacing.sectionGap),
                _buildStatCards(currentCourses),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
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
          Image.asset('assets/images/beltei_logo.png',
              height: 48, fit: BoxFit.contain),
          const SizedBox(width: 10),
          Text('BELTEI Portal', style: AppTextStyles.h3),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined),
          onPressed: () {},
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
        Text('Current Semester', style: AppTextStyles.caption),
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
              _weekLabel(),
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

  // ── Timetable ──────────────────────────────────────────────────────────────

  Widget _buildTimetable(List<TeacherCourse> courses) {
    if (courses.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(AppSpacing.cardPadding),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          border: Border.all(color: AppColors.border),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text('No scheduled classes this semester.',
                style: AppTextStyles.body
                    .copyWith(color: AppColors.textSecondary)),
          ),
        ),
      );
    }

    // Build: day → startTime → {course, end, room, color}
    final Map<String, Map<String, _SlotData>> grid = {};
    for (var i = 0; i < courses.length; i++) {
      final course = courses[i];
      final color = _kSlotColors[i % _kSlotColors.length];
      for (final slot in course.schedule) {
        final day = (slot['day'] as String?) ?? '';
        final start = (slot['start'] as String?) ?? '';
        final end = (slot['end'] as String?) ?? '';
        final room = (slot['room'] as String?) ?? course.room ?? '';
        if (day.isEmpty || start.isEmpty) continue;
        grid.putIfAbsent(day, () => {});
        grid[day]![start] = _SlotData(
          courseName: course.name,
          room: room,
          start: start,
          end: end,
          studentCount: course.studentCount,
          color: color,
        );
      }
    }

    if (grid.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(AppSpacing.cardPadding),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          border: Border.all(color: AppColors.border),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text('No schedule data available.',
                style: AppTextStyles.body
                    .copyWith(color: AppColors.textSecondary)),
          ),
        ),
      );
    }

    // Collect unique days, sorted by _kDayOrder
    final days = grid.keys.toList()
      ..sort((a, b) {
        final ai = _kDayOrder.indexOf(a);
        final bi = _kDayOrder.indexOf(b);
        return (ai < 0 ? 99 : ai).compareTo(bi < 0 ? 99 : bi);
      });

    // Collect unique start times, sorted
    final startTimes = grid.values
        .expand((m) => m.keys)
        .toSet()
        .toList()
      ..sort((a, b) => _parseHour(a).compareTo(_parseHour(b)));

    final weekStart = _weekStart();
    const double rowH = 100;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          // Header
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
                VerticalDivider(width: 1, color: AppColors.border),
                ...days.map((d) => Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        child: Text(
                          _dayDateLabel(d, weekStart),
                          style: AppTextStyles.label.copyWith(fontSize: 11),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )),
              ],
            ),
          ),
          Divider(height: 1, color: AppColors.border),
          // Time rows
          ...startTimes.map((startTime) {
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
                            startTime,
                            style: AppTextStyles.caption.copyWith(
                                color: AppColors.textSecondary),
                          ),
                        ),
                      ),
                      VerticalDivider(
                          width: 1, color: AppColors.border),
                      ...days.map((day) {
                        final slot = grid[day]?[startTime];
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
                Divider(height: 1, color: AppColors.border),
              ],
            );
          }),
        ],
      ),
    );
  }

  // ── Stat cards ─────────────────────────────────────────────────────────────

  Widget _buildStatCards(List<TeacherCourse> courses) {
    // Compute total weekly hours from all schedule slots
    double totalHours = 0;
    for (final c in courses) {
      for (final slot in c.schedule) {
        final start = (slot['start'] as String?) ?? '';
        final end = (slot['end'] as String?) ?? '';
        if (start.isNotEmpty && end.isNotEmpty) {
          totalHours += _parseHour(end) - _parseHour(start);
        }
      }
    }
    final totalStudents =
        courses.fold<int>(0, (s, c) => s + c.studentCount);
    final todayCount = courses.where((c) => c.hasTodayClass()).length;

    final items = [
      (
        icon: Icons.hourglass_empty_outlined,
        iconBg: AppColors.primaryNavy,
        label: 'WEEKLY HOURS',
        value: '${totalHours.toStringAsFixed(1)} Hours'
      ),
      (
        icon: Icons.people_outline,
        iconBg: AppColors.primaryBlue,
        label: 'TOTAL STUDENTS',
        value: '$totalStudents Students'
      ),
      (
        icon: Icons.check_circle_outline,
        iconBg: AppColors.statusAmber,
        label: 'CLASSES TODAY',
        value: '$todayCount Classes'
      ),
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
                          style: AppTextStyles.metric.copyWith(
                              color: AppColors.textPrimary, fontSize: 20)),
                    ],
                  ),
                ],
              ),
            ),
          )).toList(),
    );
  }
}

// ── Slot data ──────────────────────────────────────────────────────────────────

class _SlotData {
  const _SlotData({
    required this.courseName,
    required this.room,
    required this.start,
    required this.end,
    required this.studentCount,
    required this.color,
  });
  final String courseName, room, start, end;
  final int studentCount;
  final Color color;
}

// ── Slot card ──────────────────────────────────────────────────────────────────

class _SlotCard extends StatelessWidget {
  const _SlotCard({required this.slot});
  final _SlotData slot;

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
          Text(slot.courseName,
              style: AppTextStyles.caption.copyWith(
                  fontWeight: FontWeight.w600,
                  color: slot.color,
                  fontSize: 11),
              maxLines: 2,
              overflow: TextOverflow.ellipsis),
          const SizedBox(height: 4),
          if (slot.room.isNotEmpty)
            Row(
              children: [
                Icon(Icons.meeting_room_outlined,
                    size: 10, color: AppColors.textSecondary),
                const SizedBox(width: 2),
                Expanded(
                  child: Text(slot.room,
                      style: AppTextStyles.caption.copyWith(fontSize: 10),
                      overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
          const SizedBox(height: 2),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: slot.color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text('${slot.studentCount} Students',
                style: AppTextStyles.caption
                    .copyWith(color: slot.color, fontSize: 10)),
          ),
        ],
      ),
    );
  }
}

