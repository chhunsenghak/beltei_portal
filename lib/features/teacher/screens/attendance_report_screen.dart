import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../shared/widgets/beltei_app_bar.dart';

// ── Mock data ──────────────────────────────────────────────────────────────────

const _kCourses = [
  'Advanced Web Development (WD-401)',
  'Introduction to Computer Science (CS101)',
  'Data Structures & Algorithms (CS301)',
];

class _StudentRecord {
  const _StudentRecord({required this.name, required this.present, required this.absent});
  final String name;
  final int present, absent;
}

const _kRecords = [
  _StudentRecord(name: 'Liam Henderson',  present: 22, absent: 1),
  _StudentRecord(name: 'Sophia Martinez', present: 16, absent: 4),
  _StudentRecord(name: 'Ethan Wright',    present: 20, absent: 2),
  _StudentRecord(name: 'Ava Thompson',    present: 13, absent: 9),
  _StudentRecord(name: 'Isabella Garcia', present: 14, absent: 6),
];

// ── Screen ────────────────────────────────────────────────────────────────────

class AttendanceReportScreen extends StatefulWidget {
  const AttendanceReportScreen({super.key, required this.courseId});
  final String courseId;

  @override
  State<AttendanceReportScreen> createState() => _AttendanceReportScreenState();
}

class _AttendanceReportScreenState extends State<AttendanceReportScreen> {
  String _selectedCourse = _kCourses[0];
  final _fromController = TextEditingController(text: '09/01/2023');
  final _toController   = TextEditingController(text: '12/15/2023');

  @override
  void dispose() {
    _fromController.dispose();
    _toController.dispose();
    super.dispose();
  }

  void _apply() {
    FocusScope.of(context).unfocus();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Filter applied.',
            style: AppTextStyles.body.copyWith(color: Colors.white)),
        backgroundColor: AppColors.primaryNavy,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      appBar: BelteiAppBar(showNotification: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTitle(),
            const SizedBox(height: AppSpacing.md),
            _buildExportButton(),
            const SizedBox(height: AppSpacing.sectionGap),
            _buildFilterCard(),
            const SizedBox(height: AppSpacing.sectionGap),
            _buildStatCards(),
            const SizedBox(height: AppSpacing.sectionGap),
            _buildStudentRecords(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // ── Title ──────────────────────────────────────────────────────────────────

  Widget _buildTitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Attendance Report', style: AppTextStyles.h1),
        Text('Analyze student participation and attendance patterns for the current semester.',
            style: AppTextStyles.caption.copyWith(height: 1.4)),
      ],
    );
  }

  // ── Export button ──────────────────────────────────────────────────────────

  Widget _buildExportButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {},
        icon: const Icon(Icons.download_outlined, size: 18),
        label: Text('Export Report', style: AppTextStyles.button),
      ),
    );
  }

  // ── Filter card ────────────────────────────────────────────────────────────

  Widget _buildFilterCard() {
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
          Text('SELECT COURSE', style: AppTextStyles.label),
          const SizedBox(height: 8),
          _buildCourseDropdown(),
          const SizedBox(height: 16),
          Text('DATE RANGE FILTER', style: AppTextStyles.label),
          const SizedBox(height: 8),
          TextField(
              controller: _fromController,
              decoration: const InputDecoration(
                hintText: 'mm/dd/yyyy',
              )),
          const SizedBox(height: 8),
          Text('to', style: AppTextStyles.body.copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: 8),
          TextField(
              controller: _toController,
              decoration: const InputDecoration(
                hintText: 'mm/dd/yyyy',
              )),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _apply,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: Text('Apply', style: AppTextStyles.button),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCourseDropdown() {
    return GestureDetector(
      onTap: () => showModalBottomSheet(
        context: context,
        backgroundColor: AppColors.bgCard,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        builder: (_) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            ..._kCourses.map((c) => ListTile(
                  title: Text(c, style: AppTextStyles.body),
                  trailing: c == _selectedCourse
                      ? const Icon(Icons.check, color: AppColors.primaryNavy)
                      : null,
                  onTap: () {
                    setState(() => _selectedCourse = c);
                    Navigator.pop(context);
                  },
                )),
            const SizedBox(height: 16),
          ],
        ),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.bgPage,
          borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(_selectedCourse,
                  style: AppTextStyles.body,
                  overflow: TextOverflow.ellipsis),
            ),
            const Icon(Icons.keyboard_arrow_down,
                color: AppColors.textLabel),
          ],
        ),
      ),
    );
  }

  // ── Stat cards ─────────────────────────────────────────────────────────────

  Widget _buildStatCards() {
    return Column(
      children: [
        _AccentCard(
          accentColor: AppColors.primaryNavy,
          label: 'TOTAL CLASSES',
          value: '24 Sessions',
          subLabel: 'Semestral Total',
          subIcon: Icons.calendar_today_outlined,
        ),
        const SizedBox(height: 10),
        _AccentCard(
          accentColor: AppColors.statusGreen,
          label: 'PRESENT AVG',
          value: '92%',
          progress: 0.92,
          progressColor: AppColors.statusGreen,
        ),
        const SizedBox(height: 10),
        _AccentCard(
          accentColor: AppColors.statusRed,
          label: 'ABSENT AVG',
          value: '5%',
          progress: 0.05,
          progressColor: AppColors.statusRed,
        ),
      ],
    );
  }

  // ── Student records table ──────────────────────────────────────────────────

  Widget _buildStudentRecords() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Student Records', style: AppTextStyles.h2),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: AppColors.bgCard,
            borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: [
              _buildTableHeader(),
              const Divider(height: 1, color: AppColors.border),
              ..._kRecords.asMap().entries.map((e) => Column(
                    children: [
                      _buildRecordRow(e.value),
                      if (e.key < _kRecords.length - 1)
                        const Divider(height: 1, color: AppColors.divider),
                    ],
                  )),
              const Divider(height: 1, color: AppColors.border),
              _buildPagination(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTableHeader() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          const Expanded(
              flex: 3,
              child: Text('STUDENT\nNAME',
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textLabel,
                      letterSpacing: 0.5))),
          ...[
            'PRESENT',
            'ABSENT'
          ].map((h) => Expanded(
                child: Text(h,
                    style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textLabel,
                        letterSpacing: 0.5),
                    textAlign: TextAlign.center),
              )),
        ],
      ),
    );
  }

  Widget _buildRecordRow(_StudentRecord r) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: AppColors.primaryNavy.withValues(alpha: 0.1),
                  child: Text(r.name[0],
                      style: AppTextStyles.caption.copyWith(
                          color: AppColors.primaryNavy,
                          fontWeight: FontWeight.w700)),
                ),
                const SizedBox(width: 8),
                Expanded(
                    child: Text(r.name,
                        style: AppTextStyles.body,
                        overflow: TextOverflow.ellipsis)),
              ],
            ),
          ),
          Expanded(
            child: Text('${r.present}',
                style: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.statusGreen),
                textAlign: TextAlign.center),
          ),
          Expanded(
            child: Text('${r.absent}',
                style: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.statusRed),
                textAlign: TextAlign.center),
          ),
        ],
      ),
    );
  }

  Widget _buildPagination() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Text('Showing 5 of 32 students',
              style: AppTextStyles.caption),
          const Spacer(),
          _PageBtn(Icons.chevron_left, enabled: false, onTap: () {}),
          _PageBtn(null, label: '1', active: true, onTap: () {}),
          _PageBtn(null, label: '2', onTap: () {}),
          _PageBtn(Icons.chevron_right, onTap: () {}),
        ],
      ),
    );
  }
}

