import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/providers/admin_providers.dart';

// ── Static settings ────────────────────────────────────────────────────────────

final _kSystemSettings = [
  _SettingGroup(
    title: 'Academic',
    items: [
      _SettingItem(icon: Icons.calendar_today_outlined,  label: 'Academic Year Settings', trailing: '2024–2025'),
      _SettingItem(icon: Icons.grading_outlined,          label: 'Grading System',          trailing: 'GPA 4.0'),
      _SettingItem(icon: Icons.alarm_outlined,            label: 'Attendance Threshold',    trailing: '75%'),
      _SettingItem(icon: Icons.event_available_outlined,  label: 'Exam Schedule',           trailing: 'Configure'),
    ],
  ),
  _SettingGroup(
    title: 'Finance',
    items: [
      _SettingItem(icon: Icons.payments_outlined,         label: 'Tuition Fee Structure',   trailing: 'Manage'),
      _SettingItem(icon: Icons.discount_outlined,         label: 'Scholarship Rules',        trailing: 'Manage'),
      _SettingItem(icon: Icons.credit_card_outlined,      label: 'Payment Methods',          trailing: 'Configure'),
    ],
  ),
  _SettingGroup(
    title: 'Notifications',
    items: [
      _SettingItem(icon: Icons.notifications_outlined,    label: 'Push Notifications',  isToggle: true, toggleValue: true),
      _SettingItem(icon: Icons.email_outlined,            label: 'Email Digests',        isToggle: true, toggleValue: true),
      _SettingItem(icon: Icons.sms_outlined,              label: 'SMS Alerts',           isToggle: false, toggleValue: false),
    ],
  ),
  _SettingGroup(
    title: 'System',
    items: [
      _SettingItem(icon: Icons.backup_outlined,           label: 'Data Backup',     trailing: 'Daily'),
      _SettingItem(icon: Icons.security_outlined,         label: 'Security & Access', trailing: 'Manage'),
      _SettingItem(icon: Icons.language_outlined,         label: 'Language',         trailing: 'English'),
      _SettingItem(icon: Icons.info_outline,              label: 'App Version',      trailing: 'v1.0.0'),
    ],
  ),
];

// ── Screen ────────────────────────────────────────────────────────────────────

class AdminProfileScreen extends ConsumerStatefulWidget {
  const AdminProfileScreen({super.key});

  @override
  ConsumerState<AdminProfileScreen> createState() =>
      _AdminProfileScreenState();
}

class _AdminProfileScreenState extends ConsumerState<AdminProfileScreen> {
  final Map<String, bool> _toggles = {};

