import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/providers/student_providers.dart';
import '../../../l10n/app_localizations.dart';

const _kMethodIcons = [
  Icons.account_balance_outlined,
  Icons.phone_android_outlined,
  Icons.qr_code_outlined,
];

List<String> _methodNames(AppLocalizations l) => [
      l.paymentMethodAbaBank,
      l.paymentMethodWing,
      l.paymentMethodPiPay,
    ];

// ── Screen ────────────────────────────────────────────────────────────────────

class OnlinePaymentScreen extends ConsumerStatefulWidget {
  const OnlinePaymentScreen({super.key});

  @override
  ConsumerState<OnlinePaymentScreen> createState() =>
      _OnlinePaymentScreenState();
}

class _OnlinePaymentScreenState extends ConsumerState<OnlinePaymentScreen> {
  int _methodIndex = 0;
  final _amountController = TextEditingController();
  bool _amountInitialized = false;
  bool _processing = false;
  bool _succeeded = false;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _initAmount(double outstanding) {
    if (_amountInitialized) return;
    _amountInitialized = true;
    _amountController.text = outstanding.toStringAsFixed(2);
  }

  String _receiptNumber(String studentCode) {
    final hash = studentCode.hashCode.abs() % 100000;
    return 'RCP-${DateTime.now().year}-${hash.toString().padLeft(5, '0')}';
  }

  // ── Actions ────────────────────────────────────────────────────────────────

