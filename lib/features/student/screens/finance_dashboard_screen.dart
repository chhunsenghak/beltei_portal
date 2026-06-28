import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/providers/student_providers.dart';
import '../../../core/services/student_service.dart';
import '../../../core/supabase/database.types.dart';

// ── Helpers ───────────────────────────────────────────────────────────────────

final _currencyFmt =
    NumberFormat.currency(symbol: '\$', decimalDigits: 2);

String _fmtDate(String iso) {
  try {
    return DateFormat('MMM dd, yyyy').format(DateTime.parse(iso));
  } catch (_) {
    return iso;
  }
}

// ── Screen ────────────────────────────────────────────────────────────────────

class FinanceDashboardScreen extends ConsumerWidget {
  const FinanceDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final financeAsync = ref.watch(studentFinanceProvider);

    return Scaffold(
      backgroundColor: AppColors.bgPage,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/student/finance/payment'),
        backgroundColor: AppColors.primaryBlue,
        icon: const Icon(Icons.payment, color: Colors.white),
        label: Text('PAY NOW',
            style: AppTextStyles.button.copyWith(fontSize: 13)),
      ),
      body: financeAsync.when(
        loading: () =>
            const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline,
                  color: AppColors.statusRed, size: 40),
              const SizedBox(height: 8),
              Text('Could not load finance data',
                  style: AppTextStyles.bodyMedium),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () =>
                    ref.invalidate(studentFinanceProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (fin) => SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTitle(),
              const SizedBox(height: AppSpacing.md),
              _buildSummaryCards(fin),
              const SizedBox(height: AppSpacing.sectionGap),
              _buildPaymentProgressCard(fin),
              const SizedBox(height: AppSpacing.sectionGap),
              _buildPaymentHistory(context, fin.invoices),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Finance Overview', style: AppTextStyles.h1),
        const SizedBox(height: 4),
        Text(
          'Manage your tuition fees and payment history.',
          style: AppTextStyles.caption.copyWith(height: 1.4),
        ),
      ],
    );
  }

  Widget _buildSummaryCards(FinanceSummary fin) {
    final paidPct = fin.totalFees > 0
        ? (fin.paidPercent * 100).toStringAsFixed(1)
        : '0.0';
    final dueDateLabel = fin.nextDueName ?? 'No pending fees';

    final items = [
      (
        label: 'TOTAL FEE',
        value: _currencyFmt.format(fin.totalFees),
        sub: 'Total across all invoices',
        icon: Icons.receipt_outlined,
        iconColor: AppColors.primaryNavy,
        valueColor: AppColors.textPrimary,
      ),
      (
        label: 'TOTAL PAID',
        value: _currencyFmt.format(fin.totalPaid),
        sub: '$paidPct% of total completed',
        icon: Icons.check_circle_outline,
        iconColor: AppColors.statusGreen,
        valueColor: AppColors.statusGreen,
      ),
      (
        label: 'OUTSTANDING',
        value: _currencyFmt.format(fin.outstanding),
        sub: fin.outstanding > 0
            ? 'Action required'
            : 'All fees cleared',
        icon: Icons.warning_amber_outlined,
        iconColor: fin.outstanding > 0
            ? AppColors.statusRed
            : AppColors.statusGreen,
        valueColor: fin.outstanding > 0
            ? AppColors.statusRed
            : AppColors.statusGreen,
      ),
      (
        label: 'NEXT DUE DATE',
        value: fin.nextDueDate != null
            ? _fmtDate(fin.nextDueDate!)
            : '—',
        sub: dueDateLabel,
        icon: Icons.event_outlined,
        iconColor: AppColors.statusAmber,
        valueColor: AppColors.statusAmber,
      ),
    ];

    return Column(
      children: items
          .map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _SummaryCard(
                  label: item.label,
                  value: item.value,
                  sub: item.sub,
                  icon: item.icon,
                  iconColor: item.iconColor,
                  valueColor: item.valueColor,
                ),
              ))
          .toList(),
    );
  }

  Widget _buildPaymentProgressCard(FinanceSummary fin) {
    final statusColor = switch (fin.status) {
      'PAID' => AppColors.statusGreen,
      'OVERDUE' => AppColors.statusRed,
      _ => AppColors.primaryNavy,
    };

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
          Text('Payment Progress',
              style: AppTextStyles.h2
                  .copyWith(color: AppColors.primaryNavy)),
          const SizedBox(height: 14),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.15),
                  borderRadius:
                      BorderRadius.circular(AppSpacing.chipRadius),
                ),
                child: Text(fin.status,
                    style: AppTextStyles.label
                        .copyWith(color: statusColor)),
              ),
              const Spacer(),
              Text(
                '${(fin.paidPercent * 100).round()}%',
                style: AppTextStyles.bodySemiBold
                    .copyWith(color: AppColors.primaryNavy),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: fin.paidPercent,
              minHeight: 10,
              backgroundColor: AppColors.border,
              valueColor: const AlwaysStoppedAnimation<Color>(
                  AppColors.primaryNavy),
            ),
          ),
          const SizedBox(height: 12),
          _legendRow(AppColors.primaryNavy,
              'Paid: ${_currencyFmt.format(fin.totalPaid)}'),
          const SizedBox(height: 6),
          _legendRow(AppColors.border,
              'Remaining: ${_currencyFmt.format(fin.outstanding)}'),
        ],
      ),
    );
  }

  Widget _legendRow(Color color, String label) {
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

  Widget _buildPaymentHistory(
      BuildContext context, List<InvoiceRow> invoices) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Payment History',
                style: AppTextStyles.h2
                    .copyWith(color: AppColors.primaryNavy)),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: AppColors.bgCard,
            borderRadius:
                BorderRadius.circular(AppSpacing.cardRadius),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: [
              _buildTableHeader(),
              const Divider(color: AppColors.border, height: 1),
              if (invoices.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(24),
                  child:
                      Center(child: Text('No invoices found.')),
                )
              else
                ...invoices.asMap().entries.map((e) {
                  final isLast = e.key == invoices.length - 1;
                  return Column(
                    children: [
                      _buildInvoiceRow(context, e.value),
                      if (!isLast)
                        const Divider(
                            color: AppColors.divider, height: 1),
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
        children: ['DESCRIPTION', 'DUE DATE', 'STATUS']
            .map((h) => Expanded(
                  child: Text(h, style: AppTextStyles.label),
                ))
            .toList(),
      ),
    );
  }

  Widget _buildInvoiceRow(BuildContext context, InvoiceRow inv) {
    final statusColor = switch (inv.status) {
      InvoiceStatus.paid => AppColors.statusGreen,
      InvoiceStatus.overdue => AppColors.statusRed,
      InvoiceStatus.partial => AppColors.statusAmber,
      InvoiceStatus.unpaid => AppColors.statusAmber,
    };
    final statusLabel = switch (inv.status) {
      InvoiceStatus.paid => 'Paid',
      InvoiceStatus.overdue => 'Overdue',
      InvoiceStatus.partial => 'Partial',
      InvoiceStatus.unpaid => 'Unpaid',
    };

    return GestureDetector(
      onTap: () => context.go('/student/finance/invoice/${inv.id}'),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Expanded(
              child: Text(
                inv.description,
                style: AppTextStyles.bodySemiBold
                    .copyWith(color: AppColors.primaryBlue, fontSize: 13),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Expanded(
                child: Text(_fmtDate(inv.dueDate),
                    style: AppTextStyles.caption)),
            Expanded(
              child: Text(
                statusLabel,
                style: AppTextStyles.caption.copyWith(
                    color: statusColor, fontWeight: FontWeight.w600),
              ),
            ),
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
