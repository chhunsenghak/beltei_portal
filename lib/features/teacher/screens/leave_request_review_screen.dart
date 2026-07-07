import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/providers/teacher_providers.dart';
import '../../../core/services/teacher_service.dart';
import '../../../core/supabase/database.types.dart';
import '../../../l10n/app_localizations.dart';

// ── Helpers ───────────────────────────────────────────────────────────────────

String _fmtDate(String? iso, String locale) {
  if (iso == null) return '—';
  try {
    return DateFormat('MMM d, yyyy', locale).format(DateTime.parse(iso));
  } catch (_) {
    return iso;
  }
}

String _fmtDateTime(DateTime? dt, String locale) {
  if (dt == null) return '—';
  return DateFormat('MMM d, yyyy • hh:mm a', locale).format(dt);
}

// ── Screen ────────────────────────────────────────────────────────────────────

class LeaveRequestReviewScreen extends ConsumerWidget {
  const LeaveRequestReviewScreen({super.key, required this.requestId});
  final String requestId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
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
        title: Text(l.leaveReviewAppBarTitle, style: AppTextStyles.h3),
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
              Text(l.leaveDetailLoadError,
                  style: AppTextStyles.bodyMedium),
              TextButton(
                onPressed: () =>
                    ref.invalidate(leaveDetailProvider(requestId)),
                child: Text(l.retry),
              ),
            ],
          ),
        ),
        data: (leave) => leave == null
            ? Center(child: Text(l.leaveDetailNotFound))
            : _LeaveDetailBody(leave: leave, l: l),
      ),
    );
  }
}

// ── Body ──────────────────────────────────────────────────────────────────────

class _LeaveDetailBody extends StatelessWidget {
  const _LeaveDetailBody({required this.leave, required this.l});
  final StudentLeaveDetail leave;
  final AppLocalizations l;

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
              l.leaveReviewViewOnlyBanner,
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
          Text(l.profileIdLabel(leave.studentCode), style: AppTextStyles.caption),
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
      LeaveStatus.approved => l.leaveDashboardStatusApproved,
      LeaveStatus.rejected => l.leaveDashboardStatusRejected,
      _ => l.createLeaveSummaryStatusValue,
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
      title: l.leaveReviewAttendanceSummaryTitle,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(l.dashboardOverallRateLabel, style: AppTextStyles.bodyMedium),
              Text(
                leave.totalAttendanceDays > 0 ? '$pct%' : l.profileNa,
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
              Text(l.leaveReviewTotalRecordsLabel,
                  style: AppTextStyles.body),
              Text(
                l.leaveReviewSessionsCountValue(leave.totalAttendanceDays),
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
    final startFmt = _fmtDate(leave.startDate, l.localeName);
    final endFmt = _fmtDate(leave.endDate, l.localeName);

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
                    Text(l.leaveReviewCategoryLabel, style: AppTextStyles.label),
                    const SizedBox(height: 4),
                    Text(leave.type, style: AppTextStyles.bodyMedium),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(l.leaveReviewSubmittedLabel, style: AppTextStyles.label),
                  const SizedBox(height: 4),
                  Text(_fmtDateTime(leave.createdAt, l.localeName),
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
                    Text(l.createLeaveStartDateLabel, style: AppTextStyles.label),
                    const SizedBox(height: 2),
                    Text(startFmt, style: AppTextStyles.bodyMedium),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l.createLeaveEndDateLabel, style: AppTextStyles.label),
                    const SizedBox(height: 2),
                    Text(endFmt, style: AppTextStyles.bodyMedium),
                    Text(l.leaveReviewDaysCountValue(days),
                        style: AppTextStyles.caption),
                  ],
                ),
              ),
            ],
          ),
          if (leave.sessionNumber != null) ...[
            const SizedBox(height: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l.leaveReviewSessionLabel, style: AppTextStyles.label),
                const SizedBox(height: 2),
                Text(l.leaveSessionNumbered(leave.sessionNumber!),
                    style: AppTextStyles.bodyMedium),
              ],
            ),
          ],
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
      title: l.leaveReviewReasonTitle,
      child: Text(
        l.leaveReviewReasonQuoted(leave.reason),
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
      title: l.leaveReviewAttachmentTitle,
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
        title: l.leaveReviewDecisionTitle,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.hourglass_empty_outlined,
                    color: AppColors.statusAmber, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    l.leaveReviewAwaitingReviewText,
                    style: AppTextStyles.body
                        .copyWith(color: AppColors.textSecondary, height: 1.4),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    final isApproved = leave.status == LeaveStatus.approved;
    final color =
        isApproved ? AppColors.statusGreen : AppColors.statusRed;
    final icon = isApproved ? Icons.check_circle_outline : Icons.cancel_outlined;
    final label = isApproved ? l.leaveDashboardStatusApproved : l.leaveDashboardStatusRejected;

    return _SectionCard(
      title: l.leaveReviewDecisionTitle,
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
              Text(_fmtDateTime(leave.reviewedAt, l.localeName),
                  style: AppTextStyles.caption),
            ],
          ),
          if (leave.reviewNotes != null &&
              leave.reviewNotes!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Divider(color: AppColors.border),
            const SizedBox(height: 10),
            Text(l.leaveReviewReviewerNotesLabel, style: AppTextStyles.label),
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
