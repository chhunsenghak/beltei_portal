import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/providers/teacher_providers.dart';
import '../../../core/services/teacher_service.dart';

const _kTabs = ['Midterm', 'Assignment', 'Participation', 'Final Exam'];

class GradeManagementScreen extends ConsumerStatefulWidget {
  const GradeManagementScreen({super.key, required this.courseId});
  final String courseId;

  @override
  ConsumerState<GradeManagementScreen> createState() =>
      _GradeManagementScreenState();
}

class _GradeManagementScreenState extends ConsumerState<GradeManagementScreen> {
  int _selectedTab = 0;
  bool _saving = false;

  // studentId → tab index → TextEditingController
  final Map<String, List<TextEditingController>> _controllers = {};

  bool _initialized = false;

  void _initControllers(
    List<CourseStudent> students,
    List<CourseGradeData> grades,
  ) {
    if (_initialized) return;
    _initialized = true;

    final gradeMap = {for (final g in grades) g.studentId: g};

    for (final student in students) {
      final g = gradeMap[student.studentId];
      _controllers[student.studentId] = [
        TextEditingController(
            text: _fmt(g?.midterm)),       // tab 0 = midterm
        TextEditingController(
            text: _fmt(g?.assignment)),    // tab 1 = assignment
        TextEditingController(
            text: _fmt(g?.participation)), // tab 2 = participation
        TextEditingController(
            text: _fmt(g?.finalExam)),     // tab 3 = final_exam
      ];
    }
  }

  String _fmt(double? v) => v == null ? '' : v.toStringAsFixed(0);

  @override
  void dispose() {
    for (final list in _controllers.values) {
      for (final c in list) {
        c.dispose();
      }
    }
    super.dispose();
  }

  Future<void> _saveGrades(String semesterId, List<CourseStudent> students) async {
    setState(() => _saving = true);
    try {
      final gradesToSave = <CourseGradeData>[];
      for (final student in students) {
        final ctrls = _controllers[student.studentId];
        if (ctrls == null) continue;

        final midterm = double.tryParse(ctrls[0].text.trim());
        final assignment = double.tryParse(ctrls[1].text.trim());
        final participation = double.tryParse(ctrls[2].text.trim());
        final finalExam = double.tryParse(ctrls[3].text.trim());

        if (midterm == null &&
            assignment == null &&
            participation == null &&
            finalExam == null) {
          continue;
        }

        gradesToSave.add(CourseGradeData(
          studentId: student.studentId,
          midterm: midterm,
          assignment: assignment,
          participation: participation,
          finalExam: finalExam,
        ));
      }

      await ref.read(teacherServiceProvider).saveGrades(
            courseId: widget.courseId,
            semesterId: semesterId,
            grades: gradesToSave,
          );

      ref.invalidate(courseGradesProvider(widget.courseId));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Grades saved successfully.',
                style: AppTextStyles.body.copyWith(color: Colors.white)),
            backgroundColor: AppColors.statusGreen,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save grades: $e',
                style: AppTextStyles.body.copyWith(color: Colors.white)),
            backgroundColor: AppColors.statusRed,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final asyncCourse = ref.watch(courseInfoProvider(widget.courseId));
    final asyncStudents = ref.watch(courseStudentsProvider(widget.courseId));
    final asyncGrades = ref.watch(courseGradesProvider(widget.courseId));

    final semesterId = asyncCourse.whenData((c) => c?.semesterId).value;
    final courseName = asyncCourse.whenData((c) => c?.name).value;

