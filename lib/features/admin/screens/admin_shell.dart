import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/providers/admin_providers.dart';
import '../../../core/providers/theme_provider.dart';
import '../../../l10n/app_localizations.dart';

class AdminShell extends ConsumerStatefulWidget {
  const AdminShell({super.key, required this.child});
  final Widget child;

  @override
  ConsumerState<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends ConsumerState<AdminShell> {
  static const _tabs = [
    (icon: Icons.dashboard_outlined, route: '/admin'),
    (icon: Icons.people_outline, route: '/admin/users'),
    (icon: Icons.school_outlined, route: '/admin/academic'),
    (icon: Icons.account_balance_wallet_outlined, route: '/admin/finance'),
    (icon: Icons.settings_outlined, route: '/admin/settings'),
  ];

  List<String> _tabLabels(AppLocalizations l) =>
      [l.navDashboard, l.navUsers, l.navAcademic, l.navFinance, l.navSettings];

  int _activeIndex(BuildContext context) {
    final loc = GoRouterState.of(context).uri.toString();
    for (int i = _tabs.length - 1; i >= 0; i--) {
      if (loc.startsWith(_tabs[i].route)) return i;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(themeModeProvider);
    final matchedLoc = GoRouterState.of(context).matchedLocation;
    final showHeader = matchedLoc == '/admin' ||
                       matchedLoc == '/admin/users' ||
                       matchedLoc == '/admin/academic' ||
                       matchedLoc == '/admin/finance' ||
                       matchedLoc == '/admin/settings';
    final active = _activeIndex(context);
    final profileAsync = ref.watch(adminProfileProvider);
    final logoUrl = ref.watch(appSettingsProvider).valueOrNull?.logoUrl;
    return Scaffold(
      body: Column(
        children: [
          if (showHeader) _buildShellHeader(context, active, profileAsync, logoUrl),
          Expanded(child: widget.child),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(context, active),
    );
  }

  void _confirmLogout(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(l.logoutTitle),
        content: Text(l.logoutConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.statusRed),
            onPressed: () {
              Navigator.pop(ctx);
              context.go('/login');
            },
            child: Text(l.logoutTitle),
          ),
        ],
      ),
    );
  }

  Widget _buildShellHeader(BuildContext context, int active,
      AsyncValue<dynamic> profileAsync, String? logoUrl) {
    final l = AppLocalizations.of(context)!;
    final profile = profileAsync.valueOrNull;
    final displayName = profile?.fullName as String? ?? 'Administrator';
    final displayEmail = profile?.email as String? ?? '';
    final initials = profile?.initials as String? ?? 'A';

    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgPage,
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
                      child: logoUrl != null
                          ? Image.network(logoUrl, height: 40, fit: BoxFit.contain)
                          : Image.asset(
                              'assets/images/beltei_logo.png',
                              height: 40,
                              fit: BoxFit.contain,
                            ),
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    l.adminAppBarTitle,
                    style: AppTextStyles.h3.copyWith(
                      color: AppColors.primaryNavy,
                    ),
                  ),
                  const Spacer(),
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      IconButton(
                        icon: Icon(
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
                          decoration: BoxDecoration(
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
                      PopupMenuItem(
                        value: 'logout',
                        child: Row(
                          children: [
                            Icon(
                              Icons.logout,
                              size: 18,
                              color: AppColors.statusRed,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              l.logoutTitle,
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
    final labels = _tabLabels(AppLocalizations.of(context)!);
    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: AppColors.bgCard,
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
                    labels[i],
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
