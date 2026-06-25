import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';

// ── Mock data ──────────────────────────────────────────────────────────────────

const _kStats = [
  (icon: Icons.school_outlined,               label: 'Total Students',    value: '45,210', sub: '↑ 2.3% this year',   color: AppColors.primaryBlue),
  (icon: Icons.person_outlined,               label: 'Faculty',           value: '1,840',  sub: 'Active: 114',         color: AppColors.primaryNavy),
  (icon: Icons.account_balance_outlined,      label: 'Departments',       value: '324',    sub: 'Across 6 Faculties',  color: Color(0xFF7C3AED)),
  (icon: Icons.account_balance_wallet_outlined, label: 'Revenue',         value: '\$2.4M', sub: '↑ 8.9% growth',       color: AppColors.statusGreen),
  (icon: Icons.event_note_outlined,           label: 'Leave Requests',    value: '142',    sub: 'Pending review',      color: AppColors.statusAmber),
  (icon: Icons.campaign_outlined,             label: 'Announcements',     value: '02',     sub: 'March 2024',          color: AppColors.statusRed),
];

const _kEnrollmentMonths = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'];
const _kEnrollmentValues = [0.55, 0.7, 0.65, 0.82, 0.75, 0.90];

final _kRevenueDepts = [
  (dept: 'Engineering',  pct: 0.82, color: AppColors.primaryNavy),
  (dept: 'Business',     pct: 0.65, color: AppColors.primaryBlue),
  (dept: 'IT',           pct: 0.74, color: Color(0xFF7C3AED)),
  (dept: 'Languages',    pct: 0.48, color: AppColors.statusAmber),
  (dept: 'Law',          pct: 0.41, color: AppColors.statusRed),
];

final _kQuickManagement = [
  (icon: Icons.school_outlined,         label: 'Students',  route: '/admin/users'),
  (icon: Icons.person_outlined,         label: 'Teachers',  route: '/admin/users'),
  (icon: Icons.menu_book_outlined,      label: 'Courses',   route: '/admin/academic'),
  (icon: Icons.date_range_outlined,     label: 'Semesters', route: '/admin/academic'),
  (icon: Icons.payments_outlined,       label: 'Payments',  route: '/admin/finance'),
  (icon: Icons.bar_chart_outlined,      label: 'Reports',   route: '/admin/finance'),
];

final _kRecentActivity = [
  (
    initials: 'SR', name: 'Sreynich Vong', action: 'Submitted leave request',
    tag: 'Pending', tagColor: AppColors.statusAmber, tagBg: AppColors.statusAmberBg, time: '10 min ago',
  ),
  (
    initials: 'JW', name: 'Dr. James Wilson', action: 'Added new assessment',
    tag: 'Approved', tagColor: AppColors.statusGreen, tagBg: AppColors.statusGreenBg, time: '1 hr ago',
  ),
  (
    initials: 'SK', name: 'Sok Khema', action: 'Payment received \$450',
    tag: 'Paid', tagColor: AppColors.primaryBlue, tagBg: AppColors.statusBlueBg, time: '2 hr ago',
  ),
  (
    initials: 'RP', name: 'Rath Piseth', action: 'Account suspended',
    tag: 'Alert', tagColor: AppColors.statusRed, tagBg: AppColors.statusRedBg, time: '3 hr ago',
  ),
];

