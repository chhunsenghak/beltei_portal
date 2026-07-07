import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/providers/admin_providers.dart';
import '../../../core/services/admin_service.dart';

// ── Screen ────────────────────────────────────────────────────────────────────

class UserManagementScreen extends ConsumerStatefulWidget {
  const UserManagementScreen({super.key, this.initialRole});
  final String? initialRole;

  @override
  ConsumerState<UserManagementScreen> createState() =>
      _UserManagementScreenState();
}

class _UserManagementScreenState extends ConsumerState<UserManagementScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    final int initialIndex = widget.initialRole == 'teacher' ? 1 : 0;
    _tabController = TabController(length: 2, vsync: this, initialIndex: initialIndex);
    _tabController.addListener(() {
      if (!mounted) return;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() {});
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final studentsAsync = ref.watch(adminStudentsProvider);
    final teachersAsync = ref.watch(adminTeachersProvider);

    return Scaffold(
      backgroundColor: AppColors.bgPage,
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddUserSheet(context),
        backgroundColor: AppColors.primaryNavy,
        child: const Icon(Icons.person_add_outlined, color: Colors.white),
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildStudentTab(studentsAsync),
                _buildTeacherTab(teachersAsync),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      color: AppColors.bgPage,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: TextField(
        onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
        decoration: InputDecoration(
          hintText: _tabController.index == 0
              ? 'Search by student name or ID...'
              : 'Search teachers by name, ID or department...',
          hintStyle: AppTextStyles.caption,
          prefixIcon:
              Icon(Icons.search, color: AppColors.textLabel, size: 20),
          filled: true,
          fillColor: AppColors.bgInput,
          contentPadding: const EdgeInsets.symmetric(vertical: 10),
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
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: AppColors.bgPage,
      child: TabBar(
        controller: _tabController,
        labelColor: AppColors.primaryNavy,
        unselectedLabelColor: AppColors.textSecondary,
        indicatorColor: AppColors.primaryNavy,
        labelStyle: AppTextStyles.bodySemiBold.copyWith(fontSize: 14),
        tabs: const [Tab(text: 'Students'), Tab(text: 'Teachers')],
      ),
    );
  }

  // ── Student tab ────────────────────────────────────────────────────────────

  Widget _buildStudentTab(AsyncValue<List<AdminStudent>> async) {
    return async.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => _buildError(() => ref.invalidate(adminStudentsProvider)),
      data: (all) {
        final filtered = _searchQuery.isEmpty
            ? all
            : all.where((s) =>
                s.fullName.toLowerCase().contains(_searchQuery) ||
                s.studentCode.toLowerCase().contains(_searchQuery)).toList();

        return Column(
          children: [
            Container(
              width: double.infinity,
              color: AppColors.bgPage,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Student Directory',
                      style: AppTextStyles.h3.copyWith(color: AppColors.primaryNavy)),
                  Text('${filtered.length} Students', style: AppTextStyles.caption),
                ],
              ),
            ),
            Expanded(
              child: filtered.isEmpty
                  ? _buildEmpty('No students found')
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      itemCount: filtered.length,
                      itemBuilder: (_, i) {
                        final s = filtered[i];
                        return _StudentRow(
                          initials: s.initials,
                          name: s.fullName,
                          studentId: s.studentCode,
                          status: s.statusLabel,
                          onTap: () => context.push('/admin/users/students/${s.id}'),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  // ── Teacher tab ────────────────────────────────────────────────────────────

  Widget _buildTeacherTab(AsyncValue<List<AdminTeacher>> async) {
    return async.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => _buildError(() => ref.invalidate(adminTeachersProvider)),
      data: (all) {
        final filtered = _searchQuery.isEmpty
            ? all
            : all.where((t) =>
                t.fullName.toLowerCase().contains(_searchQuery) ||
                t.employeeCode.toLowerCase().contains(_searchQuery)).toList();

        return filtered.isEmpty
            ? _buildEmpty('No teachers found')
            : ListView.separated(
                padding: const EdgeInsets.all(AppSpacing.screenPadding),
                itemCount: filtered.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (_, i) {
                  final t = filtered[i];
                  return _TeacherCard(
                    initials: t.initials,
                    name: t.fullName,
                    teacherId: t.employeeCode,
                    faculty: t.facultyName ?? 'No Faculty',
                    status: t.statusLabel,
                    courses: t.courseCount,
                    onTap: () => context.push('/admin/users/teachers/${t.id}'),
                  );
                },
              );
      },
    );
  }

  void _showAddUserSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _AddUserSheet(),
    );
  }

  Widget _buildError(VoidCallback onRetry) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline, color: AppColors.statusRed, size: 40),
          const SizedBox(height: 8),
          Text('Could not load data', style: AppTextStyles.bodyMedium),
          TextButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }

  Widget _buildEmpty(String msg) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_outlined, color: AppColors.textLabel, size: 48),
          const SizedBox(height: 12),
          Text(msg, style: AppTextStyles.body.copyWith(color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

// ── Student row ────────────────────────────────────────────────────────────────

class _StudentRow extends StatelessWidget {
  const _StudentRow({
    required this.initials,
    required this.name,
    required this.studentId,
    required this.status,
    required this.onTap,
  });

  final String initials, name, studentId, status;
  final VoidCallback onTap;

  Color get _statusColor {
    switch (status) {
      case 'Active': return AppColors.statusGreen;
      case 'Suspended': return AppColors.statusRed;
      case 'Graduated': return AppColors.primaryBlue;
      default: return AppColors.statusGray;
    }
  }

  Color get _statusBg {
    switch (status) {
      case 'Active': return AppColors.statusGreenBg;
      case 'Suspended': return AppColors.statusRedBg;
      case 'Graduated': return AppColors.statusBlueBg;
      default: return AppColors.statusGrayBg;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 1),
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          border: Border(bottom: BorderSide(color: AppColors.border)),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: AppColors.primaryNavy.withValues(alpha: 0.12),
              child: Text(initials,
                  style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.primaryNavy, fontWeight: FontWeight.w700)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: AppTextStyles.bodyMedium),
                  Text('ID: $studentId',
                      style: AppTextStyles.caption.copyWith(fontSize: 11)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: _statusBg,
                borderRadius: BorderRadius.circular(AppSpacing.chipRadius),
              ),
              child: Text(status,
                  style: AppTextStyles.caption.copyWith(
                      color: _statusColor, fontWeight: FontWeight.w600)),
            ),
            const SizedBox(width: 8),
            Icon(Icons.chevron_right, color: AppColors.textLabel, size: 18),
          ],
        ),
      ),
    );
  }
}

