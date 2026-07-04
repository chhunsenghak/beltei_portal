import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/providers/teacher_providers.dart';
import '../../../core/services/teacher_service.dart';
import '../../../core/supabase/database.types.dart';
import '../../../l10n/app_localizations.dart';

// ── Helpers ───────────────────────────────────────────────────────────────────

String _fmtDateRange(String start, String end, String locale) {
  try {
    final s = DateFormat('MMM d', locale).format(DateTime.parse(start));
    final e = DateFormat('MMM d', locale).format(DateTime.parse(end));
    return s == e ? s : '$s – $e';
  } catch (_) {
    return '$start – $end';
  }
}

// ── Screen ────────────────────────────────────────────────────────────────────

class TeacherDashboardScreen extends ConsumerWidget {
  const TeacherDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final profileAsync = ref.watch(teacherProfileProvider);
    final coursesAsync = ref.watch(teacherCoursesProvider);
    final leavesAsync = ref.watch(teacherStudentLeavesProvider);

    return Scaffold(
      backgroundColor: AppColors.bgPage,
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        children: [
          // Header
          profileAsync.when(
            loading: () => _buildHeaderSkeleton(),
            error: (_, _) => _buildHeaderPlaceholder(l),
            data: (p) =>
                p == null ? _buildHeaderPlaceholder(l) : _buildHeader(p, l),
          ),
          const SizedBox(height: AppSpacing.sectionGap),
          // Stats
          Builder(builder: (_) {
            final courses = coursesAsync.valueOrNull ?? [];
            final leaves = leavesAsync.valueOrNull ?? [];
            final isLoading =
                coursesAsync.isLoading || leavesAsync.isLoading;
            if (isLoading) return _buildStatsLoading();
            return _buildStatsGrid(
              courses.length,
              courses.fold(0, (s, c) => s + c.studentCount),
              leaves
                  .where((l) => l.status == LeaveStatus.pending)
                  .length,
              courses.where((c) => c.hasTodayClass()).length,
              l,
            );
          }),
          const SizedBox(height: AppSpacing.sectionGap),
          _buildQuickActions(context, l),
          const SizedBox(height: AppSpacing.sectionGap),
          // Today's schedule
          coursesAsync.when(
            loading: () => const SizedBox.shrink(),
            error: (_, _) => const SizedBox.shrink(),
            data: (courses) => _buildTodaySchedule(context, courses, l),
          ),
          const SizedBox(height: AppSpacing.sectionGap),
          // Pending leaves (view-only)
          leavesAsync.when(
            loading: () => const SizedBox.shrink(),
            error: (_, _) => const SizedBox.shrink(),
            data: (leaves) => _buildPendingLeaves(
              context,
              leaves
                  .where((l) => l.status == LeaveStatus.pending)
                  .take(3)
                  .toList(),
              l,
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // ── Header ─────────────────────────────────────────────────────────────────

  Widget _buildHeader(TeacherProfile profile, AppLocalizations l) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.splashDark, AppColors.splashLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
      child: Row(
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: Colors.white.withValues(alpha: 0.2),
            child: const Icon(Icons.person, color: Colors.white, size: 36),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(profile.fullName, style: AppTextStyles.h2White),
                const SizedBox(height: 2),
                Text(
                  profile.departmentName != null
                      ? l.teacherDashboardDeptLabel(profile.departmentName!)
                      : profile.position ?? l.teacherDashboardDefaultPosition,
                  style:
                      AppTextStyles.captionWhite.copyWith(fontSize: 12),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.badge_outlined,
                          color: Colors.white, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        l.profileIdLabel(profile.employeeCode),
                        style: AppTextStyles.label.copyWith(
                            color: Colors.white, letterSpacing: 0.6),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderSkeleton() {
    return Container(
      height: 100,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.splashDark, AppColors.splashLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Center(
        child: CircularProgressIndicator(color: Colors.white),
      ),
    );
  }

  Widget _buildHeaderPlaceholder(AppLocalizations l) {
    return _buildHeader(
        TeacherProfile(
          id: '',
          employeeCode: '---',
          fullName: l.teacherDashboardDefaultPosition,
          email: '',
        ),
        l);
  }

  // ── Stats grid ─────────────────────────────────────────────────────────────

  Widget _buildStatsLoading() {
    return const SizedBox(
      height: 100,
      child: Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildStatsGrid(int courses, int students, int pendingLeaves,
      int todayClasses, AppLocalizations l) {
    final items = [
      (
        icon: Icons.menu_book_outlined,
        label: l.teacherDashboardStatTotalCourses,
        value: '$courses',
        color: AppColors.primaryNavy
      ),
      (
        icon: Icons.people_outline,
        label: l.teacherDashboardStatTotalStudents,
        value: '$students',
        color: AppColors.primaryBlue
      ),
      (
        icon: Icons.pending_actions_outlined,
        label: l.teacherDashboardStatPendingLeaves,
        value: '$pendingLeaves',
        color: AppColors.statusAmber
      ),
      (
        icon: Icons.today_outlined,
        label: l.teacherDashboardStatTodayClasses,
        value: '$todayClasses',
        color: AppColors.statusGreen
      ),
    ];
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 1.9,
      children: items
          .map((item) => _StatCard(
                icon: item.icon,
                label: item.label,
                value: item.value,
                color: item.color,
              ))
          .toList(),
    );
  }

  // ── Quick actions ──────────────────────────────────────────────────────────

  Widget _buildQuickActions(BuildContext context, AppLocalizations l) {
    final actions = [
      (
        icon: Icons.how_to_reg_outlined,
        label: l.teacherDashboardQuickActionMarkAttendance,
        route: '/teacher/courses'
      ),
      (
        icon: Icons.grade_outlined,
        label: l.dashboardActionGrades,
        route: '/teacher/courses'
      ),
      (
        icon: Icons.assignment_outlined,
        label: l.teacherDashboardQuickActionAssignments,
        route: '/teacher/courses'
      ),
      (
        icon: Icons.folder_outlined,
        label: l.teacherDashboardQuickActionMaterials,
        route: '/teacher/courses'
      ),
      (
        icon: Icons.bar_chart_outlined,
        label: l.teacherDashboardQuickActionReports,
        route: '/teacher/analytics'
      ),
      (
        icon: Icons.campaign_outlined,
        label: l.teacherDashboardQuickActionAnnouncements,
        route: '/teacher/alerts/announcement'
      ),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l.dashboardQuickActionsTitle, style: AppTextStyles.h2),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 1.2,
          children: actions.map((a) {
            return GestureDetector(
              onTap: () => context.push(a.route),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.bgCard,
                  borderRadius:
                      BorderRadius.circular(AppSpacing.cardRadius),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: AppColors.primaryNavy.withValues(alpha: 0.08),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(a.icon,
                          color: AppColors.primaryNavy, size: 20),
                    ),
                    const SizedBox(height: 6),
                    Text(a.label,
                        style: AppTextStyles.caption
                            .copyWith(fontSize: 11, height: 1.3),
                        textAlign: TextAlign.center),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // ── Today's schedule ───────────────────────────────────────────────────────

  Widget _buildTodaySchedule(BuildContext context, List<TeacherCourse> courses,
      AppLocalizations l) {
    final todayCourses = courses.where((c) => c.hasTodayClass()).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(l.teacherDashboardTodayScheduleTitle, style: AppTextStyles.h2),
            GestureDetector(
              onTap: () => context.push('/teacher/schedule'),
              child: Text(l.teacherDashboardFullScheduleLink, style: AppTextStyles.link),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (todayCourses.isEmpty)
          Container(
            padding: const EdgeInsets.all(AppSpacing.cardPadding),
            decoration: BoxDecoration(
              color: AppColors.bgCard,
              borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Icon(Icons.event_available_outlined,
                    color: AppColors.textLabel, size: 22),
                const SizedBox(width: 12),
                Text(l.teacherDashboardNoClassesScheduledToday,
                    style: AppTextStyles.body
                        .copyWith(color: AppColors.textSecondary)),
              ],
            ),
          )
        else
          ...todayCourses.asMap().entries.map((entry) {
            final i = entry.key;
            final c = entry.value;
            final slot = c.todaySlot();
            final now = DateTime.now();
            final startStr = slot?['start'] as String? ?? '';
            bool isCurrent = false;
            String statusLabel =
                i == 0 ? l.teacherDashboardStatusNext : l.teacherDashboardStatusLater;
            Color statusColor = AppColors.primaryNavy;

            if (startStr.isNotEmpty) {
              try {
                final parts = startStr.split(':');
                final slotStart = DateTime(now.year, now.month, now.day,
                    int.parse(parts[0]), int.parse(parts[1]));
                final endStr = slot?['end'] as String? ?? '';
                DateTime? slotEnd;
                if (endStr.isNotEmpty) {
                  final ep = endStr.split(':');
                  slotEnd = DateTime(now.year, now.month, now.day,
                      int.parse(ep[0]), int.parse(ep[1]));
                }
                if (now.isAfter(slotStart) &&
                    (slotEnd == null || now.isBefore(slotEnd))) {
                  isCurrent = true;
                  statusLabel = l.teacherDashboardStatusNow;
                  statusColor = AppColors.statusGreen;
                } else if (now.isBefore(slotStart) && i == 0) {
                  statusLabel = l.teacherDashboardStatusNext;
                  statusColor = AppColors.primaryNavy;
                }
              } catch (_) {}
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _ScheduleTodayCard(
                course: c,
                slot: slot,
                statusLabel: statusLabel,
                statusColor: statusColor,
                isCurrent: isCurrent,
                l: l,
              ),
            );
          }),
      ],
    );
  }

  // ── Pending leaves (view-only) ─────────────────────────────────────────────

  Widget _buildPendingLeaves(BuildContext context,
      List<StudentLeaveDetail> leaves, AppLocalizations l) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(l.teacherDashboardPendingLeaveRequestsTitle, style: AppTextStyles.h2),
            GestureDetector(
              onTap: () => context.go('/teacher/students'),
              child: Text(l.teacherDashboardViewAllLink, style: AppTextStyles.link),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (leaves.isEmpty)
          Container(
            padding: const EdgeInsets.all(AppSpacing.cardPadding),
            decoration: BoxDecoration(
              color: AppColors.bgCard,
              borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Icon(Icons.inbox_outlined,
                    color: AppColors.textLabel, size: 22),
                const SizedBox(width: 12),
                Text(l.teacherDashboardNoPendingRequests,
                    style: AppTextStyles.body
                        .copyWith(color: AppColors.textSecondary)),
              ],
            ),
          )
        else
          Container(
            decoration: BoxDecoration(
              color: AppColors.bgCard,
              borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: leaves.asMap().entries.map((entry) {
                final isLast = entry.key == leaves.length - 1;
                return _buildLeaveRow(
                    context, entry.value, l,
                    showDivider: !isLast);
              }).toList(),
            ),
          ),
      ],
    );
  }

  Widget _buildLeaveRow(BuildContext context, StudentLeaveDetail leave,
      AppLocalizations l, {required bool showDivider}) {
    return Column(
      children: [
        InkWell(
          onTap: () =>
              context.push('/teacher/students/leave/${leave.id}'),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor:
                      AppColors.primaryNavy.withValues(alpha: 0.12),
                  child: Text(leave.initials,
                      style: AppTextStyles.caption.copyWith(
                          color: AppColors.primaryNavy,
                          fontWeight: FontWeight.w700)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(leave.studentName,
                          style: AppTextStyles.bodyMedium),
                      Text(
                        '${leave.type} • ${_fmtDateRange(leave.startDate, leave.endDate, l.localeName)}',
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios,
                    size: 14, color: AppColors.primaryNavy),
              ],
            ),
          ),
        ),
        if (showDivider)
          Divider(height: 1, color: AppColors.divider),
      ],
    );
  }
}

// ── Stat card ──────────────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(label,
                    style: AppTextStyles.label.copyWith(fontSize: 10),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                Text(value,
                    style: AppTextStyles.metric
                        .copyWith(color: color, fontSize: 22)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Today schedule card ────────────────────────────────────────────────────────

class _ScheduleTodayCard extends StatelessWidget {
  const _ScheduleTodayCard({
    required this.course,
    required this.slot,
    required this.statusLabel,
    required this.statusColor,
    required this.isCurrent,
    required this.l,
  });

  final TeacherCourse course;
  final Map<String, dynamic>? slot;
  final String statusLabel;
  final Color statusColor;
  final bool isCurrent;
  final AppLocalizations l;

  @override
  Widget build(BuildContext context) {
    final startTime = slot?['start'] as String? ?? '--:--';
    final room = slot?['room'] as String? ?? course.room ?? '---';

    return Container(
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: isCurrent
            ? AppColors.primaryNavy.withValues(alpha: 0.04)
            : AppColors.bgCard,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(
          color: isCurrent ? AppColors.primaryNavy : AppColors.border,
          width: isCurrent ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              statusLabel,
              style: AppTextStyles.label
                  .copyWith(color: Colors.white, letterSpacing: 0.6),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${course.code} – ${course.name}',
                    style: AppTextStyles.bodyMedium,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.access_time_outlined,
                        size: 12, color: AppColors.textSecondary),
                    const SizedBox(width: 3),
                    Text(startTime, style: AppTextStyles.caption),
                    const SizedBox(width: 10),
                    Icon(Icons.meeting_room_outlined,
                        size: 12, color: AppColors.textSecondary),
                    const SizedBox(width: 3),
                    Text(room, style: AppTextStyles.caption),
                    const SizedBox(width: 10),
                    Icon(Icons.people_outline,
                        size: 12, color: AppColors.textSecondary),
                    const SizedBox(width: 3),
                    Text(l.studentsCountLabel(course.studentCount),
                        style: AppTextStyles.caption),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
