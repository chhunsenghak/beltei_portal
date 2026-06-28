import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/providers/admin_providers.dart';
import '../../../core/services/admin_service.dart';
import '../../../core/supabase/database.types.dart';

// ── Screen ────────────────────────────────────────────────────────────────────

class PaymentManagementScreen extends ConsumerStatefulWidget {
  const PaymentManagementScreen({super.key});

  @override
  ConsumerState<PaymentManagementScreen> createState() =>
      _PaymentManagementScreenState();
}

class _PaymentManagementScreenState
    extends ConsumerState<PaymentManagementScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final invoicesAsync = ref.watch(adminInvoicesProvider);

    return Scaffold(
      backgroundColor: AppColors.bgPage,
      body: invoicesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline,
                  color: AppColors.statusRed, size: 40),
              const SizedBox(height: 8),
              Text('Could not load payments', style: AppTextStyles.bodyMedium),
              TextButton(
                onPressed: () => ref.invalidate(adminInvoicesProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (invoices) {
          final totalBilled = invoices.fold<double>(
              0, (s, i) => s + i.amount);
          final collected = invoices
              .where((i) => i.status == InvoiceStatus.paid)
              .fold<double>(0, (s, i) => s + i.amount);
          final outstanding = invoices
              .where((i) => i.status == InvoiceStatus.overdue)
              .fold<double>(0, (s, i) => s + i.amount);

          final filtered = _searchQuery.isEmpty
              ? invoices
              : invoices
                  .where((i) =>
                      i.studentName
                          .toLowerCase()
                          .contains(_searchQuery) ||
                      i.studentCode
                          .toLowerCase()
                          .contains(_searchQuery))
                  .toList();

          // Group by semester for tuition plans
          final Map<String, _SemesterPlan> plans = {};
          for (final inv in invoices) {
            final key = inv.semesterName ?? 'Unknown';
            final plan = plans.putIfAbsent(key, () => _SemesterPlan(key));
            plan.total += inv.amount;
            if (inv.status == InvoiceStatus.paid) plan.paid += inv.amount;
          }
          final planList = plans.values.toList()
            ..sort((a, b) => b.total.compareTo(a.total));

          return ListView(
            padding: const EdgeInsets.all(AppSpacing.screenPadding),
            children: [
              _buildSummaryCards(totalBilled, collected, outstanding),
              const SizedBox(height: 20),
              _buildTuitionPlans(planList),
              const SizedBox(height: 16),
              _buildActionButtons(),
              const SizedBox(height: 20),
              Text('Payment Records', style: AppTextStyles.h2),
              const SizedBox(height: 10),
              _buildSearchBar(),
              const SizedBox(height: 10),
              _buildPaymentList(filtered),
              const SizedBox(height: 24),
            ],
          );
        },
      ),
    );
  }

  // ── Summary cards ──────────────────────────────────────────────────────────

  Widget _buildSummaryCards(
      double total, double collected, double outstanding) {
    final paidPct = total > 0 ? (collected / total * 100).round() : 0;
    final cards = [
      (
        label: 'BILLED TO',
        value: _fmtCurrency(total),
        sub: 'All invoices this period',
        icon: Icons.receipt_long_outlined,
        color: AppColors.primaryNavy,
      ),
      (
        label: 'COLLECTED',
        value: _fmtCurrency(collected),
        sub: '$paidPct% of total billed',
        icon: Icons.check_circle_outline,
        color: AppColors.statusGreen,
      ),
      (
        label: 'OUTSTANDING',
        value: _fmtCurrency(outstanding),
        sub: outstanding > 0 ? 'Immediate action required' : 'No overdue invoices',
        icon: Icons.warning_amber_outlined,
        color: outstanding > 0 ? AppColors.statusRed : AppColors.statusGray,
      ),
    ];

    return Column(
      children: cards.map((c) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.cardPadding),
            decoration: BoxDecoration(
              color: AppColors.bgCard,
              borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(
                    color: c.color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(c.icon, color: c.color, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(c.label,
                          style: AppTextStyles.label.copyWith(fontSize: 9)),
                      Text(c.value,
                          style: AppTextStyles.metric
                              .copyWith(color: c.color, fontSize: 22)),
                      Text(c.sub,
                          style: AppTextStyles.caption.copyWith(fontSize: 11)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  // ── Tuition plans ──────────────────────────────────────────────────────────

  Widget _buildTuitionPlans(List<_SemesterPlan> plans) {
    if (plans.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Tuition Plans', style: AppTextStyles.h2),
        const SizedBox(height: 10),
        ...plans.take(3).map((plan) {
          final pct = plan.total > 0 ? plan.paid / plan.total : 0.0;
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Container(
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
                      Expanded(
                        child: Text(plan.name,
                            style: AppTextStyles.bodyMedium,
                            overflow: TextOverflow.ellipsis),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: pct >= 0.7
                              ? AppColors.statusGreenBg
                              : AppColors.statusAmberBg,
                          borderRadius:
                              BorderRadius.circular(AppSpacing.tagRadius),
                        ),
                        child: Text(
                          pct >= 0.7 ? 'On Track' : 'Pending',
                          style: AppTextStyles.label.copyWith(
                              color: pct >= 0.7
                                  ? AppColors.statusGreen
                                  : AppColors.statusAmber,
                              letterSpacing: 0.3),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text('${_fmtCurrency(plan.paid)} collected of ${_fmtCurrency(plan.total)}',
                      style: AppTextStyles.caption),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${(pct * 100).round()}% Paid',
                          style: AppTextStyles.caption
                              .copyWith(fontWeight: FontWeight.w600)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: pct,
                      minHeight: 6,
                      backgroundColor: AppColors.border,
                      valueColor: AlwaysStoppedAnimation<Color>(
                          pct >= 0.7
                              ? AppColors.statusGreen
                              : AppColors.statusAmber),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  // ── Action buttons ─────────────────────────────────────────────────────────

  Widget _buildActionButtons() {
    return Column(
      children: [
        _ActionButton(
            icon: Icons.receipt_outlined,
            label: 'Generate Invoice',
            onTap: () {}),
        const SizedBox(height: 8),
        _ActionButton(
            icon: Icons.verified_outlined,
            label: 'Verify Payment',
            onTap: () {}),
        const SizedBox(height: 8),
        _ActionButton(
            icon: Icons.download_outlined,
            label: 'Export Financial Report',
            onTap: () {}),
      ],
    );
  }

  // ── Search bar ─────────────────────────────────────────────────────────────

  Widget _buildSearchBar() {
    return TextField(
      onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
      decoration: InputDecoration(
        hintText: 'Search student name or ID...',
        hintStyle: AppTextStyles.caption,
        prefixIcon:
            const Icon(Icons.search, color: AppColors.textLabel, size: 20),
        filled: true,
        fillColor: AppColors.bgInput,
        contentPadding: const EdgeInsets.symmetric(vertical: 10),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
          borderSide: const BorderSide(color: AppColors.primaryNavy),
        ),
      ),
    );
  }

  // ── Payment list ───────────────────────────────────────────────────────────

  Widget _buildPaymentList(List<AdminInvoiceRecord> records) {
    if (records.isEmpty) {
      return Center(
        child: Text('No records found',
            style: AppTextStyles.body
                .copyWith(color: AppColors.textSecondary)),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: records.asMap().entries.map((e) {
          final isLast = e.key == records.length - 1;
          final r = e.value;
          Color statusColor;
          Color statusBg;
          switch (r.status) {
            case InvoiceStatus.paid:
              statusColor = AppColors.statusGreen;
              statusBg = AppColors.statusGreenBg;
            case InvoiceStatus.partial:
              statusColor = AppColors.statusAmber;
              statusBg = AppColors.statusAmberBg;
            case InvoiceStatus.overdue:
              statusColor = AppColors.statusRed;
              statusBg = AppColors.statusRedBg;
            default:
              statusColor = AppColors.statusGray;
              statusBg = AppColors.statusGrayBg;
          }
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 12),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor:
                          AppColors.primaryNavy.withValues(alpha: 0.1),
                      child: Text(r.initials,
                          style: AppTextStyles.label.copyWith(
                              color: AppColors.primaryNavy,
                              letterSpacing: 0)),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(r.studentName,
                              style: AppTextStyles.bodyMedium),
                          Text(r.semesterName ?? r.studentCode,
                              style: AppTextStyles.caption),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(r.fmtAmount,
                            style: AppTextStyles.bodySemiBold),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: statusBg,
                            borderRadius: BorderRadius.circular(
                                AppSpacing.tagRadius),
                          ),
                          child: Text(r.statusLabel,
                              style: AppTextStyles.label.copyWith(
                                  color: statusColor,
                                  letterSpacing: 0.3,
                                  fontSize: 9)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (!isLast)
                const Divider(height: 1, color: AppColors.divider),
            ],
          );
        }).toList(),
      ),
    );
  }

  String _fmtCurrency(double amount) {
    if (amount >= 1000000) return '\$${(amount / 1000000).toStringAsFixed(1)}M';
    if (amount >= 1000) return '\$${(amount / 1000).toStringAsFixed(1)}K';
    return '\$${amount.toStringAsFixed(0)}';
  }
}

// ── Helper class ──────────────────────────────────────────────────────────────

class _SemesterPlan {
  final String name;
  double total = 0;
  double paid = 0;
  _SemesterPlan(this.name);
}

// ── Action button ─────────────────────────────────────────────────────────────

class _ActionButton extends StatelessWidget {
  const _ActionButton(
      {required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 13),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: AppColors.textSecondary),
            const SizedBox(width: 8),
            Text(label,
                style: AppTextStyles.body.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}
