import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';

final _kFaculties = [
  (icon: Icons.account_balance_outlined, iconColor: AppColors.primaryNavy,
   name: 'Faculty of Business Administration', code: 'FBA-01',
   dean: 'Dr. Sok Sopheap', departments: 12),
  (icon: Icons.computer_outlined, iconColor: AppColors.primaryBlue,
   name: 'Faculty of Information Technology', code: 'FIT-02',
   dean: 'Keo Vannak, PhD', departments: 8),
  (icon: Icons.translate_outlined, iconColor: Color(0xFF7C3AED),
   name: 'Faculty of Foreign Languages', code: 'FFL-03',
   dean: 'Ms. Maria Chen', departments: 5),
  (icon: Icons.gavel_outlined, iconColor: AppColors.statusAmber,
   name: 'Faculty of Law', code: 'LAW-04',
   dean: 'Sam Vichet, LLM', departments: 4),
  (icon: Icons.biotech_outlined, iconColor: AppColors.statusGreen,
   name: 'Faculty of Engineering & Science', code: 'ENG-05',
   dean: 'Prof. Dara Meas, PhD', departments: 7),
];

final _kDepartments = [
  (faculty: 'FBA-01', name: 'Management & Entrepreneurship', code: 'MGT-01', students: 450),
  (faculty: 'FBA-01', name: 'Accounting & Finance',          code: 'ACC-02', students: 380),
  (faculty: 'FBA-01', name: 'Marketing',                     code: 'MKT-03', students: 290),
  (faculty: 'FIT-02', name: 'Computer Science',              code: 'CS-01',  students: 520),
  (faculty: 'FIT-02', name: 'Information Systems',           code: 'IS-02',  students: 310),
  (faculty: 'FIT-02', name: 'Network Engineering',           code: 'NET-03', students: 180),
  (faculty: 'FFL-03', name: 'English Language',              code: 'ENG-01', students: 420),
  (faculty: 'FFL-03', name: 'Chinese Language',              code: 'CHN-02', students: 230),
];

class FacultyDepartmentScreen extends StatefulWidget {
  const FacultyDepartmentScreen({super.key});

  @override
  State<FacultyDepartmentScreen> createState() =>
      _FacultyDepartmentScreenState();
}

class _FacultyDepartmentScreenState extends State<FacultyDepartmentScreen> {
  bool _showFaculties = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: AppColors.primaryBlue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Academic Structure', style: AppTextStyles.h1.copyWith(color: AppColors.primaryNavy)),
                  const SizedBox(height: 4),
                  Text('Manage higher education faculties and their respective academic departments.',
                      style: AppTextStyles.caption),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.cardPadding),
                    decoration: BoxDecoration(
                      color: AppColors.bgCard,
                      borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 48, height: 48,
                          decoration: BoxDecoration(
                            color: AppColors.primaryBlue.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.school_outlined,
                              color: AppColors.primaryBlue, size: 24),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('TOTAL ENTITIES',
                                style: AppTextStyles.label.copyWith(fontSize: 9)),
                            Text('48 Units', style: AppTextStyles.h2),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildToggle(),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: _showFaculties
                ? _buildFacultiesList()
                : _buildDepartmentsList(),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
    );
  }

  Widget _buildToggle() {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: AppColors.bgPage,
        borderRadius: BorderRadius.circular(AppSpacing.chipRadius),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(child: _ToggleOption(label: 'Faculties', isSelected: _showFaculties,
              onTap: () => setState(() => _showFaculties = true))),
          Expanded(child: _ToggleOption(label: 'Departments', isSelected: !_showFaculties,
              onTap: () => setState(() => _showFaculties = false))),
        ],
      ),
    );
  }

  SliverList _buildFacultiesList() {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, i) {
          final f = _kFaculties[i];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
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
                      Container(
                        width: 44, height: 44,
                        decoration: BoxDecoration(
                          color: f.iconColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(f.icon, color: f.iconColor, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(f.name, style: AppTextStyles.bodyMedium),
                            Text('Code: ${f.code}', style: AppTextStyles.caption),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 12,
                        backgroundColor: AppColors.border,
                        child: const Icon(Icons.person, size: 14, color: AppColors.textSecondary),
                      ),
                      const SizedBox(width: 6),
                      Text(f.dean, style: AppTextStyles.caption),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primaryBlue.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(AppSpacing.chipRadius),
                        ),
                        child: Text('${f.departments} Departments',
                            style: AppTextStyles.label.copyWith(
                                color: AppColors.primaryBlue, letterSpacing: 0.3)),
                      ),
                      GestureDetector(
                        onTap: () {},
                        child: const Icon(Icons.edit_outlined,
                            size: 18, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
        childCount: _kFaculties.length,
      ),
    );
  }

  SliverList _buildDepartmentsList() {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, i) {
          final d = _kDepartments[i];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.cardPadding),
              decoration: BoxDecoration(
                color: AppColors.bgCard,
                borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.primaryNavy.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.meeting_room_outlined,
                        color: AppColors.primaryNavy, size: 18),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(d.name, style: AppTextStyles.bodyMedium),
                        Text('Code: ${d.code} • Faculty: ${d.faculty}',
                            style: AppTextStyles.caption),
                        Text('${d.students} Students',
                            style: AppTextStyles.label.copyWith(
                                color: AppColors.primaryBlue, letterSpacing: 0.3)),
                      ],
                    ),
                  ),
                  const Icon(Icons.edit_outlined,
                      size: 18, color: AppColors.textSecondary),
                ],
              ),
            ),
          );
        },
        childCount: _kDepartments.length,
      ),
    );
  }
}

class _ToggleOption extends StatelessWidget {
  const _ToggleOption(
      {required this.label, required this.isSelected, required this.onTap});
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(AppSpacing.chipRadius - 2),
          boxShadow: isSelected
              ? [BoxShadow(color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 4, offset: const Offset(0, 1))]
              : null,
        ),
        child: Center(
          child: Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(
              color: isSelected ? AppColors.primaryNavy : AppColors.textSecondary,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}
