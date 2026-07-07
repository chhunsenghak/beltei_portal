import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/providers/admin_providers.dart';
import '../../core/services/admin_service.dart';

/// Opens a bottom sheet to enroll a student directly into [classTermId] —
/// used from "View Students" sheets (class management, enrollment
/// management) so admins can add someone without leaving the class, sharing
/// one enroll-into-a-term flow instead of duplicating it per screen.
Future<void> showEnrollStudentSheet(
  BuildContext context, {
  required String classTermId,
  required VoidCallback onEnrolled,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
    builder: (ctx) => _EnrollStudentSheet(
      classTermId: classTermId,
      onEnrolled: onEnrolled,
    ),
  );
}

class _EnrollStudentSheet extends ConsumerStatefulWidget {
  const _EnrollStudentSheet({required this.classTermId, required this.onEnrolled});
  final String classTermId;
  final VoidCallback onEnrolled;

  @override
  ConsumerState<_EnrollStudentSheet> createState() => _EnrollStudentSheetState();
}

class _EnrollStudentSheetState extends ConsumerState<_EnrollStudentSheet> {
  AdminStudent? _selected;
  String _query = '';
  bool _saving = false;

  Future<void> _enroll() async {
    if (_selected == null) return;
    setState(() => _saving = true);
    try {
      await ref.read(adminServiceProvider).enrollStudent(
            studentId: _selected!.id,
            classTermId: widget.classTermId,
          );
      widget.onEnrolled();
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        setState(() => _saving = false);
        final msg = e.toString().contains('unique')
            ? 'Student is already enrolled in this class term.'
            : 'Error: $e';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg), backgroundColor: AppColors.statusRed),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final allStudents = ref.watch(adminStudentsProvider).valueOrNull ?? [];
    final enrolledAsync = ref.watch(classTermEnrollmentsProvider(widget.classTermId));
    final enrolledIds =
        enrolledAsync.valueOrNull?.map((e) => e.studentId).toSet() ?? <String>{};

    final filtered = _query.isEmpty
        ? const <AdminStudent>[]
        : allStudents.where((s) {
            if (enrolledIds.contains(s.id)) return false;
            final q = _query.toLowerCase();
            return s.fullName.toLowerCase().contains(q) ||
                s.studentCode.toLowerCase().contains(q);
          }).toList();

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 20, 16, MediaQuery.of(context).viewInsets.bottom + 24),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Add Student', style: AppTextStyles.h3.copyWith(color: AppColors.primaryNavy)),
            const SizedBox(height: 16),
            if (_selected == null) ...[
              TextField(
                autofocus: true,
                onChanged: (v) => setState(() => _query = v),
                style: AppTextStyles.body,
                decoration: InputDecoration(
                  hintText: 'Search by name or code…',
                  hintStyle: AppTextStyles.caption.copyWith(color: AppColors.textLabel),
                  prefixIcon: Icon(Icons.search, color: AppColors.textLabel, size: 20),
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
              if (_query.isNotEmpty) ...[
                const SizedBox(height: 6),
                Container(
                  constraints: const BoxConstraints(maxHeight: 240),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: filtered.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.all(12),
                          child: Text('No matching students found', style: AppTextStyles.caption),
                        )
                      : ListView.separated(
                          shrinkWrap: true,
                          itemCount: filtered.length.clamp(0, 8),
                          separatorBuilder: (_, idx) =>
                              Divider(height: 1, color: AppColors.divider),
                          itemBuilder: (_, i) {
                            final s = filtered[i];
                            return ListTile(
                              dense: true,
                              leading: CircleAvatar(
                                radius: 16,
                                backgroundColor: AppColors.primaryBlue.withValues(alpha: 0.1),
                                child: Text(s.initials,
                                    style: AppTextStyles.label
                                        .copyWith(color: AppColors.primaryBlue, fontSize: 10)),
                              ),
                              title: Text(s.fullName, style: AppTextStyles.body),
                              subtitle: Text(s.studentCode,
                                  style: AppTextStyles.caption.copyWith(fontSize: 10)),
                              onTap: () => setState(() {
                                _selected = s;
                                _query = '';
                              }),
                            );
                          },
                        ),
                ),
              ],
            ] else
              GestureDetector(
                onTap: () => setState(() => _selected = null),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
                    border: Border.all(color: AppColors.primaryBlue.withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(_selected!.fullName,
                                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.primaryNavy)),
                            Text(_selected!.studentCode, style: AppTextStyles.caption),
                          ],
                        ),
                      ),
                      Icon(Icons.close, size: 16, color: AppColors.textSecondary),
                    ],
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
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: (_saving || _selected == null) ? null : _enroll,
                child: _saving
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Add to Class'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
