import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/providers/student_providers.dart';
import '../../../core/supabase/database.types.dart';
import '../../../l10n/app_localizations.dart';

class InvoiceDetailScreen extends ConsumerWidget {
  const InvoiceDetailScreen({super.key, required this.invoiceId});
  final String invoiceId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final asyncFinance = ref.watch(studentFinanceProvider);

    return Scaffold(
      backgroundColor: AppColors.bgPage,
      appBar: AppBar(
        backgroundColor: AppColors.bgPage,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 18),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(l.invoiceDetailTitle, style: AppTextStyles.h3),
      ),
      body: asyncFinance.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(l.invoiceLoadError(e),
                style: AppTextStyles.body, textAlign: TextAlign.center),
          ),
        ),
        data: (finance) {
          final invoice =
              finance.invoices.where((i) => i.id == invoiceId).firstOrNull;
          if (invoice == null) {
            return Center(child: Text(l.invoiceNotFound));
          }
          return _InvoiceBody(invoice: invoice, l: l);
        },
      ),
    );
  }
}

// ── Body ──────────────────────────────────────────────────────────────────────

class _InvoiceBody extends StatelessWidget {
  const _InvoiceBody({required this.invoice, required this.l});
  final InvoiceRow invoice;
  final AppLocalizations l;

  String _fmtDate(String iso) {
    try {
      return DateFormat('MMM dd, yyyy').format(DateTime.parse(iso));
    } catch (_) {
      return iso;
    }
  }

  String _fmtDateTime(DateTime dt) =>
      DateFormat('MMM dd, yyyy').format(dt);

  String get _shortId {
    final raw = invoice.id.replaceAll('-', '').toUpperCase();
    return raw.length > 8 ? raw.substring(0, 8) : raw;
  }

  String get _statusLabel => switch (invoice.status) {
        InvoiceStatus.paid    => l.invoiceStatusPaid,
        InvoiceStatus.overdue => l.invoiceStatusOverdue,
        InvoiceStatus.partial => l.invoiceStatusPartial,
        InvoiceStatus.unpaid  => l.invoiceStatusUnpaid,
      };

  Color get _statusColor => switch (invoice.status) {
        InvoiceStatus.paid    => AppColors.statusGreen,
        InvoiceStatus.overdue => AppColors.statusRed,
        InvoiceStatus.partial => AppColors.statusAmber,
        InvoiceStatus.unpaid  => AppColors.statusAmber,
      };

  Color get _statusBg => switch (invoice.status) {
        InvoiceStatus.paid    => AppColors.statusGreenBg,
        InvoiceStatus.overdue => AppColors.statusRedBg,
        InvoiceStatus.partial => AppColors.statusAmberBg,
        InvoiceStatus.unpaid  => AppColors.statusAmberBg,
      };

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      child: Column(
        children: [
          _buildHeader(),
          const SizedBox(height: AppSpacing.sectionGap),
          _buildDetails(),
          const SizedBox(height: AppSpacing.sectionGap),
          _buildTotal(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.primaryNavy,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(l.invoiceLabelBadge,
                  style:
                      AppTextStyles.label.copyWith(color: Colors.white70)),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _statusBg,
                  borderRadius:
                      BorderRadius.circular(AppSpacing.chipRadius),
                ),
                child: Text(_statusLabel,
                    style: AppTextStyles.label
                        .copyWith(color: _statusColor)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(l.invoiceNumberLabel(_shortId), style: AppTextStyles.h2White),
          const SizedBox(height: 4),
          Text(invoice.description, style: AppTextStyles.captionWhite),
          Text(l.invoiceDueLabel(_fmtDate(invoice.dueDate)),
              style: AppTextStyles.captionWhite),
        ],
      ),
    );
  }

  Widget _buildDetails() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l.invoicePaymentDetailsTitle, style: AppTextStyles.h3),
          const SizedBox(height: 12),
          _row(l.invoiceDescriptionRowLabel, invoice.description),
          Divider(color: AppColors.divider, height: 20),
          _row(l.invoiceDueDateRowLabel, _fmtDate(invoice.dueDate)),
          if (invoice.paidAt != null) ...[
            Divider(color: AppColors.divider, height: 20),
            _row(l.invoicePaidOnRowLabel, _fmtDateTime(invoice.paidAt!)),
          ],
          if (invoice.status == InvoiceStatus.overdue) ...[
            Divider(color: AppColors.divider, height: 20),
            Row(
              children: [
                Icon(Icons.warning_amber_outlined,
                    color: AppColors.statusRed, size: 16),
                const SizedBox(width: 6),
                Text(l.invoicePastDueWarning,
                    style: AppTextStyles.body
                        .copyWith(color: AppColors.statusRed)),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTotal() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(l.invoiceTotalAmountLabel, style: AppTextStyles.h2),
          Text(
            '\$${invoice.amount.toStringAsFixed(2)}',
            style: AppTextStyles.metric
                .copyWith(color: AppColors.primaryNavy, fontSize: 24),
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style:
                AppTextStyles.body.copyWith(color: AppColors.textSecondary)),
        const SizedBox(width: 12),
        Flexible(
          child: Text(value,
              style: AppTextStyles.bodyMedium, textAlign: TextAlign.end),
        ),
      ],
    );
  }
}
