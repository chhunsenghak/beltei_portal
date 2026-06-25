import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';

final _kSemesters = [
  (
    name: 'Semester 1, 2023-2024',
    status: 'ACTIVE',
    startDate: 'Oct 15, 2023',
    endDate: 'Mar 20, 2024',
    registrationOpen: true,
    icon: Icons.calendar_today_outlined,
    iconColor: AppColors.primaryNavy,
    iconBg: AppColors.statusBlueBg,
  ),
  (
    name: 'Semester 2, 2023-2024',
    status: 'UPCOMING',
    startDate: 'Apr 01, 2024',
    endDate: 'Aug 30, 2024',
    registrationOpen: false,
    icon: Icons.access_time_outlined,
    iconColor: AppColors.statusAmber,
    iconBg: AppColors.statusAmberBg,
  ),
  (
    name: 'Semester 2, 2022-2023',
    status: 'CLOSED',
    startDate: 'Mar 15, 2023',
    endDate: 'Aug 20, 2023',
    registrationOpen: false,
    icon: Icons.history_outlined,
    iconColor: AppColors.statusGray,
    iconBg: AppColors.statusGrayBg,
  ),
  (
    name: 'Semester 1, 2022-2023',
    status: 'CLOSED',
    startDate: 'Oct 01, 2022',
    endDate: 'Feb 28, 2023',
    registrationOpen: false,
    icon: Icons.history_outlined,
    iconColor: AppColors.statusGray,
    iconBg: AppColors.statusGrayBg,
  ),
];

class SemesterManagementScreen extends StatefulWidget {
  const SemesterManagementScreen({super.key});

  @override
  State<SemesterManagementScreen> createState() =>
      _SemesterManagementScreenState();
}

class _SemesterManagementScreenState extends State<SemesterManagementScreen> {
  late final List<bool> _registrationStates;

  @override
  void initState() {
    super.initState();
    _registrationStates = _kSemesters.map((s) => s.registrationOpen).toList();
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
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        children: [
          Text('Semester Management',
              style: AppTextStyles.h1.copyWith(color: AppColors.primaryNavy)),
          const SizedBox(height: 4),
          Text('Configure and monitor academic periods and registration windows.',
              style: AppTextStyles.caption),
          const SizedBox(height: 20),
          ...List.generate(_kSemesters.length, (i) {
            final s = _kSemesters[i];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _SemesterCard(
                semester: s,
                registrationOpen: _registrationStates[i],
                onRegistrationToggle: (val) =>
                    setState(() => _registrationStates[i] = val),
              ),
            );
          }),
          const SizedBox(height: 16),
          _buildCurrentFocusCard(),
          const SizedBox(height: 12),
          _buildRegistrationAnalyticsCard(),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildCurrentFocusCard() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.primaryNavy,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('CURRENT FOCUS',
              style: AppTextStyles.label.copyWith(
                  color: Colors.white.withValues(alpha: 0.7), letterSpacing: 1)),
          const SizedBox(height: 4),
          Text('Grading Phase',
              style: AppTextStyles.h2.copyWith(color: Colors.white)),
          const SizedBox(height: 8),
          Text('Ends in 12 days',
              style: AppTextStyles.captionWhite),
        ],
      ),
    );
  }

  Widget _buildRegistrationAnalyticsCard() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Registration Analytics', style: AppTextStyles.h3),
                const SizedBox(height: 4),
                Text('85% of target capacity reached for Semester 2.',
                    style: AppTextStyles.caption),
              ],
            ),
          ),
          SizedBox(
            width: 44, height: 44,
            child: CircularProgressIndicator(
              value: 0.85,
              strokeWidth: 5,
              backgroundColor: AppColors.border,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryBlue),
            ),
          ),
        ],
      ),
    );
  }
}

class _SemesterCard extends StatelessWidget {
  const _SemesterCard({
    required this.semester,
    required this.registrationOpen,
    required this.onRegistrationToggle,
  });

  final dynamic semester;
  final bool registrationOpen;
  final ValueChanged<bool> onRegistrationToggle;

  Color get _statusColor {
    switch (semester.status as String) {
      case 'ACTIVE':    return AppColors.primaryBlue;
      case 'UPCOMING':  return AppColors.statusAmber;
      default:          return AppColors.statusGray;
    }
  }

  Color get _statusBg {
    switch (semester.status as String) {
      case 'ACTIVE':    return AppColors.statusBlueBg;
      case 'UPCOMING':  return AppColors.statusAmberBg;
      default:          return AppColors.statusGrayBg;
    }
  }

  bool get _isClosed => semester.status == 'CLOSED';

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: _isClosed ? 0.7 : 1.0,
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
                    color: (semester.iconBg as Color),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(semester.icon as IconData,
                      color: semester.iconColor as Color, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(semester.name as String, style: AppTextStyles.bodyMedium),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(Icons.calendar_month_outlined,
                              size: 12, color: AppColors.textSecondary),
                          const SizedBox(width: 4),
                          Text(
                            '${semester.startDate} — ${semester.endDate}',
                            style: AppTextStyles.caption.copyWith(fontSize: 11),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: _statusBg,
                    borderRadius: BorderRadius.circular(AppSpacing.tagRadius),
                  ),
                  child: Text(semester.status as String,
                      style: AppTextStyles.label.copyWith(
                          color: _statusColor, fontSize: 9, letterSpacing: 0.5)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1, color: AppColors.divider),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text('Registration',
                        style: AppTextStyles.caption.copyWith(
                            color: _isClosed ? AppColors.textLabel : AppColors.textSecondary)),
                    const SizedBox(width: 8),
                    Switch(
                      value: registrationOpen,
                      onChanged: _isClosed ? null : onRegistrationToggle,
                      activeThumbColor: AppColors.primaryBlue,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () {},
                  child: const Icon(Icons.more_vert,
                      size: 18, color: AppColors.textSecondary),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
