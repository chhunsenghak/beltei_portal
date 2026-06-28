import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/providers/admin_providers.dart';
import '../../../core/services/admin_service.dart';

class AttendanceManagementScreen extends ConsumerStatefulWidget {
  const AttendanceManagementScreen({super.key});

  @override
  ConsumerState<AttendanceManagementScreen> createState() =>
      _AttendanceManagementScreenState();
}

class _AttendanceManagementScreenState
    extends ConsumerState<AttendanceManagementScreen> {
  bool _bulkEditMode = false;
  final Set<int> _selected = {};
  String _studentQuery = '';

  List<AdminAttendanceRecord> _applyFilter(List<AdminAttendanceRecord> records) {
    if (_studentQuery.trim().isEmpty) return records;
    final q = _studentQuery.toLowerCase();
    return records
        .where((r) =>
            r.studentName.toLowerCase().contains(q) ||
            r.studentCode.toLowerCase().contains(q))
        .toList();
  }

  Color _statusColor(String s) {
    switch (s) {
      case 'present': return AppColors.statusGreen;
      case 'absent':  return AppColors.statusRed;
      case 'late':    return AppColors.statusAmber;
      default:        return AppColors.statusGray;
    }
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(adminAttendanceProvider);

    return Scaffold(
      backgroundColor: AppColors.bgPage,
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: AppColors.statusRed, size: 40),
              const SizedBox(height: 8),
              Text('Could not load attendance data', style: AppTextStyles.body),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => ref.invalidate(adminAttendanceProvider),
                child: Text('Retry', style: AppTextStyles.link),
              ),
            ],
          ),
        ),
        data: (allRecords) {
          final records = _applyFilter(allRecords);
          return Column(
            children: [
              _buildHeader(),
              _buildFilterPanel(),
              Expanded(child: _buildRecordTable(records)),
              if (_bulkEditMode && _selected.isNotEmpty) _buildBulkActionBar(records.length),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Attendance',
              style: AppTextStyles.h1.copyWith(color: AppColors.primaryNavy)),
          Text('Management',
              style: AppTextStyles.h1.copyWith(color: AppColors.primaryNavy)),
          const SizedBox(height: 4),
          Text('Review and manage daily attendance across all campuses.',
              style: AppTextStyles.caption),
          const SizedBox(height: 12),
          Row(
            children: [
              Row(
                children: [
                  Text('Bulk Edit',
                      style: AppTextStyles.caption
                          .copyWith(fontWeight: FontWeight.w500)),
                  const SizedBox(width: 8),
                  Switch(
                    value: _bulkEditMode,
                    onChanged: (v) => setState(() {
                      _bulkEditMode = v;
                      if (!v) _selected.clear();
                    }),
                    activeThumbColor: AppColors.primaryBlue,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ],
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.download_outlined,
                    size: 14, color: Colors.white),
                label: Text('Export CSV',
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

  Widget _buildFilterPanel() {
    return Container(
      margin: const EdgeInsets.all(AppSpacing.screenPadding),
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Student',
              style: AppTextStyles.caption
                  .copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: 4),
          TextField(
            onChanged: (v) => setState(() => _studentQuery = v),
            decoration: InputDecoration(
              hintText: 'ID or Name',
              hintStyle: AppTextStyles.caption,
              prefixIcon: const Icon(Icons.search,
                  size: 16, color: AppColors.textSecondary),
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
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () => setState(() {}),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 46),
              backgroundColor: AppColors.primaryBlue,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.buttonRadius)),
            ),
            child: Text('Apply Filters', style: AppTextStyles.button),
          ),
        ],
      ),
    );
  }

  Widget _buildRecordTable(List<AdminAttendanceRecord> records) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          _buildTableHeader(),
          Expanded(
            child: records.isEmpty
                ? Center(
                    child: Text('No attendance records found',
                        style: AppTextStyles.caption))
                : ListView.builder(
                    itemCount: records.length,
                    itemBuilder: (context, i) => _buildTableRow(i, records[i]),
                  ),
          ),
          _buildPagination(records.length),
        ],
      ),
    );
  }

  Widget _buildTableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.divider)),
      ),
      child: Row(
        children: [
          if (_bulkEditMode) const SizedBox(width: 28),
          Expanded(
              flex: 3,
              child: Text('STUDENT',
                  style: AppTextStyles.label.copyWith(fontSize: 9))),
          Expanded(
              flex: 3,
              child: Text('COURSE',
                  style: AppTextStyles.label.copyWith(fontSize: 9))),
          Expanded(
              flex: 2,
              child:
                  Text('DATE', style: AppTextStyles.label.copyWith(fontSize: 9))),
          Text('ST', style: AppTextStyles.label.copyWith(fontSize: 9)),
        ],
      ),
    );
  }

  Widget _buildTableRow(int i, AdminAttendanceRecord r) {
    final isSelected = _selected.contains(i);
    final statusColor = _statusColor(r.status);

    return GestureDetector(
      onTap: _bulkEditMode
          ? () => setState(() {
                if (isSelected) {
                  _selected.remove(i);
                } else {
                  _selected.add(i);
                }
              })
          : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        color: isSelected
            ? AppColors.primaryNavy.withValues(alpha: 0.05)
            : Colors.transparent,
        child: Row(
          children: [
            if (_bulkEditMode)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Checkbox(
                  value: isSelected,
                  onChanged: (_) => setState(() {
                    if (isSelected) {
                      _selected.remove(i);
                    } else {
                      _selected.add(i);
                    }
                  }),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  activeColor: AppColors.primaryNavy,
                ),
              ),
            Expanded(
              flex: 3,
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 14,
                    backgroundColor:
                        AppColors.primaryNavy.withValues(alpha: 0.1),
                    child: Text(r.initials,
                        style: AppTextStyles.label.copyWith(
                            color: AppColors.primaryNavy, fontSize: 9)),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(r.studentName,
                            style: AppTextStyles.caption
                                .copyWith(fontWeight: FontWeight.w600),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                        Text('ID: ${r.studentCode}',
                            style: AppTextStyles.label
                                .copyWith(fontSize: 8, letterSpacing: 0)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 3,
              child: Text(r.courseName,
                  style: AppTextStyles.caption.copyWith(fontSize: 11),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis),
            ),
            Expanded(
              flex: 2,
              child: Text(r.fmtDate,
                  style: AppTextStyles.caption.copyWith(fontSize: 10)),
            ),
            Container(
              width: 22, height: 22,
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(r.statusCode,
                    style: AppTextStyles.label
                        .copyWith(color: statusColor, fontSize: 9)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPagination(int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.divider)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Showing $count record${count == 1 ? '' : 's'}',
              style: AppTextStyles.caption.copyWith(fontSize: 11)),
          Row(
            children: [
              _PageBtn(icon: Icons.chevron_left, onTap: () {}),
              const SizedBox(width: 6),
              _PageBtn(icon: Icons.chevron_right, onTap: () {}),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBulkActionBar(int total) {
    return Container(
      height: 60,
      color: AppColors.primaryNavy,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Text('${_selected.length} items selected',
              style: AppTextStyles.captionWhite),
          const Spacer(),
          _BulkBtn(label: 'Mark Present', color: AppColors.statusGreen, onTap: () {}),
          const SizedBox(width: 8),
          _BulkBtn(label: 'Mark Absent', color: AppColors.statusAmber, onTap: () {}),
          const SizedBox(width: 8),
          _BulkBtn(label: 'Delete Records', color: AppColors.statusRed, onTap: () {}),
        ],
      ),
    );
  }
}

class _PageBtn extends StatelessWidget {
  const _PageBtn({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28, height: 28,
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(icon, size: 16, color: AppColors.textSecondary),
      ),
    );
  }
}

class _BulkBtn extends StatelessWidget {
  const _BulkBtn({required this.label, required this.color, required this.onTap});
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
        ),
        child: Text(label,
            style: AppTextStyles.label.copyWith(
                color: Colors.white, letterSpacing: 0.3, fontSize: 10)),
      ),
    );
  }
}
