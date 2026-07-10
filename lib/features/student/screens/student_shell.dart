import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/providers/admin_providers.dart';
import '../../../core/providers/theme_provider.dart';
import '../../../core/router/app_router.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/utils/responsive.dart';

class StudentShell extends ConsumerWidget {
  const StudentShell({super.key, required this.child});

  final Widget child;

  static int _indexFromLocation(String location) {
    if (location.startsWith(AppRoutes.courseList)) return 1;
    if (location.startsWith(AppRoutes.schedule)) return 2;
    if (location.startsWith(AppRoutes.notificationCenter)) return 3;
    if (location.startsWith(AppRoutes.studentProfile)) return 4;
    return 0;
  }

  Widget _buildShellHeader(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final logoUrl = ref.watch(appSettingsProvider).valueOrNull?.logoUrl;
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
                    l.appTitle,
                    style: AppTextStyles.h3.copyWith(
                      color: AppColors.primaryNavy,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: Icon(
                      Icons.notifications_outlined,
                      color: AppColors.textSecondary,
                    ),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final keyedChild = KeyedSubtree(
      key: ValueKey(themeMode),
      child: child,
    );
    final matchedLoc = GoRouterState.of(context).matchedLocation;
    final showHeader = matchedLoc == AppRoutes.studentHome ||
                       matchedLoc == AppRoutes.courseList ||
                       matchedLoc == AppRoutes.schedule ||
                       matchedLoc == AppRoutes.notificationCenter ||
                       matchedLoc == AppRoutes.studentProfile;
    final location = GoRouterState.of(context).uri.toString();
    final currentIndex = _indexFromLocation(location);

    if (Responsive.isWide(context)) {
      return Scaffold(
        body: Row(
          children: [
            _buildSidebar(context, ref, currentIndex),
            VerticalDivider(width: 1, color: AppColors.border, thickness: 1),
            Expanded(
              child: keyedChild,
            ),
          ],
        ),
      );
    }

    return Scaffold(
      body: Column(
        children: [
          if (showHeader) _buildShellHeader(context, ref),
          Expanded(child: keyedChild),
        ],
      ),
      bottomNavigationBar: _BottomNav(currentIndex: currentIndex),
    );
  }

  Widget _buildSidebar(BuildContext context, WidgetRef ref, int active) {
    final l = AppLocalizations.of(context)!;
    final logoUrl = ref.watch(appSettingsProvider).valueOrNull?.logoUrl;
    final labels = [l.navHome, l.navCourses, l.navSchedule, l.navAlerts, l.navProfile];

    return Container(
      width: 260,
      color: AppColors.bgCard,
      child: Column(
        children: [
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Row(
                children: [
                  logoUrl != null
                      ? Image.network(logoUrl, height: 44, fit: BoxFit.contain)
                      : Image.asset(
                          'assets/images/beltei_logo.png',
                          height: 44,
                          fit: BoxFit.contain,
                        ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      l.appTitle,
                      style: AppTextStyles.h3.copyWith(
                        color: AppColors.primaryNavy,
                        fontWeight: FontWeight.w700,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Divider(height: 1),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: _BottomNav._items.length,
              itemBuilder: (context, i) {
                final isActive = i == active;
                final item = _BottomNav._items[i];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: InkWell(
                    onTap: () => context.go(_BottomNav._routes[i]),
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isActive
                            ? AppColors.primaryNavy.withValues(alpha: 0.08)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isActive ? item.activeIcon : item.icon,
                            color: isActive
                                ? AppColors.primaryNavy
                                : AppColors.textSecondary,
                            size: 22,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              labels[i],
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: isActive
                                    ? AppColors.primaryNavy
                                    : AppColors.textSecondary,
                                fontWeight: isActive
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                              ),
                            ),
                          ),
                          if (isActive)
                            Container(
                              width: 4,
                              height: 16,
                              decoration: BoxDecoration(
                                color: AppColors.primaryNavy,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.school_outlined, color: AppColors.primaryNavy, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Student Account',
                    style: AppTextStyles.bodySemiBold,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert, color: AppColors.textSecondary),
                  offset: const Offset(0, -100),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  itemBuilder: (_) => [
                    PopupMenuItem(
                      value: 'profile',
                      child: Row(
                        children: [
                          Icon(Icons.person_outline, size: 18, color: AppColors.textSecondary),
                          const SizedBox(width: 10),
                          Text(l.navProfile),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'theme',
                      child: Row(
                        children: [
                          Icon(
                            Theme.of(context).brightness == Brightness.dark
                                ? Icons.light_mode_outlined
                                : Icons.dark_mode_outlined,
                            size: 18,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 10),
                          Text(Theme.of(context).brightness == Brightness.dark ? 'Light Mode' : 'Dark Mode'),
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
                    if (value == 'profile') {
                      context.go(AppRoutes.studentProfile);
                    } else if (value == 'theme') {
                      final notifier = ref.read(themeModeProvider.notifier);
                      final current = Theme.of(context).brightness;
                      notifier.setThemeMode(
                        current == Brightness.dark ? ThemeMode.light : ThemeMode.dark,
                      );
                    } else if (value == 'logout') {
                      _confirmLogout(context);
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
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
}

class _BottomNav extends StatelessWidget {
  const _BottomNav({required this.currentIndex});

  final int currentIndex;

  static const _items = [
    _NavItem(icon: Icons.home_outlined, activeIcon: Icons.home),
    _NavItem(icon: Icons.menu_book_outlined, activeIcon: Icons.menu_book),
    _NavItem(icon: Icons.calendar_today_outlined, activeIcon: Icons.calendar_today),
    _NavItem(icon: Icons.notifications_outlined, activeIcon: Icons.notifications),
    _NavItem(icon: Icons.person_outline, activeIcon: Icons.person),
  ];

  static const _routes = [
    AppRoutes.studentHome,
    AppRoutes.courseList,
    AppRoutes.schedule,
    AppRoutes.notificationCenter,
    AppRoutes.studentProfile,
  ];

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final labels = [l.navHome, l.navCourses, l.navSchedule, l.navAlerts, l.navProfile];
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        child: SizedBox(
          height: 64,
          child: Row(
            children: List.generate(_items.length, (i) {
              final item = _items[i];
              final isActive = i == currentIndex;
              return Expanded(
                child: GestureDetector(
                  onTap: () => context.go(_routes[i]),
                  behavior: HitTestBehavior.opaque,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        decoration: isActive
                            ? BoxDecoration(
                                color: AppColors.primaryNavy.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(20),
                              )
                            : null,
                        child: Icon(
                          isActive ? item.activeIcon : item.icon,
                          color: isActive ? AppColors.primaryNavy : AppColors.textSecondary,
                          size: 22,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        labels[i],
                        style: AppTextStyles.caption.copyWith(
                          color: isActive ? AppColors.primaryNavy : AppColors.textSecondary,
                          fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  const _NavItem({required this.icon, required this.activeIcon});
  final IconData icon;
  final IconData activeIcon;
}
