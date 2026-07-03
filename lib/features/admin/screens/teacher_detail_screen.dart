import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/providers/admin_providers.dart';
import '../../../core/services/admin_service.dart';

class TeacherDetailScreen extends ConsumerStatefulWidget {
  const TeacherDetailScreen({super.key, required this.teacherId});
  final String teacherId;

  @override
  ConsumerState<TeacherDetailScreen> createState() => _TeacherDetailScreenState();
}

class _TeacherDetailScreenState extends ConsumerState<TeacherDetailScreen> {
  bool _loaded = false;
  bool _saving = false;

  final _firstNameController   = TextEditingController();
  final _lastNameController    = TextEditingController();
  final _designationController = TextEditingController();
  final _phoneController       = TextEditingController();

  String? _facultyId;
  List<String> _assignedCourses = [];
  int _totalStudents = 0;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _designationController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _populate(AdminTeacherDetail detail) {
    if (_loaded) return;
    _loaded = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _firstNameController.text   = detail.firstName;
      _lastNameController.text    = detail.lastName;
      _designationController.text = detail.position ?? '';
      _phoneController.text       = detail.phone ?? '';
      setState(() {
        _facultyId       = detail.facultyId;
        _assignedCourses = List<String>.from(detail.assignedCourses);
        _totalStudents   = detail.totalStudents;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final asyncDetail = ref.watch(teacherDetailProvider(widget.teacherId));
    asyncDetail.whenData((d) { if (d != null) _populate(d); });

    return Scaffold(
      backgroundColor: AppColors.bgPage,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildNavRow(context),
          Expanded(
            child: asyncDetail.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.error_outline, color: AppColors.statusRed, size: 40),
                    const SizedBox(height: 8),
                    Text('Could not load teacher data\n$e', style: AppTextStyles.body, textAlign: TextAlign.center),
                  ],
                ),
              ),
              data: (detail) {
                if (detail == null) {
                  return Center(child: Text('Teacher not found', style: AppTextStyles.body));
                }
                final faculties =
                    ref.watch(adminFacultiesProvider).valueOrNull ?? [];
                return SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildProfileHeader(context, detail),
                      Padding(
                        padding: const EdgeInsets.all(AppSpacing.screenPadding),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _buildPersonalInfoSection(faculties),
                            const SizedBox(height: 16),
                            _buildAssignedCoursesSection(),
                            const SizedBox(height: 16),
                            _buildWorkloadSection(detail),
                            const SizedBox(height: 16),
                            _buildAdminActionsSection(context),
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavRow(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back, color: AppColors.primaryNavy),
            onPressed: () => context.pop(),
          ),
          Text('Teacher Detail',
              style: AppTextStyles.h3.copyWith(color: AppColors.primaryNavy)),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, AdminTeacherDetail detail) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      child: Column(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 48,
                backgroundColor: AppColors.primaryNavy.withValues(alpha: 0.1),
                child: Text(detail.initials,
                    style: AppTextStyles.h1.copyWith(
                        color: AppColors.primaryNavy, fontSize: 24)),
              ),
              Positioned(
                bottom: 0, right: 0,
                child: Container(
                  width: 28, height: 28,
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(Icons.edit, color: Colors.white, size: 14),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(detail.fullName, style: AppTextStyles.h2),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppSpacing.chipRadius),
            ),
            child: Text(detail.position ?? 'Faculty',
                style: AppTextStyles.label.copyWith(
                    color: AppColors.primaryBlue, letterSpacing: 0.3)),
          ),
          const SizedBox(height: 8),
          Text('Employee ID: ${detail.employeeCode}',
              style: AppTextStyles.caption.copyWith(color: AppColors.primaryBlue)),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.email_outlined, size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 4),
              Text(detail.email, style: AppTextStyles.caption),
            ],
          ),
          if (detail.phone != null) ...[
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.phone_outlined, size: 14, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Text(detail.phone!, style: AppTextStyles.caption),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPersonalInfoSection(List<AdminFaculty> faculties) {
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Personal Information', style: AppTextStyles.h3),
              Icon(Icons.info_outline, size: 18, color: AppColors.textLabel),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(child: _LabeledField(label: 'First Name', controller: _firstNameController)),
              const SizedBox(width: 12),
              Expanded(child: _LabeledField(label: 'Last Name', controller: _lastNameController)),
            ],
          ),
          const SizedBox(height: 12),
          _LabeledField(label: 'Phone Number', controller: _phoneController),
          const SizedBox(height: 12),
          _LabeledField(label: 'Designation / Position', controller: _designationController),
          const SizedBox(height: 12),
          _FacultyDropdown(
            label: 'Faculty',
            value: _facultyId,
            faculties: faculties,
            onChanged: (v) => setState(() => _facultyId = v),
          ),
        ],
      ),
    );
  }

  Widget _buildAssignedCoursesSection() {
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Assigned Courses', style: AppTextStyles.h3),
              SizedBox(
                width: 130, // enough for "Assign Course" label
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.add, size: 14, color: Colors.white),
                  label: Text('Assign Course',
                      style: AppTextStyles.button.copyWith(fontSize: 12)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSpacing.chipRadius)),
                  ),
                ),
              ),
              // ElevatedButton.icon(
              //   onPressed: () {},
              //   icon: const Icon(Icons.add, size: 14, color: Colors.white),
              //   label: Text('Assign Course',
              //       style: AppTextStyles.button.copyWith(fontSize: 12)),
              //   style: ElevatedButton.styleFrom(
              //     backgroundColor: AppColors.primaryBlue,
              //     padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              //     shape: RoundedRectangleBorder(
              //         borderRadius: BorderRadius.circular(AppSpacing.chipRadius)),
              //   ),
              // ),
            ],
          ),
          const SizedBox(height: 14),
          _assignedCourses.isEmpty
              ? Text('No courses assigned', style: AppTextStyles.caption)
              : Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _assignedCourses.map((course) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.bgPage,
                        borderRadius: BorderRadius.circular(AppSpacing.chipRadius),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: Text(course,
                                style: AppTextStyles.caption
                                    .copyWith(fontWeight: FontWeight.w500),
                                overflow: TextOverflow.ellipsis),
                          ),
                          const SizedBox(width: 6),
                          GestureDetector(
                            onTap: () => setState(() => _assignedCourses.remove(course)),
                            child: Icon(Icons.close,
                                size: 14, color: AppColors.textLabel),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
        ],
      ),
    );
  }

  Widget _buildWorkloadSection(AdminTeacherDetail detail) {
    final courseCount = detail.assignedCourses.length;
    const maxCourses = 6;
    final pct = maxCourses > 0 ? courseCount / maxCourses : 0.0;
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
          Text('Workload Statistics', style: AppTextStyles.h3),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Active Courses', style: AppTextStyles.caption),
              Text('$courseCount / $maxCourses courses',
                  style: AppTextStyles.bodySemiBold
                      .copyWith(color: AppColors.primaryNavy)),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: pct.clamp(0.0, 1.0),
              minHeight: 8,
              backgroundColor: AppColors.border,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryBlue),
            ),
          ),
          const SizedBox(height: 4),
          Text('Workload ${(pct * 100).toInt()}%',
              style: AppTextStyles.label.copyWith(fontSize: 9, letterSpacing: 0)),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(child: _StatBox(value: '$_totalStudents', label: 'Total Students')),
              const SizedBox(width: 12),
              Expanded(child: _StatBox(value: '$courseCount', label: 'Courses')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAdminActionsSection(BuildContext context) {
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
          Text('Administrative Actions', style: AppTextStyles.h3),
          const SizedBox(height: 14),
          ElevatedButton(
            onPressed: _saving ? null : () => _saveChanges(context),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
              backgroundColor: AppColors.primaryNavy,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.buttonRadius)),
            ),
            child: _saving
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : Text('Save All Changes', style: AppTextStyles.button),
          ),
          const SizedBox(height: 10),
          OutlinedButton(
            onPressed: _saving ? null : () {
              setState(() => _loaded = false);
              ref.invalidate(teacherDetailProvider(widget.teacherId));
            },
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
              side: BorderSide(color: AppColors.border),
              foregroundColor: AppColors.textPrimary,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.buttonRadius)),
            ),
            child: Text('Discard Edits', style: AppTextStyles.body),
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: _saving ? null : () => _showDeleteDialog(context),
            icon: Icon(Icons.delete_outline, color: AppColors.statusRed, size: 16),
            label: Text('Delete Teacher', style: AppTextStyles.caption.copyWith(color: AppColors.statusRed)),
          ),
        ],
      ),
    );
  }

  Future<void> _saveChanges(BuildContext context) async {
    setState(() => _saving = true);
    try {
      await ref.read(adminServiceProvider).updateTeacher(
        teacherId: widget.teacherId,
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        phone: _phoneController.text.trim(),
        position: _designationController.text.trim(),
        facultyId: _facultyId ?? '',
      );
      ref.invalidate(teacherDetailProvider(widget.teacherId));
      ref.invalidate(adminTeachersProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Teacher updated successfully'), backgroundColor: AppColors.statusGreen),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.statusRed),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Delete Teacher', style: AppTextStyles.h3),
        content: const Text('This will permanently remove the teacher account. This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.statusRed),
            onPressed: () async {
              Navigator.pop(ctx);
              setState(() => _saving = true);
              try {
                await ref.read(adminServiceProvider).deleteUser(widget.teacherId);
                ref.invalidate(adminTeachersProvider);
                if (context.mounted) context.pop();
              } catch (e) {
                if (mounted) setState(() => _saving = false);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.statusRed),
                  );
                }
              }
            },
            child: Text('Delete', style: AppTextStyles.button),
          ),
        ],
      ),
    );
  }
}

class _FacultyDropdown extends StatelessWidget {
  const _FacultyDropdown({
    required this.label,
    required this.value,
    required this.faculties,
    required this.onChanged,
  });

  final String label;
  final String? value;
  final List<AdminFaculty> faculties;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: AppColors.bgInput,
            borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
            border: Border.all(color: AppColors.border),
          ),
          child: DropdownButton<String?>(
            value: value,
            isExpanded: true,
            underline: const SizedBox.shrink(),
            style: AppTextStyles.body,
            items: [
              const DropdownMenuItem(value: null, child: Text('None')),
              ...faculties.map(
                (f) => DropdownMenuItem(value: f.id, child: Text(f.name)),
              ),
            ],
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}

class _LabeledField extends StatelessWidget {
  const _LabeledField({required this.label, required this.controller});
  final String label;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          style: AppTextStyles.body,
          decoration: InputDecoration(
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

class _StatBox extends StatelessWidget {
  const _StatBox({required this.value, required this.label});
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.bgPage,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Text(value,
              style: AppTextStyles.metric.copyWith(
                  color: AppColors.primaryNavy, fontSize: 22)),
          Text(label, style: AppTextStyles.caption),
        ],
      ),
    );
  }
}
