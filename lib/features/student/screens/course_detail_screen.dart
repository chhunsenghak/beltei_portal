import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/providers/student_providers.dart';
import '../../../core/providers/teacher_providers.dart';
import '../../../core/services/student_service.dart';
import '../../../core/services/teacher_service.dart';
import '../../../core/supabase/database.types.dart';
import '../../../l10n/app_localizations.dart';

// ── Screen ────────────────────────────────────────────────────────────────────

class CourseDetailScreen extends ConsumerStatefulWidget {
  const CourseDetailScreen({super.key, required this.courseId});
  final String courseId;

  @override
  ConsumerState<CourseDetailScreen> createState() =>
      _CourseDetailScreenState();
}

class _CourseDetailScreenState extends ConsumerState<CourseDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final asyncCourses = ref.watch(studentCoursesProvider);
    final course = asyncCourses
        .whenData((list) =>
            list.where((c) => c.courseId == widget.courseId).firstOrNull)
        .value;

    return Scaffold(
      backgroundColor: AppColors.bgPage,
      appBar: _buildAppBar(context, course, l),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(course, l),
          _buildAttendanceTab(l),
          _buildGradesTab(l),
          _buildAssignmentsTab(course, l),
          _buildMaterialsTab(l),
        ],
      ),
    );
  }

  // ── App bar ────────────────────────────────────────────────────────────────

  PreferredSizeWidget _buildAppBar(
      BuildContext context, EnrolledCourse? course, AppLocalizations l) {
    final tabs = [
      l.courseDetailTabOverview,
      l.courseDetailTabAttendance,
      l.courseDetailTabGrades,
      l.teacherDashboardQuickActionAssignments,
      l.courseDetailTabMaterials,
    ];
    return AppBar(
      backgroundColor: AppColors.bgPage,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, size: 18),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Text(
        course?.name ?? l.courseDetailFallbackTitle,
        style: AppTextStyles.h3.copyWith(color: AppColors.primaryNavy),
        overflow: TextOverflow.ellipsis,
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined),
          onPressed: () {},
        ),
      ],
      bottom: TabBar(
        controller: _tabController,
        isScrollable: true,
        tabAlignment: TabAlignment.start,
        labelStyle: AppTextStyles.bodySemiBold.copyWith(fontSize: 14),
        unselectedLabelStyle: AppTextStyles.body.copyWith(fontSize: 14),
        labelColor: AppColors.primaryNavy,
        unselectedLabelColor: AppColors.textSecondary,
        indicatorColor: AppColors.primaryNavy,
        indicatorWeight: 2.5,
        tabs: tabs.map((t) => Tab(text: t)).toList(),
      ),
    );
  }

  // ── Overview tab ───────────────────────────────────────────────────────────

  Widget _buildOverviewTab(EnrolledCourse? course, AppLocalizations l) {
    if (course == null) {
      return const Center(child: CircularProgressIndicator());
    }
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatusCard(course, l),
          const SizedBox(height: 14),
          _buildInfoRow(Icons.school_outlined, l.courseDetailCreditsLabel,
              l.courseDetailAcademicCreditsValue(course.credits)),
          const SizedBox(height: 10),
          if (course.semesterName != null)
            _buildInfoRow(
              Icons.calendar_today_outlined,
              l.courseDetailSemesterLabel,
              [
                course.semesterName!,
                if (course.semesterAcademicYear != null)
                  course.semesterAcademicYear!,
              ].join(' — '),
            ),
          if (course.semesterName != null) const SizedBox(height: 14),
          if (course.teacherName != null)
            _buildTeacherCard(course.teacherName!, l),
          if (course.attendanceRate != null) ...[
            const SizedBox(height: 14),
            _buildAttendanceBadge(course.attendanceRate!, l),
          ],
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildStatusCard(EnrolledCourse course, AppLocalizations l) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.primaryNavy,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(course.name, style: AppTextStyles.h2White)),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius:
                      BorderRadius.circular(AppSpacing.chipRadius),
                ),
                child: Text(
                  course.isCurrentSemester
                      ? l.courseDetailCurrentChip
                      : l.courseDetailEnrolledChip,
                  style: AppTextStyles.label
                      .copyWith(color: Colors.white, fontSize: 11),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(course.code, style: AppTextStyles.captionWhite),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return _Card(
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.statusBlueBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.primaryNavy, size: 20),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTextStyles.caption),
              Text(value, style: AppTextStyles.h3),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTeacherCard(String teacherName, AppLocalizations l) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l.courseDetailInstructorTitle,
              style: AppTextStyles.h2.copyWith(color: AppColors.primaryNavy)),
          const SizedBox(height: 14),
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: AppColors.statusGrayBg,
                child: Icon(Icons.person,
                    color: AppColors.textSecondary, size: 32),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(teacherName, style: AppTextStyles.h3),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.email_outlined,
                          color: AppColors.primaryNavy, size: 16),
                      const SizedBox(width: 4),
                      Text(l.courseDetailContactLink, style: AppTextStyles.link),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceBadge(double rate, AppLocalizations l) {
    final pct = (rate * 100).round();
    final isLow = rate < 0.75;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: isLow
            ? AppColors.statusRedBg.withValues(alpha: 0.5)
            : AppColors.statusGreenBg.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(
            color: isLow ? AppColors.statusRed : AppColors.statusGreen,
            width: 1.2),
      ),
      child: Row(
        children: [
          Icon(
            isLow
                ? Icons.warning_amber_outlined
                : Icons.check_circle_outline,
            color: isLow ? AppColors.statusRed : AppColors.statusGreen,
            size: 20,
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l.courseDetailAttendanceRateLabel, style: AppTextStyles.caption),
              Text(
                isLow
                    ? l.courseDetailAttendanceBelowThreshold(pct)
                    : '$pct%',
                style: AppTextStyles.h3.copyWith(
                    color: isLow
                        ? AppColors.statusRed
                        : AppColors.statusGreen),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Attendance tab ─────────────────────────────────────────────────────────

  Widget _buildAttendanceTab(AppLocalizations l) {
    final asyncRecords =
        ref.watch(studentCourseAttendanceProvider(widget.courseId));

    return asyncRecords.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline,
                color: AppColors.statusRed, size: 40),
            const SizedBox(height: 8),
            Text(l.loadErrorAttendance, style: AppTextStyles.body),
            TextButton(
              onPressed: () => ref.invalidate(
                  studentCourseAttendanceProvider(widget.courseId)),
              child: Text(l.retry),
            ),
          ],
        ),
      ),
      data: (records) {
        if (records.isEmpty) {
          return Center(
            child: Text(l.courseDetailNoAttendanceRecords,
                style:
                    AppTextStyles.body.copyWith(color: AppColors.textSecondary)),
          );
        }

        final present =
            records.where((r) => r.status == AttendanceStatus.present).length;
        final late =
            records.where((r) => r.status == AttendanceStatus.late).length;
        final absent =
            records.where((r) => r.status == AttendanceStatus.absent).length;
        final rate = present / records.length;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAttendanceSummaryCard(
                  records.length, present, late, absent, rate, l),
              const SizedBox(height: AppSpacing.sectionGap),
              Text(l.courseDetailSessionHistoryTitle, style: AppTextStyles.h2),
              const SizedBox(height: 12),
              _Card(
                child: Column(
                  children: records.asMap().entries.map((e) {
                    final isLast = e.key == records.length - 1;
                    return Column(
                      children: [
                        _AttendanceRow(record: e.value, l: l),
                        if (!isLast)
                          Divider(
                              height: 1, color: AppColors.divider),
                      ],
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAttendanceSummaryCard(int total, int present, int late,
      int absent, double rate, AppLocalizations l) {
    final isLow = rate < 0.75;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.primaryNavy,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l.courseDetailAttendanceRateAllCaps,
              style: AppTextStyles.label.copyWith(color: Colors.white70)),
          const SizedBox(height: 6),
          Row(
            children: [
              Text('${(rate * 100).round()}%',
                  style: AppTextStyles.metric
                      .copyWith(color: Colors.white, fontSize: 36)),
              const SizedBox(width: 10),
              if (isLow)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.statusRedBg,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(l.courseDetailBelowThresholdChip,
                      style: AppTextStyles.caption
                          .copyWith(color: AppColors.statusRed)),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _AttendStat(l.courseDetailTotalLabel, '$total', Colors.white70),
              const SizedBox(width: 20),
              _AttendStat(l.statusPresent, '$present', AppColors.statusGreen),
              const SizedBox(width: 20),
              _AttendStat(l.statusLate, '$late', AppColors.statusAmber),
              const SizedBox(width: 20),
              _AttendStat(l.statusAbsent, '$absent', AppColors.statusRed),
            ],
          ),
        ],
      ),
    );
  }

  // ── Grades tab ─────────────────────────────────────────────────────────────

  Widget _buildGradesTab(AppLocalizations l) {
    final asyncGrades = ref.watch(studentGradesProvider);

    return asyncGrades.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline,
                color: AppColors.statusRed, size: 40),
            const SizedBox(height: 8),
            Text(l.loadErrorGrades, style: AppTextStyles.body),
            TextButton(
              onPressed: () => ref.invalidate(studentGradesProvider),
              child: Text(l.retry),
            ),
          ],
        ),
      ),
      data: (semesters) {
        CourseGrade? grade;
        for (final sem in semesters) {
          final found = sem.courses
              .where((c) => c.courseId == widget.courseId)
              .firstOrNull;
          if (found != null) {
            grade = found;
            break;
          }
        }

        if (grade == null) {
          return Center(
            child: Text(l.courseDetailNoGradesRecorded,
                style: AppTextStyles.body
                    .copyWith(color: AppColors.textSecondary)),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildGradeBanner(grade, l),
              const SizedBox(height: AppSpacing.sectionGap),
              Text(l.courseDetailScoreBreakdownTitle, style: AppTextStyles.h2),
              const SizedBox(height: 12),
              _Card(
                child: Column(
                  children: [
                    _GradeRow(l.courseDetailMidtermLabel, grade.midterm),
                    Divider(height: 1, color: AppColors.divider),
                    _GradeRow(l.courseDetailAssignmentLabel, grade.assignment),
                    Divider(height: 1, color: AppColors.divider),
                    _GradeRow(l.courseDetailFinalExamLabel, grade.finalExam),
                    Divider(height: 1, color: AppColors.divider),
                    _GradeRow(l.courseDetailTotalLabel, grade.total,
                        isTotal: true),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGradeBanner(CourseGrade grade, AppLocalizations l) {
    final letterGrade = grade.letterGrade ?? '—';
    final Color gradeColor;
    if (letterGrade.startsWith('A')) {
      gradeColor = AppColors.statusGreen;
    } else if (letterGrade.startsWith('B')) {
      gradeColor = AppColors.primaryBlue;
    } else if (letterGrade.startsWith('C')) {
      gradeColor = AppColors.statusAmber;
    } else if (letterGrade == 'F') {
      gradeColor = AppColors.statusRed;
    } else {
      gradeColor = AppColors.textLabel;
    }

    return Container(
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.primaryNavy,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l.courseDetailFinalGradeLabel,
                    style:
                        AppTextStyles.label.copyWith(color: Colors.white70)),
                const SizedBox(height: 4),
                Text(
                  grade.gpaPoints != null
                      ? l.courseDetailGpaPointsValue(
                          grade.gpaPoints!.toStringAsFixed(1))
                      : l.courseDetailNotYetGraded,
                  style: AppTextStyles.h3White,
                ),
                const SizedBox(height: 4),
                Text(l.courseDetailGradeCreditsValue(grade.credits),
                    style: AppTextStyles.captionWhite),
              ],
            ),
          ),
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: gradeColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(letterGrade,
                  style: AppTextStyles.metric
                      .copyWith(color: Colors.white, fontSize: 24)),
            ),
          ),
        ],
      ),
    );
  }

  // ── Materials tab ──────────────────────────────────────────────────────────

  Widget _buildMaterialsTab(AppLocalizations l) {
    final asyncMaterials =
        ref.watch(courseMaterialsProvider(widget.courseId));

    return asyncMaterials.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline,
                color: AppColors.statusRed, size: 40),
            const SizedBox(height: 8),
            Text(l.courseDetailMaterialsLoadError, style: AppTextStyles.body),
            TextButton(
              onPressed: () =>
                  ref.invalidate(courseMaterialsProvider(widget.courseId)),
              child: Text(l.retry),
            ),
          ],
        ),
      ),
      data: (materials) {
        if (materials.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.folder_open_outlined,
                    color: AppColors.textLabel, size: 48),
                const SizedBox(height: 12),
                Text(l.courseDetailNoMaterialsUploaded,
                    style: AppTextStyles.body
                        .copyWith(color: AppColors.textSecondary)),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          itemCount: materials.length + 1,
          itemBuilder: (_, i) {
            if (i == 0) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Text(l.courseDetailMaterialsTitle, style: AppTextStyles.h2),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.statusBlueBg,
                        borderRadius: BorderRadius.circular(
                            AppSpacing.chipRadius),
                      ),
                      child: Text(
                          l.courseDetailFilesCountValue(materials.length),
                          style: AppTextStyles.label
                              .copyWith(color: AppColors.primaryBlue)),
                    ),
                  ],
                ),
              );
            }
            final item = materials[i - 1];
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _MaterialCard(item: item, l: l),
            );
          },
        );
      },
    );
  }

  Widget _buildAssignmentsTab(EnrolledCourse? course, AppLocalizations l) {
    if (course == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final userAsync = ref.watch(currentUserProvider);
    final studentId = userAsync.valueOrNull?.id;

    if (studentId == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final assessmentsAsync = ref.watch(studentCourseAssessmentsProvider(course.classTermCourseId));

    return assessmentsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => Center(child: Text("Error loading assignments: $e")),
      data: (assessments) {
        if (assessments.isEmpty) {
          return Center(
            child: Text(
              "No assignments found for this course.",
              style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
            ),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          itemCount: assessments.length,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final assessment = assessments[index];
            return _AssignmentItemWidget(
              assessment: assessment,
              studentId: studentId,
              l: l,
            );
          },
        );
      },
    );
  }
}

