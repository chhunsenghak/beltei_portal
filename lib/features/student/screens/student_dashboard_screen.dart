import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/providers/student_providers.dart';
import '../../../core/router/app_router.dart';
import '../../../core/services/student_service.dart';
import '../../../core/supabase/database.types.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/section_header.dart';

// ── Helpers ───────────────────────────────────────────────────────────────────

final _currencyFmt = NumberFormat.currency(symbol: '\$', decimalDigits: 2);

String _fmtDate(String iso) {
  try {
    return DateFormat('MMM dd, yyyy').format(DateTime.parse(iso));
  } catch (_) {
    return iso;
  }
}

double _computeCgpa(List<SemesterGrades> semesters) {
  double totalPoints = 0;
  int totalCredits = 0;
  for (final sem in semesters) {
    for (final c in sem.courses) {
      if (c.gpaPoints != null) {
        totalPoints += c.gpaPoints! * c.credits;
        totalCredits += c.credits;
      }
    }
  }
  return totalCredits > 0 ? totalPoints / totalCredits : 0;
}

// ── Screen ────────────────────────────────────────────────────────────────────

class StudentDashboardScreen extends ConsumerWidget {
  const StudentDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        children: [
          _buildQuickActions(context, l),
          const SizedBox(height: AppSpacing.sectionGap),
          _buildAcademicSummary(ref, l),
          const SizedBox(height: AppSpacing.sectionGap),
          _buildAttendanceOverview(ref, l),
          const SizedBox(height: AppSpacing.sectionGap),
          _buildFinancialSummary(context, ref, l),
          const SizedBox(height: AppSpacing.sectionGap),
          _buildRecentActivities(context, ref, l),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // ── Quick actions ──────────────────────────────────────────────────────────

  Widget _buildQuickActions(BuildContext context, AppLocalizations l) {
    final actions = [
      (icon: Icons.calendar_today_outlined, label: l.dashboardActionAttendance, route: AppRoutes.attendanceDashboard),
      (icon: Icons.beach_access_outlined,   label: l.dashboardActionLeave,      route: AppRoutes.leaveRequestDashboard),
      (icon: Icons.menu_book_outlined,      label: l.dashboardActionCourses,    route: AppRoutes.courseList),
      (icon: Icons.grade_outlined,          label: l.dashboardActionGrades,     route: AppRoutes.gradesDashboard),
    ];

    return Column(
      children: [
        SectionHeader(title: l.dashboardQuickActionsTitle, actionLabel: l.dashboardSeeAll, onAction: () {}),
        const SizedBox(height: 12),
        Row(
          children: actions.map((a) {
            return Expanded(
              child: GestureDetector(
                onTap: () => context.go(a.route),
                child: Column(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: AppColors.bgCard,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Icon(a.icon, color: AppColors.primaryNavy, size: 24),
                    ),
                    const SizedBox(height: 6),
                    Text(a.label, style: AppTextStyles.caption.copyWith(fontSize: 11)),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // ── Academic summary ───────────────────────────────────────────────────────

  Widget _buildAcademicSummary(WidgetRef ref, AppLocalizations l) {
    final gradesAsync = ref.watch(studentGradesProvider);
    final coursesAsync = ref.watch(studentCoursesProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: l.dashboardAcademicSummaryTitle, icon: Icons.school_outlined),
        const SizedBox(height: 12),
        gradesAsync.when(
          loading: () => _SummaryGrid(items: [
            _SummaryItem(label: l.dashboardGpaCurrentLabel, value: '—'),
            _SummaryItem(label: l.dashboardCgpaLabel, value: '—'),
            _SummaryItem(label: l.dashboardCreditsDoneLabel, value: '—'),
            _SummaryItem(label: l.dashboardThisSemesterLabel, value: '—'),
          ]),
          error: (_, _) => _SummaryGrid(items: [
            _SummaryItem(label: l.dashboardGpaCurrentLabel, value: l.profileNa),
            _SummaryItem(label: l.dashboardCgpaLabel, value: l.profileNa),
            _SummaryItem(label: l.dashboardCreditsDoneLabel, value: l.profileNa),
            _SummaryItem(label: l.dashboardThisSemesterLabel, value: l.profileNa),
          ]),
          data: (semesters) {
            final current = semesters.where((s) => s.isCurrent).firstOrNull
                ?? (semesters.isNotEmpty ? semesters.first : null);
            final gpa = current != null
                ? current.semesterGpa.toStringAsFixed(2)
                : '—';
            final cgpa = semesters.isNotEmpty
                ? _computeCgpa(semesters).toStringAsFixed(2)
                : '—';
            final creditsDone = semesters
                .where((s) => !s.isCurrent)
                .fold(0, (sum, s) => sum + s.totalCredits);
            final currentCredits = current?.totalCredits ?? 0;

            return coursesAsync.when(
              loading: () => _SummaryGrid(items: [
                _SummaryItem(label: l.dashboardGpaCurrentLabel, value: gpa, valueColor: AppColors.primaryNavy),
                _SummaryItem(label: l.dashboardCgpaLabel, value: cgpa),
                _SummaryItem(label: l.dashboardCreditsDoneLabel, value: '$creditsDone'),
                _SummaryItem(label: l.dashboardThisSemesterLabel, value: '—'),
              ]),
              error: (_, _) => _SummaryGrid(items: [
                _SummaryItem(label: l.dashboardGpaCurrentLabel, value: gpa, valueColor: AppColors.primaryNavy),
                _SummaryItem(label: l.dashboardCgpaLabel, value: cgpa),
                _SummaryItem(label: l.dashboardCreditsDoneLabel, value: '$creditsDone'),
                _SummaryItem(label: l.dashboardThisSemesterLabel, value: l.dashboardCreditsUnit(currentCredits)),
              ]),
              data: (courses) {
                final currentCourseCredits = courses
                    .where((c) => c.isCurrentSemester)
                    .fold(0, (sum, c) => sum + c.credits);
                return _SummaryGrid(items: [
                  _SummaryItem(label: l.dashboardGpaCurrentLabel, value: gpa, valueColor: AppColors.primaryNavy),
                  _SummaryItem(label: l.dashboardCgpaLabel, value: cgpa),
                  _SummaryItem(label: l.dashboardCreditsDoneLabel, value: '$creditsDone'),
                  _SummaryItem(label: l.dashboardThisSemesterLabel, value: l.dashboardCreditsUnit(currentCourseCredits)),
                ]);
              },
            );
          },
        ),
      ],
    );
  }

  // ── Attendance overview ────────────────────────────────────────────────────

  Widget _buildAttendanceOverview(WidgetRef ref, AppLocalizations l) {
    final attendanceAsync = ref.watch(studentAttendanceProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: l.dashboardAttendanceOverviewTitle, icon: Icons.person_outline),
        const SizedBox(height: 12),
        attendanceAsync.when(
          loading: () => _SummaryGrid(items: [
            _SummaryItem(label: l.dashboardOverallRateLabel, value: '—'),
            _SummaryItem(label: l.statusPresent, value: '—'),
            _SummaryItem(label: l.statusAbsent, value: '—'),
            _SummaryItem(label: l.dashboardAttendanceLeaveLabel, value: '—'),
          ]),
          error: (_, _) => _SummaryGrid(items: [
            _SummaryItem(label: l.dashboardOverallRateLabel, value: l.profileNa),
            _SummaryItem(label: l.statusPresent, value: l.profileNa),
            _SummaryItem(label: l.statusAbsent, value: l.profileNa),
            _SummaryItem(label: l.dashboardAttendanceLeaveLabel, value: l.profileNa),
          ]),
          data: (att) => _SummaryGrid(items: [
            _SummaryItem(
              label: l.dashboardOverallRateLabel,
              value: '${(att.overallRate * 100).toStringAsFixed(1)}%',
              valueColor: AppColors.primaryBlue,
            ),
            _SummaryItem(
              label: l.statusPresent,
              value: '${att.present}',
              trailingIcon: Icons.check_circle_outline,
              trailingColor: AppColors.statusGreen,
            ),
            _SummaryItem(
              label: l.statusAbsent,
              value: '${att.absent}',
              valueColor: AppColors.statusRed,
              trailingIcon: Icons.cancel_outlined,
              trailingColor: AppColors.statusRed,
            ),
            _SummaryItem(
              label: l.dashboardAttendanceLeaveLabel,
              value: '${att.excused}',
              valueColor: AppColors.statusAmber,
              trailingIcon: Icons.watch_later_outlined,
              trailingColor: AppColors.statusAmber,
            ),
          ]),
        ),
      ],
    );
  }

  // ── Financial summary ──────────────────────────────────────────────────────

  Widget _buildFinancialSummary(BuildContext context, WidgetRef ref, AppLocalizations l) {
    final financeAsync = ref.watch(studentFinanceProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: l.dashboardFinancialSummaryTitle,
          icon: Icons.account_balance_wallet_outlined,
          actionLabel: l.dashboardSeeAll,
          onAction: () => context.go(AppRoutes.financeDashboard),
        ),
        const SizedBox(height: 12),
        financeAsync.when(
          loading: () => const _FinanceLoadingCard(),
          error: (_, _) => _FinanceErrorCard(l: l),
          data: (fin) => _FinanceSummaryCard(finance: fin, context: context, l: l),
        ),
      ],
    );
  }

  // ── Recent activities ──────────────────────────────────────────────────────

  Widget _buildRecentActivities(BuildContext context, WidgetRef ref, AppLocalizations l) {
    final notifAsync = ref.watch(studentNotificationsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: l.dashboardRecentActivitiesTitle, icon: Icons.history),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: AppColors.bgCard,
            borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
            border: Border.all(color: AppColors.border),
          ),
          child: notifAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            ),
            error: (_, _) => Padding(
              padding: const EdgeInsets.all(16),
              child: Text(l.dashboardActivitiesLoadError),
            ),
            data: (notifications) {
              final recent = notifications.take(3).toList();
              if (recent.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.all(24),
                  child: Center(child: Text(l.dashboardNoRecentActivities)),
                );
              }
              return Column(
                children: [
                  ...recent.asMap().entries.map((e) {
                    final isLast = e.key == recent.length - 1;
                    return _NotifActivityItem(
                      notif: e.value,
                      showDivider: !isLast,
                      l: l,
                    );
                  }),
                  Divider(height: 1, color: AppColors.border),
                  TextButton(
                    onPressed: () => context.go(AppRoutes.notificationCenter),
                    child: Text(l.dashboardViewAllNotifications,
                        style: AppTextStyles.label.copyWith(
                            color: AppColors.primaryBlue, letterSpacing: 1.0)),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

// ── Finance card variants ──────────────────────────────────────────────────────

class _FinanceLoadingCard extends StatelessWidget {
  const _FinanceLoadingCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 160,
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(color: AppColors.border),
      ),
      child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
    );
  }
}

class _FinanceErrorCard extends StatelessWidget {
  const _FinanceErrorCard({required this.l});
  final AppLocalizations l;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(l.dashboardFinanceLoadError),
    );
  }
}

class _FinanceSummaryCard extends StatelessWidget {
  const _FinanceSummaryCard({required this.finance, required this.context, required this.l});
  final FinanceSummary finance;
  final BuildContext context;
  final AppLocalizations l;

