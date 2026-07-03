import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/providers/student_providers.dart';
import '../../../core/services/student_service.dart';

const _kDayOrder = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

// ── Data model ────────────────────────────────────────────────────────────────

class _Slot {
  const _Slot({
    required this.courseName,
    required this.courseCode,
    required this.room,
    required this.teacher,
    required this.startHour,
    required this.endHour,
  });
  final String courseName, courseCode;
  final String? room, teacher;
  final double startHour, endHour; // fractional hours, e.g. 8.5 = 08:30

  String _fmtHour(double h) {
    final wholeH = h.toInt();
    final mins = ((h - wholeH) * 60).round();
    return '${wholeH.toString().padLeft(2, '0')}:${mins.toString().padLeft(2, '0')}';
  }

  String get startLabel => _fmtHour(startHour);
  String get endLabel => _fmtHour(endHour);
}

double _parseHour(String t) {
  final parts = t.split(':');
  if (parts.length < 2) return 0;
  final h = int.tryParse(parts[0]) ?? 0;
  final m = int.tryParse(parts[1]) ?? 0;
  return h + m / 60;
}

Map<String, List<_Slot>> _buildScheduleMap(List<EnrolledCourse> courses) {
  final result = <String, List<_Slot>>{};
  for (final course in courses) {
    if (!course.isCurrentSemester) continue;
    for (final entry in course.schedule) {
      final day = entry['day'] as String?;
      final start = entry['start'] as String?;
      final end = entry['end'] as String?;
      if (day == null || start == null || end == null) continue;
      result.putIfAbsent(day, () => []).add(_Slot(
        courseName: course.name,
        courseCode: course.code,
        room: entry['room'] as String?,
        teacher: course.teacherName,
        startHour: _parseHour(start),
        endHour: _parseHour(end),
      ));
    }
  }
  // Sort each day's slots by start time
  for (final slots in result.values) {
    slots.sort((a, b) => a.startHour.compareTo(b.startHour));
  }
  return result;
}

// ── Screen ────────────────────────────────────────────────────────────────────

class ScheduleScreen extends ConsumerStatefulWidget {
  const ScheduleScreen({super.key});

  @override
  ConsumerState<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends ConsumerState<ScheduleScreen> {
  int _selectedDayIndex = 0;

  @override
  Widget build(BuildContext context) {
    final asyncCourses = ref.watch(studentCoursesProvider);

    return Scaffold(
      backgroundColor: AppColors.bgPage,
      body: asyncCourses.when(
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
                onPressed: () => ref.invalidate(studentCoursesProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (courses) {
          final scheduleMap = _buildScheduleMap(courses);

          // Ordered list of days that have at least one slot
          final activeDays = _kDayOrder
              .where((d) => scheduleMap.containsKey(d))
              .toList();

          // If no days have classes, show all weekdays
          final days = activeDays.isEmpty
              ? _kDayOrder.sublist(0, 5)
              : activeDays;

          final safeIndex =
              _selectedDayIndex.clamp(0, days.length - 1);
          final selectedDay = days[safeIndex];
          final slots = scheduleMap[selectedDay] ?? [];

          // Compute time grid bounds from all slots in this day
          final int firstHour = slots.isEmpty
              ? 8
              : slots.map((s) => s.startHour.toInt()).reduce((a, b) => a < b ? a : b);
          final int lastHour = slots.isEmpty
              ? 16
              : (slots
                      .map((s) => s.endHour.ceil())
                      .reduce((a, b) => a > b ? a : b))
                  .clamp(firstHour + 1, 22);
          final timeSlots =
              List.generate(lastHour - firstHour, (i) => firstHour + i);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(courses),
              _buildDayTabs(days, safeIndex),
              Expanded(
                child: _buildTimeline(slots, timeSlots, firstHour),
              ),
            ],
          );
        },
      ),
    );
  }

  // ── Header ─────────────────────────────────────────────────────────────────