// ── Attendance row ─────────────────────────────────────────────────────────────

class _AttendanceRow extends StatelessWidget {
  const _AttendanceRow({required this.record, required this.l});
  final AttendanceRecord record;
  final AppLocalizations l;

  Color get _statusColor => switch (record.status) {
        AttendanceStatus.present => AppColors.statusGreen,
        AttendanceStatus.late => AppColors.statusAmber,
        AttendanceStatus.absent => AppColors.statusRed,
        AttendanceStatus.excused => AppColors.primaryBlue,
      };

  Color get _statusBg => switch (record.status) {
        AttendanceStatus.present => AppColors.statusGreenBg,
        AttendanceStatus.late => AppColors.statusAmberBg,
        AttendanceStatus.absent => AppColors.statusRedBg,
        AttendanceStatus.excused => AppColors.statusBlueBg,
      };

  String get _statusLabel => switch (record.status) {
        AttendanceStatus.present => l.statusPresent,
        AttendanceStatus.late => l.statusLate,
        AttendanceStatus.absent => l.statusAbsent,
        AttendanceStatus.excused => l.statusExcused,
      };

  String _fmtDate(String iso) {
    try {
      final d = DateTime.parse(iso);
      return DateFormat.yMMMd(l.localeName).format(d);
    } catch (_) {
      return iso;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.cardPadding, vertical: 12),
      child: Row(
        children: [
          Icon(Icons.calendar_today_outlined,
              size: 16, color: AppColors.textSecondary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(_fmtDate(record.date),
                style: AppTextStyles.bodyMedium),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: _statusBg,
              borderRadius:
                  BorderRadius.circular(AppSpacing.chipRadius),
            ),
            child: Text(_statusLabel,
                style: AppTextStyles.caption.copyWith(
                    color: _statusColor, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}

// ── Attendance stat ────────────────────────────────────────────────────────────

class _AttendStat extends StatelessWidget {
  const _AttendStat(this.label, this.value, this.color);
  final String label, value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: AppTextStyles.label.copyWith(color: Colors.white70)),
        Text(value,
            style: AppTextStyles.metric
                .copyWith(color: color, fontSize: 20)),
      ],
    );
  }
}

// ── Grade row ─────────────────────────────────────────────────────────────────

class _GradeRow extends StatelessWidget {
  const _GradeRow(this.label, this.value, {this.isTotal = false});
  final String label;
  final double? value;
  final bool isTotal;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.cardPadding, vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: isTotal
                  ? AppTextStyles.bodySemiBold
                  : AppTextStyles.body
                      .copyWith(color: AppColors.textSecondary)),
          Text(
            value != null ? value!.toStringAsFixed(1) : '—',
            style: isTotal
                ? AppTextStyles.h3.copyWith(color: AppColors.primaryNavy)
                : AppTextStyles.bodyMedium,
          ),
        ],
      ),
    );
  }
}

