import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/providers/admin_providers.dart';
import '../../../core/services/admin_service.dart';
import '../../../shared/widgets/app_toast.dart';

// ── Screen ────────────────────────────────────────────────────────────────────

class SemesterManagementScreen extends ConsumerStatefulWidget {
  const SemesterManagementScreen({super.key});

  @override
  ConsumerState<SemesterManagementScreen> createState() =>
      _SemesterManagementScreenState();
}

class _SemesterManagementScreenState
    extends ConsumerState<SemesterManagementScreen> {
  @override
  Widget build(BuildContext context) {
    final semestersAsync = ref.watch(adminSemestersProvider);

    return Scaffold(
      backgroundColor: AppColors.bgPage,
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showSemesterSheet(context),
        backgroundColor: AppColors.primaryBlue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: semestersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline,
                  color: AppColors.statusRed, size: 40),
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
          final current = semesters.where((s) => s.isCurrent).firstOrNull;

          return ListView(
            padding: const EdgeInsets.all(AppSpacing.screenPadding),
            children: [
              Text('Semester Management',
                  style:
                      AppTextStyles.h1.copyWith(color: AppColors.primaryNavy)),
              const SizedBox(height: 4),
              Text(
                  'Configure and monitor academic periods.',
                  style: AppTextStyles.caption),
              const SizedBox(height: 20),
              ...semesters.map((s) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _SemesterCard(
                      semester: s,
                      onEdit: () => _showSemesterSheet(context, semester: s),
                      onSetCurrent: s.isCurrent
                          ? null
                          : () => _setCurrentSemester(s),
                    ),
                  )),
              const SizedBox(height: 16),
              if (current != null) _buildCurrentFocusCard(current),
              if (current != null) const SizedBox(height: 12),
              _buildOverviewCard(semesters),
              const SizedBox(height: 80),
            ],
          );
        },
      ),
    );
  }

  // ── Actions ──────────────────────────────────────────────────────────────────

  Future<void> _setCurrentSemester(AdminSemester s) async {
    try {
      await ref.read(adminServiceProvider).setCurrentSemester(s.id);
      ref.invalidate(adminSemestersProvider);
      ref.invalidate(adminAcademicYearsProvider);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error: $e'),
          backgroundColor: AppColors.statusRed,
        ));
      }
    }
  }

  // ── Bottom sheet (create / edit) ─────────────────────────────────────────────

  Future<void> _showSemesterSheet(BuildContext context,
      {AdminSemester? semester}) async {
    final isEdit = semester != null;
    final nameCtrl = TextEditingController(text: semester?.name ?? '');
    final academicYears = ref.read(adminAcademicYearsProvider).valueOrNull ?? [];
    var yearOptions = academicYears.map((y) => y.name).toList();
    String? selectedYear = semester?.academicYear;
    if (selectedYear != null && !yearOptions.contains(selectedYear)) {
      yearOptions = [selectedYear, ...yearOptions];
    }
    DateTime? startDate = semester != null
        ? DateTime.tryParse(semester.startDate)
        : null;
    DateTime? endDate = semester != null
        ? DateTime.tryParse(semester.endDate)
        : null;
    bool saving = false;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
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
                    style: AppTextStyles.h3
                        .copyWith(color: AppColors.primaryNavy)),
                const SizedBox(height: 16),
                _SheetField(label: 'Semester Name', controller: nameCtrl,
                    hint: 'e.g. Semester 1'),
                const SizedBox(height: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Academic Year',
                        style: AppTextStyles.caption.copyWith(
                            fontSize: 11, color: AppColors.textSecondary)),
                    const SizedBox(height: 4),
                    DropdownButtonFormField<String>(
                      initialValue: selectedYear,
                      isExpanded: true,
                      hint: Text('Select academic year',
                          style: AppTextStyles.caption
                              .copyWith(color: AppColors.textLabel)),
                      style: AppTextStyles.body.copyWith(color: AppColors.textPrimary),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: AppColors.bgInput,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(AppSpacing.inputRadius),
                          borderSide: BorderSide(color: AppColors.border),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(AppSpacing.inputRadius),
                          borderSide: BorderSide(color: AppColors.border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(AppSpacing.inputRadius),
                          borderSide: BorderSide(color: AppColors.primaryNavy),
                        ),
                      ),
                      items: yearOptions
                          .map((y) => DropdownMenuItem(value: y, child: Text(y)))
                          .toList(),
                      onChanged: (v) => setSheet(() {
                        selectedYear = v;
                        // Default the date range to the academic year's own
                        // range so admins aren't picking dates from scratch;
                        // only applies while creating (dates still untouched).
                        if (!isEdit && startDate == null && endDate == null) {
                          final match = academicYears
                              .where((y) => y.name == v)
                              .firstOrNull;
                          if (match != null) {
                            startDate = DateTime.tryParse(match.startDate);
                            endDate = DateTime.tryParse(match.endDate);
                          }
                        }
                      }),
                    ),
                    if (yearOptions.isEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          'No academic years defined yet — create one in the Academic Years tab.',
                          style: AppTextStyles.caption
                              .copyWith(fontSize: 11, color: AppColors.statusAmber),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                // Start date
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
                    if (d != null) setSheet(() => startDate = d);
                  },
                ),
                const SizedBox(height: 12),
                // End date
                _DatePickerRow(
                  label: 'End Date',
                  date: endDate,
                  onPick: () async {
                    final d = await showDatePicker(
                      context: ctx,
                      initialDate:
                          endDate ?? (startDate ?? DateTime.now()),
                      firstDate: DateTime(2020),
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
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: saving
                        ? null
                        : () async {
                            final name = nameCtrl.text.trim();
                            final year = selectedYear;
                            if (name.isEmpty ||
                                year == null ||
                                year.isEmpty ||
                                startDate == null ||
                                endDate == null) {
                              ScaffoldMessenger.of(ctx).showSnackBar(
                                const SnackBar(
                                    content: Text(
                                        'Please fill in all fields')),
                              );
                              return;
                            }
                            if (endDate!.isBefore(startDate!)) {
                              ScaffoldMessenger.of(ctx).showSnackBar(
                                const SnackBar(
                                    content: Text(
                                        'End date must be after start date')),
                              );
                              return;
                            }
                            setSheet(() => saving = true);
                            final startStr =
                                '${startDate!.year}-${startDate!.month.toString().padLeft(2, '0')}-${startDate!.day.toString().padLeft(2, '0')}';
                            final endStr =
                                '${endDate!.year}-${endDate!.month.toString().padLeft(2, '0')}-${endDate!.day.toString().padLeft(2, '0')}';
                            try {
                              final svc =
                                  ref.read(adminServiceProvider);
                              if (isEdit) {
                                await svc.updateSemester(
                                  semesterId: semester.id,
                                  name: name,
                                  academicYear: year,
                                  startDate: startStr,
                                  endDate: endStr,
                                );
                              } else {
                                await svc.createSemester(
                                  name: name,
                                  academicYear: year,
                                  startDate: startStr,
                                  endDate: endStr,
                                );
                              }
                              ref.invalidate(adminSemestersProvider);
                              if (ctx.mounted) Navigator.pop(ctx);
                              if (mounted) {
                                showSuccessToast(
                                    context, isEdit ? 'Semester updated.' : 'Semester created.');
                              }
                            } catch (e) {
                              setSheet(() => saving = false);
                              if (ctx.mounted) {
                                ScaffoldMessenger.of(ctx).showSnackBar(
                                  SnackBar(
                                      content: Text('Error: $e'),
                                      backgroundColor:
                                          AppColors.statusRed),
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

  // ── Summary widgets ───────────────────────────────────────────────────────────

  Widget _buildCurrentFocusCard(AdminSemester current) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.primaryNavy,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('CURRENT SEMESTER',
              style: AppTextStyles.label.copyWith(
                  color: Colors.white.withValues(alpha: 0.7),
                  letterSpacing: 1)),
          const SizedBox(height: 4),
          Text(current.name,
              style: AppTextStyles.h2.copyWith(color: Colors.white)),
          const SizedBox(height: 4),
          Text('${current.fmtStart} – ${current.fmtEnd}',
              style: AppTextStyles.captionWhite),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppSpacing.tagRadius),
            ),
            child: Text(
                '${current.classCount} class${current.classCount == 1 ? '' : 'es'}',
                style: AppTextStyles.label
                    .copyWith(color: Colors.white, letterSpacing: 0.3)),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewCard(List<AdminSemester> semesters) {
    final total = semesters.length;
    final closed = semesters.where((s) => s.statusLabel == 'CLOSED').length;
    final completionPct = total > 0 ? closed / total : 0.0;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Semester Overview', style: AppTextStyles.h3),
                const SizedBox(height: 4),
                Text('$total total • $closed completed',
                    style: AppTextStyles.caption),
              ],
            ),
          ),
          SizedBox(
            width: 44,
            height: 44,
            child: CircularProgressIndicator(
              value: completionPct,
              strokeWidth: 5,
              backgroundColor: AppColors.border,
              valueColor: AlwaysStoppedAnimation<Color>(
                  AppColors.primaryBlue),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Semester card ─────────────────────────────────────────────────────────────

class _SemesterCard extends StatelessWidget {
  const _SemesterCard({
    required this.semester,
    required this.onEdit,
    required this.onSetCurrent,
  });

  final AdminSemester semester;
  final VoidCallback onEdit;
  final VoidCallback? onSetCurrent;

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

  bool get _isClosed => semester.statusLabel == 'CLOSED';

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: _isClosed ? 0.7 : 1.0,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.cardPadding),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          border: Border.all(
            color: semester.isCurrent
                ? AppColors.primaryBlue.withValues(alpha: 0.4)
                : AppColors.border,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: _statusBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(_icon, color: _statusColor, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(semester.name, style: AppTextStyles.bodyMedium),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(Icons.calendar_month_outlined,
                              size: 12, color: AppColors.textSecondary),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              '${semester.fmtStart} – ${semester.fmtEnd}',
                              style: AppTextStyles.caption
                                  .copyWith(fontSize: 11),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: _statusBg,
                    borderRadius:
                        BorderRadius.circular(AppSpacing.tagRadius),
                  ),
                  child: Text(semester.statusLabel,
                      style: AppTextStyles.label.copyWith(
                          color: _statusColor,
                          fontSize: 9,
                          letterSpacing: 0.5)),
                ),
                const SizedBox(width: 8),
                _MoreMenu(
                  onEdit: onEdit,
                  onSetCurrent: onSetCurrent,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Divider(height: 1, color: AppColors.divider),
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.class_outlined,
                    size: 14,
                    color: _isClosed ? AppColors.textLabel : AppColors.textSecondary),
                const SizedBox(width: 4),
                Text(
                  '${semester.classCount} class${semester.classCount == 1 ? '' : 'es'}',
                  style: AppTextStyles.caption.copyWith(
                      color: _isClosed
                          ? AppColors.textLabel
                          : AppColors.textSecondary),
                ),
                const Spacer(),
                if (semester.isCurrent)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.primaryNavy.withValues(alpha: 0.08),
                      borderRadius:
                          BorderRadius.circular(AppSpacing.tagRadius),
                    ),
                    child: Text('CURRENT',
                        style: AppTextStyles.label.copyWith(
                            color: AppColors.primaryNavy,
                            fontSize: 9,
                            letterSpacing: 0.5)),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Three-dot menu ────────────────────────────────────────────────────────────

class _MoreMenu extends StatelessWidget {
  const _MoreMenu({required this.onEdit, required this.onSetCurrent});
  final VoidCallback onEdit;
  final VoidCallback? onSetCurrent;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: Icon(Icons.more_vert,
          size: 18, color: AppColors.textSecondary),
      onSelected: (v) {
        if (v == 'edit') onEdit();
        if (v == 'set_current') onSetCurrent?.call();
      },
      itemBuilder: (_) => [
        const PopupMenuItem(
          value: 'edit',
          child: Row(children: [
            Icon(Icons.edit_outlined, size: 16),
            SizedBox(width: 8),
            Text('Edit'),
          ]),
        ),
        if (onSetCurrent != null)
          PopupMenuItem(
            value: 'set_current',
            child: Row(children: [
              Icon(Icons.check_circle_outline, size: 16,
                  color: AppColors.primaryBlue),
              const SizedBox(width: 8),
              Text('Set as Current',
                  style: TextStyle(color: AppColors.primaryBlue)),
            ]),
          ),
      ],
    );
  }
}

// ── Sheet helpers ─────────────────────────────────────────────────────────────

class _SheetField extends StatelessWidget {
  const _SheetField(
      {required this.label, required this.controller, this.hint});
  final String label;
  final TextEditingController controller;
  final String? hint;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: AppTextStyles.caption
                .copyWith(fontSize: 11, color: AppColors.textSecondary)),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          style: AppTextStyles.body,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle:
                AppTextStyles.caption.copyWith(color: AppColors.textLabel),
            filled: true,
            fillColor: AppColors.bgInput,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            border: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(AppSpacing.inputRadius),
              borderSide: BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(AppSpacing.inputRadius),
              borderSide: BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(AppSpacing.inputRadius),
              borderSide: BorderSide(color: AppColors.primaryNavy),
            ),
          ),
        ),
      ],
    );
  }
}

class _DatePickerRow extends StatelessWidget {
  const _DatePickerRow(
      {required this.label, required this.date, required this.onPick});
  final String label;
  final DateTime? date;
  final VoidCallback onPick;

  @override
  Widget build(BuildContext context) {
    final display = date != null
        ? '${date!.year}-${date!.month.toString().padLeft(2, '0')}-${date!.day.toString().padLeft(2, '0')}'
        : 'Select date';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: AppTextStyles.caption
                .copyWith(fontSize: 11, color: AppColors.textSecondary)),
        const SizedBox(height: 4),
        GestureDetector(
          onTap: onPick,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
            decoration: BoxDecoration(
              color: AppColors.bgInput,
              borderRadius:
                  BorderRadius.circular(AppSpacing.inputRadius),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today_outlined,
                    size: 16, color: AppColors.textSecondary),
                const SizedBox(width: 8),
                Text(display,
                    style: date != null
                        ? AppTextStyles.body
                        : AppTextStyles.caption
                            .copyWith(color: AppColors.textLabel)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
