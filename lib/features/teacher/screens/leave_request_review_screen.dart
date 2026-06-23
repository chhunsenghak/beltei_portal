import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';

// ── Mock data ──────────────────────────────────────────────────────────────────

const _kLeave = (
  studentName: 'Sokha Menglong',
  studentId: 'ID: BT-99281',
  year: 'Year 3',
  shift: 'Evening Shift',
  attendanceRate: '94%',
  totalLeaves: '2 Days',
  category: 'Sick\nLeave',
  categoryColor: AppColors.primaryBlue,
  categoryBg: AppColors.statusBlueBg,
  submittedDate: 'Oct 24, 2023 • 09:15 AM',
  targetCourse: 'Advanced Macroeconomics',
  targetClass: 'Class: A2-G4',
  requestedDates: 'Oct 25 – Oct 27',
  totalWorkdays: '3 Total Workdays',
  reason:
      '"I have been diagnosed with a severe case of seasonal influenza and the doctor has recommended three days of strict bed rest. I have attached the medical certificate from Royal Phnom Penh Hospital for your reference."',
);

// ── Screen ────────────────────────────────────────────────────────────────────

class LeaveRequestReviewScreen extends StatefulWidget {
  const LeaveRequestReviewScreen({super.key, required this.requestId});
  final String requestId;

  @override
  State<LeaveRequestReviewScreen> createState() =>
      _LeaveRequestReviewScreenState();
}

class _LeaveRequestReviewScreenState extends State<LeaveRequestReviewScreen> {
  final _remarksController = TextEditingController();
  String? _decision; // 'approved' or 'rejected'

  @override
  void dispose() {
    _remarksController.dispose();
    super.dispose();
  }

