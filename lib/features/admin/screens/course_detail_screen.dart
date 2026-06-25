import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';

class CourseDetailScreen extends StatefulWidget {
  const CourseDetailScreen({super.key, required this.courseId});
  final String courseId;

  @override
  State<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen> {
  bool _hasUnsavedChanges = false;

  final _codeController = TextEditingController(text: 'CS-301');
  final _nameController = TextEditingController(text: 'Advanced Database Systems');
  final _descController = TextEditingController(
      text: 'This course covers the architectural foundations and implementation '
          'techniques of modern database management systems. Topics include storage '
          'management, query processing, transaction management, and distributed...');
  final _creditsController = TextEditingController(text: '3');

  String _department = 'Computer Science';
  String _semester   = 'Semester 1';
  String _teacher    = 'Dr. Samnang Chea';

  @override
  void initState() {
    super.initState();
    _creditsController.addListener(() => setState(() => _hasUnsavedChanges = true));
  }

  @override
  void dispose() {
    _codeController.dispose();
    _nameController.dispose();
    _descController.dispose();
    _creditsController.dispose();
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
        title: Text('Edit Course',
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
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          children: [
            _buildGeneralInfoSection(),
            const SizedBox(height: 16),
            _buildFacultySection(),
            const SizedBox(height: 16),
            _buildEnrolledStudentsSection(),
            const SizedBox(height: 16),
            if (_hasUnsavedChanges) ...[
              _buildUnsavedWarning(),
              const SizedBox(height: 16),
            ],
            _buildActions(context),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildGeneralInfoSection() {
    return _Section(
      title: 'General Information',
      children: [
        _LabelField(label: 'Course Code', controller: _codeController),
        const SizedBox(height: 12),
        _LabelField(label: 'Course Name', controller: _nameController),
        const SizedBox(height: 12),
        _LabelField(
            label: 'Description', controller: _descController, maxLines: 4),
        const SizedBox(height: 12),
        _LabelField(label: 'Credits', controller: _creditsController,
            keyboardType: TextInputType.number),
        const SizedBox(height: 12),
        _LabelDropdown(
          label: 'Department',
          value: _department,
          items: ['Computer Science', 'Business Admin', 'Engineering',
                  'Languages', 'Mathematics', 'Law'],
          onChanged: (v) => setState(() {
            _department = v!;
            _hasUnsavedChanges = true;
          }),
        ),
        const SizedBox(height: 12),
        _LabelDropdown(
          label: 'Semester',
          value: _semester,
          items: ['Semester 1', 'Semester 2', 'Semester 3'],
          onChanged: (v) => setState(() {
            _semester = v!;
            _hasUnsavedChanges = true;
          }),
        ),
      ],
    );
  }

  Widget _buildFacultySection() {
    return _Section(
      title: 'Faculty Assignment',
      children: [
        _LabelDropdown(
          label: 'Lead Teacher',
          value: _teacher,
          items: ['Dr. Samnang Chea', 'Dr. Sam Sokha', 'Prof. Linda Smith',
                  'Mr. Chan Dara', 'Mr. Ratha Tep'],
          onChanged: (v) => setState(() {
            _teacher = v!;
            _hasUnsavedChanges = true;
          }),
        ),
      ],
    );
  }

  Widget _buildEnrolledStudentsSection() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.statusBlueBg,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(color: AppColors.primaryBlue.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.people_outline, color: AppColors.primaryBlue, size: 20),
          const SizedBox(width: 8),
          Text('Enrolled Students',
              style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.primaryBlue)),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('124',
                  style: AppTextStyles.metric.copyWith(
                      color: AppColors.primaryNavy, fontSize: 22)),
              Text('Capacity: 150 (82% full)',
                  style: AppTextStyles.label.copyWith(
                      fontSize: 9, letterSpacing: 0)),
              const SizedBox(height: 4),
              SizedBox(
                width: 120,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: 124 / 150,
                    minHeight: 6,
                    backgroundColor: AppColors.border,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                        AppColors.primaryBlue),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUnsavedWarning() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF9C4),
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(color: const Color(0xFFF9A825)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline,
              size: 16, color: Color(0xFFF9A825)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Unsaved Changes — You have edited the credits field. Click save to apply the changes.',
              style: AppTextStyles.caption.copyWith(color: const Color(0xFF5D4037)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: () {
            setState(() => _hasUnsavedChanges = false);
          },
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 50),
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
        const SizedBox(height: 10),
        OutlinedButton(
          onPressed: () => _showDeleteDialog(context),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(double.infinity, 50),
            side: const BorderSide(color: AppColors.statusRed),
            foregroundColor: AppColors.statusRed,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSpacing.buttonRadius)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.delete_outline, size: 18),
              const SizedBox(width: 8),
              Text('Delete Course',
                  style: AppTextStyles.button.copyWith(
                      color: AppColors.statusRed)),
            ],
          ),
        ),
      ],
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Delete Course', style: AppTextStyles.h3),
        content: Text(
          'Are you sure you want to delete this course? This action cannot be undone.',
          style: AppTextStyles.body,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: AppTextStyles.link),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.pop();
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.statusRed),
            child: Text('Delete', style: AppTextStyles.button),
          ),
        ],
      ),
    );
  }
}

// ── Shared widgets ─────────────────────────────────────────────────────────────

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.children});
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
          Text(title, style: AppTextStyles.h3),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }
}

class _LabelField extends StatelessWidget {
  const _LabelField({
    required this.label,
    required this.controller,
    this.maxLines = 1,
    this.keyboardType,
  });

  final String label;
  final TextEditingController controller;
  final int maxLines;
  final TextInputType? keyboardType;

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
          keyboardType: keyboardType,
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

class _LabelDropdown extends StatelessWidget {
  const _LabelDropdown({
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
        Text(label,
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
              value: value,
              isExpanded: true,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
              items: items
                  .map((e) => DropdownMenuItem(
                      value: e, child: Text(e, style: AppTextStyles.body)))
                  .toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}
