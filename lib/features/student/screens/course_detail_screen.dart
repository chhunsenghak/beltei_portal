import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';

// ── Mock data ──────────────────────────────────────────────────────────────────

const _kCourse = (
  title: 'Advanced Web Development',
  code: 'CS305',
  description:
      'This course focuses on advanced concepts in web development, including responsive design architectures, state management in modern frameworks, and serverless deployment strategies. Students will master full-stack integration and performance optimization techniques using current industry standards.',
  credits: '3.0 Academic Credits',
  semester: 'Year 3, Semester 1',
  professor: 'Dr. Sarah Jenkins',
  professorRole: 'Senior Lecturer in Computer Science',
);

final _kSchedule = [
  (day: 'Monday', time: '08:00 AM - 10:30 AM', room: 'Room 402'),
  (day: 'Thursday', time: '01:30 PM - 03:00 PM', room: 'Lab 12'),
];

const _kTabs = ['Overview', 'Attendance', 'Grades', 'Materials'];

// ── Screen ────────────────────────────────────────────────────────────────────

class CourseDetailScreen extends StatefulWidget {
  const CourseDetailScreen({super.key, required this.courseId});
  final String courseId;

  @override
  State<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _kTabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ── build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      appBar: _buildAppBar(context),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(),
          _buildComingSoonTab('Attendance'),
          _buildComingSoonTab('Grades'),
          _buildComingSoonTab('Materials'),
        ],
      ),
    );
  }

  // ── app bar ────────────────────────────────────────────────────────────────

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.bgPage,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, size: 18),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Text(
        _kCourse.title,
        style: AppTextStyles.h3.copyWith(color: AppColors.primaryNavy),
        overflow: TextOverflow.ellipsis,
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined),
          onPressed: () {},
        ),
      ],
      bottom: TabBar(
        controller: _tabController,
        isScrollable: true,
        tabAlignment: TabAlignment.start,
        labelStyle: AppTextStyles.bodySemiBold.copyWith(fontSize: 14),
        unselectedLabelStyle: AppTextStyles.body.copyWith(fontSize: 14),
        labelColor: AppColors.primaryNavy,
        unselectedLabelColor: AppColors.textSecondary,
        indicatorColor: AppColors.primaryNavy,
        indicatorWeight: 2.5,
        tabs: _kTabs.map((t) => Tab(text: t)).toList(),
      ),
    );
  }

  // ── overview tab ───────────────────────────────────────────────────────────

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDescriptionCard(),
          const SizedBox(height: 14),
          _buildInfoRow(Icons.school_outlined, 'Credits', _kCourse.credits),
          const SizedBox(height: 10),
          _buildInfoRow(Icons.calendar_today_outlined, 'Semester', _kCourse.semester),
          const SizedBox(height: 14),
          _buildTeacherCard(),
          const SizedBox(height: 14),
          _buildScheduleCard(),
        ],
      ),
    );
  }

  Widget _buildDescriptionCard() {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Course Description',
              style: AppTextStyles.h2.copyWith(color: AppColors.primaryNavy)),
          const SizedBox(height: 12),
          Text(_kCourse.description,
              style: AppTextStyles.body.copyWith(height: 1.6, color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return _Card(
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.statusBlueBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.primaryNavy, size: 20),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTextStyles.caption),
              Text(value, style: AppTextStyles.h3),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTeacherCard() {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Teacher',
              style: AppTextStyles.h2.copyWith(color: AppColors.primaryNavy)),
          const SizedBox(height: 14),
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: AppColors.statusGrayBg,
                child: const Icon(Icons.person, color: AppColors.textSecondary, size: 32),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_kCourse.professor, style: AppTextStyles.h3),
                  const SizedBox(height: 2),
                  Text(_kCourse.professorRole,
                      style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
                  const SizedBox(height: 6),
                  GestureDetector(
                    onTap: () {},
                    child: Row(
                      children: [
                        const Icon(Icons.email_outlined,
                            color: AppColors.primaryNavy, size: 16),
                        const SizedBox(width: 4),
                        Text('Contact', style: AppTextStyles.link),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleCard() {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Weekly Schedule',
              style: AppTextStyles.h2.copyWith(color: AppColors.primaryNavy)),
          const SizedBox(height: 14),
          ...List.generate(_kSchedule.length, (i) {
            final s = _kSchedule[i];
            final isLast = i == _kSchedule.length - 1;
            return Column(
              children: [
                _buildScheduleItem(s.day, s.time, s.room),
                if (!isLast) const Divider(color: AppColors.border, height: 20),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildScheduleItem(String day, String time, String room) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(day, style: AppTextStyles.bodyMedium),
              const SizedBox(height: 2),
              Text(time, style: AppTextStyles.caption),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.statusGrayBg,
            borderRadius: BorderRadius.circular(AppSpacing.tagRadius),
          ),
          child: Text(room, style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }

  // ── placeholder tab ────────────────────────────────────────────────────────

  Widget _buildComingSoonTab(String name) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.hourglass_empty, color: AppColors.textLabel, size: 48),
          const SizedBox(height: 12),
          Text('$name coming soon', style: AppTextStyles.body.copyWith(color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

// ── Shared card ────────────────────────────────────────────────────────────────

class _Card extends StatelessWidget {
  const _Card({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(color: AppColors.border),
      ),
      child: child,
    );
  }
}
