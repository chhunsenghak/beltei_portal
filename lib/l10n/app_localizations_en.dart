// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'BELTEI Portal';

  @override
  String get loginWelcome => 'Welcome to BELTEI\nPortal';

  @override
  String get loginEmailLabel => 'Email';

  @override
  String get loginEmailHint => 'Enter your email';

  @override
  String get loginPasswordLabel => 'Password';

  @override
  String get loginRememberMe => 'Remember Me';

  @override
  String get loginForgotPassword => 'Forgot Password?';

  @override
  String get loginButton => 'Login';

  @override
  String get loginNeedHelp => 'Need help? ';

  @override
  String get loginContactSupport => 'Contact Support';

  @override
  String get loginMissingFields => 'Please enter your email and password.';

  @override
  String get splashInitializing => 'INITIALIZING ACADEMIC PORTAL...';

  @override
  String get splashLoadingData => 'LOADING STUDENT DATA...';

  @override
  String get splashReady => 'READY';

  @override
  String get splashTagline =>
      'QUALITY · EFFICIENCY · EXCELLENCE · MORALITY · VIRTUE';

  @override
  String get adminAppBarTitle => 'BELTEI Admin';

  @override
  String get navDashboard => 'Dashboard';

  @override
  String get navUsers => 'Users';

  @override
  String get navAcademic => 'Academic';

  @override
  String get navFinance => 'Finance';

  @override
  String get navSettings => 'Settings';

  @override
  String get navHome => 'Home';

  @override
  String get navCourses => 'Courses';

  @override
  String get navStudents => 'Students';

  @override
  String get navAlerts => 'Alerts';

  @override
  String get navProfile => 'Profile';

  @override
  String get navSchedule => 'Schedule';

  @override
  String get logoutTitle => 'Logout';

  @override
  String get logoutConfirm => 'Are you sure you want to logout?';

  @override
  String get cancel => 'Cancel';

  @override
  String get settingsUniversityInfoTitle => 'University Information';

  @override
  String get settingsUniversityNameLabel => 'University Name';

  @override
  String get settingsContactEmailLabel => 'Contact Email';

  @override
  String get settingsUploadLogo => 'Upload Logo';

  @override
  String get settingsUploadLogoHint =>
      'Update the primary institutional logo. Recommended size: 512×512px.';

  @override
  String get settingsAcademicCycleTitle => 'Academic Cycle';

  @override
  String get settingsCurrentAcademicYear => 'Current Academic Year';

  @override
  String get settingsCurrentSemester => 'Current Semester';

  @override
  String get settingsManageInAcademic => 'Manage in Academic Management';

  @override
  String get settingsSemesterFormat => 'Semester Format';

  @override
  String get settingsSemester => 'Semester';

  @override
  String get settingsTrimester => 'Trimester';

  @override
  String get settingsGradingThresholdsTitle => 'Grading Thresholds';

  @override
  String get settingsNotConfigurable => 'Not yet configurable';

  @override
  String get settingsNotificationsTitle => 'Notification Channels';

  @override
  String get settingsPushNotifications => 'Push Notifications';

  @override
  String get settingsPushNotificationsSubtitle =>
      'Alert admins of urgent financial approvals.';

  @override
  String get settingsEmailDigests => 'Automated Email Digests';

  @override
  String get settingsEmailDigestsSubtitle =>
      'Weekly enrollment and attendance reports.';

  @override
  String get settingsAccessControlTitle => 'Role-Based Access Control';

  @override
  String get settingsAccessControlReadOnly =>
      'Read-only — access control management is not yet available.';

  @override
  String get settingsAppearanceTitle => 'Appearance';

  @override
  String get settingsThemeLight => 'Light';

  @override
  String get settingsThemeDark => 'Dark';

  @override
  String get settingsThemeSystem => 'System';

  @override
  String get settingsLanguageTitle => 'Language';

  @override
  String get settingsDiscardChanges => 'Discard Changes';

  @override
  String get settingsSaveSettings => 'Save Settings';

  @override
  String get settingsSaved => 'Settings saved.';

  @override
  String profileLoadError(Object error) {
    return 'Failed to load profile: $error';
  }

  @override
  String get profileNotFoundTitle => 'Profile Not Found';

  @override
  String get profileNotFoundMessage =>
      'Your student record could not be loaded. This may be a temporary issue or your account may not be fully set up yet.';

  @override
  String get profileTryAgain => 'Try Again';

  @override
  String get profileSignOut => 'Sign Out';

  @override
  String profileIdLabel(String code) {
    return 'ID: $code';
  }

  @override
  String get profileNa => 'N/A';

  @override
  String get profilePersonalInfoTitle => 'Personal Information';

  @override
  String get profileFullNameLabel => 'FULL NAME';

  @override
  String get profileDateOfBirthLabel => 'DATE OF BIRTH';

  @override
  String get profileGenderLabel => 'GENDER';

  @override
  String get profileNationalityLabel => 'NATIONALITY';

  @override
  String get profileAcademicInfoTitle => 'Academic Information';

  @override
  String get profileMajorLabel => 'MAJOR';

  @override
  String get profileYearLevelLabel => 'YEAR LEVEL';

  @override
  String profileYearLevelValue(int level) {
    return 'Year $level';
  }

  @override
  String get profileAcademicStatusLabel => 'ACADEMIC STATUS';

  @override
  String get profileGpaLabel => 'GPA';

  @override
  String profileGpaValue(String gpa) {
    return '$gpa / 4.00';
  }

  @override
  String get profileContactInfoTitle => 'Contact Information';

  @override
  String get profileEmergencyContactTitle => 'Emergency Contact';

  @override
  String get profileContactLabel => 'Contact';

  @override
  String get profileAccountSettingsTitle => 'Account Settings';

  @override
  String get profileChangePassword => 'Change Password';

  @override
  String get profileChangePasswordSubtitle => 'Update your account password';

  @override
  String get profileNotificationSettings => 'Notification Settings';

  @override
  String get profileNotificationSettingsSubtitle =>
      'Manage app alerts and emails';

  @override
  String get profileLanguageSettings => 'Language Settings';

  @override
  String get profileLanguageSettingsSubtitle =>
      'Choose your preferred language';

  @override
  String get profileChooseLanguage => 'Choose Language';

  @override
  String get profileLogout => 'Logout';

  @override
  String get statusActive => 'Active';

  @override
  String get statusInactive => 'Inactive';

  @override
  String get statusGraduated => 'Graduated';

  @override
  String get statusSuspended => 'Suspended';

  @override
  String get retry => 'Retry';

  @override
  String get loadErrorSchedule => 'Could not load schedule';

  @override
  String get loadErrorAttendance => 'Could not load attendance';

  @override
  String get loadErrorGrades => 'Could not load grades';

  @override
  String timeAgoMinutes(int minutes) {
    return '${minutes}m ago';
  }

  @override
  String timeAgoHours(int hours) {
    return '${hours}h ago';
  }

  @override
  String get timeAgoYesterday => 'Yesterday';

  @override
  String get statusPresent => 'Present';

  @override
  String get statusAbsent => 'Absent';

  @override
  String get statusLate => 'Late';

  @override
  String get statusExcused => 'Excused';

  @override
  String get statusCompleted => 'Completed';

  @override
  String get statusDropped => 'Dropped';

  @override
  String get statusEnrolled => 'Enrolled';

  @override
  String get noClassesToday => 'No classes today';

  @override
  String get scheduleNoTimeslotYet => 'No timeslot yet';

  @override
  String get dayMon => 'Mon';

  @override
  String get dayTue => 'Tue';

  @override
  String get dayWed => 'Wed';

  @override
  String get dayThu => 'Thu';

  @override
  String get dayFri => 'Fri';

  @override
  String get daySat => 'Sat';

  @override
  String get daySun => 'Sun';

  @override
  String get leaveSessionFullDay => 'Full Day';

  @override
  String leaveSessionNumbered(int n) {
    return 'Session $n';
  }

  @override
  String get dashboardQuickActionsTitle => 'Quick Actions';

  @override
  String get dashboardSeeAll => 'SEE ALL';

  @override
  String get dashboardActionAttendance => 'Attendance';

  @override
  String get dashboardActionLeave => 'Leave';

  @override
  String get dashboardActionCourses => 'Courses';

  @override
  String get dashboardActionGrades => 'Grades';

  @override
  String get dashboardAcademicSummaryTitle => 'Academic Summary';

  @override
  String get dashboardGpaCurrentLabel => 'GPA (Current)';

  @override
  String get dashboardCgpaLabel => 'CGPA';

  @override
  String get dashboardCreditsDoneLabel => 'Credits Done';

  @override
  String get dashboardThisSemesterLabel => 'This Semester';

  @override
  String dashboardCreditsUnit(int credits) {
    return '$credits cr';
  }

  @override
  String get dashboardAttendanceOverviewTitle => 'Attendance Overview';

  @override
  String get dashboardOverallRateLabel => 'Overall Rate';

  @override
  String get dashboardAttendanceLeaveLabel => 'Leave';

  @override
  String get dashboardFinancialSummaryTitle => 'Financial Summary';

  @override
  String get dashboardRecentActivitiesTitle => 'Recent Activities';

  @override
  String get dashboardActivitiesLoadError => 'Could not load activities.';

  @override
  String get dashboardNoRecentActivities => 'No recent activities.';

  @override
  String get dashboardViewAllNotifications => 'VIEW ALL NOTIFICATIONS';

  @override
  String get dashboardFinanceLoadError => 'Could not load finance data.';

  @override
  String get dashboardTotalSemesterFee => 'Total Semester Fee';

  @override
  String get dashboardPaidLabel => 'Paid';

  @override
  String get dashboardOutstandingLabel => 'Outstanding';

  @override
  String get dashboardDueDateReminder => 'DUE DATE REMINDER';

  @override
  String get dashboardPayNow => 'Pay Now';

  @override
  String get agendaAppBarTitle => 'Daily Agenda';

  @override
  String agendaClassCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Classes',
      one: '$count Class',
      zero: 'No Classes',
    );
    return '$_temp0';
  }

  @override
  String get agendaEmptySubtitle => 'Enjoy your free day!';

  @override
  String get scheduleWeeklyTitle => 'Weekly Schedule';

  @override
  String get scheduleLunchBreak => 'LUNCH BREAK';

  @override
  String get courseListFilterAll => 'All';

  @override
  String get courseListFilterCurrent => 'Current';

  @override
  String get courseListLoadError => 'Could not load courses';

  @override
  String get courseListEmptyState => 'No courses found.';

  @override
  String get courseListSearchHint => 'Search courses, professors, or codes...';

  @override
  String get courseListProfessorLabel => 'PROFESSOR';

  @override
  String get courseListSemesterLabel => 'SEMESTER';

  @override
  String get courseListCreditsLabel => 'CREDITS';

  @override
  String courseListCreditsUnitsValue(int credits) {
    return '$credits Units';
  }

  @override
  String get courseListStatusLabel => 'STATUS';

  @override
  String get courseListCourseCompletionLabel => 'Course Completion';

  @override
  String get courseListAttendanceRateLabel => 'Attendance Rate';

  @override
  String get courseDetailTabOverview => 'Overview';

  @override
  String get courseDetailTabAttendance => 'Attendance';

  @override
  String get courseDetailTabGrades => 'Grades';

  @override
  String get courseDetailTabMaterials => 'Materials';

  @override
  String get courseDetailFallbackTitle => 'Course Detail';

  @override
  String get courseDetailCreditsLabel => 'Credits';

  @override
  String courseDetailAcademicCreditsValue(int credits) {
    return '$credits Academic Credits';
  }

  @override
  String get courseDetailSemesterLabel => 'Semester';

  @override
  String get courseDetailCurrentChip => 'CURRENT';

  @override
  String get courseDetailEnrolledChip => 'ENROLLED';

  @override
  String get courseDetailInstructorTitle => 'Instructor';

  @override
  String get courseDetailContactLink => 'Contact';

  @override
  String get courseDetailAttendanceRateLabel => 'Attendance Rate';

  @override
  String courseDetailAttendanceBelowThreshold(int pct) {
    return '$pct% — Below 75% threshold';
  }

  @override
  String get courseDetailNoAttendanceRecords => 'No attendance records yet.';

  @override
  String get courseDetailSessionHistoryTitle => 'Session History';

  @override
  String get courseDetailAttendanceRateAllCaps => 'ATTENDANCE RATE';

  @override
  String get courseDetailBelowThresholdChip => 'Below 75%';

  @override
  String get courseDetailTotalLabel => 'Total';

  @override
  String get courseDetailNoGradesRecorded => 'No grades recorded yet.';

  @override
  String get courseDetailScoreBreakdownTitle => 'Score Breakdown';

  @override
  String get courseDetailMidtermLabel => 'Midterm';

  @override
  String get courseDetailAssignmentLabel => 'Assignment';

  @override
  String get courseDetailFinalExamLabel => 'Final Exam';

  @override
  String get courseDetailFinalGradeLabel => 'FINAL GRADE';

  @override
  String courseDetailGpaPointsValue(String points) {
    return '$points GPA Points';
  }

  @override
  String get courseDetailNotYetGraded => 'Not yet graded';

  @override
  String courseDetailGradeCreditsValue(int credits) {
    return '$credits Credits';
  }

  @override
  String get courseDetailMaterialsLoadError => 'Could not load materials';

  @override
  String get courseDetailNoMaterialsUploaded => 'No materials uploaded yet.';

  @override
  String get courseDetailMaterialsTitle => 'Course Materials';

  @override
  String courseDetailFilesCountValue(int count) {
    return '$count Files';
  }

  @override
  String get gradesStandingGood => 'GOOD STANDING';

  @override
  String get gradesStandingAtRisk => 'AT RISK';

  @override
  String get gradesPageTitle => 'Academic Performance';

  @override
  String gradesStudentIdLabel(String code) {
    return 'Student ID: $code';
  }

  @override
  String gradesStudentIdWithYearLabel(String code, int level) {
    return 'Student ID: $code • Year $level';
  }

  @override
  String get gradesOverviewTitle => 'Grade Overview';

  @override
  String get gradesGpaLabel => 'GPA';

  @override
  String get gradesCurrentTermLabel => 'Current Term';

  @override
  String get gradesCgpaLabel => 'CGPA';

  @override
  String get gradesCumulativeLabel => 'Cumulative';

  @override
  String get gradesDegreeProgressTitle => 'Degree Progress';

  @override
  String get gradesDegreeProgramSubtitle => 'Bachelor\'s Degree Program';

  @override
  String get gradesTotalCreditsLabel => 'Total Credits';

  @override
  String gradesCreditsProgressValue(int earned, int total) {
    return '$earned / $total';
  }

  @override
  String gradesProgressCompletedLabel(int pct) {
    return '$pct% completed';
  }

  @override
  String get gradesSemesterHistoryTitle => 'Semester History';

  @override
  String get gradesHonorsEligibilityTitle => 'Honors Eligibility';

  @override
  String get gradesHonorsOnTrackMessage =>
      'You are on track for the Dean\'s List! Maintain a CGPA above 3.50 for the upcoming graduation.';

  @override
  String get gradesHonorsNotOnTrackMessage =>
      'Maintain a CGPA above 3.50 to qualify for the Dean\'s List for the upcoming graduation.';

  @override
  String gradesCurrentCgpaCheckmark(String cgpa) {
    return 'Current CGPA: $cgpa ✓';
  }

  @override
  String gradesCurrentCgpaLabel(String cgpa) {
    return 'Current CGPA: $cgpa';
  }

  @override
  String get gradesSemesterNowLabel => 'NOW';

  @override
  String get gradesNoGradesYetLabel => 'No grades yet';

  @override
  String gradesSemesterGpaValue(String gpa) {
    return 'GPA $gpa';
  }

  @override
  String get semesterGradeDefaultTitle => 'Semester Grades';

  @override
  String get semesterGradeNotFound => 'Semester not found.';

  @override
  String get semesterGradeEnrolledCoursesTitle => 'Enrolled Courses';

  @override
  String get semesterGradeGpaLabel => 'SEMESTER GPA';

  @override
  String get semesterGradeDeansListQualification =>
      'Dean\'s List Qualification';

  @override
  String get semesterGradeCreditsEarnedLabel => 'Credits\nEarned';

  @override
  String semesterGradeCreditsRatio(int earned, int enrolled) {
    return '$earned / $enrolled';
  }

  @override
  String get semesterGradeNoGradesRecorded => 'No grades recorded yet.';

  @override
  String get semesterGradeKeyTitle => 'Grade Key';

  @override
  String get semesterGradeRangeA => '4.0 (90–100)';

  @override
  String get semesterGradeRangeB => '3.0 (80–89)';

  @override
  String get semesterGradeRangeC => '2.0 (70–79)';

  @override
  String get semesterGradeRangeF => '0.0 (below 60)';

  @override
  String get semesterGradeDegreeCompletionTitle => 'Degree Completion';

  @override
  String semesterGradePercentComplete(int percent) {
    return '$percent%';
  }

  @override
  String semesterGradeCreditsCompletedSummary(int earned, int required) {
    return '$earned of $required credits completed.';
  }

  @override
  String semesterGradeCreditsCount(int credits) {
    return '$credits Credits';
  }

  @override
  String get semesterGradeGradePointsLabel => 'GRADE POINTS';

  @override
  String get analyticsTitle => 'Academic Performance';

  @override
  String get analyticsSubtitle => 'Insights and progress tracking';

  @override
  String get analyticsCurrentCgpaLabel => 'CURRENT CGPA';

  @override
  String analyticsGpaDeltaLabel(String delta) {
    return '$delta vs last sem';
  }

  @override
  String get analyticsDegreeProgressTitle => 'Degree Progress';

  @override
  String analyticsPercentComplete(int percent) {
    return '$percent%';
  }

  @override
  String get analyticsDefaultDegreeName => 'Degree Program';

  @override
  String get analyticsEarnedLabel => 'Earned';

  @override
  String analyticsEarnedValue(int earned, int required) {
    return '$earned / $required';
  }

  @override
  String get analyticsRequiredLabel => 'Required';

  @override
  String analyticsRemainingCreditsValue(int remaining) {
    return '$remaining Credits';
  }

  @override
  String get analyticsStatusLabel => 'Status';

  @override
  String get analyticsStatusOnTrack => 'On Track';

  @override
  String get analyticsStatusInProgress => 'In Progress';

  @override
  String get analyticsGpaTrendTitle => 'GPA Trend Analysis';

  @override
  String get analyticsLegendTermGpa => 'Term GPA';

  @override
  String get analyticsLegendCgpa => 'CGPA';

  @override
  String get analyticsSemesterComparisonTitle => 'Semester Comparison';

  @override
  String get analyticsSemesterComparisonSubtitle => 'GPA per semester';

  @override
  String get analyticsCurrentCoursesTitle => 'Current Semester Courses';

  @override
  String get analyticsNoCoursesMessage => 'No courses enrolled this semester.';

  @override
  String get analyticsCourseNameHeader => 'COURSE NAME';

  @override
  String get analyticsCourseCodeHeader => 'CODE';

  @override
  String get attendanceDashboardTitle => 'Attendance Overview';

  @override
  String get attendanceDashboardSubtitle =>
      'All recorded attendance across your enrolled courses';

  @override
  String get attendanceDashboardTotalDaysLabel => 'TOTAL DAYS';

  @override
  String get attendanceDashboardLeaveLabel => 'LEAVE';

  @override
  String get attendanceDashboardRateTitle => 'Attendance Rate';

  @override
  String get attendanceDashboardCurrentRateLabel => 'Current Rate';

  @override
  String get attendanceDashboardLowAttendanceWarning =>
      'Attendance below 75%. Risk of academic penalty.';

  @override
  String get attendanceDashboardCourseBreakdownTitle => 'Course Breakdown';

  @override
  String get attendanceDashboardRecentLogsTitle => 'Recent Attendance Logs';

  @override
  String get attendanceDashboardViewFullHistory => 'View Full History';

  @override
  String get attendanceDashboardNoRecords => 'No attendance records yet.';

  @override
  String get attendanceDashboardDateColumn => 'DATE';

  @override
  String get attendanceDashboardCourseColumn => 'COURSE';

  @override
  String get attendanceDashboardStatusColumn => 'STATUS';

  @override
  String get attendanceHistoryOverallRateLabel => 'Attendance';

  @override
  String get attendanceHistoryCalendarTitle => 'Attendance History';

  @override
  String get attendanceHistoryNoRecordForDay => 'No attendance recorded';

  @override
  String get attendanceHistoryExcusedAbsenceLabel => 'Excused Absence';

  @override
  String get attendanceHistoryNoRecordLegendLabel => 'No Record';

  @override
  String get leaveDashboardNewRequestButton => 'New Request';

  @override
  String get leaveDashboardLoadError => 'Could not load leave requests';

  @override
  String get leaveDashboardEmptyState => 'No leave requests yet.';

  @override
  String get leaveDashboardTitle => 'Leave Requests';

  @override
  String get leaveDashboardSubtitle =>
      'Manage and track your absence applications.';

  @override
  String get leaveDashboardStatusPending => 'Pending';

  @override
  String get leaveDashboardStatusApproved => 'Approved';

  @override
  String get leaveDashboardStatusRejected => 'Rejected';

  @override
  String get leaveDetailAppBarTitle => 'Leave Detail';

  @override
  String get leaveDetailLoadError => 'Could not load request';

  @override
  String get leaveDetailNotFound => 'Request not found.';

  @override
  String get leaveDetailStatusApproved => 'APPROVED';

  @override
  String get leaveDetailStatusRejected => 'REJECTED';

  @override
  String get leaveDetailStatusPending => 'PENDING';

  @override
  String leaveDetailSubmittedOn(String date) {
    return 'Submitted $date';
  }

  @override
  String get leaveDetailTimelineSubmitted => 'Submitted';

  @override
  String get leaveDetailTimelineUnderReview => 'Under Review';

  @override
  String get leaveDetailTimelineAcademicOffice => 'Academic Office';

  @override
  String get leaveDetailTimelineDecision => 'Decision';

  @override
  String get leaveDetailTimelineTitle => 'Request Timeline';

  @override
  String get leaveDetailRequestInfoTitle => 'Request Information';

  @override
  String get leaveDetailLeaveTypeLabel => 'LEAVE TYPE';

  @override
  String get leaveDetailSessionLabel => 'SESSION';

  @override
  String get leaveDetailDatesLabel => 'DATES';

  @override
  String get leaveDetailTotalDaysLabel => 'TOTAL DAYS';

  @override
  String leaveDetailTotalDaysValue(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days',
      one: '$count day',
    );
    return '$_temp0';
  }

  @override
  String get leaveDetailReasonLabel => 'REASON FOR REQUEST';

  @override
  String get leaveDetailReviewerNotesTitle => 'Reviewer Notes';

  @override
  String leaveDetailReviewNotesQuoted(String notes) {
    return '\"$notes\"';
  }

  @override
  String leaveDetailReviewedOn(String date) {
    return 'Reviewed on $date';
  }

  @override
  String get leaveDetailWithdrawButtonLabel => 'Withdraw Request';

  @override
  String get leaveDetailWithdrawDialogTitle => 'Withdraw Request';

  @override
  String get leaveDetailWithdrawConfirmMessage =>
      'Are you sure you want to withdraw this leave request? This cannot be undone.';

  @override
  String get leaveDetailWithdrawDialogConfirm => 'Withdraw';

  @override
  String leaveDetailWithdrawError(Object error) {
    return 'Failed to withdraw: $error';
  }

  @override
  String get createLeaveValidationRequiredFields =>
      'Please fill in all required fields.';

  @override
  String get createLeaveSessionExpiredError =>
      'Session expired. Please log in again.';

  @override
  String get createLeaveSubmitError =>
      'Failed to submit request. Please try again.';

  @override
  String get createLeaveAppBarTitle => 'New Leave Request';

  @override
  String get createLeavePolicyBannerTitle => 'Academic Policy';

  @override
  String get createLeavePolicyBannerMessage =>
      'Submit leave requests at least 24 hours in advance, except for medical emergencies.';

  @override
  String get createLeaveTypeSectionLabel => 'LEAVE TYPE';

  @override
  String get createLeaveTypeMedical => 'Medical';

  @override
  String get createLeaveTypePersonal => 'Personal';

  @override
  String get createLeaveTypeFamily => 'Family';

  @override
  String get createLeaveTypeOther => 'Other';

  @override
  String get createLeaveSessionSectionLabel => 'SESSION';

  @override
  String get createLeaveStartDateLabel => 'START DATE';

  @override
  String get createLeaveEndDateLabel => 'END DATE';

  @override
  String get createLeaveDatePlaceholder => 'dd/mm/yyyy';

  @override
  String createLeaveDurationChipLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days',
      one: '$count day',
    );
    return 'Duration: $_temp0';
  }

  @override
  String get createLeaveReasonSectionLabel => 'REASON FOR LEAVE';

  @override
  String get createLeaveReasonHint =>
      'Briefly describe why you are requesting leave...';

  @override
  String createLeaveCharCount(int count) {
    return '$count chars';
  }

  @override
  String get createLeaveAttachmentsSectionLabel => 'ATTACHMENTS (OPTIONAL)';

  @override
  String get createLeaveAttachmentsHint =>
      'Tap to upload medical certificates or letters';

  @override
  String get createLeaveSubmittingButton => 'Submitting...';

  @override
  String get createLeaveSubmitButton => 'Submit Request';

  @override
  String get createLeaveSuccessTitle => 'Request Submitted!';

  @override
  String createLeaveSuccessMessage(String type) {
    return 'Your $type leave request has been submitted and is pending review.';
  }

  @override
  String get createLeaveBackToListButton => 'Back to Leave Requests';

  @override
  String get createLeaveSummaryTypeLabel => 'Type';

  @override
  String createLeaveSummaryTypeValue(String type) {
    return '$type Leave';
  }

  @override
  String get createLeaveSummaryPeriodLabel => 'Period';

  @override
  String get createLeaveSummaryDurationLabel => 'Duration';

  @override
  String createLeaveSummaryDurationValue(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days',
      one: '$count day',
    );
    return '$_temp0';
  }

  @override
  String get createLeaveSummaryStatusLabel => 'Status';

  @override
  String get createLeaveSummaryStatusValue => 'Pending Review';

  @override
  String get createLeaveNoClassOnDateError =>
      'No class is scheduled on the selected date. Please choose a day you attend class.';

  @override
  String get createLeaveAffectedCoursesLabel => 'COURSE(S) AFFECTED';

  @override
  String get createLeaveSummaryCoursesLabel => 'Course(s)';

  @override
  String get createLeaveSummarySessionLabel => 'Session';

  @override
  String get financePayNowButton => 'PAY NOW';

  @override
  String get financeLoadError => 'Could not load finance data';

  @override
  String get financeOverviewTitle => 'Finance Overview';

  @override
  String get financeOverviewSubtitle =>
      'Manage your tuition fees and payment history.';

  @override
  String get financeTotalFeeLabel => 'TOTAL FEE';

  @override
  String get financeTotalFeeSub => 'Total across all invoices';

  @override
  String get financeTotalPaidLabel => 'TOTAL PAID';

  @override
  String financeTotalPaidSub(String percent) {
    return '$percent% of total completed';
  }

  @override
  String get financeOutstandingLabel => 'OUTSTANDING';

  @override
  String get financeActionRequired => 'Action required';

  @override
  String get financeAllFeesCleared => 'All fees cleared';

  @override
  String get financeNextDueDateLabel => 'NEXT DUE DATE';

  @override
  String get financeNoPendingFees => 'No pending fees';

  @override
  String get financePaymentProgressTitle => 'Payment Progress';

  @override
  String financePaidLegend(String amount) {
    return 'Paid: $amount';
  }

  @override
  String financeRemainingLegend(String amount) {
    return 'Remaining: $amount';
  }

  @override
  String get financePaymentHistoryTitle => 'Payment History';

  @override
  String get financeNoInvoicesFound => 'No invoices found.';

  @override
  String get financeTableHeaderDescription => 'DESCRIPTION';

  @override
  String get financeTableHeaderDueDate => 'DUE DATE';

  @override
  String get financeTableHeaderStatus => 'STATUS';

  @override
  String get financeStatusPaid => 'Paid';

  @override
  String get financeStatusOverdue => 'Overdue';

  @override
  String get financeStatusPartial => 'Partial';

  @override
  String get financeStatusUnpaid => 'Unpaid';

  @override
  String get invoiceDetailTitle => 'Invoice Detail';

  @override
  String invoiceLoadError(Object error) {
    return 'Failed to load invoice: $error';
  }

  @override
  String get invoiceNotFound => 'Invoice not found.';

  @override
  String get invoiceStatusPaid => 'PAID';

  @override
  String get invoiceStatusOverdue => 'OVERDUE';

  @override
  String get invoiceStatusPartial => 'PARTIAL';

  @override
  String get invoiceStatusUnpaid => 'UNPAID';

  @override
  String get invoiceLabelBadge => 'INVOICE';

  @override
  String invoiceNumberLabel(String id) {
    return '#$id';
  }

  @override
  String invoiceDueLabel(String date) {
    return 'Due: $date';
  }

  @override
  String get invoicePaymentDetailsTitle => 'Payment Details';

  @override
  String get invoiceDescriptionRowLabel => 'Description';

  @override
  String get invoiceDueDateRowLabel => 'Due Date';

  @override
  String get invoicePaidOnRowLabel => 'Paid On';

  @override
  String get invoicePastDueWarning => 'This invoice is past due.';

  @override
  String get invoiceTotalAmountLabel => 'Total Amount';

  @override
  String get paymentMethodAbaBank => 'ABA Bank';

  @override
  String get paymentMethodWing => 'Wing';

  @override
  String get paymentMethodPiPay => 'Pi Pay';

  @override
  String get paymentAmountRequired => 'Please enter a payment amount.';

  @override
  String get paymentAppBarTitle => 'Online Payment';

  @override
  String get paymentNoOutstandingBalance => 'No Outstanding Balance';

  @override
  String get paymentOutstandingBalance => 'Outstanding Balance';

  @override
  String get paymentMethodSectionLabel => 'PAYMENT METHOD';

  @override
  String get paymentAmountSectionLabel => 'AMOUNT (USD)';

  @override
  String get paymentOrderSummaryLabel => 'ORDER SUMMARY';

  @override
  String get paymentStudentLabel => 'Student';

  @override
  String get paymentStudentIdLabel => 'Student ID';

  @override
  String get paymentMethodLabel => 'Method';

  @override
  String get paymentAmountLabel => 'Amount';

  @override
  String get paymentProceedButton => 'Proceed to Pay';

  @override
  String get paymentProcessingTitle => 'Processing Payment...';

  @override
  String get paymentProcessingSubtitle => 'Please do not close this screen.';

  @override
  String get paymentSuccessTitle => 'Payment Successful!';

  @override
  String get paymentSuccessSubtitle =>
      'Your payment has been processed successfully.';

  @override
  String get paymentBackToFinanceButton => 'Back to Finance';

  @override
  String get paymentReceiptNumberLabel => 'Receipt No.';

  @override
  String get paymentAmountPaidLabel => 'Amount Paid';

  @override
  String get paymentStatusLabel => 'Status';

  @override
  String get paymentStatusPaidValue => 'PAID';

  @override
  String get paymentConfirmDialogTitle => 'Confirm Payment';

  @override
  String get paymentConfirmDialogBody =>
      'You are about to make the following payment:';

  @override
  String get paymentConfirmButton => 'Confirm & Pay';

  @override
  String get notificationsFilterAll => 'All';

  @override
  String get notificationsFilterGrades => 'Grades';

  @override
  String get notificationsFilterAttendance => 'Attendance';

  @override
  String get notificationsFilterPayment => 'Payment';

  @override
  String get notificationsFilterLeave => 'Leave';

  @override
  String get notificationsLoadError => 'Could not load notifications';

  @override
  String get notificationsEmptyState => 'No notifications here.';

  @override
  String studentsCountLabel(int count) {
    return '$count Students';
  }

  @override
  String get done => 'Done';

  @override
  String get loadErrorStudents => 'Could not load students';

  @override
  String teacherDashboardDeptLabel(String dept) {
    return 'Dept: $dept';
  }

  @override
  String get teacherDashboardDefaultPosition => 'Teacher';

  @override
  String get teacherDashboardStatTotalCourses => 'Total Courses';

  @override
  String get teacherDashboardStatTotalStudents => 'Total Students';

  @override
  String get teacherDashboardStatPendingLeaves => 'Pending Leaves';

  @override
  String get teacherDashboardStatTodayClasses => 'Today\'s Classes';

  @override
  String get teacherDashboardQuickActionMarkAttendance => 'Mark\nAttendance';

  @override
  String get teacherDashboardQuickActionAssignments => 'Assignments';

  @override
  String get teacherDashboardQuickActionMaterials => 'Materials';

  @override
  String get teacherDashboardQuickActionReports => 'Reports';

  @override
  String get teacherDashboardQuickActionAnnouncements => 'Announcements';

  @override
  String get teacherDashboardTodayScheduleTitle => 'Today\'s Schedule';

  @override
  String get teacherDashboardFullScheduleLink => 'Full Schedule';

  @override
  String get teacherDashboardNoClassesScheduledToday =>
      'No classes scheduled today';

  @override
  String get teacherDashboardStatusNext => 'NEXT';

  @override
  String get teacherDashboardStatusLater => 'LATER';

  @override
  String get teacherDashboardStatusNow => 'NOW';

  @override
  String get teacherDashboardPendingLeaveRequestsTitle =>
      'Pending Leave Requests';

  @override
  String get teacherDashboardViewAllLink => 'View All';

  @override
  String get teacherDashboardNoPendingRequests => 'No pending requests';

  @override
  String get teacherProfileLoadError => 'Could not load profile';

  @override
  String get teacherProfileNotFound => 'Profile not found.';

  @override
  String get teacherProfileStatActiveCourses => 'ACTIVE\nCOURSES';

  @override
  String get teacherProfileStatStudents => 'STUDENTS';

  @override
  String get teacherProfileStatCreditsPerSem => 'CREDITS\n/ SEM';

  @override
  String get teacherProfileStatStatus => 'STATUS';

  @override
  String get teacherProfileTeachingInfoTitle => 'Teaching Information';

  @override
  String get teacherProfileNoActiveCourses => 'No active courses assigned.';

  @override
  String teacherProfileStudentsCountLabel(int count) {
    return '$count\nStudents';
  }

  @override
  String get teacherProfileProfessionalInfoTitle => 'Professional Information';

  @override
  String get teacherProfileEmployeeIdLabel => 'EMPLOYEE ID';

  @override
  String get teacherProfilePositionLabel => 'POSITION';

  @override
  String get teacherProfileSpecializationLabel => 'SPECIALIZATION';

  @override
  String get teacherProfileHireDateLabel => 'HIRE DATE';

  @override
  String get teacherProfileNotSpecified => 'Not specified';

  @override
  String get teacherProfileDepartmentNotSet => 'Department not set';

  @override
  String get teacherScheduleTitle => 'Academic Weekly Schedule';

  @override
  String get teacherScheduleNoClassesThisSemester =>
      'No scheduled classes this semester.';

  @override
  String get teacherScheduleNoScheduleData => 'No schedule data available.';

  @override
  String get teacherScheduleTimeColumnHeader => 'TIME';

  @override
  String get teacherScheduleWeeklyHoursLabel => 'WEEKLY HOURS';

  @override
  String teacherScheduleHoursValue(String hours) {
    return '$hours Hours';
  }

  @override
  String get teacherScheduleTotalStudentsLabel => 'TOTAL STUDENTS';

  @override
  String get teacherScheduleClassesTodayLabel => 'CLASSES TODAY';

  @override
  String teacherScheduleClassesCountValue(int count) {
    return '$count Classes';
  }

  @override
  String get teacherCourseListTitle => 'My Courses';

  @override
  String get teacherCourseListSubtitle => 'Manage your assigned courses.';

  @override
  String teacherCourseListSubtitleWithSemester(String semester) {
    return 'Manage your assigned courses for $semester.';
  }

  @override
  String get teacherCourseListEmptyState => 'No courses assigned yet.';

  @override
  String teacherCourseListStudentsEnrolled(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Students Enrolled',
      one: '$count Student Enrolled',
    );
    return '$_temp0';
  }

  @override
  String get teacherCourseListFilterPast => 'Past';

  @override
  String get teacherCourseListSearchHint => 'Search courses or codes...';

  @override
  String get teacherAnalyticsNoCurrentCourses => 'No current courses';

  @override
  String get teacherAnalyticsSelectCourse => 'Select a course';

  @override
  String teacherAnalyticsCourseNameWithCode(String name, String code) {
    return '$name ($code)';
  }

  @override
  String get teacherAnalyticsLoadError => 'Could not load analytics';

  @override
  String get teacherAnalyticsTitle => 'Student Analytics';

  @override
  String get teacherAnalyticsSubtitle =>
      'Performance overview for enrolled students.';

  @override
  String get teacherAnalyticsPerformanceRankingTitle =>
      'Student Performance\nRanking';

  @override
  String get teacherAnalyticsNoGradeData => 'No grade data yet.';

  @override
  String get teacherAnalyticsGradeDistributionTitle => 'Grade Distribution';

  @override
  String teacherAnalyticsGradeLegendLabel(String grade, int percent) {
    return '$grade ($percent%)';
  }

  @override
  String get teacherAnalyticsAttendanceTrendsTitle => 'Attendance Trends';

  @override
  String get teacherAnalyticsAveragePercentLegend => 'Average %';

  @override
  String get teacherAnalyticsAtRiskStudentsTitle => 'At-Risk Students';

  @override
  String get teacherAnalyticsAllStudentsAboveThreshold =>
      'All students are above the 75% threshold.';

  @override
  String get teacherAnalyticsSendAlertButton => 'Send Alert to Guardians';

  @override
  String teacherAnalyticsAttendancePercentLabel(int pct) {
    return 'Attendance: $pct%';
  }

  @override
  String markAttendanceUnmarkedWarning(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count students still unmarked.',
      one: '$count student still unmarked.',
    );
    return '$_temp0';
  }

  @override
  String get markAttendanceSaveFailedError => 'Failed to save attendance.';

  @override
  String get markAttendanceEmptyState => 'No students enrolled.';

  @override
  String get markAttendanceFallbackTitle => 'Attendance';

  @override
  String get markAttendanceTodaySession => 'Today\'s Session';

  @override
  String get markAttendanceInProgressLabel => 'IN PROGRESS';

  @override
  String get markAttendanceStudentsListLabel => 'Students\nList';

  @override
  String markAttendanceTotalCountBadge(int count) {
    return '$count\nTOTAL';
  }

  @override
  String get markAttendanceSelectAllPresent => 'Select All\nPresent';

  @override
  String get markAttendanceClearAll => 'Clear\nAll';

  @override
  String get markAttendanceSavingButton => 'Saving...';

  @override
  String markAttendanceSaveButtonLabel(int marked, int total) {
    return 'Save Attendance ($marked/$total)';
  }

  @override
  String get markAttendanceSavedTitle => 'Attendance Saved!';

  @override
  String get markAttendanceSessionRecordedFallback => 'Session recorded';

  @override
  String get markAttendanceLeaveExcusedLabel => 'Leave / Excused';

  @override
  String markAttendanceStudentsCountLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count students',
      one: '$count student',
    );
    return '$_temp0';
  }

  @override
  String get markAttendanceStatusLeave => 'Leave';

  @override
  String get editAttendanceUpdatedMessage => 'Attendance updated.';

  @override
  String editAttendanceSaveFailedError(Object error) {
    return 'Save failed: $error';
  }

  @override
  String get editAttendanceAppBarTitle => 'Edit Attendance';

  @override
  String get editAttendanceLoadingCourseName => 'Loading…';

  @override
  String get editAttendanceUpdateButton => 'Update Attendance';

  @override
  String get editAttendanceChangedBadge => 'CHANGED';

  @override
  String get editAttendanceViewOnlyBanner =>
      'This is a past session. Attendance can only be edited on the day it was taken.';

  @override
  String get attendanceReportLoadError => 'Could not load report';

  @override
  String get attendanceReportTitle => 'Attendance Report';

  @override
  String get attendanceReportSubtitle =>
      'Analyze student participation and attendance patterns.';

  @override
  String get attendanceReportExportButton => 'Export Report';

  @override
  String get attendanceReportTotalSessionsLabel => 'TOTAL SESSIONS';

  @override
  String attendanceReportSessionsValue(int count) {
    return '$count Sessions';
  }

  @override
  String get attendanceReportPresentAvgLabel => 'PRESENT AVG';

  @override
  String get attendanceReportAbsentAvgLabel => 'ABSENT AVG';

  @override
  String get attendanceReportStudentRecordsTitle => 'Student Records';

  @override
  String get attendanceReportNoDataMessage => 'No attendance data yet.';

  @override
  String attendanceReportShowingAllLabel(int count) {
    return 'Showing all $count students';
  }

  @override
  String get attendanceReportStudentNameHeader => 'STUDENT\nNAME';

  @override
  String get attendanceReportPresentHeader => 'PRESENT';

  @override
  String get attendanceReportAbsentHeader => 'ABSENT';

  @override
  String get gradeManagementTitle => 'Grade Management';

  @override
  String get gradeManagementLoadingCourse => 'Loading course...';

  @override
  String get gradeManagementEmptyState =>
      'No students enrolled in this course.';

  @override
  String get gradeManagementSaveSuccess => 'Grades saved successfully.';

  @override
  String gradeManagementSaveError(Object error) {
    return 'Failed to save grades: $error';
  }

  @override
  String get gradeManagementSaving => 'Saving…';

  @override
  String get gradeManagementSaveButton => 'Save Grades';

  @override
  String get gradeManagementParticipationLabel => 'Participation';

  @override
  String gradeManagementStudentsEnrolledCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Students Enrolled',
      one: '$count Student Enrolled',
    );
    return '$_temp0';
  }

  @override
  String get gradeManagementMaxScoreLabel => '/ 100';

  @override
  String get createAssessmentTitle => 'Create Assessment';

  @override
  String get createAssessmentValidationError =>
      'Please fill in Title, Type and Max Score.';

  @override
  String get createAssessmentBreadcrumbNew => 'New Assessment';

  @override
  String get createAssessmentTitleFieldLabel => 'Assessment Title';

  @override
  String get createAssessmentTitleHint => 'e.g. Mid-term Research Paper';

  @override
  String get createAssessmentTypeFieldLabel => 'Type';

  @override
  String get createAssessmentMaxScoreFieldLabel => 'Max Score';

  @override
  String get createAssessmentDueDateFieldLabel => 'Due Date & Time';

  @override
  String get createAssessmentDueDatePlaceholder => 'mm/dd/yyyy, --:-- --';

  @override
  String get createAssessmentDescriptionFieldLabel => 'Description';

  @override
  String get createAssessmentDescriptionHint =>
      'Provide detailed instructions for the students...';

  @override
  String get createAssessmentAttachmentsFieldLabel => 'Attachments';

  @override
  String get createAssessmentSelectTypeHint => 'Select assessment type';

  @override
  String get createAssessmentTypeQuiz => 'Quiz';

  @override
  String get createAssessmentTypeLabReport => 'Lab Report';

  @override
  String get createAssessmentTypeProject => 'Project';

  @override
  String get createAssessmentUploadZoneTitle =>
      'Click or drag and drop to upload files';

  @override
  String get createAssessmentUploadZoneSubtitle => 'PDF, DOCX, ZIP (Max 50MB)';

  @override
  String get createAssessmentQuickTipTitle => 'Quick Tip';

  @override
  String get createAssessmentQuickTipBody =>
      'Scheduled assessments will automatically alert all enrolled students via push notifications.';

  @override
  String get createAssessmentVisibilityTitle => 'Visibility';

  @override
  String get createAssessmentVisibilityBody =>
      'This assessment will be saved as a draft and hidden until you toggle \'Publish\'.';

  @override
  String get createAssessmentSuccessTitle => 'Assessment Created!';

  @override
  String createAssessmentSuccessMessage(String title) {
    return '\"$title\" has been saved as a draft. Students will be notified when published.';
  }

  @override
  String get createAssessmentBackToCourseButton => 'Back to Course';

  @override
  String get leaveManagementSubtitle =>
      'Student absence submissions for your courses.';

  @override
  String get leaveManagementViewOnlyBadge => 'View Only';

  @override
  String get leaveManagementFilterAll => 'All Requests';

  @override
  String get leaveManagementEmptyState => 'No requests found';

  @override
  String leaveManagementTypeLabel(String type) {
    return 'Type: $type';
  }

  @override
  String leaveManagementDatesLabel(String range) {
    return 'Dates: $range';
  }

  @override
  String get leaveManagementViewDetailsButton => 'View Details';

  @override
  String get leaveReviewAppBarTitle => 'Leave Request Details';

  @override
  String get leaveReviewApproveDialogTitle => 'Approve Leave Request';

  @override
  String get leaveReviewRejectDialogTitle => 'Reject Leave Request';

  @override
  String get leaveReviewNotesHint => 'Optional reviewer notes...';

  @override
  String get leaveReviewApproveButton => 'Approve';

  @override
  String get leaveReviewRejectButton => 'Reject';

  @override
  String get leaveReviewApprovedSnackbar => 'Leave request approved.';

  @override
  String get leaveReviewRejectedSnackbar => 'Leave request rejected.';

  @override
  String get leaveReviewSubmitError =>
      'Failed to submit decision. Please try again.';

  @override
  String get leaveReviewAttendanceSummaryTitle => 'Attendance Summary';

  @override
  String get leaveReviewTotalRecordsLabel => 'Total Records (Sem)';

  @override
  String leaveReviewSessionsCountValue(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Sessions',
      one: '$count Session',
    );
    return '$_temp0';
  }

  @override
  String get leaveReviewCategoryLabel => 'LEAVE CATEGORY';

  @override
  String get leaveReviewSessionLabel => 'SESSION';

  @override
  String get leaveReviewSubmittedLabel => 'SUBMITTED';

  @override
  String leaveReviewDaysCountValue(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Days',
      one: '$count Day',
    );
    return '$_temp0';
  }

  @override
  String get leaveReviewReasonTitle => 'Reason';

  @override
  String leaveReviewReasonQuoted(String reason) {
    return '\"$reason\"';
  }

  @override
  String get leaveReviewAttachmentTitle => 'Attachment';

  @override
  String get leaveReviewDecisionTitle => 'Decision';

  @override
  String get leaveReviewAwaitingReviewText => 'Awaiting admin review.';

  @override
  String get leaveReviewViewOnlyBanner =>
      'Only administrators can approve or reject student leave requests.';

  @override
  String get leaveReviewReviewerNotesLabel => 'REVIEWER NOTES';

  @override
  String get createAnnouncementValidationError =>
      'Please fill in the title and content.';

  @override
  String get createAnnouncementPostError => 'Failed to post announcement.';

  @override
  String get createAnnouncementDraftSavedSnackbar => 'Saved as draft.';

  @override
  String get createAnnouncementTitle => 'Create Announcement';

  @override
  String get createAnnouncementSubtitle =>
      'Broadcast information to students and faculty members.';

  @override
  String get createAnnouncementTitleFieldLabel => 'ANNOUNCEMENT TITLE';

  @override
  String get createAnnouncementTitleHint =>
      'e.g., Upcoming Midterm Examination Schedule';

  @override
  String get createAnnouncementContentLabel => 'CONTENT';

  @override
  String get createAnnouncementContentHint =>
      'Write your announcement details here...';

  @override
  String get createAnnouncementAttachFilesButton => 'Attach Files';

  @override
  String get createAnnouncementScheduleButton => 'Schedule';

  @override
  String get createAnnouncementPublicationSettingsTitle =>
      'Publication Settings';

  @override
  String get createAnnouncementRecipientScopeLabel => 'RECIPIENT SCOPE';

  @override
  String get createAnnouncementSendEmailLabel => 'Send Email Notification';

  @override
  String get createAnnouncementPushNotifLabel => 'Push Notification (App)';

  @override
  String get createAnnouncementAllStudentsChip => 'All Students';

  @override
  String get createAnnouncementSpecificCourseChip => 'Specific Course';

  @override
  String get createAnnouncementLivePreviewTitle => 'Live Preview';

  @override
  String get createAnnouncementLivePreviewSubtitle =>
      'See how your announcement will appear to the selected audience.';

  @override
  String get createAnnouncementPreviewAsStudentButton => 'Preview as Student';

  @override
  String get createAnnouncementPostButton => 'Post Announcement';

  @override
  String get createAnnouncementSaveDraftButton => 'Save as Draft';

  @override
  String get createAnnouncementSuccessTitle => 'Announcement Posted!';

  @override
  String createAnnouncementSuccessMessage(String title) {
    return '\"$title\" has been posted successfully.';
  }

  @override
  String get uploadMaterialsValidationError => 'Please enter a material title.';

  @override
  String uploadMaterialsFilePlaceholderSnackbar(String title) {
    return '\"$title\" — select a file to upload.';
  }

  @override
  String get uploadMaterialsDropzoneText => 'Drag and drop or tap to upload';

  @override
  String get uploadMaterialsSupportedFormatsText =>
      'Supported formats: PDF, MP4, PPTX, DOCX\n(Max 100MB)';

  @override
  String get uploadMaterialsTitleFieldLabel => 'Material Title';

  @override
  String get uploadMaterialsTitleHint => 'Enter title for this material...';

  @override
  String get uploadMaterialsUploadButton => 'Upload';

  @override
  String get uploadMaterialsListTitle => 'Uploaded Materials';

  @override
  String get weeklyAttendanceSheet => 'Weekly Attendance Sheet';

  @override
  String weekOfTotal(int current, int total) {
    return 'Week $current of $total';
  }

  @override
  String get activeWeekEditable => 'Active Week (Editable)';

  @override
  String get lockedWeekReadOnly => 'Locked Week (Read-Only)';

  @override
  String get activeWeekLockBanner =>
      '🟢 Active Week: Attendance can be updated and saved.';

  @override
  String get lockedWeekLockBanner =>
      '🔒 Locked: Past/upcoming week records are read-only.';

  @override
  String get scheduledSessionsThisWeek => 'SCHEDULED SESSIONS THIS WEEK';

  @override
  String get downloadAttendanceReports => 'Download Attendance Reports';

  @override
  String get chooseReportScope =>
      'Choose a report scope and format to download/share:';

  @override
  String thisWeekPdf(int week) {
    return 'This Week (PDF) – Week $week';
  }

  @override
  String get allWeeksPdf => 'All Weeks (PDF) – Cumulative';

  @override
  String thisWeekExcel(int week) {
    return 'This Week (Excel) – Week $week';
  }

  @override
  String get allWeeksExcel => 'All Weeks (Excel) – Cumulative';

  @override
  String get detailedSessionChecklist =>
      'Detailed session check-in list for this week';

  @override
  String get overallStatsRoster =>
      'Overall statistics, total absences, and repeat warnings';

  @override
  String get exportThisWeekSpreadsheet =>
      'Export this week\'s session details to spreadsheet';

  @override
  String get fullStudentRosterSpreadsheet =>
      'Full student roster totals and pass/fail spreadsheet';

  @override
  String get failedRepeat => '⚠️ FAILED (Repeat)';

  @override
  String get excusedLeave => 'Excused (Leave)';

  @override
  String get present => 'Present';

  @override
  String get absent => 'Absent';

  @override
  String get late => 'Late';

  @override
  String get notMarked => 'Not Marked';

  @override
  String get saveAttendanceChanges => 'Save Attendance Changes';

  @override
  String get saving => 'Saving...';

  @override
  String get attendanceUpdatedSuccess => 'Attendance updated successfully!';

  @override
  String failedToSaveAttendance(String error) {
    return 'Failed to save attendance: $error';
  }

  @override
  String get markAllPresent => 'Mark All Present';

  @override
  String get markAllAbsent => 'Mark All Absent';

  @override
  String get chooseExportFormat => 'Choose Export Format';

  @override
  String get chooseExportScope => 'Choose Export Scope';

  @override
  String get pdfDocument => 'PDF Document';

  @override
  String get excelSpreadsheet => 'Excel Spreadsheet';

  @override
  String get pdfDocumentSubtitle =>
      'Best for viewing, printing, and official records';

  @override
  String get excelSpreadsheetSubtitle =>
      'Best for data sorting, analysis, and custom formulas';

  @override
  String get selectFileTypeHint =>
      'Select the file type you would like to download:';

  @override
  String selectRangeWeeksHint(String format) {
    return 'Select the range of weeks for the $format report:';
  }

  @override
  String get thisWeekOnlySubtitle =>
      'Export check-ins for the selected week\'s scheduled sessions';

  @override
  String get allWeeksOnlySubtitle =>
      'Export overall summary totals, attendance rates, and repeat status warnings';
}
