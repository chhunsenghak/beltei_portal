import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';

// ── Mock data ──────────────────────────────────────────────────────────────────

const _kProfile = (
  name: 'Dr. James Wilson',
  fullName: 'Dr. James Arthur Wilson',
  department: 'Department of Computer Science',
  employeeId: 'T-2024-001',
  rank: 'Senior Faculty',
  activeCourses: 4,
  students: 120,
  workload: '28h',
  rating: '4.9',
  dob: '14 May 1978',
  gender: 'Male',
  nationality: 'American',
  education: 'Ph.D. in Computer Science, Stanford University',
  email: 'j.wilson@beltei.edu.kh',
  phone: '+855 23 999 123 (Ext 405)',
  location: 'Block B, 4th Floor, Room 402',
  semesterProgress: 0.75,
);

final _kTeachingCourses = [
  (icon: Icons.code_outlined, name: 'Advanced Algorithms',
   code: 'CS402', schedule: 'Mon, Wed 10:00 AM', students: 32),
  (icon: Icons.storage_outlined, name: 'Database Management',
   code: 'CS205', schedule: 'Tue, Thu 02:00 PM', students: 45),
];

// ── Screen ────────────────────────────────────────────────────────────────────

class TeacherProfileScreen extends StatelessWidget {
  const TeacherProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      body: CustomScrollView(
        slivers: [
          _buildHeader(context),
          SliverPadding(
            padding: const EdgeInsets.all(AppSpacing.screenPadding),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildStatsGrid(),
                const SizedBox(height: AppSpacing.sectionGap),
                _buildTeachingInfo(),
                const SizedBox(height: AppSpacing.sectionGap),
                _buildPersonalInfo(),
                const SizedBox(height: AppSpacing.sectionGap),
                _buildContactInfo(),
                const SizedBox(height: AppSpacing.sectionGap),
                _buildAccountSettings(context),
                const SizedBox(height: 24),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  // ── Header ─────────────────────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 240,
      pinned: true,
      backgroundColor: AppColors.primaryNavy,
      leading: Padding(
        padding: const EdgeInsets.all(8),
        child: Image.asset('assets/images/beltei_logo.png', fit: BoxFit.contain),
      ),
      title: Text('BELTEI Portal', style: AppTextStyles.h3White),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined, color: Colors.white),
          onPressed: () {},
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.splashDark, AppColors.splashLight],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 56),
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  const CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.white24,
                    child: Icon(Icons.person, color: Colors.white, size: 44),
                  ),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppColors.primaryBlue,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.edit, color: Colors.white, size: 12),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(_kProfile.name, style: AppTextStyles.h2White),
              Text(_kProfile.department,
                  style: AppTextStyles.captionWhite.copyWith(fontSize: 12)),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _ProfileBadge(_kProfile.employeeId,
                      icon: Icons.badge_outlined),
                  const SizedBox(width: 8),
                  _ProfileBadge(_kProfile.rank,
                      icon: Icons.verified_outlined,
                      bg: AppColors.statusAmber.withValues(alpha: 0.25)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Stats grid ─────────────────────────────────────────────────────────────

  Widget _buildStatsGrid() {
    final stats = [
      (label: 'ACTIVE\nCOURSES', value: '0${_kProfile.activeCourses}',
       color: AppColors.primaryNavy),
      (label: 'STUDENTS', value: '${_kProfile.students}',
       color: AppColors.primaryBlue),
      (label: 'WORKLOAD\n/ WK', value: _kProfile.workload,
       color: AppColors.statusAmber),
      (label: 'RATING', value: _kProfile.rating,
       color: AppColors.statusGreen),
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
                  borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(s.value,
                        style: AppTextStyles.metric
                            .copyWith(color: s.color, fontSize: 20)),
                    const SizedBox(height: 4),
                    Text(s.label,
                        style: AppTextStyles.label.copyWith(fontSize: 9),
                        textAlign: TextAlign.center),
                  ],
                ),
              ))
          .toList(),
    );
  }

  // ── Teaching info ──────────────────────────────────────────────────────────

  Widget _buildTeachingInfo() {
    return _SectionCard(
      icon: Icons.menu_book_outlined,
      title: 'Teaching Information',
      child: Column(
        children: [
          ..._kTeachingCourses.map((c) => Padding(
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
                          color: AppColors.primaryNavy.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(c.icon,
                            color: AppColors.primaryNavy, size: 18),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(c.name, style: AppTextStyles.bodyMedium),
                            Text('${c.code} • ${c.schedule}',
                                style: AppTextStyles.caption),
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
                        child: Text('${c.students}\nStudents',
                            style: AppTextStyles.label.copyWith(
                                color: AppColors.primaryBlue, fontSize: 10),
                            textAlign: TextAlign.center),
                      ),
                    ],
                  ),
                ),
              )),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Semester Progress', style: AppTextStyles.bodyMedium),
              Text('${(_kProfile.semesterProgress * 100).round()}% Complete',
                  style: AppTextStyles.caption
                      .copyWith(color: AppColors.primaryBlue)),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: _kProfile.semesterProgress,
              minHeight: 6,
              backgroundColor: AppColors.border,
              valueColor: const AlwaysStoppedAnimation<Color>(
                  AppColors.primaryNavy),
            ),
          ),
        ],
      ),
    );
  }

  // ── Personal info ──────────────────────────────────────────────────────────

  Widget _buildPersonalInfo() {
    return _SectionCard(
      icon: Icons.person_outline,
      title: 'Personal Information',
      child: Column(
        children: [
          _InfoRow('FULL NAME', _kProfile.fullName),
          _InfoRow('DATE OF BIRTH', _kProfile.dob),
          _InfoRow('GENDER', _kProfile.gender),
          _InfoRow('NATIONALITY', _kProfile.nationality),
          _InfoRow('EDUCATION', _kProfile.education, last: true),
        ],
      ),
    );
  }

  // ── Contact info ───────────────────────────────────────────────────────────

  Widget _buildContactInfo() {
    return _SectionCard(
      icon: Icons.contact_phone_outlined,
      title: 'Contact Information',
      child: Column(
        children: [
          _ContactRow(Icons.email_outlined, _kProfile.email),
          _ContactRow(Icons.phone_outlined, _kProfile.phone),
          _ContactRow(Icons.location_on_outlined, _kProfile.location,
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
              icon: const Icon(Icons.logout, size: 16,
                  color: AppColors.statusRed),
              label: Text('Sign Out',
                  style: AppTextStyles.button
                      .copyWith(color: AppColors.statusRed)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.statusRed),
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

class _ProfileBadge extends StatelessWidget {
  const _ProfileBadge(this.label, {required this.icon, this.bg});
  final String label;
  final IconData icon;
  final Color? bg;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg ?? Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 12),
          const SizedBox(width: 4),
          Text(label,
              style:
                  AppTextStyles.label.copyWith(color: Colors.white, fontSize: 10)),
        ],
      ),
    );
  }
}

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
          const Divider(color: AppColors.border, height: 1),
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
  const _SettingsTile({required this.icon, required this.label, required this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: AppColors.primaryNavy, size: 20),
      title: Text(label, style: AppTextStyles.body),
      trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
      onTap: onTap,
    );
  }
}