  Color get _statusColor => switch (finance.status) {
        'PAID' => AppColors.statusGreen,
        'OVERDUE' => AppColors.statusRed,
        _ => AppColors.statusAmber,
      };

  Color get _statusBg => switch (finance.status) {
        'PAID' => AppColors.statusGreenBg,
        'OVERDUE' => AppColors.statusRedBg,
        _ => AppColors.statusAmberBg,
      };

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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l.dashboardTotalSemesterFee, style: AppTextStyles.label),
                    const SizedBox(height: 4),
                    Text(
                      _currencyFmt.format(finance.totalFees),
                      style: AppTextStyles.metric.copyWith(fontSize: 22),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _statusBg,
                  borderRadius: BorderRadius.circular(AppSpacing.chipRadius),
                ),
                child: Text(
                  finance.status,
                  style: AppTextStyles.label.copyWith(color: _statusColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Divider(color: AppColors.border),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l.dashboardPaidLabel, style: AppTextStyles.label),
                    const SizedBox(height: 2),
                    Text(
                      _currencyFmt.format(finance.totalPaid),
                      style: AppTextStyles.metricSmall.copyWith(
                          color: AppColors.statusGreen, fontSize: 18),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l.dashboardOutstandingLabel, style: AppTextStyles.label),
                    const SizedBox(height: 2),
                    Text(
                      _currencyFmt.format(finance.outstanding),
                      style: AppTextStyles.metricSmall.copyWith(
                          color: AppColors.statusRed, fontSize: 18),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (finance.nextDueDate != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.statusAmberBg,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.access_time, color: AppColors.statusAmber, size: 18),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l.dashboardDueDateReminder,
                          style: AppTextStyles.label.copyWith(color: AppColors.statusAmber)),
                      Text(
                        _fmtDate(finance.nextDueDate!),
                        style: AppTextStyles.bodySemiBold.copyWith(color: AppColors.statusAmber),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton.icon(
              onPressed: () => context.go(AppRoutes.onlinePayment),
              icon: const Icon(Icons.payment, size: 16),
              label: Text(l.dashboardPayNow, style: AppTextStyles.button),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Notification activity item ─────────────────────────────────────────────────

class _NotifActivityItem extends StatelessWidget {
  const _NotifActivityItem({required this.notif, required this.showDivider, required this.l});
  final NotificationRow notif;
  final bool showDivider;
  final AppLocalizations l;

  IconData get _icon => switch (notif.type) {
        'grade' => Icons.grade_outlined,
        'attendance' => Icons.calendar_today_outlined,
        'payment' => Icons.credit_card_outlined,
        'announcement' => Icons.campaign_outlined,
        'leave' => Icons.event_busy_outlined,
        _ => Icons.notifications_outlined,
      };

  Color get _iconColor => switch (notif.type) {
        'grade' => AppColors.primaryBlue,
        'attendance' => AppColors.textSecondary,
        'payment' => AppColors.statusGreen,
        'announcement' => AppColors.statusAmber,
        'leave' => AppColors.statusRed,
        _ => AppColors.primaryNavy,
      };

  Color get _iconBg => switch (notif.type) {
        'grade' => AppColors.statusBlueBg,
        'payment' => AppColors.statusGreenBg,
        'announcement' => AppColors.statusAmberBg,
        'leave' => AppColors.statusRedBg,
        _ => AppColors.statusGrayBg,
      };

  String _timeAgo(DateTime? createdAt) {
    if (createdAt == null) return '';
    final diff = DateTime.now().difference(createdAt);
    if (diff.inMinutes < 60) return l.timeAgoMinutes(diff.inMinutes);
    if (diff.inHours < 24) return l.timeAgoHours(diff.inHours);
    if (diff.inDays == 1) return l.timeAgoYesterday;
    return DateFormat('MMM d').format(createdAt);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _iconBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(_icon, color: _iconColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(notif.title,
                        style: AppTextStyles.bodyMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 2),
                    Text(notif.body,
                        style: AppTextStyles.caption,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(_timeAgo(notif.createdAt),
                  style: AppTextStyles.label.copyWith(fontSize: 10)),
            ],
          ),
        ),
        if (showDivider) Divider(height: 1, color: AppColors.divider),
      ],
    );
  }
}

// ── Reusable 2×2 summary grid ──────────────────────────────────────────────────

class _SummaryGrid extends StatelessWidget {
  const _SummaryGrid({required this.items});
  final List<_SummaryItem> items;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 1.8,
      children: items,
    );
  }
}

class _SummaryItem extends StatelessWidget {
  const _SummaryItem({
    required this.label,
    required this.value,
    this.valueColor,
    this.trailingIcon,
    this.trailingColor,
  });

  final String label;
  final String value;
  final Color? valueColor;
  final IconData? trailingIcon;
  final Color? trailingColor;

  @override
  Widget build(BuildContext context) {
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
          Text(label.toUpperCase(), style: AppTextStyles.label),
          const SizedBox(height: 4),
          Row(
            children: [
              Text(
                value,
                style: AppTextStyles.metricSmall.copyWith(
                  color: valueColor ?? AppColors.textPrimary,
                  fontSize: 22,
                ),
              ),
              if (trailingIcon != null) ...[
                const Spacer(),
                Icon(trailingIcon, color: trailingColor, size: 20),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