    return Scaffold(
      backgroundColor: AppColors.bgPage,
      body: Column(
        children: [
          Expanded(
            child: asyncStudents.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.error_outline,
                        color: AppColors.statusRed, size: 40),
                    const SizedBox(height: 8),
                    Text('Could not load students',
                        style: AppTextStyles.bodyMedium),
                    TextButton(
                      onPressed: () => ref
                          .invalidate(courseStudentsProvider(widget.courseId)),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
              data: (students) {
                return asyncGrades.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.error_outline,
                            color: AppColors.statusRed, size: 40),
                        const SizedBox(height: 8),
                        Text('Could not load grades',
                            style: AppTextStyles.bodyMedium),
                        TextButton(
                          onPressed: () => ref.invalidate(
                              courseGradesProvider(widget.courseId)),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                  data: (grades) {
                    _initControllers(students, grades);
                    return SingleChildScrollView(
                      padding:
                          const EdgeInsets.all(AppSpacing.screenPadding),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildTitle(courseName),
                          const SizedBox(height: AppSpacing.md),
                          _buildTypeTabs(),
                          const SizedBox(height: 12),
                          Text(
                              '${students.length} Student${students.length == 1 ? '' : 's'} Enrolled',
                              style: AppTextStyles.caption),
                          const SizedBox(height: 12),
                          if (students.isEmpty)
                            _buildEmpty()
                          else
                            ...students.map((s) {
                              final ctrls = _controllers[s.studentId]!;
                              return Padding(
                                padding:
                                    const EdgeInsets.only(bottom: 10),
                                child: _GradeCard(
                                  student: s,
                                  controller: ctrls[_selectedTab],
                                  tabLabel: _kTabs[_selectedTab],
                                ),
                              );
                            }),
                          const SizedBox(height: 16),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
          _buildSaveButton(semesterId,
              asyncStudents.whenData((s) => s).value ?? []),
        ],
      ),
    );
  }

  Widget _buildTitle(String? courseName) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Grade Management', style: AppTextStyles.h1),
        Text(
          courseName ?? 'Loading course...',
          style: AppTextStyles.caption,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildTypeTabs() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(_kTabs.length, (i) {
          final isActive = i == _selectedTab;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => setState(() => _selectedTab = i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
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
                child: Text(
                  _kTabs[i],
                  style: AppTextStyles.caption.copyWith(
                    color: isActive
                        ? Colors.white
                        : AppColors.textSecondary,
                    fontWeight: isActive
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildEmpty() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32),
      alignment: Alignment.center,
      child: Text('No students enrolled in this course.',
          style: AppTextStyles.body
              .copyWith(color: AppColors.textSecondary)),
    );
  }

  Widget _buildSaveButton(
      String? semesterId, List<CourseStudent> students) {
    final canSave = semesterId != null && !_saving;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      color: AppColors.bgCard,
      child: SizedBox(
        width: double.infinity,
        height: AppSpacing.buttonHeight,
        child: ElevatedButton.icon(
          onPressed: canSave
              ? () => _saveGrades(semesterId, students)
              : null,
          icon: _saving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white),
                )
              : const Icon(Icons.save_outlined, size: 18),
          label: Text(
            _saving ? 'Saving…' : 'Save Grades',
            style: AppTextStyles.button,
          ),
        ),
      ),
    );
  }
}

// ── Grade card ─────────────────────────────────────────────────────────────────

class _GradeCard extends StatelessWidget {
  const _GradeCard({
    required this.student,
    required this.controller,
    required this.tabLabel,
  });

  final CourseStudent student;
  final TextEditingController controller;
  final String tabLabel;

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
            backgroundColor:
                AppColors.primaryNavy.withValues(alpha: 0.1),
            child: Text(
              student.fullName.isNotEmpty ? student.fullName[0] : '?',
              style: AppTextStyles.h3
                  .copyWith(color: AppColors.primaryNavy),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(student.fullName, style: AppTextStyles.bodyMedium),
                Text(student.studentCode, style: AppTextStyles.caption),
              ],
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 64,
            child: TextField(
              controller: controller,
              textAlign: TextAlign.center,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              style: AppTextStyles.metric.copyWith(
                fontSize: 18,
                color: controller.text.isEmpty
                    ? AppColors.textLabel
                    : AppColors.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: '--',
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide:
                      BorderSide(color: AppColors.border),
                ),
              ),
            ),
          ),
          const SizedBox(width: 6),
          Text('/ 100',
              style: AppTextStyles.body
                  .copyWith(color: AppColors.textSecondary)),
          const SizedBox(width: 10),
          _ScoreLabel(tabLabel: tabLabel, controller: controller),
        ],
      ),
    );
  }
}

class _ScoreLabel extends StatefulWidget {
  const _ScoreLabel(
      {required this.tabLabel, required this.controller});
  final String tabLabel;
  final TextEditingController controller;

  @override
  State<_ScoreLabel> createState() => _ScoreLabelState();
}

class _ScoreLabelState extends State<_ScoreLabel> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onChanged);
    super.dispose();
  }

  void _onChanged() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final hasScore = widget.controller.text.trim().isNotEmpty;
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: hasScore
            ? AppColors.statusBlueBg
            : AppColors.statusAmberBg,
        borderRadius:
            BorderRadius.circular(AppSpacing.chipRadius),
      ),
      child: Text(
        hasScore ? widget.tabLabel : 'Pending',
        style: AppTextStyles.caption.copyWith(
          color: hasScore
              ? AppColors.primaryBlue
              : AppColors.statusAmber,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
