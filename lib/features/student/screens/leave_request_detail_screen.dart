import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';

class LeaveRequestDetailScreen extends StatelessWidget {
  const LeaveRequestDetailScreen({super.key, required this.requestId});
  final String requestId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          children: [
            _buildStatusHeader(),
            const SizedBox(height: AppSpacing.sectionGap),
            _buildTimeline(),
            const SizedBox(height: AppSpacing.sectionGap),
            _buildRequestInfo(),
            const SizedBox(height: AppSpacing.sectionGap),
            _buildFacultyRemarks(),
            const SizedBox(height: AppSpacing.sectionGap),
            _buildActions(context),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // ── App bar ────────────────────────────────────────────────────────────────

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.bgPage,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, size: 18),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Text('Leave Detail', style: AppTextStyles.h3),
      actions: [
        IconButton(icon: const Icon(Icons.share_outlined), onPressed: () {}),
      ],
    );
  }

  // ── Status header ──────────────────────────────────────────────────────────

  Widget _buildStatusHeader() {
    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: AppColors.statusAmberBg,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.description_outlined,
              color: AppColors.statusAmber, size: 32),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.statusAmberBg,
            borderRadius: BorderRadius.circular(AppSpacing.chipRadius),
          ),
          child: Text('PENDING',
              style: AppTextStyles.label.copyWith(color: AppColors.statusAmber)),
        ),
        const SizedBox(height: 6),
        Text('Submitted on Oct 24, 2023 • 09:15 AM',
            style: AppTextStyles.caption),
      ],
    );
  }

  // ── Timeline ───────────────────────────────────────────────────────────────

  Widget _buildTimeline() {
    final steps = [
      (label: 'Submitted', sub: 'Oct 24, 09:15', done: true),
      (label: 'Under Review', sub: 'Academic Office', done: true),
      (label: 'Decision', sub: '', done: false),
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
                      color: step.done ? AppColors.primaryNavy : AppColors.bgPage,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: step.done ? AppColors.primaryNavy : AppColors.border,
                        width: 2,
                      ),
                    ),
                    child: step.done
                        ? const Icon(Icons.check, color: Colors.white, size: 18)
                        : null,
                  ),
                  const SizedBox(height: 4),
                  Text(step.label,
                      style: AppTextStyles.caption.copyWith(
                          fontWeight: FontWeight.w600, fontSize: 11),
                      textAlign: TextAlign.center),
                  if (step.sub.isNotEmpty)
                    Text(step.sub,
                        style: AppTextStyles.caption.copyWith(fontSize: 10),
                        textAlign: TextAlign.center),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  // ── Request info ───────────────────────────────────────────────────────────

  Widget _buildRequestInfo() {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.article_outlined, color: AppColors.primaryNavy, size: 20),
              const SizedBox(width: 8),
              Text('Request Information', style: AppTextStyles.h3),
            ],
          ),
          const SizedBox(height: 16),
          _buildField('COURSE / SUBJECT', 'BBA in International Business'),
          const SizedBox(height: 12),
          _buildField('LEAVE TYPE', null, chip: 'Medical Leave'),
          const SizedBox(height: 12),
          _buildField('DURATION', null, sub: 'Oct 26 — Oct 28, 2023',
              icon: Icons.calendar_today_outlined),
          const SizedBox(height: 12),
          _buildField('TOTAL DAYS', '3 Days'),
          const SizedBox(height: 12),
          _buildField('REASON FOR REQUEST', null),
          const SizedBox(height: 6),
          Text(
            'I am writing to request a medical leave as I have been diagnosed with acute seasonal influenza. My physician has advised strictly bed rest and isolation for at least 72 hours to ensure full recovery.',
            style: AppTextStyles.body.copyWith(color: AppColors.textSecondary, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildField(String label, String? value,
      {String? chip, String? sub, IconData? icon}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.label),
        const SizedBox(height: 4),
        if (chip != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.statusBlueBg,
              borderRadius: BorderRadius.circular(AppSpacing.chipRadius),
            ),
            child: Text(chip,
                style: AppTextStyles.caption.copyWith(
                    color: AppColors.primaryBlue, fontWeight: FontWeight.w600)),
          )
        else if (sub != null)
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 14, color: AppColors.textSecondary),
                const SizedBox(width: 4),
              ],
              Text(sub, style: AppTextStyles.bodyMedium),
            ],
          )
        else if (value != null)
          Text(value, style: AppTextStyles.h3),
      ],
    );
  }

  // ── Faculty remarks ────────────────────────────────────────────────────────

  Widget _buildFacultyRemarks() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.primaryNavy.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.comment_outlined, color: AppColors.primaryNavy, size: 18),
              const SizedBox(width: 8),
              Text('Faculty Remarks', style: AppTextStyles.h3),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '"The student has maintained excellent attendance prior to this. Awaiting verification of the medical certificate from the campus clinic. Request seems valid."',
            style: AppTextStyles.body.copyWith(
                color: AppColors.textSecondary, fontStyle: FontStyle.italic, height: 1.5),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.statusGrayBg,
                child: const Icon(Icons.person, color: AppColors.textSecondary, size: 18),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Dr. Sophea Morn', style: AppTextStyles.bodyMedium),
                  Text('HEAD OF DEPARTMENT',
                      style: AppTextStyles.label.copyWith(color: AppColors.textSecondary)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Actions ────────────────────────────────────────────────────────────────

  Widget _buildActions(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: AppSpacing.buttonHeight,
          child: OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.edit_outlined, color: AppColors.primaryNavy),
            label: Text('Edit Request',
                style: AppTextStyles.button.copyWith(color: AppColors.primaryNavy)),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.primaryNavy),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.buttonRadius)),
            ),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          height: AppSpacing.buttonHeight,
          child: OutlinedButton.icon(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.cancel_outlined, color: AppColors.statusRed),
            label: Text('Withdraw',
                style: AppTextStyles.button.copyWith(color: AppColors.statusRed)),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.statusRed),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.buttonRadius)),
            ),
          ),
        ),
      ],
    );
  }
}

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