// ── Add user bottom sheet ──────────────────────────────────────────────────────

class _AddUserSheet extends ConsumerStatefulWidget {
  const _AddUserSheet();

  @override
  ConsumerState<_AddUserSheet> createState() => _AddUserSheetState();
}

class _AddUserSheetState extends ConsumerState<_AddUserSheet> {
  bool _isStudent = true;
  bool _saving = false;

  final _firstNameCtrl    = TextEditingController();
  final _lastNameCtrl     = TextEditingController();
  final _emailCtrl        = TextEditingController();
  final _passwordCtrl     = TextEditingController();
  final _phoneCtrl        = TextEditingController();
  final _studentCodeCtrl  = TextEditingController();
  final _employeeCodeCtrl = TextEditingController();
  final _positionCtrl     = TextEditingController();

  String? _facultyId;
  String? _majorId;
  String _gender = 'Male';
  int _yearLevel = 1;
  int _enrollmentYear = DateTime.now().year;

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _phoneCtrl.dispose();
    _studentCodeCtrl.dispose();
    _employeeCodeCtrl.dispose();
    _positionCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final firstName = _firstNameCtrl.text.trim();
    final lastName  = _lastNameCtrl.text.trim();
    final email     = _emailCtrl.text.trim();
    final password  = _passwordCtrl.text.trim();

