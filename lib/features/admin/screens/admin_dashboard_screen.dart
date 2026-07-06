import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/providers/admin_providers.dart';
import '../../../core/services/admin_service.dart';

final _kQuickManagement = [
  (icon: Icons.school_outlined,     label: 'Students',  route: '/admin/users'),
  (icon: Icons.person_outlined,     label: 'Teachers',  route: '/admin/users'),
  (icon: Icons.menu_book_outlined,  label: 'Courses',   route: '/admin/academic'),
  (icon: Icons.class_outlined,      label: 'Classes',   route: '/admin/academic'),
  (icon: Icons.how_to_reg_outlined, label: 'Enrollment',route: '/admin/academic'),
  (icon: Icons.payments_outlined,   label: 'Payments',  route: '/admin/finance'),
];

final _kBarColors = [
  AppColors.primaryNavy,
  AppColors.primaryBlue,
  Color(0xFF7C3AED),
  AppColors.statusAmber,
  AppColors.statusRed,
];

// ── Screen ────────────────────────────────────────────────────────────────────

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(adminStatsProvider);
    final leavesAsync = ref.watch(adminLeaveRequestsProvider);
    final analyticsAsync = ref.watch(adminAnalyticsProvider);
    final analytics = analyticsAsync.valueOrNull;

    return Scaffold(
      backgroundColor: AppColors.bgPage,
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        children: [
          Text('Overview', style: AppTextStyles.h1),
          const SizedBox(height: 14),
          statsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => _buildStatsError(ref),
            data: (stats) => _buildStatsGrid(stats),
          ),
          const SizedBox(height: AppSpacing.sectionGap),
          _buildEnrollmentTrends(analytics),
          const SizedBox(height: AppSpacing.sectionGap),
          statsAsync.when(
            loading: () => const SizedBox.shrink(),
            error: (_, _) => const SizedBox.shrink(),
            data: (stats) => _buildAttendanceAndRevenue(stats, analytics),
          ),
          const SizedBox(height: AppSpacing.sectionGap),
          _buildAcademicPerformance(analytics),
          const SizedBox(height: AppSpacing.sectionGap),
          _buildQuickManagement(context),
          const SizedBox(height: AppSpacing.sectionGap),
          leavesAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, _) => const SizedBox.shrink(),
            data: (leaves) => _buildRecentLeaves(context, leaves),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildStatsError(WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: AppColors.statusRed),
          const SizedBox(width: 8),
          const Expanded(child: Text('Could not load stats')),
          TextButton(
            onPressed: () => ref.invalidate(adminStatsProvider),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  // ── Stats grid ─────────────────────────────────────────────────────────────

  Widget _buildStatsGrid(AdminStats stats) {
    final items = [
      (icon: Icons.school_outlined, label: 'Total\nStudents', value: '${stats.studentCount}', color: AppColors.primaryBlue),
      (icon: Icons.person_outlined, label: 'Active\nTeachers', value: '${stats.teacherCount}', color: AppColors.primaryNavy),
      (icon: Icons.menu_book_outlined, label: 'Active\nCourses', value: '${stats.courseCount}', color: Color(0xFF7C3AED)),
      (icon: Icons.account_balance_wallet_outlined, label: 'Revenue\nCollected', value: stats.fmtCollected, color: AppColors.statusGreen),
      (icon: Icons.event_note_outlined, label: 'Leave\nPending', value: '${stats.pendingLeaveCount}', color: AppColors.statusAmber),
      (icon: Icons.calendar_month_outlined, label: 'Current\nSemester', value: stats.currentSemester.split(',').first, color: AppColors.statusRed),
    ];
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 1.7,
      children: items.map((s) => _StatCard(stat: s)).toList(),
    );
  }

  // ── Enrollment trends ──────────────────────────────────────────────────────

  Widget _buildEnrollmentTrends(AdminAnalyticsData? analytics) {
    // Last 6 months of the 12-month data
    final monthly = analytics != null && analytics.monthlyEnrollments.length >= 6
        ? analytics.monthlyEnrollments.sublist(
            analytics.monthlyEnrollments.length - 6)
        : List.generate(6, (i) => (month: '', count: 0));

    final maxCount = monthly.fold<int>(
        1, (m, e) => e.count > m ? e.count : m);

    return _SectionCard(
      title: 'Enrollment Trends',
      subtitle: 'Last 6 Months',
      child: SizedBox(
        height: 100,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(monthly.length, (i) {
            final norm = monthly[i].count / maxCount;
            return Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Expanded(
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 400),
                      width: 28,
                      height: (norm * 80).clamp(2.0, 80.0),
                      decoration: BoxDecoration(
                        color: AppColors.primaryBlue
                            .withValues(alpha: 0.15 + norm * 0.5),
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(4)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(monthly[i].month,
                    style: AppTextStyles.label.copyWith(fontSize: 10)),
              ],
            );
          }),
        ),
      ),
    );
  }

  // ── Attendance + Revenue ───────────────────────────────────────────────────

  Widget _buildAttendanceAndRevenue(
      AdminStats stats, AdminAnalyticsData? analytics) {
    final totalBilled = stats.totalRevenue;
    final collected = stats.collectedRevenue;
    final collectedPct = totalBilled > 0 ? collected / totalBilled : 0.0;

    final depts = analytics?.facultyRevenue ?? [];

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _SectionCard(
            title: 'Revenue',
            subtitle: 'Collection Rate',
            child: Column(
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 80,
                      height: 80,
                      child: CircularProgressIndicator(
                        value: collectedPct,
                        strokeWidth: 10,
                        backgroundColor: AppColors.statusRedBg,
                        valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.primaryBlue),
                      ),
                    ),
                    Text('${(collectedPct * 100).round()}%',
                        style: AppTextStyles.bodySemiBold
                            .copyWith(fontSize: 16)),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _LegendDot(
                        color: AppColors.primaryBlue, label: 'Collected'),
                    const SizedBox(width: 10),
                    _LegendDot(
                        color: AppColors.statusRedBg, label: 'Pending'),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _SectionCard(
            title: 'Revenue',
            subtitle: 'by Faculty',
            child: depts.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : Column(
                    children: List.generate(
                      depts.length.clamp(0, 5),
                      (i) {
                        final barColor = _kBarColors[
                            i % _kBarColors.length];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(depts[i].name,
                                  style: AppTextStyles.label
                                      .copyWith(fontSize: 9),
                                  overflow: TextOverflow.ellipsis),
                              const SizedBox(height: 2),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(3),
                                child: LinearProgressIndicator(
                                  value: depts[i].collectedPct,
                                  minHeight: 5,
                                  backgroundColor: AppColors.border,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      barColor),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  // ── Academic performance ───────────────────────────────────────────────────

  Widget _buildAcademicPerformance(AdminAnalyticsData? analytics) {
    final gpa = analytics != null
        ? analytics.avgGpa.toStringAsFixed(2)
        : '—';
    final pass = analytics != null
        ? '${(analytics.passRate * 100).toStringAsFixed(1)}%'
        : '—';

    return Container(
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0D9488), Color(0xFF0891B2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Academic Performance',
              style: AppTextStyles.h3.copyWith(color: Colors.white)),
          const SizedBox(height: 4),
          Text('Overall GPA & pass rate across all faculties',
              style: AppTextStyles.captionWhite),
          const SizedBox(height: 16),
          Row(
            children: [
              _PerformanceStat(value: gpa, label: 'Avg GPA'),
              const SizedBox(width: 24),
              _PerformanceStat(value: pass, label: 'Pass Rate'),
            ],
          ),
        ],
      ),
    );
  }

  // ── Quick management ───────────────────────────────────────────────────────

  Widget _buildQuickManagement(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Quick Management', style: AppTextStyles.h2),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 1.2,
          children: _kQuickManagement.map((item) {
            return GestureDetector(
              onTap: () => context.go(item.route),
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
                      width: 42, height: 42,
                      decoration: BoxDecoration(
                        color: AppColors.primaryNavy.withValues(alpha: 0.08),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(item.icon, color: AppColors.primaryNavy, size: 20),
                    ),
                    const SizedBox(height: 6),
                    Text(item.label,
                        style: AppTextStyles.caption.copyWith(
                            fontSize: 11, fontWeight: FontWeight.w600),
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

  // ── Recent leave requests ──────────────────────────────────────────────────

  Widget _buildRecentLeaves(BuildContext context, List<AdminLeaveRequest> all) {
    final recent = all.take(5).toList();
    if (recent.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Recent Leave Requests', style: AppTextStyles.h2),
            TextButton(
              onPressed: () => context.go('/admin/academic?tab=leave'),
              child: Text('View All', style: AppTextStyles.link),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.bgCard,
            borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: recent.asMap().entries.map((e) {
              final isLast = e.key == recent.length - 1;
              final leave = e.value;
              final tagColor = switch (leave.status.name) {
                'approved' => AppColors.statusGreen,
                'rejected' => AppColors.statusRed,
                _ => AppColors.statusAmber,
              };
              final tagBg = switch (leave.status.name) {
                'approved' => AppColors.statusGreenBg,
                'rejected' => AppColors.statusRedBg,
                _ => AppColors.statusAmberBg,
              };
              final tagLabel = switch (leave.status.name) {
                'approved' => 'Approved',
                'rejected' => 'Rejected',
                _ => 'Pending',
              };
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundColor: AppColors.primaryNavy.withValues(alpha: 0.1),
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
                              Text(leave.requesterName, style: AppTextStyles.bodyMedium),
                              Text('${leave.type} • ${leave.dateRange}',
                                  style: AppTextStyles.caption),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                          decoration: BoxDecoration(
                            color: tagBg,
                            borderRadius: BorderRadius.circular(AppSpacing.tagRadius),
                          ),
                          child: Text(tagLabel,
                              style: AppTextStyles.label.copyWith(
                                  color: tagColor, letterSpacing: 0.3)),
                        ),
                      ],
                    ),
                  ),
                  if (!isLast) Divider(height: 1, color: AppColors.divider),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

// ── Supporting widgets ────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  const _StatCard({required this.stat});
  final ({IconData icon, String label, String value, Color color}) stat;

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
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: stat.color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(stat.icon, color: stat.color, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(stat.label,
                    style: AppTextStyles.label.copyWith(fontSize: 9),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
                Text(stat.value,
                    style: AppTextStyles.metric.copyWith(
                        color: stat.color,
                        fontSize: stat.value.length > 5 ? 15 : 20),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, this.subtitle, required this.child});
  final String title;
  final String? subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: AppTextStyles.h3),
              if (subtitle != null)
                Text(subtitle!, style: AppTextStyles.caption.copyWith(fontSize: 11)),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(label, style: AppTextStyles.label.copyWith(fontSize: 10)),
      ],
    );
  }
}

class _PerformanceStat extends StatelessWidget {
  const _PerformanceStat({required this.value, required this.label});
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value, style: AppTextStyles.h2.copyWith(color: Colors.white, fontSize: 20)),
        Text(label, style: AppTextStyles.captionWhite.copyWith(fontSize: 11)),
      ],
    );
  }
}
