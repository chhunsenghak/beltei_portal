import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';

// ── Mock data ──────────────────────────────────────────────────────────────────

const _kCourses = [
  'International Relations - Semester 1',
  'Introduction to Computer Science (CS101)',
  'Data Structures & Algorithms (CS301)',
];

class _MaterialFile {
  const _MaterialFile({
    required this.name,
    required this.size,
    required this.date,
    required this.type,
  });
  final String name, size, date, type; // type: 'pdf', 'video', 'doc', 'pptx'
}

const _kLectureFiles = [
  _MaterialFile(name: 'Lecture_01_Intro_to_IR.pdf',            size: '2.4 MB',  date: 'Oct 12, 2023', type: 'pdf'),
  _MaterialFile(name: 'Historical_Perspective_Part2.mp4',      size: '45.8 MB', date: 'Oct 11, 2023', type: 'video'),
  _MaterialFile(name: 'Week_3_Reading_List.docx',              size: '124 KB',  date: 'Oct 10, 2023', type: 'doc'),
  _MaterialFile(name: 'Diplomatic_Theories_Presentation.pptx', size: '15.2 MB', date: 'Oct 08, 2023', type: 'pptx'),
];

const _kAssignmentFiles = [
  _MaterialFile(name: 'Assignment_1_Brief.pdf',   size: '1.1 MB', date: 'Oct 05, 2023', type: 'pdf'),
  _MaterialFile(name: 'Rubric_Assignment_2.docx', size: '88 KB',  date: 'Oct 01, 2023', type: 'doc'),
];

const _kResourceFiles = [
  _MaterialFile(name: 'Supplementary_Reading.pdf', size: '3.2 MB', date: 'Sep 28, 2023', type: 'pdf'),
];

// ── Screen ────────────────────────────────────────────────────────────────────

class UploadMaterialsScreen extends StatefulWidget {
  const UploadMaterialsScreen({super.key, required this.courseId});
  final String courseId;

  @override
  State<UploadMaterialsScreen> createState() => _UploadMaterialsScreenState();
}

class _UploadMaterialsScreenState extends State<UploadMaterialsScreen> {
  String _selectedCourse = _kCourses[0];
  int _selectedTab = 0; // 0=Lectures, 1=Assignments, 2=Resources
  final _titleController = TextEditingController();

  static const _tabs = ['Lectures', 'Assignments', 'Resources'];

  List<_MaterialFile> get _currentFiles {
    switch (_selectedTab) {
      case 1: return _kAssignmentFiles;
      case 2: return _kResourceFiles;
      default: return _kLectureFiles;
    }
  }

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
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('"${_titleController.text}" uploaded successfully.',
          style: AppTextStyles.body.copyWith(color: Colors.white)),
      backgroundColor: AppColors.statusGreen,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
    _titleController.clear();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCourseDropdown(),
            const SizedBox(height: AppSpacing.md),
            _buildTypeTabs(),
            const SizedBox(height: AppSpacing.sectionGap),
            _buildUploadZone(),
            const SizedBox(height: AppSpacing.md),
            _buildTitleField(),
            const SizedBox(height: AppSpacing.md),
            _buildUploadButton(),
            const SizedBox(height: AppSpacing.sectionGap),
            _buildRecentFiles(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // ── Course dropdown ────────────────────────────────────────────────────────

  Widget _buildCourseDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Select Course', style: AppTextStyles.caption),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: () => showModalBottomSheet(
            context: context,
            backgroundColor: AppColors.bgCard,
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
            builder: (_) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 16),
                ..._kCourses.map((c) => ListTile(
                      title: Text(c, style: AppTextStyles.body),
                      trailing: c == _selectedCourse
                          ? const Icon(Icons.check, color: AppColors.primaryNavy)
                          : null,
                      onTap: () {
                        setState(() => _selectedCourse = c);
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
              color: AppColors.bgCard,
              borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(_selectedCourse,
                      style: AppTextStyles.body,
                      overflow: TextOverflow.ellipsis),
                ),
                const Icon(Icons.keyboard_arrow_down,
                    color: AppColors.textLabel),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── Type tabs ──────────────────────────────────────────────────────────────

  Widget _buildTypeTabs() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(_tabs.length, (i) {
          final isActive = i == _selectedTab;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => setState(() => _selectedTab = i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: isActive ? AppColors.primaryNavy : AppColors.bgCard,
                  borderRadius: BorderRadius.circular(AppSpacing.chipRadius),
                  border: Border.all(
                    color: isActive
                        ? AppColors.primaryNavy
                        : AppColors.border,
                  ),
                ),
                child: Text(_tabs[i],
                    style: AppTextStyles.caption.copyWith(
                      color: isActive ? Colors.white : AppColors.textSecondary,
                      fontWeight:
                          isActive ? FontWeight.w600 : FontWeight.normal,
                    )),
              ),
            ),
          );
        }),
      ),
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
          border: Border.all(
            color: AppColors.border,
            width: 1.5,
          ),
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
              child: const Icon(Icons.cloud_upload_outlined,
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

  // ── Recently uploaded ──────────────────────────────────────────────────────

  Widget _buildRecentFiles() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Recently Uploaded (${_tabs[_selectedTab]})',
                style: AppTextStyles.h2),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.statusBlueBg,
                borderRadius: BorderRadius.circular(AppSpacing.chipRadius),
              ),
              child: Text('${_currentFiles.length} Files',
                  style: AppTextStyles.label
                      .copyWith(color: AppColors.primaryBlue)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: AppColors.bgCard,
            borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: _currentFiles.asMap().entries.map((e) {
              final isLast = e.key == _currentFiles.length - 1;
              return Column(
                children: [
                  _FileRow(file: e.value),
                  if (!isLast) const Divider(height: 1, color: AppColors.divider),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

// ── File row ───────────────────────────────────────────────────────────────────

class _FileRow extends StatelessWidget {
  const _FileRow({required this.file});
  final _MaterialFile file;

  IconData get _icon {
    switch (file.type) {
      case 'pdf':   return Icons.picture_as_pdf_outlined;
      case 'video': return Icons.play_circle_outline;
      case 'doc':   return Icons.description_outlined;
      default:      return Icons.slideshow_outlined;
    }
  }

  Color get _iconColor {
    switch (file.type) {
      case 'pdf':   return AppColors.statusRed;
      case 'video': return AppColors.primaryBlue;
      case 'doc':   return AppColors.statusAmber;
      default:      return AppColors.statusGreen;
    }
  }

  Color get _iconBg {
    switch (file.type) {
      case 'pdf':   return AppColors.statusRedBg;
      case 'video': return AppColors.statusBlueBg;
      case 'doc':   return AppColors.statusAmberBg;
      default:      return AppColors.statusGreenBg;
    }
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
                Text(file.name,
                    style: AppTextStyles.bodyMedium,
                    overflow: TextOverflow.ellipsis),
                Text('${file.size} • ${file.date}',
                    style: AppTextStyles.caption),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.more_vert,
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
