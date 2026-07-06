import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/providers/locale_provider.dart';
import '../../../core/providers/teacher_providers.dart';
import '../../../core/services/teacher_service.dart';
import '../../../l10n/app_localizations.dart';

// ── Screen ────────────────────────────────────────────────────────────────────

class TeacherProfileScreen extends ConsumerWidget {
  const TeacherProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final profileAsync = ref.watch(teacherProfileProvider);
    final coursesAsync = ref.watch(teacherCoursesProvider);

    return Scaffold(
      backgroundColor: AppColors.bgPage,
      body: profileAsync.when(
        loading: () =>
            const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline,
                  color: AppColors.statusRed, size: 40),
              const SizedBox(height: 8),
              Text(l.teacherProfileLoadError,
                  style: AppTextStyles.bodyMedium),
              TextButton(
                onPressed: () =>
                    ref.invalidate(teacherProfileProvider),
                child: Text(l.retry),
              ),
            ],
          ),
        ),
        data: (profile) {
          if (profile == null) {
            return Center(child: Text(l.teacherProfileNotFound));
          }
          final courses = coursesAsync.valueOrNull ?? [];
          final activeCourses = courses
              .where((c) => c.status.name == 'active')
              .toList();
          final totalStudents = courses.fold(
              0, (s, c) => s + c.studentCount);
          final totalCredits = activeCourses.fold(
              0, (s, c) => s + c.credits);

          return ListView(
            padding:
                const EdgeInsets.all(AppSpacing.screenPadding),
            children: [
              _buildStatsGrid(activeCourses.length, totalStudents,
                  totalCredits, l),
              const SizedBox(height: AppSpacing.sectionGap),
              _buildTeachingInfo(activeCourses, l),
              const SizedBox(height: AppSpacing.sectionGap),
              _buildPersonalInfo(profile, l),
              const SizedBox(height: AppSpacing.sectionGap),
              _buildContactInfo(profile, l),
              const SizedBox(height: AppSpacing.sectionGap),
              _buildAccountSettings(context, ref, l),
              const SizedBox(height: 24),
            ],
          );
        },
      ),
    );
  }

  // ── Stats grid ─────────────────────────────────────────────────────────────

  Widget _buildStatsGrid(int activeCourses, int totalStudents,
      int weeklyCredits, AppLocalizations l) {
    final stats = [
      (
        label: l.teacherProfileStatActiveCourses,
        value: activeCourses.toString().padLeft(2, '0'),
        color: AppColors.primaryNavy
      ),
      (
        label: l.teacherProfileStatStudents,
        value: '$totalStudents',
        color: AppColors.primaryBlue
      ),
      (
        label: l.teacherProfileStatCreditsPerSem,
        value: '$weeklyCredits',
        color: AppColors.statusAmber
      ),
      (
        label: l.teacherProfileStatStatus,
        value: l.statusActive,
        color: AppColors.statusGreen
      ),
    ];
    return GridView.count(
      crossAxisCount: 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 8,
      mainAxisSpacing: 8,
      childAspectRatio: 0.72,
      children: stats
          .map((s) => Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.bgCard,
                  borderRadius:
                      BorderRadius.circular(AppSpacing.cardRadius),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(s.value,
                        style: AppTextStyles.metric
                            .copyWith(color: s.color, fontSize: 18)),
                    const SizedBox(height: 4),
                    Text(s.label,
                        style:
                            AppTextStyles.label.copyWith(fontSize: 9),
                        textAlign: TextAlign.center),
                  ],
                ),
              ))
          .toList(),
    );
  }

  // ── Teaching info ──────────────────────────────────────────────────────────

  Widget _buildTeachingInfo(List<TeacherCourse> courses, AppLocalizations l) {
    return _SectionCard(
      icon: Icons.menu_book_outlined,
      title: l.teacherProfileTeachingInfoTitle,
      child: Column(
        children: [
          if (courses.isEmpty)
            Text(l.teacherProfileNoActiveCourses,
                style: AppTextStyles.body
                    .copyWith(color: AppColors.textSecondary))
          else
            ...courses.take(3).map((c) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.bgPage,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: AppColors.primaryNavy
                                .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(Icons.menu_book_outlined,
                              color: AppColors.primaryNavy, size: 18),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(c.name,
                                  style: AppTextStyles.bodyMedium,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis),
                              Text('${c.code} • ${c.scheduleDisplay}',
                                  style: AppTextStyles.caption,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.statusBlueBg,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                              l.teacherProfileStudentsCountLabel(
                                  c.studentCount),
                              style: AppTextStyles.label.copyWith(
                                  color: AppColors.primaryBlue,
                                  fontSize: 10),
                              textAlign: TextAlign.center),
                        ),
                      ],
                    ),
                  ),
                )),
        ],
      ),
    );
  }

  // ── Personal info ──────────────────────────────────────────────────────────

  Widget _buildPersonalInfo(TeacherProfile profile, AppLocalizations l) {
    return _SectionCard(
      icon: Icons.person_outline,
      title: l.teacherProfileProfessionalInfoTitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _InfoRow(l.profileFullNameLabel, profile.fullName),
          _InfoRow(l.teacherProfileEmployeeIdLabel, profile.employeeCode),
          _InfoRow(l.teacherProfilePositionLabel,
              profile.position ?? l.teacherProfileNotSpecified),
          _InfoRow(l.teacherProfileSpecializationLabel,
              profile.specialization ?? l.teacherProfileNotSpecified),
          _InfoRow(
              l.teacherProfileHireDateLabel,
              _fmtDate(profile.hireDate, l) ?? l.teacherProfileNotSpecified,
              last: true),
        ],
      ),
    );
  }

  String? _fmtDate(String? iso, AppLocalizations l) {
    if (iso == null) return null;
    try {
      final d = DateTime.parse(iso);
      return DateFormat.yMMMd(l.localeName).format(d);
    } catch (_) {
      return iso;
    }
  }

  // ── Contact info ───────────────────────────────────────────────────────────

  Widget _buildContactInfo(TeacherProfile profile, AppLocalizations l) {
    return _SectionCard(
      icon: Icons.contact_phone_outlined,
      title: l.profileContactInfoTitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ContactRow(Icons.email_outlined, profile.email),
          if (profile.phone != null)
            _ContactRow(Icons.phone_outlined, profile.phone!),
          if (profile.departmentName != null)
            _ContactRow(Icons.business_outlined,
                profile.departmentName!,
                last: true)
          else
            _ContactRow(Icons.business_outlined,
                l.teacherProfileDepartmentNotSet,
                last: true),
        ],
      ),
    );
  }

  // ── Account settings ───────────────────────────────────────────────────────

  Widget _buildAccountSettings(
      BuildContext context, WidgetRef ref, AppLocalizations l) {
    final locale = ref.watch(localeProvider);
    return _SectionCard(
      icon: Icons.settings_outlined,
      title: l.profileAccountSettingsTitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SettingsTile(
            icon: Icons.lock_outline,
            label: l.profileChangePassword,
            onTap: () {},
          ),
          _SettingsTile(
            icon: Icons.notifications_outlined,
            label: l.profileNotificationSettings,
            onTap: () => context.push('/teacher/alerts'),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.language_outlined,
                color: AppColors.primaryNavy, size: 20),
            title: Text(l.profileLanguageSettings, style: AppTextStyles.body),
            subtitle: Text(l.profileLanguageSettingsSubtitle,
                style: AppTextStyles.caption),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(locale.languageCode == 'km' ? 'ភាសាខ្មែរ' : 'English',
                    style: AppTextStyles.body
                        .copyWith(color: AppColors.textSecondary)),
                Icon(Icons.chevron_right, color: AppColors.textSecondary),
              ],
            ),
            onTap: () => _showLanguagePicker(context, ref, locale, l),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => context.go('/login'),
              icon: Icon(Icons.logout,
                  size: 16, color: AppColors.statusRed),
              label: Text(l.profileSignOut,
                  style: AppTextStyles.button
                      .copyWith(color: AppColors.statusRed)),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: AppColors.statusRed),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ],
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
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(AppSpacing.cardRadius))),
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
}

// ── Reusable widgets ───────────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  const _SectionCard(
      {required this.icon, required this.title, required this.child});
  final IconData icon;
  final String title;
  final Widget child;

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
          Divider(color: AppColors.border, height: 1),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow(this.label, this.value, {this.last = false});
  final String label, value;
  final bool last;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: last ? 0 : 12),
      child: SizedBox(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: AppTextStyles.label),
            const SizedBox(height: 2),
            Text(value, style: AppTextStyles.body),
          ],
        ),
      ),
    );
  }
}

class _ContactRow extends StatelessWidget {
  const _ContactRow(this.icon, this.value, {this.last = false});
  final IconData icon;
  final String value;
  final bool last;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: last ? 0 : 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: AppColors.primaryNavy),
          const SizedBox(width: 10),
          Expanded(child: Text(value, style: AppTextStyles.body)),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile(
      {required this.icon,
      required this.label,
      required this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: AppColors.primaryNavy, size: 20),
      title: Text(label, style: AppTextStyles.body),
      trailing: Icon(Icons.chevron_right,
          color: AppColors.textSecondary),
      onTap: onTap,
    );
  }
}
