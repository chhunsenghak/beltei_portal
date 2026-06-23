import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';

// ── Mock data ──────────────────────────────────────────────────────────────────

class _Notif {
  const _Notif({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.body,
    required this.time,
    this.hasUnread = false,
    this.accentColor,
  });
  final IconData icon;
  final Color iconBg, iconColor;
  final String title, body, time;
  final bool hasUnread;
  final Color? accentColor;
}

const _kNotifications = [
  _Notif(
    icon: Icons.grade_outlined,
    iconBg: AppColors.statusBlueBg,
    iconColor: AppColors.primaryBlue,
    title: 'New Grade Posted: Advance...',
    body: 'Your final grade for the semester has been processed. Log in to your...',
    time: '2m ago',
    hasUnread: true,
    accentColor: AppColors.primaryNavy,
  ),
  _Notif(
    icon: Icons.calendar_today_outlined,
    iconBg: AppColors.statusGrayBg,
    iconColor: AppColors.textSecondary,
    title: 'Attendance Update',
    body: 'Your attendance for Computer Science has been updated.',
    time: '1h ago',
  ),
  _Notif(
    icon: Icons.payment_outlined,
    iconBg: AppColors.statusAmberBg,
    iconColor: AppColors.statusAmber,
    title: 'Tuition Fee Due Reminder',
    body: 'The installment for Quarter 3 is due in 3 days. Avoid late payment penalties...',
    time: '5h ago',
    hasUnread: true,
    accentColor: AppColors.statusAmber,
  ),
  _Notif(
    icon: Icons.campaign_outlined,
    iconBg: AppColors.statusGrayBg,
    iconColor: AppColors.textSecondary,
    title: 'Campus Event: Tech Symp...',
    body: 'Join us this Friday for the annual Tech Symposium featuring industry experts.',
    time: 'Yesterday',
  ),
  _Notif(
    icon: Icons.event_busy_outlined,
    iconBg: AppColors.statusRedBg,
    iconColor: AppColors.statusRed,
    title: 'Leave Request Rejected',
    body: 'Your leave request for the upcoming week has been rejected by the...',
    time: 'Yesterday',
    hasUnread: true,
    accentColor: AppColors.statusRed,
  ),
  _Notif(
    icon: Icons.menu_book_outlined,
    iconBg: AppColors.statusGrayBg,
    iconColor: AppColors.textSecondary,
    title: 'Library Book Overdue',
    body: '"Clean Code: A Handbook of Agile Software Craftsmanship" was due...',
    time: '2 days ago',
  ),
];

const _kFilters = ['All', 'Grades', 'Attendance', 'Tuition'];

// ── Screen ────────────────────────────────────────────────────────────────────

class NotificationCenterScreen extends StatefulWidget {
  const NotificationCenterScreen({super.key});

  @override
  State<NotificationCenterScreen> createState() => _NotificationCenterScreenState();
}

class _NotificationCenterScreenState extends State<NotificationCenterScreen> {
  int _filterIndex = 0;

  // ── build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildFilterChips(),
          Expanded(child: _buildList()),
        ],
      ),
    );
  }

  // ── App bar ────────────────────────────────────────────────────────────────

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.bgPage,
      elevation: 0,
      scrolledUnderElevation: 0,
      automaticallyImplyLeading: false,
      toolbarHeight: 64,
      titleSpacing: 0,
      title: Padding(
        padding: const EdgeInsets.only(left: 16),
        child: Row(
          children: [
            Image.asset('assets/images/beltei_logo.png', height: 48, fit: BoxFit.contain),
            const SizedBox(width: 10),
            Text('Notifications', style: AppTextStyles.h3.copyWith(color: AppColors.primaryNavy)),
          ],
        ),
      ),
      actions: [
        TextButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.done_all, size: 16, color: AppColors.primaryBlue),
          label: Text('Mark all read', style: AppTextStyles.link),
        ),
      ],
    );
  }

  // ── Filter chips ───────────────────────────────────────────────────────────

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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: isActive ? AppColors.primaryNavy : AppColors.bgCard,
                borderRadius: BorderRadius.circular(AppSpacing.chipRadius),
                border: Border.all(
                    color: isActive ? AppColors.primaryNavy : AppColors.border),
              ),
              child: Text(
                _kFilters[i],
                style: AppTextStyles.bodySemiBold.copyWith(
                  color: isActive ? Colors.white : AppColors.textSecondary,
                  fontSize: 13,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Notification list ──────────────────────────────────────────────────────

  Widget _buildList() {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      itemCount: _kNotifications.length + 1,
      separatorBuilder: (_, _) => const Divider(color: AppColors.divider, height: 1),
      itemBuilder: (_, i) {
        if (i == _kNotifications.length) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: Text('View older notifications', style: AppTextStyles.link),
            ),
          );
        }
        return _NotifTile(notif: _kNotifications[i]);
      },
    );
  }
}

// ── Notification tile ─────────────────────────────────────────────────────────

class _NotifTile extends StatelessWidget {
  const _NotifTile({required this.notif});
  final _Notif notif;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: notif.hasUnread
            ? AppColors.primaryNavy.withValues(alpha: 0.03)
            : Colors.transparent,
        border: notif.accentColor != null
            ? Border(left: BorderSide(color: notif.accentColor!, width: 3))
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
                color: notif.iconBg,
                shape: BoxShape.circle,
              ),
              child: Icon(notif.icon, color: notif.iconColor, size: 22),
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
                            fontWeight: notif.hasUnread
                                ? FontWeight.bold
                                : FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(notif.time, style: AppTextStyles.caption),
                      if (notif.hasUnread) ...[
                        const SizedBox(width: 6),
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.statusAmber,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(notif.body,
                      style: AppTextStyles.caption.copyWith(height: 1.4),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
