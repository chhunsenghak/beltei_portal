import 'dart:io' as io;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:excel/excel.dart' hide Border;
import 'package:flutter/foundation.dart' show kIsWeb;
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/providers/auth_provider.dart';
import '../../auth/models/app_user.dart';
import '../../../core/providers/teacher_providers.dart';
import '../../../core/services/teacher_service.dart';
import '../../../core/supabase/database.types.dart';
import '../../../l10n/app_localizations.dart';

// ── Screen ────────────────────────────────────────────────────────────────────

class MarkAttendanceScreen extends ConsumerStatefulWidget {
  const MarkAttendanceScreen({super.key, required this.courseId});
  final String courseId;

  @override
  ConsumerState<MarkAttendanceScreen> createState() =>
      _MarkAttendanceScreenState();
}

class _MarkAttendanceScreenState extends ConsumerState<MarkAttendanceScreen> {
  // key: studentId_date, value: 'P' | 'A' | 'L' | 'LV'
  final Map<String, String?> _statuses = {};
  int _selectedWeek = -1;
  bool _saving = false;
  bool _initialized = false;

  void _initStatuses(List<CourseStudent> students, List<StudentLeaveDetail> leaves, Map<String, String> allExisting) {
    if (_initialized) return;
    _initialized = true;
    allExisting.forEach((key, dbStatus) {
      _statuses[key] = dbStatus == 'present'
          ? 'P'
          : dbStatus == 'absent'
              ? 'A'
              : dbStatus == 'late'
                  ? 'L'
                  : 'LV';
    });
  }

  int getSessionNumberForIndex(List<dynamic> schedule, int index) {
    if (schedule.isEmpty) return 1;
    const dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final sortedSchedule = List<Map<String, dynamic>>.from(schedule)
      ..sort((a, b) {
        final dayA = a['day'] as String? ?? 'Mon';
        final dayB = b['day'] as String? ?? 'Mon';
        final idxA = dayNames.indexOf(dayA);
        final idxB = dayNames.indexOf(dayB);
        final dayCompare = idxA.compareTo(idxB);
        if (dayCompare != 0) return dayCompare;
        
        final startA = a['start'] as String? ?? '00:00';
        final startB = b['start'] as String? ?? '00:00';
        return startA.compareTo(startB);
      });

    if (index < 0 || index >= sortedSchedule.length) return 1;
    final targetSlot = sortedSchedule[index];
    final targetDay = targetSlot['day'] as String? ?? 'Mon';
    
    int sessionNum = 1;
    for (int i = 0; i < index; i++) {
      final slot = sortedSchedule[i];
      final day = slot['day'] as String? ?? 'Mon';
      if (day == targetDay) {
        sessionNum++;
      }
    }
    return sessionNum;
  }

  String _getWeekRangeStr(TeacherCourse? course, int weekNum) {
    if (course == null || course.semesterStartDate == null) return '';
    final start = DateTime.tryParse(course.semesterStartDate!);
    if (start == null) return '';

    final semesterStartMonday = start.subtract(Duration(days: start.weekday - 1));
    final weekMonday = semesterStartMonday.add(Duration(days: (weekNum - 1) * 7));
    final weekSunday = weekMonday.add(const Duration(days: 6));
    final fmt = DateFormat('MMMM dd, yyyy');
    return '${fmt.format(weekMonday)} to ${fmt.format(weekSunday)}';
  }

  bool _hasChanges(List<CourseStudent> students, List<DateTime> sessionDates, Map<String, String> allExisting, List<dynamic> schedule) {
    for (final s in students) {
      for (int i = 0; i < sessionDates.length; i++) {
        final date = sessionDates[i];
        final sessionNum = getSessionNumberForIndex(schedule, i);
        final dateStr = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
        final key = '${s.studentId}_${dateStr}_$sessionNum';
        final current = _statuses[key];
        final dbStatus = allExisting[key];

        final mappedCurrent = current == 'P'
            ? 'present'
            : (current == 'A'
                ? 'absent'
                : (current == 'L' ? 'late' : (current == 'LV' ? 'excused' : null)));
        if (mappedCurrent != dbStatus) {
          return true;
        }
      }
    }
    return false;
  }

