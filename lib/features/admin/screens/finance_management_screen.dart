import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import 'payment_management_screen.dart';
import 'university_analytics_screen.dart';
import 'institutional_reports_screen.dart';

class FinanceManagementScreen extends StatefulWidget {
  const FinanceManagementScreen({super.key});

  @override
  State<FinanceManagementScreen> createState() =>
      _FinanceManagementScreenState();
}

class _FinanceManagementScreenState extends State<FinanceManagementScreen> {
  int _selectedIndex = 0;

  static const _tabs = [
    (label: 'Payments',  icon: Icons.payments_outlined),
    (label: 'Analytics', icon: Icons.bar_chart_outlined),
    (label: 'Reports',   icon: Icons.description_outlined),
  ];

  static const _bodies = [
    PaymentManagementScreen(),
    UniversityAnalyticsScreen(),
    InstitutionalReportsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      body: Column(
        children: [
          _buildSecondaryNav(),
          Expanded(child: _bodies[_selectedIndex]),
        ],
      ),
    );
  }

  Widget _buildSecondaryNav() {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              itemCount: _tabs.length,
              itemBuilder: (context, i) {
                final isSelected = i == _selectedIndex;
                return GestureDetector(
                  onTap: () => setState(() => _selectedIndex = i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primaryNavy
                          : AppColors.bgPage,
                      borderRadius: BorderRadius.circular(AppSpacing.chipRadius),
                      border: Border.all(
                        color: isSelected ? AppColors.primaryNavy : AppColors.border,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(_tabs[i].icon,
                            size: 14,
                            color: isSelected ? Colors.white : AppColors.textSecondary),
                        const SizedBox(width: 5),
                        Text(
                          _tabs[i].label,
                          style: AppTextStyles.caption.copyWith(
                            color: isSelected ? Colors.white : AppColors.textSecondary,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const Divider(height: 1, color: AppColors.border),
        ],
      ),
    );
  }
}
