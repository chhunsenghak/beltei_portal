import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/providers/admin_providers.dart';
import '../../../core/services/admin_service.dart';

class StudentDetailScreen extends ConsumerStatefulWidget {
  const StudentDetailScreen({super.key, required this.studentId});
  final String studentId;

  @override
  ConsumerState<StudentDetailScreen> createState() => _StudentDetailScreenState();
}

class _StudentDetailScreenState extends ConsumerState<StudentDetailScreen> {
  bool _loaded = false;
  bool _saving = false;
  String _accountStatus = 'Active';
  String _genderValue   = 'Male';
  String? _facultyId;
  String? _majorId;

  final _firstNameController   = TextEditingController();
  final _lastNameController    = TextEditingController();
  final _dobController         = TextEditingController();
  final _nationalityController = TextEditingController();
  final _semesterController    = TextEditingController();
  final _enrollDateController  = TextEditingController();
  final _phoneController       = TextEditingController();
  final _emailController       = TextEditingController();
  final _addressController     = TextEditingController();

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _dobController.dispose();
    _nationalityController.dispose();
    _semesterController.dispose();
    _enrollDateController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _populate(AdminStudentDetail detail) {
    if (_loaded) return;
    _loaded = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _firstNameController.text   = detail.firstName;
      _lastNameController.text    = detail.lastName;
      _dobController.text         = detail.fmtDateOfBirth;
      _nationalityController.text = detail.nationality ?? '';
      _semesterController.text    = 'Year ${detail.yearLevel}';
      _enrollDateController.text  = '${detail.enrollmentYear}';
      _phoneController.text       = detail.phone ?? '';
      _emailController.text       = detail.email;
      _addressController.text     = detail.address ?? '';
      setState(() {
        _genderValue   = detail.displayGender;
        _facultyId     = detail.facultyId;
        _majorId       = detail.majorId;
        _accountStatus = detail.statusLabel;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final asyncDetail = ref.watch(studentDetailProvider(widget.studentId));
    asyncDetail.whenData((d) { if (d != null) _populate(d); });

    return Scaffold(
      backgroundColor: AppColors.bgPage,
      body: Column(
        children: [
          _buildNavRow(context),
          Expanded(
            child: asyncDetail.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline, color: AppColors.statusRed, size: 40),
                    const SizedBox(height: 8),
                    Text('Could not load student data', style: AppTextStyles.body),
                  ],
                ),
              ),
              data: (detail) {
                if (detail == null) {
                  return Center(child: Text('Student not found', style: AppTextStyles.body));
                }
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSpacing.screenPadding),
                  child: Column(
                    children: [
                      _buildProfileHeader(detail),
                      const SizedBox(height: 16),
                      _buildPersonalInfoSection(),
                      const SizedBox(height: 16),
                      _buildAcademicInfoSection(),
                      const SizedBox(height: 16),
                      _buildContactInfoSection(),
                      const SizedBox(height: 16),
                      _buildAccountStatusSection(),
                      const SizedBox(height: 24),
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
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.primaryNavy),
            onPressed: () => context.pop(),
          ),
          Text('Student Detail',
              style: AppTextStyles.h3.copyWith(color: AppColors.primaryNavy)),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(AdminStudentDetail detail) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 44,
                backgroundColor: AppColors.primaryNavy.withValues(alpha: 0.1),
                child: Text(detail.initials,
                    style: AppTextStyles.h1.copyWith(color: AppColors.primaryNavy)),
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
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.credit_card_outlined,
                  size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 4),
              Text('ID: ${detail.studentCode}', style: AppTextStyles.caption),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppSpacing.chipRadius),
                ),
                child: Text('Undergraduate',
                    style: AppTextStyles.label.copyWith(
                        color: AppColors.primaryBlue, letterSpacing: 0.3)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoSection() {
    return _FormSection(
      icon: Icons.person_outline,
      title: 'Personal Info',
      children: [
        Row(
          children: [
            Expanded(child: _FormField(label: 'First Name', controller: _firstNameController)),
            const SizedBox(width: 12),
            Expanded(child: _FormField(label: 'Last Name', controller: _lastNameController)),
          ],
        ),
        Row(
          children: [
            Expanded(child: _FormField(label: 'Date of Birth', controller: _dobController)),
            const SizedBox(width: 12),
            Expanded(
              child: _DropdownField(
                label: 'Gender',
                value: _genderValue,
                items: const ['Male', 'Female', 'Other'],
                onChanged: (v) => setState(() => _genderValue = v!),
              ),
            ),
          ],
        ),
        _FormField(label: 'Nationality', controller: _nationalityController),
      ],
    );
  }

  Widget _buildAcademicInfoSection() {
    final faculties = ref.watch(adminFacultiesProvider).valueOrNull ?? [];
    final allMajors = ref.watch(adminMajorsProvider).valueOrNull ?? [];

    final validFacultyIds = {null, ...faculties.map((f) => f.id)};
    final selectedFacultyId = validFacultyIds.contains(_facultyId) ? _facultyId : null;
    final facultyItems = <_FacultyItem>[
      const _FacultyItem(id: null, name: 'No Faculty'),
      ...faculties.map((f) => _FacultyItem(id: f.id, name: f.name)),
    ];

    final filteredMajors = _facultyId == null
        ? allMajors
        : allMajors.where((m) => m.facultyId == _facultyId).toList();
    final validMajorIds = {null, ...filteredMajors.map((m) => m.id)};
    final selectedMajorId = validMajorIds.contains(_majorId) ? _majorId : null;
    final majorItems = <_FacultyItem>[
      const _FacultyItem(id: null, name: 'No Major'),
      ...filteredMajors.map((m) => _FacultyItem(id: m.id, name: m.name)),
    ];

    return _FormSection(
      icon: Icons.school_outlined,
      title: 'Academic Info',
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Faculty',
                style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
            const SizedBox(height: 4),
            Container(
              decoration: BoxDecoration(
                color: AppColors.bgInput,
                borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
                border: Border.all(color: AppColors.border),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String?>(
                  value: selectedFacultyId,
                  isExpanded: true,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                  items: facultyItems.map((f) => DropdownMenuItem<String?>(
                    value: f.id,
                    child: Text(f.name, style: AppTextStyles.body),
                  )).toList(),
                  onChanged: (v) => setState(() {
                    _facultyId = v;
                    _majorId = null;
                  }),
                ),
              ),
            ),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Major',
                style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
            const SizedBox(height: 4),
            Container(
              decoration: BoxDecoration(
                color: AppColors.bgInput,
                borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
                border: Border.all(color: AppColors.border),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String?>(
                  value: selectedMajorId,
                  isExpanded: true,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                  items: majorItems.map((m) => DropdownMenuItem<String?>(
                    value: m.id,
                    child: Text(m.name, style: AppTextStyles.body),
                  )).toList(),
                  onChanged: (v) => setState(() => _majorId = v),
                ),
              ),
            ),
          ],
        ),
        Row(
          children: [
            Expanded(child: _FormField(label: 'Year Level', controller: _semesterController)),
            const SizedBox(width: 12),
            Expanded(child: _FormField(label: 'Enrollment Year', controller: _enrollDateController)),
          ],
        ),
      ],
    );
  }

  Widget _buildContactInfoSection() {
    return _FormSection(
      icon: Icons.contact_page_outlined,
      title: 'Contact Info',
      children: [
        _FormField(label: 'Phone Number', controller: _phoneController,
            prefix: const Icon(Icons.phone_outlined, size: 16, color: AppColors.textSecondary)),
        _FormField(label: 'Email Address', controller: _emailController,
            prefix: const Icon(Icons.email_outlined, size: 16, color: AppColors.textSecondary)),
        _FormField(label: 'Residential Address', controller: _addressController, maxLines: 3),
      ],
    );
  }

  Widget _buildAccountStatusSection() {
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
          Text('Account Status', style: AppTextStyles.h3),
          const SizedBox(height: 4),
          Text('Manage the visibility and accessibility of this student\'s account.',
              style: AppTextStyles.caption),
          const SizedBox(height: 14),
          Row(
            children: ['Active', 'Suspended', 'Archived'].map((s) {
              final isSelected = s == _accountStatus;
              Color color;
              switch (s) {
                case 'Active':    color = AppColors.statusGreen; break;
                case 'Suspended': color = AppColors.statusRed;   break;
                default:          color = AppColors.statusGray;
              }
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () => setState(() => _accountStatus = s),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      color: isSelected ? color.withValues(alpha: 0.1) : Colors.white,
                      borderRadius: BorderRadius.circular(AppSpacing.chipRadius),
                      border: Border.all(
                          color: isSelected ? color : AppColors.border,
                          width: isSelected ? 1.5 : 1),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(isSelected ? Icons.check_circle : Icons.circle_outlined,
                            size: 14,
                            color: isSelected ? color : AppColors.textLabel),
                        const SizedBox(width: 4),
                        Text(s,
                            style: AppTextStyles.caption.copyWith(
                                color: isSelected ? color : AppColors.textSecondary,
                                fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: _saving ? null : () {
              setState(() => _accountStatus = _accountStatus == 'Active' ? 'Suspended' : 'Active');
            },
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
              side: const BorderSide(color: AppColors.statusRed),
              foregroundColor: AppColors.statusRed,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.buttonRadius)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.block_outlined, size: 18),
                const SizedBox(width: 8),
                Text('Suspend Access',
                    style: AppTextStyles.button.copyWith(color: AppColors.statusRed)),
              ],
            ),
          ),
          const SizedBox(height: 10),
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
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.save_outlined, size: 18, color: Colors.white),
                      const SizedBox(width: 8),
                      Text('Save Changes', style: AppTextStyles.button),
                    ],
                  ),
          ),
          const SizedBox(height: 10),
          TextButton.icon(
            onPressed: _saving ? null : () => _showDeleteDialog(context),
            icon: const Icon(Icons.delete_outline, color: AppColors.statusRed, size: 16),
            label: Text('Delete Student', style: AppTextStyles.caption.copyWith(color: AppColors.statusRed)),
          ),
        ],
      ),
    );
  }

  Future<void> _saveChanges(BuildContext context) async {
    setState(() => _saving = true);
    try {
      final yearText = _semesterController.text.replaceAll(RegExp(r'[^0-9]'), '');
      final yearLevel = int.tryParse(yearText);
      await ref.read(adminServiceProvider).updateStudent(
        studentId: widget.studentId,
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        phone: _phoneController.text.trim(),
        gender: _genderValue,
        dateOfBirth: _dobController.text.trim(),
        nationality: _nationalityController.text.trim(),
        address: _addressController.text.trim(),
        yearLevel: yearLevel,
        statusLabel: _accountStatus,
        facultyId: _facultyId,
        majorId: _majorId,
      );
      ref.invalidate(studentDetailProvider(widget.studentId));
      ref.invalidate(adminStudentsProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Student updated successfully'), backgroundColor: AppColors.statusGreen),
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
        title: Text('Delete Student', style: AppTextStyles.h3),
        content: const Text('This will permanently remove the student account. This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.statusRed),
            onPressed: () async {
              Navigator.pop(ctx);
              setState(() => _saving = true);
              try {
                await ref.read(adminServiceProvider).deleteUser(widget.studentId);
                ref.invalidate(adminStudentsProvider);
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

// ── Shared form widgets ────────────────────────────────────────────────────────

class _FormSection extends StatelessWidget {
  const _FormSection({required this.icon, required this.title, required this.children});
  final IconData icon;
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
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
              Icon(icon, size: 18, color: AppColors.primaryNavy),
              const SizedBox(width: 8),
              Text(title, style: AppTextStyles.h3),
            ],
          ),
          const SizedBox(height: 14),
          ...children.map((child) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: child,
              )),
        ],
      ),
    );
  }
}

class _FormField extends StatelessWidget {
  const _FormField({
    required this.label,
    required this.controller,
    this.prefix,
    this.maxLines = 1,
  });

  final String label;
  final TextEditingController controller;
  final Widget? prefix;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          maxLines: maxLines,
          style: AppTextStyles.body,
          decoration: InputDecoration(
            prefixIcon: prefix,
            filled: true,
            fillColor: AppColors.bgInput,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
              borderSide: const BorderSide(color: AppColors.primaryNavy),
            ),
          ),
        ),
      ],
    );
  }
}

class _DropdownField extends StatelessWidget {
  const _DropdownField({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final String label;
  final String value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
        const SizedBox(height: 4),
        Container(
          decoration: BoxDecoration(
            color: AppColors.bgInput,
            borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
            border: Border.all(color: AppColors.border),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
              items: items
                  .map((e) => DropdownMenuItem(value: e, child: Text(e, style: AppTextStyles.body)))
                  .toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}

class _FacultyItem {
  final String? id;
  final String name;
  const _FacultyItem({required this.id, required this.name});
}
