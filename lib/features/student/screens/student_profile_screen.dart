import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/providers/locale_provider.dart';
import '../../../core/providers/theme_provider.dart';
import '../../../core/providers/student_providers.dart';
import '../../../core/router/app_router.dart';
import '../../../core/services/student_service.dart';
import '../../../core/supabase/database.types.dart';
import '../../../l10n/app_localizations.dart';

class StudentProfileScreen extends ConsumerWidget {
  const StudentProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final asyncProfile = ref.watch(studentProfileProvider);
    final asyncGrades = ref.watch(studentGradesProvider);

    return Scaffold(
      backgroundColor: AppColors.bgPage,
      body: asyncProfile.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(l.profileLoadError(e),
                style: AppTextStyles.body, textAlign: TextAlign.center),
          ),
        ),
        data: (profile) {
          if (profile == null) {
            return _buildProfileNotFound(context, ref, l);
          }
          final gpa = asyncGrades
              .whenData((semesters) => _cumulativeGpa(semesters))
              .value ??
              0.0;
          return SingleChildScrollView(
            child: Column(
              children: [
                _buildProfileHeader(context, profile, l),
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.screenPadding),
                  child: Column(
                    children: [
                      _buildPersonalInfo(context, profile, l),
                      const SizedBox(height: AppSpacing.sectionGap),
                      _buildAcademicInfo(context, profile, gpa, l),
                      const SizedBox(height: AppSpacing.sectionGap),
                      _buildContactInfo(context, profile, l),
                      const SizedBox(height: AppSpacing.sectionGap),
                      _buildEmergencyContact(context, profile, l),
                      const SizedBox(height: AppSpacing.sectionGap),
                      _buildAccountSettings(context, ref, l),
                      const SizedBox(height: AppSpacing.sectionGap),
                      _buildLogoutButton(context, l),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileNotFound(
      BuildContext context, WidgetRef ref, AppLocalizations l) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.statusRedBg,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.person_off_outlined,
                  color: AppColors.statusRed, size: 36),
            ),
            const SizedBox(height: 20),
            Text(l.profileNotFoundTitle,
                style: AppTextStyles.h2.copyWith(color: AppColors.primaryNavy),
                textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(
              l.profileNotFoundMessage,
              style: AppTextStyles.body
                  .copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            ElevatedButton.icon(
              onPressed: () => ref.invalidate(studentProfileProvider),
              icon: const Icon(Icons.refresh, size: 18, color: Colors.white),
              label: Text(l.profileTryAgain, style: AppTextStyles.button),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryNavy,
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.buttonRadius)),
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () async {
                await Supabase.instance.client.auth.signOut();
                if (context.mounted) context.go(AppRoutes.login);
              },
              icon: Icon(Icons.logout,
                  size: 18, color: AppColors.statusRed),
              label: Text(l.profileSignOut,
                  style: AppTextStyles.button
                      .copyWith(color: AppColors.statusRed)),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
                side: BorderSide(color: AppColors.statusRed),
                shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(AppSpacing.buttonRadius)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  double _cumulativeGpa(List<SemesterGrades> semesters) {
    double totalPoints = 0;
    int totalCredits = 0;
    for (final s in semesters) {
      for (final c in s.courses) {
        if (c.gpaPoints != null && c.credits > 0) {
          totalPoints += c.gpaPoints! * c.credits;
          totalCredits += c.credits;
        }
      }
    }
    return totalCredits > 0 ? totalPoints / totalCredits : 0.0;
  }

  String _formatDate(String? isoDate, AppLocalizations l) {
    if (isoDate == null || isoDate.isEmpty) return l.profileNa;
    final dt = DateTime.tryParse(isoDate);
    if (dt == null) return isoDate;
    return DateFormat.yMMMd(l.localeName).format(dt);
  }

  String _statusLabel(StudentStatus status, AppLocalizations l) => switch (status) {
        StudentStatus.active => l.statusActive,
        StudentStatus.inactive => l.statusInactive,
        StudentStatus.graduated => l.statusGraduated,
        StudentStatus.suspended => l.statusSuspended,
      };

  Color _statusColor(StudentStatus status) => switch (status) {
        StudentStatus.active => AppColors.statusGreen,
        StudentStatus.graduated => AppColors.primaryBlue,
        _ => AppColors.statusRed,
      };

  Color _statusBgColor(StudentStatus status) => switch (status) {
        StudentStatus.active => AppColors.statusGreenBg,
        StudentStatus.graduated => const Color(0xFFDBEAFE),
        _ => AppColors.statusRedBg,
      };

  // ── Profile header ─────────────────────────────────────────────────────────

  Widget _buildProfileHeader(
      BuildContext context, StudentProfile profile, AppLocalizations l) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.splashDark, AppColors.splashLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              profile.avatarUrl != null
                  ? CircleAvatar(
                      radius: 44,
                      backgroundImage: NetworkImage(profile.avatarUrl!),
                    )
                  : CircleAvatar(
                      radius: 44,
                      backgroundColor: Colors.white.withValues(alpha: 0.2),
                      child:
                          const Icon(Icons.person, color: Colors.white, size: 48),
                    ),
            ],
          ),
          const SizedBox(height: 12),
          Text(profile.fullName, style: AppTextStyles.h1White),
          const SizedBox(height: 4),
          Text(l.profileIdLabel(profile.studentCode),
              style: AppTextStyles.captionWhite),
          const SizedBox(height: 6),
          if (profile.facultyName != null)
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius:
                    BorderRadius.circular(AppSpacing.chipRadius),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.school_outlined,
                      color: Colors.white70, size: 14),
                  const SizedBox(width: 4),
                  Text(profile.facultyName!,
                      style: AppTextStyles.captionWhite
                          .copyWith(fontSize: 12)),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // ── Personal info ──────────────────────────────────────────────────────────

  Widget _buildPersonalInfo(
      BuildContext context, StudentProfile profile, AppLocalizations l) {
    return _SectionCard(
      icon: Icons.person_outline,
      title: l.profilePersonalInfoTitle,
      children: [
        _InfoRow(label: l.profileFullNameLabel, value: profile.fullName),
        _InfoRow(
            label: l.profileDateOfBirthLabel,
            value: _formatDate(profile.dateOfBirth, l)),
        _InfoRow(label: l.profileGenderLabel, value: profile.gender ?? l.profileNa),
        _InfoRow(
            label: l.profileNationalityLabel,
            value: profile.nationality ?? l.profileNa,
            isLast: true),
      ],
    );
  }

  // ── Academic info ──────────────────────────────────────────────────────────

  Widget _buildAcademicInfo(BuildContext context, StudentProfile profile,
      double gpa, AppLocalizations l) {
    return _SectionCard(
      icon: Icons.school_outlined,
      title: l.profileAcademicInfoTitle,
      children: [
        _InfoRow(label: l.profileMajorLabel, value: profile.majorName ?? l.profileNa),
        _InfoRow(
            label: l.profileYearLevelLabel,
            value: l.profileYearLevelValue(profile.yearLevel)),
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l.profileAcademicStatusLabel, style: AppTextStyles.label),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _statusBgColor(profile.status),
                  borderRadius:
                      BorderRadius.circular(AppSpacing.chipRadius),
                ),
                child: Text(
                  _statusLabel(profile.status, l),
                  style: AppTextStyles.caption.copyWith(
                      color: _statusColor(profile.status),
                      fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.zero,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l.profileGpaLabel, style: AppTextStyles.label),
              const SizedBox(height: 4),
              Text(
                gpa > 0 ? l.profileGpaValue(gpa.toStringAsFixed(2)) : l.profileNa,
                style: AppTextStyles.metricSmall.copyWith(
                    color: AppColors.primaryNavy, fontSize: 20),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Contact info ───────────────────────────────────────────────────────────

  Widget _buildContactInfo(
      BuildContext context, StudentProfile profile, AppLocalizations l) {
    return _SectionCard(
      icon: Icons.contact_phone_outlined,
      title: l.profileContactInfoTitle,
      children: [
        _IconInfoRow(icon: Icons.email_outlined, value: profile.email),
        _IconInfoRow(
            icon: Icons.phone_outlined, value: profile.phone ?? l.profileNa),
        _IconInfoRow(
            icon: Icons.location_on_outlined,
            value: profile.address ?? l.profileNa,
            isLast: true),
      ],
    );
  }

  // ── Emergency contact ──────────────────────────────────────────────────────

  Widget _buildEmergencyContact(
      BuildContext context, StudentProfile profile, AppLocalizations l) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.emergency_outlined,
                  color: AppColors.statusRed, size: 18),
              const SizedBox(width: 8),
              Text(l.profileEmergencyContactTitle, style: AppTextStyles.h3),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(l.profileContactLabel,
                  style: AppTextStyles.body
                      .copyWith(color: AppColors.textSecondary)),
              Flexible(
                child: Text(
                  profile.emergencyContact ?? l.profileNa,
                  style: AppTextStyles.bodyMedium
                      .copyWith(color: AppColors.primaryBlue),
                  textAlign: TextAlign.end,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Account settings ───────────────────────────────────────────────────────

  Widget _buildAccountSettings(
      BuildContext context, WidgetRef ref, AppLocalizations l) {
    final locale = ref.watch(localeProvider);
    final themeMode = ref.watch(themeModeProvider);
    final items = [
      (
        icon: Icons.lock_outline,
        title: l.profileChangePassword,
        subtitle: l.profileChangePasswordSubtitle,
        onTap: () {}
      ),
      (
        icon: Icons.notifications_outlined,
        title: l.profileNotificationSettings,
        subtitle: l.profileNotificationSettingsSubtitle,
        onTap: () => context.push(AppRoutes.notificationCenter)
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(l.profileAccountSettingsTitle, style: AppTextStyles.h3),
          ),
          ...items.asMap().entries.map((e) {
            final isLast = e.key == items.length - 1;
            return Column(
              children: [
                ListTile(
                  leading: Icon(e.value.icon,
                      color: AppColors.primaryNavy, size: 22),
                  title:
                      Text(e.value.title, style: AppTextStyles.bodyMedium),
                  subtitle:
                      Text(e.value.subtitle, style: AppTextStyles.caption),
                  trailing: Icon(Icons.chevron_right,
                      color: AppColors.textLabel),
                  onTap: e.value.onTap,
                  dense: true,
                ),
                if (!isLast)
                  Divider(
                      color: AppColors.divider, height: 1, indent: 16),
              ],
            );
          }),
          Divider(
              color: AppColors.border, height: 1, indent: 16),
          ListTile(
            leading: Icon(Icons.language_outlined,
                color: AppColors.primaryNavy, size: 22),
            title: Text(l.profileLanguageSettings,
                style: AppTextStyles.bodyMedium),
            subtitle: Text(l.profileLanguageSettingsSubtitle,
                style: AppTextStyles.caption),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(locale.languageCode == 'km' ? 'ភាសាខ្មែរ' : 'English',
                    style: AppTextStyles.bodyMedium
                        .copyWith(color: AppColors.textSecondary)),
                Icon(Icons.chevron_right,
                    color: AppColors.textLabel),
              ],
            ),
            dense: true,
            onTap: () => _showLanguagePicker(context, ref, locale, l),
          ),
          Divider(
              color: AppColors.divider, height: 1, indent: 16),
          ListTile(
            leading: Icon(Icons.dark_mode_outlined,
                color: AppColors.primaryNavy, size: 22),
            title: Text(l.settingsAppearanceTitle,
                style: AppTextStyles.bodyMedium),
            subtitle: Text("Choose your preferred theme",
                style: AppTextStyles.caption),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  switch (themeMode) {
                    ThemeMode.light => l.settingsThemeLight,
                    ThemeMode.dark => l.settingsThemeDark,
                    ThemeMode.system => l.settingsThemeSystem,
                  },
                  style: AppTextStyles.bodyMedium
                      .copyWith(color: AppColors.textSecondary),
                ),
                Icon(Icons.chevron_right,
                    color: AppColors.textLabel),
              ],
            ),
            dense: true,
            onTap: () => _showThemePicker(context, ref, themeMode, l),
          ),
        ],
      ),
    );
  }

  // ── Theme picker ───────────────────────────────────────────────────────────

  void _showThemePicker(
      BuildContext context, WidgetRef ref, ThemeMode currentMode, AppLocalizations l) {
    final options = [
      (mode: ThemeMode.light, label: l.settingsThemeLight),
      (mode: ThemeMode.dark, label: l.settingsThemeDark),
      (mode: ThemeMode.system, label: l.settingsThemeSystem),
    ];
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.bgCard,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppSpacing.cardRadius))),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(l.settingsAppearanceTitle, style: AppTextStyles.h3),
              ),
              ...options.map((opt) {
                final isSelected = currentMode == opt.mode;
                return ListTile(
                  title: Text(opt.label, style: AppTextStyles.body),
                  trailing: isSelected
                      ? Icon(Icons.check_circle, color: AppColors.primaryNavy)
                      : null,
                  onTap: () {
                    ref.read(themeModeProvider.notifier).setThemeMode(opt.mode);
                    Navigator.of(ctx).pop();
                  },
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  // ── Language picker ────────────────────────────────────────────────────────

  void _showLanguagePicker(
      BuildContext context, WidgetRef ref, Locale locale, AppLocalizations l) {
    final options = [
      (code: 'en', label: 'English'),
      (code: 'km', label: 'ភាសាខ្មែរ'),
    ];
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.bgCard,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppSpacing.cardRadius))),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(l.profileChooseLanguage, style: AppTextStyles.h3),
              ),
              ...options.map((opt) {
                final isSelected = locale.languageCode == opt.code;
                return ListTile(
                  title: Text(opt.label, style: AppTextStyles.body),
                  trailing: isSelected
                      ? Icon(Icons.check_circle, color: AppColors.primaryNavy)
                      : null,
                  onTap: () {
                    ref.read(localeProvider.notifier).setLocale(Locale(opt.code));
                    Navigator.of(ctx).pop();
                  },
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  // ── Logout ─────────────────────────────────────────────────────────────────

  Widget _buildLogoutButton(BuildContext context, AppLocalizations l) {
    return GestureDetector(
      onTap: () async {
        await Supabase.instance.client.auth.signOut();
        if (context.mounted) context.go(AppRoutes.login);
      },
      child: Row(
        children: [
          Icon(Icons.logout, color: AppColors.statusRed, size: 20),
          const SizedBox(width: 8),
          Text(l.profileLogout,
              style:
                  AppTextStyles.bodyMedium.copyWith(color: AppColors.statusRed)),
        ],
      ),
    );
  }
}

// ── Reusable section card ──────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.icon,
    required this.title,
    required this.children,
  });

  final IconData icon;
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primaryNavy, size: 18),
              const SizedBox(width: 8),
              Text(title, style: AppTextStyles.h3),
            ],
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow(
      {required this.label, required this.value, this.isLast = false});
  final String label, value;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTextStyles.label),
          const SizedBox(height: 2),
          Text(value, style: AppTextStyles.body),
        ],
      ),
    );
  }
}

class _IconInfoRow extends StatelessWidget {
  const _IconInfoRow(
      {required this.icon, required this.value, this.isLast = false});
  final IconData icon;
  final String value;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: AppColors.textSecondary),
          const SizedBox(width: 10),
          Expanded(child: Text(value, style: AppTextStyles.body)),
        ],
      ),
    );
  }
}
