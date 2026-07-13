import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/providers/admin_providers.dart';
import '../../../core/services/admin_service.dart';
import '../../../shared/widgets/app_toast.dart';

class AcademicCalendarScreen extends ConsumerStatefulWidget {
  const AcademicCalendarScreen({super.key});

  @override
  ConsumerState<AcademicCalendarScreen> createState() =>
      _AcademicCalendarScreenState();
}

class _AcademicCalendarScreenState extends ConsumerState<AcademicCalendarScreen> {
  String? _selectedYearId;

  @override
  Widget build(BuildContext context) {
    final yearsAsync = ref.watch(adminAcademicYearsProvider);
    final semestersAsync = ref.watch(adminSemestersProvider);

    return Scaffold(
      backgroundColor: AppColors.bgPage,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAcademicYearSheet(context),
        backgroundColor: AppColors.primaryNavy,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Year', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: yearsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, color: AppColors.statusRed, size: 40),
              const SizedBox(height: 8),
              Text('Could not load academic calendar', style: AppTextStyles.bodyMedium),
              TextButton(
                onPressed: () {
                  ref.invalidate(adminAcademicYearsProvider);
                  ref.invalidate(adminSemestersProvider);
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (years) {
          return semestersAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.error_outline, color: AppColors.statusRed, size: 40),
                  const SizedBox(height: 8),
                  Text('Could not load semesters', style: AppTextStyles.bodyMedium),
                  TextButton(
                    onPressed: () => ref.invalidate(adminSemestersProvider),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
            data: (semesters) {
              if (years.isEmpty) {
                return ListView(
                  padding: const EdgeInsets.all(AppSpacing.screenPadding),
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 60),
                    Center(
                      child: Column(
                        children: [
                          Icon(Icons.calendar_month_outlined, size: 48, color: AppColors.textLabel),
                          const SizedBox(height: 12),
                          Text('No academic years yet', style: AppTextStyles.bodyMedium),
                          const SizedBox(height: 6),
                          Text('Tap "+ Add Year" to define the first academic year.',
                              style: AppTextStyles.caption, textAlign: TextAlign.center),
                        ],
                      ),
                    ),
                  ],
                );
              }

              // Pre-select first academic year on first load
              if (_selectedYearId == null || !years.any((y) => y.id == _selectedYearId)) {
                _selectedYearId = years.first.id;
              }

              final selectedYear = years.firstWhere((y) => y.id == _selectedYearId, orElse: () => years.first);
              final yearSemesters = semesters.where((s) => s.academicYearId == selectedYear.id).toList()
                ..sort((a, b) => a.startDate.compareTo(b.startDate));

              return ListView(
                padding: const EdgeInsets.all(AppSpacing.screenPadding),
                children: [
                  _buildHeader(),
                  const SizedBox(height: 16),
                  
                  // Horizontal Year Tabs
                  SizedBox(
                    height: 40,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: years.length,
                      itemBuilder: (context, idx) {
                        final y = years[idx];
                        final isSelected = y.id == _selectedYearId;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  y.name,
                                  style: TextStyle(
                                    color: isSelected ? Colors.white : AppColors.textPrimary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                                // Active badge removed to prevent confusion with simultaneous cohort semesters,
                              ],
                            ),
                            selected: isSelected,
                            selectedColor: AppColors.primaryNavy,
                            backgroundColor: AppColors.bgCard,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: BorderSide(color: isSelected ? AppColors.primaryNavy : AppColors.border),
                            ),
                            onSelected: (val) {
                              if (val) setState(() => _selectedYearId = y.id);
                            },
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Selected Year Banner Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.bgCard,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: selectedYear.isCurrent ? AppColors.statusBlueBg : AppColors.statusGrayBg,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.calendar_today_outlined,
                            color: selectedYear.isCurrent ? AppColors.primaryBlue : AppColors.textSecondary,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Academic Year ${selectedYear.name}',
                                style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold, fontSize: 15),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${selectedYear.fmtStart} – ${selectedYear.fmtEnd}',
                                style: AppTextStyles.caption.copyWith(fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        PopupMenuButton<String>(
                          icon: Icon(Icons.more_vert, color: AppColors.textSecondary),
                          onSelected: (v) {
                            if (v == 'edit') _showAcademicYearSheet(context, year: selectedYear);
                            if (v == 'delete') _confirmDeleteAcademicYear(selectedYear);
                          },
                          itemBuilder: (_) => [
                            const PopupMenuItem(
                              value: 'edit',
                              child: Row(children: [
                                Icon(Icons.edit_outlined, size: 16),
                                SizedBox(width: 8),
                                Text('Edit Year'),
                              ]),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Row(children: [
                                Icon(Icons.delete_outline, size: 16, color: Colors.red),
                                SizedBox(width: 8),
                                Text('Delete Year', style: TextStyle(color: Colors.red)),
                              ]),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Semesters List Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Semesters',
                        style: AppTextStyles.h3.copyWith(color: AppColors.primaryNavy, fontWeight: FontWeight.bold),
                      ),
                      TextButton.icon(
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.primaryBlue,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: () => _showSemesterSheet(context, parentYear: selectedYear),
                        icon: const Icon(Icons.add, size: 16),
                        label: const Text('Add Semester', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  if (yearSemesters.isEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      decoration: BoxDecoration(
                        color: AppColors.bgCard,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border, style: BorderStyle.solid),
                      ),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(Icons.calendar_view_month_outlined, size: 36, color: AppColors.textLabel),
                            const SizedBox(height: 8),
                            Text('No semesters defined yet', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
                            const SizedBox(height: 4),
                            Text('Tap "Add Semester" to create one for this year.', style: AppTextStyles.caption),
                          ],
                        ),
                      ),
                    )
                  else
                    ...yearSemesters.map((s) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _SemesterCard(
                            semester: s,
                            onEdit: () => _showSemesterSheet(context, parentYear: selectedYear, semester: s),
                            onDelete: () => _confirmDeleteSemester(s),
                          ),
                        )),
                  const SizedBox(height: 80),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Academic Calendar',
            style: AppTextStyles.h1.copyWith(color: AppColors.primaryNavy)),
        const SizedBox(height: 4),
        Text('Manage academic years and their associated semesters in a unified structure.',
            style: AppTextStyles.caption),
      ],
    );
  }

  // ── Actions ──────────────────────────────────────────────────────────────────

  Future<void> _confirmDeleteSemester(AdminSemester s) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Semester'),
        content: Text('Are you sure you want to delete "${s.name}"?\nThis will permanently delete the semester and may fail if classes are already scheduled.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Delete', style: TextStyle(color: AppColors.statusRed)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await ref.read(adminServiceProvider).deleteSemester(s.id);
      ref.invalidate(adminSemestersProvider);
      ref.invalidate(adminAcademicYearsProvider);
      if (mounted) {
        showSuccessToast(context, 'Semester "${s.name}" deleted.');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error: $e'),
          backgroundColor: AppColors.statusRed,
        ));
      }
    }
  }

  Future<void> _confirmDeleteAcademicYear(AdminAcademicYear y) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Academic Year'),
        content: Text('Are you sure you want to delete "${y.name}"?\nAll associated semesters will be permanently deleted.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Delete', style: TextStyle(color: AppColors.statusRed)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await ref.read(adminServiceProvider).deleteAcademicYear(y.id);
      ref.invalidate(adminAcademicYearsProvider);
      ref.invalidate(adminSemestersProvider);
      if (mounted) {
        showSuccessToast(context, 'Academic Year "${y.name}" and all of its semesters deleted.');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error: $e'),
          backgroundColor: AppColors.statusRed,
        ));
      }
    }
  }

  // ── Bottom Sheets ────────────────────────────────────────────────────────────

  Future<void> _showAcademicYearSheet(BuildContext context, {AdminAcademicYear? year}) async {
    final isEdit = year != null;
    final nameCtrl = TextEditingController(text: year?.name ?? '');
    DateTime? startDate = year != null ? DateTime.tryParse(year.startDate) : null;
    DateTime? endDate = year != null ? DateTime.tryParse(year.endDate) : null;
    bool saving = false;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.bgCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) => Padding(
          padding: EdgeInsets.fromLTRB(
              16, 20, 16, MediaQuery.of(ctx).viewInsets.bottom + 24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(isEdit ? 'Edit Academic Year' : 'New Academic Year',
                    style: AppTextStyles.h3.copyWith(color: AppColors.primaryNavy)),
                const SizedBox(height: 16),
                _SheetField(label: 'Academic Year Name', controller: nameCtrl, hint: 'e.g. 2026-2027'),
                const SizedBox(height: 12),
                _DatePickerRow(
                  label: 'Start Date',
                  date: startDate,
                  onPick: () async {
                    final d = await showDatePicker(
                      context: ctx,
                      initialDate: startDate ?? DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2035),
                    );
                    if (d != null) {
                      setSheet(() {
                        startDate = d;
                        if (endDate == null || endDate!.isBefore(d)) {
                          endDate = d.add(const Duration(days: 300));
                        }
                      });
                    }
                  },
                ),
                const SizedBox(height: 12),
                _DatePickerRow(
                  label: 'End Date',
                  date: endDate,
                  onPick: () async {
                    DateTime initialEndDate = endDate ?? (startDate ?? DateTime.now());
                    if (startDate != null && initialEndDate.isBefore(startDate!)) {
                      initialEndDate = startDate!;
                    }
                    final d = await showDatePicker(
                      context: ctx,
                      initialDate: initialEndDate,
                      firstDate: startDate ?? DateTime(2020),
                      lastDate: DateTime(2035),
                    );
                    if (d != null) setSheet(() => endDate = d);
                  },
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryNavy,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: saving
                        ? null
                        : () async {
                            final name = nameCtrl.text.trim();
                            if (name.isEmpty || startDate == null || endDate == null) {
                              ScaffoldMessenger.of(ctx).showSnackBar(
                                const SnackBar(content: Text('Please fill in all fields')),
                              );
                              return;
                            }
                            if (endDate!.isBefore(startDate!)) {
                              ScaffoldMessenger.of(ctx).showSnackBar(
                                const SnackBar(content: Text('End date must be after start date')),
                              );
                              return;
                            }
                            setSheet(() => saving = true);
                            final startStr = DateFormat('yyyy-MM-dd').format(startDate!);
                            final endStr = DateFormat('yyyy-MM-dd').format(endDate!);
                            try {
                              final svc = ref.read(adminServiceProvider);
                              if (isEdit) {
                                await svc.updateAcademicYear(
                                  academicYearId: year.id,
                                  name: name,
                                  startDate: startStr,
                                  endDate: endStr,
                                );
                              } else {
                                await svc.createAcademicYear(
                                  name: name,
                                  startDate: startStr,
                                  endDate: endStr,
                                );
                              }
                              ref.invalidate(adminAcademicYearsProvider);
                              if (ctx.mounted) Navigator.pop(ctx);
                              if (context.mounted) {
                                showSuccessToast(context, isEdit ? 'Academic Year updated.' : 'Academic Year created.');
                              }
                            } catch (e) {
                              setSheet(() => saving = false);
                              if (ctx.mounted) {
                                ScaffoldMessenger.of(ctx).showSnackBar(
                                  SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.statusRed),
                                );
                              }
                            }
                          },
                    child: saving
                        ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : Text(isEdit ? 'Save Changes' : 'Create Academic Year'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    nameCtrl.dispose();
  }

  Future<void> _showSemesterSheet(BuildContext context, {required AdminAcademicYear parentYear, AdminSemester? semester}) async {
    final isEdit = semester != null;
    final nameCtrl = TextEditingController(text: semester?.name ?? '');

    final parentStart = DateTime.parse(parentYear.startDate);
    final parentEnd = DateTime.parse(parentYear.endDate);

    // Initial dates constrained to parent Academic Year
    DateTime? startDate = semester != null
        ? DateTime.tryParse(semester.startDate)
        : parentStart; // Default to parent academic year start
    DateTime? endDate = semester != null
        ? DateTime.tryParse(semester.endDate)
        : parentStart.add(const Duration(days: 120)).isBefore(parentEnd)
            ? parentStart.add(const Duration(days: 120))
            : parentEnd; // Default to 4 months later or clamped to parent end

    bool saving = false;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.bgCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) => Padding(
          padding: EdgeInsets.fromLTRB(
              16, 20, 16, MediaQuery.of(ctx).viewInsets.bottom + 24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(isEdit ? 'Edit Semester' : 'New Semester',
                    style: AppTextStyles.h3.copyWith(color: AppColors.primaryNavy)),
                const SizedBox(height: 8),
                Text('Creating semester for Academic Year: ${parentYear.name}',
                    style: AppTextStyles.caption.copyWith(color: AppColors.primaryBlue, fontWeight: FontWeight.w600)),
                const SizedBox(height: 16),
                _SheetField(label: 'Semester Name', controller: nameCtrl, hint: 'e.g. Semester 1'),
                const SizedBox(height: 12),
                
                // Read-only Academic Year label, locked
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Academic Year', style: AppTextStyles.caption.copyWith(fontSize: 11, color: AppColors.textSecondary)),
                    const SizedBox(height: 4),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppColors.bgPage,
                        borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Text(
                        parentYear.name,
                        style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                
                // Start date (constrained by parent dates)
                _DatePickerRow(
                  label: 'Start Date',
                  date: startDate,
                  onPick: () async {
                    final d = await showDatePicker(
                      context: ctx,
                      initialDate: startDate ?? parentStart,
                      firstDate: parentStart,
                      lastDate: parentEnd,
                    );
                    if (d != null) {
                      setSheet(() {
                        startDate = d;
                        if (endDate == null || endDate!.isBefore(d)) {
                          final nextEnd = d.add(const Duration(days: 120));
                          endDate = nextEnd.isBefore(parentEnd) ? nextEnd : parentEnd;
                        }
                      });
                    }
                  },
                ),
                const SizedBox(height: 12),
                
                // End date (constrained by parent dates)
                _DatePickerRow(
                  label: 'End Date',
                  date: endDate,
                  onPick: () async {
                    DateTime initialEndDate = endDate ?? (startDate ?? parentStart);
                    if (startDate != null && initialEndDate.isBefore(startDate!)) {
                      initialEndDate = startDate!;
                    }
                    if (initialEndDate.isBefore(parentStart)) {
                      initialEndDate = parentStart;
                    }
                    if (initialEndDate.isAfter(parentEnd)) {
                      initialEndDate = parentEnd;
                    }

                    final d = await showDatePicker(
                      context: ctx,
                      initialDate: initialEndDate,
                      firstDate: startDate ?? parentStart,
                      lastDate: parentEnd,
                    );
                    if (d != null) setSheet(() => endDate = d);
                  },
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryNavy,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: saving
                        ? null
                        : () async {
                            final name = nameCtrl.text.trim();
                            if (name.isEmpty || startDate == null || endDate == null) {
                              ScaffoldMessenger.of(ctx).showSnackBar(
                                const SnackBar(content: Text('Please fill in all fields')),
                              );
                              return;
                            }
                            if (endDate!.isBefore(startDate!)) {
                              ScaffoldMessenger.of(ctx).showSnackBar(
                                const SnackBar(content: Text('End date must be after start date')),
                              );
                              return;
                            }
                            setSheet(() => saving = true);
                            final startStr = DateFormat('yyyy-MM-dd').format(startDate!);
                            final endStr = DateFormat('yyyy-MM-dd').format(endDate!);
                            try {
                              final svc = ref.read(adminServiceProvider);
                              if (isEdit) {
                                await svc.updateSemester(
                                  semesterId: semester.id,
                                  name: name,
                                  academicYearId: parentYear.id,
                                  startDate: startStr,
                                  endDate: endStr,
                                );
                              } else {
                                await svc.createSemester(
                                  name: name,
                                  academicYearId: parentYear.id,
                                  startDate: startStr,
                                  endDate: endStr,
                                );
                              }
                              ref.invalidate(adminSemestersProvider);
                              ref.invalidate(adminAcademicYearsProvider);
                              if (ctx.mounted) Navigator.pop(ctx);
                              if (context.mounted) {
                                showSuccessToast(context, isEdit ? 'Semester updated.' : 'Semester created.');
                              }
                            } catch (e) {
                              setSheet(() => saving = false);
                              if (ctx.mounted) {
                                ScaffoldMessenger.of(ctx).showSnackBar(
                                  SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.statusRed),
                                );
                              }
                            }
                          },
                    child: saving
                        ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : Text(isEdit ? 'Save Changes' : 'Create Semester'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    nameCtrl.dispose();
  }
}



// ── Semester Card ─────────────────────────────────────────────────────────────

class _SemesterCard extends StatelessWidget {
  const _SemesterCard({
    required this.semester,
    required this.onEdit,
    required this.onDelete,
  });

  final AdminSemester semester;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  Color get _statusColor {
    switch (semester.statusLabel) {
      case 'ACTIVE':
        return AppColors.primaryBlue;
      case 'UPCOMING':
        return AppColors.statusAmber;
      default:
        return AppColors.statusGray;
    }
  }

  Color get _statusBg {
    switch (semester.statusLabel) {
      case 'ACTIVE':
        return AppColors.statusBlueBg;
      case 'UPCOMING':
        return AppColors.statusAmberBg;
      default:
        return AppColors.statusGrayBg;
    }
  }

  IconData get _icon {
    switch (semester.statusLabel) {
      case 'ACTIVE':
        return Icons.calendar_today_outlined;
      case 'UPCOMING':
        return Icons.access_time_outlined;
      default:
        return Icons.history_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isClosed = semester.statusLabel == 'CLOSED';

    return Opacity(
      opacity: isClosed ? 0.75 : 1.0,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: AppColors.border,
            width: 1.0,
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                // Small indicator block
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: _statusBg,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(_icon, color: _statusColor, size: 16),
                ),
                const SizedBox(width: 10),
                
                // Semester Name & dates
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            semester.name,
                            style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                          ),
                          // Current tag removed
                        ],
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(Icons.calendar_month_outlined, size: 11, color: AppColors.textSecondary),
                          const SizedBox(width: 3),
                          Text(
                            '${semester.fmtStart} – ${semester.fmtEnd}',
                            style: AppTextStyles.caption.copyWith(fontSize: 10.5),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Status label
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: _statusBg,
                    borderRadius: BorderRadius.circular(AppSpacing.tagRadius),
                  ),
                  child: Text(
                    semester.statusLabel,
                    style: AppTextStyles.label.copyWith(color: _statusColor, fontSize: 8, letterSpacing: 0.5),
                  ),
                ),
                const SizedBox(width: 6),
                
                // Three-dot Options Menu for Semester
                PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert, size: 16, color: AppColors.textSecondary),
                  onSelected: (v) {
                    if (v == 'edit') onEdit();
                    if (v == 'delete') onDelete();
                  },
                  itemBuilder: (_) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(children: [
                        Icon(Icons.edit_outlined, size: 16),
                        SizedBox(width: 8),
                        Text('Edit Semester'),
                      ]),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(children: [
                        Icon(Icons.delete_outline, size: 16, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Delete Semester', style: TextStyle(color: Colors.red)),
                      ]),
                    ),
                  ],
                ),
              ],
            ),
            
            const SizedBox(height: 8),
            Divider(height: 1, color: AppColors.divider),
            const SizedBox(height: 6),
            
            // Bottom stats row
            Row(
              children: [
                Icon(Icons.class_outlined, size: 12, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Text(
                  '${semester.classCount} class${semester.classCount == 1 ? "" : "es"}',
                  style: AppTextStyles.caption.copyWith(fontSize: 11),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Common Helpers ───────────────────────────────────────────────────────────

class _DatePickerRow extends StatelessWidget {
  const _DatePickerRow({required this.label, required this.date, required this.onPick});
  final String label;
  final DateTime? date;
  final VoidCallback onPick;

  @override
  Widget build(BuildContext context) {
    final fmtDate = date != null ? DateFormat('MMM d, yyyy').format(date!) : 'Select Date';
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTextStyles.caption.copyWith(fontSize: 11, color: AppColors.textSecondary)),
              const SizedBox(height: 4),
              InkWell(
                onTap: onPick,
                borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.bgInput,
                    borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_month_outlined, size: 16, color: AppColors.textSecondary),
                      const SizedBox(width: 8),
                      Text(fmtDate, style: AppTextStyles.body.copyWith(color: date != null ? AppColors.textPrimary : AppColors.textLabel)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SheetField extends StatelessWidget {
  const _SheetField({required this.label, required this.controller, this.hint});
  final String label;
  final TextEditingController controller;
  final String? hint;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.caption.copyWith(fontSize: 11, color: AppColors.textSecondary)),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          style: AppTextStyles.body,
          decoration: InputDecoration(
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
          ),
        ),
      ],
    );
  }
}