    if (firstName.isEmpty || lastName.isEmpty || email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all required fields')),
      );
      return;
    }

    if (_isStudent && _studentCodeCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Student Code is required')),
      );
      return;
    }

    if (!_isStudent && _employeeCodeCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Employee Code is required')),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      if (_isStudent) {
        await ref.read(adminServiceProvider).createStudent(
          firstName: firstName,
          lastName: lastName,
          email: email,
          password: password,
          studentCode: _studentCodeCtrl.text.trim(),
          phone: _phoneCtrl.text.trim(),
          gender: _gender,
          facultyId: _facultyId,
          majorId: _majorId,
          yearLevel: _yearLevel,
          enrollmentYear: _enrollmentYear,
        );
        ref.invalidate(adminStudentsProvider);
      } else {
        await ref.read(adminServiceProvider).createTeacher(
          firstName: firstName,
          lastName: lastName,
          email: email,
          password: password,
          employeeCode: _employeeCodeCtrl.text.trim(),
          phone: _phoneCtrl.text.trim(),
          position: _positionCtrl.text.trim(),
          facultyId: _facultyId,
        );
        ref.invalidate(adminTeachersProvider);
      }
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User created successfully'), backgroundColor: AppColors.statusGreen),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.statusRed),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final faculties  = ref.watch(adminFacultiesProvider).valueOrNull ?? [];
    final allMajors  = ref.watch(adminMajorsProvider).valueOrNull ?? [];
    final filteredMajors = _facultyId == null
        ? allMajors
        : allMajors.where((m) => m.facultyId == _facultyId).toList();

    return DraggableScrollableSheet(
      initialChildSize: 0.92,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, scrollController) => Container(
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 8),
            Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2))),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Add New User', style: AppTextStyles.h3.copyWith(color: AppColors.primaryNavy)),
                  IconButton(
                    icon: Icon(Icons.close, color: AppColors.textLabel),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: AppColors.border),
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.all(16),
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() { _isStudent = true; _majorId = null; _facultyId = null; }),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: _isStudent ? AppColors.primaryNavy : Colors.white,
                              borderRadius: BorderRadius.circular(AppSpacing.chipRadius),
                              border: Border.all(color: _isStudent ? AppColors.primaryNavy : AppColors.border),
                            ),
                            child: Center(
                              child: Text('Student',
                                  style: AppTextStyles.bodySemiBold.copyWith(
                                      color: _isStudent ? Colors.white : AppColors.textSecondary)),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() { _isStudent = false; _majorId = null; _facultyId = null; }),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: !_isStudent ? AppColors.primaryNavy : Colors.white,
                              borderRadius: BorderRadius.circular(AppSpacing.chipRadius),
                              border: Border.all(color: !_isStudent ? AppColors.primaryNavy : AppColors.border),
                            ),
                            child: Center(
                              child: Text('Teacher',
                                  style: AppTextStyles.bodySemiBold.copyWith(
                                      color: !_isStudent ? Colors.white : AppColors.textSecondary)),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _SheetField(label: 'First Name *', controller: _firstNameCtrl),
                  const SizedBox(height: 12),
                  _SheetField(label: 'Last Name *', controller: _lastNameCtrl),
                  const SizedBox(height: 12),
                  _SheetField(label: 'Email *', controller: _emailCtrl, keyboardType: TextInputType.emailAddress),
                  const SizedBox(height: 12),
                  _SheetField(label: 'Temporary Password *', controller: _passwordCtrl, obscureText: true),
                  const SizedBox(height: 12),
                  _SheetField(label: 'Phone', controller: _phoneCtrl, keyboardType: TextInputType.phone),
                  const SizedBox(height: 12),
                  if (_isStudent) ...[
                    _SheetField(label: 'Student Code *', controller: _studentCodeCtrl),
                    const SizedBox(height: 12),
                    _SheetDropdown<String?>(
                      label: 'Faculty',
                      value: _facultyId,
                      items: [
                        const DropdownMenuItem(value: null, child: Text('None')),
                        ...faculties.map((f) => DropdownMenuItem(value: f.id, child: Text(f.name))),
                      ],
                      onChanged: (v) => setState(() { _facultyId = v; _majorId = null; }),
                    ),
                    const SizedBox(height: 12),
                    _SheetDropdown<String?>(
                      label: 'Major',
                      value: _majorId,
                      items: [
                        const DropdownMenuItem(value: null, child: Text('None')),
                        ...filteredMajors.map((m) => DropdownMenuItem(value: m.id, child: Text(m.name))),
                      ],
                      onChanged: (v) => setState(() => _majorId = v),
                    ),
                    const SizedBox(height: 12),
                    _SheetDropdown<int>(
                      label: 'Year Level',
                      value: _yearLevel,
                      items: List.generate(6, (i) => DropdownMenuItem(value: i + 1, child: Text('Year ${i + 1}'))),
                      onChanged: (v) => setState(() => _yearLevel = v ?? 1),
                    ),
                    const SizedBox(height: 12),
                    _SheetDropdown<String>(
                      label: 'Gender',
                      value: _gender,
                      items: const [
                        DropdownMenuItem(value: 'Male', child: Text('Male')),
                        DropdownMenuItem(value: 'Female', child: Text('Female')),
                        DropdownMenuItem(value: 'Other', child: Text('Other')),
                      ],
                      onChanged: (v) => setState(() => _gender = v ?? 'Male'),
                    ),
                    const SizedBox(height: 12),
                    _SheetDropdown<int>(
                      label: 'Enrollment Year',
                      value: _enrollmentYear,
                      items: List.generate(10, (i) {
                        final y = DateTime.now().year - i;
                        return DropdownMenuItem(value: y, child: Text('$y'));
                      }),
                      onChanged: (v) => setState(() => _enrollmentYear = v ?? DateTime.now().year),
                    ),
                  ] else ...[
                    _SheetField(label: 'Employee Code *', controller: _employeeCodeCtrl),
                    const SizedBox(height: 12),
                    _SheetField(label: 'Position', controller: _positionCtrl),
                    const SizedBox(height: 12),
                    _SheetDropdown<String?>(
                      label: 'Faculty',
                      value: _facultyId,
                      items: [
                        const DropdownMenuItem(value: null, child: Text('None')),
                        ...faculties.map((f) => DropdownMenuItem(value: f.id, child: Text(f.name))),
                      ],
                      onChanged: (v) => setState(() => _facultyId = v),
                    ),
                  ],
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _saving ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      backgroundColor: AppColors.primaryNavy,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.buttonRadius)),
                    ),
                    child: _saving
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : Text('Create User', style: AppTextStyles.button),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SheetField extends StatelessWidget {
  const _SheetField({
    required this.label,
    required this.controller,
    this.obscureText = false,
    this.keyboardType,
  });

  final String label;
  final TextEditingController controller;
  final bool obscureText;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
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

class _SheetDropdown<T> extends StatelessWidget {
  const _SheetDropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final String label;
  final T value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;

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
            child: DropdownButton<T>(
              value: value,
              isExpanded: true,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
              items: items,
              onChanged: onChanged,
              style: AppTextStyles.body,
            ),
          ),
        ),
      ],
    );
  }
}

