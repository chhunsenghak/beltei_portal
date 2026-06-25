import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';

// ── Mock data ──────────────────────────────────────────────────────────────────

final _kStudents = [
  (id: 'S001', initials: 'SK', name: 'Sovannarith Keo',  studentId: 'B2023-08812', status: 'Active',    hasPhoto: false),
  (id: 'S002', initials: 'VM', name: 'Vannary Mean',     studentId: 'B2022-12455', status: 'Suspended', hasPhoto: false),
  (id: 'S003', initials: 'TC', name: 'Thida Chhay',      studentId: 'B2024-00102', status: 'Active',    hasPhoto: false),
  (id: 'S004', initials: 'SP', name: 'Sereyvath Phann',  studentId: 'B2021-09932', status: 'Active',    hasPhoto: false),
  (id: 'S005', initials: 'DS', name: 'Dina Sok',         studentId: 'B2023-05431', status: 'Suspended', hasPhoto: false),
  (id: 'S006', initials: 'VK', name: 'Vanna Kosal',      studentId: 'B2021-00055', status: 'Active',    hasPhoto: false),
  (id: 'S007', initials: 'CN', name: 'Chan Narith',      studentId: 'B2021-00062', status: 'Active',    hasPhoto: false),
  (id: 'S008', initials: 'SB', name: 'Srey Bopha',       studentId: 'B2024-00007', status: 'On Leave',  hasPhoto: false),
];

final _kTeachers = [
  (
    id: 'T001', initials: 'SC', name: 'Dr. Sarah Connor',
    teacherId: 'B-2024-001', faculty: 'Faculty of Engineering',
    type: 'Full-time', status: 'Active', courses: 5,
  ),
  (
    id: 'T002', initials: 'JW', name: 'Johnathan Wick',
    teacherId: 'B-2024-042', faculty: 'General Education',
    type: 'Visiting', status: 'Active', courses: 3,
  ),
  (
    id: 'T003', initials: 'EG', name: 'Prof. Elena Gilbert',
    teacherId: 'B-2023-889', faculty: 'Mathematics & Physics',
    type: 'Tenured', status: 'On Leave', courses: 0,
  ),
  (
    id: 'T004', initials: 'MA', name: 'Marcus Aurelius',
    teacherId: 'B-2024-112', faculty: 'Philosophy',
    type: 'Part-time', status: 'Active', courses: 2,
  ),
  (
    id: 'T005', initials: 'LK', name: 'Ms. Lida Keo',
    teacherId: 'B-2023-015', faculty: 'Business Administration',
    type: 'Full-time', status: 'Active', courses: 5,
  ),
  (
    id: 'T006', initials: 'RT', name: 'Mr. Ratha Tep',
    teacherId: 'B-2021-003', faculty: 'Law & Politics',
    type: 'Full-time', status: 'Active', courses: 2,
  ),
];

