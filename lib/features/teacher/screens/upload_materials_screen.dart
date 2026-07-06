import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/providers/teacher_providers.dart';
import '../../../core/services/teacher_service.dart';
import '../../../l10n/app_localizations.dart';

// ── Screen ────────────────────────────────────────────────────────────────────

class UploadMaterialsScreen extends ConsumerStatefulWidget {
  const UploadMaterialsScreen({super.key, required this.courseId});
  final String courseId;

  @override
  ConsumerState<UploadMaterialsScreen> createState() =>
      _UploadMaterialsScreenState();
}

class _UploadMaterialsScreenState
    extends ConsumerState<UploadMaterialsScreen> {
  final _titleController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  void _upload() {
    final l = AppLocalizations.of(context)!;
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(l.uploadMaterialsValidationError,
            style: AppTextStyles.body.copyWith(color: Colors.white)),
        backgroundColor: AppColors.statusRed,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ));
      return;
    }
    // File picking requires a device file-picker plugin — placeholder UX only.
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
          l.uploadMaterialsFilePlaceholderSnackbar(_titleController.text.trim()),
          style: AppTextStyles.body.copyWith(color: Colors.white)),
      backgroundColor: AppColors.primaryNavy,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
    _titleController.clear();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final courseAsync = ref.watch(courseInfoProvider(widget.courseId));
    final course = courseAsync.valueOrNull;
    // widget.courseId is a class_term_course id; materials live on the
    // catalog course, so resolve the real course id via the teaching
    // assignment before looking materials up.
    final materialsAsync = course != null
        ? ref.watch(courseMaterialsProvider(course.courseId))
        : const AsyncValue<List<CourseMaterialItem>>.loading();

    return Scaffold(
      backgroundColor: AppColors.bgPage,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(course?.name, l),
            const SizedBox(height: AppSpacing.md),
            _buildUploadZone(l),
            const SizedBox(height: AppSpacing.md),
            _buildTitleField(l),
            const SizedBox(height: AppSpacing.md),
            _buildUploadButton(l),
            const SizedBox(height: AppSpacing.sectionGap),
            _buildMaterialsList(materialsAsync, l),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // ── Header ─────────────────────────────────────────────────────────────────

  Widget _buildHeader(String? courseName, AppLocalizations l) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            IconButton(
              icon: Icon(Icons.arrow_back_ios, size: 20, color: AppColors.primaryNavy),
              onPressed: () => Navigator.of(context).pop(),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
            const SizedBox(width: 8),
            Text(l.courseDetailMaterialsTitle, style: AppTextStyles.h1),
          ],
        ),
        const SizedBox(height: 6),
        if (courseName != null)
          Text(courseName,
              style: AppTextStyles.caption
                  .copyWith(color: AppColors.primaryNavy)),
      ],
    );
  }

  // ── Upload zone ────────────────────────────────────────────────────────────

  Widget _buildUploadZone(AppLocalizations l) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 40),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          border: Border.all(color: AppColors.border, width: 1.5),
        ),
        child: Column(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.cloud_upload_outlined,
                  color: AppColors.primaryBlue, size: 28),
            ),
            const SizedBox(height: 12),
            Text(l.uploadMaterialsDropzoneText,
                style: AppTextStyles.bodyMedium, textAlign: TextAlign.center),
            const SizedBox(height: 4),
            Text(l.uploadMaterialsSupportedFormatsText,
                style: AppTextStyles.caption, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  // ── Title field ────────────────────────────────────────────────────────────

  Widget _buildTitleField(AppLocalizations l) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l.uploadMaterialsTitleFieldLabel, style: AppTextStyles.caption),
        const SizedBox(height: 6),
        TextField(
          controller: _titleController,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            hintText: l.uploadMaterialsTitleHint,
          ),
        ),
      ],
    );
  }

  // ── Upload button ──────────────────────────────────────────────────────────

  Widget _buildUploadButton(AppLocalizations l) {
    return SizedBox(
      width: double.infinity,
      height: AppSpacing.buttonHeight,
      child: ElevatedButton.icon(
        onPressed: _upload,
        icon: const Icon(Icons.upload_outlined, size: 18),
        label: Text(l.uploadMaterialsUploadButton, style: AppTextStyles.button),
      ),
    );
  }

  // ── Materials list ─────────────────────────────────────────────────────────

  Widget _buildMaterialsList(
      AsyncValue<List<CourseMaterialItem>> materialsAsync, AppLocalizations l) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(l.uploadMaterialsListTitle, style: AppTextStyles.h2),
            materialsAsync.when(
              loading: () => const SizedBox.shrink(),
              error: (_, _) => const SizedBox.shrink(),
              data: (list) => Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.statusBlueBg,
                  borderRadius:
                      BorderRadius.circular(AppSpacing.chipRadius),
                ),
                child: Text(l.courseDetailFilesCountValue(list.length),
                    style: AppTextStyles.label
                        .copyWith(color: AppColors.primaryBlue)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        materialsAsync.when(
          loading: () =>
              const Center(child: CircularProgressIndicator()),
          error: (e, _) => Container(
            padding: const EdgeInsets.all(AppSpacing.cardPadding),
            decoration: BoxDecoration(
              color: AppColors.bgCard,
              borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
              border: Border.all(color: AppColors.border),
            ),
            child: Center(
              child: Column(
                children: [
                  Icon(Icons.error_outline,
                      color: AppColors.statusRed),
                  const SizedBox(height: 8),
                  Text(l.courseDetailMaterialsLoadError,
                      style: AppTextStyles.body),
                  TextButton(
                    onPressed: () {
                      final c = ref.read(courseInfoProvider(widget.courseId)).valueOrNull;
                      if (c != null) ref.invalidate(courseMaterialsProvider(c.courseId));
                    },
                    child: Text(l.retry),
                  ),
                ],
              ),
            ),
          ),
          data: (materials) => materials.isEmpty
              ? Container(
                  padding: const EdgeInsets.all(AppSpacing.cardPadding),
                  decoration: BoxDecoration(
                    color: AppColors.bgCard,
                    borderRadius:
                        BorderRadius.circular(AppSpacing.cardRadius),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Text(l.courseDetailNoMaterialsUploaded,
                          style: AppTextStyles.body.copyWith(
                              color: AppColors.textSecondary)),
                    ),
                  ),
                )
              : Container(
                  decoration: BoxDecoration(
                    color: AppColors.bgCard,
                    borderRadius:
                        BorderRadius.circular(AppSpacing.cardRadius),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    children: materials.asMap().entries.map((e) {
                      final isLast = e.key == materials.length - 1;
                      return Column(
                        children: [
                          _MaterialRow(item: e.value, locale: l.localeName),
                          if (!isLast)
                            Divider(
                                height: 1, color: AppColors.divider),
                        ],
                      );
                    }).toList(),
                  ),
                ),
        ),
      ],
    );
  }
}

