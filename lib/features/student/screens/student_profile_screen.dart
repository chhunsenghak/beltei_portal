import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/providers/student_providers.dart';
import '../../../core/router/app_router.dart';
import '../../../core/services/student_service.dart';
import '../../../core/supabase/database.types.dart';

class StudentProfileScreen extends ConsumerWidget {
  const StudentProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncProfile = ref.watch(studentProfileProvider);
    final asyncGrades = ref.watch(studentGradesProvider);

    return Scaffold(
      backgroundColor: AppColors.bgPage,
      body: asyncProfile.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text('Failed to load profile: $e',
                style: AppTextStyles.body, textAlign: TextAlign.center),
          ),
        ),
        data: (profile) {
          if (profile == null) {
            return const Center(child: Text('Profile not found.'));
          }
          final gpa = asyncGrades
              .whenData((semesters) => _cumulativeGpa(semesters))
              .value ??
              0.0;
          return SingleChildScrollView(
            child: Column(
              children: [
                _buildProfileHeader(profile),
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.screenPadding),
                  child: Column(
                    children: [
                      _buildPersonalInfo(profile),
                      const SizedBox(height: AppSpacing.sectionGap),
                      _buildAcademicInfo(profile, gpa),
                      const SizedBox(height: AppSpacing.sectionGap),
                      _buildContactInfo(profile),
                      const SizedBox(height: AppSpacing.sectionGap),
                      _buildEmergencyContact(profile),
                      const SizedBox(height: AppSpacing.sectionGap),
                      _buildAccountSettings(context),
                      const SizedBox(height: AppSpacing.sectionGap),
                      _buildLogoutButton(context),
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

  String _formatDate(String? isoDate) {
    if (isoDate == null || isoDate.isEmpty) return 'N/A';
    final dt = DateTime.tryParse(isoDate);
    if (dt == null) return isoDate;
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
  }

  String _statusLabel(StudentStatus status) => switch (status) {
        StudentStatus.active => 'Active',
        StudentStatus.inactive => 'Inactive',
        StudentStatus.graduated => 'Graduated',
        StudentStatus.suspended => 'Suspended',
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

  Widget _buildProfileHeader(StudentProfile profile) {
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
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child:
                    const Icon(Icons.edit, color: Colors.white, size: 12),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(profile.fullName, style: AppTextStyles.h1White),
          const SizedBox(height: 4),
          Text('ID: ${profile.studentCode}',
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

  Widget _buildPersonalInfo(StudentProfile profile) {
    return _SectionCard(
      icon: Icons.person_outline,
      title: 'Personal Information',
      children: [
        _InfoRow(label: 'FULL NAME', value: profile.fullName),
        _InfoRow(
            label: 'DATE OF BIRTH',
            value: _formatDate(profile.dateOfBirth)),
        _InfoRow(label: 'GENDER', value: profile.gender ?? 'N/A'),
        _InfoRow(
            label: 'NATIONALITY',
            value: profile.nationality ?? 'N/A',
            isLast: true),
      ],
    );
  }

  // ── Academic info ──────────────────────────────────────────────────────────

  Widget _buildAcademicInfo(StudentProfile profile, double gpa) {
    return _SectionCard(
      icon: Icons.school_outlined,
      title: 'Academic Information',
      children: [
        _InfoRow(label: 'MAJOR', value: profile.majorName ?? 'N/A'),
        _InfoRow(
            label: 'YEAR LEVEL', value: 'Year ${profile.yearLevel}'),
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('ACADEMIC STATUS', style: AppTextStyles.label),
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
                  _statusLabel(profile.status),
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
              Text('GPA', style: AppTextStyles.label),
              const SizedBox(height: 4),
              Text(
                gpa > 0 ? '${gpa.toStringAsFixed(2)} / 4.00' : 'N/A',
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

  Widget _buildContactInfo(StudentProfile profile) {
    return _SectionCard(
      icon: Icons.contact_phone_outlined,
      title: 'Contact Information',
      children: [
        _IconInfoRow(icon: Icons.email_outlined, value: profile.email),
        _IconInfoRow(
            icon: Icons.phone_outlined, value: profile.phone ?? 'N/A'),
        _IconInfoRow(
            icon: Icons.location_on_outlined,
            value: profile.address ?? 'N/A',
            isLast: true),
      ],
    );
  }

  // ── Emergency contact ──────────────────────────────────────────────────────

  Widget _buildEmergencyContact(StudentProfile profile) {
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
              const Icon(Icons.emergency_outlined,
                  color: AppColors.statusRed, size: 18),
              const SizedBox(width: 8),
              Text('Emergency Contact', style: AppTextStyles.h3),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Contact',
                  style: AppTextStyles.body
                      .copyWith(color: AppColors.textSecondary)),
              Flexible(
                child: Text(
                  profile.emergencyContact ?? 'N/A',
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

  Widget _buildAccountSettings(BuildContext context) {
    final items = [
      (
        icon: Icons.lock_outline,
        title: 'Change Password',
        subtitle: 'Update your account password',
        onTap: () {}
      ),
      (
        icon: Icons.notifications_outlined,
        title: 'Notification Settings',
        subtitle: 'Manage app alerts and emails',
        onTap: () {}
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
            child: Text('Account Settings', style: AppTextStyles.h3),
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
                  trailing: const Icon(Icons.chevron_right,
                      color: AppColors.textLabel),
                  onTap: e.value.onTap,
                  dense: true,
                ),
                if (!isLast)
                  const Divider(
                      color: AppColors.divider, height: 1, indent: 16),
              ],
            );
          }),
          const Divider(
              color: AppColors.border, height: 1, indent: 16),
          ListTile(
            leading: const Icon(Icons.language_outlined,
                color: AppColors.primaryNavy, size: 22),
            title: Text('Language Settings',
                style: AppTextStyles.bodyMedium),
            subtitle: Text('Choose your preferred language',
                style: AppTextStyles.caption),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('English',
                    style: AppTextStyles.bodyMedium
                        .copyWith(color: AppColors.textSecondary)),
                const Icon(Icons.chevron_right,
                    color: AppColors.textLabel),
              ],
            ),
            dense: true,
            onTap: () {},
          ),
        ],
      ),
    );
  }

  // ── Logout ─────────────────────────────────────────────────────────────────

  Widget _buildLogoutButton(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        await Supabase.instance.client.auth.signOut();
        if (context.mounted) context.go(AppRoutes.login);
      },
      child: Row(
        children: [
          const Icon(Icons.logout, color: AppColors.statusRed, size: 20),
          const SizedBox(width: 8),
          Text('Logout',
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
