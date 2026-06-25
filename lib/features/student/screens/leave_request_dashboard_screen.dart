import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';

// ── Mock data ──────────────────────────────────────────────────────────────────

enum _LeaveStatus { pending, approved, rejected }

class _LeaveItem {
  const _LeaveItem({
    required this.id,
    required this.course,
    required this.type,
    required this.dateRange,
    required this.status,
    required this.icon,
  });
  final String id, course, type, dateRange;
  final _LeaveStatus status;
  final IconData icon;
}

const _kLeaves = [
  _LeaveItem(
    id: '1',
    course: 'Digital Marketing 101',
    type: 'Sick Leave',
    dateRange: 'Oct 12 - Oct 14, 2023',
    status: _LeaveStatus.pending,
    icon: Icons.sick_outlined,
  ),
  _LeaveItem(
    id: '2',
    course: 'Advanced Mathematics',
    type: 'Family Event',
    dateRange: 'Sep 25 - Sep 25, 2023',
    status: _LeaveStatus.approved,
    icon: Icons.calendar_today_outlined,
  ),
  _LeaveItem(
    id: '3',
    course: 'Introduction to Law',
    type: 'Medical Checkup',
    dateRange: 'Aug 14 - Aug 14, 2023',
    status: _LeaveStatus.rejected,
    icon: Icons.local_hospital_outlined,
  ),
  _LeaveItem(
    id: '4',
    course: 'Economics Foundations',
    type: 'Overseas Program',
    dateRange: 'Jul 10 - Jul 20, 2023',
    status: _LeaveStatus.approved,
    icon: Icons.flight_takeoff_outlined,
  ),
];

// ── Screen ────────────────────────────────────────────────────────────────────

class LeaveRequestDashboardScreen extends StatelessWidget {
  const LeaveRequestDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      floatingActionButton: _buildNewRequestFab(context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTitle(),
            const SizedBox(height: AppSpacing.md),
            _buildStatusChips(),
            const SizedBox(height: AppSpacing.md),
            ..._kLeaves.map((leave) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _LeaveCard(
                    leave: leave,
                    onTap: () => context.go('/student/leave/${leave.id}'),
                  ),
                )),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  // ── FAB ────────────────────────────────────────────────────────────────────

  Widget _buildNewRequestFab(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () => context.go('/student/leave/create'),
      backgroundColor: AppColors.primaryBlue,
      icon: const Icon(Icons.add, color: Colors.white),
      label: Text('New Request', style: AppTextStyles.button.copyWith(fontSize: 14)),
    );
  }

  // ── Title ──────────────────────────────────────────────────────────────────

  Widget _buildTitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Leave Requests', style: AppTextStyles.h1),
        const SizedBox(height: 4),
        Text('Manage and track your absence applications.',
            style: AppTextStyles.caption),
      ],
    );
  }

  // ── Status summary chips ───────────────────────────────────────────────────

  Widget _buildStatusChips() {
    final pending = _kLeaves.where((l) => l.status == _LeaveStatus.pending).length;
    final approved = _kLeaves.where((l) => l.status == _LeaveStatus.approved).length;
    final rejected = _kLeaves.where((l) => l.status == _LeaveStatus.rejected).length;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _StatusChip(count: pending, label: 'Pending', color: AppColors.statusAmber),
        _StatusChip(count: approved, label: 'Approved', color: AppColors.statusGreen),
        _StatusChip(count: rejected, label: 'Rejected', color: AppColors.statusRed),
      ],
    );
  }
}

// ── Status chip ────────────────────────────────────────────────────────────────

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.count, required this.label, required this.color});
  final int count;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(AppSpacing.chipRadius),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text('$count $label', style: AppTextStyles.bodyMedium),
        ],
      ),
    );
  }
}

// ── Leave card ────────────────────────────────────────────────────────────────

class _LeaveCard extends StatelessWidget {
  const _LeaveCard({required this.leave, required this.onTap});
  final _LeaveItem leave;
  final VoidCallback onTap;

  Color get _statusColor => switch (leave.status) {
        _LeaveStatus.pending => AppColors.statusAmber,
        _LeaveStatus.approved => AppColors.statusGreen,
        _LeaveStatus.rejected => AppColors.statusRed,
      };

  String get _statusLabel => switch (leave.status) {
        _LeaveStatus.pending => 'Pending',
        _LeaveStatus.approved => 'Approved',
        _LeaveStatus.rejected => 'Rejected',
      };

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
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
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.statusGrayBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(leave.icon, color: AppColors.primaryNavy, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(leave.course, style: AppTextStyles.h3),
                  const SizedBox(height: 2),
                  Text('${leave.type} • ${leave.dateRange}',
                      style: AppTextStyles.caption),
                  const SizedBox(height: 6),
                  _buildStatusBadge(),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textLabel),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(color: _statusColor, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(_statusLabel,
            style: AppTextStyles.caption.copyWith(
                color: _statusColor, fontWeight: FontWeight.w600)),
      ],
    );
  }
}
