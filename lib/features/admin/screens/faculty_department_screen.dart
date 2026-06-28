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

    return Scaffold(
      backgroundColor: AppColors.bgPage,
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
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
            child: const Icon(Icons.school_outlined,
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
              child: _FacultyCard(faculty: faculties[i]),
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
              child: _MajorCard(major: majors[i]),
            ),
            childCount: majors.length,
          ),
        );
      },
    );
  }
}

// ── Faculty card ──────────────────────────────────────────────────────────────

class _FacultyCard extends StatelessWidget {
  const _FacultyCard({required this.faculty});
  final AdminFaculty faculty;

  static const _colors = [
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
              const Icon(Icons.edit_outlined,
                  size: 18, color: AppColors.textSecondary),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Major card ────────────────────────────────────────────────────────────────

class _MajorCard extends StatelessWidget {
  const _MajorCard({required this.major});
  final AdminMajor major;

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
            child: const Icon(Icons.bookmark_outline,
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
          const Icon(Icons.edit_outlined,
              size: 18, color: AppColors.textSecondary),
        ],
      ),
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
