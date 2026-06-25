import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';

// ── Mock data ──────────────────────────────────────────────────────────────────

class _LeaveRequest {
  _LeaveRequest({
    required this.id,
    required this.initials,
    required this.name,
    required this.studentId,
    required this.course,
    required this.type,
    required this.dates,
    required this.status,
  });
  final String id, initials, name, studentId, course, type, dates;
  String status; // 'pending', 'approved', 'rejected'
}

final _kRequests = [
  _LeaveRequest(
    id: 'lr1',
    initials: 'ER',
    name: 'Elena Rodriguez',
    studentId: 'B24-88902',
    course: 'Business Ethics 301',
    type: 'Medical Leave',
    dates: 'Oct 12 – Oct 14, 2023',
    status: 'pending',
  ),
  _LeaveRequest(
    id: 'lr2',
    initials: 'JT',
    name: 'James K. Thompson',
    studentId: 'B24-88945',
    course: 'Intro to Psychology',
    type: 'Personal/Family',
    dates: 'Oct 15, 2023',
    status: 'pending',
  ),
  _LeaveRequest(
    id: 'lr3',
    initials: 'LN',
    name: 'Linh Nguyen',
    studentId: 'B24-88911',
    course: 'Advanced Calculus',
    type: 'Medical Leave',
    dates: 'Oct 18 – Oct 20, 2023',
    status: 'pending',
  ),
  _LeaveRequest(
    id: 'lr4',
    initials: 'MC',
    name: 'Marcus Chen',
    studentId: 'B24-88776',
    course: 'Digital Marketing',
    type: 'External Competition',
    dates: 'Oct 10 – Oct 12, 2023',
    status: 'approved',
  ),
];

// ── Screen ────────────────────────────────────────────────────────────────────

class LeaveManagementScreen extends StatefulWidget {
  const LeaveManagementScreen({super.key});

  @override
  State<LeaveManagementScreen> createState() => _LeaveManagementScreenState();
}

class _LeaveManagementScreenState extends State<LeaveManagementScreen> {
  String _filter = 'all';
  late final List<_LeaveRequest> _requests =
      _kRequests.map((r) => _LeaveRequest(
            id: r.id,
            initials: r.initials,
            name: r.name,
            studentId: r.studentId,
            course: r.course,
            type: r.type,
            dates: r.dates,
            status: r.status,
          )).toList();

  List<_LeaveRequest> get _filtered {
    if (_filter == 'all') return _requests;
    return _requests.where((r) => r.status == _filter).toList();
  }

  void _approve(String id) => setState(() {
        _requests.firstWhere((r) => r.id == id).status = 'approved';
      });

