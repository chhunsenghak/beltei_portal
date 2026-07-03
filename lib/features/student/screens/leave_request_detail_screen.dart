import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/providers/student_providers.dart';
import '../../../core/supabase/database.types.dart';

String _fmtDate(String? iso) {
  if (iso == null) return '—';
  try {
    return DateFormat('MMM d, yyyy').format(DateTime.parse(iso));
  } catch (_) {
    return iso;
  }
}

String _fmtDateTime(DateTime? dt) {
  if (dt == null) return '—';
  return DateFormat('MMM d, yyyy • hh:mm a').format(dt);
}

class LeaveRequestDetailScreen extends ConsumerWidget {
  const LeaveRequestDetailScreen(
      {super.key, required this.requestId});
  final String requestId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncLeaves = ref.watch(studentLeaveRequestsProvider);

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
        title: Text('Leave Detail', style: AppTextStyles.h3),
      ),
      body: asyncLeaves.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline,
                  color: AppColors.statusRed, size: 40),
              const SizedBox(height: 8),
              Text('Could not load request', style: AppTextStyles.bodyMedium),
              TextButton(
                onPressed: () =>
                    ref.invalidate(studentLeaveRequestsProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (leaves) {
          final leave =
              leaves.where((l) => l.id == requestId).firstOrNull;
          if (leave == null) {
            return const Center(child: Text('Request not found.'));
          }
          return _LeaveBody(leave: leave, ref: ref);
        },
      ),
    );
  }
}

// ── Body ──────────────────────────────────────────────────────────────────────

class _LeaveBody extends StatelessWidget {
  const _LeaveBody({required this.leave, required this.ref});
  final LeaveRequestRow leave;
  final WidgetRef ref;

  Color get _statusColor => switch (leave.status) {
        LeaveStatus.approved => AppColors.statusGreen,
        LeaveStatus.rejected => AppColors.statusRed,
        LeaveStatus.pending  => AppColors.statusAmber,
      };

  Color get _statusBg => switch (leave.status) {
        LeaveStatus.approved => AppColors.statusGreenBg,
        LeaveStatus.rejected => AppColors.statusRedBg,
        LeaveStatus.pending  => AppColors.statusAmberBg,
      };

  String get _statusLabel => switch (leave.status) {
        LeaveStatus.approved => 'APPROVED',
        LeaveStatus.rejected => 'REJECTED',
        LeaveStatus.pending  => 'PENDING',
      };

  IconData get _statusIcon => switch (leave.status) {
        LeaveStatus.approved => Icons.check_circle_outline,
        LeaveStatus.rejected => Icons.cancel_outlined,
        LeaveStatus.pending  => Icons.description_outlined,
      };

