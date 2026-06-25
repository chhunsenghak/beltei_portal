import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';

// ── Mock data ──────────────────────────────────────────────────────────────────

const _kCGPA = '3.84';
const _kCGPADelta = '+0.12 vs last sem';

final _kGpaTrend = [
  FlSpot(1, 3.2),
  FlSpot(2, 3.1),
  FlSpot(3, 3.4),
  FlSpot(4, 3.3),
  FlSpot(5, 3.6),
  FlSpot(6, 3.84),
];

final _kBarData = [0.6, 0.55, 0.65, 0.7, 0.75, 0.82];
const _kBarLabels = ['FALL\n21', 'SPR\n22', 'FALL\n22', 'SPR\n23', 'FALL\n23', 'SPR\n24'];

final _kCourses = [
  (icon: Icons.device_hub_outlined, name: 'Data Structures & Algos', code: 'CS301'),
  (icon: Icons.calculate_outlined, name: 'Discrete Mathematics', code: 'MATH202'),
  (icon: Icons.storage_outlined, name: 'Database Systems', code: 'CS305'),
];

// ── Screen ────────────────────────────────────────────────────────────────────

class AcademicAnalyticsScreen extends StatelessWidget {
  const AcademicAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTitle(),
            const SizedBox(height: AppSpacing.md),
            _buildCGPACard(),
            const SizedBox(height: AppSpacing.sectionGap),
            _buildDegreeProgress(),
            const SizedBox(height: AppSpacing.sectionGap),
            _buildGPATrend(),
            const SizedBox(height: AppSpacing.sectionGap),
            _buildSemesterComparison(),
            const SizedBox(height: AppSpacing.sectionGap),
            _buildCoursePerformance(),
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
        Text('Academic Performance', style: AppTextStyles.h1),
        Text('Insights and progress tracking for Academic Year 2023-24',
            style: AppTextStyles.caption),
      ],
    );
  }

  // ── CGPA card ──────────────────────────────────────────────────────────────

  Widget _buildCGPACard() {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('CURRENT CGPA', style: AppTextStyles.label),
          const SizedBox(height: 6),
          Row(
            children: [
              Text(_kCGPA,
                  style: AppTextStyles.metric.copyWith(
                      color: AppColors.primaryNavy, fontSize: 36)),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.statusGreenBg,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.trending_up, color: AppColors.statusGreen, size: 14),
                    const SizedBox(width: 4),
                    Text(_kCGPADelta,
                        style: AppTextStyles.caption.copyWith(
                            color: AppColors.statusGreen, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 80,
            child: LineChart(_buildMiniChart()),
          ),
        ],
      ),
    );
  }

  LineChartData _buildMiniChart() {
    return LineChartData(
      gridData: const FlGridData(show: false),
      titlesData: const FlTitlesData(show: false),
      borderData: FlBorderData(show: false),
      lineBarsData: [
        LineChartBarData(
          spots: _kGpaTrend,
          isCurved: true,
          color: AppColors.primaryNavy,
          barWidth: 2.5,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            color: AppColors.primaryNavy.withValues(alpha: 0.08),
          ),
        ),
      ],
    );
  }

  // ── Degree progress ────────────────────────────────────────────────────────

  Widget _buildDegreeProgress() {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Degree Progress', style: AppTextStyles.h2),
              Text('78%',
                  style: AppTextStyles.h3.copyWith(color: AppColors.primaryNavy)),
            ],
          ),
          Text('B.Sc. Computer Science & Engineering', style: AppTextStyles.caption),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: const LinearProgressIndicator(
              value: 0.78,
              minHeight: 10,
              backgroundColor: AppColors.border,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.statusAmber),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildProgressStat('Earned', '94 / 120', AppColors.primaryBlue),
              const SizedBox(width: 24),
              _buildProgressStat('Required', '26 Credits', AppColors.textPrimary),
              const SizedBox(width: 24),
              _buildProgressStat('Status', 'On Track', AppColors.statusGreen),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressStat(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.label),
        Text(value,
            style: AppTextStyles.bodySemiBold.copyWith(color: color)),
      ],
    );
  }

  // ── GPA Trend chart ────────────────────────────────────────────────────────

  Widget _buildGPATrend() {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('GPA Trend Analysis', style: AppTextStyles.h2),
              const Spacer(),
              _buildLegendDot(AppColors.primaryNavy, 'Term GPA'),
              const SizedBox(width: 12),
              _buildLegendDot(AppColors.primaryBlue, 'CGPA'),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 160,
            child: LineChart(_buildTrendChart()),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendDot(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(label, style: AppTextStyles.caption),
      ],
    );
  }

  LineChartData _buildTrendChart() {
    final cgpa = _kGpaTrend.map((s) => FlSpot(s.x, s.y - 0.1)).toList();
    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        getDrawingHorizontalLine: (_) =>
            const FlLine(color: AppColors.border, strokeWidth: 1),
      ),
      titlesData: FlTitlesData(
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 36,
            getTitlesWidget: (v, _) =>
                Text(v.toStringAsFixed(1), style: AppTextStyles.caption.copyWith(fontSize: 10)),
          ),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (v, _) {
              final labels = ['Sem1', 'Sem2', 'Sem3', 'Sem4', 'Sem5', 'Sem6'];
              final i = v.toInt() - 1;
              if (i < 0 || i >= labels.length) return const SizedBox.shrink();
              return Text(labels[i],
                  style: AppTextStyles.caption.copyWith(fontSize: 10));
            },
          ),
        ),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      borderData: FlBorderData(show: false),
      lineBarsData: [
        LineChartBarData(
          spots: _kGpaTrend,
          isCurved: true,
          color: AppColors.primaryNavy,
          barWidth: 2.5,
          dotData: const FlDotData(show: false),
        ),
        LineChartBarData(
          spots: cgpa,
          isCurved: true,
          color: AppColors.primaryBlue,
          barWidth: 2,
          dotData: const FlDotData(show: false),
          dashArray: [4, 4],
        ),
      ],
    );
  }

  // ── Semester comparison bar chart ──────────────────────────────────────────

  Widget _buildSemesterComparison() {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Semester Comparison', style: AppTextStyles.h2),
                    Text('Average score distribution per semester',
                        style: AppTextStyles.caption),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.statusGrayBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.filter_list, size: 14, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Text('All Years', style: AppTextStyles.caption),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 140,
            child: BarChart(_buildBarChart()),
          ),
        ],
      ),
    );
  }

  BarChartData _buildBarChart() {
    return BarChartData(
      alignment: BarChartAlignment.spaceAround,
      barTouchData: BarTouchData(enabled: false),
      titlesData: FlTitlesData(
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (v, _) {
              final i = v.toInt();
              if (i < 0 || i >= _kBarLabels.length) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(_kBarLabels[i],
                    textAlign: TextAlign.center,
                    style: AppTextStyles.caption.copyWith(fontSize: 9)),
              );
            },
          ),
        ),
        leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      gridData: const FlGridData(show: false),
      borderData: FlBorderData(show: false),
      barGroups: List.generate(_kBarData.length, (i) => BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: _kBarData[i] * 4,
                color: i == _kBarData.length - 1
                    ? AppColors.primaryNavy
                    : AppColors.primaryNavy.withValues(alpha: 0.3),
                width: 28,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
              ),
            ],
          )),
    );
  }

  // ── Course performance table ───────────────────────────────────────────────

  Widget _buildCoursePerformance() {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Detailed Course Performance', style: AppTextStyles.h2),
          const SizedBox(height: 4),
          Row(
            children: ['COURSE NAME', 'CODE']
                .map((h) => Expanded(child: Text(h, style: AppTextStyles.label)))
                .toList(),
          ),
          const Divider(color: AppColors.border, height: 20),
          ..._kCourses.map((c) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.statusGrayBg,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(c.icon, size: 18, color: AppColors.primaryNavy),
                    ),
                    const SizedBox(width: 10),
                    Expanded(child: Text(c.name, style: AppTextStyles.bodyMedium)),
                    Text(c.code,
                        style: AppTextStyles.caption.copyWith(
                            color: AppColors.primaryBlue, fontWeight: FontWeight.w600)),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

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
