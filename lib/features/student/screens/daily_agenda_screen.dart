import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/providers/student_providers.dart';
import '../../../core/services/student_service.dart';

// ── Screen ────────────────────────────────────────────────────────────────────

class DailyAgendaScreen extends ConsumerWidget {
  const DailyAgendaScreen({super.key});

  static const _kDayAbbr = [
    'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'
  ];

  static const _kMonthName = [
    '', 'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];

  static const _kDayName = [
    '', 'Monday', 'Tuesday', 'Wednesday', 'Thursday',
    'Friday', 'Saturday', 'Sunday',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coursesAsync = ref.watch(studentCoursesProvider);
    final today = DateTime.now();
    final todayAbbr = _kDayAbbr[today.weekday - 1];

    return Scaffold(
      backgroundColor: AppColors.bgPage,
      appBar: AppBar(
        backgroundColor: AppColors.bgPage,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 18),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('Daily Agenda', style: AppTextStyles.h3),
      ),
      body: coursesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => Center(
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
          final agenda = _buildAgenda(courses, todayAbbr);
          return SingleChildScrollView(
            padding:
                const EdgeInsets.all(AppSpacing.screenPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDateBanner(today, agenda.length),
                const SizedBox(height: AppSpacing.sectionGap),
                if (agenda.isEmpty)
                  _buildEmptyState(todayAbbr)
                else
                  ...agenda.map((a) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _AgendaCard(
                          time: a.time,
                          title: a.title,
                          room: a.room,
                          teacher: a.teacher,
                          code: a.code,
                        ),
                      )),
              ],
            ),
          );
        },
      ),
    );
  }

  // ── Agenda builder ─────────────────────────────────────────────────────────

  List<
      ({
        String time,
        String title,
        String room,
        String teacher,
        String code,
        String sortKey
      })> _buildAgenda(List<EnrolledCourse> courses, String todayAbbr) {
    final agenda = <
        ({
          String time,
          String title,
          String room,
          String teacher,
          String code,
          String sortKey
        })>[];

    for (final course in courses.where((c) => c.isCurrentSemester)) {
      for (final slot in course.schedule) {
        if ((slot['day'] as String?) == todayAbbr) {
          final start = slot['start'] as String? ?? '';
          agenda.add((
            time: _formatTime(start),
            title: course.name,
            room: slot['room'] as String? ?? '',
            teacher: course.teacherName ?? '',
            code: course.code,
            sortKey: start,
          ));
        }
      }
    }

    agenda.sort((a, b) => a.sortKey.compareTo(b.sortKey));
    return agenda;
  }

  // ── Time formatter ─────────────────────────────────────────────────────────

  static String _formatTime(String hhmm) {
    if (hhmm.isEmpty) return '';
    final parts = hhmm.split(':');
    if (parts.length < 2) return hhmm;
    final hour = int.tryParse(parts[0]) ?? 0;
    final min = parts[1];
    final suffix = hour < 12 ? 'AM' : 'PM';
    final h = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    return '$h:$min $suffix';
  }

  // ── Date banner ────────────────────────────────────────────────────────────

  Widget _buildDateBanner(DateTime today, int count) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.primaryNavy,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
      ),
      child: Row(
        children: [
          const Icon(Icons.calendar_today, color: Colors.white, size: 20),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_kDayName[today.weekday], style: AppTextStyles.h2White),
              Text(
                '${_kMonthName[today.month]} ${today.day}, ${today.year}',
                style: AppTextStyles.captionWhite,
              ),
            ],
          ),
          const Spacer(),
          Text(
            count == 0 ? 'No Classes' : '$count ${count == 1 ? 'Class' : 'Classes'}',
            style: AppTextStyles.bodyWhite,
          ),
        ],
      ),
    );
  }

  // ── Empty state ────────────────────────────────────────────────────────────

  Widget _buildEmptyState(String dayAbbr) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 48),
      alignment: Alignment.center,
      child: Column(
        children: [
          Icon(Icons.event_available_outlined,
              size: 48, color: AppColors.textLabel),
          const SizedBox(height: 12),
          Text('No classes today', style: AppTextStyles.h3),
          const SizedBox(height: 4),
          Text('Enjoy your free day!',
              style: AppTextStyles.body
                  .copyWith(color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

// ── Agenda card ────────────────────────────────────────────────────────────────

class _AgendaCard extends StatelessWidget {
  const _AgendaCard({
    required this.time,
    required this.title,
    required this.room,
    required this.teacher,
    required this.code,
  });

  final String time, title, room, teacher, code;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border(
            left: BorderSide(color: AppColors.primaryNavy, width: 3)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04), blurRadius: 4),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTimeChip(),
          const SizedBox(width: 12),
          Expanded(child: _buildDetails()),
        ],
      ),
    );
  }

  Widget _buildTimeChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.statusBlueBg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        time,
        style: AppTextStyles.caption.copyWith(
            color: AppColors.primaryBlue, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: Text(title, style: AppTextStyles.h3)),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.statusGrayBg,
                borderRadius: BorderRadius.circular(AppSpacing.tagRadius),
              ),
              child: Text(code,
                  style: AppTextStyles.label
                      .copyWith(color: AppColors.textSecondary)),
            ),
          ],
        ),
        if (room.isNotEmpty) ...[
          const SizedBox(height: 4),
          Row(children: [
            Icon(Icons.door_back_door_outlined,
                size: 13, color: AppColors.textSecondary),
            const SizedBox(width: 4),
            Text(room, style: AppTextStyles.caption),
          ]),
        ],
        if (teacher.isNotEmpty) ...[
          const SizedBox(height: 2),
          Row(children: [
            Icon(Icons.person_outline,
                size: 13, color: AppColors.textSecondary),
            const SizedBox(width: 4),
            Text(teacher, style: AppTextStyles.caption),
          ]),
        ],
      ],
    );
  }
}