  void _decide(String decision) {
    setState(() => _decision = decision);
    final label = decision == 'approved' ? 'Approved' : 'Rejected';
    final color = decision == 'approved' ? AppColors.statusGreen : AppColors.statusRed;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Leave request $label.',
          style: AppTextStyles.body.copyWith(color: Colors.white)),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) Navigator.of(context).pop();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStudentCard(),
            const SizedBox(height: AppSpacing.sectionGap),
            _buildAttendanceSummary(),
            const SizedBox(height: AppSpacing.sectionGap),
            _buildLeaveDetails(),
            const SizedBox(height: AppSpacing.sectionGap),
            _buildReason(),
            const SizedBox(height: AppSpacing.sectionGap),
            _buildAttachment(),
            const SizedBox(height: AppSpacing.sectionGap),
            _buildReviewerRemarks(),
            const SizedBox(height: AppSpacing.xl),
            _buildActionButtons(),
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
      title: Text('Review Leave Request', style: AppTextStyles.h3),
    );
  }

  // ── Student card ───────────────────────────────────────────────────────────

  Widget _buildStudentCard() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: AppColors.primaryNavy.withValues(alpha: 0.1),
            child: const Icon(Icons.person, color: AppColors.primaryNavy, size: 36),
          ),
          const SizedBox(height: 10),
          Text(_kLeave.studentName, style: AppTextStyles.h2),
          Text(_kLeave.studentId, style: AppTextStyles.caption),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _SmallBadge(_kLeave.year,
                  bg: AppColors.statusBlueBg, color: AppColors.primaryBlue),
              const SizedBox(width: 8),
              _SmallBadge(_kLeave.shift,
                  bg: AppColors.statusAmberBg, color: AppColors.statusAmber),
            ],
          ),
        ],
      ),
    );
  }

  // ── Attendance summary ─────────────────────────────────────────────────────

  Widget _buildAttendanceSummary() {
    return _SectionCard(
      title: 'Attendance Summary',
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Overall Rate', style: AppTextStyles.bodyMedium),
              Text(_kLeave.attendanceRate,
                  style: AppTextStyles.bodyMedium
                      .copyWith(color: AppColors.statusGreen)),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: const LinearProgressIndicator(
              value: 0.94,
              minHeight: 6,
              backgroundColor: AppColors.border,
              valueColor:
                  AlwaysStoppedAnimation<Color>(AppColors.statusGreen),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total Leaves (Sem)', style: AppTextStyles.body),
              Text(_kLeave.totalLeaves, style: AppTextStyles.bodyMedium),
            ],
          ),
        ],
      ),
    );
  }

  // ── Leave details ──────────────────────────────────────────────────────────

  Widget _buildLeaveDetails() {
    return _SectionCard(
      title: '',
      showTitle: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _kLeave.categoryBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(_kLeave.category,
                    style: AppTextStyles.label.copyWith(
                        color: _kLeave.categoryColor, height: 1.4),
                    textAlign: TextAlign.center),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('LEAVE CATEGORY',
                        style: AppTextStyles.label),
                    const SizedBox(height: 4),
                    Text('Sick Leave', style: AppTextStyles.bodyMedium),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('SUBMISSION DATE',
                      style: AppTextStyles.label),
                  const SizedBox(height: 4),
                  Text(_kLeave.submittedDate,
                      style: AppTextStyles.caption, textAlign: TextAlign.right),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(color: AppColors.border),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('TARGET COURSE', style: AppTextStyles.label),
                    const SizedBox(height: 2),
                    Text(_kLeave.targetCourse,
                        style: AppTextStyles.bodyMedium),
                    Text(_kLeave.targetClass, style: AppTextStyles.caption),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('REQUESTED DATES', style: AppTextStyles.label),
                    const SizedBox(height: 2),
                    Text(_kLeave.requestedDates,
                        style: AppTextStyles.bodyMedium),
                    Text(_kLeave.totalWorkdays,
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

  // ── Reason ─────────────────────────────────────────────────────────────────

  Widget _buildReason() {
    return _SectionCard(
      title: 'Reason',
      child: Text(_kLeave.reason,
          style: AppTextStyles.body
              .copyWith(fontStyle: FontStyle.italic, height: 1.6)),
    );
  }

  // ── Attachment ─────────────────────────────────────────────────────────────

  Widget _buildAttachment() {
    return _SectionCard(
      title: 'Attachment',
      child: Container(
        width: double.infinity,
        height: 120,
        decoration: BoxDecoration(
          color: AppColors.statusGrayBg,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.border),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.picture_as_pdf_outlined,
                color: AppColors.statusRed, size: 36),
            SizedBox(height: 6),
            Text('Medical_Certificate.pdf',
                style: TextStyle(
                    color: AppColors.textSecondary, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  // ── Reviewer remarks ───────────────────────────────────────────────────────

  Widget _buildReviewerRemarks() {
    return _SectionCard(
      title: 'Reviewer Remarks',
      child: TextField(
        controller: _remarksController,
        maxLines: 4,
        decoration: const InputDecoration(
          hintText:
              'Add notes for the student or internal administration...',
          alignLabelWithHint: true,
        ),
      ),
    );
  }

  // ── Action buttons ─────────────────────────────────────────────────────────

  Widget _buildActionButtons() {
    final isDecided = _decision != null;
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: AppSpacing.buttonHeight,
          child: ElevatedButton.icon(
            onPressed: isDecided ? null : () => _decide('rejected'),
            icon: const Icon(Icons.close, size: 18),
            label: Text('Reject', style: AppTextStyles.button),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.statusRed,
              disabledBackgroundColor: AppColors.border,
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: AppSpacing.buttonHeight,
          child: ElevatedButton.icon(
            onPressed: isDecided ? null : () => _decide('approved'),
            icon: const Icon(Icons.check, size: 18),
            label: Text('Approve', style: AppTextStyles.button),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.statusGreen,
              disabledBackgroundColor: AppColors.border,
            ),
          ),
        ),
      ],
    );
  }
}

// ── Reusable widgets ───────────────────────────────────────────────────────────

class _SmallBadge extends StatelessWidget {
  const _SmallBadge(this.label, {required this.bg, required this.color});
  final String label;
  final Color bg, color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
          color: bg, borderRadius: BorderRadius.circular(AppSpacing.chipRadius)),
      child: Text(label,
          style:
              AppTextStyles.caption.copyWith(color: color, fontWeight: FontWeight.w600)),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child, this.showTitle = true});
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
            Text(title.toUpperCase(),
                style: AppTextStyles.label),
            const SizedBox(height: 12),
          ],
          child,
        ],
      ),
    );
  }
}
