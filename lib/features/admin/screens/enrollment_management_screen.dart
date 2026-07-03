import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/providers/admin_providers.dart';
import '../../../core/services/admin_service.dart';

// ── File-level helpers ─────────────────────────────────────────────────────────

Color _shiftColor(String shift) {
  switch (shift) {
    case 'morning':   return const Color(0xFFD97706);
    case 'afternoon': return AppColors.primaryBlue;
    case 'evening':   return const Color(0xFF7C3AED);
    default:          return AppColors.primaryNavy;
  }
}

String _shiftLabel(String shift) {
  switch (shift) {
    case 'morning':   return 'Morning';
    case 'afternoon': return 'Afternoon';
    case 'evening':   return 'Evening';
    default:          return shift;
  }
}

Widget _programChip(String programType) {
  final color = programType == 'international'
      ? AppColors.primaryBlue
      : const Color(0xFF2E7D32);
  final label = programType == 'international' ? 'Intl' : 'Natl';
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.10),
      borderRadius: BorderRadius.circular(4),
    ),
    child: Text(label,
        style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.w600)),
  );
}

Widget _scheduleChip(String scheduleType) {
  final color = scheduleType == 'weekend'
      ? const Color(0xFFD97706)
      : AppColors.primaryNavy;
  final label = scheduleType == 'weekend' ? 'Wknd' : 'Wkdy';
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.10),
      borderRadius: BorderRadius.circular(4),
    ),
    child: Text(label,
        style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.w600)),
  );
}

// ── Screen ────────────────────────────────────────────────────────────────────

class EnrollmentManagementScreen extends ConsumerStatefulWidget {
  const EnrollmentManagementScreen({super.key});

  @override
  ConsumerState<EnrollmentManagementScreen> createState() =>
      _EnrollmentManagementScreenState();
}