  void _reject(String id) => setState(() {
        _requests.firstWhere((r) => r.id == id).status = 'rejected';
      });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      body: Column(
        children: [
          _buildHeader(),
          _buildFilterChips(),
          Expanded(
            child: _filtered.isEmpty
                ? _buildEmpty()
                : ListView.separated(
                    padding:
                        const EdgeInsets.all(AppSpacing.screenPadding),
                    itemCount: _filtered.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (_, i) => _LeaveCard(
                          request: _filtered[i],
                          onApprove: () => _approve(_filtered[i].id),
                          onReject: () => _reject(_filtered[i].id),
                          onTap: () => context.push(
                              '/teacher/students/leave/${_filtered[i].id}'),
                        ),
                  ),
          ),
        ],
      ),
    );
  }

  // ── Header ─────────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Leave Requests', style: AppTextStyles.h1),
              Row(
                children: [
                  Text('Sort by: ',
                      style: AppTextStyles.caption),
                  Text('Newest First',
                      style: AppTextStyles.caption.copyWith(
                          color: AppColors.primaryBlue,
                          fontWeight: FontWeight.w600)),
                  const Icon(Icons.keyboard_arrow_down,
                      size: 16, color: AppColors.primaryBlue),
                ],
              ),
            ],
          ),
          Text('Manage and review student absence submissions.',
              style: AppTextStyles.caption),
        ],
      ),
    );
  }

  // ── Filter chips ───────────────────────────────────────────────────────────

  Widget _buildFilterChips() {
    final chips = [
      (value: 'all',      label: 'All Requests', dot: null),
      (value: 'pending',  label: 'Pending',       dot: AppColors.statusAmber),
      (value: 'approved', label: 'Approved',      dot: AppColors.statusGreen),
      (value: 'rejected', label: 'Rejected',      dot: AppColors.statusRed),
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
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isActive ? AppColors.primaryNavy : AppColors.bgCard,
                  borderRadius:
                      BorderRadius.circular(AppSpacing.chipRadius),
                  border: Border.all(
                    color: isActive
                        ? AppColors.primaryNavy
                        : AppColors.border,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (c.dot != null) ...[
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: isActive ? Colors.white : c.dot!,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                    ],
                    Text(c.label,
                        style: AppTextStyles.caption.copyWith(
                          color: isActive ? Colors.white : AppColors.textSecondary,
                          fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                        )),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.inbox_outlined,
              color: AppColors.textLabel, size: 48),
          const SizedBox(height: 12),
          Text('No requests found',
              style: AppTextStyles.body.copyWith(
                  color: AppColors.textSecondary)),
        ],
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
    required this.onTap,
  });

  final _LeaveRequest request;
  final VoidCallback onApprove, onReject, onTap;

  Color get _statusColor {
    switch (request.status) {
      case 'approved': return AppColors.statusGreen;
      case 'rejected': return AppColors.statusRed;
      default:         return AppColors.statusAmber;
    }
  }

  Color get _statusBg {
    switch (request.status) {
      case 'approved': return AppColors.statusGreenBg;
      case 'rejected': return AppColors.statusRedBg;
      default:         return AppColors.statusAmberBg;
    }
  }

  String get _statusLabel {
    switch (request.status) {
      case 'approved': return 'Approved';
      case 'rejected': return 'Rejected';
      default:         return 'Pending';
    }
  }

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
          _buildCardHeader(),
          const SizedBox(height: 12),
          _buildMeta(Icons.menu_book_outlined,
              'Course: ${request.course}'),
          const SizedBox(height: 4),
          _buildMeta(Icons.beach_access_outlined,
              'Type: ${request.type}'),
          const SizedBox(height: 4),
          _buildMeta(Icons.calendar_today_outlined,
              'Dates: ${request.dates}'),
          if (request.status == 'pending') ...[
            const SizedBox(height: 14),
            _buildActions(),
          ],
        ],
      ),
    );
  }

  Widget _buildCardHeader() {
    return Row(
      children: [
        CircleAvatar(
          radius: 22,
          backgroundColor: AppColors.primaryNavy.withValues(alpha: 0.1),
          child: Text(request.initials,
              style: AppTextStyles.caption.copyWith(
                  color: AppColors.primaryNavy,
                  fontWeight: FontWeight.w700)),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(request.name, style: AppTextStyles.bodyMedium),
              Text('ID: ${request.studentId}',
                  style: AppTextStyles.caption),
            ],
          ),
        ),
        Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: _statusBg,
            borderRadius: BorderRadius.circular(AppSpacing.chipRadius),
          ),
          child: Text(_statusLabel,
              style: AppTextStyles.label
                  .copyWith(color: _statusColor, letterSpacing: 0.4)),
        ),
      ],
    );
  }

  Widget _buildMeta(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 13, color: AppColors.textSecondary),
        const SizedBox(width: 6),
        Expanded(
          child: Text(text,
              style: AppTextStyles.body
                  .copyWith(color: AppColors.textSecondary)),
        ),
      ],
    );
  }

  Widget _buildActions() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: onApprove,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.statusGreen,
              padding: const EdgeInsets.symmetric(vertical: 10),
            ),
            child: Text('Approve', style: AppTextStyles.button),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: ElevatedButton(
            onPressed: onReject,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.statusRed,
              padding: const EdgeInsets.symmetric(vertical: 10),
            ),
            child: Text('Reject', style: AppTextStyles.button),
          ),
        ),
        const SizedBox(width: 10),
        GestureDetector(
          onTap: onTap,
          child: const Icon(Icons.arrow_forward_ios,
              size: 16, color: AppColors.primaryNavy),
        ),
      ],
    );
  }
}
