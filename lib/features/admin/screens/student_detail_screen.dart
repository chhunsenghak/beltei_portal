import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';

class StudentDetailScreen extends StatefulWidget {
  const StudentDetailScreen({super.key, required this.studentId});
  final String studentId;

  @override
  State<StudentDetailScreen> createState() => _StudentDetailScreenState();
}

class _StudentDetailScreenState extends State<StudentDetailScreen> {
  String _accountStatus = 'Active';

  final _nameController = TextEditingController(text: 'Rathana Morn');
  final _dobController = TextEditingController(text: '05/15/2002');
  final _nationalityController = TextEditingController(text: 'Cambodian');
  final _deptController = TextEditingController(text: 'Management & Entrepreneurship');
  final _semesterController = TextEditingController(text: '4');
  final _enrollDateController = TextEditingController(text: '09/01/2022');
  final _phoneController = TextEditingController(text: '+855 12 345 678');
  final _emailController = TextEditingController(text: 'rathana.morn@beltei.edu.kh');
  final _addressController = TextEditingController(
      text: 'No. 123, St. 456, Sangkat Boeung Keng Kang I, Khan Chamkarmon, Phnom Penh');

  String _genderValue = 'Male';
  String _facultyValue = 'Business Administration';

  @override
  void dispose() {
    _nameController.dispose();
    _dobController.dispose();
    _nationalityController.dispose();
    _deptController.dispose();
    _semesterController.dispose();
    _enrollDateController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primaryNavy),
          onPressed: () => context.pop(),
        ),
        title: Row(
          children: [
            ClipOval(
              child: Image.asset('assets/images/beltei_logo.png',
                  width: 32, height: 32, fit: BoxFit.cover),
            ),
            const SizedBox(width: 8),
            Text('BELTEI Admin',
                style: AppTextStyles.h3.copyWith(color: AppColors.primaryNavy)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined,
                color: AppColors.textSecondary),
            onPressed: () {},
          ),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: AppColors.border),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          children: [
            _buildProfileHeader(),
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
      ),
    );
  }

  Widget _buildProfileHeader() {
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
                child: Text('RM',
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
          Text('Rathana Morn', style: AppTextStyles.h2),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.credit_card_outlined,
                  size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 4),
              Text('ID: 2024-BIU-8821', style: AppTextStyles.caption),
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
        _FormField(label: 'Full Name', controller: _nameController),
        Row(
          children: [
            Expanded(child: _FormField(label: 'DOB', controller: _dobController)),
            const SizedBox(width: 12),
            Expanded(
              child: _DropdownField(
                label: 'Gender',
                value: _genderValue,
                items: ['Male', 'Female', 'Other'],
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
    return _FormSection(
      icon: Icons.school_outlined,
      title: 'Academic Info',
      children: [
        _DropdownField(
          label: 'Faculty',
          value: _facultyValue,
          items: ['Business Administration', 'Information Technology', 'Engineering', 'Law'],
          onChanged: (v) => setState(() => _facultyValue = v!),
        ),
        _FormField(label: 'Department', controller: _deptController),
        Row(
          children: [
            Expanded(child: _FormField(label: 'Semester', controller: _semesterController)),
            const SizedBox(width: 12),
            Expanded(child: _FormField(label: 'Enrollment Date', controller: _enrollDateController)),
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
                case 'Active':    color = AppColors.statusGreen;  break;
                case 'Suspended': color = AppColors.statusRed;    break;
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
                        if (isSelected)
                          Icon(Icons.check_circle,
                              size: 14, color: color),
                        if (!isSelected)
                          Icon(Icons.circle_outlined,
                              size: 14, color: AppColors.textLabel),
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
            onPressed: () {},
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
                Text('Suspend Access', style: AppTextStyles.button.copyWith(color: AppColors.statusRed)),
              ],
            ),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
              backgroundColor: AppColors.primaryNavy,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.buttonRadius)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.save_outlined, size: 18, color: Colors.white),
                const SizedBox(width: 8),
                Text('Save Changes', style: AppTextStyles.button),
              ],
            ),
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
              items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, style: AppTextStyles.body))).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}
