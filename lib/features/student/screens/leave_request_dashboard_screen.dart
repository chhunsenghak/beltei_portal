import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/providers/student_providers.dart';
import '../../../core/supabase/database.types.dart';
import '../../../l10n/app_localizations.dart';

// ── Helpers ───────────────────────────────────────────────────────────────────

String _fmtDateRange(String start, String end) {
  try {
    final s = DateFormat('MMM d').format(DateTime.parse(start));
    final e = DateFormat('MMM d, yyyy').format(DateTime.parse(end));
    return '$s - $e';
  } catch (_) {
    return '$start – $end';
  }
}

IconData _iconForType(String type) {
  final t = type.toLowerCase();
  if (t.contains('sick') || t.contains('medical')) {
    return Icons.local_hospital_outlined;
  }
  if (t.contains('family')) return Icons.family_restroom_outlined;
  if (t.contains('travel') || t.contains('overseas')) {
    return Icons.flight_takeoff_outlined;
  }
  return Icons.event_note_outlined;
}

// ── Screen ────────────────────────────────────────────────────────────────────

class LeaveRequestDashboardScreen extends ConsumerWidget {
  const LeaveRequestDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final leavesAsync = ref.watch(studentLeaveRequestsProvider);

    return Scaffold(
      backgroundColor: AppColors.bgPage,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/student/leave/create'),
        backgroundColor: AppColors.primaryBlue,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(l.leaveDashboardNewRequestButton,
            style: AppTextStyles.button.copyWith(fontSize: 14)),
      ),
      body: leavesAsync.when(
        loading: () =>
            const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline,
                  color: AppColors.statusRed, size: 40),
              const SizedBox(height: 8),
              Text(l.leaveDashboardLoadError,
                  style: AppTextStyles.bodyMedium),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () =>
                    ref.invalidate(studentLeaveRequestsProvider),
                child: Text(l.retry),
              ),
            ],
          ),
        ),
        data: (leaves) => SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTitle(l),
              const SizedBox(height: AppSpacing.md),
              _buildStatusChips(leaves, l),
              const SizedBox(height: AppSpacing.md),
              if (leaves.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 40),
                    child: Text(l.leaveDashboardEmptyState),
                  ),
                )
              else
                ...leaves.map((leave) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _LeaveCard(
                        leave: leave,
                        l: l,
                        onTap: () => context
                            .go('/student/leave/${leave.id}'),
                      ),
                    )),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTitle(AppLocalizations l) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l.leaveDashboardTitle, style: AppTextStyles.h1),
        const SizedBox(height: 4),
        Text(l.leaveDashboardSubtitle,
            style: AppTextStyles.caption),
      ],
    );
  }

  Widget _buildStatusChips(List<LeaveRequestRow> leaves, AppLocalizations l) {
    final pending =
        leaves.where((r) => r.status == LeaveStatus.pending).length;
    final approved =
        leaves.where((r) => r.status == LeaveStatus.approved).length;
    final rejected =
        leaves.where((r) => r.status == LeaveStatus.rejected).length;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _StatusChip(
            count: pending,
            label: l.leaveDashboardStatusPending,
            color: AppColors.statusAmber),
        _StatusChip(
            count: approved,
            label: l.leaveDashboardStatusApproved,
            color: AppColors.statusGreen),
        _StatusChip(
            count: rejected,
            label: l.leaveDashboardStatusRejected,
            color: AppColors.statusRed),
      ],
    );
  }
}

// ── Status chip ────────────────────────────────────────────────────────────────

class _StatusChip extends StatelessWidget {
  const _StatusChip(
      {required this.count,
      required this.label,
      required this.color});
  final int count;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
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
            decoration:
                BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text('$count $label', style: AppTextStyles.bodyMedium),
        ],
      ),
    );
  }
}

// ── Leave card ─────────────────────────────────────────────────────────────────

class _LeaveCard extends StatelessWidget {
  const _LeaveCard({required this.leave, required this.onTap, required this.l});
  final LeaveRequestRow leave;
  final VoidCallback onTap;
  final AppLocalizations l;

  Color get _statusColor => switch (leave.status) {
        LeaveStatus.pending => AppColors.statusAmber,
        LeaveStatus.approved => AppColors.statusGreen,
        LeaveStatus.rejected => AppColors.statusRed,
      };

  String get _statusLabel => switch (leave.status) {
        LeaveStatus.pending => l.leaveDashboardStatusPending,
        LeaveStatus.approved => l.leaveDashboardStatusApproved,
        LeaveStatus.rejected => l.leaveDashboardStatusRejected,
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
              child: Icon(_iconForType(leave.type),
                  color: AppColors.primaryNavy, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(leave.type, style: AppTextStyles.h3),
                  const SizedBox(height: 2),
                  Text(
                    _fmtDateRange(leave.startDate, leave.endDate),
                    style: AppTextStyles.caption,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    leave.reason,
                    style: AppTextStyles.caption
                        .copyWith(color: AppColors.textSecondary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  _buildStatusBadge(),
                ],
              ),
            ),
            Icon(Icons.chevron_right,
                color: AppColors.textLabel),
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
          decoration: BoxDecoration(
              color: _statusColor, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(_statusLabel,
            style: AppTextStyles.caption.copyWith(
                color: _statusColor,
                fontWeight: FontWeight.w600)),
      ],
    );
  }
}
