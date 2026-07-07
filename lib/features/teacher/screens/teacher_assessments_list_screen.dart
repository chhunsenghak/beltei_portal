import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/providers/teacher_providers.dart';
import '../../../core/services/teacher_service.dart';
import '../../../l10n/app_localizations.dart';

class TeacherAssessmentsListScreen extends ConsumerWidget {
  const TeacherAssessmentsListScreen({super.key, required this.courseId});
  final String courseId;

  Color _getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'quiz':
        return AppColors.primaryBlue;
      case 'assignment':
        return const Color(0xFF7C3AED); // Purple
      case 'project':
        return AppColors.statusGreen;
      case 'exam':
      case 'midterm':
      case 'final exam':
        return AppColors.statusRed;
      default:
        return AppColors.primaryNavy;
    }
  }

  Color _getTypeBgColor(String type) {
    switch (type.toLowerCase()) {
      case 'quiz':
        return AppColors.statusBlueBg;
      case 'assignment':
        return const Color(0xFFF3E8FF); // Light purple
      case 'project':
        return AppColors.statusGreenBg;
      case 'exam':
      case 'midterm':
      case 'final exam':
        return AppColors.statusRedBg;
      default:
        return AppColors.border.withValues(alpha: 0.2);
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'quiz':
        return Icons.quiz_outlined;
      case 'assignment':
        return Icons.assignment_outlined;
      case 'project':
        return Icons.rocket_launch_outlined;
      case 'exam':
      case 'midterm':
      case 'final exam':
        return Icons.gavel_outlined;
      default:
        return Icons.task_outlined;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final courseAsync = ref.watch(courseInfoProvider(courseId));
    final assessmentsAsync = ref.watch(courseAssessmentsProvider(courseId));

    final courseName = courseAsync.valueOrNull?.name ?? 'Course';
    final courseCode = courseAsync.valueOrNull?.code ?? '';

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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              courseCode.isNotEmpty ? '$courseCode – $courseName' : courseName,
              style: AppTextStyles.h3,
              overflow: TextOverflow.ellipsis,
            ),
            Text(l.teacherDashboardQuickActionAssignments, style: AppTextStyles.caption),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(courseAssessmentsProvider(courseId));
          ref.invalidate(courseInfoProvider(courseId));
        },
        child: assessmentsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error_outline, color: AppColors.statusRed, size: 40),
                const SizedBox(height: 8),
                Text(l.courseListLoadError, style: AppTextStyles.bodyMedium),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => ref.invalidate(courseAssessmentsProvider(courseId)),
                  child: Text(l.retry),
                ),
              ],
            ),
          ),
          data: (assessments) {
            if (assessments.isEmpty) {
              return _buildEmptyState(context, l);
            }
            return ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(AppSpacing.screenPadding),
              itemCount: assessments.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final assessment = assessments[index];
                return _buildAssessmentCard(context, assessment);
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/teacher/courses/$courseId/assessments/create'),
        backgroundColor: AppColors.primaryNavy,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, AppLocalizations l) {
    return Center(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.primaryNavy.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.assignment_late_outlined, color: AppColors.primaryNavy, size: 36),
            ),
            const SizedBox(height: 16),
            Text(
              l.teacherCourseListEmptyState,
              style: AppTextStyles.h3.copyWith(color: AppColors.textPrimary),
            ),
            const SizedBox(height: 8),
            Text(
              "No assessments created for this course yet.",
              style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => context.push('/teacher/courses/$courseId/assessments/create'),
              icon: const Icon(Icons.add, size: 18),
              label: Text(l.createAssessmentTitle, style: AppTextStyles.button),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryNavy,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAssessmentCard(BuildContext context, AssessmentItem assessment) {
    final typeColor = _getTypeColor(assessment.type);
    final typeBgColor = _getTypeBgColor(assessment.type);
    final typeIcon = _getTypeIcon(assessment.type);

    String formattedDueDate = 'No due date';
    if (assessment.dueDate != null) {
      formattedDueDate = DateFormat('EEEE, MMM d, yyyy').format(assessment.dueDate!);
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          context.push('/teacher/courses/$courseId/assessments/${assessment.id}/submissions');
        },
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.cardPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: typeBgColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(typeIcon, color: typeColor, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          assessment.title,
                          style: AppTextStyles.bodySemiBold.copyWith(
                            color: AppColors.textPrimary,
                            fontSize: 15,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: typeBgColor,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                assessment.type,
                                style: AppTextStyles.label.copyWith(
                                  color: typeColor,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "Max: ${assessment.maxScore.toStringAsFixed(0)} pts",
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.textSecondary,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.textLabel),
                ],
              ),
              if (assessment.description != null && assessment.description!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  assessment.description!,
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    height: 1.4,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 12),
              Divider(color: AppColors.border, height: 1),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.calendar_today_outlined, size: 13, color: AppColors.textLabel),
                      const SizedBox(width: 6),
                      Text(
                        "Due: $formattedDueDate",
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  if (assessment.fileUrl != null && assessment.fileUrl!.isNotEmpty)
                    Icon(Icons.attachment_outlined, size: 16, color: AppColors.primaryBlue)
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
