import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/providers/admin_providers.dart';
import '../../../core/router/app_router.dart';
import '../../../l10n/app_localizations.dart';

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
    final matchedLoc = GoRouterState.of(context).matchedLocation;
    final showHeader = matchedLoc == AppRoutes.studentHome ||
                       matchedLoc == AppRoutes.courseList ||
                       matchedLoc == AppRoutes.schedule ||
                       matchedLoc == AppRoutes.notificationCenter ||
                       matchedLoc == AppRoutes.studentProfile;
    final location = GoRouterState.of(context).uri.toString();
    final currentIndex = _indexFromLocation(location);

    return Scaffold(
      body: Column(
        children: [
          if (showHeader) _buildShellHeader(context, ref),
          Expanded(child: child),
        ],
      ),
      bottomNavigationBar: _BottomNav(currentIndex: currentIndex),
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