  @override
  void initState() {
    super.initState();
    for (final group in _kSystemSettings) {
      for (final item in group.items) {
        if (item.isToggle) _toggles[item.label] = item.toggleValue;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(adminProfileProvider);

    return Scaffold(
      backgroundColor: AppColors.bgPage,
      appBar: AppBar(
        backgroundColor: AppColors.primaryNavy,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.go('/admin'),
        ),
        title: Text('Profile & Settings', style: AppTextStyles.h3White),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline,
                  color: AppColors.statusRed, size: 40),
              const SizedBox(height: 8),
              Text('Could not load profile', style: AppTextStyles.bodyMedium),
              TextButton(
                onPressed: () => ref.invalidate(adminProfileProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (profile) => SingleChildScrollView(
          child: Column(
            children: [
              _buildProfileHeader(
                name: profile?.fullName ?? 'Administrator',
                initials: profile?.initials ?? 'AD',
              ),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.screenPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildAdminInfo(profile),
                    const SizedBox(height: AppSpacing.sectionGap),
                    ..._kSystemSettings.map((group) => Padding(
                          padding: const EdgeInsets.only(
                              bottom: AppSpacing.sectionGap),
                          child: _buildSettingGroup(group),
                        )),
                    _buildLogoutButton(context),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Profile header ─────────────────────────────────────────────────────────

  Widget _buildProfileHeader({required String name, required String initials}) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.splashDark, AppColors.splashLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
      child: Column(
        children: [
          Container(
            width: 80, height: 80,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
              border: Border.all(
                  color: Colors.white.withValues(alpha: 0.4), width: 2),
            ),
            child: Center(
              child: Text(initials,
                  style: AppTextStyles.h1.copyWith(
                      color: Colors.white, fontSize: 28)),
            ),
          ),
          const SizedBox(height: 12),
          Text(name, style: AppTextStyles.h2White),
          const SizedBox(height: 4),
          Text('System Administrator',
              style: AppTextStyles.captionWhite.copyWith(fontSize: 13)),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppSpacing.tagRadius),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.shield_outlined, color: Colors.white, size: 13),
                const SizedBox(width: 5),
                Text('ADMINISTRATOR',
                    style: AppTextStyles.label
                        .copyWith(color: Colors.white, letterSpacing: 0.6)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Admin info ─────────────────────────────────────────────────────────────

  Widget _buildAdminInfo(dynamic profile) {
    final details = [
      (icon: Icons.email_outlined, label: 'Email', value: profile?.email ?? '—'),
      if (profile?.phone != null)
        (icon: Icons.phone_outlined, label: 'Phone', value: profile!.phone!),
      (icon: Icons.admin_panel_settings_outlined, label: 'Role', value: 'System Administrator'),
    ];

    return Container(
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: details.asMap().entries.map((e) {
          final isLast = e.key == details.length - 1;
          final d = e.value;
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  children: [
                    Container(
                      width: 34, height: 34,
                      decoration: BoxDecoration(
                        color: AppColors.primaryNavy.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(d.icon,
                          color: AppColors.primaryNavy, size: 16),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(d.label,
                            style: AppTextStyles.label
                                .copyWith(fontSize: 10, letterSpacing: 0.4)),
                        const SizedBox(height: 2),
                        Text(d.value, style: AppTextStyles.body),
                      ],
                    ),
                  ],
                ),
              ),
              if (!isLast) const Divider(height: 1, color: AppColors.divider),
            ],
          );
        }).toList(),
      ),
    );
  }

  // ── Setting group ──────────────────────────────────────────────────────────

  Widget _buildSettingGroup(_SettingGroup group) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(group.title, style: AppTextStyles.h2),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: AppColors.bgCard,
            borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: group.items.asMap().entries.map((e) {
              final isLast = e.key == group.items.length - 1;
              final item = e.value;
              return Column(
                children: [
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 2),
                    leading: Container(
                      width: 34, height: 34,
                      decoration: BoxDecoration(
                        color: AppColors.primaryNavy.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(item.icon,
                          color: AppColors.primaryNavy, size: 16),
                    ),
                    title: Text(item.label, style: AppTextStyles.body),
                    trailing: item.isToggle
                        ? Switch(
                            value: _toggles[item.label] ?? false,
                            onChanged: (v) =>
                                setState(() => _toggles[item.label] = v),
                            activeThumbColor: AppColors.primaryNavy,
                          )
                        : item.trailing != null
                            ? Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(item.trailing!,
                                      style: AppTextStyles.caption),
                                  const SizedBox(width: 4),
                                  const Icon(Icons.chevron_right,
                                      size: 18, color: AppColors.textLabel),
                                ],
                              )
                            : null,
                    onTap: item.isToggle ? null : () {},
                  ),
                  if (!isLast)
                    const Divider(
                        height: 1, color: AppColors.divider, indent: 62),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  // ── Logout button ──────────────────────────────────────────────────────────

  Widget _buildLogoutButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: AppSpacing.buttonHeight,
      child: OutlinedButton.icon(
        onPressed: () => context.go('/login'),
        icon: const Icon(Icons.logout, color: AppColors.statusRed, size: 18),
        label: Text('Sign Out',
            style: AppTextStyles.button.copyWith(color: AppColors.statusRed)),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.statusRed),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
          ),
        ),
      ),
    );
  }
}

// ── Data classes ──────────────────────────────────────────────────────────────

class _SettingGroup {
  const _SettingGroup({required this.title, required this.items});
  final String title;
  final List<_SettingItem> items;
}

class _SettingItem {
  const _SettingItem({
    required this.icon,
    required this.label,
    this.trailing,
    this.isToggle = false,
    this.toggleValue = false,
  });
  final IconData icon;
  final String label;
  final String? trailing;
  final bool isToggle;
  final bool toggleValue;
}
