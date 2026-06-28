import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/providers/admin_providers.dart';

final _kReportModules = [
  (
    icon: Icons.fact_check_outlined,
    iconColor: AppColors.primaryBlue,
    iconBg: AppColors.statusBlueBg,
    title: 'Attendance Report',
    desc: 'Analyze student presence, tardiness, and trends across all areas.',
  ),
  (
    icon: Icons.grade_outlined,
    iconColor: AppColors.statusGreen,
    iconBg: AppColors.statusGreenBg,
    title: 'Grade Report',
    desc: 'GPA distributions, passing rates, and individual academic performance metrics.',
  ),
  (
    icon: Icons.account_balance_wallet_outlined,
    iconColor: AppColors.statusAmber,
    iconBg: AppColors.statusAmberBg,
    title: 'Revenue Report',
    desc: 'Tuition fee collection status, outstanding balances, and monthly financial summaries.',
  ),
  (
    icon: Icons.how_to_reg_outlined,
    iconColor: Color(0xFF7C3AED),
    iconBg: Color(0xFFEDE9FE),
    title: 'Enrollment Report',
    desc: 'Track course registrations, re-enrollment rates, and capacity per classroom.',
  ),
  (
    icon: Icons.people_outline,
    iconColor: AppColors.primaryNavy,
    iconBg: Color(0xFFE8EAF6),
    title: 'Faculty Report',
    desc: 'Teacher performance reviews, teaching hours log, and departmental distribution.',
  ),
];

class InstitutionalReportsScreen extends ConsumerStatefulWidget {
  const InstitutionalReportsScreen({super.key});

  @override
  ConsumerState<InstitutionalReportsScreen> createState() =>
      _InstitutionalReportsScreenState();
}

class _InstitutionalReportsScreenState
    extends ConsumerState<InstitutionalReportsScreen> {
  String _semester  = 'All Semesters';
  bool _viewMonthly = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        children: [
          Text('Institutional Reports',
              style: AppTextStyles.h1.copyWith(color: AppColors.primaryNavy)),
          const SizedBox(height: 4),
          Text('Access comprehensive data visualizations and administrative analytics '
              'for the current academic year.',
              style: AppTextStyles.caption),
          const SizedBox(height: 16),
          _buildFilters(),
          const SizedBox(height: 16),
          _buildQuickExport(),
          const SizedBox(height: 20),
          Text('Report Modules', style: AppTextStyles.h2),
          const SizedBox(height: 12),
          ..._kReportModules.map((m) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _ReportModuleCard(module: m),
              )),
          const SizedBox(height: 16),
          _buildCustomDashboard(),
          const SizedBox(height: 16),
          _buildOverviewChart(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    final semesterItems = <String>[
      'All Semesters',
      ...ref.watch(adminSemestersProvider).valueOrNull?.map((s) => s.name) ?? <String>[],
    ];
    final semValue = semesterItems.contains(_semester) ? _semester : semesterItems.first;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _FilterDrop(
                  label: 'Date Range',
                  value: 'Jan 2024 - Dec 2024',
                  items: ['Jan 2024 - Dec 2024', 'Jan 2023 - Dec 2023'],
                  onChanged: (_) {},
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _FilterDrop(
            label: 'Semester',
            value: semValue,
            items: semesterItems,
            onChanged: (v) => setState(() => _semester = v!),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 46),
              backgroundColor: AppColors.primaryNavy,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.buttonRadius)),
            ),
            child: Text('Generate', style: AppTextStyles.button),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickExport() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Quick Export', style: AppTextStyles.h3),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _ExportButton(
                icon: Icons.picture_as_pdf_outlined,
                label: 'PDF Report',
                color: AppColors.statusRed,
                onTap: () {},
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _ExportButton(
                icon: Icons.table_chart_outlined,
                label: 'CSV Sheet',
                color: AppColors.statusGreen,
                onTap: () {},
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCustomDashboard() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.primaryNavy.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: AppColors.primaryNavy.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.dashboard_customize_outlined,
                color: AppColors.primaryNavy, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Custom Dashboard',
                    style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.primaryNavy)),
                Text('Create a bespoke report view',
                    style: AppTextStyles.caption),
              ],
            ),
          ),
          const Icon(Icons.chevron_right,
              color: AppColors.primaryNavy, size: 20),
        ],
      ),
    );
  }

  Widget _buildOverviewChart() {
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Overview Trend: Academic Performance',
                      style: AppTextStyles.h3),
                  Text('Aggregated data across all campuses for the last 6 months.',
                      style: AppTextStyles.caption),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _ToggleBtn(label: 'Monthly', isSelected: _viewMonthly,
                  onTap: () => setState(() => _viewMonthly = true)),
              const SizedBox(width: 4),
              _ToggleBtn(label: 'Yearly', isSelected: !_viewMonthly,
                  onTap: () => setState(() => _viewMonthly = false)),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 80,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(6, (i) {
                final heights = [0.6, 0.72, 0.65, 0.80, 0.75, 0.88];
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          height: heights[i] * 70,
                          decoration: BoxDecoration(
                            color: AppColors.primaryBlue.withValues(alpha: 0.6),
                            borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(3)),
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'][i],
                            style: AppTextStyles.label.copyWith(fontSize: 8)),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterDrop extends StatelessWidget {
  const _FilterDrop({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final String label;
  final String value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
        const SizedBox(height: 4),
        Container(
          decoration: BoxDecoration(
            color: AppColors.bgInput,
            borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
            border: Border.all(color: AppColors.border),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
              items: items.map((e) =>
                  DropdownMenuItem(value: e, child: Text(e, style: AppTextStyles.caption))).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}

class _ExportButton extends StatelessWidget {
  const _ExportButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 6),
            Text(label,
                style: AppTextStyles.caption.copyWith(
                    color: color, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

class _ReportModuleCard extends StatelessWidget {
  const _ReportModuleCard({required this.module});
  final dynamic module;

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
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: module.iconBg as Color,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(module.icon as IconData,
                color: module.iconColor as Color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(module.title as String, style: AppTextStyles.bodyMedium),
                Text(module.desc as String,
                    style: AppTextStyles.caption.copyWith(fontSize: 11),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () {},
            child: Text('View Analytics', style: AppTextStyles.link.copyWith(fontSize: 12)),
          ),
        ],
      ),
    );
  }
}

class _ToggleBtn extends StatelessWidget {
  const _ToggleBtn({required this.label, required this.isSelected, required this.onTap});
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryNavy : Colors.transparent,
          borderRadius: BorderRadius.circular(AppSpacing.chipRadius),
          border: Border.all(color: AppColors.border),
        ),
        child: Text(label,
            style: AppTextStyles.caption.copyWith(
                color: isSelected ? Colors.white : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal)),
      ),
    );
  }
}
