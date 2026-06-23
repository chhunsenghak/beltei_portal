import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/router/app_router.dart';
import '../../../shared/widgets/section_header.dart';

// ── Mock data ──────────────────────────────────────────────────────────────────

const _kStudent = (
  name: 'SOVANN REAKSA',
  id: 'ID: B-2024-00892',
  faculty: 'Faculty of Business Administration',
  major: 'Accounting & Finance | Semester 5',
);

const _kAcademic = (
  gpa: '3.85',
  cgpa: '3.72',
  creditsDone: 82,
  creditsLeft: 38,
);

const _kAttendance = (
  overallRate: '94.2%',
  present: 48,
  absent: 2,
  leave: 1,
);

const _kFinance = (
  totalFee: '\$1,250.00',
  paid: '\$850.00',
  outstanding: '\$400.00',
  dueDate: 'Oct 15, 2024',
  status: 'PARTIAL',
);

final _kActivities = [
  (
    icon: Icons.quiz_outlined,
    iconBg: AppColors.statusBlueBg,
    iconColor: AppColors.primaryBlue,
    title: 'Quiz 1: Microeconomics',
    subtitle: 'Grade released: 9.5/10',
    time: '2 HOURS AGO',
  ),
  (
    icon: Icons.credit_card_outlined,
    iconBg: AppColors.statusGreenBg,
    iconColor: AppColors.statusGreen,
    title: 'Tuition Payment Success',
    subtitle: 'Amount: \$450.00 | Receipt #00938',
    time: 'YESTERDAY',
  ),
  (
    icon: Icons.campaign_outlined,
    iconBg: AppColors.statusAmberBg,
    iconColor: AppColors.statusAmber,
    title: 'Faculty Holiday Notice',
    subtitle: 'Campus closed on upcoming Monday.',
    time: 'SEP 24, 2024',
  ),
];

// ── Screen ────────────────────────────────────────────────────────────────────

