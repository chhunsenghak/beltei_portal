import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/providers/admin_providers.dart';
import '../../../core/services/admin_service.dart';
import '../../../shared/widgets/app_toast.dart';

// ── Screen ────────────────────────────────────────────────────────────────────

class AcademicYearManagementScreen extends ConsumerStatefulWidget {
  const AcademicYearManagementScreen({super.key});

  @override
  ConsumerState<AcademicYearManagementScreen> createState() =>
      _AcademicYearManagementScreenState();
}

class _AcademicYearManagementScreenState
    extends ConsumerState<AcademicYearManagementScreen> {
  @override
  Widget build(BuildContext context) {
    final yearsAsync = ref.watch(adminAcademicYearsProvider);

    return Scaffold(
      backgroundColor: AppColors.bgPage,
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAcademicYearSheet(context),
        backgroundColor: AppColors.primaryBlue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: yearsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline,
                  color: AppColors.statusRed, size: 40),
              const SizedBox(height: 8),
              Text('Could not load academic years',
                  style: AppTextStyles.bodyMedium),
              TextButton(
                onPressed: () => ref.invalidate(adminAcademicYearsProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (years) {
          if (years.isEmpty) {
            return ListView(
              padding: const EdgeInsets.all(AppSpacing.screenPadding),
              children: [
                Text('Academic Year Management',
                    style: AppTextStyles.h1
                        .copyWith(color: AppColors.primaryNavy)),
                const SizedBox(height: 4),
                Text('Define the academic years used across semesters.',
                    style: AppTextStyles.caption),
                const SizedBox(height: 60),
                Center(
                  child: Column(
                    children: [
                      Icon(Icons.calendar_today_outlined,
                          size: 40, color: AppColors.textLabel),
                      const SizedBox(height: 8),
                      Text('No academic years yet',
                          style: AppTextStyles.bodyMedium),
                      const SizedBox(height: 4),
                      Text('Tap + to create one, e.g. "2026-2027".',
                          style: AppTextStyles.caption),
                    ],
                  ),
                ),
              ],
            );
          }

          return ListView(
            padding: const EdgeInsets.all(AppSpacing.screenPadding),
            children: [
              Text('Academic Year Management',
                  style:
                      AppTextStyles.h1.copyWith(color: AppColors.primaryNavy)),
              const SizedBox(height: 4),
              Text('Define the academic years used across semesters.',
                  style: AppTextStyles.caption),
              const SizedBox(height: 20),
              ...years.map((y) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _AcademicYearCard(
                      year: y,
                      onEdit: () => _showAcademicYearSheet(context, year: y),
                      onSetCurrent:
                          y.isCurrent ? null : () => _setCurrent(y),
                      onDelete: () => _confirmDelete(y),
                    ),
                  )),
              const SizedBox(height: 80),
            ],
          );
        },
      ),
    );
  }

  // ── Actions ──────────────────────────────────────────────────────────────────

  Future<void> _setCurrent(AdminAcademicYear y) async {
    try {
      await ref.read(adminServiceProvider).setCurrentAcademicYear(y.id);
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

  Future<void> _confirmDelete(AdminAcademicYear y) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Academic Year'),
        content: Text('Remove "${y.name}"? This does not affect existing semesters.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Delete',
                style: TextStyle(color: AppColors.statusRed)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await ref.read(adminServiceProvider).deleteAcademicYear(y.id);
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

  Future<void> _showAcademicYearSheet(BuildContext context,
      {AdminAcademicYear? year}) async {
    final isEdit = year != null;
    final nameCtrl = TextEditingController(text: year?.name ?? '');
    DateTime? startDate =
        year != null ? DateTime.tryParse(year.startDate) : null;
    DateTime? endDate = year != null ? DateTime.tryParse(year.endDate) : null;
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
                Text(isEdit ? 'Edit Academic Year' : 'New Academic Year',
                    style: AppTextStyles.h3
                        .copyWith(color: AppColors.primaryNavy)),
                const SizedBox(height: 16),
                _SheetField(
                    label: 'Name', controller: nameCtrl, hint: 'e.g. 2026-2027'),
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
                    if (d != null) setSheet(() => startDate = d);
                  },
                ),
                const SizedBox(height: 12),
                _DatePickerRow(
                  label: 'End Date',
                  date: endDate,
                  onPick: () async {
                    final d = await showDatePicker(
                      context: ctx,
                      initialDate: endDate ?? (startDate ?? DateTime.now()),
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
                            if (name.isEmpty ||
                                startDate == null ||
                                endDate == null) {
                              ScaffoldMessenger.of(ctx).showSnackBar(
                                const SnackBar(
                                    content:
                                        Text('Please fill in all fields')),
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
                              if (mounted) {
                                showSuccessToast(context,
                                    isEdit ? 'Academic year updated.' : 'Academic year created.');
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
}

// ── Academic year card ────────────────────────────────────────────────────────

class _AcademicYearCard extends StatelessWidget {
  const _AcademicYearCard({
    required this.year,
    required this.onEdit,
    required this.onSetCurrent,
    required this.onDelete,
  });

  final AdminAcademicYear year;
  final VoidCallback onEdit;
  final VoidCallback? onSetCurrent;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(
          color: year.isCurrent
              ? AppColors.primaryBlue.withValues(alpha: 0.4)
              : AppColors.border,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.statusBlueBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.calendar_today_outlined,
                color: AppColors.primaryBlue, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(year.name, style: AppTextStyles.bodyMedium),
                const SizedBox(height: 2),
                Text('${year.fmtStart} – ${year.fmtEnd}',
                    style: AppTextStyles.caption.copyWith(fontSize: 11)),
              ],
            ),
          ),
          if (year.isCurrent)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.primaryNavy.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(AppSpacing.tagRadius),
              ),
              child: Text('CURRENT',
                  style: AppTextStyles.label.copyWith(
                      color: AppColors.primaryNavy,
                      fontSize: 9,
                      letterSpacing: 0.5)),
            ),
          const SizedBox(width: 8),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert,
                size: 18, color: AppColors.textSecondary),
            onSelected: (v) {
              if (v == 'edit') onEdit();
              if (v == 'set_current') onSetCurrent?.call();
              if (v == 'delete') onDelete();
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
                    Icon(Icons.check_circle_outline,
                        size: 16, color: AppColors.primaryBlue),
                    const SizedBox(width: 8),
                    Text('Set as Current',
                        style: TextStyle(color: AppColors.primaryBlue)),
                  ]),
                ),
              PopupMenuItem(
                value: 'delete',
                child: Row(children: [
                  Icon(Icons.delete_outline,
                      size: 16, color: AppColors.statusRed),
                  const SizedBox(width: 8),
                  Text('Delete', style: TextStyle(color: AppColors.statusRed)),
                ]),
              ),
            ],
          ),
        ],
      ),
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
              borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
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