// ── Accent stat card ───────────────────────────────────────────────────────────

class _AccentCard extends StatelessWidget {
  const _AccentCard({
    required this.accentColor,
    required this.label,
    required this.value,
    this.subLabel,
    this.subIcon,
    this.progress,
    this.progressColor,
  });

  final Color accentColor;
  final String label, value;
  final String? subLabel;
  final IconData? subIcon;
  final double? progress;
  final Color? progressColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(color: AppColors.border),
        // ignore: prefer_const_constructors
        boxShadow: const [],
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 50,
            decoration: BoxDecoration(
              color: accentColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTextStyles.label),
                const SizedBox(height: 4),
                Text(value,
                    style: AppTextStyles.metric
                        .copyWith(color: accentColor, fontSize: 24)),
                if (subLabel != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (subIcon != null)
                        Icon(subIcon!, size: 12, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Text(subLabel!, style: AppTextStyles.caption),
                    ],
                  ),
                ],
                if (progress != null) ...[
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 6,
                      backgroundColor: AppColors.border,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(progressColor!),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Pagination button ──────────────────────────────────────────────────────────

class _PageBtn extends StatelessWidget {
  const _PageBtn(this.icon, {this.label, this.active = false, this.enabled = true, required this.onTap});
  final IconData? icon;
  final String? label;
  final bool active, enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        margin: const EdgeInsets.only(left: 4),
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: active ? AppColors.primaryNavy : AppColors.bgPage,
          shape: BoxShape.circle,
          border: Border.all(
              color: active ? AppColors.primaryNavy : AppColors.border),
        ),
        child: Center(
          child: icon != null
              ? Icon(icon, size: 16,
                  color: enabled ? AppColors.textPrimary : AppColors.textLabel)
              : Text(label!,
                  style: AppTextStyles.caption.copyWith(
                      color: active ? Colors.white : AppColors.textPrimary,
                      fontWeight: FontWeight.w600)),
        ),
      ),
    );
  }
}
