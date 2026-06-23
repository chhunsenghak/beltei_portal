import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';

final _kAgenda = [
  (time: '08:30 AM', title: 'Advanced Algorithms & Complexity', room: 'Room 402', professor: 'Dr. Sarah Jenkins', type: 'Lecture'),
  (time: '10:30 AM', title: 'Database Management Systems', room: 'Lab 12', professor: 'Prof. Michael Chen', type: 'Lab'),
  (time: '01:30 PM', title: 'Software Engineering Principles', room: 'Auditorium B', professor: 'Dr. Elena Rodriguez', type: 'Lecture'),
];

class DailyAgendaScreen extends StatelessWidget {
  const DailyAgendaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      appBar: AppBar(
        backgroundColor: AppColors.bgPage,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 18),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('Daily Agenda', style: AppTextStyles.h3),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDateBanner(),
            const SizedBox(height: AppSpacing.sectionGap),
            ..._kAgenda.map((a) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _AgendaCard(
                    time: a.time,
                    title: a.title,
                    room: a.room,
                    professor: a.professor,
                    type: a.type,
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildDateBanner() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.primaryNavy,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
      ),
      child: Row(
        children: [
          const Icon(Icons.calendar_today, color: Colors.white, size: 20),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Monday', style: AppTextStyles.h2White),
              Text('February 19, 2024', style: AppTextStyles.captionWhite),
            ],
          ),
          const Spacer(),
          Text('3 Classes', style: AppTextStyles.bodyWhite),
        ],
      ),
    );
  }
}

class _AgendaCard extends StatelessWidget {
  const _AgendaCard({
    required this.time,
    required this.title,
    required this.room,
    required this.professor,
    required this.type,
  });

  final String time, title, room, professor, type;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: const Border(left: BorderSide(color: AppColors.primaryNavy, width: 3)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 4),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTimeChip(),
          const SizedBox(width: 12),
          Expanded(child: _buildDetails()),
        ],
      ),
    );
  }

  Widget _buildTimeChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.statusBlueBg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(time,
          style: AppTextStyles.caption.copyWith(
              color: AppColors.primaryBlue, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: Text(title, style: AppTextStyles.h3)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.statusGrayBg,
                borderRadius: BorderRadius.circular(AppSpacing.tagRadius),
              ),
              child: Text(type,
                  style: AppTextStyles.label.copyWith(color: AppColors.textSecondary)),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(children: [
          const Icon(Icons.door_back_door_outlined, size: 13, color: AppColors.textSecondary),
          const SizedBox(width: 4),
          Text(room, style: AppTextStyles.caption),
        ]),
        const SizedBox(height: 2),
        Row(children: [
          const Icon(Icons.person_outline, size: 13, color: AppColors.textSecondary),
          const SizedBox(width: 4),
          Text(professor, style: AppTextStyles.caption),
        ]),
      ],
    );
  }
}
