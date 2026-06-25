import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';

// ── Mock data ──────────────────────────────────────────────────────────────────

const _kTeacher = (
  name: 'Dr. James Wilson',
  department: 'Department: Computer Science',
  employeeId: 'T-2024-001',
);

const _kStats = (
  totalCourses: 4,
  totalStudents: 120,
  pendingLeaves: 3,
  todayClasses: 2,
);

final _kQuickActions = [
  (icon: Icons.how_to_reg_outlined,        label: 'Mark\nAttendance', route: '/teacher/courses/CS101/attendance'),
  (icon: Icons.grade_outlined,             label: 'Grades',           route: '/teacher/courses/CS101/grades'),
  (icon: Icons.assignment_outlined,        label: 'Assignments',      route: '/teacher/courses/CS101/assessments/create'),
  (icon: Icons.folder_outlined,            label: 'Materials',        route: '/teacher/courses/CS101/materials'),
  (icon: Icons.bar_chart_outlined,         label: 'Reports',          route: '/teacher/courses/CS101/attendance/report'),
  (icon: Icons.campaign_outlined,          label: 'Announcements',    route: '/teacher/alerts/announcement'),
];

final _kScheduleToday = [
  (
    status: 'NOW',
    statusColor: AppColors.statusGreen,
    time: '08:30',
    course: 'CS101 - Introduction to Algorithms',
    room: 'Room 402',
    students: 45,
    isCurrent: true,
  ),
  (
    status: 'NEXT',
    statusColor: AppColors.primaryNavy,
    time: '11:00',
    course: 'CS205 - Web Development Frameworks',
    room: 'Lab 02',
    students: 32,
    isCurrent: false,
  ),
];

final _kPendingLeaves = [
  (initials: 'SK', name: 'Sok Khema',    details: 'Medical Leave • 24 Oct – 26 Oct'),
  (initials: 'VP', name: 'Vannak Phirun', details: 'Personal Reason • 25 Oct'),
  (initials: 'LM', name: 'Ly Monica',    details: 'Event Participation • 28 Oct – 30 Oct'),
];

// ── Screen ────────────────────────────────────────────────────────────────────

class TeacherDashboardScreen extends StatelessWidget {
  const TeacherDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        children: [
          _buildTeacherHeader(),
          const SizedBox(height: AppSpacing.sectionGap),
          _buildStatsGrid(),
          const SizedBox(height: AppSpacing.sectionGap),
          _buildQuickActions(context),
          const SizedBox(height: AppSpacing.sectionGap),
          _buildTodaySchedule(context),
          const SizedBox(height: AppSpacing.sectionGap),
          _buildPendingLeaves(context),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // ── Teacher header ─────────────────────────────────────────────────────────

  Widget _buildTeacherHeader() {
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
                Text(_kTeacher.name, style: AppTextStyles.h2White),
                const SizedBox(height: 2),
                Text(_kTeacher.department,
                    style: AppTextStyles.captionWhite.copyWith(fontSize: 12)),
                const SizedBox(height: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
                      Text('EMPLOYEE ID: ${_kTeacher.employeeId}',
                          style: AppTextStyles.label
                              .copyWith(color: Colors.white, letterSpacing: 0.6)),
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

  // ── Stats grid ─────────────────────────────────────────────────────────────

  Widget _buildStatsGrid() {
    final items = [
      (icon: Icons.menu_book_outlined, label: 'Total Courses',
       value: '${_kStats.totalCourses}', color: AppColors.primaryNavy),
      (icon: Icons.people_outline, label: 'Total Students',
       value: '${_kStats.totalStudents}', color: AppColors.primaryBlue),
      (icon: Icons.pending_actions_outlined, label: 'Pending Leaves',
       value: '${_kStats.pendingLeaves}', color: AppColors.statusAmber),
      (icon: Icons.today_outlined, label: "Today's Classes",
       value: '${_kStats.todayClasses}', color: AppColors.statusGreen),
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

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Quick Actions', style: AppTextStyles.h2),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 1.2,
          children: _kQuickActions.map((a) {
            return GestureDetector(
              onTap: () => context.push(a.route),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.bgCard,
                  borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
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

  Widget _buildTodaySchedule(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Today's Schedule", style: AppTextStyles.h2),
            GestureDetector(
              onTap: () => context.push('/teacher/schedule'),
              child: Text('Full Schedule', style: AppTextStyles.link),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ..._kScheduleToday.map((s) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _ScheduleTodayCard(item: s),
            )),
      ],
    );
  }

  // ── Pending leave requests ─────────────────────────────────────────────────

  Widget _buildPendingLeaves(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Pending Leave Requests', style: AppTextStyles.h2),
            GestureDetector(
              onTap: () => context.go('/teacher/students'),
              child: Text('View All', style: AppTextStyles.link),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: AppColors.bgCard,
            borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: _kPendingLeaves.asMap().entries.map((e) {
              final isLast = e.key == _kPendingLeaves.length - 1;
              return _buildLeaveRow(context, e.value, showDivider: !isLast);
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildLeaveRow(BuildContext context, dynamic leave,
      {required bool showDivider}) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.primaryNavy.withValues(alpha: 0.12),
                child: Text(leave.initials as String,
                    style: AppTextStyles.caption.copyWith(
                        color: AppColors.primaryNavy,
                        fontWeight: FontWeight.w700)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(leave.name as String, style: AppTextStyles.bodyMedium),
                    Text(leave.details as String,
                        style: AppTextStyles.caption),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: AppColors.statusRed, size: 20),
                onPressed: () {},
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.check, color: AppColors.statusGreen, size: 20),
                onPressed: () {},
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ),
        if (showDivider) const Divider(height: 1, color: AppColors.divider),
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
  const _ScheduleTodayCard({required this.item});
  final dynamic item;

  @override
  Widget build(BuildContext context) {
    final isCurrent = item.isCurrent as bool;
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
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: item.statusColor as Color,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              item.status as String,
              style: AppTextStyles.label
                  .copyWith(color: Colors.white, letterSpacing: 0.6),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.course as String, style: AppTextStyles.bodyMedium),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.access_time_outlined,
                        size: 12, color: AppColors.textSecondary),
                    const SizedBox(width: 3),
                    Text(item.time as String,
                        style: AppTextStyles.caption),
                    const SizedBox(width: 10),
                    const Icon(Icons.meeting_room_outlined,
                        size: 12, color: AppColors.textSecondary),
                    const SizedBox(width: 3),
                    Text(item.room as String,
                        style: AppTextStyles.caption),
                    const SizedBox(width: 10),
                    const Icon(Icons.people_outline,
                        size: 12, color: AppColors.textSecondary),
                    const SizedBox(width: 3),
                    Text('${item.students} Students',
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
