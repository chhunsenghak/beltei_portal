import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';

// ── Mock data ──────────────────────────────────────────────────────────────────

const _kFinance = (
  totalFee: '\$12,450.00',
  totalFeeNum: 12450.0,
  totalPaid: '\$8,200.00',
  totalPaidNum: 8200.0,
  outstanding: '\$4,250.00',
  outstandingNum: 4250.0,
  paidPercent: 0.66,
  dueDate: 'Oct 15, 2023',
  dueName: 'Fall Semester Installment',
  academicYear: 'Academic Year 2023-24',
);

final _kInvoices = [
  (no: 'INV-2023-001', semester: 'Fall 2023', date: 'Sep 05, 2023', amount: '\$3,200', status: 'Paid'),
  (no: 'INV-2023-002', semester: 'Spring 2023', date: 'Jan 12, 2023', amount: '\$3,200', status: 'Paid'),
  (no: 'INV-2023-003', semester: 'Summer 2023', date: 'Jun 10, 2023', amount: '\$1,800', status: 'Paid'),
  (no: 'INV-2023-004', semester: 'Special Lab Fee', date: 'Oct 02, 2023', amount: '\$250', status: 'Pending'),
];

// ── Screen ────────────────────────────────────────────────────────────────────

class FinanceDashboardScreen extends StatelessWidget {
  const FinanceDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      floatingActionButton: _buildPayNowFab(context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTitle(),
            const SizedBox(height: AppSpacing.md),
            _buildSummaryCards(),
            const SizedBox(height: AppSpacing.sectionGap),
            _buildPaymentProgressCard(),
            const SizedBox(height: AppSpacing.sectionGap),
            _buildPaymentHistory(context),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  // ── FAB ────────────────────────────────────────────────────────────────────

  Widget _buildPayNowFab(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () => context.go('/student/finance/payment'),
      backgroundColor: AppColors.primaryBlue,
      icon: const Icon(Icons.payment, color: Colors.white),
      label: Text('PAY NOW', style: AppTextStyles.button.copyWith(fontSize: 13)),
    );
  }

  // ── Title ──────────────────────────────────────────────────────────────────

  Widget _buildTitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Finance Overview', style: AppTextStyles.h1),
        const SizedBox(height: 4),
        Text('Manage your tuition fees and payment history for the current academic year.',
            style: AppTextStyles.caption.copyWith(height: 1.4)),
      ],
    );
  }

  // ── Summary cards ──────────────────────────────────────────────────────────

  Widget _buildSummaryCards() {
    final items = [
      (label: 'TOTAL FEE', value: _kFinance.totalFee, sub: _kFinance.academicYear,
       icon: Icons.receipt_outlined, iconColor: AppColors.primaryNavy,
       valueColor: AppColors.textPrimary),
      (label: 'TOTAL PAID', value: _kFinance.totalPaid, sub: '65.8% of total completed',
       icon: Icons.check_circle_outline, iconColor: AppColors.statusGreen,
       valueColor: AppColors.statusGreen),
      (label: 'OUTSTANDING', value: _kFinance.outstanding, sub: 'Immediate action required',
       icon: Icons.warning_amber_outlined, iconColor: AppColors.statusRed,
       valueColor: AppColors.statusRed),
      (label: 'NEXT DUE DATE', value: _kFinance.dueDate, sub: _kFinance.dueName,
       icon: Icons.event_outlined, iconColor: AppColors.statusAmber,
       valueColor: AppColors.statusAmber),
    ];

    return Column(
      children: items.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _SummaryCard(
              label: item.label,
              value: item.value,
              sub: item.sub,
              icon: item.icon,
              iconColor: item.iconColor,
              valueColor: item.valueColor,
            ),
          )).toList(),
    );
  }

  // ── Payment progress ───────────────────────────────────────────────────────

  Widget _buildPaymentProgressCard() {
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
          Text('Payment Progress', style: AppTextStyles.h2.copyWith(color: AppColors.primaryNavy)),
          const SizedBox(height: 14),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryNavy,
                  borderRadius: BorderRadius.circular(AppSpacing.chipRadius),
                ),
                child: Text('ONGOING',
                    style: AppTextStyles.label.copyWith(color: Colors.white)),
              ),
              const Spacer(),
              Text(
                '${(_kFinance.paidPercent * 100).round()}%',
                style: AppTextStyles.bodySemiBold.copyWith(color: AppColors.primaryNavy),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: _kFinance.paidPercent,
              minHeight: 10,
              backgroundColor: AppColors.border,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryNavy),
            ),
          ),
          const SizedBox(height: 12),
          _buildLegendRow(AppColors.primaryNavy, 'Paid: ${_kFinance.totalPaid}'),
          const SizedBox(height: 6),
          _buildLegendRow(AppColors.border, 'Remaining: ${_kFinance.outstanding}'),
        ],
      ),
    );
  }

  Widget _buildLegendRow(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.borderDark),
          ),
        ),
        const SizedBox(width: 8),
        Text(label, style: AppTextStyles.body),
      ],
    );
  }

  // ── Payment history ────────────────────────────────────────────────────────

  Widget _buildPaymentHistory(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Payment History',
                style: AppTextStyles.h2.copyWith(color: AppColors.primaryNavy)),
            GestureDetector(
              onTap: () {},
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('View All', style: AppTextStyles.link),
                  const Icon(Icons.arrow_forward, color: AppColors.primaryBlue, size: 16),
                ],
              ),
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
            children: [
              _buildTableHeader(),
              const Divider(color: AppColors.border, height: 1),
              ..._kInvoices.asMap().entries.map((e) {
                final isLast = e.key == _kInvoices.length - 1;
                return Column(
                  children: [
                    _buildInvoiceRow(e.value, context),
                    if (!isLast) const Divider(color: AppColors.divider, height: 1),
                  ],
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTableHeader() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: ['INVOICE NO', 'SEMESTER', 'DATE']
            .map((h) => Expanded(
                  child: Text(h, style: AppTextStyles.label),
                ))
            .toList(),
      ),
    );
  }

  Widget _buildInvoiceRow(dynamic inv, BuildContext context) {
    return GestureDetector(
      onTap: () => context.go('/student/finance/invoice/${inv.no}'),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Expanded(
              child: Text(inv.no as String,
                  style: AppTextStyles.bodySemiBold.copyWith(
                      color: AppColors.primaryBlue, fontSize: 13)),
            ),
            Expanded(child: Text(inv.semester as String, style: AppTextStyles.body)),
            Expanded(child: Text(inv.date as String, style: AppTextStyles.caption)),
          ],
        ),
      ),
    );
  }
}

// ── Summary card ───────────────────────────────────────────────────────────────

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.label,
    required this.value,
    required this.sub,
    required this.icon,
    required this.iconColor,
    required this.valueColor,
  });

  final String label, value, sub;
  final IconData icon;
  final Color iconColor, valueColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTextStyles.label),
                const SizedBox(height: 6),
                Text(value,
                    style: AppTextStyles.metric.copyWith(
                        color: valueColor, fontSize: 24)),
                const SizedBox(height: 4),
                Text(sub, style: AppTextStyles.caption),
              ],
            ),
          ),
          Icon(icon, color: iconColor, size: 26),
        ],
      ),
    );
  }
}
