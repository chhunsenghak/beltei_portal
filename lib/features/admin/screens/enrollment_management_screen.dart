import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/providers/admin_providers.dart';
import '../../../core/services/admin_service.dart';

class EnrollmentManagementScreen extends ConsumerStatefulWidget {
  const EnrollmentManagementScreen({super.key});

  @override
  ConsumerState<EnrollmentManagementScreen> createState() =>
      _EnrollmentManagementScreenState();
}

class _EnrollmentManagementScreenState
    extends ConsumerState<EnrollmentManagementScreen> {
  String _filter = 'All Courses';

  List<AdminEnrollmentRecord> _applyFilter(List<AdminEnrollmentRecord> records) {
    switch (_filter) {
      case 'Under-capacity':
        return records.where((r) => r.pct < 0.5).toList();
      case 'Full / Overloaded':
        return records.where((r) => r.pct >= 0.9).toList();
      default:
        return records;
    }
  }

  Color _barColor(double pct) {
    if (pct >= 1.0) return AppColors.statusRed;
    if (pct >= 0.8) return AppColors.statusAmber;
    if (pct >= 0.5) return AppColors.primaryNavy;
    return AppColors.primaryBlue;
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(adminEnrollmentProvider);

    return Scaffold(
      backgroundColor: AppColors.bgPage,
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: AppColors.primaryBlue,
        child: const Icon(Icons.person_add_outlined, color: Colors.white),
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: AppColors.statusRed, size: 40),
              const SizedBox(height: 8),
              Text('Could not load enrollment data', style: AppTextStyles.body),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => ref.invalidate(adminEnrollmentProvider),
                child: Text('Retry', style: AppTextStyles.link),
              ),
            ],
          ),
        ),
        data: (allRecords) {
          final records = _applyFilter(allRecords);
          return ListView(
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
              if (records.isEmpty)
                Container(
                  padding: const EdgeInsets.all(AppSpacing.cardPadding),
                  decoration: BoxDecoration(
                    color: AppColors.bgCard,
                    borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Center(
                    child: Text('No courses found', style: AppTextStyles.caption),
                  ),
                )
              else
                ...records.map((r) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _EnrollmentCard(record: r, barColor: _barColor(r.pct)),
                    )),
              const SizedBox(height: 80),
            ],
          );
        },
      ),
    );
  }

  Widget _buildActivePeriodCard() {
    final semAsync = ref.watch(adminSemestersProvider);
    final semName = semAsync.valueOrNull
            ?.where((s) => s.isCurrent)
            .map((s) => s.name)
            .firstOrNull ??
        'Current Semester';
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
          Text('ACTIVE PERIOD', style: AppTextStyles.label.copyWith(fontSize: 9)),
          const SizedBox(height: 4),
          Text(semName, style: AppTextStyles.h3),
          const SizedBox(height: 10),
          ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.calendar_today_outlined, size: 14, color: Colors.white),
            label: Text('Manage', style: AppTextStyles.button.copyWith(fontSize: 13)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryNavy,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.buttonRadius)),
            ),
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
    final filters = ['All Courses', 'Under-capacity', 'Full / Overloaded'];
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
}

class _EnrollmentCard extends StatelessWidget {
  const _EnrollmentCard({required this.record, required this.barColor});
  final AdminEnrollmentRecord record;
  final Color barColor;

  @override
  Widget build(BuildContext context) {
    final pct = record.pct;
    final pctLabel = '${(pct * 100).toInt()}% Full';
    final isFullCapacity = pct >= 1.0;

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
                  color: barColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppSpacing.tagRadius),
                ),
                child: Text(record.courseCode,
                    style: AppTextStyles.label
                        .copyWith(color: barColor, letterSpacing: 0.5)),
              ),
              Text('${record.enrolled} enrolled',
                  style: AppTextStyles.caption),
            ],
          ),
          const SizedBox(height: 8),
          Text(record.courseName, style: AppTextStyles.bodyMedium),
          const SizedBox(height: 2),
          Text(record.teacherName ?? 'No teacher assigned',
              style: AppTextStyles.caption),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${record.enrolled} / ${record.maxStudents} students',
                style: AppTextStyles.bodySemiBold.copyWith(
                  color: isFullCapacity
                      ? AppColors.statusRed
                      : AppColors.textPrimary,
                ),
              ),
              Text(pctLabel,
                  style: AppTextStyles.caption.copyWith(
                      color: barColor, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: pct.clamp(0.0, 1.0),
              minHeight: 8,
              backgroundColor: AppColors.border,
              valueColor: AlwaysStoppedAnimation<Color>(barColor),
            ),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.people_outline, size: 14),
            label: const Text('View Students'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 36),
              foregroundColor: AppColors.primaryNavy,
              side: const BorderSide(color: AppColors.border),
              textStyle:
                  AppTextStyles.caption.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
