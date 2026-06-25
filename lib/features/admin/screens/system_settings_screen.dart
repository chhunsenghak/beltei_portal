import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';

class SystemSettingsScreen extends StatefulWidget {
  const SystemSettingsScreen({super.key});

  @override
  State<SystemSettingsScreen> createState() => _SystemSettingsScreenState();
}

class _SystemSettingsScreenState extends State<SystemSettingsScreen> {
  final _uniNameController = TextEditingController(text: 'BELTEI International University');
  final _emailController   = TextEditingController(text: 'info@beltei.edu.kh');

  String _academicYear     = '2023 - 2024 (Current)';
  String _semesterFormat   = 'Semester';
  bool _pushNotifications  = true;
  bool _emailDigests       = false;

  final _gradeThresholds = [
    (grade: 'Grade A', range: '90% - 100%'),
    (grade: 'Grade B', range: '80% - 89%'),
    (grade: 'Grade C', range: '70% - 79%'),
  ];

  final _accessControl = [
    (module: 'Student Records',   superAdmin: true,  academicHead: true),
    (module: 'Fee Collection',    superAdmin: true,  academicHead: false),
    (module: 'Curriculum Settings', superAdmin: true, academicHead: true),
  ];

  @override
  void dispose() {
    _uniNameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        children: [
          _buildUniversityInfoSection(),
          const SizedBox(height: 16),
          _buildAcademicCycleSection(),
          const SizedBox(height: 16),
          _buildGradingThresholdsSection(),
          const SizedBox(height: 16),
          _buildNotificationSection(),
          const SizedBox(height: 16),
          _buildAccessControlSection(),
          const SizedBox(height: 20),
          _buildActions(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildUniversityInfoSection() {
    return _SettingsSection(
      icon: Icons.account_balance_outlined,
      title: 'University Information',
      children: [
        _LabeledInput(label: 'University Name', controller: _uniNameController),
        const SizedBox(height: 12),
        _LabeledInput(label: 'Contact Email', controller: _emailController),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          height: 90,
          decoration: BoxDecoration(
            color: AppColors.bgPage,
            borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
            border: Border.all(color: AppColors.border, style: BorderStyle.solid),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.add_photo_alternate_outlined,
                  color: AppColors.textLabel, size: 28),
              const SizedBox(height: 4),
              Text('Upload Logo', style: AppTextStyles.caption),
              Text('Update the primary institutional logo. Recommended size: 512×512px.',
                  style: AppTextStyles.label.copyWith(
                      fontSize: 9, letterSpacing: 0, color: AppColors.textLabel),
                  textAlign: TextAlign.center),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAcademicCycleSection() {
    return _SettingsSection(
      icon: Icons.calendar_month_outlined,
      title: 'Academic Cycle',
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Active Academic Year',
                style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
            const SizedBox(height: 4),
            Container(
              decoration: BoxDecoration(
                color: AppColors.bgInput,
                borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
                border: Border.all(color: AppColors.border),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _academicYear,
                  isExpanded: true,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                  items: ['2023 - 2024 (Current)', '2024 - 2025', '2022 - 2023']
                      .map((e) => DropdownMenuItem(
                          value: e, child: Text(e, style: AppTextStyles.body)))
                      .toList(),
                  onChanged: (v) => setState(() => _academicYear = v!),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Semester Format',
                style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
            const SizedBox(height: 8),
            Row(
              children: ['Semester', 'Trimester'].map((fmt) {
                final isSelected = _semesterFormat == fmt;
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(right: fmt == 'Semester' ? 8 : 0),
                    child: GestureDetector(
                      onTap: () => setState(() => _semesterFormat = fmt),
                      child: Container(
                        height: 44,
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primaryNavy : Colors.white,
                          borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
                          border: Border.all(
                              color: isSelected ? AppColors.primaryNavy : AppColors.border),
                        ),
                        child: Center(
                          child: Text(fmt,
                              style: AppTextStyles.body.copyWith(
                                  color: isSelected ? Colors.white : AppColors.textSecondary,
                                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal)),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGradingThresholdsSection() {
    return _SettingsSection(
      icon: Icons.star_outline,
      title: 'Grading Thresholds',
      children: [
        ..._gradeThresholds.map((g) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(g.grade,
                      style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.primaryNavy)),
                  Text(g.range, style: AppTextStyles.body),
                ],
              ),
            )),
        GestureDetector(
          onTap: () {},
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.edit_outlined, size: 14, color: AppColors.primaryBlue),
              const SizedBox(width: 4),
              Text('Edit Thresholds', style: AppTextStyles.link),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNotificationSection() {
    return _SettingsSection(
      icon: Icons.notifications_outlined,
      title: 'Notification Channels',
      children: [
        _NotificationToggle(
          title: 'Push Notifications',
          subtitle: 'Alert admins of urgent financial approvals.',
          value: _pushNotifications,
          onChanged: (v) => setState(() => _pushNotifications = v),
        ),
        const Divider(height: 20, color: AppColors.divider),
        _NotificationToggle(
          title: 'Automated Email Digests',
          subtitle: 'Weekly enrollment and attendance reports.',
          value: _emailDigests,
          onChanged: (v) => setState(() => _emailDigests = v),
        ),
      ],
    );
  }

  Widget _buildAccessControlSection() {
    return _SettingsSection(
      icon: Icons.lock_outlined,
      title: 'Role-Based Access Control',
      children: [
        Table(
          columnWidths: const {
            0: FlexColumnWidth(2),
            1: FlexColumnWidth(1),
            2: FlexColumnWidth(1),
          },
          children: [
            TableRow(
              children: [
                Text('MODULE', style: AppTextStyles.label.copyWith(fontSize: 9)),
                Text('SUPER\nADMIN', style: AppTextStyles.label.copyWith(fontSize: 9)),
                Text('ACADEMIC\nHEAD', style: AppTextStyles.label.copyWith(fontSize: 9)),
              ],
            ),
            const TableRow(children: [
              SizedBox(height: 8), SizedBox(height: 8), SizedBox(height: 8)
            ]),
            ..._accessControl.map((row) => TableRow(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(row.module, style: AppTextStyles.body),
                    ),
                    Center(
                      child: Icon(
                        row.superAdmin ? Icons.check_circle : Icons.cancel_outlined,
                        color: row.superAdmin ? AppColors.statusGreen : AppColors.statusRed,
                        size: 18,
                      ),
                    ),
                    Center(
                      child: Icon(
                        row.academicHead ? Icons.check_circle : Icons.cancel_outlined,
                        color: row.academicHead ? AppColors.statusGreen : AppColors.statusRed,
                        size: 18,
                      ),
                    ),
                  ],
                )),
          ],
        ),
      ],
    );
  }

  Widget _buildActions() {
    return Column(
      children: [
        TextButton(
          onPressed: () {},
          child: Text('Discard Changes',
              style: AppTextStyles.body.copyWith(color: AppColors.textSecondary)),
        ),
        const SizedBox(height: 8),
        ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 50),
            backgroundColor: AppColors.primaryNavy,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSpacing.buttonRadius)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.save_outlined, size: 18, color: Colors.white),
              const SizedBox(width: 8),
              Text('Save Settings', style: AppTextStyles.button),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Shared widgets ─────────────────────────────────────────────────────────────

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({
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
              Icon(icon, size: 18, color: AppColors.primaryNavy),
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

class _LabeledInput extends StatelessWidget {
  const _LabeledInput({required this.label, required this.controller});
  final String label;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          style: AppTextStyles.body,
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.bgInput,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
              borderSide: const BorderSide(color: AppColors.primaryNavy),
            ),
          ),
        ),
      ],
    );
  }
}

class _NotificationToggle extends StatelessWidget {
  const _NotificationToggle({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTextStyles.bodyMedium),
              Text(subtitle, style: AppTextStyles.caption),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeThumbColor: Colors.white,
          activeTrackColor: AppColors.primaryBlue,
        ),
      ],
    );
  }
}