// ── Screen ────────────────────────────────────────────────────────────────────

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  String _searchQuery = '';
  String _deptFilter = 'All Students';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: AppColors.primaryBlue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildFilterChips(),
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [_buildStudentList(), _buildTeacherList()],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: TextField(
        onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
        decoration: InputDecoration(
          hintText: _tabController.index == 0
              ? 'Search by student name or ID...'
              : 'Search teachers by name, ID or department...',
          hintStyle: AppTextStyles.caption,
          prefixIcon:
              const Icon(Icons.search, color: AppColors.textLabel, size: 20),
          filled: true,
          fillColor: AppColors.bgInput,
          contentPadding: const EdgeInsets.symmetric(vertical: 10),
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
    );
  }

  Widget _buildFilterChips() {
    if (_tabController.index == 0) {
      final chips = ['All Students', 'Faculty', 'Department'];
      return Container(
        color: Colors.white,
        padding: const EdgeInsets.only(left: 16, right: 16, bottom: 12),
        child: Row(
          children: chips.map((chip) {
            final isSelected = chip == _deptFilter;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () => setState(() => _deptFilter = chip),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primaryNavy : Colors.white,
                    borderRadius: BorderRadius.circular(AppSpacing.chipRadius),
                    border: Border.all(
                      color: isSelected ? AppColors.primaryNavy : AppColors.border,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(chip,
                          style: AppTextStyles.caption.copyWith(
                              color: isSelected ? Colors.white : AppColors.textSecondary,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.normal)),
                      if (!isSelected && chip != 'All Students') ...[
                        const SizedBox(width: 4),
                        Icon(Icons.keyboard_arrow_down,
                            size: 14,
                            color: AppColors.textSecondary),
                      ],
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      );
    }
    // Teacher filter chips
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.tune, size: 14),
            label: const Text('Advanced Filters'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.textSecondary,
              side: const BorderSide(color: AppColors.border),
              textStyle: AppTextStyles.caption,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: Colors.white,
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

  Widget _buildStudentList() {
    final filtered = _searchQuery.isEmpty
        ? _kStudents
        : _kStudents
            .where((s) =>
                s.name.toLowerCase().contains(_searchQuery) ||
                s.studentId.toLowerCase().contains(_searchQuery))
            .toList();

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
              Text('Showing ${filtered.length} Students',
                  style: AppTextStyles.caption),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            itemCount: filtered.length,
            itemBuilder: (context, i) {
              final s = filtered[i];
              return _StudentRow(
                initials: s.initials,
                name: s.name,
                studentId: s.studentId,
                status: s.status,
                onTap: () => context.push('/admin/users/students/${s.id}'),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTeacherList() {
    final filtered = _searchQuery.isEmpty
        ? _kTeachers
        : _kTeachers
            .where((t) =>
                t.name.toLowerCase().contains(_searchQuery) ||
                t.teacherId.toLowerCase().contains(_searchQuery))
            .toList();

    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      itemCount: filtered.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, i) {
        final t = filtered[i];
        return _TeacherCard(
          initials: t.initials,
          name: t.name,
          teacherId: t.teacherId,
          faculty: t.faculty,
          type: t.type,
          status: t.status,
          courses: t.courses,
          onTap: () => context.push('/admin/users/teachers/${t.id}'),
        );
      },
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
      case 'Active':    return AppColors.statusGreen;
      case 'Suspended': return AppColors.statusRed;
      case 'On Leave':  return AppColors.statusAmber;
      default:          return AppColors.statusGray;
    }
  }

  Color get _statusBg {
    switch (status) {
      case 'Active':    return AppColors.statusGreenBg;
      case 'Suspended': return AppColors.statusRedBg;
      case 'On Leave':  return AppColors.statusAmberBg;
      default:          return AppColors.statusGrayBg;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 1),
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(bottom: BorderSide(color: AppColors.border)),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: AppColors.primaryNavy.withValues(alpha: 0.12),
              child: Text(initials,
                  style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.primaryNavy,
                      fontWeight: FontWeight.w700)),
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
            const Icon(Icons.chevron_right,
                color: AppColors.textLabel, size: 18),
          ],
        ),
      ),
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
    required this.type,
    required this.status,
    required this.courses,
    required this.onTap,
  });

  final String initials, name, teacherId, faculty, type, status;
  final int courses;
  final VoidCallback onTap;

  Color get _statusColor {
    switch (status) {
      case 'Active':   return AppColors.statusGreen;
      case 'On Leave': return AppColors.statusAmber;
      default:         return AppColors.statusGray;
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
                          color: AppColors.primaryNavy,
                          fontWeight: FontWeight.w700)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, style: AppTextStyles.bodyMedium),
                      Text(
                        '$status • $type',
                        style: AppTextStyles.caption.copyWith(
                          color: _statusColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text('ID: ', style: AppTextStyles.caption),
                Text(teacherId,
                    style: AppTextStyles.caption.copyWith(
                        fontWeight: FontWeight.w600)),
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
            const Divider(height: 1, color: AppColors.divider),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text('COURSES: ',
                        style: AppTextStyles.label.copyWith(letterSpacing: 0.6)),
                    Text(courses.toString().padLeft(2, '0'),
                        style: AppTextStyles.bodySemiBold.copyWith(
                            color: AppColors.primaryNavy)),
                  ],
                ),
                Row(
                  children: [
                    _IconBtn(
                        icon: Icons.edit_outlined,
                        color: AppColors.textSecondary,
                        onTap: () => context.push(
                            '/admin/users/teachers/T00$courses')),
                    const SizedBox(width: 8),
                    _IconBtn(
                        icon: Icons.more_vert,
                        color: AppColors.textSecondary,
                        onTap: () {}),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _IconBtn extends StatelessWidget {
  const _IconBtn({required this.icon, required this.color, required this.onTap});
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Icon(icon, size: 18, color: color),
    );
  }
}
