import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/providers/admin_providers.dart';

class AdminShell extends ConsumerStatefulWidget {
  const AdminShell({super.key, required this.child});
  final Widget child;

  @override
  ConsumerState<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends ConsumerState<AdminShell> {
  static const _tabs = [
    (label: 'Dashboard', icon: Icons.dashboard_outlined, route: '/admin'),
    (label: 'Users', icon: Icons.people_outline, route: '/admin/users'),
    (label: 'Academic', icon: Icons.school_outlined, route: '/admin/academic'),
    (
      label: 'Finance',
      icon: Icons.account_balance_wallet_outlined,
      route: '/admin/finance',
    ),
    (
      label: 'Settings',
      icon: Icons.settings_outlined,
      route: '/admin/settings',
    ),
  ];

  int _activeIndex(BuildContext context) {
    final loc = GoRouterState.of(context).uri.toString();
    for (int i = _tabs.length - 1; i >= 0; i--) {
      if (loc.startsWith(_tabs[i].route)) return i;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final active = _activeIndex(context);
    final profileAsync = ref.watch(adminProfileProvider);
    return Scaffold(
      body: Column(
        children: [
          _buildShellHeader(context, active, profileAsync),
          Expanded(child: widget.child),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(context, active),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.statusRed),
            onPressed: () {
              Navigator.pop(ctx);
              context.go('/login');
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  Widget _buildShellHeader(BuildContext context, int active, AsyncValue<dynamic> profileAsync) {
    final profile = profileAsync.valueOrNull;
    final displayName = profile?.fullName as String? ?? 'Administrator';
    final displayEmail = profile?.email as String? ?? '';
    final initials = profile?.initials as String? ?? 'A';

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: MediaQuery.of(context).padding.top),
          SizedBox(
            height: 56,
            child: Padding(
              padding: const EdgeInsets.only(left: 0, right: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ClipRect(
                    child: Transform.translate(
                      offset: const Offset(-10, 0),
                      child: Image.asset(
                        'assets/images/beltei_logo.png',
                        height: 40,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    'BELTEI Admin',
                    style: AppTextStyles.h3.copyWith(
                      color: AppColors.primaryNavy,
                    ),
                  ),
                  const Spacer(),
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.notifications_outlined,
                          color: AppColors.textSecondary,
                        ),
                        onPressed: () {},
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.statusRed,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.settings_outlined,
                      color: active == 4
                          ? AppColors.primaryNavy
                          : AppColors.textSecondary,
                    ),
                    onPressed: () => context.go('/admin/settings'),
                  ),
                  PopupMenuButton<String>(
                    offset: const Offset(0, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    icon: CircleAvatar(
                      radius: 17,
                      backgroundColor: AppColors.primaryNavy,
                      child: Text(
                        initials,
                        style: AppTextStyles.caption.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    itemBuilder: (_) => [
                      PopupMenuItem(
                        enabled: false,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              displayName,
                              style: AppTextStyles.bodyMedium,
                            ),
                            if (displayEmail.isNotEmpty)
                              Text(
                                displayEmail,
                                style: AppTextStyles.caption,
                              ),
                          ],
                        ),
                      ),
                      const PopupMenuDivider(),
                      const PopupMenuItem(
                        value: 'logout',
                        child: Row(
                          children: [
                            Icon(
                              Icons.logout,
                              size: 18,
                              color: AppColors.statusRed,
                            ),
                            SizedBox(width: 10),
                            Text(
                              'Logout',
                              style: TextStyle(color: AppColors.statusRed),
                            ),
                          ],
                        ),
                      ),
                    ],
                    onSelected: (value) {
                      if (value == 'logout') _confirmLogout(context);
                    },
                  ),
                  const SizedBox(width: 4),
                ], // Row children
              ), // Row
            ), // Padding
          ), // SizedBox(height: 56)
        ], // Column children
      ), // Column
    ); // Container
  }

  Widget _buildBottomNav(BuildContext context, int active) {
    return Container(
      height: 64,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: List.generate(_tabs.length, (i) {
          final isActive = i == active;
          return Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => context.go(_tabs[i].route),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: isActive
                          ? AppColors.primaryNavy.withValues(alpha: 0.1)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(
                      _tabs[i].icon,
                      size: 22,
                      color: isActive
                          ? AppColors.primaryNavy
                          : AppColors.textLabel,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _tabs[i].label,
                    style: AppTextStyles.caption.copyWith(
                      fontSize: 10,
                      color: isActive
                          ? AppColors.primaryNavy
                          : AppColors.textLabel,
                      fontWeight: isActive
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
