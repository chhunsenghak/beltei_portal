import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/providers/teacher_providers.dart';
import '../../../core/services/teacher_service.dart';
import '../../../core/supabase/database.types.dart';

// ── Helpers ───────────────────────────────────────────────────────────────────

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

// ── Screen ────────────────────────────────────────────────────────────────────

class LeaveRequestReviewScreen extends ConsumerWidget {
  const LeaveRequestReviewScreen({super.key, required this.requestId});
  final String requestId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final leaveAsync = ref.watch(leaveDetailProvider(requestId));

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
        title: Text('Leave Request Details', style: AppTextStyles.h3),
      ),
      body: leaveAsync.when(
        loading: () =>
            const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline,
                  color: AppColors.statusRed, size: 40),
              const SizedBox(height: 8),
              Text('Could not load request',
                  style: AppTextStyles.bodyMedium),
              TextButton(
                onPressed: () =>
                    ref.invalidate(leaveDetailProvider(requestId)),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (leave) => leave == null
            ? const Center(child: Text('Request not found.'))
            : _LeaveDetailBody(leave: leave),
      ),
    );
  }
}

// ── Body ──────────────────────────────────────────────────────────────────────

class _LeaveDetailBody extends StatelessWidget {
  const _LeaveDetailBody({required this.leave});
  final StudentLeaveDetail leave;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildViewOnlyBanner(),
          const SizedBox(height: AppSpacing.sectionGap),
          _buildStudentCard(),
          const SizedBox(height: AppSpacing.sectionGap),
          _buildAttendanceSummary(),
          const SizedBox(height: AppSpacing.sectionGap),
          _buildLeaveDetails(),
          const SizedBox(height: AppSpacing.sectionGap),
          _buildReason(),
          if (leave.docUrl != null) ...[
            const SizedBox(height: AppSpacing.sectionGap),
            _buildAttachment(),
          ],
          const SizedBox(height: AppSpacing.sectionGap),
          _buildStatusPanel(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // ── View-only banner ───────────────────────────────────────────────────────

  Widget _buildViewOnlyBanner() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.statusAmberBg,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(
            color: AppColors.statusAmber.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline,
              color: AppColors.statusAmber, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Only administrators can approve or reject student leave requests.',
              style: AppTextStyles.body.copyWith(
                  color: AppColors.statusAmber, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  // ── Student card ───────────────────────────────────────────────────────────

  Widget _buildStudentCard() {
    return _SectionCard(
      showTitle: false,
      title: '',
      child: Column(
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: AppColors.primaryNavy.withValues(alpha: 0.1),
            child: Text(
              leave.initials,
              style: AppTextStyles.h2.copyWith(color: AppColors.primaryNavy),
            ),
          ),
          const SizedBox(height: 10),
          Text(leave.studentName, style: AppTextStyles.h2),
          Text('ID: ${leave.studentCode}', style: AppTextStyles.caption),
          const SizedBox(height: 8),
          _buildStatusBadge(),
        ],
      ),
    );
  }

  Widget _buildStatusBadge() {
    final color = switch (leave.status) {
      LeaveStatus.approved => AppColors.statusGreen,
      LeaveStatus.rejected => AppColors.statusRed,
      _ => AppColors.statusAmber,
    };
    final bg = switch (leave.status) {
      LeaveStatus.approved => AppColors.statusGreenBg,
      LeaveStatus.rejected => AppColors.statusRedBg,
      _ => AppColors.statusAmberBg,
    };
    final label = switch (leave.status) {
      LeaveStatus.approved => 'Approved',
      LeaveStatus.rejected => 'Rejected',
      _ => 'Pending Review',
    };
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppSpacing.chipRadius),
      ),
      child: Text(label,
          style: AppTextStyles.bodyMedium
              .copyWith(color: color, letterSpacing: 0.4)),
    );
  }

  // ── Attendance summary ─────────────────────────────────────────────────────

  Widget _buildAttendanceSummary() {
    final rate = leave.attendanceRate;
    final pct = (rate * 100).round();
    final rateColor = rate >= 0.85
        ? AppColors.statusGreen
        : rate >= 0.70
            ? AppColors.statusAmber
            : AppColors.statusRed;

    return _SectionCard(
      title: 'Attendance Summary',
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Overall Rate', style: AppTextStyles.bodyMedium),
              Text(
                leave.totalAttendanceDays > 0 ? '$pct%' : 'N/A',
                style: AppTextStyles.bodyMedium.copyWith(color: rateColor),
              ),
            ],
          ),
          if (leave.totalAttendanceDays > 0) ...[
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: rate,
                minHeight: 6,
                backgroundColor: AppColors.border,
                valueColor: AlwaysStoppedAnimation<Color>(rateColor),
              ),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total Records (Sem)',
                  style: AppTextStyles.body),
              Text(
                '${leave.totalAttendanceDays} Sessions',
                style: AppTextStyles.bodyMedium,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Leave details ──────────────────────────────────────────────────────────

  Widget _buildLeaveDetails() {
    final startFmt = _fmtDate(leave.startDate);
    final endFmt = _fmtDate(leave.endDate);

    int days = 1;
    try {
      days = DateTime.parse(leave.endDate)
              .difference(DateTime.parse(leave.startDate))
              .inDays +
          1;
    } catch (_) {}

    return _SectionCard(
      showTitle: false,
      title: '',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.statusBlueBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _iconForType(leave.type),
                  color: AppColors.primaryBlue,
                  size: 22,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('LEAVE CATEGORY', style: AppTextStyles.label),
                    const SizedBox(height: 4),
                    Text(leave.type, style: AppTextStyles.bodyMedium),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('SUBMITTED', style: AppTextStyles.label),
                  const SizedBox(height: 4),
                  Text(_fmtDateTime(leave.createdAt),
                      style: AppTextStyles.caption,
                      textAlign: TextAlign.right),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          Divider(color: AppColors.border),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('START DATE', style: AppTextStyles.label),
                    const SizedBox(height: 2),
                    Text(startFmt, style: AppTextStyles.bodyMedium),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('END DATE', style: AppTextStyles.label),
                    const SizedBox(height: 2),
                    Text(endFmt, style: AppTextStyles.bodyMedium),
                    Text('$days Day${days == 1 ? '' : 's'}',
                        style: AppTextStyles.caption),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _iconForType(String type) {
    final t = type.toLowerCase();
    if (t.contains('sick') || t.contains('medical')) {
      return Icons.local_hospital_outlined;
    }
    if (t.contains('family')) return Icons.family_restroom_outlined;
    if (t.contains('personal')) return Icons.person_outline;
    if (t.contains('travel') || t.contains('overseas')) {
      return Icons.flight_takeoff_outlined;
    }
    return Icons.event_note_outlined;
  }

  // ── Reason ─────────────────────────────────────────────────────────────────

  Widget _buildReason() {
    return _SectionCard(
      title: 'Reason',
      child: Text(
        '"${leave.reason}"',
        style: AppTextStyles.body
            .copyWith(fontStyle: FontStyle.italic, height: 1.6),
      ),
    );
  }

  // ── Attachment ─────────────────────────────────────────────────────────────

  Widget _buildAttachment() {
    final url = leave.docUrl!;
    final isPdf = url.toLowerCase().endsWith('.pdf');
    return _SectionCard(
      title: 'Attachment',
      child: Container(
        width: double.infinity,
        height: 100,
        decoration: BoxDecoration(
          color: AppColors.statusGrayBg,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isPdf
                  ? Icons.picture_as_pdf_outlined
                  : Icons.attach_file_outlined,
              color: AppColors.statusRed,
              size: 32,
            ),
            const SizedBox(height: 6),
            Text(
              url.split('/').last,
              style: TextStyle(
                  color: AppColors.textSecondary, fontSize: 12),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  // ── Status panel ───────────────────────────────────────────────────────────

  Widget _buildStatusPanel() {
    if (leave.status == LeaveStatus.pending) {
      return _SectionCard(
        title: 'Decision',
        child: Row(
          children: [
            Icon(Icons.hourglass_empty_outlined,
                color: AppColors.statusAmber, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Awaiting admin review. Only administrators can approve or reject leave requests.',
                style: AppTextStyles.body
                    .copyWith(color: AppColors.textSecondary, height: 1.4),
              ),
            ),
          ],
        ),
      );
    }

    final isApproved = leave.status == LeaveStatus.approved;
    final color =
        isApproved ? AppColors.statusGreen : AppColors.statusRed;
    final icon = isApproved ? Icons.check_circle_outline : Icons.cancel_outlined;
    final label = isApproved ? 'Approved' : 'Rejected';

    return _SectionCard(
      title: 'Decision',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(label,
                  style: AppTextStyles.bodyMedium.copyWith(color: color)),
              const Spacer(),
              Text(_fmtDateTime(leave.reviewedAt),
                  style: AppTextStyles.caption),
            ],
          ),
          if (leave.reviewNotes != null &&
              leave.reviewNotes!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Divider(color: AppColors.border),
            const SizedBox(height: 10),
            Text('REVIEWER NOTES', style: AppTextStyles.label),
            const SizedBox(height: 4),
            Text(leave.reviewNotes!,
                style:
                    AppTextStyles.body.copyWith(height: 1.5)),
          ],
        ],
      ),
    );
  }
}

// ── Reusable widgets ───────────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  const _SectionCard(
      {required this.title,
      required this.child,
      this.showTitle = true});
  final String title;
  final Widget child;
  final bool showTitle;

  @override
  Widget build(BuildContext context) {
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
          if (showTitle) ...[
            Text(title.toUpperCase(), style: AppTextStyles.label),
            const SizedBox(height: 12),
          ],
          child,
        ],
      ),
    );
  }
}
