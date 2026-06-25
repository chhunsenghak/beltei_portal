import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';

class TeacherDetailScreen extends StatefulWidget {
  const TeacherDetailScreen({super.key, required this.teacherId});
  final String teacherId;

  @override
  State<TeacherDetailScreen> createState() => _TeacherDetailScreenState();
}

class _TeacherDetailScreenState extends State<TeacherDetailScreen> {
  final _firstNameController = TextEditingController(text: 'Thomas');
  final _lastNameController = TextEditingController(text: 'Anderson');
  final _designationController = TextEditingController(text: 'Senior Lecturer');
  final _officeController =
      TextEditingController(text: 'Campus 10, Building B, Room 402, Phnom Penh');

  String _department = 'Information Technology';

  final _assignedCourses = ['Data Structures (CS301)', 'Database Systems (CS204)',
    'Network Security (CS412)', 'Web Dev II (CS205)'];

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _designationController.dispose();
    _officeController.dispose();
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
        title: Text('Teacher Detail',
            style: AppTextStyles.h3.copyWith(color: AppColors.primaryNavy)),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined,
                color: AppColors.textSecondary),
            onPressed: () {},
          ),
          const Padding(
            padding: EdgeInsets.only(right: 12),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.primaryNavy,
              child: Icon(Icons.person_outline, color: Colors.white, size: 16),
            ),
          ),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: AppColors.border),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildProfileHeader(context),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.screenPadding),
              child: Column(
                children: [
                  _buildPersonalInfoSection(),
                  const SizedBox(height: 16),
                  _buildAssignedCoursesSection(),
                  const SizedBox(height: 16),
                  _buildWorkloadSection(),
                  const SizedBox(height: 16),
                  _buildAdminActionsSection(context),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
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
                child: Text('TA',
                    style: AppTextStyles.h1.copyWith(color: AppColors.primaryNavy, fontSize: 24)),
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
          Text('Dr. Thomas P. Anderson', style: AppTextStyles.h2),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppSpacing.chipRadius),
            ),
            child: Text('Senior Faculty',
                style: AppTextStyles.label.copyWith(
                    color: AppColors.primaryBlue, letterSpacing: 0.3)),
          ),
          const SizedBox(height: 8),
          Text('Employee ID: BT-EDU-4829',
              style: AppTextStyles.caption.copyWith(
                  color: AppColors.primaryBlue)),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.email_outlined,
                  size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 4),
              Text('t.anderson@beltei.edu.kh', style: AppTextStyles.caption),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.phone_outlined,
                  size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 4),
              Text('+855 23 999 888', style: AppTextStyles.caption),
            ],
          ),
          const SizedBox(height: 14),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(200, 42),
              backgroundColor: AppColors.primaryNavy,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.buttonRadius)),
            ),
            child: Text('Save Changes', style: AppTextStyles.button),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoSection() {
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
              const Icon(Icons.info_outline, size: 18, color: AppColors.textLabel),
            ],
          ),
          const SizedBox(height: 14),
          _LabeledField(label: 'First Name', controller: _firstNameController),
          const SizedBox(height: 12),
          _LabeledField(label: 'Last Name', controller: _lastNameController),
          const SizedBox(height: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Department',
                  style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
              const SizedBox(height: 4),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.bgInput,
                  borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
                  border: Border.all(color: AppColors.border),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _department,
                    isExpanded: true,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                    items: ['Information Technology', 'Computer Science',
                            'Mathematics', 'Business', 'Engineering']
                        .map((e) => DropdownMenuItem(
                            value: e, child: Text(e, style: AppTextStyles.body)))
                        .toList(),
                    onChanged: (v) => setState(() => _department = v!),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _LabeledField(label: 'Designation', controller: _designationController),
          const SizedBox(height: 12),
          _LabeledField(label: 'Office Address', controller: _officeController, maxLines: 2),
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
              ElevatedButton.icon(
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
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
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
                    Text(course, style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w500)),
                    const SizedBox(width: 6),
                    GestureDetector(
                      onTap: () => setState(() => _assignedCourses.remove(course)),
                      child: const Icon(Icons.close, size: 14, color: AppColors.textLabel),
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

  Widget _buildWorkloadSection() {
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
              Text('Credit Hours (Weekly)',
                  style: AppTextStyles.caption),
              Text('18 / 24 hrs',
                  style: AppTextStyles.bodySemiBold.copyWith(
                      color: AppColors.primaryNavy)),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: 18 / 24,
              minHeight: 8,
              backgroundColor: AppColors.border,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryBlue),
            ),
          ),
          const SizedBox(height: 4),
          Text('Optimal workload range (75%)',
              style: AppTextStyles.label.copyWith(fontSize: 9, letterSpacing: 0)),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _StatBox(value: '342', label: 'Total Students'),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatBox(value: '4.8/5', label: 'Rating'),
              ),
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
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
              backgroundColor: AppColors.primaryNavy,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.buttonRadius)),
            ),
            child: Text('Save All Changes', style: AppTextStyles.button),
          ),
          const SizedBox(height: 10),
          OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
              side: const BorderSide(color: AppColors.border),
              foregroundColor: AppColors.textPrimary,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.buttonRadius)),
            ),
            child: Text('Discard Edits', style: AppTextStyles.body),
          ),
          const SizedBox(height: 16),
          Center(
            child: GestureDetector(
              onTap: () {},
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.person_off_outlined,
                      size: 16, color: AppColors.statusRed),
                  const SizedBox(width: 6),
                  Text('Deactivate Teacher Profile',
                      style: AppTextStyles.body.copyWith(
                          color: AppColors.statusRed,
                          fontWeight: FontWeight.w500)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LabeledField extends StatelessWidget {
  const _LabeledField(
      {required this.label, required this.controller, this.maxLines = 1});
  final String label;
  final TextEditingController controller;
  final int maxLines;

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
          maxLines: maxLines,
          style: AppTextStyles.body,
          decoration: InputDecoration(
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
