import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/student_providers.dart';

enum _LeaveType { medical, personal, family, other }

// ── Screen ────────────────────────────────────────────────────────────────────

class CreateLeaveRequestScreen extends ConsumerStatefulWidget {
  const CreateLeaveRequestScreen({super.key});

  @override
  ConsumerState<CreateLeaveRequestScreen> createState() =>
      _CreateLeaveRequestScreenState();
}

class _CreateLeaveRequestScreenState
    extends ConsumerState<CreateLeaveRequestScreen> {
  _LeaveType? _leaveType;
  final _reasonController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isSubmitting = false;
  bool _submitted = false;

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  // ── Computed ───────────────────────────────────────────────────────────────

  int get _totalDays {
    if (_startDate == null || _endDate == null) return 0;
    return _endDate!.difference(_startDate!).inDays + 1;
  }

  bool get _isValid =>
      _leaveType != null &&
      _startDate != null &&
      _endDate != null &&
      _reasonController.text.trim().isNotEmpty;

  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  String _isoDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  // ── Actions ────────────────────────────────────────────────────────────────

  Future<void> _pickDate(bool isStart) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart
          ? (_startDate ?? now)
          : (_endDate ?? _startDate ?? now),
      firstDate: now,
      lastDate: DateTime(now.year + 1),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: ColorScheme.light(
              primary: AppColors.primaryNavy),
        ),
        child: child!,
      ),
    );
    if (picked == null) return;
    setState(() {
      if (isStart) {
        _startDate = picked;
        if (_endDate != null && _endDate!.isBefore(picked)) {
          _endDate = picked;
        }
      } else {
        _endDate = picked;
      }
    });
  }

  Future<void> _submit() async {
    if (!_isValid) {
      _showSnackBar('Please fill in all required fields.',
          isError: true);
      return;
    }

    final user = ref.read(currentUserProvider).valueOrNull;
    if (user == null) {
      _showSnackBar('Session expired. Please log in again.',
          isError: true);
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      await ref.read(studentServiceProvider).createLeaveRequest(
            studentId: user.id,
            type: _leaveType!.name.capitalize,
            reason: _reasonController.text.trim(),
            startDate: _isoDate(_startDate!),
            endDate: _isoDate(_endDate!),
          );
      ref.invalidate(studentLeaveRequestsProvider);
      if (mounted) setState(() => _submitted = true);
    } catch (e) {
      if (mounted) {
        _showSnackBar('Failed to submit request. Please try again.',
            isError: true);
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message,
            style: AppTextStyles.body.copyWith(color: Colors.white)),
        backgroundColor:
            isError ? AppColors.statusRed : AppColors.statusGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  // ── build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    if (_submitted) return _buildSuccessScreen();

    return Scaffold(
      backgroundColor: AppColors.bgPage,
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPolicyBanner(),
            const SizedBox(height: AppSpacing.sectionGap),
            _buildLeaveTypeGrid(),
            const SizedBox(height: AppSpacing.sectionGap),
            _buildDateFields(),
            if (_startDate != null && _endDate != null) ...[
              const SizedBox(height: 8),
              _buildDurationChip(),
            ],
            const SizedBox(height: AppSpacing.sectionGap),
            _buildReasonField(),
            const SizedBox(height: AppSpacing.sectionGap),
            _buildAttachmentArea(),
            const SizedBox(height: AppSpacing.xl),
            _buildSubmitButton(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.bgPage,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, size: 18),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Text('New Leave Request', style: AppTextStyles.h3),
    );
  }

  Widget _buildPolicyBanner() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.primaryNavy,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, color: Colors.white, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Academic Policy', style: AppTextStyles.h3White),
                const SizedBox(height: 4),
                Text(
                  'Submit leave requests at least 24 hours in advance, except for medical emergencies.',
                  style: AppTextStyles.bodyWhite.copyWith(height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaveTypeGrid() {
    final types = [
      (type: _LeaveType.medical,  icon: Icons.local_hospital_outlined,   label: 'Medical'),
      (type: _LeaveType.personal, icon: Icons.person_outline,            label: 'Personal'),
      (type: _LeaveType.family,   icon: Icons.family_restroom_outlined,  label: 'Family'),
      (type: _LeaveType.other,    icon: Icons.more_horiz,                label: 'Other'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('LEAVE TYPE', style: AppTextStyles.label),
        const SizedBox(height: 8),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 2.2,
          children: types.map((t) {
            final isSelected = _leaveType == t.type;
            return GestureDetector(
              onTap: () => setState(() => _leaveType = t.type),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primaryNavy.withValues(alpha: 0.08)
                      : AppColors.bgCard,
                  borderRadius:
                      BorderRadius.circular(AppSpacing.cardRadius),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primaryNavy
                        : AppColors.border,
                    width: isSelected ? 1.5 : 1,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(t.icon,
                        color: isSelected
                            ? AppColors.primaryNavy
                            : AppColors.textSecondary,
                        size: 22),
                    const SizedBox(height: 4),
                    Text(t.label,
                        style: AppTextStyles.caption.copyWith(
                            color: isSelected
                                ? AppColors.primaryNavy
                                : AppColors.textSecondary,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.normal)),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDateFields() {
    return Column(
      children: [
        _buildDateTile('START DATE', _startDate, () => _pickDate(true)),
        const SizedBox(height: 12),
        _buildDateTile('END DATE', _endDate, () => _pickDate(false)),
      ],
    );
  }

  Widget _buildDateTile(String label, DateTime? date, VoidCallback onTap) {
    final hasValue = date != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.label),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.bgCard,
              borderRadius:
                  BorderRadius.circular(AppSpacing.inputRadius),
              border: Border.all(
                color: hasValue
                    ? AppColors.primaryNavy
                    : AppColors.border,
                width: hasValue ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    date != null ? _formatDate(date) : 'dd/mm/yyyy',
                    style: AppTextStyles.body.copyWith(
                      color: hasValue
                          ? AppColors.textPrimary
                          : AppColors.textLabel,
                    ),
                  ),
                ),
                Icon(Icons.calendar_today_outlined,
                    color: hasValue
                        ? AppColors.primaryNavy
                        : AppColors.textLabel,
                    size: 18),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDurationChip() {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.statusBlueBg,
        borderRadius: BorderRadius.circular(AppSpacing.chipRadius),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.schedule,
              color: AppColors.primaryBlue, size: 14),
          const SizedBox(width: 6),
          Text(
            'Duration: $_totalDays day${_totalDays == 1 ? '' : 's'}',
            style: AppTextStyles.caption.copyWith(
                color: AppColors.primaryBlue,
                fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildReasonField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('REASON FOR LEAVE', style: AppTextStyles.label),
        const SizedBox(height: 8),
        TextField(
          controller: _reasonController,
          maxLines: 5,
          onChanged: (_) => setState(() {}),
          decoration: const InputDecoration(
            hintText:
                'Briefly describe why you are requesting leave...',
            alignLabelWithHint: true,
          ),
        ),
        const SizedBox(height: 4),
        Align(
          alignment: Alignment.centerRight,
          child: Text('${_reasonController.text.length} chars',
              style: AppTextStyles.caption),
        ),
      ],
    );
  }

  Widget _buildAttachmentArea() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('ATTACHMENTS (OPTIONAL)', style: AppTextStyles.label),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 28),
          decoration: BoxDecoration(
            color: AppColors.bgCard,
            borderRadius:
                BorderRadius.circular(AppSpacing.cardRadius),
            border:
                Border.all(color: AppColors.border, width: 1.5),
          ),
          child: Column(
            children: [
              Icon(Icons.cloud_upload_outlined,
                  color: AppColors.textLabel, size: 32),
              const SizedBox(height: 8),
              Text(
                'Tap to upload medical certificates or letters',
                style: AppTextStyles.body
                    .copyWith(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return AnimatedOpacity(
      opacity: _isValid ? 1.0 : 0.5,
      duration: const Duration(milliseconds: 200),
      child: SizedBox(
        width: double.infinity,
        height: AppSpacing.buttonHeight,
        child: ElevatedButton.icon(
          onPressed: _isSubmitting ? null : _submit,
          icon: _isSubmitting
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white),
                )
              : const Icon(Icons.send_outlined, size: 18),
          label: Text(
              _isSubmitting ? 'Submitting...' : 'Submit Request',
              style: AppTextStyles.button),
        ),
      ),
    );
  }

  // ── Success screen ─────────────────────────────────────────────────────────

  Widget _buildSuccessScreen() {
    final leaveLabel = _leaveType?.name.capitalize ?? '';
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.statusGreenBg,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.check_circle_outline,
                    color: AppColors.statusGreen, size: 44),
              ),
              const SizedBox(height: 24),
              Text('Request Submitted!',
                  style: AppTextStyles.h1,
                  textAlign: TextAlign.center),
              const SizedBox(height: 12),
              Text(
                'Your $leaveLabel leave request has been submitted and is pending review.',
                style: AppTextStyles.body.copyWith(
                    color: AppColors.textSecondary, height: 1.6),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),
              _buildSummaryCard(leaveLabel),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: AppSpacing.buttonHeight,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Back to Leave Requests',
                      style: AppTextStyles.button),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard(String leaveLabel) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          _summaryRow('Type', '$leaveLabel Leave'),
          Divider(color: AppColors.divider, height: 20),
          _summaryRow('Period',
              '${_formatDate(_startDate!)} → ${_formatDate(_endDate!)}'),
          Divider(color: AppColors.divider, height: 20),
          _summaryRow('Duration',
              '$_totalDays day${_totalDays == 1 ? '' : 's'}'),
          Divider(color: AppColors.divider, height: 20),
          _summaryRow('Status', 'Pending Review'),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: AppTextStyles.body
                .copyWith(color: AppColors.textSecondary)),
        Flexible(
          child: Text(value,
              style: AppTextStyles.bodyMedium,
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis),
        ),
      ],
    );
  }
}

// ── Extension ──────────────────────────────────────────────────────────────────

extension _StringExt on String {
  String get capitalize =>
      isEmpty ? '' : '${this[0].toUpperCase()}${substring(1)}';
}