  int get _totalDays {
    try {
      return DateTime.parse(leave.endDate)
              .difference(DateTime.parse(leave.startDate))
              .inDays +
          1;
    } catch (_) {
      return 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      child: Column(
        children: [
          _buildStatusHeader(),
          const SizedBox(height: AppSpacing.sectionGap),
          _buildTimeline(),
          const SizedBox(height: AppSpacing.sectionGap),
          _buildRequestInfo(),
          if (leave.status != LeaveStatus.pending &&
              leave.reviewNotes != null &&
              leave.reviewNotes!.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sectionGap),
            _buildReviewNotes(),
          ],
          if (leave.status == LeaveStatus.pending) ...[
            const SizedBox(height: AppSpacing.sectionGap),
            _buildWithdrawButton(context),
          ],
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildStatusHeader() {
    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: _statusBg,
            shape: BoxShape.circle,
          ),
          child: Icon(_statusIcon, color: _statusColor, size: 32),
        ),
        const SizedBox(height: 12),
        Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: _statusBg,
            borderRadius:
                BorderRadius.circular(AppSpacing.chipRadius),
          ),
          child: Text(_statusLabel,
              style: AppTextStyles.label
                  .copyWith(color: _statusColor)),
        ),
        const SizedBox(height: 6),
        Text('Submitted ${_fmtDateTime(leave.createdAt)}',
            style: AppTextStyles.caption),
      ],
    );
  }

  Widget _buildTimeline() {
    final isDecided = leave.status != LeaveStatus.pending;
    final steps = [
      (label: 'Submitted',    sub: _fmtDate(leave.startDate), done: true),
      (label: 'Under Review', sub: 'Academic Office',         done: true),
      (label: 'Decision',     sub: isDecided ? _statusLabel : '', done: isDecided),
    ];

    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Request Timeline', style: AppTextStyles.h3),
          const SizedBox(height: 16),
          Row(
            children: List.generate(steps.length * 2 - 1, (i) {
              if (i.isOdd) {
                return Expanded(
                  child: Container(
                    height: 2,
                    color: steps[(i ~/ 2) + 1].done
                        ? AppColors.primaryNavy
                        : AppColors.border,
                  ),
                );
              }
              final step = steps[i ~/ 2];
              return Column(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: step.done
                          ? AppColors.primaryNavy
                          : AppColors.bgPage,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: step.done
                            ? AppColors.primaryNavy
                            : AppColors.border,
                        width: 2,
                      ),
                    ),
                    child: step.done
                        ? const Icon(Icons.check,
                            color: Colors.white, size: 18)
                        : null,
                  ),
                  const SizedBox(height: 4),
                  Text(step.label,
                      style: AppTextStyles.caption.copyWith(
                          fontWeight: FontWeight.w600, fontSize: 11),
                      textAlign: TextAlign.center),
                  if (step.sub.isNotEmpty)
                    Text(step.sub,
                        style: AppTextStyles.caption
                            .copyWith(fontSize: 10),
                        textAlign: TextAlign.center),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestInfo() {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.article_outlined,
                  color: AppColors.primaryNavy, size: 20),
              const SizedBox(width: 8),
              Text('Request Information', style: AppTextStyles.h3),
            ],
          ),
          const SizedBox(height: 16),
          _field('LEAVE TYPE',
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.statusBlueBg,
                  borderRadius:
                      BorderRadius.circular(AppSpacing.chipRadius),
                ),
                child: Text(leave.type,
                    style: AppTextStyles.caption.copyWith(
                        color: AppColors.primaryBlue,
                        fontWeight: FontWeight.w600)),
              )),
          const SizedBox(height: 12),
          _field('DATES',
              child: Row(
                children: [
                  Icon(Icons.calendar_today_outlined,
                      size: 14, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Text(
                    '${_fmtDate(leave.startDate)} — ${_fmtDate(leave.endDate)}',
                    style: AppTextStyles.bodyMedium,
                  ),
                ],
              )),
          const SizedBox(height: 12),
          _labelValue('TOTAL DAYS',
              '$_totalDays day${_totalDays == 1 ? '' : 's'}'),
          const SizedBox(height: 12),
          _field('REASON FOR REQUEST',
              child: Text(
                leave.reason,
                style: AppTextStyles.body.copyWith(
                    color: AppColors.textSecondary, height: 1.5),
              )),
        ],
      ),
    );
  }

  Widget _buildReviewNotes() {
    final isApproved = leave.status == LeaveStatus.approved;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: isApproved
            ? AppColors.statusGreenBg.withValues(alpha: 0.4)
            : AppColors.statusRedBg.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isApproved
                    ? Icons.check_circle_outline
                    : Icons.comment_outlined,
                color: isApproved
                    ? AppColors.statusGreen
                    : AppColors.statusRed,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text('Reviewer Notes', style: AppTextStyles.h3),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            '"${leave.reviewNotes!}"',
            style: AppTextStyles.body.copyWith(
                color: AppColors.textSecondary,
                fontStyle: FontStyle.italic,
                height: 1.5),
          ),
          if (leave.reviewedAt != null) ...[
            const SizedBox(height: 8),
            Text(
              'Reviewed on ${_fmtDateTime(leave.reviewedAt)}',
              style: AppTextStyles.caption,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildWithdrawButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: AppSpacing.buttonHeight,
      child: OutlinedButton.icon(
        onPressed: () => _confirmWithdraw(context),
        icon: Icon(Icons.cancel_outlined,
            color: AppColors.statusRed),
        label: Text('Withdraw Request',
            style:
                AppTextStyles.button.copyWith(color: AppColors.statusRed)),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: AppColors.statusRed),
          shape: RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(AppSpacing.buttonRadius)),
        ),
      ),
    );
  }

  void _confirmWithdraw(BuildContext context) {
    showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Withdraw Request'),
        content: const Text(
            'Are you sure you want to withdraw this leave request? This cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style:
                TextButton.styleFrom(foregroundColor: AppColors.statusRed),
            child: const Text('Withdraw'),
          ),
        ],
      ),
    ).then((confirmed) async {
      if (confirmed != true) return;
      try {
        await ref
            .read(studentServiceProvider)
            .cancelLeaveRequest(leave.id);
        ref.invalidate(studentLeaveRequestsProvider);
        if (context.mounted) Navigator.of(context).pop();
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Failed to withdraw: $e'),
            backgroundColor: AppColors.statusRed,
          ));
        }
      }
    });
  }

  Widget _field(String label, {required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.label),
        const SizedBox(height: 4),
        child,
      ],
    );
  }

  Widget _labelValue(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.label),
        const SizedBox(height: 2),
        Text(value, style: AppTextStyles.h3),
      ],
    );
  }
}

// ── Reusable card ──────────────────────────────────────────────────────────────

class _Card extends StatelessWidget {
  const _Card({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(color: AppColors.border),
      ),
      child: child,
    );
  }
}