// ── Screen ────────────────────────────────────────────────────────────────────

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        children: [
          Text('Overview', style: AppTextStyles.h1),
          const SizedBox(height: 14),
          _buildStatsGrid(),
          const SizedBox(height: AppSpacing.sectionGap),
          _buildEnrollmentTrends(),
          const SizedBox(height: AppSpacing.sectionGap),
          _buildAttendanceAndRevenue(),
          const SizedBox(height: AppSpacing.sectionGap),
          _buildAcademicPerformance(),
          const SizedBox(height: AppSpacing.sectionGap),
          _buildQuickManagement(context),
          const SizedBox(height: AppSpacing.sectionGap),
          _buildRecentActivity(context),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // ── Stats grid ─────────────────────────────────────────────────────────────

  Widget _buildStatsGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 1.7,
      children: _kStats.map((s) => _StatCard(stat: s)).toList(),
    );
  }

  // ── Enrollment trends ──────────────────────────────────────────────────────

  Widget _buildEnrollmentTrends() {
    return _SectionCard(
      title: 'Enrollment Trends',
      subtitle: 'Last 6 Months',
      child: SizedBox(
        height: 100,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(_kEnrollmentMonths.length, (i) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Expanded(
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 400),
                      width: 28,
                      height: _kEnrollmentValues[i] * 80,
                      decoration: BoxDecoration(
                        color: AppColors.primaryBlue.withValues(alpha: 0.15 + _kEnrollmentValues[i] * 0.5),
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(_kEnrollmentMonths[i],
                    style: AppTextStyles.label.copyWith(fontSize: 10)),
              ],
            );
          }),
        ),
      ),
    );
  }

  // ── Attendance + Revenue ───────────────────────────────────────────────────

  Widget _buildAttendanceAndRevenue() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _SectionCard(
            title: 'Attendance',
            child: Column(
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 80, height: 80,
                      child: CircularProgressIndicator(
                        value: 0.88,
                        strokeWidth: 10,
                        backgroundColor: AppColors.statusRedBg,
                        valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryBlue),
                      ),
                    ),
                    Text('88%', style: AppTextStyles.bodySemiBold.copyWith(fontSize: 16)),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _LegendDot(color: AppColors.primaryBlue, label: 'Present'),
                    const SizedBox(width: 10),
                    _LegendDot(color: AppColors.statusRedBg, label: 'Absent'),
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
            subtitle: 'by Dept',
            child: Column(
              children: _kRevenueDepts.map((d) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(d.dept,
                        style: AppTextStyles.label.copyWith(fontSize: 9)),
                    const SizedBox(height: 2),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: LinearProgressIndicator(
                        value: d.pct,
                        minHeight: 5,
                        backgroundColor: AppColors.border,
                        valueColor: AlwaysStoppedAnimation<Color>(d.color),
                      ),
                    ),
                  ],
                ),
              )).toList(),
            ),
          ),
        ),
      ],
    );
  }

  // ── Academic performance ───────────────────────────────────────────────────

  Widget _buildAcademicPerformance() {
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
          Text('Overall GPA trend across all faculties',
              style: AppTextStyles.captionWhite),
          const SizedBox(height: 16),
          Row(
            children: [
              _PerformanceStat(value: '3.42', label: 'Avg GPA', positive: true),
              const SizedBox(width: 24),
              _PerformanceStat(value: '94.8%', label: 'Pass Rate', positive: true),
              const SizedBox(width: 24),
              _PerformanceStat(value: '314', label: 'Honors', positive: false),
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

  // ── Recent activity ────────────────────────────────────────────────────────

  Widget _buildRecentActivity(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Recent Activity', style: AppTextStyles.h2),
            TextButton(
              onPressed: () {},
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
            children: _kRecentActivity.asMap().entries.map((e) {
              final isLast = e.key == _kRecentActivity.length - 1;
              final a = e.value;
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundColor: AppColors.primaryNavy.withValues(alpha: 0.1),
                          child: Text(a.initials,
                              style: AppTextStyles.caption.copyWith(
                                  color: AppColors.primaryNavy,
                                  fontWeight: FontWeight.w700)),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(a.name, style: AppTextStyles.bodyMedium),
                              Text(a.action, style: AppTextStyles.caption),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                              decoration: BoxDecoration(
                                color: a.tagBg,
                                borderRadius: BorderRadius.circular(AppSpacing.tagRadius),
                              ),
                              child: Text(a.tag,
                                  style: AppTextStyles.label.copyWith(
                                      color: a.tagColor, letterSpacing: 0.3)),
                            ),
                            const SizedBox(height: 4),
                            Text(a.time,
                                style: AppTextStyles.label.copyWith(fontSize: 9)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (!isLast) const Divider(height: 1, color: AppColors.divider),
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
  final ({IconData icon, String label, String value, String sub, Color color}) stat;

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
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                Text(stat.value,
                    style: AppTextStyles.metric.copyWith(
                        color: stat.color,
                        fontSize: stat.value.length > 5 ? 16 : 20),
                    maxLines: 1),
                Text(stat.sub,
                    style: AppTextStyles.label.copyWith(fontSize: 9, letterSpacing: 0),
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
                Text(subtitle!,
                    style: AppTextStyles.caption.copyWith(fontSize: 11)),
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
        Container(
          width: 8, height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label, style: AppTextStyles.label.copyWith(fontSize: 10)),
      ],
    );
  }
}

class _PerformanceStat extends StatelessWidget {
  const _PerformanceStat(
      {required this.value, required this.label, required this.positive});
  final String value;
  final String label;
  final bool positive;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value,
            style: AppTextStyles.h2.copyWith(color: Colors.white, fontSize: 20)),
        Text(label,
            style: AppTextStyles.captionWhite.copyWith(fontSize: 11)),
      ],
    );
  }
}