  Future<void> _saveChanges(
      List<CourseStudent> students,
      List<DateTime> sessionDates,
      Map<String, String> allExisting,
      List<StudentLeaveDetail> leaves,
      TeacherCourse course,
      AppLocalizations l) async {
    final user = ref.read(currentUserProvider).valueOrNull;
    if (user == null) return;
    final isAdmin = user.role == UserRole.admin;

    setState(() => _saving = true);
    try {
      final teacherService = ref.read(teacherServiceProvider);
      final sessionGroupsToSave = <(String dateStr, int sessionNum)>{};

      for (final s in students) {
        for (int i = 0; i < sessionDates.length; i++) {
          final date = sessionDates[i];
          final sessionNum = getSessionNumberForIndex(course.schedule, i);
          final dateStr = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
          final key = '${s.studentId}_${dateStr}_$sessionNum';
          final current = _statuses[key];
          final dbStatus = allExisting[key];

          final mappedCurrent = current == 'P'
              ? 'present'
              : (current == 'A'
                  ? 'absent'
                  : (current == 'L' ? 'late' : (current == 'LV' ? 'excused' : null)));
          if (mappedCurrent != dbStatus) {
            sessionGroupsToSave.add((dateStr, sessionNum));
          }
        }
      }

      for (final group in sessionGroupsToSave) {
        final dateStr = group.$1;
        final sessionNum = group.$2;
        final dateStatuses = <String, String>{};
        for (final s in students) {
          final key = '${s.studentId}_${dateStr}_$sessionNum';
          
          final approvedLeave = leaves.any((lv) =>
              lv.studentId == s.studentId &&
              lv.status == LeaveStatus.approved &&
              lv.startDate.compareTo(dateStr) <= 0 &&
              lv.endDate.compareTo(dateStr) >= 0 &&
              (lv.sessionNumber == null || lv.sessionNumber == sessionNum));

          if (approvedLeave) {
            dateStatuses[s.studentId] = 'excused';
          } else {
            final current = _statuses[key] ?? 'P'; // Default to present if unmarked
            final dbStatus = current == 'P'
                ? 'present'
                : (current == 'A' ? 'absent' : (current == 'L' ? 'late' : 'excused'));
            dateStatuses[s.studentId] = dbStatus;
          }
        }

        await teacherService.saveAttendance(
          teacherId: isAdmin ? null : user.id,
          classTermCourseId: widget.courseId,
          date: dateStr,
          sessionNumber: sessionNum,
          statuses: dateStatuses,
        );
      }

      ref.invalidate(allAttendanceProvider(widget.courseId));
      ref.invalidate(attendanceSummaryProvider(widget.courseId));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(l.attendanceUpdatedSuccess,
              style: AppTextStyles.body.copyWith(color: Colors.white)),
          backgroundColor: AppColors.statusGreen,
          behavior: SnackBarBehavior.floating,
        ));
      }
    } catch (e) {
      debugPrint('saveAttendance error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(l.failedToSaveAttendance(e.toString()),
              style: AppTextStyles.body.copyWith(color: Colors.white)),
          backgroundColor: AppColors.statusRed,
          behavior: SnackBarBehavior.floating,
        ));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _markAllWeek(String status, List<CourseStudent> students, List<DateTime> sessionDates, List<dynamic> schedule, List<StudentLeaveDetail> leaves) {
    setState(() {
      for (final s in students) {
        for (int i = 0; i < sessionDates.length; i++) {
          final date = sessionDates[i];
          final sessionNum = getSessionNumberForIndex(schedule, i);
          final dateStr = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
          final key = '${s.studentId}_${dateStr}_$sessionNum';
          
          final approvedLeave = leaves.any((lv) =>
              lv.studentId == s.studentId &&
              lv.status == LeaveStatus.approved &&
              lv.startDate.compareTo(dateStr) <= 0 &&
              lv.endDate.compareTo(dateStr) >= 0 &&
              (lv.sessionNumber == null || lv.sessionNumber == sessionNum));
          
          if (!approvedLeave) {
            _statuses[key] = status;
          }
        }
      }
    });
  }

  int _getWeekCount(List<CourseStudent> students, List<DateTime> sessionDates, List<dynamic> schedule, String status) {
    int count = 0;
    for (final s in students) {
      for (int i = 0; i < sessionDates.length; i++) {
        final date = sessionDates[i];
        final sessionNum = getSessionNumberForIndex(schedule, i);
        final dateStr = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
        final key = '${s.studentId}_${dateStr}_$sessionNum';
        if (_statuses[key] == status) {
          count++;
        }
      }
    }
    return count;
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final studentsAsync = ref.watch(courseStudentsProvider(widget.courseId));
    final courseAsync = ref.watch(courseInfoProvider(widget.courseId));
    final leavesAsync = ref.watch(teacherStudentLeavesProvider);
    final allExistingAsync = ref.watch(allAttendanceProvider(widget.courseId));
    final summaryAsync = ref.watch(attendanceSummaryProvider(widget.courseId));

    final course = courseAsync.valueOrNull;
    if (_selectedWeek == -1 && course != null) {
      _selectedWeek = course.currentWeek;
    }

    if (studentsAsync.isLoading ||
        leavesAsync.isLoading ||
        allExistingAsync.isLoading ||
        summaryAsync.isLoading ||
        courseAsync.isLoading) {
      return Scaffold(
        appBar: _buildAppBar(context, null, l, [], null, []),
        backgroundColor: AppColors.bgPage,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (studentsAsync.hasError ||
        leavesAsync.hasError ||
        allExistingAsync.hasError ||
        summaryAsync.hasError ||
        courseAsync.hasError) {
      return Scaffold(
        appBar: _buildAppBar(context, null, l, [], null, []),
        backgroundColor: AppColors.bgPage,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, color: AppColors.statusRed, size: 40),
              const SizedBox(height: 8),
              Text(l.loadErrorStudents, style: AppTextStyles.bodyMedium),
              TextButton(
                onPressed: () {
                  ref.invalidate(courseStudentsProvider(widget.courseId));
                  ref.invalidate(courseInfoProvider(widget.courseId));
                  ref.invalidate(teacherStudentLeavesProvider);
                  ref.invalidate(allAttendanceProvider(widget.courseId));
                  ref.invalidate(attendanceSummaryProvider(widget.courseId));
                },
                child: Text(l.retry),
              ),
            ],
          ),
        ),
      );
    }

    final students = studentsAsync.valueOrNull ?? [];
    final leaves = leavesAsync.valueOrNull ?? [];
    final allExisting = allExistingAsync.valueOrNull ?? {};
    final summary = summaryAsync.valueOrNull;

    if (!_initialized && students.isNotEmpty && allExistingAsync.hasValue) {
      _initStatuses(students, leaves, allExisting);
    }

    final user = ref.watch(currentUserProvider).valueOrNull;
    final isAdmin = user?.role == UserRole.admin;
    final sessionDates = course?.getSessionDatesForWeek(_selectedWeek) ?? [];
    final isEditable = isAdmin || (_selectedWeek == (course?.currentWeek ?? 1));
    final hasChanges = _hasChanges(students, sessionDates, allExisting, course?.schedule ?? []);
    final Map<String, int> totalAbsences = {for (final s in (summary?.students ?? [])) s.studentId: s.absentCount};

    return Scaffold(
      backgroundColor: AppColors.bgPage,
      appBar: _buildAppBar(context, course, l, students, summary, sessionDates),
      body: Column(
        children: [
          _buildWeekSwitcher(course!, l),
          _buildLockBanner(course, l),
          _buildSessionHeader(sessionDates, l),
          _buildWeekStatsOverview(students, sessionDates, l, course.schedule),
          _buildQuickActions(students, sessionDates, isEditable, l, course.schedule, leaves),
          Expanded(
            child: _buildStudentList(students, sessionDates, totalAbsences, leaves, isEditable, l, course.schedule),
          ),
          if (hasChanges && isEditable)
            _buildFloatingSaveBar(students, sessionDates, allExisting, leaves, course, l),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(
      BuildContext context,
      TeacherCourse? course,
      AppLocalizations l,
      List<CourseStudent> studentList,
      AttendanceSummaryData? summary,
      List<DateTime> sessionDates) {
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
          Text(
            course != null
                ? '${course.code} – ${course.name}'
                : l.markAttendanceFallbackTitle,
            style: AppTextStyles.h3,
            overflow: TextOverflow.ellipsis,
          ),
          Text(l.weeklyAttendanceSheet, style: AppTextStyles.caption),
        ],
      ),
      actions: [
        if (course != null && summary != null)
          IconButton(
            icon: const Icon(Icons.download_outlined),
            onPressed: () => _showDownloadOptions(context, course, summary, studentList, sessionDates, l),
            tooltip: l.downloadAttendanceReports,
          ),
      ],
    );
  }

  Widget _buildWeekSwitcher(TeacherCourse course, AppLocalizations l) {
    final total = course.totalWeeks;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back_ios,
                size: 16,
                color: _selectedWeek > 1 ? AppColors.primaryNavy : Colors.grey),
            onPressed: _selectedWeek > 1 ? () => setState(() => _selectedWeek--) : null,
          ),
          Column(
            children: [
              Text(
                l.weekOfTotal(_selectedWeek, total),
                style: AppTextStyles.h2.copyWith(color: AppColors.primaryNavy),
              ),
              const SizedBox(height: 2),
              Text(
                _selectedWeek == course.currentWeek ? l.activeWeekEditable : l.lockedWeekReadOnly,
                style: AppTextStyles.caption.copyWith(
                  color: _selectedWeek == course.currentWeek ? AppColors.statusGreen : AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          IconButton(
            icon: Icon(Icons.arrow_forward_ios,
                size: 16,
                color: _selectedWeek < total ? AppColors.primaryNavy : Colors.grey),
            onPressed: _selectedWeek < total ? () => setState(() => _selectedWeek++) : null,
          ),
        ],
      ),
    );
  }

  Widget _buildLockBanner(TeacherCourse course, AppLocalizations l) {
    final user = ref.watch(currentUserProvider).valueOrNull;
    final isAdmin = user?.role == UserRole.admin;
    final isEditable = isAdmin || (_selectedWeek == course.currentWeek);
    final bg = isAdmin
        ? AppColors.primaryBlue.withValues(alpha: 0.1)
        : (isEditable ? AppColors.statusGreenBg : AppColors.statusAmberBg);
    final color = isAdmin
        ? AppColors.primaryNavy
        : (isEditable ? AppColors.statusGreen : AppColors.statusAmber);
    final text = isAdmin
        ? "Admin Mode: You have permission to edit attendance for any week."
        : (isEditable ? l.activeWeekLockBanner : l.lockedWeekLockBanner);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      color: bg,
      child: Text(
        text,
        style: AppTextStyles.caption.copyWith(color: color, fontWeight: FontWeight.w600),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildSessionHeader(List<DateTime> sessionDates, AppLocalizations l) {
    if (sessionDates.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      color: AppColors.bgPage,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l.scheduledSessionsThisWeek,
            style: AppTextStyles.label.copyWith(
                color: AppColors.textSecondary, fontSize: 10, letterSpacing: 0.5),
          ),
          const SizedBox(height: 8),
          Row(
            children: sessionDates.asMap().entries.map((e) {
              final idx = e.key + 1;
              final date = e.value;
              final formatted = DateFormat('EEE, MMM d').format(date);
              return Expanded(
                child: Card(
                  elevation: 0,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  color: AppColors.bgCard,
                  shape: RoundedRectangleBorder(
                    side: BorderSide(color: AppColors.border),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                    child: Column(
                      children: [
                        Text('Session $idx',
                            style: AppTextStyles.label
                                .copyWith(color: AppColors.primaryNavy, fontSize: 11)),
                        const SizedBox(height: 2),
                        Text(formatted,
                            style: AppTextStyles.caption.copyWith(fontSize: 10)),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekStatsOverview(List<CourseStudent> students, List<DateTime> sessionDates, AppLocalizations l, List<dynamic> schedule) {
    if (students.isEmpty || sessionDates.isEmpty) return const SizedBox.shrink();
    final p = _getWeekCount(students, sessionDates, schedule, 'P');
    final lat = _getWeekCount(students, sessionDates, schedule, 'L');
    final a = _getWeekCount(students, sessionDates, schedule, 'A');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatIndicator(l.present, p, AppColors.statusGreen),
          _buildStatIndicator(l.late, lat, AppColors.statusAmber),
          _buildStatIndicator(l.absent, a, AppColors.statusRed),
        ],
      ),
    );
  }

  Widget _buildStatIndicator(String label, int count, Color color) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text('$label: ', style: AppTextStyles.caption),
        Text('$count', style: AppTextStyles.label.copyWith(color: color, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildQuickActions(List<CourseStudent> students, List<DateTime> sessionDates, bool isEditable, AppLocalizations l, List<dynamic> schedule, List<StudentLeaveDetail> leaves) {
    if (!isEditable || students.isEmpty || sessionDates.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      color: AppColors.bgPage,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton.icon(
            icon: Icon(Icons.check_circle_outline, color: AppColors.statusGreen, size: 16),
            label: Text(l.markAllPresent, style: AppTextStyles.label.copyWith(color: AppColors.statusGreen)),
            onPressed: () => _markAllWeek('P', students, sessionDates, schedule, leaves),
          ),
          const SizedBox(width: 12),
          TextButton.icon(
            icon: Icon(Icons.remove_circle_outline, color: AppColors.statusRed, size: 16),
            label: Text(l.markAllAbsent, style: AppTextStyles.label.copyWith(color: AppColors.statusRed)),
            onPressed: () => _markAllWeek('A', students, sessionDates, schedule, leaves),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentList(
      List<CourseStudent> students,
      List<DateTime> sessionDates,
      Map<String, int> totalAbsences,
      List<StudentLeaveDetail> leaves,
      bool isEditable,
      AppLocalizations l,
      List<dynamic> schedule) {
    if (students.isEmpty) {
      return Center(
        child: Text(l.markAttendanceEmptyState,
            style: AppTextStyles.body.copyWith(color: AppColors.textSecondary)),
      );
    }

    if (sessionDates.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.calendar_today_outlined, size: 48, color: AppColors.textSecondary.withValues(alpha: 0.5)),
              const SizedBox(height: 16),
              Text(
                "No schedule timeslots found for this course.",
                style: AppTextStyles.bodySemiBold,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                "Please configure the course schedule in Class Management to enable attendance marking.",
                style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      itemCount: students.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (ctx, i) {
        final s = students[i];
        final absences = totalAbsences[s.studentId] ?? 0;
        final isFailing = absences >= 6;

        return Container(
          decoration: BoxDecoration(
            color: AppColors.bgCard,
            borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
            border: Border.all(
              color: isFailing ? AppColors.statusRed : AppColors.border,
              width: isFailing ? 1.5 : 1,
            ),
          ),
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: isFailing
                        ? AppColors.statusRed.withValues(alpha: 0.1)
                        : AppColors.primaryNavy.withValues(alpha: 0.1),
                    child: Text(
                      s.fullName.isNotEmpty ? s.fullName[0].toUpperCase() : '?',
                      style: AppTextStyles.h3.copyWith(
                        color: isFailing ? AppColors.statusRed : AppColors.primaryNavy,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(s.fullName, style: AppTextStyles.bodyMedium),
                        const SizedBox(height: 2),
                        Text(l.profileIdLabel(s.studentCode), style: AppTextStyles.caption),
                      ],
                    ),
                  ),
                  if (isFailing)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.statusRed,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        l.failedRepeat,
                        style: AppTextStyles.label.copyWith(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 10),
              Column(
                children: sessionDates.asMap().entries.map((e) {
                  final idx = e.key + 1;
                  final date = e.value;
                  final sessionNum = getSessionNumberForIndex(schedule, e.key);
                  final dateStr = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
                  final key = '${s.studentId}_${dateStr}_$sessionNum';
                  final currentStatus = _statuses[key];

                  // Check for approved leave
                  final approvedLeave = leaves.any((lv) =>
                      lv.studentId == s.studentId &&
                      lv.status == LeaveStatus.approved &&
                      lv.startDate.compareTo(dateStr) <= 0 &&
                      lv.endDate.compareTo(dateStr) >= 0 &&
                      (lv.sessionNumber == null || lv.sessionNumber == sessionNum));

                  final pendingLeave = leaves.any((lv) =>
                      lv.studentId == s.studentId &&
                      lv.status == LeaveStatus.pending &&
                      lv.startDate.compareTo(dateStr) <= 0 &&
                      lv.endDate.compareTo(dateStr) >= 0 &&
                      (lv.sessionNumber == null || lv.sessionNumber == sessionNum));

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Session $idx (${DateFormat('EEE, d/M').format(date)})',
                            style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w500)),
                        if (approvedLeave)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: AppColors.primaryBlue.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.event_available, color: AppColors.primaryBlue, size: 12),
                                const SizedBox(width: 4),
                                Text(
                                  l.excusedLeave,
                                  style: AppTextStyles.bodySemiBold
                                      .copyWith(color: AppColors.primaryBlue, fontSize: 10),
                                ),
                              ],
                            ),
                          )
                        else if (!isEditable)
                          _buildReadOnlyBadge(currentStatus, l)
                        else
                          _buildEditableChips(key, currentStatus, pendingLeave),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildReadOnlyBadge(String? status, AppLocalizations l) {
    final color = status == 'P'
        ? AppColors.statusGreen
        : status == 'A'
            ? AppColors.statusRed
            : status == 'L'
                ? AppColors.statusAmber
                : AppColors.textSecondary;

    final label = status == 'P'
        ? l.present
        : status == 'A'
            ? l.absent
            : status == 'L'
                ? l.late
                : l.notMarked;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color, width: 0.5),
      ),
      child: Text(
        label,
        style: AppTextStyles.label.copyWith(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildEditableChips(String key, String? currentStatus, bool hasPendingLeave) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (hasPendingLeave) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.statusAmber.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              'Pending Leave',
              style: TextStyle(color: AppColors.statusAmber, fontSize: 8),
            ),
          ),
          const SizedBox(width: 6),
        ],
        _OptionChip(
          label: 'P',
          color: AppColors.statusGreen,
          selected: currentStatus == 'P',
          onTap: () => setState(() => _statuses[key] = currentStatus == 'P' ? null : 'P'),
        ),
        const SizedBox(width: 4),
        _OptionChip(
          label: 'L',
          color: AppColors.statusAmber,
          selected: currentStatus == 'L',
          onTap: () => setState(() => _statuses[key] = currentStatus == 'L' ? null : 'L'),
        ),
        const SizedBox(width: 4),
        _OptionChip(
          label: 'A',
          color: AppColors.statusRed,
          selected: currentStatus == 'A',
          onTap: () => setState(() => _statuses[key] = currentStatus == 'A' ? null : 'A'),
        ),
      ],
    );
  }

  Widget _buildFloatingSaveBar(
      List<CourseStudent> students,
      List<DateTime> sessionDates,
      Map<String, String> allExisting,
      List<StudentLeaveDetail> leaves,
      TeacherCourse course,
      AppLocalizations l) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -4)),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: AppSpacing.buttonHeight,
        child: ElevatedButton.icon(
          onPressed: _saving ? null : () => _saveChanges(students, sessionDates, allExisting, leaves, course, l),
          icon: _saving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                )
              : const Icon(Icons.save_outlined),
          label: Text(_saving ? l.saving : l.saveAttendanceChanges, style: AppTextStyles.button),
        ),
      ),
    );
  }

  void _showDownloadOptions(
      BuildContext context,
      TeacherCourse course,
      AttendanceSummaryData summary,
      List<CourseStudent> studentList,
      List<DateTime> sessionDates,
      AppLocalizations l) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.bgCard,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l.downloadAttendanceReports,
                style: AppTextStyles.h2,
              ),
              const SizedBox(height: 6),
              Text(
                'Select report range and download format.',
                style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 24),
              
              // This Week Group
              Text(
                'THIS WEEK (WEEK $_selectedWeek)',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.primaryNavy,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _ExportButton(
                      icon: Icons.picture_as_pdf,
                      iconColor: Colors.red.shade700,
                      label: 'PDF Report',
                      onTap: () async {
                        Navigator.of(ctx).pop();
                        final leaves = ref.read(teacherStudentLeavesProvider).valueOrNull ?? [];
                        await _exportPdf(context, course, summary, studentList, sessionDates, leaves, false, l);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ExportButton(
                      icon: Icons.table_chart,
                      iconColor: Colors.green.shade700,
                      label: 'Excel Report',
                      onTap: () async {
                        Navigator.of(ctx).pop();
                        final leaves = ref.read(teacherStudentLeavesProvider).valueOrNull ?? [];
                        await _exportExcel(context, course, summary, studentList, sessionDates, leaves, false, l);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              // All Weeks Group
              Text(
                'ALL WEEKS (CUMULATIVE)',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.primaryNavy,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _ExportButton(
                      icon: Icons.picture_as_pdf,
                      iconColor: Colors.red.shade700,
                      label: 'PDF Report',
                      onTap: () async {
                        Navigator.of(ctx).pop();
                        final leaves = ref.read(teacherStudentLeavesProvider).valueOrNull ?? [];
                        await _exportPdf(context, course, summary, studentList, sessionDates, leaves, true, l);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ExportButton(
                      icon: Icons.table_chart,
                      iconColor: Colors.green.shade700,
                      label: 'Excel Report',
                      onTap: () async {
                        Navigator.of(ctx).pop();
                        final leaves = ref.read(teacherStudentLeavesProvider).valueOrNull ?? [];
                        await _exportExcel(context, course, summary, studentList, sessionDates, leaves, true, l);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Future<void> _exportPdf(
      BuildContext context,
      TeacherCourse? course,
      AttendanceSummaryData summary,
      List<CourseStudent> studentList,
      List<DateTime> sessionDates,
      List<StudentLeaveDetail> leaves,
      bool allWeeks,
      AppLocalizations l) async {
    final doc = pw.Document();
    final studentCodes = {for (final s in studentList) s.studentId: s.studentCode};
    final weekRangeStr = _getWeekRangeStr(course, _selectedWeek);

    if (!allWeeks) {
      doc.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          build: (pw.Context ctx) => [
            _pwHeader('WEEK $_selectedWeek ATTENDANCE REPORT'),
            if (weekRangeStr.isNotEmpty)
              pw.Padding(
                padding: const pw.EdgeInsets.only(top: 4, bottom: 8),
                child: pw.Text(
                  'Date Range: $weekRangeStr',
                  style: pw.TextStyle(fontSize: 10, fontStyle: pw.FontStyle.italic, color: PdfColors.grey700),
                ),
              ),
            _pwMeta(course, 'Week $_selectedWeek of ${course?.totalWeeks ?? 15}'),
            pw.SizedBox(height: 20),
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.blueGrey100, width: 0.5),
              children: [
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.blueGrey800),
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(6),
                      child: pw.Text('Student Code',
                          style: pw.TextStyle(color: PdfColors.white, fontSize: 8, fontWeight: pw.FontWeight.bold)),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(6),
                      child: pw.Text('Student Name',
                          style: pw.TextStyle(color: PdfColors.white, fontSize: 8, fontWeight: pw.FontWeight.bold)),
                    ),
                    ...sessionDates.asMap().entries.map((e) => pw.Padding(
                          padding: const pw.EdgeInsets.all(6),
                          child: pw.Text('Session ${e.key + 1}\n(${DateFormat('d/M').format(e.value)})',
                              style: pw.TextStyle(
                                  color: PdfColors.white, fontSize: 7, fontWeight: pw.FontWeight.bold),
                              textAlign: pw.TextAlign.center),
                        )),
                  ],
                ),
                ...studentList.map((s) {
                  final code = studentCodes[s.studentId] ?? 'N/A';
                  return pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(5),
                        child: pw.Text(code, style: const pw.TextStyle(fontSize: 7.5)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(5),
                        child: pw.Text(s.fullName, style: const pw.TextStyle(fontSize: 7.5)),
                      ),
                      ...sessionDates.asMap().entries.map((e) {
                        final i = e.key;
                        final date = e.value;
                        final dateStr = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
                        final sessionNum = getSessionNumberForIndex(course?.schedule ?? [], i);
                        
                        final approvedLeave = leaves.any((lv) =>
                            lv.studentId == s.studentId &&
                            lv.status == LeaveStatus.approved &&
                            lv.startDate.compareTo(dateStr) <= 0 &&
                            lv.endDate.compareTo(dateStr) >= 0 &&
                            (lv.sessionNumber == null || lv.sessionNumber == sessionNum));

                        final key = '${s.studentId}_${dateStr}_$sessionNum';
                        final status = approvedLeave ? 'LV' : (_statuses[key] ?? '-');
                        final color = status == 'P'
                            ? PdfColors.green700
                            : (status == 'A'
                                ? PdfColors.red700
                                : (status == 'L' ? PdfColors.orange700 : (status == 'LV' ? PdfColors.blue700 : PdfColors.blueGrey500)));
                        return pw.Padding(
                          padding: const pw.EdgeInsets.all(5),
                          child: pw.Text(status,
                              style: pw.TextStyle(fontSize: 7.5, fontWeight: pw.FontWeight.bold, color: color),
                              textAlign: pw.TextAlign.center),
                        );
                      }),
                    ],
                  );
                }),
              ],
            ),
          ],
        ),
      );
    } else {
      doc.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          build: (pw.Context ctx) => [
            _pwHeader('SEMESTER CUMULATIVE ATTENDANCE REPORT'),
            _pwMeta(course, 'All Weeks'),
            pw.SizedBox(height: 20),
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.blueGrey100, width: 0.5),
              columnWidths: {
                0: const pw.FlexColumnWidth(1.2), // Code
                1: const pw.FlexColumnWidth(2.6), // Name
                2: const pw.FlexColumnWidth(0.7), // Present
                3: const pw.FlexColumnWidth(0.7), // Absent
                4: const pw.FlexColumnWidth(1.1), // Rate
                5: const pw.FlexColumnWidth(1.5), // Status
              },
              children: [
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.blueGrey800),
                  children: [
                    'Student Code',
                    'Student Name',
                    'Present',
                    'Absent',
                    'Attendance Rate',
                    'Status'
                  ].map((h) => pw.Padding(
                        padding: const pw.EdgeInsets.all(6),
                        child: pw.Text(h,
                            style: pw.TextStyle(color: PdfColors.white, fontSize: 8, fontWeight: pw.FontWeight.bold),
                            textAlign: h == 'Student Name' ? pw.TextAlign.left : pw.TextAlign.center),
                      )).toList(),
                ),
                ...summary.students.map((s) {
                  final code = studentCodes[s.studentId] ?? 'N/A';
                  final rate = summary.totalSessions > 0 ? (s.presentCount / summary.totalSessions) : 0.0;
                  final rateStr = '${(rate * 100).toStringAsFixed(1)}%';
                  final isFailed = s.absentCount >= 6;

                  return pw.TableRow(
                    decoration: pw.BoxDecoration(
                      color: isFailed ? PdfColors.red50 : PdfColors.white,
                    ),
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(5),
                        child: pw.Text(code, style: const pw.TextStyle(fontSize: 7.5)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(5),
                        child: pw.Text(s.fullName, style: const pw.TextStyle(fontSize: 7.5)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(5),
                        child: pw.Text(s.presentCount.toString(),
                            style: const pw.TextStyle(fontSize: 7.5), textAlign: pw.TextAlign.center),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(5),
                        child: pw.Text(s.absentCount.toString(),
                            style: const pw.TextStyle(fontSize: 7.5), textAlign: pw.TextAlign.center),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(5),
                        child: pw.Text(rateStr,
                            style: pw.TextStyle(
                                fontSize: 7.5,
                                fontWeight: pw.FontWeight.bold,
                                color: rate >= 0.85
                                    ? PdfColors.green700
                                    : (rate >= 0.75 ? PdfColors.orange700 : PdfColors.red700)),
                            textAlign: pw.TextAlign.center),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(5),
                        child: pw.Text(isFailed ? 'FAILED (Repeat)' : 'PASS',
                            style: pw.TextStyle(
                                fontSize: 7.5,
                                fontWeight: pw.FontWeight.bold,
                                color: isFailed ? PdfColors.red700 : PdfColors.green700),
                            textAlign: pw.TextAlign.center),
                      ),
                    ],
                  );
                }),
              ],
            ),
          ],
        ),
      );
    }

    final bytes = await doc.save();
    final cleanCode = course?.code.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_') ?? 'report';
    final suffix = allWeeks ? 'cumulative' : 'week_$_selectedWeek';
    await Printing.sharePdf(bytes: bytes, filename: 'attendance_report_${cleanCode}_$suffix.pdf');
  }

  Future<void> _exportExcel(
      BuildContext context,
      TeacherCourse? course,
      AttendanceSummaryData summary,
      List<CourseStudent> studentList,
      List<DateTime> sessionDates,
      List<StudentLeaveDetail> leaves,
      bool allWeeks,
      AppLocalizations l) async {
    final xcel = Excel.createExcel();
    xcel.delete('Sheet1');
    final sheet = xcel['Attendance Report'];
    final studentCodes = {for (final s in studentList) s.studentId: s.studentCode};
    final weekRangeStr = _getWeekRangeStr(course, _selectedWeek);

    if (!allWeeks) {
      // Row 0: Title
      final titleCell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0));
      titleCell.value = TextCellValue('WEEK $_selectedWeek ATTENDANCE REPORT');
      titleCell.cellStyle = CellStyle(bold: true, fontSize: 14);

      // Row 1: Date Range
      if (weekRangeStr.isNotEmpty) {
        final dateCell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 1));
        dateCell.value = TextCellValue('Date: $weekRangeStr');
        dateCell.cellStyle = CellStyle(italic: true, fontSize: 10);
      }

      final headers = [
        'Student Code',
        'Student Name',
        ...sessionDates.asMap().entries.map((e) => 'Session ${e.key + 1} (${DateFormat('d/M').format(e.value)})')
      ];

      for (int j = 0; j < headers.length; j++) {
        final cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: j, rowIndex: 3));
        cell.value = TextCellValue(headers[j]);
        cell.cellStyle = CellStyle(
          bold: true,
          backgroundColorHex: ExcelColor.fromHexString('#1E3A5F'),
          fontColorHex: ExcelColor.fromHexString('#FFFFFF'),
        );
        sheet.setColumnWidth(j, j == 1 ? 28.0 : 16.0);
      }

      for (int i = 0; i < studentList.length; i++) {
        final s = studentList[i];
        final code = studentCodes[s.studentId] ?? 'N/A';
        final isEven = i.isEven;
        final bg = ExcelColor.fromHexString(isEven ? '#FFFFFF' : '#F8F9FF');

        final rowValues = [
          code,
          s.fullName,
          ...sessionDates.asMap().entries.map((e) {
            final idx = e.key;
            final date = e.value;
            final sessionNum = getSessionNumberForIndex(course?.schedule ?? [], idx);
            final dateStr = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
            
            final approvedLeave = leaves.any((lv) =>
                lv.studentId == s.studentId &&
                lv.status == LeaveStatus.approved &&
                lv.startDate.compareTo(dateStr) <= 0 &&
                lv.endDate.compareTo(dateStr) >= 0 &&
                (lv.sessionNumber == null || lv.sessionNumber == sessionNum));
                
            return approvedLeave ? 'LV' : (_statuses['${s.studentId}_${dateStr}_$sessionNum'] ?? '-');
          }),
        ];

        for (int j = 0; j < rowValues.length; j++) {
          final cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: j, rowIndex: i + 4));
          cell.value = TextCellValue(rowValues[j]);

          final statusVal = rowValues[j];
          final statusColor = ExcelColor.fromHexString(
            statusVal == 'P' ? '#059669' : (statusVal == 'A' ? '#DC2626' : (statusVal == 'L' ? '#D97706' : '#111827')),
          );

          cell.cellStyle = CellStyle(
            backgroundColorHex: bg,
            fontColorHex: j >= 2 ? statusColor : ExcelColor.fromHexString('#111827'),
            bold: j >= 2,
          );
        }
      }
    } else {
      // Semester Title
      final titleCell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0));
      titleCell.value = TextCellValue('SEMESTER CUMULATIVE ATTENDANCE REPORT');
      titleCell.cellStyle = CellStyle(bold: true, fontSize: 14);

      final headers = ['Student Code', 'Student Name', 'Present Sessions', 'Absent Sessions', 'Attendance Rate', 'Status'];
      final widths = [18.0, 28.0, 16.0, 16.0, 18.0, 18.0];

      for (int j = 0; j < headers.length; j++) {
        final cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: j, rowIndex: 2));
        cell.value = TextCellValue(headers[j]);
        cell.cellStyle = CellStyle(
          bold: true,
          backgroundColorHex: ExcelColor.fromHexString('#1E3A5F'),
          fontColorHex: ExcelColor.fromHexString('#FFFFFF'),
        );
        sheet.setColumnWidth(j, widths[j]);
      }

      for (int i = 0; i < summary.students.length; i++) {
        final s = summary.students[i];
        final isEven = i.isEven;
        final code = studentCodes[s.studentId] ?? 'N/A';
        final rate = summary.totalSessions > 0 ? (s.presentCount / summary.totalSessions) : 0.0;
        final rateStr = '${(rate * 100).toStringAsFixed(1)}%';
        final isFailed = s.absentCount >= 6;

        final bg = ExcelColor.fromHexString(isFailed ? '#FEF2F2' : (isEven ? '#FFFFFF' : '#F8F9FF'));
        final rateColor = ExcelColor.fromHexString(rate >= 0.85 ? '#059669' : (rate >= 0.75 ? '#D97706' : '#DC2626'));
        final statusColor = ExcelColor.fromHexString(isFailed ? '#DC2626' : '#059669');

        final rowValues = [
          code,
          s.fullName,
          s.presentCount.toString(),
          s.absentCount.toString(),
          rateStr,
          isFailed ? 'FAILED (Repeat)' : 'PASS',
        ];

        for (int j = 0; j < rowValues.length; j++) {
          final cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: j, rowIndex: i + 3));
          cell.value = TextCellValue(rowValues[j]);
          cell.cellStyle = CellStyle(
            backgroundColorHex: bg,
            fontColorHex: j == 4 ? rateColor : (j == 5 ? statusColor : ExcelColor.fromHexString('#111827')),
            bold: j >= 4,
          );
        }
      }
    }

    final bytes = xcel.encode() ?? [];
    final cleanCode = course?.code.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_') ?? 'report';
    final suffix = allWeeks ? 'cumulative' : 'week_$_selectedWeek';
    final filename = 'attendance_report_${cleanCode}_$suffix.xlsx';

    if (kIsWeb) {
      await Printing.sharePdf(bytes: Uint8List.fromList(bytes), filename: filename);
    } else {
      try {
        await Printing.sharePdf(bytes: Uint8List.fromList(bytes), filename: filename);
      } catch (_) {
        final home = io.Platform.environment['USERPROFILE'] ?? io.Platform.environment['HOME'] ?? '.';
        final dir = io.Directory(io.Platform.isWindows ? '$home\\Downloads' : '$home/Downloads');
        if (!await dir.exists()) await dir.create(recursive: true);
        final file = io.File('${dir.path}${io.Platform.pathSeparator}$filename');
        await file.writeAsBytes(bytes);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Saved to Downloads: ${file.path}'),
            backgroundColor: AppColors.statusGreen,
          ));
        }
      }
    }
  }

  pw.Widget _pwHeader(String title) {
    return pw.Header(
      level: 0,
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('BELTEI International University',
              style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: PdfColors.blueGrey900)),
          pw.Text(title,
              style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, color: PdfColors.blueGrey600)),
          pw.SizedBox(height: 4),
          pw.Divider(color: PdfColors.blueGrey100, thickness: 1),
        ],
      ),
    );
  }

  pw.Widget _pwMeta(TeacherCourse? course, String rangeLabel) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        color: PdfColors.blueGrey50,
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('Course: ${course?.code ?? ""} - ${course?.name ?? ""}',
                  style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
              pw.Text('Class Code: ${course?.classCode ?? "N/A"}',
                  style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
            ],
          ),
          pw.SizedBox(height: 4),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('Academic Year: ${course?.semesterAcademicYear ?? "N/A"} (${course?.semesterName ?? "N/A"})',
                  style: const pw.TextStyle(fontSize: 8.5)),
              pw.Text('Selected Scope: $rangeLabel',
                  style: const pw.TextStyle(fontSize: 8.5)),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Option chip ───────────────────────────────────────────────────────────────

class _OptionChip extends StatelessWidget {
  const _OptionChip({
    required this.label,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.15) : AppColors.bgPage,
          shape: BoxShape.circle,
          border: Border.all(
            color: selected ? color : AppColors.border,
            width: selected ? 2 : 1,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: AppTextStyles.label.copyWith(
              color: selected ? color : AppColors.textLabel,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

class _ExportButton extends StatelessWidget {
  const _ExportButton({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: AppColors.bgPage,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: iconColor, size: 20),
            const SizedBox(width: 8),
            Text(label, style: AppTextStyles.bodySemiBold.copyWith(fontSize: 13)),
          ],
        ),
      ),
    );
  }
}
