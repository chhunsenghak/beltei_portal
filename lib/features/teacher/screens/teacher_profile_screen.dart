import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/providers/teacher_providers.dart';
import '../../../core/services/teacher_service.dart';

// ── Screen ────────────────────────────────────────────────────────────────────

class TeacherProfileScreen extends ConsumerWidget {
  const TeacherProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
              Text('Could not load profile',
                  style: AppTextStyles.bodyMedium),
              TextButton(
                onPressed: () =>
                    ref.invalidate(teacherProfileProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (profile) {
          if (profile == null) {
            return const Center(child: Text('Profile not found.'));
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
                  totalCredits),
              const SizedBox(height: AppSpacing.sectionGap),
              _buildTeachingInfo(activeCourses),
              const SizedBox(height: AppSpacing.sectionGap),
              _buildPersonalInfo(profile),
              const SizedBox(height: AppSpacing.sectionGap),
              _buildContactInfo(profile),
              const SizedBox(height: AppSpacing.sectionGap),
              _buildAccountSettings(context),
              const SizedBox(height: 24),
            ],
          );
        },
      ),
    );
  }

  // ── Stats grid ─────────────────────────────────────────────────────────────

  Widget _buildStatsGrid(
      int activeCourses, int totalStudents, int weeklyCredits) {
    final stats = [
      (
        label: 'ACTIVE\nCOURSES',
        value: activeCourses.toString().padLeft(2, '0'),
        color: AppColors.primaryNavy
      ),
      (
        label: 'STUDENTS',
        value: '$totalStudents',
        color: AppColors.primaryBlue
      ),
      (
        label: 'CREDITS\n/ SEM',
        value: '$weeklyCredits',
        color: AppColors.statusAmber
      ),
      (
        label: 'STATUS',
        value: 'Active',
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

  Widget _buildTeachingInfo(List<TeacherCourse> courses) {
    return _SectionCard(
      icon: Icons.menu_book_outlined,
      title: 'Teaching Information',
      child: Column(
        children: [
          if (courses.isEmpty)
            Text('No active courses assigned.',
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
                          child: Text('${c.studentCount}\nStudents',
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

  Widget _buildPersonalInfo(TeacherProfile profile) {
    return _SectionCard(
      icon: Icons.person_outline,
      title: 'Professional Information',
      child: Column(
        children: [
          _InfoRow('FULL NAME', profile.fullName),
          _InfoRow('EMPLOYEE ID', profile.employeeCode),
          _InfoRow('POSITION', profile.position ?? 'Not specified'),
          _InfoRow('SPECIALIZATION',
              profile.specialization ?? 'Not specified'),
          _InfoRow('HIRE DATE',
              _fmtDate(profile.hireDate) ?? 'Not specified',
              last: true),
        ],
      ),
    );
  }

  String? _fmtDate(String? iso) {
    if (iso == null) return null;
    try {
      final d = DateTime.parse(iso);
      const months = [
        '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      return '${d.day} ${months[d.month]} ${d.year}';
    } catch (_) {
      return iso;
    }
  }

  // ── Contact info ───────────────────────────────────────────────────────────

  Widget _buildContactInfo(TeacherProfile profile) {
    return _SectionCard(
      icon: Icons.contact_phone_outlined,
      title: 'Contact Information',
      child: Column(
        children: [
          _ContactRow(Icons.email_outlined, profile.email),
          if (profile.phone != null)
            _ContactRow(Icons.phone_outlined, profile.phone!),
          if (profile.departmentName != null)
            _ContactRow(Icons.business_outlined,
                profile.departmentName!,
                last: true)
          else
            _ContactRow(Icons.business_outlined, 'Department not set',
                last: true),
        ],
      ),
    );
  }

  // ── Account settings ───────────────────────────────────────────────────────

  Widget _buildAccountSettings(BuildContext context) {
    return _SectionCard(
      icon: Icons.settings_outlined,
      title: 'Account Settings',
      child: Column(
        children: [
          _SettingsTile(
            icon: Icons.lock_outline,
            label: 'Change Password',
            onTap: () {},
          ),
          _SettingsTile(
            icon: Icons.notifications_outlined,
            label: 'Notification Settings',
            onTap: () {},
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => context.go('/login'),
              icon: Icon(Icons.logout,
                  size: 16, color: AppColors.statusRed),
              label: Text('Sign Out',
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
