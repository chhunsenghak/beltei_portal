import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/router/app_router.dart';

// ── Mock data ──────────────────────────────────────────────────────────────────

const _kProfile = (
  name: 'Sovannara Chen',
  id: 'ID: STU-2024-0892',
  faculty: 'Faculty of Information Technology',
  fullName: 'Sovannara Chen',
  dob: 'May 14, 2002',
  gender: 'Male',
  nationality: 'Cambodian',
  degree: 'B.S. in Computer Science',
  semester: 'Year 4, Semester 1',
  academicStatus: 'Enrolled',
  gpa: '3.85 / 4.00',
  email: 's.chen@campus.edu.kh',
  phone: '+855 12 345 678',
  address: 'No. 45, Street 123, Toul Tom Poung, Phnom Penh',
  guardianName: 'Chanthou Chen',
  relationship: 'Father',
  guardianContact: '+855 11 999 888',
);

// ── Screen ────────────────────────────────────────────────────────────────────

class StudentProfileScreen extends StatelessWidget {
  const StudentProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildProfileHeader(),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.screenPadding),
              child: Column(
                children: [
                  _buildPersonalInfo(),
                  const SizedBox(height: AppSpacing.sectionGap),
                  _buildAcademicInfo(),
                  const SizedBox(height: AppSpacing.sectionGap),
                  _buildContactInfo(),
                  const SizedBox(height: AppSpacing.sectionGap),
                  _buildEmergencyContact(),
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
      ),
    );
  }

  // ── App bar ────────────────────────────────────────────────────────────────

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.bgPage,
      elevation: 0,
      scrolledUnderElevation: 0,
      automaticallyImplyLeading: false,
      toolbarHeight: 64,
      titleSpacing: 0,
      title: Padding(
        padding: const EdgeInsets.only(left: 16),
        child: Row(
          children: [
            Image.asset('assets/images/beltei_logo.png', height: 48, fit: BoxFit.contain),
            const SizedBox(width: 10),
            Text('Campus Connect', style: AppTextStyles.h3.copyWith(color: AppColors.primaryNavy)),
          ],
        ),
      ),
      actions: [
        IconButton(icon: const Icon(Icons.search), onPressed: () {}),
      ],
    );
  }

  // ── Profile header ─────────────────────────────────────────────────────────

  Widget _buildProfileHeader() {
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
              CircleAvatar(
                radius: 44,
                backgroundColor: Colors.white.withValues(alpha: 0.2),
                child: const Icon(Icons.person, color: Colors.white, size: 48),
              ),
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Icon(Icons.edit, color: Colors.white, size: 12),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(_kProfile.name, style: AppTextStyles.h1White),
          const SizedBox(height: 4),
          Text(_kProfile.id, style: AppTextStyles.captionWhite),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppSpacing.chipRadius),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.school_outlined, color: Colors.white70, size: 14),
                const SizedBox(width: 4),
                Text(_kProfile.faculty,
                    style: AppTextStyles.captionWhite.copyWith(fontSize: 12)),
              ],
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
      children: [
        _InfoRow(label: 'FULL NAME', value: _kProfile.fullName),
        _InfoRow(label: 'DATE OF BIRTH', value: _kProfile.dob),
        _InfoRow(label: 'GENDER', value: _kProfile.gender),
        _InfoRow(label: 'NATIONALITY', value: _kProfile.nationality, isLast: true),
      ],
    );
  }

  // ── Academic info ──────────────────────────────────────────────────────────

  Widget _buildAcademicInfo() {
    return _SectionCard(
      icon: Icons.school_outlined,
      title: 'Academic Information',
      children: [
        _InfoRow(label: 'DEGREE PROGRAM', value: _kProfile.degree),
        _InfoRow(label: 'CURRENT SEMESTER', value: _kProfile.semester),
        _buildAcademicStatusRow(),
        _buildGPARow(),
      ],
    );
  }

  Widget _buildAcademicStatusRow() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('ACADEMIC STATUS', style: AppTextStyles.label),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.statusGreenBg,
              borderRadius: BorderRadius.circular(AppSpacing.chipRadius),
            ),
            child: Text(_kProfile.academicStatus,
                style: AppTextStyles.caption.copyWith(
                    color: AppColors.statusGreen, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _buildGPARow() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('GPA', style: AppTextStyles.label),
          const SizedBox(height: 4),
          Text(_kProfile.gpa,
              style: AppTextStyles.metricSmall.copyWith(
                  color: AppColors.primaryNavy, fontSize: 20)),
        ],
      ),
    );
  }

  // ── Contact info ───────────────────────────────────────────────────────────

  Widget _buildContactInfo() {
    return _SectionCard(
      icon: Icons.contact_phone_outlined,
      title: 'Contact Information',
      children: [
        _IconInfoRow(icon: Icons.email_outlined, value: _kProfile.email),
        _IconInfoRow(icon: Icons.phone_outlined, value: _kProfile.phone),
        _IconInfoRow(
            icon: Icons.location_on_outlined,
            value: _kProfile.address,
            isLast: true),
      ],
    );
  }

  // ── Emergency contact ──────────────────────────────────────────────────────

  Widget _buildEmergencyContact() {
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
              const Icon(Icons.emergency_outlined, color: AppColors.statusRed, size: 18),
              const SizedBox(width: 8),
              Text('Emergency Contact', style: AppTextStyles.h3),
            ],
          ),
          const SizedBox(height: 14),
          _buildKeyValue('Guardian Name', _kProfile.guardianName),
          const SizedBox(height: 8),
          _buildKeyValue('Relationship', _kProfile.relationship),
          const SizedBox(height: 8),
          _buildKeyValue('Contact', _kProfile.guardianContact,
              valueColor: AppColors.primaryBlue),
        ],
      ),
    );
  }

  Widget _buildKeyValue(String key, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(key, style: AppTextStyles.body.copyWith(color: AppColors.textSecondary)),
        Text(value,
            style: AppTextStyles.bodyMedium.copyWith(color: valueColor)),
      ],
    );
  }

  // ── Account settings ───────────────────────────────────────────────────────

  Widget _buildAccountSettings(BuildContext context) {
    final items = [
      (icon: Icons.lock_outline, title: 'Change Password',
       subtitle: 'Last changed 3 months ago', onTap: () {}),
      (icon: Icons.notifications_outlined, title: 'Notification Settings',
       subtitle: 'Manage app alerts and emails', onTap: () {}),
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
                  leading: Icon(e.value.icon, color: AppColors.primaryNavy, size: 22),
                  title: Text(e.value.title, style: AppTextStyles.bodyMedium),
                  subtitle: Text(e.value.subtitle, style: AppTextStyles.caption),
                  trailing: const Icon(Icons.chevron_right, color: AppColors.textLabel),
                  onTap: e.value.onTap,
                  dense: true,
                ),
                if (!isLast) const Divider(color: AppColors.divider, height: 1, indent: 16),
              ],
            );
          }),
          const Divider(color: AppColors.border, height: 1, indent: 16),
          ListTile(
            leading: const Icon(Icons.language_outlined, color: AppColors.primaryNavy, size: 22),
            title: Text('Language Settings', style: AppTextStyles.bodyMedium),
            subtitle: Text('Choose your preferred language', style: AppTextStyles.caption),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('English',
                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
                const Icon(Icons.chevron_right, color: AppColors.textLabel),
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
      onTap: () => context.go(AppRoutes.login),
      child: Row(
        children: [
          const Icon(Icons.logout, color: AppColors.statusRed, size: 20),
          const SizedBox(width: 8),
          Text('Logout',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.statusRed)),
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
  const _InfoRow({required this.label, required this.value, this.isLast = false});
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
  const _IconInfoRow({required this.icon, required this.value, this.isLast = false});
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
