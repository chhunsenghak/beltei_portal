import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';

final _kLeaveRequests = [
  (
    initials: 'JS', name: 'John Smith',
    program: 'Intl. Business Management • Year 3',
    type: 'Medical Leave', dateRange: 'Oct 12 - Oct 14, 2023',
    status: 'pending', statusLabel: 'Pending Review',
    quote: '"Requires surgery follow-up. Medical certificate attached."',
  ),
  (
    initials: 'VL', name: 'Vannak Ly',
    program: 'Computer Science • Year 2',
    type: 'Personal', dateRange: 'Oct 08 - Oct 09, 2023',
    status: 'approved', statusLabel: 'Approved',
    quote: '',
  ),
  (
    initials: 'SR', name: 'Serey Roth',
    program: 'Banking & Finance • Year 4',
    type: 'Sick Leave', dateRange: 'Oct 05, 2023',
    status: 'rejected', statusLabel: 'Rejected',
    quote: '',
  ),
  (
    initials: 'MD', name: 'Malai Dara',
    program: 'Architecture • Year 1',
    type: 'Family Event', dateRange: 'Oct 20 - Oct 25, 2023',
    status: 'pending', statusLabel: 'Pending Review',
    quote: '"Attending sister\'s wedding in rural province."',
  ),
];

class GlobalLeaveRequestsScreen extends StatefulWidget {
  const GlobalLeaveRequestsScreen({super.key});

  @override
  State<GlobalLeaveRequestsScreen> createState() =>
      _GlobalLeaveRequestsScreenState();
}

class _GlobalLeaveRequestsScreenState
    extends State<GlobalLeaveRequestsScreen> {
  String _filter = 'all';

  List<dynamic> get _filtered {
    if (_filter == 'all') return _kLeaveRequests;
    if (_filter == 'pending') {
      return _kLeaveRequests.where((r) => r.status == 'pending').toList();
    }
    return _kLeaveRequests.where((r) => r.status == 'approved').toList();
  }

  @override
  Widget build(BuildContext context) {
    final pendingCount =
        _kLeaveRequests.where((r) => r.status == 'pending').length;

    return Scaffold(
      backgroundColor: AppColors.bgPage,
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        children: [
          Text('Leave Management', style: AppTextStyles.h1.copyWith(color: AppColors.primaryNavy)),
          const SizedBox(height: 4),
          Text('Review and manage student absence requests across campuses.',
              style: AppTextStyles.caption),
          const SizedBox(height: 16),
          _buildFilterChips(pendingCount),
          const SizedBox(height: 16),
          ..._filtered.map((r) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _LeaveCard(request: r),
              )),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildFilterChips(int pendingCount) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _FilterChip(
            label: 'All Requests ${_kLeaveRequests.length}',
            isSelected: _filter == 'all',
            onTap: () => setState(() => _filter = 'all'),
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: 'Pending $pendingCount',
            isSelected: _filter == 'pending',
            badgeCount: pendingCount,
            onTap: () => setState(() => _filter = 'pending'),
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: 'Approved',
            isSelected: _filter == 'approved',
            onTap: () => setState(() => _filter = 'approved'),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.badgeCount,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final int? badgeCount;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryNavy : Colors.white,
          borderRadius: BorderRadius.circular(AppSpacing.chipRadius),
          border: Border.all(
              color: isSelected ? AppColors.primaryNavy : AppColors.border),
        ),
        child: Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: isSelected ? Colors.white : AppColors.textSecondary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

class _LeaveCard extends StatelessWidget {
  const _LeaveCard({required this.request});
  final dynamic request;

  Color get _typeColor {
    switch (request.type as String) {
      case 'Medical Leave': return AppColors.primaryBlue;
      case 'Personal':      return AppColors.statusGray;
      case 'Sick Leave':    return AppColors.statusAmber;
      case 'Family Event':  return const Color(0xFF7C3AED);
      default:              return AppColors.statusGray;
    }
  }

  Color get _typeBg {
    switch (request.type as String) {
      case 'Medical Leave': return AppColors.statusBlueBg;
      case 'Personal':      return AppColors.statusGrayBg;
      case 'Sick Leave':    return AppColors.statusAmberBg;
      case 'Family Event':  return const Color(0xFFEDE9FE);
      default:              return AppColors.statusGrayBg;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isPending  = request.status == 'pending';
    final isApproved = request.status == 'approved';

    Color statusColor;
    IconData statusIcon;
    Color statusBg;

    if (isPending) {
      statusColor = AppColors.statusAmber;
      statusIcon = Icons.schedule_outlined;
      statusBg = AppColors.statusAmberBg;
    } else if (isApproved) {
      statusColor = AppColors.statusGreen;
      statusIcon = Icons.check_circle_outline;
      statusBg = AppColors.statusGreenBg;
    } else { // rejected
      statusColor = AppColors.statusRed;
      statusIcon = Icons.cancel_outlined;
      statusBg = AppColors.statusRedBg;
    }

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
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: AppColors.primaryNavy.withValues(alpha: 0.12),
                child: Text(request.initials as String,
                    style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.primaryNavy,
                        fontWeight: FontWeight.w700)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(request.name as String, style: AppTextStyles.bodyMedium),
                    Text(request.program as String, style: AppTextStyles.caption),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: _typeBg,
                  borderRadius: BorderRadius.circular(AppSpacing.tagRadius),
                ),
                child: Text(request.type as String,
                    style: AppTextStyles.label.copyWith(
                        color: _typeColor, letterSpacing: 0.3)),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.calendar_today_outlined,
                  size: 13, color: AppColors.textSecondary),
              const SizedBox(width: 4),
              Text(request.dateRange as String,
                  style: AppTextStyles.caption.copyWith(fontSize: 11)),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusBg,
              borderRadius: BorderRadius.circular(AppSpacing.tagRadius),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(statusIcon, size: 13, color: statusColor),
                const SizedBox(width: 4),
                Text(request.statusLabel as String,
                    style: AppTextStyles.label.copyWith(
                        color: statusColor, letterSpacing: 0.3)),
              ],
            ),
          ),
          if (isPending && (request.quote as String).isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(request.quote as String,
                style: AppTextStyles.caption.copyWith(
                    fontStyle: FontStyle.italic)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.statusRed),
                      foregroundColor: AppColors.statusRed,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppSpacing.buttonRadius)),
                    ),
                    child: Text('Override Reject',
                        style: AppTextStyles.caption.copyWith(
                            color: AppColors.statusRed,
                            fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryNavy,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppSpacing.buttonRadius)),
                    ),
                    child: Text('Override Approve',
                        style: AppTextStyles.button.copyWith(fontSize: 13)),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
