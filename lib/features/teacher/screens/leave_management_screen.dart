import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/providers/teacher_providers.dart';
import '../../../core/services/teacher_service.dart';
import '../../../core/supabase/database.types.dart';
import '../../../l10n/app_localizations.dart';

// ── Helpers ───────────────────────────────────────────────────────────────────

String _fmtDateRange(String start, String end, String locale) {
  try {
    final s = DateFormat('MMM d', locale).format(DateTime.parse(start));
    final e = DateFormat('MMM d, yyyy', locale).format(DateTime.parse(end));
    return s == e ? s : '$s – $e';
  } catch (_) {
    return '$start – $end';
  }
}

// ── Screen ────────────────────────────────────────────────────────────────────

class LeaveManagementScreen extends ConsumerStatefulWidget {
  const LeaveManagementScreen({super.key});

  @override
  ConsumerState<LeaveManagementScreen> createState() =>
      _LeaveManagementScreenState();
}

class _LeaveManagementScreenState
    extends ConsumerState<LeaveManagementScreen> {
  String _filter = 'all';

  List<StudentLeaveDetail> _filtered(List<StudentLeaveDetail> all) {
    if (_filter == 'all') return all;
    return all.where((r) => r.status.name == _filter).toList();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final leavesAsync = ref.watch(teacherStudentLeavesProvider);

    return Scaffold(
      backgroundColor: AppColors.bgPage,
      body: Column(
        children: [
          _buildHeader(l),
          _buildFilterChips(l),
          Expanded(
            child: leavesAsync.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.error_outline,
                        color: AppColors.statusRed, size: 40),
                    const SizedBox(height: 8),
                    Text(l.leaveDashboardLoadError,
                        style: AppTextStyles.bodyMedium),
                    TextButton(
                      onPressed: () =>
                          ref.invalidate(teacherStudentLeavesProvider),
                      child: Text(l.retry),
                    ),
                  ],
                ),
              ),
              data: (all) {
                final items = _filtered(all);
                if (items.isEmpty) return _buildEmpty(l);
                return ListView.separated(
                  padding:
                      const EdgeInsets.all(AppSpacing.screenPadding),
                  itemCount: items.length,
                  separatorBuilder: (_, _) =>
                      const SizedBox(height: 12),
                  itemBuilder: (_, i) => _LeaveCard(
                    request: items[i],
                    l: l,
                    onTap: () => context.push(
                        '/teacher/students/leave/${items[i].id}'),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ── Header ─────────────────────────────────────────────────────────────────

  Widget _buildHeader(AppLocalizations l) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l.leaveDashboardTitle, style: AppTextStyles.h1),
          Text(l.leaveManagementSubtitle,
              style: AppTextStyles.caption),
        ],
      ),
    );
  }

  // ── Filter chips ───────────────────────────────────────────────────────────

  Widget _buildFilterChips(AppLocalizations l) {
    final chips = [
      (value: 'all', label: l.leaveManagementFilterAll, dot: null),
      (value: 'pending', label: l.leaveDashboardStatusPending, dot: AppColors.statusAmber),
      (value: 'approved', label: l.leaveDashboardStatusApproved, dot: AppColors.statusGreen),
      (value: 'rejected', label: l.leaveDashboardStatusRejected, dot: AppColors.statusRed),
    ];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      child: Row(
        children: chips.map((c) {
          final isActive = _filter == c.value;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => setState(() => _filter = c.value),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isActive
                      ? AppColors.primaryNavy
                      : AppColors.bgCard,
                  borderRadius:
                      BorderRadius.circular(AppSpacing.chipRadius),
                  border: Border.all(
                    color: isActive
                        ? AppColors.primaryNavy
                        : AppColors.border,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (c.dot != null) ...[
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color:
                              isActive ? Colors.white : c.dot!,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                    ],
                    Text(c.label,
                        style: AppTextStyles.caption.copyWith(
                          color: isActive
                              ? Colors.white
                              : AppColors.textSecondary,
                          fontWeight: isActive
                              ? FontWeight.w600
                              : FontWeight.normal,
                        )),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildEmpty(AppLocalizations l) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_outlined,
              color: AppColors.textLabel, size: 48),
          const SizedBox(height: 12),
          Text(l.leaveManagementEmptyState,
              style: AppTextStyles.body
                  .copyWith(color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

// ── Leave card ────────────────────────────────────────────────────────────────

class _LeaveCard extends StatelessWidget {
  const _LeaveCard({required this.request, required this.l, required this.onTap});

  final StudentLeaveDetail request;
  final AppLocalizations l;
  final VoidCallback onTap;

  Color get _statusColor => switch (request.status) {
        LeaveStatus.approved => AppColors.statusGreen,
        LeaveStatus.rejected => AppColors.statusRed,
        _ => AppColors.statusAmber,
      };

  Color get _statusBg => switch (request.status) {
        LeaveStatus.approved => AppColors.statusGreenBg,
        LeaveStatus.rejected => AppColors.statusRedBg,
        _ => AppColors.statusAmberBg,
      };

  String get _statusLabel => switch (request.status) {
        LeaveStatus.approved => l.leaveDashboardStatusApproved,
        LeaveStatus.rejected => l.leaveDashboardStatusRejected,
        _ => l.leaveDashboardStatusPending,
      };

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
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
            _buildCardHeader(),
            const SizedBox(height: 12),
            _buildMeta(Icons.beach_access_outlined,
                l.leaveManagementTypeLabel(request.type)),
            const SizedBox(height: 4),
            _buildMeta(Icons.calendar_today_outlined,
                l.leaveManagementDatesLabel(_fmtDateRange(
                    request.startDate, request.endDate, l.localeName))),
            const SizedBox(height: 4),
            _buildMeta(Icons.notes_outlined,
                request.reason,
                maxLines: 2),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.statusBlueBg,
                    borderRadius:
                        BorderRadius.circular(AppSpacing.chipRadius),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.visibility_outlined,
                          size: 12, color: AppColors.primaryBlue),
                      const SizedBox(width: 4),
                      Text(l.leaveManagementViewDetailsButton,
                          style: AppTextStyles.label.copyWith(
                              color: AppColors.primaryBlue)),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios,
                    size: 14, color: AppColors.primaryNavy),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardHeader() {
    return Row(
      children: [
        CircleAvatar(
          radius: 22,
          backgroundColor: AppColors.primaryNavy.withValues(alpha: 0.1),
          child: Text(request.initials,
              style: AppTextStyles.caption.copyWith(
                  color: AppColors.primaryNavy,
                  fontWeight: FontWeight.w700)),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(request.studentName,
                  style: AppTextStyles.bodyMedium),
              Text(l.profileIdLabel(request.studentCode),
                  style: AppTextStyles.caption),
            ],
          ),
        ),
        Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: _statusBg,
            borderRadius: BorderRadius.circular(AppSpacing.chipRadius),
          ),
          child: Text(_statusLabel,
              style: AppTextStyles.label
                  .copyWith(color: _statusColor, letterSpacing: 0.4)),
        ),
      ],
    );
  }

  Widget _buildMeta(IconData icon, String text, {int maxLines = 1}) {
    return Row(
      crossAxisAlignment: maxLines > 1
          ? CrossAxisAlignment.start
          : CrossAxisAlignment.center,
      children: [
        Icon(icon, size: 13, color: AppColors.textSecondary),
        const SizedBox(width: 6),
        Expanded(
          child: Text(text,
              style: AppTextStyles.body
                  .copyWith(color: AppColors.textSecondary),
              maxLines: maxLines,
              overflow: TextOverflow.ellipsis),
        ),
      ],
    );
  }
}
