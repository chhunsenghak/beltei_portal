import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/student_providers.dart';
import '../../../core/services/student_service.dart';
import '../../../l10n/app_localizations.dart';

enum _LeaveType { medical, personal, family, other }

// Mon-Fri map to one course each (5 courses per class per semester, two
// sessions a day); Sat/Sun never appear as a key since there's no class.
const _kWeekdayAbbr = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

Map<String, EnrolledCourse> _buildDayCourseMap(List<EnrolledCourse> courses) {
  final map = <String, EnrolledCourse>{};
  for (final course in courses) {
    if (!course.isCurrentSemester) continue;
    for (final entry in course.schedule) {
      final day = entry['day'] as String?;
      if (day != null) map[day] = course;
    }
  }
  return map;
}

// While courses haven't loaded yet (or the student has none this semester),
// fall back to a plain Mon-Fri rule rather than blocking date selection.
bool _isSelectableDay(DateTime date, Map<String, EnrolledCourse> dayCourseMap) {
  if (dayCourseMap.isEmpty) return date.weekday <= DateTime.friday;
  return dayCourseMap.containsKey(_kWeekdayAbbr[date.weekday - 1]);
}

// ── Screen ────────────────────────────────────────────────────────────────────

class CreateLeaveRequestScreen extends ConsumerStatefulWidget {
  const CreateLeaveRequestScreen({super.key});

  @override
  ConsumerState<CreateLeaveRequestScreen> createState() =>
      _CreateLeaveRequestScreenState();
}