class _EnrollmentManagementScreenState
    extends ConsumerState<EnrollmentManagementScreen> {
  String _filter = 'All';

  List<AdminEnrollmentRecord> _applyFilter(List<AdminEnrollmentRecord> all) {
    switch (_filter) {
      case 'Under 50%':
        return all.where((r) => r.pct < 0.5).toList();
      case 'Near Full':
        return all.where((r) => r.pct >= 0.8 && r.pct < 1.0).toList();
      case 'Full':
        return all.where((r) => r.pct >= 1.0).toList();
      default:
        return all;
    }
  }

  Color _barColor(double pct) {
    if (pct >= 1.0) return AppColors.statusRed;
    if (pct >= 0.8) return AppColors.statusAmber;
    if (pct >= 0.5) return AppColors.primaryNavy;
    return AppColors.primaryBlue;
  }

  @override
  Widget build(BuildContext context) {
    final enrollAsync = ref.watch(adminEnrollmentProvider);
    ref.watch(adminStudentsProvider);
    ref.watch(adminSemestersProvider);

    return Scaffold(
      backgroundColor: AppColors.bgPage,
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showEnrollSheet(context),
        backgroundColor: AppColors.primaryBlue,
        child: const Icon(Icons.person_add_outlined, color: Colors.white),
      ),
      body: enrollAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, color: AppColors.statusRed, size: 40),
              const SizedBox(height: 8),
              Text('Could not load enrollment data', style: AppTextStyles.bodyMedium),
              TextButton(
                onPressed: () => ref.invalidate(adminEnrollmentProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (allRecords) {
          final filtered = _applyFilter(allRecords);
          return ListView(
            padding: const EdgeInsets.all(AppSpacing.screenPadding),
            children: [
              _buildActivePeriodCard(),
              const SizedBox(height: 12),
              _buildStatsCard(allRecords),
              const SizedBox(height: 20),
              Text('Class Enrollment',
                  style: AppTextStyles.h2.copyWith(color: AppColors.primaryNavy)),
              const SizedBox(height: 4),
              Text('Capacity tracking across all active classes',
                  style: AppTextStyles.caption),
              const SizedBox(height: 12),
              _buildFilterChips(),
              const SizedBox(height: 12),
              if (filtered.isEmpty)
                Container(
                  padding: const EdgeInsets.all(AppSpacing.cardPadding),
                  decoration: BoxDecoration(
                    color: AppColors.bgCard,
                    borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Center(
                    child: Text('No classes in this category', style: AppTextStyles.caption),
                  ),
                )
              else
                ...filtered.map((r) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _EnrollmentCard(
                        record: r,
                        barColor: _barColor(r.pct),
                        onViewStudents: () => _showClassStudentsSheet(context, r),
                      ),
                    )),
              const SizedBox(height: 80),
            ],
          );
        },
      ),
    );
  }

  // ── Cards ─────────────────────────────────────────────────────────────────

  Widget _buildActivePeriodCard() {
    final semesters = ref.watch(adminSemestersProvider).valueOrNull ?? [];
    final current   = semesters.where((s) => s.isCurrent).firstOrNull;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.primaryNavy,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
      ),
      child: Row(
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.calendar_today_outlined, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('ACTIVE PERIOD',
                    style: AppTextStyles.label.copyWith(
                        color: Colors.white.withValues(alpha: 0.7),
                        letterSpacing: 1, fontSize: 9)),
                const SizedBox(height: 2),
                Text(current?.name ?? 'No active semester',
                    style: AppTextStyles.h3.copyWith(color: Colors.white)),
                if (current != null)
                  Text('${current.fmtStart} – ${current.fmtEnd}',
                      style: AppTextStyles.caption
                          .copyWith(color: Colors.white.withValues(alpha: 0.7))),
              ],
            ),
          ),
          if (current?.registrationOpen == true)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.statusGreen.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(AppSpacing.tagRadius),
              ),
              child: Text('Open',
                  style: AppTextStyles.label.copyWith(color: Colors.white, letterSpacing: 0.3)),
            ),
        ],
      ),
    );
  }

  Widget _buildStatsCard(List<AdminEnrollmentRecord> records) {
    final totalEnrolled = records.fold(0, (s, r) => s + r.enrolled);
    final totalSeats    = records.fold(0, (s, r) => s + r.maxStudents);
    final available     = totalSeats - totalEnrolled;
    final fullCount     = records.where((r) => r.pct >= 1.0).length;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          _StatPill(label: 'Enrolled', value: '$totalEnrolled', color: AppColors.primaryBlue),
          _StatDivider(),
          _StatPill(label: 'Available', value: '$available', color: AppColors.statusGreen),
          _StatDivider(),
          _StatPill(label: 'Full', value: '$fullCount', color: AppColors.statusRed),
          _StatDivider(),
          _StatPill(label: 'Total Seats', value: '$totalSeats', color: AppColors.textSecondary),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    const filters = ['All', 'Under 50%', 'Near Full', 'Full'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((f) {
          final isSelected = f == _filter;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => setState(() => _filter = f),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primaryNavy : Colors.white,
                  borderRadius: BorderRadius.circular(AppSpacing.chipRadius),
                  border: Border.all(
                      color: isSelected ? AppColors.primaryNavy : AppColors.border),
                ),
                child: Text(f,
                    style: AppTextStyles.caption.copyWith(
                        color: isSelected ? Colors.white : AppColors.textSecondary,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal)),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ── Enroll student sheet ──────────────────────────────────────────────────

  Future<void> _showEnrollSheet(BuildContext context) async {
    final students = ref.read(adminStudentsProvider).valueOrNull ?? [];
    final records  = ref.read(adminEnrollmentProvider).valueOrNull ?? [];
    final semesters = ref.read(adminSemestersProvider).valueOrNull ?? [];

    // Filter classes to current semester if available
    final currentSemId = semesters.where((s) => s.isCurrent).firstOrNull?.id;
    final classesToShow = currentSemId != null
        ? records.where((r) => r.semesterId == currentSemId).toList()
        : records;

    AdminStudent? selectedStudent;
    AdminEnrollmentRecord? selectedClass;
    String searchQuery = '';
    bool saving = false;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) {
          final filteredStudents = searchQuery.isEmpty
              ? students
              : students.where((s) {
                  final q = searchQuery.toLowerCase();
                  return s.fullName.toLowerCase().contains(q) ||
                      s.studentCode.toLowerCase().contains(q);
                }).toList();

          return Padding(
            padding: EdgeInsets.fromLTRB(
                16, 20, 16, MediaQuery.of(ctx).viewInsets.bottom + 24),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Enroll Student',
                      style: AppTextStyles.h3.copyWith(color: AppColors.primaryNavy)),
                  if (currentSemId != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Showing classes for current semester',
                      style: AppTextStyles.caption.copyWith(color: AppColors.primaryBlue),
                    ),
                  ],
                  const SizedBox(height: 16),

                  // Student search
                  Text('Student',
                      style: AppTextStyles.caption
                          .copyWith(fontSize: 11, color: AppColors.textSecondary)),
                  const SizedBox(height: 4),
                  if (selectedStudent == null) ...[
                    TextField(
                      autofocus: true,
                      onChanged: (v) => setSheet(() => searchQuery = v),
                      style: AppTextStyles.body,
                      decoration: _inputDecoration('Search by name or code…'),
                    ),
                    if (searchQuery.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Container(
                        constraints: const BoxConstraints(maxHeight: 200),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: filteredStudents.isEmpty
                            ? Padding(
                                padding: const EdgeInsets.all(12),
                                child: Text('No students found', style: AppTextStyles.caption),
                              )
                            : ListView.separated(
                                shrinkWrap: true,
                                itemCount: filteredStudents.length.clamp(0, 8),
                                separatorBuilder: (_, idx) =>
                                    Divider(height: 1, color: AppColors.divider),
                                itemBuilder: (_, i) {
                                  final s = filteredStudents[i];
                                  return ListTile(
                                    dense: true,
                                    leading: CircleAvatar(
                                      radius: 16,
                                      backgroundColor:
                                          AppColors.primaryBlue.withValues(alpha: 0.1),
                                      child: Text(s.initials,
                                          style: AppTextStyles.label.copyWith(
                                              color: AppColors.primaryBlue, fontSize: 10)),
                                    ),
                                    title: Text(s.fullName, style: AppTextStyles.body),
                                    subtitle: Text(s.studentCode,
                                        style: AppTextStyles.caption.copyWith(fontSize: 10)),
                                    onTap: () => setSheet(() {
                                      selectedStudent = s;
                                      searchQuery = '';
                                    }),
                                  );
                                },
                              ),
                      ),
                    ],
                  ] else
                    GestureDetector(
                      onTap: () => setSheet(() {
                        selectedStudent = null;
                        searchQuery = '';
                      }),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        decoration: BoxDecoration(
                          color: AppColors.primaryBlue.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
                          border: Border.all(
                              color: AppColors.primaryBlue.withValues(alpha: 0.4)),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(selectedStudent!.fullName,
                                      style: AppTextStyles.bodyMedium
                                          .copyWith(color: AppColors.primaryNavy)),
                                  Text(selectedStudent!.studentCode,
                                      style: AppTextStyles.caption),
                                ],
                              ),
                            ),
                            Icon(Icons.close, size: 16, color: AppColors.textSecondary),
                          ],
                        ),
                      ),
                    ),

                  const SizedBox(height: 12),

                  // Class dropdown
                  Text('Class',
                      style: AppTextStyles.caption
                          .copyWith(fontSize: 11, color: AppColors.textSecondary)),
                  const SizedBox(height: 4),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.bgInput,
                      borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<AdminEnrollmentRecord>(
                        value: selectedClass,
                        isExpanded: true,
                        hint: Text('Select class',
                            style: AppTextStyles.caption.copyWith(color: AppColors.textLabel)),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                        items: classesToShow
                            .map((r) => DropdownMenuItem(
                                  value: r,
                                  child: Text(
                                    '${r.courseCode}-${r.classCode} · ${_shiftLabel(r.shift)} · ${r.courseName}',
                                    style: AppTextStyles.body,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ))
                            .toList(),
                        onChanged: (v) => setSheet(() => selectedClass = v),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryNavy,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: (saving || selectedStudent == null || selectedClass == null)
                          ? null
                          : () async {
                              setSheet(() => saving = true);
                              try {
                                await ref.read(adminServiceProvider).enrollStudent(
                                  studentId: selectedStudent!.id,
                                  classId: selectedClass!.classId,
                                );
                                ref.invalidate(adminEnrollmentProvider);
                                ref.invalidate(
                                    classEnrollmentsProvider(selectedClass!.classId));
                                if (ctx.mounted) Navigator.pop(ctx);
                              } catch (e) {
                                setSheet(() => saving = false);
                                if (ctx.mounted) {
                                  final msg = e.toString().contains('unique')
                                      ? 'Student is already enrolled in this course for the semester.'
                                      : 'Error: $e';
                                  ScaffoldMessenger.of(ctx).showSnackBar(
                                    SnackBar(
                                        content: Text(msg),
                                        backgroundColor: AppColors.statusRed),
                                  );
                                }
                              }
                            },
                      child: saving
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white))
                          : const Text('Enroll Student'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Class students sheet ───────────────────────────────────────────────────

  Future<void> _showClassStudentsSheet(
      BuildContext context, AdminEnrollmentRecord record) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) => _CourseStudentsSheet(
        record: record,
        onDropped: () {
          ref.invalidate(adminEnrollmentProvider);
          ref.invalidate(classEnrollmentsProvider(record.classId));
        },
      ),
    );
  }
}