  void _confirmPayment(
      String studentName, String studentCode, AppLocalizations l) {
    final amount = _amountController.text.trim();
    if (amount.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l.paymentAmountRequired,
              style: AppTextStyles.body.copyWith(color: Colors.white)),
          backgroundColor: AppColors.statusRed,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }
    showDialog(
      context: context,
      builder: (_) => _ConfirmDialog(
        method: _methodNames(l)[_methodIndex],
        amount: amount,
        onConfirm: _processPayment,
        l: l,
      ),
    );
  }

  Future<void> _processPayment() async {
    Navigator.of(context).pop();
    setState(() => _processing = true);
    await Future.delayed(const Duration(milliseconds: 1800));
    if (mounted) {
      setState(() {
        _processing = false;
        _succeeded = true;
      });
    }
  }

  // ── build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final profileAsync = ref.watch(studentProfileProvider);
    final financeAsync = ref.watch(studentFinanceProvider);

    final profile = profileAsync.valueOrNull;
    final finance = financeAsync.valueOrNull;

    if (finance != null) _initAmount(finance.outstanding);

    final studentName = profile?.fullName.toUpperCase() ?? '—';
    final studentCode = profile?.studentCode ?? '—';
    final outstanding = finance?.outstanding ?? 0.0;

    if (_succeeded) {
      return _buildSuccessScreen(studentName, studentCode, l);
    }
    if (_processing) return _buildProcessingScreen(l);

    return Scaffold(
      backgroundColor: AppColors.bgPage,
      appBar: _buildAppBar(l),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildOutstandingBanner(outstanding, l),
            const SizedBox(height: AppSpacing.sectionGap),
            _buildPaymentMethodSelector(l),
            const SizedBox(height: AppSpacing.sectionGap),
            _buildAmountField(l),
            const SizedBox(height: AppSpacing.sectionGap),
            _buildOrderSummaryCard(studentName, studentCode, l),
            const SizedBox(height: AppSpacing.xl),
            _buildPayButton(studentName, studentCode, l),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // ── App bar ────────────────────────────────────────────────────────────────

  PreferredSizeWidget _buildAppBar(AppLocalizations l) {
    return AppBar(
      backgroundColor: AppColors.bgPage,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, size: 18),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Text(l.paymentAppBarTitle, style: AppTextStyles.h3),
    );
  }

  // ── Outstanding balance banner ─────────────────────────────────────────────

  Widget _buildOutstandingBanner(double outstanding, AppLocalizations l) {
    final isZero = outstanding <= 0;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: isZero
            ? AppColors.statusGreenBg
            : AppColors.statusRedBg,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(
          color: isZero
              ? AppColors.statusGreen.withValues(alpha: 0.3)
              : AppColors.statusRed.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            isZero
                ? Icons.check_circle_outline
                : Icons.warning_amber_outlined,
            color: isZero
                ? AppColors.statusGreen
                : AppColors.statusRed,
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isZero
                    ? l.paymentNoOutstandingBalance
                    : l.paymentOutstandingBalance,
                style: AppTextStyles.h3.copyWith(
                    color: isZero
                        ? AppColors.statusGreen
                        : AppColors.statusRed),
              ),
              if (!isZero)
                Text(
                  '\$${outstanding.toStringAsFixed(2)}',
                  style: AppTextStyles.metric.copyWith(
                      color: AppColors.statusRed, fontSize: 22),
                ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Payment method selector ────────────────────────────────────────────────

  Widget _buildPaymentMethodSelector(AppLocalizations l) {
    final methodNames = _methodNames(l);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l.paymentMethodSectionLabel, style: AppTextStyles.label),
        const SizedBox(height: 8),
        Row(
          children: List.generate(_kMethodIcons.length, (i) {
            final isSelected = _methodIndex == i;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                    right: i < _kMethodIcons.length - 1 ? 8 : 0),
                child: GestureDetector(
                  onTap: () => setState(() => _methodIndex = i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding:
                        const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primaryNavy
                          : AppColors.bgCard,
                      borderRadius: BorderRadius.circular(
                          AppSpacing.cardRadius),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primaryNavy
                            : AppColors.border,
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(_kMethodIcons[i],
                            color: isSelected
                                ? Colors.white
                                : AppColors.textSecondary,
                            size: 20),
                        const SizedBox(height: 4),
                        Text(
                          methodNames[i],
                          textAlign: TextAlign.center,
                          style: AppTextStyles.caption.copyWith(
                            color: isSelected
                                ? Colors.white
                                : AppColors.textSecondary,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  // ── Amount field ───────────────────────────────────────────────────────────

  Widget _buildAmountField(AppLocalizations l) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l.paymentAmountSectionLabel, style: AppTextStyles.label),
        const SizedBox(height: 8),
        TextField(
          controller: _amountController,
          keyboardType:
              const TextInputType.numberWithOptions(decimal: true),
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.attach_money,
                color: AppColors.textLabel),
            hintText: '0.00',
          ),
        ),
      ],
    );
  }

  // ── Order summary ──────────────────────────────────────────────────────────

  Widget _buildOrderSummaryCard(
      String studentName, String studentCode, AppLocalizations l) {
    final amount = _amountController.text.trim().isEmpty
        ? '0.00'
        : _amountController.text.trim();
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
          Text(l.paymentOrderSummaryLabel, style: AppTextStyles.label),
          const SizedBox(height: 12),
          _buildSummaryRow(l.paymentStudentLabel, studentName),
          Divider(color: AppColors.divider, height: 16),
          _buildSummaryRow(l.paymentStudentIdLabel, studentCode),
          Divider(color: AppColors.divider, height: 16),
          _buildSummaryRow(
              l.paymentMethodLabel, _methodNames(l)[_methodIndex]),
          Divider(color: AppColors.divider, height: 16),
          _buildSummaryRow(l.paymentAmountLabel, '\$$amount',
              valueStyle: AppTextStyles.metric
                  .copyWith(color: AppColors.primaryNavy, fontSize: 18)),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value,
      {TextStyle? valueStyle}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: AppTextStyles.body
                .copyWith(color: AppColors.textSecondary)),
        Text(value, style: valueStyle ?? AppTextStyles.bodyMedium),
      ],
    );
  }

  // ── Pay button ─────────────────────────────────────────────────────────────

  Widget _buildPayButton(
      String studentName, String studentCode, AppLocalizations l) {
    return SizedBox(
      width: double.infinity,
      height: AppSpacing.buttonHeight,
      child: ElevatedButton.icon(
        onPressed: () => _confirmPayment(studentName, studentCode, l),
        icon: const Icon(Icons.lock_outline, size: 18),
        label: Text(l.paymentProceedButton, style: AppTextStyles.button),
      ),
    );
  }

  // ── Processing screen ──────────────────────────────────────────────────────

  Widget _buildProcessingScreen(AppLocalizations l) {
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 64,
                height: 64,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  color: AppColors.primaryNavy,
                ),
              ),
              const SizedBox(height: 24),
              Text(l.paymentProcessingTitle, style: AppTextStyles.h2),
              const SizedBox(height: 8),
              Text(
                l.paymentProcessingSubtitle,
                style: AppTextStyles.body
                    .copyWith(color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Success screen ─────────────────────────────────────────────────────────

  Widget _buildSuccessScreen(
      String studentName, String studentCode, AppLocalizations l) {
    final amount = _amountController.text.trim().isEmpty
        ? '0.00'
        : _amountController.text.trim();
    final receiptNo = _receiptNumber(studentCode);
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.statusGreenBg,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.check_circle_outline,
                    color: AppColors.statusGreen, size: 44),
              ),
              const SizedBox(height: 24),
              Text(l.paymentSuccessTitle,
                  style: AppTextStyles.h1, textAlign: TextAlign.center),
              const SizedBox(height: 8),
              Text(
                l.paymentSuccessSubtitle,
                style: AppTextStyles.body.copyWith(
                    color: AppColors.textSecondary, height: 1.5),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),
              _buildReceiptCard(
                  amount, studentName, studentCode, receiptNo, l),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: AppSpacing.buttonHeight,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(l.paymentBackToFinanceButton,
                      style: AppTextStyles.button),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReceiptCard(String amount, String studentName,
      String studentCode, String receiptNo, AppLocalizations l) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          _buildReceiptRow(l.paymentReceiptNumberLabel, receiptNo,
              valueColor: AppColors.primaryBlue),
          Divider(color: AppColors.divider, height: 20),
          _buildReceiptRow(l.paymentStudentLabel, studentName),
          Divider(color: AppColors.divider, height: 20),
          _buildReceiptRow(
              l.paymentMethodLabel, _methodNames(l)[_methodIndex]),
          Divider(color: AppColors.divider, height: 20),
          _buildReceiptRow(l.paymentAmountPaidLabel, '\$$amount',
              valueColor: AppColors.statusGreen),
          Divider(color: AppColors.divider, height: 20),
          _buildReceiptRow(l.paymentStatusLabel, l.paymentStatusPaidValue,
              valueColor: AppColors.statusGreen),
        ],
      ),
    );
  }

  Widget _buildReceiptRow(String label, String value,
      {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: AppTextStyles.body
                .copyWith(color: AppColors.textSecondary)),
        Text(
          value,
          style: AppTextStyles.bodyMedium.copyWith(color: valueColor),
        ),
      ],
    );
  }
}

