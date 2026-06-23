import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../shared/widgets/beltei_app_bar.dart';

// ── Mock data ──────────────────────────────────────────────────────────────────

const _kCourses = [
  'Advanced Mathematics (MA102)',
  'Introduction to Computer Science (CS101)',
  'Data Structures & Algorithms (CS301)',
];

class _RankEntry {
  const _RankEntry({required this.name, required this.score});
  final String name;
  final int score;
}

const _kRanking = [
  _RankEntry(name: 'Sokha Phirum',  score: 98),
  _RankEntry(name: 'Vicheka S.',    score: 92),
  _RankEntry(name: 'Channavy Lim',  score: 85),
  _RankEntry(name: 'Rithy Panh',    score: 78),
  _RankEntry(name: 'Srey Roth',     score: 65),
];

class _AtRiskStudent {
  const _AtRiskStudent({required this.name, required this.attendance, required this.grade});
  final String name, grade;
  final int attendance;
}

const _kAtRisk = [
  _AtRiskStudent(name: 'Vannak Som',   attendance: 62, grade: 'F'),
  _AtRiskStudent(name: 'Dararith Keo', attendance: 74, grade: 'D'),
  _AtRiskStudent(name: 'Bory Chon',    attendance: 71, grade: 'D-'),
];

final _kAttendanceTrend = [
  FlSpot(0, 72), FlSpot(1, 75), FlSpot(2, 78), FlSpot(3, 80),
  FlSpot(4, 82), FlSpot(5, 88), FlSpot(6, 91),
];

const _kMonths = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul'];

// ── Screen ────────────────────────────────────────────────────────────────────

class TeacherStudentAnalyticsScreen extends StatefulWidget {
  const TeacherStudentAnalyticsScreen({super.key});

  @override
  State<TeacherStudentAnalyticsScreen> createState() =>
      _TeacherStudentAnalyticsScreenState();
}