// ── Stat helpers ──────────────────────────────────────────────────────────────

class _StatPill extends StatelessWidget {
  const _StatPill({required this.label, required this.value, required this.color});
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(value, style: AppTextStyles.h3.copyWith(color: color)),
          Text(label,
              style: AppTextStyles.caption.copyWith(fontSize: 10),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _StatDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      Container(width: 1, height: 32, color: AppColors.border);
}

// ── Enrollment card ───────────────────────────────────────────────────────────

class _EnrollmentCard extends StatelessWidget {
  const _EnrollmentCard({
    required this.record,
    required this.barColor,
    required this.onViewStudents,
  });

  final AdminEnrollmentRecord record;
  final Color barColor;
  final VoidCallback onViewStudents;

  @override
  Widget build(BuildContext context) {
    final pct      = record.pct;
    final pctLabel = '${(pct * 100).toInt()}%';
    final isFull   = pct >= 1.0;
    final shiftCol = _shiftColor(record.shift);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: barColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppSpacing.tagRadius),
                ),
                child: Text(record.courseCode,
                    style: AppTextStyles.label
                        .copyWith(color: barColor, letterSpacing: 0.5)),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: shiftCol.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppSpacing.tagRadius),
                ),
                child: Text(_shiftLabel(record.shift),
                    style: AppTextStyles.label
                        .copyWith(color: shiftCol, fontSize: 10)),
              ),
              const SizedBox(width: 6),
              _programChip(record.programType),
              const SizedBox(width: 6),
              _scheduleChip(record.scheduleType),
              const Spacer(),
              Text('${record.enrolled} / ${record.maxStudents}',
                  style: AppTextStyles.bodySemiBold.copyWith(
                      color: isFull ? AppColors.statusRed : AppColors.textPrimary)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(record.courseName, style: AppTextStyles.bodyMedium),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.bgPage,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: AppColors.border),
                ),
                child: Text('Class ${record.classCode}',
                    style: AppTextStyles.caption.copyWith(fontSize: 10)),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(record.teacherName ?? 'No teacher assigned',
              style: AppTextStyles.caption),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: pct.clamp(0.0, 1.0),
                    minHeight: 8,
                    backgroundColor: AppColors.border,
                    valueColor: AlwaysStoppedAnimation<Color>(barColor),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(pctLabel,
                  style: AppTextStyles.caption
                      .copyWith(color: barColor, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: onViewStudents,
            icon: const Icon(Icons.people_outline, size: 14),
            label: const Text('View Students'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 36),
              foregroundColor: AppColors.primaryNavy,
              side: BorderSide(color: AppColors.border),
              textStyle: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Class students bottom sheet ───────────────────────────────────────────────

class _CourseStudentsSheet extends ConsumerStatefulWidget {
  const _CourseStudentsSheet({required this.record, required this.onDropped});
  final AdminEnrollmentRecord record;
  final VoidCallback onDropped;

  @override
  ConsumerState<_CourseStudentsSheet> createState() => _CourseStudentsSheetState();
}

class _CourseStudentsSheetState extends ConsumerState<_CourseStudentsSheet> {
  final Set<String> _dropping = {};

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(classEnrollmentsProvider(widget.record.classId));

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      builder: (ctx, scrollCtrl) => Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 36, height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(widget.record.courseName,
                    style: AppTextStyles.h3.copyWith(color: AppColors.primaryNavy)),
                const SizedBox(height: 2),
                Text(
                  '${widget.record.courseCode}-${widget.record.classCode} · '
                  '${_shiftLabel(widget.record.shift)} · '
                  '${widget.record.enrolled} enrolled',
                  style: AppTextStyles.caption.copyWith(color: AppColors.primaryBlue),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: AppColors.divider),
          Expanded(
            child: async.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(
                  child: Text('Could not load students', style: AppTextStyles.caption)),
              data: (entries) {
                if (entries.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.people_outline, size: 40, color: AppColors.textLabel),
                        const SizedBox(height: 8),
                        Text('No students enrolled', style: AppTextStyles.caption),
                      ],
                    ),
                  );
                }
                return ListView.separated(
                  controller: scrollCtrl,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: entries.length,
                  separatorBuilder: (_, idx) =>
                      Divider(height: 1, color: AppColors.divider),
                  itemBuilder: (_, i) {
                    final e          = entries[i];
                    final isDropping = _dropping.contains(e.enrollmentId);
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(vertical: 4),
                      leading: CircleAvatar(
                        radius: 20,
                        backgroundColor: AppColors.primaryBlue.withValues(alpha: 0.1),
                        child: Text(e.initials,
                            style: AppTextStyles.label
                                .copyWith(color: AppColors.primaryBlue, fontSize: 12)),
                      ),
                      title: Text(e.studentName, style: AppTextStyles.bodyMedium),
                      subtitle: Text(
                        '${e.studentCode}${e.enrolledAt != null ? ' • ${DateFormat('MMM d, yyyy').format(e.enrolledAt!)}' : ''}',
                        style: AppTextStyles.caption.copyWith(fontSize: 11),
                      ),
                      trailing: isDropping
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2))
                          : TextButton(
                              onPressed: () => _dropStudent(e),
                              style: TextButton.styleFrom(
                                  foregroundColor: AppColors.statusRed),
                              child: const Text('Drop', style: TextStyle(fontSize: 13)),
                            ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _dropStudent(CourseEnrollmentEntry entry) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Drop Student?'),
        content: Text(
          'Remove ${entry.studentName} from ${widget.record.courseName} '
          '(${_shiftLabel(widget.record.shift)} Class ${widget.record.classCode})?',
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: TextButton.styleFrom(foregroundColor: AppColors.statusRed),
              child: const Text('Drop')),
        ],
      ),
    );
    if (confirm != true) return;

    setState(() => _dropping.add(entry.enrollmentId));
    try {
      await ref.read(adminServiceProvider).dropEnrollment(entry.enrollmentId);
      ref.invalidate(classEnrollmentsProvider(widget.record.classId));
      widget.onDropped();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error: $e'),
          backgroundColor: AppColors.statusRed,
        ));
      }
    } finally {
      if (mounted) setState(() => _dropping.remove(entry.enrollmentId));
    }
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────

InputDecoration _inputDecoration(String hint) => InputDecoration(
      hintText: hint,
      hintStyle: AppTextStyles.caption.copyWith(color: AppColors.textLabel),
      filled: true,
      fillColor: AppColors.bgInput,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
        borderSide: BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
        borderSide: BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
        borderSide: BorderSide(color: AppColors.primaryNavy),
      ),
    );
