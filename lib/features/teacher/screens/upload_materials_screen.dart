import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/providers/teacher_providers.dart';
import '../../../core/services/teacher_service.dart';

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
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Please enter a material title.',
            style: AppTextStyles.body.copyWith(color: Colors.white)),
        backgroundColor: AppColors.statusRed,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ));
      return;
    }
    // File picking requires a device file-picker plugin — placeholder UX only.
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('"${_titleController.text.trim()}" — select a file to upload.',
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
    final materialsAsync = ref.watch(courseMaterialsProvider(widget.courseId));
    final courseAsync = ref.watch(courseInfoProvider(widget.courseId));
    final course = courseAsync.valueOrNull;

    return Scaffold(
      backgroundColor: AppColors.bgPage,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(course?.name),
            const SizedBox(height: AppSpacing.md),
            _buildUploadZone(),
            const SizedBox(height: AppSpacing.md),
            _buildTitleField(),
            const SizedBox(height: AppSpacing.md),
            _buildUploadButton(),
            const SizedBox(height: AppSpacing.sectionGap),
            _buildMaterialsList(materialsAsync),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // ── Header ─────────────────────────────────────────────────────────────────

  Widget _buildHeader(String? courseName) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Course Materials', style: AppTextStyles.h1),
        if (courseName != null)
          Text(courseName,
              style: AppTextStyles.caption
                  .copyWith(color: AppColors.primaryNavy)),
      ],
    );
  }

  // ── Upload zone ────────────────────────────────────────────────────────────

  Widget _buildUploadZone() {
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
            Text('Drag and drop or tap to upload',
                style: AppTextStyles.bodyMedium, textAlign: TextAlign.center),
            const SizedBox(height: 4),
            Text('Supported formats: PDF, MP4, PPTX, DOCX\n(Max 100MB)',
                style: AppTextStyles.caption, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  // ── Title field ────────────────────────────────────────────────────────────

  Widget _buildTitleField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Material Title', style: AppTextStyles.caption),
        const SizedBox(height: 6),
        TextField(
          controller: _titleController,
          onChanged: (_) => setState(() {}),
          decoration: const InputDecoration(
            hintText: 'Enter title for this material...',
          ),
        ),
      ],
    );
  }

  // ── Upload button ──────────────────────────────────────────────────────────

  Widget _buildUploadButton() {
    return SizedBox(
      width: double.infinity,
      height: AppSpacing.buttonHeight,
      child: ElevatedButton.icon(
        onPressed: _upload,
        icon: const Icon(Icons.upload_outlined, size: 18),
        label: Text('Upload', style: AppTextStyles.button),
      ),
    );
  }

  // ── Materials list ─────────────────────────────────────────────────────────

  Widget _buildMaterialsList(
      AsyncValue<List<CourseMaterialItem>> materialsAsync) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Uploaded Materials', style: AppTextStyles.h2),
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
                child: Text('${list.length} Files',
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
                  Text('Could not load materials',
                      style: AppTextStyles.body),
                  TextButton(
                    onPressed: () => ref.invalidate(
                        courseMaterialsProvider(widget.courseId)),
                    child: const Text('Retry'),
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
                      child: Text('No materials uploaded yet.',
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
                          _MaterialRow(item: e.value),
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
  const _MaterialRow({required this.item});
  final CourseMaterialItem item;

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
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[d.month]} ${d.day}, ${d.year}';
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
