import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';

class TeacherShell extends StatefulWidget {
  const TeacherShell({super.key, required this.child});
  final Widget child;

  @override
  State<TeacherShell> createState() => _TeacherShellState();
}

class _TeacherShellState extends State<TeacherShell> {
  static const _tabs = [
    (label: 'Home',     icon: Icons.home_outlined,     route: '/teacher'),
    (label: 'Courses',  icon: Icons.menu_book_outlined, route: '/teacher/courses'),
    (label: 'Students', icon: Icons.people_outline,     route: '/teacher/students'),
    (label: 'Alerts',   icon: Icons.notifications_outlined, route: '/teacher/alerts'),
    (label: 'Profile',  icon: Icons.person_outline,     route: '/teacher/profile'),
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
    return Scaffold(
      body: Column(
        children: [
          _buildShellHeader(context),
          Expanded(child: widget.child),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(context, active),
    );
  }

  Widget _buildShellHeader(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
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
                      child: Image.asset(
                        'assets/images/beltei_logo.png',
                        height: 40,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    'BELTEI Campus',
                    style: AppTextStyles.h3.copyWith(
                      color: AppColors.primaryNavy,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(
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
                    _tabs[i].label,
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
}
