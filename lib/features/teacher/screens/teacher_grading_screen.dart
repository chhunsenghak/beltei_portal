import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/providers/teacher_providers.dart';
import '../../../core/services/teacher_service.dart';
import '../../../l10n/app_localizations.dart';

class TeacherGradingScreen extends ConsumerStatefulWidget {
  const TeacherGradingScreen({
    super.key,
    required this.courseId,
    required this.assessmentId,
  });

  final String courseId;
  final String assessmentId;

  @override
  ConsumerState<TeacherGradingScreen> createState() => _TeacherGradingScreenState();
}

class _TeacherGradingScreenState extends ConsumerState<TeacherGradingScreen> {
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final assessmentsAsync = ref.watch(courseAssessmentsProvider(widget.courseId));
    final submissionsAsync = ref.watch(
      assessmentSubmissionsProvider('${widget.courseId}_${widget.assessmentId}'),
    );

    final assessment = assessmentsAsync.valueOrNull
        ?.firstWhere((a) => a.id == widget.assessmentId);

    return Scaffold(
      backgroundColor: AppColors.bgPage,
      appBar: AppBar(
        backgroundColor: AppColors.bgPage,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 18),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          assessment?.title ?? "Submissions & Grading",
          style: AppTextStyles.h3.copyWith(color: AppColors.primaryNavy),
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (assessment != null) _buildAssessmentDetails(assessment),
          Expanded(
            child: submissionsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.error_outline, color: AppColors.statusRed, size: 40),
                    const SizedBox(height: 8),
                    Text("Error loading submissions", style: AppTextStyles.bodyMedium),
                    TextButton(
                      onPressed: () => ref.invalidate(
                        assessmentSubmissionsProvider('${widget.courseId}_${widget.assessmentId}'),
                      ),
                      child: Text(l.retry),
                    ),
                  ],
                ),
              ),
              data: (submissions) {
                if (submissions.isEmpty) {
                  return Center(
                    child: Text(
                      "No students enrolled in this course.",
                      style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
                    ),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.all(AppSpacing.screenPadding),
                  itemCount: submissions.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final item = submissions[index];
                    return _buildStudentSubmissionCard(item, assessment);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAssessmentDetails(AssessmentItem assessment) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      decoration: BoxDecoration(
        color: AppColors.primaryNavy.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Type: ${assessment.type}",
                style: AppTextStyles.bodySemiBold.copyWith(color: AppColors.primaryNavy, fontSize: 13),
              ),
              Text(
                "Max Score: ${assessment.maxScore} pts",
                style: AppTextStyles.bodySemiBold.copyWith(color: AppColors.primaryNavy, fontSize: 13),
              ),
            ],
          ),
          if (assessment.description != null && assessment.description!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              assessment.description!,
              style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary, height: 1.4),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStudentSubmissionCard(SubmissionListItem item, AssessmentItem? assessment) {
    final sub = item.submission;
    final isGraded = sub?.grade != null;
    final isSubmitted = sub != null;

    String statusText = "Not Submitted";
    Color statusColor = AppColors.textSecondary;
    Color statusBg = AppColors.border;

    if (isSubmitted) {
      if (isGraded) {
        statusText = "Graded: ${sub.grade} / ${assessment?.maxScore ?? 100}";
        statusColor = AppColors.statusGreen;
        statusBg = AppColors.statusGreenBg;
      } else {
        statusText = "Pending Grading";
        statusColor = AppColors.statusAmber;
        statusBg = AppColors.statusAmberBg;
      }
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(color: AppColors.border),
      ),
      child: InkWell(
        onTap: () => _openGradingSheet(item, assessment),
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.primaryNavy.withValues(alpha: 0.1),
                child: Text(
                  item.studentName.isNotEmpty ? item.studentName[0].toUpperCase() : '?',
                  style: AppTextStyles.h3.copyWith(color: AppColors.primaryNavy, fontSize: 14),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.studentName, style: AppTextStyles.bodyMedium),
                    const SizedBox(height: 2),
                    Text("ID: ${item.studentCode}", style: AppTextStyles.caption),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  statusText,
                  style: AppTextStyles.label.copyWith(
                    color: statusColor,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openGradingSheet(SubmissionListItem item, AssessmentItem? assessment) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _GradeSubmissionSheet(
        item: item,
        assessment: assessment,
        courseId: widget.courseId,
        ref: ref,
      ),
    );
  }
}

class _GradeSubmissionSheet extends StatefulWidget {
  const _GradeSubmissionSheet({
    required this.item,
    required this.assessment,
    required this.courseId,
    required this.ref,
  });

  final SubmissionListItem item;
  final AssessmentItem? assessment;
  final String courseId;
  final WidgetRef ref;

  @override
  State<_GradeSubmissionSheet> createState() => _GradeSubmissionSheetState();
}

class _GradeSubmissionSheetState extends State<_GradeSubmissionSheet> {
  final _gradeController = TextEditingController();
  final _feedbackController = TextEditingController();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    if (widget.item.submission != null) {
      _gradeController.text = widget.item.submission!.grade?.toString() ?? '';
      _feedbackController.text = widget.item.submission!.feedback ?? '';
    }
  }

  @override
  void dispose() {
    _gradeController.dispose();
    _feedbackController.dispose();
    super.dispose();
  }

  Future<void> _submitGrade() async {
    final gradeText = _gradeController.text.trim();
    final feedback = _feedbackController.text.trim();

    if (gradeText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Please enter a grade.", style: AppTextStyles.body.copyWith(color: Colors.white)),
        backgroundColor: AppColors.statusRed,
        behavior: SnackBarBehavior.floating,
      ));
      return;
    }

    final grade = double.tryParse(gradeText);
    if (grade == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Invalid grade value.", style: AppTextStyles.body.copyWith(color: Colors.white)),
        backgroundColor: AppColors.statusRed,
        behavior: SnackBarBehavior.floating,
      ));
      return;
    }

    final maxScore = widget.assessment?.maxScore ?? 100.0;
    if (grade < 0 || grade > maxScore) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Grade must be between 0 and $maxScore.", style: AppTextStyles.body.copyWith(color: Colors.white)),
        backgroundColor: AppColors.statusRed,
        behavior: SnackBarBehavior.floating,
      ));
      return;
    }

    setState(() => _saving = true);
    try {
      final teacherId = Supabase.instance.client.auth.currentUser?.id;
      if (teacherId == null) throw Exception("User not authenticated");

      await widget.ref.read(teacherServiceProvider).saveGrade(
            assessmentId: widget.assessment!.id,
            studentId: widget.item.studentId,
            teacherId: teacherId,
            grade: grade,
            feedback: feedback,
          );

      widget.ref.invalidate(
        assessmentSubmissionsProvider('${widget.courseId}_${widget.assessment!.id}'),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Grade saved successfully!", style: AppTextStyles.body.copyWith(color: Colors.white)),
          backgroundColor: AppColors.statusGreen,
          behavior: SnackBarBehavior.floating,
        ));
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        String errorMsg = e.toString();
        if (e is PostgrestException) {
          if (e.code == '42501') {
            errorMsg = "You do not have permission to perform this action.";
          } else {
            errorMsg = e.message;
          }
        } else if (e is Exception) {
          errorMsg = e.toString().replaceFirst(RegExp(r'^Exception:\s*'), '');
        }

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Failed to save grade: $errorMsg", style: AppTextStyles.body.copyWith(color: Colors.white)),
          backgroundColor: AppColors.statusRed,
          behavior: SnackBarBehavior.floating,
        ));
      }
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final sub = widget.item.submission;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgPage,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      padding: EdgeInsets.only(
        left: AppSpacing.screenPadding,
        right: AppSpacing.screenPadding,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text("Grading: ${widget.item.studentName}", style: AppTextStyles.h2),
            Text("ID: ${widget.item.studentCode}", style: AppTextStyles.caption),
            const Divider(height: 24),
            Text("Student Submission", style: AppTextStyles.label),
            const SizedBox(height: 6),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.bgCard,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (sub?.submissionText != null)
                    Text(
                      sub!.submissionText!,
                      style: AppTextStyles.body,
                    )
                  else
                    Text(
                      "No submission text response.",
                      style: AppTextStyles.body.copyWith(color: AppColors.textSecondary, fontStyle: FontStyle.italic),
                    ),
                  if (sub?.fileUrl != null) ...[
                    const SizedBox(height: 10),
                    const Divider(),
                    const SizedBox(height: 6),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(Icons.insert_drive_file_outlined, color: AppColors.primaryBlue),
                      title: const Text("View submission file"),
                      trailing: Icon(Icons.open_in_new, color: AppColors.textLabel),
                      onTap: () async {
                        try {
                          final uri = Uri.parse(sub!.fileUrl!);
                          if (await canLaunchUrl(uri)) {
                            await launchUrl(uri, mode: LaunchMode.externalApplication);
                          } else {
                            throw 'Cannot launch URL';
                          }
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Could not open file URL: $e')),
                            );
                          }
                        }
                      },
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Grade Score", style: AppTextStyles.label),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _gradeController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(
                          hintText: "Score",
                          suffixText: "/ ${widget.assessment?.maxScore ?? 100}",
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text("Teacher Feedback", style: AppTextStyles.label),
            const SizedBox(height: 6),
            TextField(
              controller: _feedbackController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: "Enter constructive feedback...",
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: AppSpacing.buttonHeight,
              child: ElevatedButton(
                onPressed: _saving ? null : _submitGrade,
                child: _saving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : Text("Save Grade & Feedback", style: AppTextStyles.button),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