// ── Material card ──────────────────────────────────────────────────────────────

class _MaterialCard extends StatelessWidget {
  const _MaterialCard({required this.item, required this.l});
  final CourseMaterialItem item;
  final AppLocalizations l;

  IconData get _icon {
    final t = (item.fileType ?? '').toLowerCase();
    if (t.contains('pdf')) return Icons.picture_as_pdf_outlined;
    if (t.contains('video') || t.contains('mp4')) {
      return Icons.play_circle_outline;
    }
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
    return DateFormat.yMMMd(l.localeName).format(d);
  }

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
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: _iconBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(_icon, color: _iconColor, size: 22),
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
                  ].join(' · '),
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.download_outlined,
                color: AppColors.primaryBlue, size: 20),
            onPressed: () async {
              try {
                final uri = Uri.parse(item.fileUrl);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                } else {
                  throw 'Cannot launch URL';
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Could not open file URL: $e')),
                  );
                }
              }
            },
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}

// ── Shared card ────────────────────────────────────────────────────────────────

class _Card extends StatelessWidget {
  const _Card({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(color: AppColors.border),
      ),
      child: child,
    );
  }
}

class _AssignmentItemWidget extends ConsumerWidget {
  const _AssignmentItemWidget({
    required this.assessment,
    required this.studentId,
    required this.l,
  });

