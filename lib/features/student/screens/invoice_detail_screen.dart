import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';

class InvoiceDetailScreen extends StatelessWidget {
  const InvoiceDetailScreen({super.key, required this.invoiceId});
  final String invoiceId;

  @override
  Widget build(BuildContext context) {
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
        title: Text('Invoice Detail', style: AppTextStyles.h3),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          children: [
            _buildInvoiceHeader(),
            const SizedBox(height: AppSpacing.sectionGap),
            _buildLineItems(),
            const SizedBox(height: AppSpacing.sectionGap),
            _buildTotal(),
          ],
        ),
      ),
    );
  }

  Widget _buildInvoiceHeader() {
    return Container(
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
              Text('INVOICE', style: AppTextStyles.label.copyWith(color: Colors.white70)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.statusGreenBg,
                  borderRadius: BorderRadius.circular(AppSpacing.chipRadius),
                ),
                child: Text('PAID',
                    style: AppTextStyles.label.copyWith(color: AppColors.statusGreen)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(invoiceId, style: AppTextStyles.h2White),
          const SizedBox(height: 4),
          Text('Fall Semester 2023', style: AppTextStyles.captionWhite),
          Text('Issued: Sep 05, 2023', style: AppTextStyles.captionWhite),
        ],
      ),
    );
  }

  Widget _buildLineItems() {
    final items = [
      (name: 'Tuition Fee', amount: '\$2,800.00'),
      (name: 'Lab & Technology Fee', amount: '\$250.00'),
      (name: 'Student Activity Fee', amount: '\$100.00'),
      (name: 'Library Fee', amount: '\$50.00'),
    ];

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
          Text('Breakdown', style: AppTextStyles.h3),
          const SizedBox(height: 12),
          ...items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(item.name, style: AppTextStyles.body),
                    Text(item.amount, style: AppTextStyles.bodyMedium),
                  ],
                ),
              )),
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
          Text('Total', style: AppTextStyles.h2),
          Text('\$3,200.00',
              style: AppTextStyles.metric.copyWith(
                  color: AppColors.primaryNavy, fontSize: 24)),
        ],
      ),
    );
  }
}
