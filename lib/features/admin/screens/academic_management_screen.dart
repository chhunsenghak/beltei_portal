import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import 'course_management_screen.dart';
import 'faculty_department_screen.dart';
import 'academic_calendar_screen.dart';
import 'enrollment_management_screen.dart';
import 'class_management_screen.dart';
import 'attendance_management_screen.dart';
import 'global_leave_requests_screen.dart';

class AcademicManagementScreen extends StatefulWidget {
  const AcademicManagementScreen({super.key});

  @override
  State<AcademicManagementScreen> createState() =>
      _AcademicManagementScreenState();
}

class _AcademicManagementScreenState extends State<AcademicManagementScreen> {
  int _selectedIndex = 0;

  static const _tabs = [
    (label: 'Faculty',    icon: Icons.account_balance_outlined),
    (label: 'Academic Calendar', icon: Icons.calendar_month_outlined),
    (label: 'Courses',    icon: Icons.menu_book_outlined),
    (label: 'Classes',    icon: Icons.class_outlined),
    (label: 'Enrollment', icon: Icons.how_to_reg_outlined),
    (label: 'Attendance', icon: Icons.fact_check_outlined),
    (label: 'Leave',      icon: Icons.event_busy_outlined),
  ];

  static const _bodies = [
    FacultyDepartmentScreen(),
    AcademicCalendarScreen(),
    CourseManagementScreen(),
    ClassManagementScreen(),
    EnrollmentManagementScreen(),
    AttendanceManagementScreen(),
    GlobalLeaveRequestsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      body: Column(
        children: [
          _buildSecondaryNav(),
          Expanded(child: _bodies[_selectedIndex]),
        ],
      ),
    );
  }

  Widget _buildSecondaryNav() {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              itemCount: _tabs.length,
              itemBuilder: (context, i) {
                final isSelected = i == _selectedIndex;
                return GestureDetector(
                  onTap: () => setState(() => _selectedIndex = i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    margin: const EdgeInsets.only(right: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primaryNavy
                          : AppColors.bgPage,
                      borderRadius: BorderRadius.circular(AppSpacing.chipRadius),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primaryNavy
                            : AppColors.border,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(_tabs[i].icon,
                            size: 14,
                            color: isSelected
                                ? Colors.white
                                : AppColors.textSecondary),
                        const SizedBox(width: 5),
                        Text(
                          _tabs[i].label,
                          style: AppTextStyles.caption.copyWith(
                            color: isSelected
                                ? Colors.white
                                : AppColors.textSecondary,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Divider(height: 1, color: AppColors.border),
        ],
      ),
    );
  }
}
