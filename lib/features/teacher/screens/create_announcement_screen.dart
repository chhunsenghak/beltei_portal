import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/teacher_providers.dart';
import '../../../l10n/app_localizations.dart';

// ── Screen ────────────────────────────────────────────────────────────────────

class CreateAnnouncementScreen extends ConsumerStatefulWidget {
  const CreateAnnouncementScreen({super.key});

  @override
  ConsumerState<CreateAnnouncementScreen> createState() =>
      _CreateAnnouncementScreenState();
}

class _CreateAnnouncementScreenState
    extends ConsumerState<CreateAnnouncementScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  bool _allStudents = true;
  bool _sendEmail = true;
  bool _pushNotif = true;
  bool _posted = false;
  bool _posting = false;
  String? _postedTitle;

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  bool get _isValid =>
      _titleController.text.trim().isNotEmpty &&
      _contentController.text.trim().isNotEmpty;

  Future<void> _post() async {
    final l = AppLocalizations.of(context)!;
    if (!_isValid) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(l.createAnnouncementValidationError,
            style: AppTextStyles.body.copyWith(color: Colors.white)),
        backgroundColor: AppColors.statusRed,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ));
      return;
    }
    setState(() => _posting = true);
    try {
      final user = ref.read(currentUserProvider).valueOrNull;
      if (user == null) return;
      await ref.read(teacherServiceProvider).createAnnouncement(
            teacherId: user.id,
            title: _titleController.text.trim(),
            body: _contentController.text.trim(),
          );
      if (mounted) {
        setState(() {
          _postedTitle = _titleController.text.trim();
          _posted = true;
        });
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(l.createAnnouncementPostError,
              style: AppTextStyles.body.copyWith(color: Colors.white)),
          backgroundColor: AppColors.statusRed,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ));
      }
    } finally {
      if (mounted) setState(() => _posting = false);
    }
  }

  void _saveDraft() {
    final l = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(l.createAnnouncementDraftSavedSnackbar,
          style: AppTextStyles.body.copyWith(color: Colors.white)),
      backgroundColor: AppColors.primaryNavy,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    if (_posted) return _buildSuccessScreen(context, l);

    return Scaffold(
      backgroundColor: AppColors.bgPage,
      appBar: _buildAppBar(context, l),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTitle(l),
            const SizedBox(height: AppSpacing.sectionGap),
            _buildCompositionCard(l),
            const SizedBox(height: AppSpacing.sectionGap),
            _buildPublicationSettings(l),
            const SizedBox(height: AppSpacing.sectionGap),
            _buildLivePreviewCard(l),
            const SizedBox(height: AppSpacing.xl),
            _buildPostButton(l),
            const SizedBox(height: 12),
            _buildDraftButton(l),
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
      toolbarHeight: 64,
      titleSpacing: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, size: 18),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Row(
        children: [
          Image.asset('assets/images/beltei_logo.png',
              height: 48, fit: BoxFit.contain),
          const SizedBox(width: 10),
          Text(l.appTitle, style: AppTextStyles.h3),
        ],
      ),
      actions: [
        IconButton(
            icon: const Icon(Icons.notifications_outlined), onPressed: () {}),
      ],
    );
  }

  // ── Title ──────────────────────────────────────────────────────────────────

  Widget _buildTitle(AppLocalizations l) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l.createAnnouncementTitle, style: AppTextStyles.h1),
        Text(l.createAnnouncementSubtitle,
            style: AppTextStyles.caption.copyWith(height: 1.4)),
      ],
    );
  }

  // ── Composition card ───────────────────────────────────────────────────────

  Widget _buildCompositionCard(AppLocalizations l) {
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
          Text(l.createAnnouncementTitleFieldLabel, style: AppTextStyles.label),
          const SizedBox(height: 8),
          TextField(
            controller: _titleController,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: l.createAnnouncementTitleHint,
            ),
          ),
          const SizedBox(height: 16),
          Text(l.createAnnouncementContentLabel, style: AppTextStyles.label),
          const SizedBox(height: 8),
          _buildFormattingToolbar(),
          const SizedBox(height: 4),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.border),
              borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(AppSpacing.inputRadius)),
            ),
            child: TextField(
              controller: _contentController,
              maxLines: 8,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: l.createAnnouncementContentHint,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(12),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              TextButton.icon(
                onPressed: () {},
                icon: Icon(Icons.attach_file,
                    size: 16, color: AppColors.primaryNavy),
                label: Text(l.createAnnouncementAttachFilesButton,
                    style: AppTextStyles.link.copyWith(fontSize: 13)),
              ),
              const SizedBox(width: 16),
              TextButton.icon(
                onPressed: () {},
                icon: Icon(Icons.schedule_outlined,
                    size: 16, color: AppColors.primaryNavy),
                label: Text(l.createAnnouncementScheduleButton,
                    style: AppTextStyles.link.copyWith(fontSize: 13)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFormattingToolbar() {
    const icons = [
      Icons.format_bold,
      Icons.format_italic,
      Icons.format_underlined,
      Icons.format_list_bulleted,
      Icons.format_list_numbered,
      Icons.link_outlined,
      Icons.image_outlined,
    ];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.bgPage,
        border: Border.all(color: AppColors.border),
        borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppSpacing.inputRadius)),
      ),
      child: Row(
        children: icons
            .map((ic) => Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: IconButton(
                    icon: Icon(ic, size: 18, color: AppColors.textSecondary),
                    onPressed: () {},
                    padding: const EdgeInsets.all(4),
                    constraints: const BoxConstraints(),
                  ),
                ))
            .toList(),
      ),
    );
  }

  // ── Publication settings ───────────────────────────────────────────────────

  Widget _buildPublicationSettings(AppLocalizations l) {
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
          Text(l.createAnnouncementPublicationSettingsTitle,
              style: AppTextStyles.h2.copyWith(color: AppColors.primaryNavy)),
          const SizedBox(height: 14),
          Text(l.createAnnouncementRecipientScopeLabel, style: AppTextStyles.label),
          const SizedBox(height: 10),
          _buildScopeButtons(l),
          const SizedBox(height: 14),
          _buildToggleRow(l.createAnnouncementSendEmailLabel, _sendEmail,
              (val) => setState(() => _sendEmail = val)),
          const SizedBox(height: 10),
          _buildToggleRow(l.createAnnouncementPushNotifLabel, _pushNotif,
              (val) => setState(() => _pushNotif = val)),
        ],
      ),
    );
  }

  Widget _buildScopeButtons(AppLocalizations l) {
    return Row(
      children: [
        _ScopeChip(
          label: l.createAnnouncementAllStudentsChip,
          icon: Icons.public,
          selected: _allStudents,
          onTap: () => setState(() => _allStudents = true),
        ),
        const SizedBox(width: 10),
        _ScopeChip(
          label: l.createAnnouncementSpecificCourseChip,
          icon: Icons.menu_book_outlined,
          selected: !_allStudents,
          onTap: () => setState(() => _allStudents = false),
        ),
      ],
    );
  }

  Widget _buildToggleRow(
      String label, bool value, ValueChanged<bool> onChanged) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.body),
        Switch(
          value: value,
          onChanged: onChanged,
          activeThumbColor: AppColors.primaryNavy,
        ),
      ],
    );
  }

  // ── Live preview card ──────────────────────────────────────────────────────

  Widget _buildLivePreviewCard(AppLocalizations l) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.bgPage,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(color: AppColors.border, width: 1.5),
      ),
      child: Column(
        children: [
          Icon(Icons.visibility_outlined,
              color: AppColors.textSecondary, size: 28),
          const SizedBox(height: 8),
          Text(l.createAnnouncementLivePreviewTitle, style: AppTextStyles.h2),
          const SizedBox(height: 4),
          Text(
            l.createAnnouncementLivePreviewSubtitle,
            style: AppTextStyles.caption.copyWith(height: 1.4),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {},
              child: Text(l.createAnnouncementPreviewAsStudentButton,
                  style: AppTextStyles.button
                      .copyWith(color: AppColors.primaryNavy)),
            ),
          ),
        ],
      ),
    );
  }

  // ── Post button ────────────────────────────────────────────────────────────

  Widget _buildPostButton(AppLocalizations l) {
    return AnimatedOpacity(
      opacity: _isValid ? 1.0 : 0.5,
      duration: const Duration(milliseconds: 200),
      child: SizedBox(
        width: double.infinity,
        height: AppSpacing.buttonHeight,
        child: ElevatedButton.icon(
          onPressed: _posting ? null : _post,
          icon: _posting
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white),
                )
              : const Icon(Icons.send_outlined, size: 18),
          label: Text(l.createAnnouncementPostButton, style: AppTextStyles.button),
        ),
      ),
    );
  }

  Widget _buildDraftButton(AppLocalizations l) {
    return SizedBox(
      width: double.infinity,
      child: TextButton(
        onPressed: _saveDraft,
        child: Text(l.createAnnouncementSaveDraftButton,
            style:
                AppTextStyles.body.copyWith(color: AppColors.textSecondary)),
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
              Text(l.createAnnouncementSuccessTitle,
                  style: AppTextStyles.h1, textAlign: TextAlign.center),
              const SizedBox(height: 8),
              Text(
                l.createAnnouncementSuccessMessage(_postedTitle ?? ''),
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
                  child: Text(l.done, style: AppTextStyles.button),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Scope chip ─────────────────────────────────────────────────────────────────

class _ScopeChip extends StatelessWidget {
  const _ScopeChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryNavy : AppColors.bgCard,
          borderRadius: BorderRadius.circular(AppSpacing.chipRadius),
          border: Border.all(
            color: selected ? AppColors.primaryNavy : AppColors.border,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                size: 14,
                color: selected ? Colors.white : AppColors.textSecondary),
            const SizedBox(width: 6),
            Text(label,
                style: AppTextStyles.caption.copyWith(
                  color: selected ? Colors.white : AppColors.textSecondary,
                  fontWeight:
                      selected ? FontWeight.w600 : FontWeight.normal,
                )),
          ],
        ),
      ),
    );
  }
}
