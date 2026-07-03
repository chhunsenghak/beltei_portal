import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/providers/student_providers.dart';
import '../../../core/providers/teacher_providers.dart';
import '../../../core/services/student_service.dart';
import '../../../core/services/teacher_service.dart';
import '../../../core/supabase/database.types.dart';

const _kTabs = ['Overview', 'Attendance', 'Grades', 'Materials'];

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
    _tabController = TabController(length: _kTabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final asyncCourses = ref.watch(studentCoursesProvider);
    final course = asyncCourses
        .whenData((list) =>
            list.where((c) => c.courseId == widget.courseId).firstOrNull)
        .value;

    return Scaffold(
      backgroundColor: AppColors.bgPage,
      appBar: _buildAppBar(context, course),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(course),
          _buildAttendanceTab(),
          _buildGradesTab(),
          _buildMaterialsTab(),
        ],
      ),
    );
  }

  // ── App bar ────────────────────────────────────────────────────────────────

  PreferredSizeWidget _buildAppBar(
      BuildContext context, EnrolledCourse? course) {
    return AppBar(
      backgroundColor: AppColors.bgPage,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, size: 18),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Text(
        course?.name ?? 'Course Detail',
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
        tabs: _kTabs.map((t) => Tab(text: t)).toList(),
      ),
    );
  }

  // ── Overview tab ───────────────────────────────────────────────────────────

  Widget _buildOverviewTab(EnrolledCourse? course) {
    if (course == null) {
      return const Center(child: CircularProgressIndicator());
    }
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatusCard(course),
          const SizedBox(height: 14),
          _buildInfoRow(Icons.school_outlined, 'Credits',
              '${course.credits} Academic Credits'),
          const SizedBox(height: 10),
          if (course.semesterName != null)
            _buildInfoRow(
              Icons.calendar_today_outlined,
              'Semester',
              [
                course.semesterName!,
                if (course.semesterAcademicYear != null)
                  course.semesterAcademicYear!,
              ].join(' — '),
            ),
          if (course.semesterName != null) const SizedBox(height: 14),
          if (course.teacherName != null)
            _buildTeacherCard(course.teacherName!),
          if (course.attendanceRate != null) ...[
            const SizedBox(height: 14),
            _buildAttendanceBadge(course.attendanceRate!),
          ],
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildStatusCard(EnrolledCourse course) {
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
                  course.isCurrentSemester ? 'CURRENT' : 'ENROLLED',
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

  Widget _buildTeacherCard(String teacherName) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Instructor',
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
                      Text('Contact', style: AppTextStyles.link),
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

  Widget _buildAttendanceBadge(double rate) {
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
              Text('Attendance Rate', style: AppTextStyles.caption),
              Text(
                '$pct%${isLow ? ' — Below 75% threshold' : ''}',
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

  Widget _buildAttendanceTab() {
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
            Text('Could not load attendance', style: AppTextStyles.body),
            TextButton(
              onPressed: () => ref.invalidate(
                  studentCourseAttendanceProvider(widget.courseId)),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
      data: (records) {
        if (records.isEmpty) {
          return Center(
            child: Text('No attendance records yet.',
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
                  records.length, present, late, absent, rate),
              const SizedBox(height: AppSpacing.sectionGap),
              Text('Session History', style: AppTextStyles.h2),
              const SizedBox(height: 12),
              _Card(
                child: Column(
                  children: records.asMap().entries.map((e) {
                    final isLast = e.key == records.length - 1;
                    return Column(
                      children: [
                        _AttendanceRow(record: e.value),
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

  Widget _buildAttendanceSummaryCard(
      int total, int present, int late, int absent, double rate) {
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
          Text('ATTENDANCE RATE',
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
                  child: Text('Below 75%',
                      style: AppTextStyles.caption
                          .copyWith(color: AppColors.statusRed)),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _AttendStat('Total', '$total', Colors.white70),
              const SizedBox(width: 20),
              _AttendStat('Present', '$present', AppColors.statusGreen),
              const SizedBox(width: 20),
              _AttendStat('Late', '$late', AppColors.statusAmber),
              const SizedBox(width: 20),
              _AttendStat('Absent', '$absent', AppColors.statusRed),
            ],
          ),
        ],
      ),
    );
  }

  // ── Grades tab ─────────────────────────────────────────────────────────────

  Widget _buildGradesTab() {
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
            Text('Could not load grades', style: AppTextStyles.body),
            TextButton(
              onPressed: () => ref.invalidate(studentGradesProvider),
              child: const Text('Retry'),
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
            child: Text('No grades recorded yet.',
                style: AppTextStyles.body
                    .copyWith(color: AppColors.textSecondary)),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildGradeBanner(grade),
              const SizedBox(height: AppSpacing.sectionGap),
              Text('Score Breakdown', style: AppTextStyles.h2),
              const SizedBox(height: 12),
              _Card(
                child: Column(
                  children: [
                    _GradeRow('Midterm', grade.midterm),
                    Divider(height: 1, color: AppColors.divider),
                    _GradeRow('Assignment', grade.assignment),
                    Divider(height: 1, color: AppColors.divider),
                    _GradeRow('Final Exam', grade.finalExam),
                    Divider(height: 1, color: AppColors.divider),
                    _GradeRow('Total', grade.total, isTotal: true),
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

  Widget _buildGradeBanner(CourseGrade grade) {
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
                Text('FINAL GRADE',
                    style:
                        AppTextStyles.label.copyWith(color: Colors.white70)),
                const SizedBox(height: 4),
                Text(
                  grade.gpaPoints != null
                      ? '${grade.gpaPoints!.toStringAsFixed(1)} GPA Points'
                      : 'Not yet graded',
                  style: AppTextStyles.h3White,
                ),
                const SizedBox(height: 4),
                Text('${grade.credits} Credits',
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

  Widget _buildMaterialsTab() {
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
            Text('Could not load materials', style: AppTextStyles.body),
            TextButton(
              onPressed: () =>
                  ref.invalidate(courseMaterialsProvider(widget.courseId)),
              child: const Text('Retry'),
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
                Text('No materials uploaded yet.',
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
                    Text('Course Materials', style: AppTextStyles.h2),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.statusBlueBg,
                        borderRadius: BorderRadius.circular(
                            AppSpacing.chipRadius),
                      ),
                      child: Text('${materials.length} Files',
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
              child: _MaterialCard(item: item),
            );
          },
        );
      },
    );
  }
}

// ── Attendance row ─────────────────────────────────────────────────────────────

class _AttendanceRow extends StatelessWidget {
  const _AttendanceRow({required this.record});
  final AttendanceRecord record;

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
        AttendanceStatus.present => 'Present',
        AttendanceStatus.late => 'Late',
        AttendanceStatus.absent => 'Absent',
        AttendanceStatus.excused => 'Excused',
      };

  String _fmtDate(String iso) {
    try {
      final d = DateTime.parse(iso);
      const months = [
        '',
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      return '${months[d.month]} ${d.day}, ${d.year}';
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
  const _MaterialCard({required this.item});
  final CourseMaterialItem item;

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
    const months = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[d.month]} ${d.day}, ${d.year}';
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
