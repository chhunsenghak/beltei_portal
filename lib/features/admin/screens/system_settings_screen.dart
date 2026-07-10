import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/providers/admin_providers.dart';
import '../../../core/providers/locale_provider.dart';
import '../../../core/providers/theme_provider.dart';
import '../../../core/router/app_router.dart';
import '../../../core/services/admin_service.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/app_toast.dart';

class SystemSettingsScreen extends ConsumerStatefulWidget {
  const SystemSettingsScreen({super.key});

  @override
  ConsumerState<SystemSettingsScreen> createState() => _SystemSettingsScreenState();
}

class _SystemSettingsScreenState extends ConsumerState<SystemSettingsScreen> {
  final _uniNameController = TextEditingController();
  final _emailController = TextEditingController();

  bool _populated = false;
  bool _saving = false;
  String _semesterFormat = 'semester';
  bool _pushNotifications = true;
  bool _emailDigests = false;
  Uint8List? _logoBytes;
  String _logoFileExt = 'jpg';

  final _gradeThresholds = const [
    (grade: 'Grade A', range: '90% - 100%'),
    (grade: 'Grade B', range: '80% - 89%'),
    (grade: 'Grade C', range: '70% - 79%'),
  ];

  final _accessControl = const [
    (module: 'Student Records', superAdmin: true, academicHead: true),
    (module: 'Fee Collection', superAdmin: true, academicHead: false),
    (module: 'Curriculum Settings', superAdmin: true, academicHead: true),
  ];

  @override
  void dispose() {
    _uniNameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _populate(AdminAppSettings s) {
    if (_populated) return;
    _populated = true;
    _resetFromSettings(s);
  }

  void _resetFromSettings(AdminAppSettings s) {
    _uniNameController.text = s.universityName;
    _emailController.text = s.contactEmail;
    _semesterFormat = s.semesterFormat;
    _pushNotifications = s.pushNotificationsEnabled;
    _emailDigests = s.emailDigestsEnabled;
    _logoBytes = null;
  }

  Future<void> _pickLogo() async {
    final file = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 90,
    );
    if (file == null) return;
    final bytes = await file.readAsBytes();
    final ext = file.path.contains('.') ? file.path.split('.').last.toLowerCase() : 'jpg';
    setState(() {
      _logoBytes = bytes;
      _logoFileExt = ext;
    });
  }

  Future<void> _save(AdminAppSettings settings) async {
    setState(() => _saving = true);
    try {
      final svc = ref.read(adminServiceProvider);
      String? logoUrl = settings.logoUrl;
      if (_logoBytes != null) {
        logoUrl = await svc.uploadLogo(_logoBytes!, _logoFileExt);
      }
      await svc.updateAppSettings(
        id: settings.id,
        universityName: _uniNameController.text,
        contactEmail: _emailController.text,
        logoUrl: logoUrl,
        semesterFormat: _semesterFormat,
        pushNotificationsEnabled: _pushNotifications,
        emailDigestsEnabled: _emailDigests,
      );
      ref.invalidate(appSettingsProvider);
      if (!mounted) return;
      setState(() {
        _saving = false;
        _logoBytes = null;
      });
      showSuccessToast(context, AppLocalizations.of(context)!.settingsSaved);
    } catch (e) {
      setState(() => _saving = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.statusRed),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(appSettingsProvider);
    final years = ref.watch(adminAcademicYearsProvider).valueOrNull ?? [];
    final semesters = ref.watch(adminSemestersProvider).valueOrNull ?? [];
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);

    return Scaffold(
      backgroundColor: AppColors.bgPage,
      body: settingsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, color: AppColors.statusRed, size: 40),
              const SizedBox(height: 8),
              Text('Could not load settings', style: AppTextStyles.bodyMedium),
              TextButton(
                onPressed: () => ref.invalidate(appSettingsProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (settings) {
          _populate(settings);
          return ListView(
            padding: const EdgeInsets.all(AppSpacing.screenPadding),
            children: [
              _buildUniversityInfoSection(settings),
              const SizedBox(height: 16),
              _buildAcademicCycleSection(years, semesters),
              const SizedBox(height: 16),
              _buildGradingThresholdsSection(),
              const SizedBox(height: 16),
              _buildNotificationSection(),
              const SizedBox(height: 16),
              _buildAccessControlSection(),
              const SizedBox(height: 16),
              _buildAppearanceSection(themeMode),
              const SizedBox(height: 16),
              _buildLanguageSection(locale),
              const SizedBox(height: 20),
              _buildActions(settings),
              const SizedBox(height: 24),
            ],
          );
        },
      ),
    );
  }

