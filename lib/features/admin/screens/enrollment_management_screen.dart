import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';

final _kEnrollments = [
  (
    id: 'IT-402', section: 'Section A',
    title: 'Advanced Data Structures', teacher: 'Professor Sovannrith K.',
    enrolled: 42, capacity: 50, pct: 0.84,
    barColor: AppColors.primaryNavy,
  ),
  (
    id: 'BUS-201', section: 'Section C',
    title: 'Business Analytics', teacher: 'Dr. Leakhena Sam',
    enrolled: 12, capacity: 30, pct: 0.40,
    barColor: AppColors.statusAmber,
  ),
  (
    id: 'LAW-105', section: 'Section B',
    title: 'International Civil Law', teacher: 'Prof. Channary Sok',
    enrolled: 45, capacity: 45, pct: 1.0,
    barColor: AppColors.statusRed,
  ),
  (
    id: 'ENG-110', section: 'Section G',
    title: 'Technical Writing', teacher: 'Ms. Sreymom Pen',
    enrolled: 28, capacity: 40, pct: 0.70,
    barColor: AppColors.primaryBlue,
  ),
];

class EnrollmentManagementScreen extends StatefulWidget {
  const EnrollmentManagementScreen({super.key});

  @override
  State<EnrollmentManagementScreen> createState() =>
      _EnrollmentManagementScreenState();
}

class _EnrollmentManagementScreenState
    extends State<EnrollmentManagementScreen> {
  String _filter = 'All Courses';
  String _semester = 'Current Semester';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: AppColors.primaryBlue,
        child: const Icon(Icons.person_add_outlined, color: Colors.white),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        children: [
          _buildActivePeriodCard(),
          const SizedBox(height: 12),
          _buildBulkEnrollmentCard(),
          const SizedBox(height: 20),
          Text('Course-wise Enrollment',
              style: AppTextStyles.h2.copyWith(color: AppColors.primaryNavy)),
          const SizedBox(height: 4),
          Text('Real-time capacity tracking across departments',
              style: AppTextStyles.caption),
          const SizedBox(height: 12),
          _buildFilterChips(),
          const SizedBox(height: 12),
          ..._kEnrollments.map((e) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _EnrollmentCard(course: e),
              )),
          _buildAddCourseCard(),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildActivePeriodCard() {
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
          Text('ACTIVE PERIOD',
              style: AppTextStyles.label.copyWith(fontSize: 9)),
          const SizedBox(height: 4),
          Text('Fall Semester 2023-2024', style: AppTextStyles.h3),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 36,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: AppColors.bgPage,
                    borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _semester,
                      isExpanded: true,
                      items: ['Current Semester', 'Spring 2024', 'Fall 2023']
                          .map((e) => DropdownMenuItem(
                              value: e, child: Text(e, style: AppTextStyles.caption)))
                          .toList(),
                      onChanged: (v) => setState(() => _semester = v!),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.calendar_today_outlined,
                    size: 14, color: Colors.white),
                label: Text('Manage',
                    style: AppTextStyles.button.copyWith(fontSize: 13)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryNavy,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.buttonRadius)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBulkEnrollmentCard() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.upload_file_outlined,
                color: AppColors.primaryBlue, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Bulk Enrollment', style: AppTextStyles.bodyMedium),
                Text('Upload CSV student data', style: AppTextStyles.caption),
              ],
            ),
          ),
          Container(
            width: 32, height: 32,
            decoration: BoxDecoration(
              color: AppColors.bgPage,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.border),
            ),
            child: const Icon(Icons.add, size: 16, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    final filters = ['All Courses', 'Under-capacity', 'Waitlisted'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((f) {
          final isSelected = f == _filter;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => setState(() => _filter = f),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primaryNavy : Colors.white,
                  borderRadius: BorderRadius.circular(AppSpacing.chipRadius),
                  border: Border.all(
                    color: isSelected ? AppColors.primaryNavy : AppColors.border,
                  ),
                ),
                child: Text(f,
                    style: AppTextStyles.caption.copyWith(
                        color: isSelected ? Colors.white : AppColors.textSecondary,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal)),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildAddCourseCard() {
    return GestureDetector(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.cardPadding),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          border: Border.all(color: AppColors.border, style: BorderStyle.solid),
        ),
        child: Column(
          children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.border),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.add, color: AppColors.textSecondary, size: 20),
            ),
            const SizedBox(height: 8),
            Text('Add New Course', style: AppTextStyles.bodyMedium),
            Text('Initialize a new course for this semester',
                style: AppTextStyles.caption),
          ],
        ),
      ),
    );
  }
}

class _EnrollmentCard extends StatelessWidget {
  const _EnrollmentCard({required this.course});
  final dynamic course;

  @override
  Widget build(BuildContext context) {
    final pct = course.pct as double;
    final isFullCapacity = pct >= 1.0;
    final pctLabel = '${(pct * 100).toInt()}% Full';

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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: (course.barColor as Color).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppSpacing.tagRadius),
                ),
                child: Text(course.id as String,
                    style: AppTextStyles.label.copyWith(
                        color: course.barColor as Color, letterSpacing: 0.5)),
              ),
              Text(course.section as String, style: AppTextStyles.caption),
            ],
          ),
          const SizedBox(height: 8),
          Text(course.title as String, style: AppTextStyles.bodyMedium),
          const SizedBox(height: 2),
          Text(course.teacher as String, style: AppTextStyles.caption),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${course.enrolled} / ${course.capacity} students',
                style: AppTextStyles.bodySemiBold.copyWith(
                  color: isFullCapacity ? AppColors.statusRed : AppColors.textPrimary,
                ),
              ),
              Text(pctLabel,
                  style: AppTextStyles.caption.copyWith(
                      color: course.barColor as Color,
                      fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: pct,
              minHeight: 8,
              backgroundColor: AppColors.border,
              valueColor: AlwaysStoppedAnimation<Color>(course.barColor as Color),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.people_outline, size: 14),
                  label: const Text('View Students'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primaryNavy,
                    side: const BorderSide(color: AppColors.border),
                    textStyle: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w600),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.more_vert,
                    size: 16, color: AppColors.textSecondary),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