class _TeacherStudentAnalyticsScreenState
    extends State<TeacherStudentAnalyticsScreen> {
  String _selectedCourse = _kCourses[0];

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
            _buildCourseDropdown(),
            const SizedBox(height: AppSpacing.sectionGap),
            _buildPerformanceRanking(),
            const SizedBox(height: AppSpacing.sectionGap),
            _buildGradeDistribution(),
            const SizedBox(height: AppSpacing.sectionGap),
            _buildAttendanceTrend(),
            const SizedBox(height: AppSpacing.sectionGap),
            _buildAtRiskSection(),
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
        Text('Student Analytics', style: AppTextStyles.h1),
        Text('Performance overview for Academic Year 2023-2024',
            style: AppTextStyles.caption),
      ],
    );
  }

  // ── Course dropdown ────────────────────────────────────────────────────────

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
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Expanded(
                child: Text(_selectedCourse,
                    style: AppTextStyles.body,
                    overflow: TextOverflow.ellipsis)),
            const Icon(Icons.keyboard_arrow_down, color: AppColors.textLabel),
          ],
        ),
      ),
    );
  }

  // ── Performance ranking ────────────────────────────────────────────────────

  Widget _buildPerformanceRanking() {
    return _Card(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Student Performance\nRanking',
                  style: AppTextStyles.h2.copyWith(height: 1.3)),
              TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.arrow_forward, size: 14),
                label: Text('View Full\nList',
                    style: AppTextStyles.link.copyWith(fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ..._kRanking.map((r) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    SizedBox(
                        width: 100,
                        child: Text(r.name,
                            style: AppTextStyles.body,
                            overflow: TextOverflow.ellipsis)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: r.score / 100,
                          minHeight: 10,
                          backgroundColor: AppColors.border,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                              AppColors.primaryNavy),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 30,
                      child: Text('${r.score}',
                          style: AppTextStyles.bodyMedium
                              .copyWith(color: AppColors.primaryNavy),
                          textAlign: TextAlign.right),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  // ── Grade distribution ─────────────────────────────────────────────────────

  Widget _buildGradeDistribution() {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Grade Distribution', style: AppTextStyles.h2),
          const SizedBox(height: 16),
          SizedBox(
            height: 180,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 50,
                sections: [
                  PieChartSectionData(
                    value: 40,
                    color: AppColors.primaryNavy,
                    radius: 40,
                    showTitle: false,
                  ),
                  PieChartSectionData(
                    value: 30,
                    color: const Color(0xFF67C8F5),
                    radius: 38,
                    showTitle: false,
                  ),
                  PieChartSectionData(
                    value: 15,
                    color: AppColors.statusAmber,
                    radius: 34,
                    showTitle: false,
                  ),
                  PieChartSectionData(
                    value: 10,
                    color: AppColors.statusRed,
                    radius: 32,
                    showTitle: false,
                  ),
                  PieChartSectionData(
                    value: 5,
                    color: AppColors.statusGray,
                    radius: 28,
                    showTitle: false,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: [
              _LegendDot(AppColors.primaryNavy, 'Grade A (40%)'),
              _LegendDot(const Color(0xFF67C8F5), 'Grade B (30%)'),
              _LegendDot(AppColors.statusAmber, 'Grade C (15%)'),
              _LegendDot(AppColors.statusRed, 'Grade D (10%)'),
            ],
          ),
        ],
      ),
    );
  }

  // ── Attendance trend ───────────────────────────────────────────────────────

  Widget _buildAttendanceTrend() {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Attendance Trends', style: AppTextStyles.h2),
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.primaryBlue,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text('Average %', style: AppTextStyles.caption),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 150,
            child: LineChart(LineChartData(
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                getDrawingHorizontalLine: (_) =>
                    const FlLine(color: AppColors.border, strokeWidth: 1),
              ),
              titlesData: FlTitlesData(
                leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false)),
                topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (v, _) {
                      final i = v.toInt();
                      if (i < 0 || i >= _kMonths.length) {
                        return const SizedBox.shrink();
                      }
                      return Text(_kMonths[i],
                          style: AppTextStyles.caption
                              .copyWith(fontSize: 10));
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(show: false),
              lineBarsData: [
                LineChartBarData(
                  spots: _kAttendanceTrend,
                  isCurved: true,
                  color: AppColors.primaryBlue,
                  barWidth: 2.5,
                  dotData: const FlDotData(show: false),
                  belowBarData: BarAreaData(
                    show: true,
                    color: AppColors.primaryBlue.withValues(alpha: 0.08),
                  ),
                ),
              ],
            )),
          ),
        ],
      ),
    );
  }

  // ── At-risk students ───────────────────────────────────────────────────────

  Widget _buildAtRiskSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.warning_amber_rounded,
                color: AppColors.statusRed, size: 20),
            const SizedBox(width: 6),
            Text('At-Risk Students',
                style: AppTextStyles.h2
                    .copyWith(color: AppColors.statusRed)),
          ],
        ),
        const SizedBox(height: 12),
        ..._kAtRisk.map((s) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _AtRiskCard(student: s),
            )),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.send_outlined, size: 16,
                color: AppColors.statusRed),
            label: Text('Send Alert to Guardians',
                style: AppTextStyles.button
                    .copyWith(color: AppColors.statusRed)),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.statusRed),
            ),
          ),
        ),
      ],
    );
  }
}

// ── At-risk card ───────────────────────────────────────────────────────────────

class _AtRiskCard extends StatelessWidget {
  const _AtRiskCard({required this.student});
  final _AtRiskStudent student;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: AppColors.statusRedBg,
            child: Text(student.name[0],
                style: AppTextStyles.h3
                    .copyWith(color: AppColors.statusRed)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(student.name, style: AppTextStyles.bodyMedium),
                Text('Attendance: ${student.attendance}%',
                    style: AppTextStyles.caption.copyWith(
                        color: AppColors.statusRed)),
              ],
            ),
          ),
          Text(student.grade,
              style: AppTextStyles.metric.copyWith(
                  color: AppColors.statusRed, fontSize: 22)),
          const SizedBox(width: 8),
          const Icon(Icons.flag, color: AppColors.statusRed, size: 18),
        ],
      ),
    );
  }
}

// ── Helpers ────────────────────────────────────────────────────────────────────

class _Card extends StatelessWidget {
  const _Card({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(color: AppColors.border),
      ),
      child: child,
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot(this.color, this.label);
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label, style: AppTextStyles.caption),
      ],
    );
  }
}
