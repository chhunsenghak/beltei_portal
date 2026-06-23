import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../shared/widgets/beltei_app_bar.dart';

// ── Mock data ──────────────────────────────────────────────────────────────────

const _kCourses = [
  'Business Communication - Sec A',
  'Introduction to Computer Science (CS101)',
  'Data Structures & Algorithms (CS301)',
];

class _GradeEntry {
  _GradeEntry({required this.id, required this.name, required this.studentId,
      required this.score, required this.graded});
  final String id, name, studentId;
  String score;
  bool graded;
}

final _kEntries = [
  _GradeEntry(id: 'g1', name: 'Alex Rivera',    studentId: 'ID: BEL-2023-0142', score: '85', graded: true),
  _GradeEntry(id: 'g2', name: 'Sarah Mitchell', studentId: 'ID: BEL-2023-0891', score: '92', graded: true),
  _GradeEntry(id: 'g3', name: 'Daniel Chen',    studentId: 'ID: BEL-2023-1102', score: '--', graded: false),
  _GradeEntry(id: 'g4', name: 'Maya Thompson',  studentId: 'ID: BEL-2023-0456', score: '78', graded: true),
  _GradeEntry(id: 'g5', name: 'James Walker',   studentId: 'ID: BEL-2023-0233', score: '90', graded: true),
];

// ── Screen ────────────────────────────────────────────────────────────────────

class GradeManagementScreen extends StatefulWidget {
  const GradeManagementScreen({super.key, required this.courseId});
  final String courseId;

  @override
  State<GradeManagementScreen> createState() => _GradeManagementScreenState();
}

class _GradeManagementScreenState extends State<GradeManagementScreen> {
  String _selectedCourse = _kCourses[0];
  int _selectedTab = 0; // 0=Assignment, 1=Quiz, 2=Lab, 3=Project
  bool _published = false;

  final _tabs = ['Assignment', 'Quiz', 'Lab', 'Project'];

  late final List<_GradeEntry> _entries = _kEntries
      .map((e) => _GradeEntry(
            id: e.id,
            name: e.name,
            studentId: e.studentId,
            score: e.score,
            graded: e.graded,
          ))
      .toList();

  late final Map<String, TextEditingController> _controllers = {
    for (final e in _entries)
      e.id: TextEditingController(text: e.score == '--' ? '' : e.score),
  };

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _publishGrades() {
    setState(() => _published = true);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Grades published successfully.',
            style: AppTextStyles.body.copyWith(color: Colors.white)),
        backgroundColor: AppColors.statusGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      appBar: BelteiAppBar(showNotification: true),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.screenPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTitle(),
                  const SizedBox(height: AppSpacing.md),
                  _buildCourseDropdown(),
                  const SizedBox(height: AppSpacing.md),
                  _buildTypeTabs(),
                  const SizedBox(height: 12),
                  _buildToolbar(),
                  const SizedBox(height: 8),
                  Text('${_entries.length} Students Enrolled',
                      style: AppTextStyles.caption),
                  const SizedBox(height: 12),
                  ..._entries.map((e) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _GradeCard(
                          entry: e,
                          controller: _controllers[e.id]!,
                          onChanged: (val) => setState(() {
                            e.score = val.isEmpty ? '--' : val;
                            e.graded = val.isNotEmpty;
                          }),
                          published: _published,
                        ),
                      )),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          _buildPublishButton(),
        ],
      ),
    );
  }

  // ── Title ──────────────────────────────────────────────────────────────────

  Widget _buildTitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Grade Management', style: AppTextStyles.h1),
        Text('Manage and publish student performance metrics.',
            style: AppTextStyles.caption),
      ],
    );
  }

  // ── Course dropdown ────────────────────────────────────────────────────────

  Widget _buildCourseDropdown() {
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
                    horizontal: 18, vertical: 10),
                decoration: BoxDecoration(
                  color: isActive ? AppColors.primaryNavy : AppColors.bgCard,
                  borderRadius:
                      BorderRadius.circular(AppSpacing.chipRadius),
                  border: Border.all(
                    color: isActive
                        ? AppColors.primaryNavy
                        : AppColors.border,
                  ),
                ),
                child: Text(_tabs[i],
                    style: AppTextStyles.caption.copyWith(
                      color: isActive ? Colors.white : AppColors.textSecondary,
                      fontWeight: isActive
                          ? FontWeight.w600
                          : FontWeight.normal,
                    )),
              ),
            ),
          );
        }),
      ),
    );
  }

  // ── Toolbar ────────────────────────────────────────────────────────────────

  Widget _buildToolbar() {
    return Row(
      children: [
        OutlinedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.upload_file_outlined, size: 15),
          label: const Text('Import CSV'),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            textStyle: AppTextStyles.caption,
          ),
        ),
        const SizedBox(width: 10),
        OutlinedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.download_outlined, size: 15),
          label: const Text('Export'),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            textStyle: AppTextStyles.caption,
          ),
        ),
      ],
    );
  }

  // ── Publish button ─────────────────────────────────────────────────────────

  Widget _buildPublishButton() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      color: AppColors.bgCard,
      child: SizedBox(
        width: double.infinity,
        height: AppSpacing.buttonHeight,
        child: ElevatedButton.icon(
          onPressed: _publishGrades,
          icon: const Icon(Icons.publish_outlined, size: 18),
          label: Text(
            _published ? 'Published' : 'Publish Grades',
            style: AppTextStyles.button,
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: _published ? AppColors.statusGreen : null,
          ),
        ),
      ),
    );
  }
}

// ── Grade card ─────────────────────────────────────────────────────────────────

class _GradeCard extends StatelessWidget {
  const _GradeCard({
    required this.entry,
    required this.controller,
    required this.onChanged,
    required this.published,
  });

  final _GradeEntry entry;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final bool published;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: AppColors.primaryNavy.withValues(alpha: 0.1),
            child: Text(entry.name[0],
                style: AppTextStyles.h3
                    .copyWith(color: AppColors.primaryNavy)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(entry.name, style: AppTextStyles.bodyMedium),
                Text(entry.studentId, style: AppTextStyles.caption),
              ],
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 64,
            child: TextField(
              controller: controller,
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              onChanged: onChanged,
              style: AppTextStyles.metric.copyWith(
                  fontSize: 18,
                  color: entry.graded ? AppColors.textPrimary : AppColors.textLabel),
              decoration: InputDecoration(
                hintText: '--',
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
              ),
            ),
          ),
          const SizedBox(width: 6),
          Text('/ 100',
              style: AppTextStyles.body
                  .copyWith(color: AppColors.textSecondary)),
          const SizedBox(width: 10),
          _GradeBadge(
              graded: entry.graded, published: published),
        ],
      ),
    );
  }
}

class _GradeBadge extends StatelessWidget {
  const _GradeBadge({required this.graded, required this.published});
  final bool graded, published;

  @override
  Widget build(BuildContext context) {
    final label = !graded
        ? 'Pending'
        : published
            ? 'Published'
            : 'Graded';
    final color = !graded
        ? AppColors.statusRed
        : published
            ? AppColors.statusGreen
            : AppColors.primaryBlue;
    final bg = !graded
        ? AppColors.statusRedBg
        : published
            ? AppColors.statusGreenBg
            : AppColors.statusBlueBg;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppSpacing.chipRadius),
      ),
      child: Text(label,
          style: AppTextStyles.caption
              .copyWith(color: color, fontWeight: FontWeight.w600)),
    );
  }
}
