import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../l10n/app_localizations.dart';

// ── Screen ────────────────────────────────────────────────────────────────────

class CreateAssessmentScreen extends StatefulWidget {
  const CreateAssessmentScreen({super.key, required this.courseId});
  final String courseId;

  @override
  State<CreateAssessmentScreen> createState() => _CreateAssessmentScreenState();
}

class _CreateAssessmentScreenState extends State<CreateAssessmentScreen> {
  final _titleController   = TextEditingController();
  final _scoreController   = TextEditingController(text: '100');
  final _descController    = TextEditingController();
  String? _selectedType;
  DateTime? _dueDate;
  bool _submitted = false;

  List<String> _types(AppLocalizations l) => [
        l.courseDetailAssignmentLabel,
        l.createAssessmentTypeQuiz,
        l.createAssessmentTypeLabReport,
        l.createAssessmentTypeProject,
        l.courseDetailMidtermLabel,
        l.courseDetailFinalExamLabel,
      ];

  @override
  void dispose() {
    _titleController.dispose();
    _scoreController.dispose();
    _descController.dispose();
    super.dispose();
  }

  bool get _isValid =>
      _titleController.text.trim().isNotEmpty &&
      _selectedType != null &&
      _scoreController.text.trim().isNotEmpty;

  void _pickDueDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? now,
      firstDate: now,
      lastDate: DateTime(now.year + 2),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
            colorScheme:
                ColorScheme.light(primary: AppColors.primaryNavy)),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _dueDate = picked);
  }

  void _create(AppLocalizations l) {
    if (!_isValid) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(l.createAssessmentValidationError,
            style: AppTextStyles.body.copyWith(color: Colors.white)),
        backgroundColor: AppColors.statusRed,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ));
      return;
    }
    setState(() => _submitted = true);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    if (_submitted) return _buildSuccessScreen(context, l);

    return Scaffold(
      backgroundColor: AppColors.bgPage,
      appBar: _buildAppBar(context, l),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBreadcrumb(l),
            const SizedBox(height: AppSpacing.md),
            _buildFormCard(l),
            const SizedBox(height: AppSpacing.md),
            _buildQuickTip(l),
            const SizedBox(height: AppSpacing.md),
            _buildVisibilityCard(l),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // ── App bar ────────────────────────────────────────────────────────────────

  PreferredSizeWidget _buildAppBar(BuildContext context, AppLocalizations l) {
    return AppBar(
      backgroundColor: AppColors.bgPage,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, size: 18),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Text(l.createAssessmentTitle,
          style: AppTextStyles.h3.copyWith(color: AppColors.primaryNavy)),
      actions: [
        IconButton(
            icon: const Icon(Icons.notifications_outlined), onPressed: () {}),
      ],
    );
  }

  // ── Breadcrumb ─────────────────────────────────────────────────────────────

  Widget _buildBreadcrumb(AppLocalizations l) {
    return Row(
      children: [
        Text(l.navCourses, style: AppTextStyles.caption),
        Icon(Icons.chevron_right, size: 14, color: AppColors.textLabel),
        Text('Advanced Mathematics',
            style: AppTextStyles.caption),
        Icon(Icons.chevron_right, size: 14, color: AppColors.textLabel),
        Text(l.createAssessmentBreadcrumbNew,
            style: AppTextStyles.caption
                .copyWith(color: AppColors.primaryBlue, fontWeight: FontWeight.w600)),
      ],
    );
  }

  // ── Form card ──────────────────────────────────────────────────────────────

  Widget _buildFormCard(AppLocalizations l) {
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
          _buildFieldLabel(l.createAssessmentTitleFieldLabel),
          const SizedBox(height: 8),
          TextField(
            controller: _titleController,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: l.createAssessmentTitleHint,
            ),
          ),
          const SizedBox(height: 16),
          _buildFieldLabel(l.createAssessmentTypeFieldLabel),
          const SizedBox(height: 8),
          _buildTypeDropdown(l),
          const SizedBox(height: 16),
          _buildFieldLabel(l.createAssessmentMaxScoreFieldLabel),
          const SizedBox(height: 8),
          TextField(
            controller: _scoreController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(hintText: '100'),
          ),
          const SizedBox(height: 16),
          _buildFieldLabel(l.createAssessmentDueDateFieldLabel),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: _pickDueDate,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.bgPage,
                borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
                border: Border.all(
                  color: _dueDate != null ? AppColors.primaryNavy : AppColors.border,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _dueDate != null
                          ? '${_dueDate!.month.toString().padLeft(2,'0')}/${_dueDate!.day.toString().padLeft(2,'0')}/${_dueDate!.year}'
                          : l.createAssessmentDueDatePlaceholder,
                      style: AppTextStyles.body.copyWith(
                        color: _dueDate != null
                            ? AppColors.textPrimary
                            : AppColors.textLabel,
                      ),
                    ),
                  ),
                  Icon(Icons.calendar_today_outlined,
                      size: 18, color: AppColors.textLabel),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildFieldLabel(l.createAssessmentDescriptionFieldLabel),
          const SizedBox(height: 8),
          TextField(
            controller: _descController,
            maxLines: 6,
            decoration: InputDecoration(
              hintText: l.createAssessmentDescriptionHint,
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 16),
          _buildFieldLabel(l.createAssessmentAttachmentsFieldLabel),
          const SizedBox(height: 8),
          _buildAttachmentZone(l),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: AppSpacing.buttonHeight,
            child: AnimatedOpacity(
              opacity: _isValid ? 1.0 : 0.5,
              duration: const Duration(milliseconds: 200),
              child: ElevatedButton.icon(
                onPressed: () => _create(l),
                icon: const Icon(Icons.send_outlined, size: 18),
                label: Text(l.createAssessmentTitle, style: AppTextStyles.button),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Text(label,
        style: AppTextStyles.body
            .copyWith(fontWeight: FontWeight.w600));
  }

  Widget _buildTypeDropdown(AppLocalizations l) {
    final types = _types(l);
    return GestureDetector(
      onTap: () => showModalBottomSheet(
        context: context,
        backgroundColor: AppColors.bgCard,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        builder: (_) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            ...types.map((t) => ListTile(
                  title: Text(t, style: AppTextStyles.body),
                  trailing: t == _selectedType
                      ? Icon(Icons.check, color: AppColors.primaryNavy)
                      : null,
                  onTap: () {
                    setState(() => _selectedType = t);
                    Navigator.pop(context);
                  },
                )),
            const SizedBox(height: 16),
          ],
        ),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.bgPage,
          borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
          border: Border.all(
            color: _selectedType != null ? AppColors.primaryNavy : AppColors.border,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                _selectedType ?? l.createAssessmentSelectTypeHint,
                style: AppTextStyles.body.copyWith(
                  color: _selectedType != null ? AppColors.textPrimary : AppColors.textLabel,
                ),
              ),
            ),
            Icon(Icons.keyboard_arrow_down, color: AppColors.textLabel),
          ],
        ),
      ),
    );
  }

  Widget _buildAttachmentZone(AppLocalizations l) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 28),
        decoration: BoxDecoration(
          color: AppColors.bgPage,
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          border: Border.all(color: AppColors.border, width: 1.5),
        ),
        child: Column(
          children: [
            Icon(Icons.cloud_upload_outlined,
                color: AppColors.textLabel, size: 32),
            const SizedBox(height: 8),
            Text(l.createAssessmentUploadZoneTitle,
                style: AppTextStyles.body
                    .copyWith(color: AppColors.textSecondary),
                textAlign: TextAlign.center),
            const SizedBox(height: 4),
            Text(l.createAssessmentUploadZoneSubtitle,
                style: AppTextStyles.caption, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  // ── Quick tip ──────────────────────────────────────────────────────────────

  Widget _buildQuickTip(AppLocalizations l) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(
            color: AppColors.primaryBlue.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.lightbulb_outline,
              color: AppColors.primaryBlue, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l.createAssessmentQuickTipTitle,
                    style: AppTextStyles.bodyMedium
                        .copyWith(color: AppColors.primaryBlue)),
                const SizedBox(height: 4),
                Text(
                  l.createAssessmentQuickTipBody,
                  style: AppTextStyles.caption.copyWith(height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Visibility card ────────────────────────────────────────────────────────

  Widget _buildVisibilityCard(AppLocalizations l) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.visibility_outlined,
              color: AppColors.textSecondary, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l.createAssessmentVisibilityTitle, style: AppTextStyles.bodyMedium),
                const SizedBox(height: 4),
                Text(
                    l.createAssessmentVisibilityBody,
                    style: AppTextStyles.caption.copyWith(height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Success screen ─────────────────────────────────────────────────────────

  Widget _buildSuccessScreen(BuildContext context, AppLocalizations l) {
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
              Text(l.createAssessmentSuccessTitle, style: AppTextStyles.h1, textAlign: TextAlign.center),
              const SizedBox(height: 8),
              Text(
                l.createAssessmentSuccessMessage(_titleController.text),
                style: AppTextStyles.body.copyWith(
                    color: AppColors.textSecondary, height: 1.5),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: AppSpacing.buttonHeight,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(l.createAssessmentBackToCourseButton, style: AppTextStyles.button),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
