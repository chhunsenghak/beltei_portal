import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';

// ── Mock data ──────────────────────────────────────────────────────────────────

final _kMonthlyEnrollment = [
  (month: 'Jan', count: 95),
  (month: 'Feb', count: 110),
  (month: 'Mar', count: 88),
  (month: 'Apr', count: 130),
  (month: 'May', count: 142),
  (month: 'Jun', count: 120),
  (month: 'Jul', count: 105),
  (month: 'Aug', count: 160),
  (month: 'Sep', count: 175),
  (month: 'Oct', count: 155),
  (month: 'Nov', count: 140),
  (month: 'Dec', count: 120),
];

final _kFinanceSummary = [
  (label: 'Total Revenue',      value: '\$1,250,400', icon: Icons.trending_up_outlined,      color: AppColors.statusGreen),
  (label: 'Outstanding Fees',   value: '\$48,200',    icon: Icons.pending_actions_outlined,   color: AppColors.statusAmber),
  (label: 'Refunds Issued',     value: '\$12,500',    icon: Icons.undo_outlined,              color: AppColors.statusRed),
  (label: 'Scholarships Given', value: '\$35,000',    icon: Icons.card_giftcard_outlined,     color: AppColors.primaryBlue),
];

final _kTopCourses = [
  (code: 'BA201', title: 'Financial Accounting', enrolled: 55, capacity: 60, pct: 0.92),
  (code: 'CS101', title: 'Intro to Algorithms',  enrolled: 45, capacity: 50, pct: 0.90),
  (code: 'BA305', title: 'Marketing Strategy',   enrolled: 40, capacity: 50, pct: 0.80),
  (code: 'ENG202',title: 'Structural Engineering',enrolled:30, capacity: 40, pct: 0.75),
  (code: 'CS205', title: 'Web Dev Frameworks',   enrolled: 32, capacity: 45, pct: 0.71),
];

final _kAttendanceStats = [
  (dept: 'Computer Science', rate: 0.87, label: '87%'),
  (dept: 'Business Admin',   rate: 0.81, label: '81%'),
  (dept: 'Engineering',      rate: 0.79, label: '79%'),
  (dept: 'Law & Politics',   rate: 0.74, label: '74%'),
  (dept: 'Education',        rate: 0.91, label: '91%'),
];

final _kExportOptions = [
  (icon: Icons.description_outlined,   label: 'Enrollment Report',  subtitle: 'PDF / Excel'),
  (icon: Icons.account_balance_outlined,label: 'Finance Report',     subtitle: 'PDF / Excel'),
  (icon: Icons.how_to_reg_outlined,     label: 'Attendance Report',  subtitle: 'PDF / Excel'),
  (icon: Icons.grade_outlined,          label: 'Academic Report',    subtitle: 'PDF / Excel'),
];

// ── Screen ────────────────────────────────────────────────────────────────────

