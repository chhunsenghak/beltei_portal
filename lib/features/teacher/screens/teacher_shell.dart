import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/providers/admin_providers.dart';
import '../../../core/providers/teacher_providers.dart';
import '../../../core/providers/theme_provider.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/utils/responsive.dart';

class TeacherShell extends ConsumerStatefulWidget {
  const TeacherShell({super.key, required this.child});
  final Widget child;

  @override
  ConsumerState<TeacherShell> createState() => _TeacherShellState();
}

class _TeacherShellState extends ConsumerState<TeacherShell> {
  static const _tabs = [
    (icon: Icons.home_outlined, route: '/teacher'),
    (icon: Icons.menu_book_outlined, route: '/teacher/courses'),
    (icon: Icons.people_outline, route: '/teacher/students'),
    (icon: Icons.notifications_outlined, route: '/teacher/alerts'),
    (icon: Icons.person_outline, route: '/teacher/profile'),
  ];

  List<String> _tabLabels(AppLocalizations l) =>
      [l.navHome, l.navCourses, l.navStudents, l.navAlerts, l.navProfile];

  int _activeIndex(BuildContext context) {
    final loc = GoRouterState.of(context).uri.toString();
    for (int i = _tabs.length - 1; i >= 0; i--) {
      if (loc.startsWith(_tabs[i].route)) return i;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    final keyedChild = KeyedSubtree(
      key: ValueKey(themeMode),
      child: widget.child,
    );
    final matchedLoc = GoRouterState.of(context).matchedLocation;
    final showHeader = matchedLoc == '/teacher' ||
                       matchedLoc == '/teacher/courses' ||
                       matchedLoc == '/teacher/students' ||
                       matchedLoc == '/teacher/alerts' ||
                       matchedLoc == '/teacher/profile' ||
                       matchedLoc == '/teacher/alerts/announcement';
    final active = _activeIndex(context);
    final profileAsync = ref.watch(teacherProfileProvider);

    if (Responsive.isWide(context)) {
      return Scaffold(
        body: Row(
          children: [
            _buildSidebar(context, active, profileAsync),
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
          if (showHeader) _buildShellHeader(context),
          Expanded(child: keyedChild),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(context, active),
    );
  }

  Widget _buildShellHeader(BuildContext context) {
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
                    onPressed: () => context.go('/teacher/alerts'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
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
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                    decoration: BoxDecoration(
                      color: isActive
                          ? AppColors.primaryNavy.withValues(alpha: 0.1)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(
                      _tabs[i].icon,
                      size: 22,
                      color: isActive ? AppColors.primaryNavy : AppColors.textLabel,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    labels[i],
                    style: AppTextStyles.caption.copyWith(
                      fontSize: 10,
                      color: isActive ? AppColors.primaryNavy : AppColors.textLabel,
                      fontWeight:
                          isActive ? FontWeight.w600 : FontWeight.normal,
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

  Widget _buildSidebar(BuildContext context, int active, AsyncValue<dynamic> profileAsync) {
    final l = AppLocalizations.of(context)!;
    final labels = _tabLabels(l);
    final profile = profileAsync.valueOrNull;
    final displayName = profile?.fullName as String? ?? 'Teacher';
    final displayEmail = profile?.email as String? ?? '';
    final initials = profile != null && profile.fullName.isNotEmpty
        ? profile.fullName.trim().split(' ').where((e) => e.isNotEmpty).map((e) => e[0]).take(2).join().toUpperCase()
        : 'T';
    final logoUrl = ref.watch(appSettingsProvider).valueOrNull?.logoUrl;

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
              itemCount: _tabs.length,
              itemBuilder: (context, i) {
                final isActive = i == active;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: InkWell(
                    onTap: () => context.go(_tabs[i].route),
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
                            _tabs[i].icon,
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
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColors.primaryNavy,
                  child: Text(
                    initials,
                    style: AppTextStyles.bodySemiBold.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        displayName,
                        style: AppTextStyles.bodySemiBold,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (displayEmail.isNotEmpty)
                        Text(
                          displayEmail,
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
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
                      context.go('/teacher/profile');
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
