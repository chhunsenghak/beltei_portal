import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/providers/admin_providers.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/services/admin_service.dart';
import '../../../core/supabase/database.types.dart';

// ── Screen ────────────────────────────────────────────────────────────────────

class GlobalLeaveRequestsScreen extends ConsumerStatefulWidget {
  const GlobalLeaveRequestsScreen({super.key});

  @override
  ConsumerState<GlobalLeaveRequestsScreen> createState() =>
      _GlobalLeaveRequestsScreenState();
}

class _GlobalLeaveRequestsScreenState
    extends ConsumerState<GlobalLeaveRequestsScreen> {
  String _filter = 'all';
  bool _isProcessing = false;

  List<AdminLeaveRequest> _filtered(List<AdminLeaveRequest> all) {
    if (_filter == 'all') return all;
    return all.where((r) => r.status.name == _filter).toList();
  }

  Future<void> _decide(AdminLeaveRequest request, bool approve) async {
    final user = await ref.read(currentUserProvider.future);
    if (user == null) return;

    final notesController = TextEditingController();
    if (!mounted) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          approve ? 'Approve Leave Request' : 'Reject Leave Request',
          style: AppTextStyles.h3,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
              text: TextSpan(
                style: AppTextStyles.body,
                children: [
                  TextSpan(text: request.requesterName,
                      style: AppTextStyles.bodyMedium),
                  TextSpan(text: ' – ${request.type}'),
                ],
              ),
            ),
            const SizedBox(height: 4),
            Text(request.dateRange, style: AppTextStyles.caption),
            const SizedBox(height: 12),
            TextField(
              controller: notesController,
              decoration: InputDecoration(
                hintText: 'Optional reviewer notes...',
                hintStyle: AppTextStyles.caption,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  approve ? AppColors.statusGreen : AppColors.statusRed,
              foregroundColor: Colors.white,
            ),
            child: Text(approve ? 'Approve' : 'Reject',
                style: AppTextStyles.button),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) {
      notesController.dispose();
      return;
    }

    setState(() => _isProcessing = true);
    final notes = notesController.text.trim();
    notesController.dispose();

    try {
      final service = ref.read(adminServiceProvider);
      if (approve) {
        await service.approveLeaveRequest(request.id, user.id,
            notes: notes.isEmpty ? null : notes);
      } else {
        await service.rejectLeaveRequest(request.id, user.id,
            notes: notes.isEmpty ? null : notes);
      }
      ref.invalidate(adminLeaveRequestsProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(approve
                ? 'Leave request approved.'
                : 'Leave request rejected.'),
            backgroundColor:
                approve ? AppColors.statusGreen : AppColors.statusRed,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Failed: $e'),
              backgroundColor: AppColors.statusRed),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final leavesAsync = ref.watch(adminLeaveRequestsProvider);

    return Scaffold(
      backgroundColor: AppColors.bgPage,
      body: Stack(
        children: [
          Column(
            children: [
              _buildHeader(),
              leavesAsync.when(
                loading: () => const SizedBox.shrink(),
                error: (_, _) => const SizedBox.shrink(),
                data: (all) => _buildFilterChips(all),
              ),
              Expanded(
                child: leavesAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.error_outline,
                            color: AppColors.statusRed, size: 40),
                        const SizedBox(height: 8),
                        Text('Could not load leave requests',
                            style: AppTextStyles.bodyMedium),
                        TextButton(
                          onPressed: () =>
                              ref.invalidate(adminLeaveRequestsProvider),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                  data: (all) {
                    final items = _filtered(all);
                    if (items.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.inbox_outlined,
                                color: AppColors.textLabel, size: 48),
                            const SizedBox(height: 12),
                            Text('No requests found',
                                style: AppTextStyles.body
                                    .copyWith(color: AppColors.textSecondary)),
                          ],
                        ),
                      );
                    }
                    return ListView.separated(
                      padding: const EdgeInsets.all(AppSpacing.screenPadding),
                      itemCount: items.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (_, i) => _LeaveCard(
                        request: items[i],
                        onApprove: () => _decide(items[i], true),
                        onReject: () => _decide(items[i], false),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          if (_isProcessing)
            const ColoredBox(
              color: Colors.black26,
              child: Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Leave Management',
              style: AppTextStyles.h1
                  .copyWith(color: AppColors.primaryNavy)),
          Text(
              'Review and manage leave requests from students and teachers.',
              style: AppTextStyles.caption),
        ],
      ),
    );
  }

  Widget _buildFilterChips(List<AdminLeaveRequest> all) {
    final pendingCount = all.where((r) => r.status == LeaveStatus.pending).length;
    final chips = [
      (value: 'all', label: 'All (${all.length})'),
      (value: 'pending', label: 'Pending ($pendingCount)'),
      (value: 'approved', label: 'Approved'),
      (value: 'rejected', label: 'Rejected'),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      child: Row(
        children: chips.map((c) {
          final isActive = _filter == c.value;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => setState(() => _filter = c.value),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: isActive ? AppColors.primaryNavy : Colors.white,
                  borderRadius:
                      BorderRadius.circular(AppSpacing.chipRadius),
                  border: Border.all(
                    color: isActive
                        ? AppColors.primaryNavy
                        : AppColors.border,
                  ),
                ),
                child: Text(
                  c.label,
                  style: AppTextStyles.caption.copyWith(
                    color: isActive
                        ? Colors.white
                        : AppColors.textSecondary,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ── Leave card ────────────────────────────────────────────────────────────────

class _LeaveCard extends StatelessWidget {
  const _LeaveCard({
    required this.request,
    required this.onApprove,
    required this.onReject,
  });

  final AdminLeaveRequest request;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  Color get _typeColor {
    final t = request.type.toLowerCase();
    if (t.contains('medical') || t.contains('sick')) return AppColors.primaryBlue;
    if (t.contains('family')) return const Color(0xFF7C3AED);
    if (t.contains('personal')) return AppColors.statusGray;
    return AppColors.statusAmber;
  }

  Color get _typeBg {
    final t = request.type.toLowerCase();
    if (t.contains('medical') || t.contains('sick')) return AppColors.statusBlueBg;
    if (t.contains('family')) return const Color(0xFFEDE9FE);
    return AppColors.statusAmberBg;
  }

  @override
  Widget build(BuildContext context) {
    final isPending = request.status == LeaveStatus.pending;
    final isApproved = request.status == LeaveStatus.approved;

    final statusColor = isPending
        ? AppColors.statusAmber
        : isApproved
            ? AppColors.statusGreen
            : AppColors.statusRed;
    final statusBg = isPending
        ? AppColors.statusAmberBg
        : isApproved
            ? AppColors.statusGreenBg
            : AppColors.statusRedBg;
    final statusIcon = isPending
        ? Icons.schedule_outlined
        : isApproved
            ? Icons.check_circle_outline
            : Icons.cancel_outlined;
    final statusLabel = isPending
        ? 'Pending Review'
        : isApproved
            ? 'Approved'
            : 'Rejected';

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
              CircleAvatar(
                radius: 22,
                backgroundColor: AppColors.primaryNavy.withValues(alpha: 0.12),
                child: Text(request.initials,
                    style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.primaryNavy,
                        fontWeight: FontWeight.w700)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(request.requesterName, style: AppTextStyles.bodyMedium),
                    Text(request.programInfo, style: AppTextStyles.caption),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: _typeBg,
                  borderRadius:
                      BorderRadius.circular(AppSpacing.tagRadius),
                ),
                child: Text(request.type,
                    style: AppTextStyles.label
                        .copyWith(color: _typeColor, letterSpacing: 0.3)),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.calendar_today_outlined,
                  size: 13, color: AppColors.textSecondary),
              const SizedBox(width: 4),
              Expanded(
                child: Text(request.dateRange,
                    style: AppTextStyles.caption.copyWith(fontSize: 11)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusBg,
              borderRadius: BorderRadius.circular(AppSpacing.tagRadius),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(statusIcon, size: 13, color: statusColor),
                const SizedBox(width: 4),
                Text(statusLabel,
                    style: AppTextStyles.label
                        .copyWith(color: statusColor, letterSpacing: 0.3)),
              ],
            ),
          ),
          if (request.reason.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text('"${request.reason}"',
                style: AppTextStyles.caption
                    .copyWith(fontStyle: FontStyle.italic),
                maxLines: 2,
                overflow: TextOverflow.ellipsis),
          ],
          if (isPending) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onReject,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.statusRed),
                      foregroundColor: AppColors.statusRed,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(AppSpacing.buttonRadius)),
                    ),
                    child: Text('Reject',
                        style: AppTextStyles.caption.copyWith(
                            color: AppColors.statusRed,
                            fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onApprove,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryNavy,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(AppSpacing.buttonRadius)),
                    ),
                    child: Text('Approve',
                        style: AppTextStyles.button.copyWith(fontSize: 13)),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