  final AssessmentItem assessment;
  final String studentId;
  final AppLocalizations l;

  Color _getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'quiz':
        return AppColors.primaryBlue;
      case 'assignment':
        return const Color(0xFF7C3AED);
      case 'project':
        return AppColors.statusGreen;
      case 'exam':
        return AppColors.statusRed;
      default:
        return AppColors.textSecondary;
    }
  }

  Color _getTypeBgColor(String type) {
    switch (type.toLowerCase()) {
      case 'quiz':
        return AppColors.statusBlueBg;
      case 'assignment':
        return const Color(0xFFF3E8FF);
      case 'project':
        return AppColors.statusGreenBg;
      case 'exam':
        return AppColors.statusRedBg;
      default:
        return AppColors.border;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final submissionAsync = ref.watch(studentAssessmentSubmissionProvider('${assessment.id}_$studentId'));
    final submission = submissionAsync.valueOrNull;

    String statusText = "Not Submitted";
    Color statusColor = AppColors.textSecondary;
    Color statusBg = AppColors.border;

    if (submission != null) {
      if (submission.grade != null) {
        statusText = "Graded: ${submission.grade} / ${assessment.maxScore}";
        statusColor = AppColors.statusGreen;
        statusBg = AppColors.statusGreenBg;
      } else {
        statusText = "Submitted (Pending Grade)";
        statusColor = AppColors.statusAmber;
        statusBg = AppColors.statusAmberBg;
      }
    }

    final formattedDueDate = assessment.dueDate != null
        ? DateFormat('EEE, MMM d, y').format(assessment.dueDate!)
        : 'No due date';

    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(color: AppColors.border),
      ),
      child: InkWell(
        onTap: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (ctx) => _SubmitAssignmentSheet(
              assessment: assessment,
              studentId: studentId,
              submission: submission,
              l: l,
            ),
          );
        },
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getTypeBgColor(assessment.type),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      assessment.type,
                      style: AppTextStyles.label.copyWith(
                        color: _getTypeColor(assessment.type),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
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
              const SizedBox(height: 12),
              Text(
                assessment.title,
                style: AppTextStyles.bodySemiBold.copyWith(fontSize: 15, color: AppColors.primaryNavy),
              ),
              if (assessment.description != null && assessment.description!.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  assessment.description!,
                  style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.calendar_today_outlined, size: 14, color: AppColors.textLabel),
                      const SizedBox(width: 6),
                      Text(
                        "Due: $formattedDueDate",
                        style: AppTextStyles.caption.copyWith(fontSize: 11),
                      ),
                    ],
                  ),
                  Text(
                    "Max Score: ${assessment.maxScore}",
                    style: AppTextStyles.caption.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryNavy,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SubmitAssignmentSheet extends ConsumerStatefulWidget {
  const _SubmitAssignmentSheet({
    required this.assessment,
    required this.studentId,
    required this.submission,
    required this.l,
  });

  final AssessmentItem assessment;
  final String studentId;
  final AssessmentSubmission? submission;
  final AppLocalizations l;

  @override
  ConsumerState<_SubmitAssignmentSheet> createState() => _SubmitAssignmentSheetState();
}

class _SubmitAssignmentSheetState extends ConsumerState<_SubmitAssignmentSheet> {
  final _textController = TextEditingController();
  XFile? _selectedFile;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    if (widget.submission != null) {
      _textController.text = widget.submission!.submissionText ?? '';
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    try {
      final picker = ImagePicker();
      final file = await picker.pickImage(source: ImageSource.gallery);
      if (file != null) {
        setState(() {
          _selectedFile = file;
        });
      }
    } catch (e) {
      debugPrint('Error picking submission file: $e');
    }
  }

  Future<void> _submit() async {
    final text = _textController.text.trim();
    if (text.isEmpty && _selectedFile == null && widget.submission?.fileUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Please write a text response or pick a file to submit.",
            style: AppTextStyles.body.copyWith(color: Colors.white)),
        backgroundColor: AppColors.statusRed,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ));
      return;
    }

    setState(() => _saving = true);
    try {
      String? finalFileUrl = widget.submission?.fileUrl;

      if (_selectedFile != null) {
        final bytes = await _selectedFile!.readAsBytes();
        final fileExt = _selectedFile!.name.split('.').last;
        final uniqueName = '${DateTime.now().millisecondsSinceEpoch}_${_selectedFile!.name}';
        final storagePath = 'submissions/${widget.assessment.id}/${widget.studentId}/$uniqueName';

        await Supabase.instance.client.storage
            .from('course-materials')
            .uploadBinary(
              storagePath,
              bytes,
              fileOptions: FileOptions(contentType: 'image/$fileExt'),
            );

        finalFileUrl = Supabase.instance.client.storage
            .from('course-materials')
            .getPublicUrl(storagePath);
      }

      await ref.read(studentServiceProvider).submitAssessment(
        assessmentId: widget.assessment.id,
        studentId: widget.studentId,
        submissionText: text.isNotEmpty ? text : null,
        fileUrl: finalFileUrl,
      );

      ref.invalidate(studentAssessmentSubmissionProvider('${widget.assessment.id}_${widget.studentId}'));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Assignment submitted successfully!",
              style: AppTextStyles.body.copyWith(color: Colors.white)),
          backgroundColor: AppColors.statusGreen,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ));
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Failed to submit: $e",
              style: AppTextStyles.body.copyWith(color: Colors.white)),
          backgroundColor: AppColors.statusRed,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
    final sub = widget.submission;
    final isGraded = sub?.grade != null;

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
            Text(widget.assessment.title, style: AppTextStyles.h2),
            const SizedBox(height: 4),
            Text(
              "Max Score: ${widget.assessment.maxScore}",
              style: AppTextStyles.caption.copyWith(color: AppColors.primaryNavy, fontWeight: FontWeight.w600),
            ),
            const Divider(height: 24),
            if (isGraded) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.statusGreenBg,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.statusGreen.withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Grade: ${sub!.grade} / ${widget.assessment.maxScore}",
                      style: AppTextStyles.bodySemiBold.copyWith(color: AppColors.statusGreen),
                    ),
                    if (sub.feedback != null && sub.feedback!.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        "Feedback: ${sub.feedback}",
                        style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
            Text("Submission Text", style: AppTextStyles.label),
            const SizedBox(height: 6),
            TextField(
              controller: _textController,
              enabled: !isGraded && !_saving,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: "Write your submission text here...",
              ),
            ),
            const SizedBox(height: 16),
            Text("Attachment File", style: AppTextStyles.label),
            const SizedBox(height: 6),
            if (isGraded)
              if (sub?.fileUrl != null)
                ListTile(
                  leading: Icon(Icons.insert_drive_file_outlined, color: AppColors.primaryBlue),
                  title: const Text("View submitted file"),
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
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Could not open file URL: $e')),
                        );
                      }
                    }
                  },
                )
              else
                Text("No file attached", style: AppTextStyles.caption)
            else ...[
              GestureDetector(
                onTap: _saving ? null : _pickFile,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  decoration: BoxDecoration(
                    color: AppColors.bgCard,
                    borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                    border: Border.all(
                      color: _selectedFile != null || sub?.fileUrl != null
                          ? AppColors.statusGreen
                          : AppColors.border,
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        _selectedFile != null || sub?.fileUrl != null
                            ? Icons.check_circle_outline
                            : Icons.add_photo_alternate_outlined,
                        color: _selectedFile != null || sub?.fileUrl != null
                            ? AppColors.statusGreen
                            : AppColors.primaryBlue,
                        size: 32,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _selectedFile != null
                            ? "Selected: ${_selectedFile!.name}"
                            : sub?.fileUrl != null
                                ? "Existing attachment: file loaded"
                                : "Tap to attach a file/image",
                        style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w600),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              if (_selectedFile != null) ...[
                const SizedBox(height: 6),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: () => setState(() {
                      _selectedFile = null;
                    }),
                    icon: Icon(Icons.clear, color: AppColors.statusRed, size: 14),
                    label: Text("Clear File", style: TextStyle(color: AppColors.statusRed, fontSize: 11)),
                  ),
                ),
              ],
            ],
            const SizedBox(height: 24),
            if (!isGraded)
              SizedBox(
                width: double.infinity,
                height: AppSpacing.buttonHeight,
                child: ElevatedButton(
                  onPressed: _saving ? null : _submit,
                  child: _saving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : Text(sub != null ? "Resubmit Assignment" : "Submit Assignment", style: AppTextStyles.button),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

