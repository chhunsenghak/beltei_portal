import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/providers/admin_providers.dart';
import '../../../core/services/admin_service.dart';

// ── Screen ────────────────────────────────────────────────────────────────────

class FacultyDepartmentScreen extends ConsumerStatefulWidget {
  const FacultyDepartmentScreen({super.key});

  @override
  ConsumerState<FacultyDepartmentScreen> createState() =>
      _FacultyDepartmentScreenState();
}

class _FacultyDepartmentScreenState
    extends ConsumerState<FacultyDepartmentScreen> {
  bool _showFaculties = true;

  @override
  Widget build(BuildContext context) {
    final facultiesAsync = ref.watch(adminFacultiesProvider);
    final majorsAsync = ref.watch(adminMajorsProvider);
    // pre-load for create-major sheet
    ref.watch(adminDepartmentsProvider);

    return Scaffold(
      backgroundColor: AppColors.bgPage,
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showFaculties
            ? _showCreateFacultySheet()
            : _showCreateMajorSheet(),
        backgroundColor: AppColors.primaryBlue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Academic Structure',
                      style: AppTextStyles.h1
                          .copyWith(color: AppColors.primaryNavy)),
                  const SizedBox(height: 4),
                  Text(
                      'Manage higher education faculties and their respective academic departments.',
                      style: AppTextStyles.caption),
                  const SizedBox(height: 16),
                  _buildTotalCard(facultiesAsync, majorsAsync),
                  const SizedBox(height: 16),
                  _buildToggle(),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: _showFaculties
                ? _buildFacultiesSliver(facultiesAsync)
                : _buildMajorsSliver(majorsAsync),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
    );
  }

  Widget _buildTotalCard(
    AsyncValue<List<AdminFaculty>> fAsync,
    AsyncValue<List<AdminMajor>> mAsync,
  ) {
    final facCount   = fAsync.valueOrNull?.length ?? 0;
    final majorCount = mAsync.valueOrNull?.length ?? 0;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.school_outlined,
                color: AppColors.primaryBlue, size: 24),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('TOTAL ENTITIES',
                  style: AppTextStyles.label.copyWith(fontSize: 9)),
              Text('$facCount Faculties • $majorCount Majors',
                  style: AppTextStyles.h3),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildToggle() {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: AppColors.bgPage,
        borderRadius: BorderRadius.circular(AppSpacing.chipRadius),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: _ToggleOption(
              label: 'Faculties',
              isSelected: _showFaculties,
              onTap: () => setState(() => _showFaculties = true),
            ),
          ),
          Expanded(
            child: _ToggleOption(
              label: 'Majors',
              isSelected: !_showFaculties,
              onTap: () => setState(() => _showFaculties = false),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFacultiesSliver(AsyncValue<List<AdminFaculty>> async) {
    return async.when(
      loading: () => const SliverToBoxAdapter(
          child: Center(child: CircularProgressIndicator())),
      error: (e, _) => SliverToBoxAdapter(
        child: Center(
          child: TextButton(
            onPressed: () => ref.invalidate(adminFacultiesProvider),
            child: const Text('Retry'),
          ),
        ),
      ),
      data: (faculties) {
        if (faculties.isEmpty) {
          return const SliverToBoxAdapter(
            child: Center(child: Text('No faculties found.')),
          );
        }
        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (_, i) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _FacultyCard(
                faculty: faculties[i],
                onEdit: () => _showEditFacultySheet(faculties[i]),
              ),
            ),
            childCount: faculties.length,
          ),
        );
      },
    );
  }

  Widget _buildMajorsSliver(AsyncValue<List<AdminMajor>> async) {
    return async.when(
      loading: () => const SliverToBoxAdapter(
          child: Center(child: CircularProgressIndicator())),
      error: (e, _) => SliverToBoxAdapter(
        child: Center(
          child: TextButton(
            onPressed: () => ref.invalidate(adminMajorsProvider),
            child: const Text('Retry'),
          ),
        ),
      ),
      data: (majors) {
        if (majors.isEmpty) {
          return const SliverToBoxAdapter(
            child: Center(child: Text('No majors found.')),
          );
        }
        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (_, i) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _MajorCard(
                major: majors[i],
                onEdit: () => _showEditMajorSheet(majors[i]),
              ),
            ),
            childCount: majors.length,
          ),
        );
      },
    );
  }

  Future<void> _showEditFacultySheet(AdminFaculty faculty) async {
    final nameCtrl = TextEditingController(text: faculty.name);
    final codeCtrl = TextEditingController(text: faculty.code);
    bool saving = false;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.bgCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: EdgeInsets.fromLTRB(
              16, 20, 16, MediaQuery.of(ctx).viewInsets.bottom + 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Edit Faculty',
                  style: AppTextStyles.h3
                      .copyWith(color: AppColors.primaryNavy)),
              const SizedBox(height: 16),
              _SheetField(
                  label: 'Faculty Name', controller: nameCtrl),
              const SizedBox(height: 12),
              _SheetField(
                  label: 'Faculty Code', controller: codeCtrl),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryNavy,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: saving
                      ? null
                      : () async {
                          final name = nameCtrl.text.trim();
                          final code = codeCtrl.text.trim();
                          if (name.isEmpty || code.isEmpty) return;
                          setSheetState(() => saving = true);
                          try {
                            await ref
                                .read(adminServiceProvider)
                                .updateFaculty(
                                    facultyId: faculty.id,
                                    name: name,
                                    code: code);
                            ref.invalidate(adminFacultiesProvider);
                            if (ctx.mounted) Navigator.pop(ctx);
                          } catch (e) {
                            setSheetState(() => saving = false);
                            if (ctx.mounted) {
                              ScaffoldMessenger.of(ctx).showSnackBar(
                                SnackBar(
                                    content: Text('Error: $e'),
                                    backgroundColor:
                                        AppColors.statusRed),
                              );
                            }
                          }
                        },
                  child: saving
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : const Text('Save Changes'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    nameCtrl.dispose();
    codeCtrl.dispose();
  }

  Future<void> _showEditMajorSheet(AdminMajor major) async {
    final nameCtrl = TextEditingController(text: major.name);
    bool saving = false;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.bgCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: EdgeInsets.fromLTRB(
              16, 20, 16, MediaQuery.of(ctx).viewInsets.bottom + 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Edit Major',
                  style: AppTextStyles.h3
                      .copyWith(color: AppColors.primaryNavy)),
              if (major.facultyName != null) ...[
                const SizedBox(height: 4),
                Text(major.facultyName!,
                    style: AppTextStyles.caption
                        .copyWith(color: AppColors.primaryBlue)),
              ],
              const SizedBox(height: 16),
              _SheetField(label: 'Major Name', controller: nameCtrl),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryNavy,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: saving
                      ? null
                      : () async {
                          final name = nameCtrl.text.trim();
                          if (name.isEmpty) return;
                          setSheetState(() => saving = true);
                          try {
                            await ref
                                .read(adminServiceProvider)
                                .updateMajor(
                                    majorId: major.id, name: name);
                            ref.invalidate(adminMajorsProvider);
                            if (ctx.mounted) Navigator.pop(ctx);
                          } catch (e) {
                            setSheetState(() => saving = false);
                            if (ctx.mounted) {
                              ScaffoldMessenger.of(ctx).showSnackBar(
                                SnackBar(
                                    content: Text('Error: $e'),
                                    backgroundColor:
                                        AppColors.statusRed),
                              );
                            }
                          }
                        },
                  child: saving
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : const Text('Save Changes'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    nameCtrl.dispose();
  }

  Future<void> _showCreateFacultySheet() async {
    final nameCtrl = TextEditingController();
    final codeCtrl = TextEditingController();
    bool saving = false;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.bgCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: EdgeInsets.fromLTRB(
              16, 20, 16, MediaQuery.of(ctx).viewInsets.bottom + 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('New Faculty',
                  style: AppTextStyles.h3
                      .copyWith(color: AppColors.primaryNavy)),
              const SizedBox(height: 16),
              _SheetField(label: 'Faculty Name *', controller: nameCtrl,
                  hint: 'e.g. Faculty of Computer Science'),
              const SizedBox(height: 12),
              _SheetField(label: 'Faculty Code *', controller: codeCtrl,
                  hint: 'e.g. FCS'),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryNavy,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: saving
                      ? null
                      : () async {
                          final name = nameCtrl.text.trim();
                          final code = codeCtrl.text.trim();
                          if (name.isEmpty || code.isEmpty) return;
                          setSheetState(() => saving = true);
                          try {
                            await ref
                                .read(adminServiceProvider)
                                .createFaculty(name: name, code: code);
                            ref.invalidate(adminFacultiesProvider);
                            if (ctx.mounted) Navigator.pop(ctx);
                          } catch (e) {
                            setSheetState(() => saving = false);
                            if (ctx.mounted) {
                              ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
                                content: Text('Error: $e'),
                                backgroundColor: AppColors.statusRed,
                              ));
                            }
                          }
                        },
                  child: saving
                      ? const SizedBox(
                          height: 18, width: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : const Text('Create Faculty'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    nameCtrl.dispose();
    codeCtrl.dispose();
  }

  Future<void> _showCreateMajorSheet() async {
    final faculties = ref.read(adminFacultiesProvider).valueOrNull ?? [];
    final departments = ref.read(adminDepartmentsProvider).valueOrNull ?? [];

    final nameCtrl = TextEditingController();
    String? selectedFacultyId;
    String? selectedDeptId;
    bool saving = false;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.bgCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) {
          final filteredDepts = departments
              .where((d) => d.facultyId == selectedFacultyId)
              .toList();

          return Padding(
            padding: EdgeInsets.fromLTRB(
                16, 20, 16, MediaQuery.of(ctx).viewInsets.bottom + 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('New Major',
                    style: AppTextStyles.h3
                        .copyWith(color: AppColors.primaryNavy)),
                const SizedBox(height: 16),
                _SheetField(label: 'Major Name *', controller: nameCtrl,
                    hint: 'e.g. Software Engineering'),
                const SizedBox(height: 12),
                _SheetDropdown<String?>(
                  label: 'Faculty',
                  value: faculties.any((f) => f.id == selectedFacultyId)
                      ? selectedFacultyId
                      : null,
                  hint: 'Select faculty (optional)',
                  items: faculties
                      .map((f) => DropdownMenuItem<String?>(
                            value: f.id,
                            child: Text(f.name,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.body),
                          ))
                      .toList(),
                  onChanged: (v) => setSheetState(() {
                    selectedFacultyId = v;
                    selectedDeptId = null;
                  }),
                ),
                if (selectedFacultyId != null) ...[
                  const SizedBox(height: 12),
                  _SheetDropdown<String?>(
                    label: 'Department',
                    value: filteredDepts.any((d) => d.id == selectedDeptId)
                        ? selectedDeptId
                        : null,
                    hint: filteredDepts.isEmpty
                        ? 'No departments in this faculty'
                        : 'Select department (optional)',
                    items: filteredDepts
                        .map((d) => DropdownMenuItem<String?>(
                              value: d.id,
                              child: Text(d.name,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextStyles.body),
                            ))
                        .toList(),
                    onChanged: filteredDepts.isEmpty
                        ? null
                        : (v) => setSheetState(() => selectedDeptId = v),
                  ),
                ],
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryNavy,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: saving
                        ? null
                        : () async {
                            final name = nameCtrl.text.trim();
                            if (name.isEmpty) {
                              ScaffoldMessenger.of(ctx).showSnackBar(
                                const SnackBar(
                                    content: Text(
                                        'Major name is required')),
                              );
                              return;
                            }
                            setSheetState(() => saving = true);
                            try {
                              await ref
                                  .read(adminServiceProvider)
                                  .createMajor(
                                      name: name,
                                      departmentId: selectedDeptId);
                              ref.invalidate(adminMajorsProvider);
                              ref.invalidate(adminFacultiesProvider);
                              if (ctx.mounted) Navigator.pop(ctx);
                            } catch (e) {
                              setSheetState(() => saving = false);
                              if (ctx.mounted) {
                                ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
                                  content: Text('Error: $e'),
                                  backgroundColor: AppColors.statusRed,
                                ));
                              }
                            }
                          },
                    child: saving
                        ? const SizedBox(
                            height: 18, width: 18,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : const Text('Create Major'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
    nameCtrl.dispose();
  }
}

// ── Faculty card ──────────────────────────────────────────────────────────────

class _FacultyCard extends StatelessWidget {
  const _FacultyCard({required this.faculty, required this.onEdit});
  final AdminFaculty faculty;
  final VoidCallback onEdit;

  static final _colors = [
    AppColors.primaryNavy,
    AppColors.primaryBlue,
    Color(0xFF7C3AED),
    AppColors.statusAmber,
    AppColors.statusGreen,
  ];
  static const _icons = [
    Icons.account_balance_outlined,
    Icons.computer_outlined,
    Icons.translate_outlined,
    Icons.gavel_outlined,
    Icons.biotech_outlined,
  ];

  @override
  Widget build(BuildContext context) {
    final idx = faculty.name.hashCode.abs() % _colors.length;
    final color = _colors[idx];
    final icon = _icons[idx];

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
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(faculty.name, style: AppTextStyles.bodyMedium),
                    Text('Code: ${faculty.code}', style: AppTextStyles.caption),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppSpacing.chipRadius),
                ),
                child: Text('${faculty.majorCount} Major${faculty.majorCount == 1 ? '' : 's'}',
                    style: AppTextStyles.label.copyWith(
                        color: AppColors.primaryBlue, letterSpacing: 0.3)),
              ),
              GestureDetector(
                onTap: onEdit,
                child: Icon(Icons.edit_outlined,
                    size: 18, color: AppColors.textSecondary),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Major card ────────────────────────────────────────────────────────────────

class _MajorCard extends StatelessWidget {
  const _MajorCard({required this.major, required this.onEdit});
  final AdminMajor major;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: AppColors.primaryNavy.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.bookmark_outline,
                color: AppColors.primaryNavy, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(major.name, style: AppTextStyles.bodyMedium),
                if (major.facultyName != null)
                  Text(major.facultyName!,
                      style: AppTextStyles.caption
                          .copyWith(color: AppColors.primaryBlue)),
              ],
            ),
          ),
          GestureDetector(
            onTap: onEdit,
            child: Icon(Icons.edit_outlined,
                size: 18, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

// ── Sheet text field ──────────────────────────────────────────────────────────

class _SheetField extends StatelessWidget {
  const _SheetField({
    required this.label,
    required this.controller,
    this.hint,
  });
  final String label;
  final TextEditingController controller;
  final String? hint;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: AppTextStyles.caption
                .copyWith(fontSize: 11, color: AppColors.textSecondary)),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          style: AppTextStyles.body,

          decoration: InputDecoration(
            hintText: hint,
            hintStyle:
                AppTextStyles.caption.copyWith(color: AppColors.textLabel),
            filled: true,
            fillColor: AppColors.bgInput,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
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

class _SheetDropdown<T> extends StatelessWidget {
  const _SheetDropdown({
    required this.label,
    required this.value,
    required this.hint,
    required this.items,
    required this.onChanged,
  });
  final String label;
  final T value;
  final String hint;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: AppTextStyles.caption
                .copyWith(fontSize: 11, color: AppColors.textSecondary)),
        const SizedBox(height: 4),
        Container(
          decoration: BoxDecoration(
            color: AppColors.bgInput,
            borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
            border: Border.all(color: AppColors.border),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: value,
              isExpanded: true,
              hint: Text(hint,
                  style:
                      AppTextStyles.caption.copyWith(color: AppColors.textLabel)),
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
              items: items,
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}

// ── Toggle option ─────────────────────────────────────────────────────────────

class _ToggleOption extends StatelessWidget {
  const _ToggleOption(
      {required this.label, required this.isSelected, required this.onTap});
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(AppSpacing.chipRadius - 2),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 4,
                      offset: const Offset(0, 1))
                ]
              : null,
        ),
        child: Center(
          child: Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(
              color: isSelected
                  ? AppColors.primaryNavy
                  : AppColors.textSecondary,
              fontWeight:
                  isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}
