import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';

final _kRecords = [
  (initials: 'CN', name: 'Chann Nimol',  studentId: '2024-0812', course: 'English Proficiency II',   date: 'Oct 24, 2023', status: 'P'),
  (initials: 'ST', name: 'Sok Thida',    studentId: '2024-0544', course: 'Business Statistics',      date: 'Oct 24, 2023', status: 'A'),
  (initials: 'KR', name: 'Keo Rithy',    studentId: '2024-0992', course: 'Modern Khmer Literature',  date: 'Oct 24, 2023', status: 'L'),
  (initials: 'VP', name: 'Vann Phally',  studentId: '2024-1201', course: 'English Proficiency II',   date: 'Oct 24, 2023', status: 'E'),
  (initials: 'RM', name: 'Ratha Morn',   studentId: '2024-0831', course: 'Business Statistics',      date: 'Oct 24, 2023', status: 'P'),
  (initials: 'SR', name: 'Serey Roth',   studentId: '2024-0663', course: 'Modern Khmer Literature',  date: 'Oct 24, 2023', status: 'P'),
];

class AttendanceManagementScreen extends StatefulWidget {
  const AttendanceManagementScreen({super.key});

  @override
  State<AttendanceManagementScreen> createState() =>
      _AttendanceManagementScreenState();
}

class _AttendanceManagementScreenState
    extends State<AttendanceManagementScreen> {
  bool _bulkEditMode = false;
  final Set<int> _selected = {};
  String _courseFilter = 'All Courses';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      bottomSheet: _bulkEditMode && _selected.isNotEmpty
          ? _buildBulkActionBar()
          : null,
      body: Column(
        children: [
          _buildHeader(),
          _buildFilterPanel(),
          Expanded(child: _buildRecordTable()),
        ],
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
          Text('Attendance', style: AppTextStyles.h1.copyWith(color: AppColors.primaryNavy)),
          Text('Management', style: AppTextStyles.h1.copyWith(color: AppColors.primaryNavy)),
          const SizedBox(height: 4),
          Text('Review and manage daily attendance across all campuses.',
              style: AppTextStyles.caption),
          const SizedBox(height: 12),
          Row(
            children: [
              Row(
                children: [
                  Text('Bulk Edit',
                      style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w500)),
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
          Text('Course', style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: 4),
          Container(
            decoration: BoxDecoration(
              color: AppColors.bgInput,
              borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
              border: Border.all(color: AppColors.border),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _courseFilter,
                isExpanded: true,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                items: ['All Courses', 'English Proficiency II',
                        'Business Statistics', 'Modern Khmer Literature']
                    .map((e) => DropdownMenuItem(
                        value: e, child: Row(children: [
                          const Icon(Icons.school_outlined, size: 14, color: AppColors.textSecondary),
                          const SizedBox(width: 6),
                          Text(e, style: AppTextStyles.body),
                        ])))
                    .toList(),
                onChanged: (v) => setState(() => _courseFilter = v!),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text('Date Range', style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: 4),
          TextField(
            onChanged: (_) {},
            decoration: InputDecoration(
              hintText: 'Select dates',
              hintStyle: AppTextStyles.caption,
              prefixIcon: const Icon(Icons.calendar_month_outlined,
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
          const SizedBox(height: 10),
          Text('Student', style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: 4),
          TextField(
            onChanged: (_) {},
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
            onPressed: () {},
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

  Widget _buildRecordTable() {
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
            child: ListView.builder(
              itemCount: _kRecords.length,
              itemBuilder: (context, i) => _buildTableRow(i),
            ),
          ),
          _buildPagination(),
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
          Expanded(flex: 3, child: Text('STUDENT', style: AppTextStyles.label.copyWith(fontSize: 9))),
          Expanded(flex: 3, child: Text('COURSE', style: AppTextStyles.label.copyWith(fontSize: 9))),
          Expanded(flex: 2, child: Text('DATE', style: AppTextStyles.label.copyWith(fontSize: 9))),
          Text('ST', style: AppTextStyles.label.copyWith(fontSize: 9)),
        ],
      ),
    );
  }

  Widget _buildTableRow(int i) {
    final r = _kRecords[i];
    final isSelected = _selected.contains(i);
    final statusColor = _statusColor(r.status);
    final statusLabel = _statusLabel(r.status);

    return GestureDetector(
      onTap: _bulkEditMode
          ? () => setState(() {
                if (isSelected) { _selected.remove(i); }
                else { _selected.add(i); }
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
                    if (isSelected) { _selected.remove(i); }
                    else { _selected.add(i); }
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
                    backgroundColor: AppColors.primaryNavy.withValues(alpha: 0.1),
                    child: Text(r.initials,
                        style: AppTextStyles.label.copyWith(
                            color: AppColors.primaryNavy, fontSize: 9)),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(r.name,
                            style: AppTextStyles.caption.copyWith(
                                fontWeight: FontWeight.w600),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                        Text('ID: ${r.studentId}',
                            style: AppTextStyles.label.copyWith(
                                fontSize: 8, letterSpacing: 0)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 3,
              child: Text(r.course,
                  style: AppTextStyles.caption.copyWith(fontSize: 11),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis),
            ),
            Expanded(
              flex: 2,
              child: Text(r.date,
                  style: AppTextStyles.caption.copyWith(fontSize: 10)),
            ),
            Container(
              width: 22, height: 22,
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(statusLabel,
                    style: AppTextStyles.label.copyWith(
                        color: statusColor, fontSize: 9)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPagination() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.divider)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Showing 1 to ${_kRecords.length} of 1,248 entries',
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

  Widget _buildBulkActionBar() {
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

  Color _statusColor(String s) {
    switch (s) {
      case 'P': return AppColors.statusGreen;
      case 'A': return AppColors.statusRed;
      case 'L': return AppColors.statusAmber;
      default:  return AppColors.statusGray;
    }
  }

  String _statusLabel(String s) => s;
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