// ── Confirmation dialog ────────────────────────────────────────────────────────

class _ConfirmDialog extends StatelessWidget {
  const _ConfirmDialog({
    required this.method,
    required this.amount,
    required this.onConfirm,
    required this.l,
  });

  final String method;
  final String amount;
  final VoidCallback onConfirm;
  final AppLocalizations l;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.bgCard,
      shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(AppSpacing.cardRadius + 4)),
      title: Text(l.paymentConfirmDialogTitle, style: AppTextStyles.h2),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l.paymentConfirmDialogBody,
            style: AppTextStyles.body
                .copyWith(color: AppColors.textSecondary, height: 1.5),
          ),
          const SizedBox(height: 16),
          _DialogRow(l.paymentMethodLabel, method),
          const SizedBox(height: 8),
          _DialogRow(l.paymentAmountLabel, '\$$amount', bold: true),
        ],
      ),
      actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      actions: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: onConfirm,
            child: Text(l.paymentConfirmButton, style: AppTextStyles.button),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l.cancel,
                style: AppTextStyles.button
                    .copyWith(color: AppColors.textSecondary)),
          ),
        ),
      ],
    );
  }
}

class _DialogRow extends StatelessWidget {
  const _DialogRow(this.label, this.value, {this.bold = false});
  final String label;
  final String value;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: AppTextStyles.body
                .copyWith(color: AppColors.textSecondary)),
        Text(value,
            style: AppTextStyles.bodyMedium.copyWith(
                color: bold ? AppColors.primaryNavy : AppColors.textPrimary,
                fontWeight:
                    bold ? FontWeight.w700 : FontWeight.w600,
                fontSize: bold ? 16 : null)),
      ],
    );
  }
}