  Widget _buildHeader(List<EnrolledCourse> courses) {
    final currentSem = courses
        .where((c) => c.isCurrentSemester && c.semesterName != null)
        .map((c) => '${c.semesterName} ${c.semesterAcademicYear ?? ''}')
        .firstOrNull;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.md, AppSpacing.sm, AppSpacing.md, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (currentSem != null)
            Text(currentSem.trim().toUpperCase(),
                style: AppTextStyles.label),
          const SizedBox(height: 4),
          Text('Weekly Schedule', style: AppTextStyles.h1),
          const SizedBox(height: AppSpacing.md),
        ],
      ),
    );
  }

  // ── Day tabs ───────────────────────────────────────────────────────────────

  Widget _buildDayTabs(List<String> days, int activeIndex) {
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding:
            const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        itemCount: days.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final isActive = i == activeIndex;
          return GestureDetector(
            onTap: () => setState(() => _selectedDayIndex = i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(
                  horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: isActive
                    ? AppColors.primaryNavy
                    : AppColors.bgCard,
                borderRadius:
                    BorderRadius.circular(AppSpacing.chipRadius),
                border: Border.all(
                  color: isActive
                      ? AppColors.primaryNavy
                      : AppColors.border,
                ),
              ),
              child: Text(
                days[i],
                style: AppTextStyles.bodySemiBold.copyWith(
                  color: isActive
                      ? Colors.white
                      : AppColors.textSecondary,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Timeline ───────────────────────────────────────────────────────────────

  Widget _buildTimeline(
      List<_Slot> slots, List<int> timeSlots, int firstHour) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTimeColumn(timeSlots),
          const SizedBox(width: 8),
          Expanded(child: _buildEventColumn(slots, timeSlots, firstHour)),
        ],
      ),
    );
  }

  Widget _buildTimeColumn(List<int> timeSlots) {
    return Column(
      children: timeSlots.map((hour) {
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

  Widget _buildEventColumn(
      List<_Slot> slots, List<int> timeSlots, int firstHour) {
    if (slots.isEmpty) {
      return SizedBox(
        height: timeSlots.length * 72.0,
        child: Stack(
          children: [
            Column(
              children: timeSlots
                  .map((_) => SizedBox(
                        height: 72,
                        child: Column(children: [
                          Divider(color: AppColors.border, height: 1),
                          Spacer(),
                        ]),
                      ))
                  .toList(),
            ),
            const Center(
              child: Padding(
                padding: EdgeInsets.only(top: 60),
                child: Text('No classes today'),
              ),
            ),
          ],
        ),
      );
    }

    return SizedBox(
      height: timeSlots.length * 72.0,
      child: Stack(
        children: [
          Column(
            children: timeSlots.map((hour) {
              final isLunch = hour == 12;
              return SizedBox(
                height: 72,
                child: Column(
                  children: [
                    if (isLunch)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Expanded(
                                child: Divider(color: AppColors.border)),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8),
                              child: Text('LUNCH BREAK',
                                  style: AppTextStyles.label),
                            ),
                            Expanded(
                                child: Divider(color: AppColors.border)),
                          ],
                        ),
                      )
                    else
                      Divider(color: AppColors.border, height: 1),
                    const Spacer(),
                  ],
                ),
              );
            }).toList(),
          ),
          ...slots.map((slot) => _buildSlotCard(slot, firstHour)),
        ],
      ),
    );
  }

  Widget _buildSlotCard(_Slot slot, int firstHour) {
    final topOffset = (slot.startHour - firstHour) * 72.0;
    final height = (slot.endHour - slot.startHour) * 72.0;

    return Positioned(
      top: topOffset,
      left: 0,
      right: 0,
      height: height.clamp(36.0, double.infinity),
      child: Container(
        margin: const EdgeInsets.only(right: 4, bottom: 2),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          border: Border(
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
                  Text(slot.courseName,
                      style: AppTextStyles.h3,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  if (slot.room != null)
                    Row(
                      children: [
                        Icon(Icons.door_back_door_outlined,
                            size: 13,
                            color: AppColors.textSecondary),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(slot.room!,
                              style: AppTextStyles.caption,
                              overflow: TextOverflow.ellipsis),
                        ),
                      ],
                    ),
                  if (slot.teacher != null) ...[
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(Icons.person_outline,
                            size: 13,
                            color: AppColors.textSecondary),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(slot.teacher!,
                              style: AppTextStyles.caption,
                              overflow: TextOverflow.ellipsis),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color:
                    AppColors.primaryBlue.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${slot.startLabel}\n-\n${slot.endLabel}',
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