class StudentDashboardScreen extends StatelessWidget {
  const StudentDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          SliverToBoxAdapter(child: _buildStudentHeader()),
          SliverPadding(
            padding: const EdgeInsets.all(AppSpacing.screenPadding),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildQuickActions(context),
                const SizedBox(height: AppSpacing.sectionGap),
                _buildAcademicSummary(),
                const SizedBox(height: AppSpacing.sectionGap),
                _buildAttendanceOverview(),
                const SizedBox(height: AppSpacing.sectionGap),
                _buildFinancialSummary(context),
                const SizedBox(height: AppSpacing.sectionGap),
                _buildRecentActivities(context),
                const SizedBox(height: 24),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  // ── App bar ────────────────────────────────────────────────────────────────

  Widget _buildAppBar() {
    return SliverAppBar(
      pinned: true,
      automaticallyImplyLeading: false,
      backgroundColor: AppColors.primaryNavy,
      toolbarHeight: 64,
      titleSpacing: 0,
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined, color: Colors.white),
          onPressed: () {},
        ),
      ],
      title: Padding(
        padding: const EdgeInsets.only(left: 16),
        child: Row(
          children: [
            Image.asset('assets/images/beltei_logo.png', height: 48, fit: BoxFit.contain),
            const SizedBox(width: 10),
            Text('BELTEI Campus', style: AppTextStyles.h3White),
          ],
        ),
      ),
    );
  }

  // ── Student header card ────────────────────────────────────────────────────

  Widget _buildStudentHeader() {
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
                Text(_kStudent.name, style: AppTextStyles.h2White),
                const SizedBox(height: 2),
                Text(_kStudent.id,
                    style: AppTextStyles.captionWhite.copyWith(fontSize: 12)),
                Text(_kStudent.faculty,
                    style: AppTextStyles.captionWhite.copyWith(fontSize: 11)),
                Text(_kStudent.major,
                    style: AppTextStyles.captionWhite.copyWith(fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Quick actions ──────────────────────────────────────────────────────────

  Widget _buildQuickActions(BuildContext context) {
    final actions = [
      (icon: Icons.calendar_today_outlined, label: 'Attendance', route: AppRoutes.attendanceDashboard),
      (icon: Icons.beach_access_outlined, label: 'Leave', route: AppRoutes.leaveRequestDashboard),
      (icon: Icons.menu_book_outlined, label: 'Courses', route: AppRoutes.courseList),
      (icon: Icons.grade_outlined, label: 'Grades', route: AppRoutes.gradesDashboard),
    ];

    return Column(
      children: [
        SectionHeader(title: 'Quick Actions', actionLabel: 'SEE ALL', onAction: () {}),
        const SizedBox(height: 12),
        Row(
          children: actions.map((a) {
            return Expanded(
              child: GestureDetector(
                onTap: () => context.go(a.route),
                child: Column(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: AppColors.bgCard,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Icon(a.icon, color: AppColors.primaryNavy, size: 24),
                    ),
                    const SizedBox(height: 6),
                    Text(a.label,
                        style: AppTextStyles.caption.copyWith(fontSize: 11)),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // ── Academic summary ───────────────────────────────────────────────────────

  Widget _buildAcademicSummary() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Academic Summary',
          icon: Icons.school_outlined,
        ),
        const SizedBox(height: 12),
        _SummaryGrid(items: [
          _SummaryItem(label: 'GPA (Current)', value: _kAcademic.gpa, valueColor: AppColors.primaryNavy),
          _SummaryItem(label: 'CGPA', value: _kAcademic.cgpa),
          _SummaryItem(label: 'Credits Done', value: '${_kAcademic.creditsDone}'),
          _SummaryItem(label: 'Credits Left', value: '${_kAcademic.creditsLeft}'),
        ]),
      ],
    );
  }

  // ── Attendance overview ────────────────────────────────────────────────────

  Widget _buildAttendanceOverview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Attendance Overview',
          icon: Icons.person_outline,
        ),
        const SizedBox(height: 12),
        _SummaryGrid(items: [
          _SummaryItem(
            label: 'Overall Rate',
            value: _kAttendance.overallRate,
            valueColor: AppColors.primaryBlue,
          ),
          _SummaryItem(
            label: 'Present',
            value: '${_kAttendance.present}',
            trailingIcon: Icons.check_circle_outline,
            trailingColor: AppColors.statusGreen,
          ),
          _SummaryItem(
            label: 'Absent',
            value: '${_kAttendance.absent}',
            valueColor: AppColors.statusRed,
            trailingIcon: Icons.cancel_outlined,
            trailingColor: AppColors.statusRed,
          ),
          _SummaryItem(
            label: 'Leave',
            value: '${_kAttendance.leave}',
            valueColor: AppColors.statusAmber,
            trailingIcon: Icons.watch_later_outlined,
            trailingColor: AppColors.statusAmber,
          ),
        ]),
      ],
    );
  }

  // ── Financial summary ──────────────────────────────────────────────────────

  Widget _buildFinancialSummary(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Financial Summary',
          icon: Icons.account_balance_wallet_outlined,
          actionLabel: 'SEE ALL',
          onAction: () => context.go(AppRoutes.financeDashboard),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(AppSpacing.cardPadding),
          decoration: BoxDecoration(
            color: AppColors.bgCard,
            borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildFinanceTopRow(),
              const SizedBox(height: 12),
              const Divider(color: AppColors.border),
              const SizedBox(height: 12),
              _buildFinanceAmounts(),
              const SizedBox(height: 12),
              _buildDueDateBanner(),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton.icon(
                  onPressed: () => context.go(AppRoutes.onlinePayment),
                  icon: const Icon(Icons.payment, size: 16),
                  label: Text('Pay Now', style: AppTextStyles.button),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFinanceTopRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Total Semester Fee', style: AppTextStyles.label),
              const SizedBox(height: 4),
              Text(_kFinance.totalFee,
                  style: AppTextStyles.metric.copyWith(fontSize: 22)),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.statusAmberBg,
            borderRadius: BorderRadius.circular(AppSpacing.chipRadius),
          ),
          child: Text(
            _kFinance.status,
            style: AppTextStyles.label.copyWith(color: AppColors.statusAmber),
          ),
        ),
      ],
    );
  }

  Widget _buildFinanceAmounts() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Paid', style: AppTextStyles.label),
              const SizedBox(height: 2),
              Text(_kFinance.paid,
                  style: AppTextStyles.metricSmall.copyWith(
                      color: AppColors.statusGreen, fontSize: 18)),
            ],
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Outstanding', style: AppTextStyles.label),
              const SizedBox(height: 2),
              Text(_kFinance.outstanding,
                  style: AppTextStyles.metricSmall.copyWith(
                      color: AppColors.statusRed, fontSize: 18)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDueDateBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.statusAmberBg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.access_time, color: AppColors.statusAmber, size: 18),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('DUE DATE REMINDER',
                  style: AppTextStyles.label.copyWith(color: AppColors.statusAmber)),
              Text(_kFinance.dueDate,
                  style: AppTextStyles.bodySemiBold.copyWith(color: AppColors.statusAmber)),
            ],
          ),
        ],
      ),
    );
  }

  // ── Recent activities ──────────────────────────────────────────────────────

  Widget _buildRecentActivities(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Recent Activities',
          icon: Icons.history,
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: AppColors.bgCard,
            borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: [
              ..._kActivities.asMap().entries.map((e) {
                final isLast = e.key == _kActivities.length - 1;
                return _buildActivityItem(e.value, showDivider: !isLast);
              }),
              const Divider(height: 1, color: AppColors.border),
              TextButton(
                onPressed: () {},
                child: Text('VIEW FULL HISTORY',
                    style: AppTextStyles.label.copyWith(
                        color: AppColors.primaryBlue, letterSpacing: 1.0)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActivityItem(dynamic activity, {required bool showDivider}) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: activity.iconBg as Color,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(activity.icon as IconData,
                    color: activity.iconColor as Color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(activity.title as String, style: AppTextStyles.bodyMedium),
                    const SizedBox(height: 2),
                    Text(activity.subtitle as String,
                        style: AppTextStyles.caption),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(activity.time as String,
                  style: AppTextStyles.label.copyWith(fontSize: 10)),
            ],
          ),
        ),
        if (showDivider) const Divider(height: 1, color: AppColors.divider),
      ],
    );
  }
}

// ── Reusable 2x2 summary grid ──────────────────────────────────────────────────

class _SummaryGrid extends StatelessWidget {
  const _SummaryGrid({required this.items});
  final List<_SummaryItem> items;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 1.8,
      children: items,
    );
  }
}

class _SummaryItem extends StatelessWidget {
  const _SummaryItem({
    required this.label,
    required this.value,
    this.valueColor,
    this.trailingIcon,
    this.trailingColor,
  });

  final String label;
  final String value;
  final Color? valueColor;
  final IconData? trailingIcon;
  final Color? trailingColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label.toUpperCase(), style: AppTextStyles.label),
          const SizedBox(height: 4),
          Row(
            children: [
              Text(
                value,
                style: AppTextStyles.metricSmall.copyWith(
                  color: valueColor ?? AppColors.textPrimary,
                  fontSize: 22,
                ),
              ),
              if (trailingIcon != null) ...[
                const Spacer(),
                Icon(trailingIcon, color: trailingColor, size: 20),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