class _CreateLeaveRequestScreenState
    extends ConsumerState<CreateLeaveRequestScreen> {
  _LeaveType? _leaveType;
  final _reasonController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isSubmitting = false;
  bool _submitted = false;

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  // ── Computed ───────────────────────────────────────────────────────────────

  int get _totalDays {
    if (_startDate == null || _endDate == null) return 0;
    return _endDate!.difference(_startDate!).inDays + 1;
  }

  bool get _isValid =>
      _leaveType != null &&
      _startDate != null &&
      _endDate != null &&
      _reasonController.text.trim().isNotEmpty;

  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  String _isoDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  List<EnrolledCourse> _affectedCourses(Map<String, EnrolledCourse> dayCourseMap) {
    if (_startDate == null || _endDate == null) return [];
    final seen = <String>{};
    final result = <EnrolledCourse>[];
    for (var d = _startDate!;
        !d.isAfter(_endDate!);
        d = d.add(const Duration(days: 1))) {
      final course = dayCourseMap[_kWeekdayAbbr[d.weekday - 1]];
      if (course != null && seen.add(course.courseId)) {
        result.add(course);
      }
    }
    return result;
  }

  // ── Actions ────────────────────────────────────────────────────────────────

  DateTime _firstSelectableFrom(
      DateTime start, Map<String, EnrolledCourse> dayCourseMap) {
    var d = start;
    for (var i = 0; i < 14; i++) {
      if (_isSelectableDay(d, dayCourseMap)) return d;
      d = d.add(const Duration(days: 1));
    }
    return start;
  }

  Future<void> _pickDate(
      bool isStart, Map<String, EnrolledCourse> dayCourseMap) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final firstDate = isStart ? today : (_startDate ?? today);
    final candidate = isStart
        ? (_startDate ?? firstDate)
        : (_endDate ?? _startDate ?? firstDate);
    final initialDate = _firstSelectableFrom(
        candidate.isBefore(firstDate) ? firstDate : candidate, dayCourseMap);

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: DateTime(now.year + 1),
      selectableDayPredicate: (d) => _isSelectableDay(d, dayCourseMap),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: ColorScheme.light(
              primary: AppColors.primaryNavy),
        ),
        child: child!,
      ),
    );
    if (picked == null) return;
    final normalized = DateTime(picked.year, picked.month, picked.day);
    setState(() {
      if (isStart) {
        _startDate = normalized;
        if (_endDate != null && _endDate!.isBefore(normalized)) {
          _endDate = normalized;
        }
      } else {
        _endDate = normalized;
      }
    });
  }

  Future<void> _submit(
      AppLocalizations l, Map<String, EnrolledCourse> dayCourseMap) async {
    if (!_isValid) {
      _showSnackBar(l.createLeaveValidationRequiredFields,
          isError: true);
      return;
    }

    if (dayCourseMap.isNotEmpty &&
        (!_isSelectableDay(_startDate!, dayCourseMap) ||
            !_isSelectableDay(_endDate!, dayCourseMap))) {
      _showSnackBar(l.createLeaveNoClassOnDateError, isError: true);
      return;
    }

    final user = ref.read(currentUserProvider).valueOrNull;
    if (user == null) {
      _showSnackBar(l.createLeaveSessionExpiredError,
          isError: true);
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      await ref.read(studentServiceProvider).createLeaveRequest(
            studentId: user.id,
            type: _leaveType!.name.capitalize,
            reason: _reasonController.text.trim(),
            startDate: _isoDate(_startDate!),
            endDate: _isoDate(_endDate!),
          );
      ref.invalidate(studentLeaveRequestsProvider);
      if (mounted) setState(() => _submitted = true);
    } catch (e) {
      if (mounted) {
        _showSnackBar(l.createLeaveSubmitError,
            isError: true);
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message,
            style: AppTextStyles.body.copyWith(color: Colors.white)),
        backgroundColor:
            isError ? AppColors.statusRed : AppColors.statusGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  // ── build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final coursesAsync = ref.watch(studentCoursesProvider);
    final dayCourseMap = _buildDayCourseMap(coursesAsync.valueOrNull ?? const []);
    if (_submitted) return _buildSuccessScreen(l, dayCourseMap);

    final affectedCourses = _affectedCourses(dayCourseMap);

    return Scaffold(
      backgroundColor: AppColors.bgPage,
      appBar: _buildAppBar(context, l),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPolicyBanner(l),
            const SizedBox(height: AppSpacing.sectionGap),
            _buildLeaveTypeGrid(l),
            const SizedBox(height: AppSpacing.sectionGap),
            _buildDateFields(l, dayCourseMap),
            if (_startDate != null && _endDate != null) ...[
              const SizedBox(height: 8),
              _buildDurationChip(l),
            ],
            if (affectedCourses.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.sectionGap),
              _buildAffectedCourses(affectedCourses, l),
            ],
            const SizedBox(height: AppSpacing.sectionGap),
            _buildReasonField(l),
            const SizedBox(height: AppSpacing.sectionGap),
            _buildAttachmentArea(l),
            const SizedBox(height: AppSpacing.xl),
            _buildSubmitButton(l, dayCourseMap),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, AppLocalizations l) {
    return AppBar(
      backgroundColor: AppColors.bgPage,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, size: 18),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Text(l.createLeaveAppBarTitle, style: AppTextStyles.h3),
    );
  }

  Widget _buildPolicyBanner(AppLocalizations l) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.primaryNavy,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, color: Colors.white, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l.createLeavePolicyBannerTitle, style: AppTextStyles.h3White),
                const SizedBox(height: 4),
                Text(
                  l.createLeavePolicyBannerMessage,
                  style: AppTextStyles.bodyWhite.copyWith(height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaveTypeGrid(AppLocalizations l) {
    final types = [
      (type: _LeaveType.medical,  icon: Icons.local_hospital_outlined,   label: l.createLeaveTypeMedical),
      (type: _LeaveType.personal, icon: Icons.person_outline,            label: l.createLeaveTypePersonal),
      (type: _LeaveType.family,   icon: Icons.family_restroom_outlined,  label: l.createLeaveTypeFamily),
      (type: _LeaveType.other,    icon: Icons.more_horiz,                label: l.createLeaveTypeOther),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('LEAVE TYPE', style: AppTextStyles.label),
        const SizedBox(height: 8),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 2.2,
          children: types.map((t) {
            final isSelected = _leaveType == t.type;
            return GestureDetector(
              onTap: () => setState(() => _leaveType = t.type),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primaryNavy.withValues(alpha: 0.08)
                      : AppColors.bgCard,
                  borderRadius:
                      BorderRadius.circular(AppSpacing.cardRadius),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primaryNavy
                        : AppColors.border,
                    width: isSelected ? 1.5 : 1,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(t.icon,
                        color: isSelected
                            ? AppColors.primaryNavy
                            : AppColors.textSecondary,
                        size: 22),
                    const SizedBox(height: 4),
                    Text(t.label,
                        style: AppTextStyles.caption.copyWith(
                            color: isSelected
                                ? AppColors.primaryNavy
                                : AppColors.textSecondary,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.normal)),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDateFields(
      AppLocalizations l, Map<String, EnrolledCourse> dayCourseMap) {
    return Column(
      children: [
        _buildDateTile(l.createLeaveStartDateLabel, _startDate,
            () => _pickDate(true, dayCourseMap), l),
        const SizedBox(height: 12),
        _buildDateTile(l.createLeaveEndDateLabel, _endDate,
            () => _pickDate(false, dayCourseMap), l),
      ],
    );
  }

  Widget _buildAffectedCourses(List<EnrolledCourse> courses, AppLocalizations l) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l.createLeaveAffectedCoursesLabel, style: AppTextStyles.label),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: courses.map((c) {
            return Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.statusBlueBg,
                borderRadius: BorderRadius.circular(AppSpacing.chipRadius),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.menu_book_outlined,
                      size: 14, color: AppColors.primaryBlue),
                  const SizedBox(width: 6),
                  Text('${c.name} (${c.code})',
                      style: AppTextStyles.caption.copyWith(
                          color: AppColors.primaryBlue,
                          fontWeight: FontWeight.w600)),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDateTile(String label, DateTime? date, VoidCallback onTap, AppLocalizations l) {
    final hasValue = date != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.label),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.bgCard,
              borderRadius:
                  BorderRadius.circular(AppSpacing.inputRadius),
              border: Border.all(
                color: hasValue
                    ? AppColors.primaryNavy
                    : AppColors.border,
                width: hasValue ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    date != null ? _formatDate(date) : l.createLeaveDatePlaceholder,
                    style: AppTextStyles.body.copyWith(
                      color: hasValue
                          ? AppColors.textPrimary
                          : AppColors.textLabel,
                    ),
                  ),
                ),
                Icon(Icons.calendar_today_outlined,
                    color: hasValue
                        ? AppColors.primaryNavy
                        : AppColors.textLabel,
                    size: 18),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDurationChip(AppLocalizations l) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.statusBlueBg,
        borderRadius: BorderRadius.circular(AppSpacing.chipRadius),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.schedule,
              color: AppColors.primaryBlue, size: 14),
          const SizedBox(width: 6),
          Text(
            l.createLeaveDurationChipLabel(_totalDays),
            style: AppTextStyles.caption.copyWith(
                color: AppColors.primaryBlue,
                fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildReasonField(AppLocalizations l) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l.createLeaveReasonSectionLabel, style: AppTextStyles.label),
        const SizedBox(height: 8),
        TextField(
          controller: _reasonController,
          maxLines: 5,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            hintText: l.createLeaveReasonHint,
            alignLabelWithHint: true,
          ),
        ),
        const SizedBox(height: 4),
        Align(
          alignment: Alignment.centerRight,
          child: Text(l.createLeaveCharCount(_reasonController.text.length),
              style: AppTextStyles.caption),
        ),
      ],
    );
  }

  Widget _buildAttachmentArea(AppLocalizations l) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l.createLeaveAttachmentsSectionLabel, style: AppTextStyles.label),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 28),
          decoration: BoxDecoration(
            color: AppColors.bgCard,
            borderRadius:
                BorderRadius.circular(AppSpacing.cardRadius),
            border:
                Border.all(color: AppColors.border, width: 1.5),
          ),
          child: Column(
            children: [
              Icon(Icons.cloud_upload_outlined,
                  color: AppColors.textLabel, size: 32),
              const SizedBox(height: 8),
              Text(
                l.createLeaveAttachmentsHint,
                style: AppTextStyles.body
                    .copyWith(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton(
      AppLocalizations l, Map<String, EnrolledCourse> dayCourseMap) {
    return AnimatedOpacity(
      opacity: _isValid ? 1.0 : 0.5,
      duration: const Duration(milliseconds: 200),
      child: SizedBox(
        width: double.infinity,
        height: AppSpacing.buttonHeight,
        child: ElevatedButton.icon(
          onPressed: _isSubmitting ? null : () => _submit(l, dayCourseMap),
          icon: _isSubmitting
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white),
                )
              : const Icon(Icons.send_outlined, size: 18),
          label: Text(
              _isSubmitting ? l.createLeaveSubmittingButton : l.createLeaveSubmitButton,
              style: AppTextStyles.button),
        ),
      ),
    );
  }

  // ── Success screen ─────────────────────────────────────────────────────────

  Widget _buildSuccessScreen(
      AppLocalizations l, Map<String, EnrolledCourse> dayCourseMap) {
    final leaveLabel = _leaveType?.name.capitalize ?? '';
    final affectedCourses = _affectedCourses(dayCourseMap);
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.statusGreenBg,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.check_circle_outline,
                    color: AppColors.statusGreen, size: 44),
              ),
              const SizedBox(height: 24),
              Text(l.createLeaveSuccessTitle,
                  style: AppTextStyles.h1,
                  textAlign: TextAlign.center),
              const SizedBox(height: 12),
              Text(
                l.createLeaveSuccessMessage(leaveLabel),
                style: AppTextStyles.body.copyWith(
                    color: AppColors.textSecondary, height: 1.6),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),
              _buildSummaryCard(leaveLabel, l, affectedCourses),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: AppSpacing.buttonHeight,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(l.createLeaveBackToListButton,
                      style: AppTextStyles.button),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard(String leaveLabel, AppLocalizations l,
      List<EnrolledCourse> affectedCourses) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          _summaryRow(l.createLeaveSummaryTypeLabel, l.createLeaveSummaryTypeValue(leaveLabel)),
          Divider(color: AppColors.divider, height: 20),
          _summaryRow(l.createLeaveSummaryPeriodLabel,
              '${_formatDate(_startDate!)} → ${_formatDate(_endDate!)}'),
          Divider(color: AppColors.divider, height: 20),
          _summaryRow(l.createLeaveSummaryDurationLabel,
              l.createLeaveSummaryDurationValue(_totalDays)),
          if (affectedCourses.isNotEmpty) ...[
            Divider(color: AppColors.divider, height: 20),
            _summaryRow(l.createLeaveSummaryCoursesLabel,
                affectedCourses.map((c) => c.code).join(', ')),
          ],
          Divider(color: AppColors.divider, height: 20),
          _summaryRow(l.createLeaveSummaryStatusLabel, l.createLeaveSummaryStatusValue),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: AppTextStyles.body
                .copyWith(color: AppColors.textSecondary)),
        Flexible(
          child: Text(value,
              style: AppTextStyles.bodyMedium,
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis),
        ),
      ],
    );
  }
}

// ── Extension ──────────────────────────────────────────────────────────────────

extension _StringExt on String {
  String get capitalize =>
      isEmpty ? '' : '${this[0].toUpperCase()}${substring(1)}';
}
