import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/providers/student_providers.dart';
import '../../../core/supabase/database.types.dart';

const _kFilters = ['All', 'Grades', 'Attendance', 'Payment', 'Leave'];

// ── Screen ────────────────────────────────────────────────────────────────────

class NotificationCenterScreen extends ConsumerStatefulWidget {
  const NotificationCenterScreen({super.key});

  @override
  ConsumerState<NotificationCenterScreen> createState() =>
      _NotificationCenterScreenState();
}

class _NotificationCenterScreenState
    extends ConsumerState<NotificationCenterScreen> {
  int _filterIndex = 0;

  List<NotificationRow> _applyFilter(List<NotificationRow> all) {
    if (_filterIndex == 0) return all;
    final typeMap = {
      1: 'grade',
      2: 'attendance',
      3: 'payment',
      4: 'leave',
    };
    final type = typeMap[_filterIndex];
    if (type == null) return all;
    return all.where((n) => n.type == type).toList();
  }

  @override
  Widget build(BuildContext context) {
    final notifsAsync = ref.watch(studentNotificationsProvider);

    return Scaffold(
      backgroundColor: AppColors.bgPage,
      body: Column(
        children: [
          _buildFilterChips(),
          Expanded(
            child: notifsAsync.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.error_outline,
                        color: AppColors.statusRed, size: 40),
                    const SizedBox(height: 8),
                    Text('Could not load notifications',
                        style: AppTextStyles.bodyMedium),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () => ref
                          .invalidate(studentNotificationsProvider),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
              data: (notifications) {
                final filtered = _applyFilter(notifications);
                if (filtered.isEmpty) {
                  return Center(
                    child: Text('No notifications here.',
                        style: AppTextStyles.caption),
                  );
                }
                return _buildList(filtered);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return SizedBox(
      height: 50,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        itemCount: _kFilters.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final isActive = i == _filterIndex;
          return GestureDetector(
            onTap: () => setState(() => _filterIndex = i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: isActive
                    ? AppColors.primaryNavy
                    : AppColors.bgCard,
                borderRadius:
                    BorderRadius.circular(AppSpacing.chipRadius),
                border: Border.all(
                    color: isActive
                        ? AppColors.primaryNavy
                        : AppColors.border),
              ),
              child: Text(
                _kFilters[i],
                style: AppTextStyles.bodySemiBold.copyWith(
                  color: isActive
                      ? Colors.white
                      : AppColors.textSecondary,
                  fontSize: 13,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildList(List<NotificationRow> notifications) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      itemCount: notifications.length,
      separatorBuilder: (_, _) =>
          Divider(color: AppColors.divider, height: 1),
      itemBuilder: (_, i) => _NotifTile(
        notif: notifications[i],
        onTap: () {
          // Mark as read on tap
          ref
              .read(studentServiceProvider)
              .markNotificationRead(notifications[i].id);
        },
      ),
    );
  }
}

// ── Notification tile ─────────────────────────────────────────────────────────

class _NotifTile extends StatelessWidget {
  const _NotifTile({required this.notif, required this.onTap});
  final NotificationRow notif;
  final VoidCallback onTap;

  IconData get _icon => switch (notif.type) {
        'grade' => Icons.grade_outlined,
        'attendance' => Icons.calendar_today_outlined,
        'payment' => Icons.payment_outlined,
        'announcement' => Icons.campaign_outlined,
        'leave' => Icons.event_busy_outlined,
        _ => Icons.notifications_outlined,
      };

  Color get _iconColor => switch (notif.type) {
        'grade' => AppColors.primaryBlue,
        'attendance' => AppColors.textSecondary,
        'payment' => AppColors.statusAmber,
        'leave' => AppColors.statusRed,
        _ => AppColors.primaryNavy,
      };

  Color get _iconBg => switch (notif.type) {
        'grade' => AppColors.statusBlueBg,
        'payment' => AppColors.statusAmberBg,
        'leave' => AppColors.statusRedBg,
        _ => AppColors.statusGrayBg,
      };

  Color? get _accentColor => switch (notif.type) {
        'grade' => AppColors.primaryNavy,
        'payment' => AppColors.statusAmber,
        'leave' => AppColors.statusRed,
        _ => null,
      };

  String _timeAgo(DateTime? createdAt) {
    if (createdAt == null) return '';
    final diff = DateTime.now().difference(createdAt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'Yesterday';
    return DateFormat('MMM d').format(createdAt);
  }

  @override
  Widget build(BuildContext context) {
    final accent = _accentColor;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: !notif.isRead
              ? AppColors.primaryNavy.withValues(alpha: 0.03)
              : Colors.transparent,
          border: accent != null
              ? Border(
                  left: BorderSide(color: accent, width: 3))
              : null,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md, vertical: 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: _iconBg,
                  shape: BoxShape.circle,
                ),
                child: Icon(_icon, color: _iconColor, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            notif.title,
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontWeight: !notif.isRead
                                  ? FontWeight.bold
                                  : FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(_timeAgo(notif.createdAt),
                            style: AppTextStyles.caption),
                        if (!notif.isRead) ...[
                          const SizedBox(width: 6),
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: AppColors.statusAmber,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      notif.body,
                      style: AppTextStyles.caption.copyWith(height: 1.4),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