class AdminReportsScreen extends StatelessWidget {
  const AdminReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      appBar: AppBar(
        backgroundColor: AppColors.primaryNavy,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.go('/admin'),
        ),
        title: Text('Reports & Analytics', style: AppTextStyles.h3White),
        actions: [
          IconButton(
            icon: const Icon(Icons.download_outlined, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFinanceCards(),
            const SizedBox(height: AppSpacing.sectionGap),
            _buildEnrollmentChart(),
            const SizedBox(height: AppSpacing.sectionGap),
            _buildTopCourses(),
            const SizedBox(height: AppSpacing.sectionGap),
            _buildAttendanceRates(),
            const SizedBox(height: AppSpacing.sectionGap),
            _buildExportSection(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // ── Finance cards ──────────────────────────────────────────────────────────

  Widget _buildFinanceCards() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Financial Overview', style: AppTextStyles.h2),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 1.7,
          children: _kFinanceSummary.map((f) {
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
                  Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: f.color.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child:
                            Icon(f.icon, color: f.color, size: 16),
                      ),
                      const Spacer(),
                      Icon(Icons.arrow_upward,
                          size: 12,
                          color: f.color == AppColors.statusRed ||
                                  f.color == AppColors.statusAmber
                              ? f.color
                              : AppColors.statusGreen),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(f.value,
                      style: AppTextStyles.metricSmall
                          .copyWith(color: f.color, fontSize: 17)),
                  Text(f.label,
                      style: AppTextStyles.label
                          .copyWith(fontSize: 9, letterSpacing: 0.3),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // ── Enrollment chart (bar chart via sized boxes) ────────────────────────────

  Widget _buildEnrollmentChart() {
    final maxCount =
        _kMonthlyEnrollment.map((e) => e.count).reduce((a, b) => a > b ? a : b);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Monthly Enrollment — 2024', style: AppTextStyles.h2),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.fromLTRB(12, 16, 12, 12),
          decoration: BoxDecoration(
            color: AppColors.bgCard,
            borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: [
              SizedBox(
                height: 120,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: _kMonthlyEnrollment.map((e) {
                    final barH = (e.count / maxCount) * 110;
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        child: Tooltip(
                          message: '${e.count}',
                          child: Container(
                            height: barH,
                            decoration: BoxDecoration(
                              color: AppColors.primaryNavy
                                  .withValues(alpha: 0.75),
                              borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(3)),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: _kMonthlyEnrollment.map((e) {
                  return Expanded(
                    child: Text(e.month,
                        style:
                            AppTextStyles.caption.copyWith(fontSize: 9),
                        textAlign: TextAlign.center),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Top courses ────────────────────────────────────────────────────────────

  Widget _buildTopCourses() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Top Enrolled Courses', style: AppTextStyles.h2),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(AppSpacing.cardPadding),
          decoration: BoxDecoration(
            color: AppColors.bgCard,
            borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: _kTopCourses.asMap().entries.map((entry) {
              final i = entry.key;
              final c = entry.value;
              return Padding(
                padding: EdgeInsets.only(
                    bottom: i < _kTopCourses.length - 1 ? 12 : 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            color: i == 0
                                ? AppColors.accentGold.withValues(alpha: 0.15)
                                : AppColors.bgInput,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text('${i + 1}',
                                style: AppTextStyles.label.copyWith(
                                    color: i == 0
                                        ? AppColors.accentGold
                                        : AppColors.textSecondary,
                                    letterSpacing: 0)),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(c.title,
                              style: AppTextStyles.bodyMedium
                                  .copyWith(fontSize: 13)),
                        ),
                        Text('${c.enrolled}/${c.capacity}',
                            style: AppTextStyles.caption
                                .copyWith(fontSize: 11)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: c.pct,
                        minHeight: 5,
                        backgroundColor: AppColors.border,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          c.pct >= 0.9
                              ? AppColors.statusGreen
                              : c.pct >= 0.75
                                  ? AppColors.primaryBlue
                                  : AppColors.statusAmber,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  // ── Attendance rates ───────────────────────────────────────────────────────

  Widget _buildAttendanceRates() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Attendance Rates by Department', style: AppTextStyles.h2),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(AppSpacing.cardPadding),
          decoration: BoxDecoration(
            color: AppColors.bgCard,
            borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: _kAttendanceStats.map((a) {
              final color = a.rate >= 0.85
                  ? AppColors.statusGreen
                  : a.rate >= 0.75
                      ? AppColors.statusAmber
                      : AppColors.statusRed;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    SizedBox(
                      width: 130,
                      child: Text(a.dept,
                          style: AppTextStyles.caption,
                          overflow: TextOverflow.ellipsis),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: a.rate,
                          minHeight: 8,
                          backgroundColor: AppColors.border,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(color),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    SizedBox(
                      width: 34,
                      child: Text(a.label,
                          style: AppTextStyles.caption.copyWith(
                              color: color,
                              fontWeight: FontWeight.w600),
                          textAlign: TextAlign.right),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  // ── Export section ─────────────────────────────────────────────────────────

  Widget _buildExportSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Export Reports', style: AppTextStyles.h2),
        const SizedBox(height: 12),
        ...(_kExportOptions.map((opt) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.cardPadding),
                decoration: BoxDecoration(
                  color: AppColors.bgCard,
                  borderRadius:
                      BorderRadius.circular(AppSpacing.cardRadius),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.primaryNavy.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(opt.icon,
                          color: AppColors.primaryNavy, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(opt.label,
                              style: AppTextStyles.bodyMedium),
                          Text(opt.subtitle,
                              style: AppTextStyles.caption),
                        ],
                      ),
                    ),
                    const Icon(Icons.download_outlined,
                        color: AppColors.primaryBlue, size: 20),
                  ],
                ),
              ),
            ))),
      ],
    );
  }
}