// ── Teacher card ───────────────────────────────────────────────────────────────

class _TeacherCard extends StatelessWidget {
  const _TeacherCard({
    required this.initials,
    required this.name,
    required this.teacherId,
    required this.faculty,
    required this.status,
    required this.courses,
    required this.onTap,
  });

  final String initials, name, teacherId, faculty, status;
  final int courses;
  final VoidCallback onTap;

  Color get _statusColor {
    switch (status) {
      case 'Active': return AppColors.statusGreen;
      default: return AppColors.statusGray;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
                CircleAvatar(
                  radius: 24,
                  backgroundColor: AppColors.primaryNavy.withValues(alpha: 0.12),
                  child: Text(initials,
                      style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.primaryNavy, fontWeight: FontWeight.w700)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, style: AppTextStyles.bodyMedium),
                      Text(status,
                          style: AppTextStyles.caption
                              .copyWith(color: _statusColor, fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: AppColors.textLabel, size: 18),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text('ID: ', style: AppTextStyles.caption),
                Text(teacherId,
                    style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w600)),
              ],
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(AppSpacing.tagRadius),
              ),
              child: Text(faculty,
                  style: AppTextStyles.label.copyWith(
                      color: AppColors.primaryBlue, letterSpacing: 0.3)),
            ),
            const SizedBox(height: 10),
            Divider(height: 1, color: AppColors.divider),
            const SizedBox(height: 10),
            Row(
              children: [
                Text('ACTIVE COURSES: ',
                    style: AppTextStyles.label.copyWith(letterSpacing: 0.6)),
                Text(courses.toString().padLeft(2, '0'),
                    style:
                        AppTextStyles.bodySemiBold.copyWith(color: AppColors.primaryNavy)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
