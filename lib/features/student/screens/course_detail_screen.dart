import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
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
    _tabController = TabController(length: 4, vsync: this);
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
          Icon(Icons.download_outlined,
              color: AppColors.textLabel, size: 20),
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
