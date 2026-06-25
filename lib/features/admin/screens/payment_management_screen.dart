import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';

final _kPaymentRecords = [
  (initials: 'RK', name: 'Rith Kosal',    semester: 'Sem 1, 2024', amount: '\$2,000.00', status: 'paid'),
  (initials: 'PS', name: 'Phally Sok',     semester: 'Sem 1, 2024', amount: '\$2,000.00', status: 'paid'),
  (initials: 'VM', name: 'Vannary Mean',   semester: 'Sem 1, 2024', amount: '\$1,500.00', status: 'partial'),
  (initials: 'CN', name: 'Chann Nimol',    semester: 'Sem 1, 2024', amount: '\$2,000.00', status: 'paid'),
  (initials: 'SK', name: 'Sok Khema',      semester: 'Sem 1, 2024', amount: '\$2,000.00', status: 'overdue'),
  (initials: 'RP', name: 'Rath Piseth',    semester: 'Sem 1, 2024', amount: '\$2,000.00', status: 'paid'),
];

final _kTuitionPlans = [
  (name: 'Semester 1, 2024', deadline: 'Sep 15, 2024', pct: 0.85, status: 'active'),
  (name: 'Semester 2, 2024', deadline: 'Feb 15, 2025', pct: 0.11, status: 'upcoming'),
];

class PaymentManagementScreen extends StatefulWidget {
  const PaymentManagementScreen({super.key});

  @override
  State<PaymentManagementScreen> createState() => _PaymentManagementScreenState();
}

class _PaymentManagementScreenState extends State<PaymentManagementScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        children: [
          _buildSummaryCards(),
          const SizedBox(height: 20),
          _buildTuitionPlans(),
          const SizedBox(height: 16),
          _buildActionButtons(),
          const SizedBox(height: 20),
          Text('Payment Records', style: AppTextStyles.h2),
          const SizedBox(height: 10),
          _buildSearchBar(),
          const SizedBox(height: 10),
          _buildPaymentList(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSummaryCards() {
    final cards = [
      (label: 'BILLED TO', value: '\$1,284,500', sub: '+12.5% this month', icon: Icons.receipt_long_outlined, color: AppColors.primaryNavy, positive: true),
      (label: 'COLLECTED', value: '\$945,200', sub: '73.5% of total', icon: Icons.check_circle_outline, color: AppColors.statusGreen, positive: true),
      (label: 'OUTSTANDING', value: '\$26,500', sub: 'Immediate action required', icon: Icons.warning_amber_outlined, color: AppColors.statusRed, positive: false),
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
                      Text(c.label, style: AppTextStyles.label.copyWith(fontSize: 9)),
                      Text(c.value,
                          style: AppTextStyles.metric.copyWith(
                              color: c.color, fontSize: 22)),
                      Text(c.sub,
                          style: AppTextStyles.caption.copyWith(
                              color: c.positive
                                  ? AppColors.statusGreen
                                  : AppColors.statusRed,
                              fontSize: 11)),
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

  Widget _buildTuitionPlans() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Tuition Plans', style: AppTextStyles.h2),
            TextButton(onPressed: () {}, child: Text('View All', style: AppTextStyles.link)),
          ],
        ),
        const SizedBox(height: 10),
        ..._kTuitionPlans.map((plan) {
          final isActive = plan.status == 'active';
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
                      Text(plan.name, style: AppTextStyles.bodyMedium),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: isActive ? AppColors.statusGreenBg : AppColors.statusAmberBg,
                          borderRadius: BorderRadius.circular(AppSpacing.tagRadius),
                        ),
                        child: Text(
                          isActive ? 'Active' : 'Upcoming',
                          style: AppTextStyles.label.copyWith(
                              color: isActive ? AppColors.statusGreen : AppColors.statusAmber,
                              letterSpacing: 0.3),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text('Deadline: ${plan.deadline}', style: AppTextStyles.caption),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${(plan.pct * 100).toInt()}% Paid',
                          style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w600)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: plan.pct,
                      minHeight: 6,
                      backgroundColor: AppColors.border,
                      valueColor: AlwaysStoppedAnimation<Color>(
                          isActive ? AppColors.statusGreen : AppColors.statusAmber),
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

  Widget _buildActionButtons() {
    return Column(
      children: [
        _ActionButton(
          icon: Icons.receipt_outlined,
          label: 'Generate Invoice',
          onTap: () {},
          style: _BtnStyle.outlined,
        ),
        const SizedBox(height: 8),
        _ActionButton(
          icon: Icons.verified_outlined,
          label: 'Verify Payment',
          onTap: () {},
          style: _BtnStyle.outlined,
        ),
        const SizedBox(height: 8),
        _ActionButton(
          icon: Icons.download_outlined,
          label: 'Export Financial Report',
          onTap: () {},
          style: _BtnStyle.outlined,
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: 'Search student or ID...',
        hintStyle: AppTextStyles.caption,
        prefixIcon: const Icon(Icons.search, color: AppColors.textLabel, size: 20),
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

  Widget _buildPaymentList() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: _kPaymentRecords.asMap().entries.map((e) {
          final isLast = e.key == _kPaymentRecords.length - 1;
          final r = e.value;
          Color statusColor;
          Color statusBg;
          switch (r.status) {
            case 'paid':    statusColor = AppColors.statusGreen; statusBg = AppColors.statusGreenBg; break;
            case 'partial': statusColor = AppColors.statusAmber; statusBg = AppColors.statusAmberBg; break;
            default:        statusColor = AppColors.statusRed;   statusBg = AppColors.statusRedBg;
          }
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: AppColors.primaryNavy.withValues(alpha: 0.1),
                      child: Text(r.initials,
                          style: AppTextStyles.label.copyWith(
                              color: AppColors.primaryNavy, letterSpacing: 0)),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(r.name, style: AppTextStyles.bodyMedium),
                          Text(r.semester, style: AppTextStyles.caption),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(r.amount, style: AppTextStyles.bodySemiBold),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: statusBg,
                            borderRadius: BorderRadius.circular(AppSpacing.tagRadius),
                          ),
                          child: Text(r.status,
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
              if (!isLast) const Divider(height: 1, color: AppColors.divider),
            ],
          );
        }).toList(),
      ),
    );
  }
}

enum _BtnStyle { outlined, filled }

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.style = _BtnStyle.outlined,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final _BtnStyle style;

  @override
  Widget build(BuildContext context) {
    final isFilled = style == _BtnStyle.filled;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 13),
        decoration: BoxDecoration(
          color: isFilled ? AppColors.primaryNavy : Colors.white,
          borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
          border: Border.all(
              color: isFilled ? AppColors.primaryNavy : AppColors.border),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                size: 18,
                color: isFilled ? Colors.white : AppColors.textSecondary),
            const SizedBox(width: 8),
            Text(label,
                style: AppTextStyles.body.copyWith(
                    color: isFilled ? Colors.white : AppColors.textPrimary,
                    fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}
