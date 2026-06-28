import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/providers/admin_providers.dart';
import '../../../core/services/admin_service.dart';

const _kEnrollmentData = [0.55, 0.62, 0.58, 0.72, 0.68, 0.78, 0.85, 0.80, 0.90, 0.88, 0.95, 0.92];
const _kMonths = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

final _kDeptAttendance = [
  (dept: 'Engineering',  pct: 0.92, color: AppColors.primaryNavy),
  (dept: 'Business',     pct: 0.85, color: AppColors.primaryBlue),
  (dept: 'IT',           pct: 0.88, color: Color(0xFF7C3AED)),
  (dept: 'Languages',    pct: 0.79, color: AppColors.statusAmber),
  (dept: 'Law',          pct: 0.76, color: AppColors.statusRed),
];

const _kGradeData = [
  (grade: 'A (90-100%)', count: 320, color: AppColors.statusGreen),
  (grade: 'B (80-89%)',  count: 580, color: AppColors.primaryBlue),
  (grade: 'C (70-79%)',  count: 410, color: AppColors.statusAmber),
  (grade: 'D (60-69%)',  count: 180, color: AppColors.statusRed),
];

class UniversityAnalyticsScreen extends ConsumerStatefulWidget {
  const UniversityAnalyticsScreen({super.key});

  @override
  ConsumerState<UniversityAnalyticsScreen> createState() =>
      _UniversityAnalyticsScreenState();
}

class _UniversityAnalyticsScreenState
    extends ConsumerState<UniversityAnalyticsScreen> {
  String _semester = 'Fall Semester 2023 — 2024';

  @override
  Widget build(BuildContext context) {
    final statsAsync = ref.watch(adminStatsProvider);
    final stats = statsAsync.valueOrNull;
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        children: [
          _buildHeader(),
          const SizedBox(height: 16),
          _buildKpiCards(stats),
          const SizedBox(height: 20),
          _buildEnrollmentTrend(),
          const SizedBox(height: 16),
          _buildGradeDistribution(),
          const SizedBox(height: 16),
          _buildDeptAttendance(),
          const SizedBox(height: 16),
          _buildAtRiskCard(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('University Analytics',
            style: AppTextStyles.h1.copyWith(color: AppColors.primaryNavy)),
        const SizedBox(height: 4),
        Text('Key performance metrics across all departments.',
            style: AppTextStyles.caption),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Container(
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.bgCard,
                  borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
                  border: Border.all(color: AppColors.border),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _semester,
                    isExpanded: true,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    items: [
                      'Fall Semester 2023 — 2024',
                      'Spring Semester 2023 — 2024',
                      'Fall Semester 2022 — 2023',
                    ]
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
              icon: const Icon(Icons.download_outlined, size: 14, color: Colors.white),
              label: Text('Export', style: AppTextStyles.button.copyWith(fontSize: 13)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryNavy,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.buttonRadius)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildKpiCards(AdminStats? stats) {
    final kpis = [
      (label: 'Active Students', value: stats != null ? '${stats.studentCount}' : '—', sub: 'enrolled', color: AppColors.primaryNavy),
      (label: 'Active Courses',  value: stats != null ? '${stats.courseCount}'  : '—', sub: 'this semester', color: AppColors.primaryBlue),
      (label: 'Attendance Rate', value: '94.8%',  sub: 'avg rate', color: AppColors.statusGreen),
      (label: 'Revenue Collected', value: stats?.fmtCollected ?? '—', sub: 'this year', color: AppColors.statusAmber),
    ];
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 1.7,
      children: kpis.map((k) {
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.bgCard,
            borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(k.label,
                  style: AppTextStyles.label.copyWith(fontSize: 9)),
              Text(k.value,
                  style: AppTextStyles.metric.copyWith(
                      color: k.color, fontSize: 20)),
              Text(k.sub,
                  style: AppTextStyles.caption.copyWith(
                      color: AppColors.statusGreen, fontSize: 11)),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildEnrollmentTrend() {
    return _AnalyticsCard(
      title: 'Student Enrollment Trend',
      subtitle: 'Total Enrollment',
      child: SizedBox(
        height: 80,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: List.generate(_kEnrollmentData.length, (i) {
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 1),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      height: _kEnrollmentData[i] * 70,
                      decoration: BoxDecoration(
                        color: AppColors.primaryBlue
                            .withValues(alpha: 0.2 + _kEnrollmentData[i] * 0.5),
                        borderRadius:
                            const BorderRadius.vertical(top: Radius.circular(3)),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(_kMonths[i],
                        style: AppTextStyles.label.copyWith(fontSize: 7)),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildGradeDistribution() {
    final total = _kGradeData.fold<int>(0, (s, g) => s + g.count);
    return _AnalyticsCard(
      title: 'Grade Distribution',
      child: Column(
        children: _kGradeData.map((g) {
          final pct = g.count / total;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                SizedBox(
                  width: 80,
                  child: Text(g.grade,
                      style: AppTextStyles.label.copyWith(fontSize: 9, letterSpacing: 0)),
                ),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: LinearProgressIndicator(
                      value: pct,
                      minHeight: 12,
                      backgroundColor: AppColors.border,
                      valueColor: AlwaysStoppedAnimation<Color>(g.color),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 30,
                  child: Text('${(pct * 100).toInt()}%',
                      style: AppTextStyles.label.copyWith(
                          fontSize: 9, letterSpacing: 0,
                          color: AppColors.textSecondary)),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDeptAttendance() {
    return _AnalyticsCard(
      title: 'Department Attendance (%)',
      child: Column(
        children: _kDeptAttendance.map((d) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                SizedBox(
                    width: 80,
                    child: Text(d.dept,
                        style: AppTextStyles.label.copyWith(fontSize: 9, letterSpacing: 0))),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: LinearProgressIndicator(
                      value: d.pct,
                      minHeight: 10,
                      backgroundColor: AppColors.border,
                      valueColor: AlwaysStoppedAnimation<Color>(d.color),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text('${(d.pct * 100).toInt()}%',
                    style: AppTextStyles.label.copyWith(
                        fontSize: 9, letterSpacing: 0,
                        color: AppColors.textSecondary)),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildAtRiskCard() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.statusRedBg,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(color: AppColors.statusRed.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('At-Risk Students',
                  style: AppTextStyles.h3.copyWith(color: AppColors.statusRed)),
              const SizedBox(height: 4),
              Text('Trend', style: AppTextStyles.caption),
            ],
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.statusRed,
              borderRadius: BorderRadius.circular(AppSpacing.chipRadius),
            ),
            child: Text('42 Students',
                style: AppTextStyles.label.copyWith(
                    color: Colors.white, letterSpacing: 0.3)),
          ),
        ],
      ),
    );
  }
}

class _AnalyticsCard extends StatelessWidget {
  const _AnalyticsCard({required this.title, this.subtitle, required this.child});
  final String title;
  final String? subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
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
              Text(title, style: AppTextStyles.h3),
              if (subtitle != null)
                Text(subtitle!, style: AppTextStyles.caption),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}