  Widget _buildUniversityInfoSection(AdminAppSettings settings) {
    final l = AppLocalizations.of(context)!;
    final hasImage = _logoBytes != null || settings.logoUrl != null;
    return _SettingsSection(
      icon: Icons.account_balance_outlined,
      title: l.settingsUniversityInfoTitle,
      children: [
        _LabeledInput(label: l.settingsUniversityNameLabel, controller: _uniNameController),
        const SizedBox(height: 12),
        _LabeledInput(label: l.settingsContactEmailLabel, controller: _emailController),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: _pickLogo,
          child: Container(
            width: double.infinity,
            height: 90,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: AppColors.bgPage,
              borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
              border: Border.all(color: AppColors.border),
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (_logoBytes != null)
                  Image.memory(_logoBytes!, fit: BoxFit.cover)
                else if (settings.logoUrl != null)
                  Image.network(settings.logoUrl!, fit: BoxFit.cover)
                else
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_photo_alternate_outlined,
                          color: AppColors.textLabel, size: 28),
                      const SizedBox(height: 4),
                      Text(l.settingsUploadLogo, style: AppTextStyles.caption),
                      Text(l.settingsUploadLogoHint,
                          style: AppTextStyles.label.copyWith(
                              fontSize: 9, letterSpacing: 0, color: AppColors.textLabel),
                          textAlign: TextAlign.center),
                    ],
                  ),
                if (hasImage)
                  Positioned(
                    right: 6,
                    bottom: 6,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.5),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.edit, size: 14, color: Colors.white),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAcademicCycleSection(
      List<AdminAcademicYear> years, List<AdminSemester> semesters) {
    final l = AppLocalizations.of(context)!;
    final currentYear = years.where((y) => y.isCurrent).firstOrNull;
    final currentSemester = semesters.where((s) => s.isCurrent).firstOrNull;

    return _SettingsSection(
      icon: Icons.calendar_month_outlined,
      title: l.settingsAcademicCycleTitle,
      children: [
        _ReadOnlyField(
            label: l.settingsCurrentAcademicYear, value: currentYear?.name ?? '—'),
        const SizedBox(height: 12),
        _ReadOnlyField(
            label: l.settingsCurrentSemester, value: currentSemester?.name ?? '—'),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => context.go(AppRoutes.adminAcademic),
          child: Row(
            children: [
              Icon(Icons.open_in_new, size: 14, color: AppColors.primaryBlue),
              const SizedBox(width: 4),
              Text(l.settingsManageInAcademic, style: AppTextStyles.link),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l.settingsSemesterFormat,
                style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
            const SizedBox(height: 8),
            Row(
              children: [
                (value: 'semester', label: l.settingsSemester),
                (value: 'trimester', label: l.settingsTrimester),
              ].map((fmt) {
                final isSelected = _semesterFormat == fmt.value;
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(right: fmt.value == 'semester' ? 8 : 0),
                    child: GestureDetector(
                      onTap: () => setState(() => _semesterFormat = fmt.value),
                      child: Container(
                        height: 44,
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primaryNavy : AppColors.bgCard,
                          borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
                          border: Border.all(
                              color: isSelected ? AppColors.primaryNavy : AppColors.border),
                        ),
                        child: Center(
                          child: Text(fmt.label,
                              style: AppTextStyles.body.copyWith(
                                  color: isSelected ? Colors.white : AppColors.textSecondary,
                                  fontWeight:
                                      isSelected ? FontWeight.w600 : FontWeight.normal)),
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
    final l = AppLocalizations.of(context)!;
    return _SettingsSection(
      icon: Icons.star_outline,
      title: l.settingsGradingThresholdsTitle,
      children: [
        ..._gradeThresholds.map((g) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(g.grade,
                      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.primaryNavy)),
                  Text(g.range, style: AppTextStyles.body),
                ],
              ),
            )),
        Text(l.settingsNotConfigurable,
            style: AppTextStyles.caption.copyWith(color: AppColors.textLabel)),
      ],
    );
  }

  Widget _buildNotificationSection() {
    final l = AppLocalizations.of(context)!;
    return _SettingsSection(
      icon: Icons.notifications_outlined,
      title: l.settingsNotificationsTitle,
      children: [
        _NotificationToggle(
          title: l.settingsPushNotifications,
          subtitle: l.settingsPushNotificationsSubtitle,
          value: _pushNotifications,
          onChanged: (v) => setState(() => _pushNotifications = v),
        ),
        Divider(height: 20, color: AppColors.divider),
        _NotificationToggle(
          title: l.settingsEmailDigests,
          subtitle: l.settingsEmailDigestsSubtitle,
          value: _emailDigests,
          onChanged: (v) => setState(() => _emailDigests = v),
        ),
      ],
    );
  }

  Widget _buildAccessControlSection() {
    final l = AppLocalizations.of(context)!;
    return _SettingsSection(
      icon: Icons.lock_outlined,
      title: l.settingsAccessControlTitle,
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
            const TableRow(
                children: [SizedBox(height: 8), SizedBox(height: 8), SizedBox(height: 8)]),
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
        const SizedBox(height: 8),
        Text(l.settingsAccessControlReadOnly,
            style: AppTextStyles.caption.copyWith(color: AppColors.textLabel)),
      ],
    );
  }

  Widget _buildAppearanceSection(ThemeMode mode) {
    final l = AppLocalizations.of(context)!;
    final currentBrandColor = ref.watch(brandColorProvider);
    return _SettingsSection(
      icon: Icons.dark_mode_outlined,
      title: l.settingsAppearanceTitle,
      children: [
        Row(
          children: [
            (mode: ThemeMode.light, label: l.settingsThemeLight, icon: Icons.light_mode_outlined),
            (mode: ThemeMode.dark, label: l.settingsThemeDark, icon: Icons.dark_mode_outlined),
            (
              mode: ThemeMode.system,
              label: l.settingsThemeSystem,
              icon: Icons.brightness_auto_outlined
            ),
          ].map((opt) {
            final isSelected = mode == opt.mode;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: opt.mode == ThemeMode.system ? 0 : 8),
                child: GestureDetector(
                  onTap: () => ref.read(themeModeProvider.notifier).setThemeMode(opt.mode),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primaryNavy : AppColors.bgCard,
                      borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
                      border: Border.all(
                          color: isSelected ? AppColors.primaryNavy : AppColors.border),
                    ),
                    child: Column(
                      children: [
                        Icon(opt.icon,
                            size: 18, color: isSelected ? Colors.white : AppColors.textSecondary),
                        const SizedBox(height: 4),
                        Text(opt.label,
                            style: AppTextStyles.caption.copyWith(
                                color: isSelected ? Colors.white : AppColors.textSecondary,
                                fontWeight:
                                    isSelected ? FontWeight.w600 : FontWeight.normal)),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        Text('Theme Color', style: AppTextStyles.bodySemiBold),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: BrandColor.values.map((colorOption) {
            final isSelected = currentBrandColor == colorOption;
            return GestureDetector(
              onTap: () => ref.read(brandColorProvider.notifier).setBrandColor(colorOption),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? colorOption.darkColor
                      : colorOption.lightColor,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected
                        ? (Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : Colors.black)
                        : Colors.transparent,
                    width: 2.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: isSelected
                    ? const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 16,
                      )
                    : null,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildLanguageSection(Locale locale) {
    final l = AppLocalizations.of(context)!;
    return _SettingsSection(
      icon: Icons.language_outlined,
      title: l.settingsLanguageTitle,
      children: [
        Row(
          children: [
            (code: 'en', label: 'English'),
            (code: 'km', label: 'ភាសាខ្មែរ'),
          ].map((opt) {
            final isSelected = locale.languageCode == opt.code;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: opt.code == 'en' ? 8 : 0),
                child: GestureDetector(
                  onTap: () => ref.read(localeProvider.notifier).setLocale(Locale(opt.code)),
                  child: Container(
                    height: 44,
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primaryNavy : AppColors.bgCard,
                      borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
                      border: Border.all(
                          color: isSelected ? AppColors.primaryNavy : AppColors.border),
                    ),
                    child: Center(
                      child: Text(opt.label,
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
    );
  }

  Widget _buildActions(AdminAppSettings settings) {
    final l = AppLocalizations.of(context)!;
    return Column(
      children: [
        TextButton(
          onPressed: _saving ? null : () => setState(() => _resetFromSettings(settings)),
          child: Text(l.settingsDiscardChanges,
              style: AppTextStyles.body.copyWith(color: AppColors.textSecondary)),
        ),
        const SizedBox(height: 8),
        ElevatedButton(
          onPressed: _saving ? null : () => _save(settings),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 50),
            backgroundColor: AppColors.primaryNavy,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSpacing.buttonRadius)),
          ),
          child: _saving
              ? const SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.save_outlined, size: 18, color: Colors.white),
                    const SizedBox(width: 8),
                    Text(l.settingsSaveSettings, style: AppTextStyles.button),
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
        Text(label, style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
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
              borderSide: BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
              borderSide: BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
              borderSide: BorderSide(color: AppColors.primaryNavy),
            ),
          ),
        ),
      ],
    );
  }
}

class _ReadOnlyField extends StatelessWidget {
  const _ReadOnlyField({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.bgInput,
            borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
            border: Border.all(color: AppColors.border),
          ),
          child: Text(value, style: AppTextStyles.body),
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