// ── Material row ───────────────────────────────────────────────────────────────

class _MaterialRow extends StatelessWidget {
  const _MaterialRow({required this.item, required this.locale});
  final CourseMaterialItem item;
  final String locale;

  IconData get _icon {
    final t = (item.fileType ?? '').toLowerCase();
    if (t.contains('pdf')) return Icons.picture_as_pdf_outlined;
    if (t.contains('video') || t.contains('mp4')) return Icons.play_circle_outline;
    if (t.contains('doc')) return Icons.description_outlined;
    return Icons.slideshow_outlined;
  }

  Color get _iconColor {
    final t = (item.fileType ?? '').toLowerCase();
    if (t.contains('pdf')) return AppColors.statusRed;
    if (t.contains('video') || t.contains('mp4')) return AppColors.primaryBlue;
    if (t.contains('doc')) return AppColors.statusAmber;
    return AppColors.statusGreen;
  }

  Color get _iconBg {
    final t = (item.fileType ?? '').toLowerCase();
    if (t.contains('pdf')) return AppColors.statusRedBg;
    if (t.contains('video') || t.contains('mp4')) return AppColors.statusBlueBg;
    if (t.contains('doc')) return AppColors.statusAmberBg;
    return AppColors.statusGreenBg;
  }

  String get _dateLabel {
    final d = item.uploadedAt;
    if (d == null) return '';
    return DateFormat.yMMMd(locale).format(d);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _iconBg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(_icon, color: _iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title,
                    style: AppTextStyles.bodyMedium,
                    overflow: TextOverflow.ellipsis),
                Text(
                  [
                    if (item.sizeLabel.isNotEmpty) item.sizeLabel,
                    if (_dateLabel.isNotEmpty) _dateLabel,
                  ].join(' • '),
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.more_vert,
                color: AppColors.textLabel, size: 18),
            onPressed: () {},
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}
