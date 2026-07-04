import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_km.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('km'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'BELTEI Portal'**
  String get appTitle;

  /// No description provided for @loginWelcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome to BELTEI\nPortal'**
  String get loginWelcome;

  /// No description provided for @loginEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get loginEmailLabel;

  /// No description provided for @loginEmailHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get loginEmailHint;

  /// No description provided for @loginPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get loginPasswordLabel;

  /// No description provided for @loginRememberMe.
  ///
  /// In en, this message translates to:
  /// **'Remember Me'**
  String get loginRememberMe;

  /// No description provided for @loginForgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get loginForgotPassword;

  /// No description provided for @loginButton.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get loginButton;

  /// No description provided for @loginNeedHelp.
  ///
  /// In en, this message translates to:
  /// **'Need help? '**
  String get loginNeedHelp;

  /// No description provided for @loginContactSupport.
  ///
  /// In en, this message translates to:
  /// **'Contact Support'**
  String get loginContactSupport;

  /// No description provided for @loginMissingFields.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email and password.'**
  String get loginMissingFields;

  /// No description provided for @splashInitializing.
  ///
  /// In en, this message translates to:
  /// **'INITIALIZING ACADEMIC PORTAL...'**
  String get splashInitializing;

  /// No description provided for @splashLoadingData.
  ///
  /// In en, this message translates to:
  /// **'LOADING STUDENT DATA...'**
  String get splashLoadingData;

  /// No description provided for @splashReady.
  ///
  /// In en, this message translates to:
  /// **'READY'**
  String get splashReady;

  /// No description provided for @splashTagline.
  ///
  /// In en, this message translates to:
  /// **'QUALITY · EFFICIENCY · EXCELLENCE · MORALITY · VIRTUE'**
  String get splashTagline;

  /// No description provided for @adminAppBarTitle.
  ///
  /// In en, this message translates to:
  /// **'BELTEI Admin'**
  String get adminAppBarTitle;

  /// No description provided for @navDashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get navDashboard;

  /// No description provided for @navUsers.
  ///
  /// In en, this message translates to:
  /// **'Users'**
  String get navUsers;

  /// No description provided for @navAcademic.
  ///
  /// In en, this message translates to:
  /// **'Academic'**
  String get navAcademic;

  /// No description provided for @navFinance.
  ///
  /// In en, this message translates to:
  /// **'Finance'**
  String get navFinance;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navCourses.
  ///
  /// In en, this message translates to:
  /// **'Courses'**
  String get navCourses;

  /// No description provided for @navStudents.
  ///
  /// In en, this message translates to:
  /// **'Students'**
  String get navStudents;

  /// No description provided for @navAlerts.
  ///
  /// In en, this message translates to:
  /// **'Alerts'**
  String get navAlerts;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @navSchedule.
  ///
  /// In en, this message translates to:
  /// **'Schedule'**
  String get navSchedule;

  /// No description provided for @logoutTitle.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logoutTitle;

  /// No description provided for @logoutConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to logout?'**
  String get logoutConfirm;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @settingsUniversityInfoTitle.
  ///
  /// In en, this message translates to:
  /// **'University Information'**
  String get settingsUniversityInfoTitle;

  /// No description provided for @settingsUniversityNameLabel.
  ///
  /// In en, this message translates to:
  /// **'University Name'**
  String get settingsUniversityNameLabel;

  /// No description provided for @settingsContactEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Contact Email'**
  String get settingsContactEmailLabel;

  /// No description provided for @settingsUploadLogo.
  ///
  /// In en, this message translates to:
  /// **'Upload Logo'**
  String get settingsUploadLogo;

  /// No description provided for @settingsUploadLogoHint.
  ///
  /// In en, this message translates to:
  /// **'Update the primary institutional logo. Recommended size: 512×512px.'**
  String get settingsUploadLogoHint;

  /// No description provided for @settingsAcademicCycleTitle.
  ///
  /// In en, this message translates to:
  /// **'Academic Cycle'**
  String get settingsAcademicCycleTitle;

  /// No description provided for @settingsCurrentAcademicYear.
  ///
  /// In en, this message translates to:
  /// **'Current Academic Year'**
  String get settingsCurrentAcademicYear;

  /// No description provided for @settingsCurrentSemester.
  ///
  /// In en, this message translates to:
  /// **'Current Semester'**
  String get settingsCurrentSemester;

  /// No description provided for @settingsManageInAcademic.
  ///
  /// In en, this message translates to:
  /// **'Manage in Academic Management'**
  String get settingsManageInAcademic;

  /// No description provided for @settingsSemesterFormat.
  ///
  /// In en, this message translates to:
  /// **'Semester Format'**
  String get settingsSemesterFormat;

  /// No description provided for @settingsSemester.
  ///
  /// In en, this message translates to:
  /// **'Semester'**
  String get settingsSemester;

  /// No description provided for @settingsTrimester.
  ///
  /// In en, this message translates to:
  /// **'Trimester'**
  String get settingsTrimester;

  /// No description provided for @settingsGradingThresholdsTitle.
  ///
  /// In en, this message translates to:
  /// **'Grading Thresholds'**
  String get settingsGradingThresholdsTitle;

  /// No description provided for @settingsNotConfigurable.
  ///
  /// In en, this message translates to:
  /// **'Not yet configurable'**
  String get settingsNotConfigurable;

  /// No description provided for @settingsNotificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Notification Channels'**
  String get settingsNotificationsTitle;

  /// No description provided for @settingsPushNotifications.
  ///
  /// In en, this message translates to:
  /// **'Push Notifications'**
  String get settingsPushNotifications;

  /// No description provided for @settingsPushNotificationsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Alert admins of urgent financial approvals.'**
  String get settingsPushNotificationsSubtitle;

  /// No description provided for @settingsEmailDigests.
  ///
  /// In en, this message translates to:
  /// **'Automated Email Digests'**
  String get settingsEmailDigests;

  /// No description provided for @settingsEmailDigestsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Weekly enrollment and attendance reports.'**
  String get settingsEmailDigestsSubtitle;

  /// No description provided for @settingsAccessControlTitle.
  ///
  /// In en, this message translates to:
  /// **'Role-Based Access Control'**
  String get settingsAccessControlTitle;

  /// No description provided for @settingsAccessControlReadOnly.
  ///
  /// In en, this message translates to:
  /// **'Read-only — access control management is not yet available.'**
  String get settingsAccessControlReadOnly;

  /// No description provided for @settingsAppearanceTitle.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get settingsAppearanceTitle;

  /// No description provided for @settingsThemeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get settingsThemeLight;

  /// No description provided for @settingsThemeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get settingsThemeDark;

  /// No description provided for @settingsThemeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get settingsThemeSystem;

  /// No description provided for @settingsLanguageTitle.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguageTitle;

  /// No description provided for @settingsDiscardChanges.
  ///
  /// In en, this message translates to:
  /// **'Discard Changes'**
  String get settingsDiscardChanges;

  /// No description provided for @settingsSaveSettings.
  ///
  /// In en, this message translates to:
  /// **'Save Settings'**
  String get settingsSaveSettings;

  /// No description provided for @settingsSaved.
  ///
  /// In en, this message translates to:
  /// **'Settings saved.'**
  String get settingsSaved;

  /// No description provided for @profileLoadError.
  ///
  /// In en, this message translates to:
  /// **'Failed to load profile: {error}'**
  String profileLoadError(Object error);

  /// No description provided for @profileNotFoundTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile Not Found'**
  String get profileNotFoundTitle;

  /// No description provided for @profileNotFoundMessage.
  ///
  /// In en, this message translates to:
  /// **'Your student record could not be loaded. This may be a temporary issue or your account may not be fully set up yet.'**
  String get profileNotFoundMessage;

  /// No description provided for @profileTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get profileTryAgain;

  /// No description provided for @profileSignOut.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get profileSignOut;

  /// No description provided for @profileIdLabel.
  ///
  /// In en, this message translates to:
  /// **'ID: {code}'**
  String profileIdLabel(String code);

  /// No description provided for @profileNa.
  ///
  /// In en, this message translates to:
  /// **'N/A'**
  String get profileNa;

  /// No description provided for @profilePersonalInfoTitle.
  ///
  /// In en, this message translates to:
  /// **'Personal Information'**
  String get profilePersonalInfoTitle;

  /// No description provided for @profileFullNameLabel.
  ///
  /// In en, this message translates to:
  /// **'FULL NAME'**
  String get profileFullNameLabel;

  /// No description provided for @profileDateOfBirthLabel.
  ///
  /// In en, this message translates to:
  /// **'DATE OF BIRTH'**
  String get profileDateOfBirthLabel;

  /// No description provided for @profileGenderLabel.
  ///
  /// In en, this message translates to:
  /// **'GENDER'**
  String get profileGenderLabel;

  /// No description provided for @profileNationalityLabel.
  ///
  /// In en, this message translates to:
  /// **'NATIONALITY'**
  String get profileNationalityLabel;

  /// No description provided for @profileAcademicInfoTitle.
  ///
  /// In en, this message translates to:
  /// **'Academic Information'**
  String get profileAcademicInfoTitle;

  /// No description provided for @profileMajorLabel.
  ///
  /// In en, this message translates to:
  /// **'MAJOR'**
  String get profileMajorLabel;

  /// No description provided for @profileYearLevelLabel.
  ///
  /// In en, this message translates to:
  /// **'YEAR LEVEL'**
  String get profileYearLevelLabel;

  /// No description provided for @profileYearLevelValue.
  ///
  /// In en, this message translates to:
  /// **'Year {level}'**
  String profileYearLevelValue(int level);

  /// No description provided for @profileAcademicStatusLabel.
  ///
  /// In en, this message translates to:
  /// **'ACADEMIC STATUS'**
  String get profileAcademicStatusLabel;

  /// No description provided for @profileGpaLabel.
  ///
  /// In en, this message translates to:
  /// **'GPA'**
  String get profileGpaLabel;

  /// No description provided for @profileGpaValue.
  ///
  /// In en, this message translates to:
  /// **'{gpa} / 4.00'**
  String profileGpaValue(String gpa);

  /// No description provided for @profileContactInfoTitle.
  ///
  /// In en, this message translates to:
  /// **'Contact Information'**
  String get profileContactInfoTitle;

  /// No description provided for @profileEmergencyContactTitle.
  ///
  /// In en, this message translates to:
  /// **'Emergency Contact'**
  String get profileEmergencyContactTitle;

  /// No description provided for @profileContactLabel.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get profileContactLabel;

  /// No description provided for @profileAccountSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Account Settings'**
  String get profileAccountSettingsTitle;

  /// No description provided for @profileChangePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get profileChangePassword;

  /// No description provided for @profileChangePasswordSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Update your account password'**
  String get profileChangePasswordSubtitle;

  /// No description provided for @profileNotificationSettings.
  ///
  /// In en, this message translates to:
  /// **'Notification Settings'**
  String get profileNotificationSettings;

  /// No description provided for @profileNotificationSettingsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage app alerts and emails'**
  String get profileNotificationSettingsSubtitle;

  /// No description provided for @profileLanguageSettings.
  ///
  /// In en, this message translates to:
  /// **'Language Settings'**
  String get profileLanguageSettings;

  /// No description provided for @profileLanguageSettingsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose your preferred language'**
  String get profileLanguageSettingsSubtitle;

  /// No description provided for @profileChooseLanguage.
  ///
  /// In en, this message translates to:
  /// **'Choose Language'**
  String get profileChooseLanguage;

  /// No description provided for @profileLogout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get profileLogout;

  /// No description provided for @statusActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get statusActive;

  /// No description provided for @statusInactive.
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get statusInactive;

  /// No description provided for @statusGraduated.
  ///
  /// In en, this message translates to:
  /// **'Graduated'**
  String get statusGraduated;

  /// No description provided for @statusSuspended.
  ///
  /// In en, this message translates to:
  /// **'Suspended'**
  String get statusSuspended;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @loadErrorSchedule.
  ///
  /// In en, this message translates to:
  /// **'Could not load schedule'**
  String get loadErrorSchedule;

  /// No description provided for @loadErrorAttendance.
  ///
  /// In en, this message translates to:
  /// **'Could not load attendance'**
  String get loadErrorAttendance;

  /// No description provided for @loadErrorGrades.
  ///
  /// In en, this message translates to:
  /// **'Could not load grades'**
  String get loadErrorGrades;

  /// No description provided for @timeAgoMinutes.
  ///
  /// In en, this message translates to:
  /// **'{minutes}m ago'**
  String timeAgoMinutes(int minutes);

  /// No description provided for @timeAgoHours.
  ///
  /// In en, this message translates to:
  /// **'{hours}h ago'**
  String timeAgoHours(int hours);

  /// No description provided for @timeAgoYesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get timeAgoYesterday;

  /// No description provided for @statusPresent.
  ///
  /// In en, this message translates to:
  /// **'Present'**
  String get statusPresent;

  /// No description provided for @statusAbsent.
  ///
  /// In en, this message translates to:
  /// **'Absent'**
  String get statusAbsent;

  /// No description provided for @statusLate.
  ///
  /// In en, this message translates to:
  /// **'Late'**
  String get statusLate;

  /// No description provided for @statusExcused.
  ///
  /// In en, this message translates to:
  /// **'Excused'**
  String get statusExcused;

  /// No description provided for @statusCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get statusCompleted;

  /// No description provided for @statusDropped.
  ///
  /// In en, this message translates to:
  /// **'Dropped'**
  String get statusDropped;

  /// No description provided for @statusEnrolled.
  ///
  /// In en, this message translates to:
  /// **'Enrolled'**
  String get statusEnrolled;

  /// No description provided for @noClassesToday.
  ///
  /// In en, this message translates to:
  /// **'No classes today'**
  String get noClassesToday;

  /// No description provided for @dayMon.
  ///
  /// In en, this message translates to:
  /// **'Mon'**
  String get dayMon;

  /// No description provided for @dayTue.
  ///
  /// In en, this message translates to:
  /// **'Tue'**
  String get dayTue;

  /// No description provided for @dayWed.
  ///
  /// In en, this message translates to:
  /// **'Wed'**
  String get dayWed;

  /// No description provided for @dayThu.
  ///
  /// In en, this message translates to:
  /// **'Thu'**
  String get dayThu;

  /// No description provided for @dayFri.
  ///
  /// In en, this message translates to:
  /// **'Fri'**
  String get dayFri;

  /// No description provided for @daySat.
  ///
  /// In en, this message translates to:
  /// **'Sat'**
  String get daySat;

  /// No description provided for @dashboardQuickActionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get dashboardQuickActionsTitle;

  /// No description provided for @dashboardSeeAll.
  ///
  /// In en, this message translates to:
  /// **'SEE ALL'**
  String get dashboardSeeAll;

  /// No description provided for @dashboardActionAttendance.
  ///
  /// In en, this message translates to:
  /// **'Attendance'**
  String get dashboardActionAttendance;

  /// No description provided for @dashboardActionLeave.
  ///
  /// In en, this message translates to:
  /// **'Leave'**
  String get dashboardActionLeave;

  /// No description provided for @dashboardActionCourses.
  ///
  /// In en, this message translates to:
  /// **'Courses'**
  String get dashboardActionCourses;

  /// No description provided for @dashboardActionGrades.
  ///
  /// In en, this message translates to:
  /// **'Grades'**
  String get dashboardActionGrades;

  /// No description provided for @dashboardAcademicSummaryTitle.
  ///
  /// In en, this message translates to:
  /// **'Academic Summary'**
  String get dashboardAcademicSummaryTitle;

  /// No description provided for @dashboardGpaCurrentLabel.
  ///
  /// In en, this message translates to:
  /// **'GPA (Current)'**
  String get dashboardGpaCurrentLabel;

  /// No description provided for @dashboardCgpaLabel.
  ///
  /// In en, this message translates to:
  /// **'CGPA'**
  String get dashboardCgpaLabel;

  /// No description provided for @dashboardCreditsDoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Credits Done'**
  String get dashboardCreditsDoneLabel;

  /// No description provided for @dashboardThisSemesterLabel.
  ///
  /// In en, this message translates to:
  /// **'This Semester'**
  String get dashboardThisSemesterLabel;

  /// No description provided for @dashboardCreditsUnit.
  ///
  /// In en, this message translates to:
  /// **'{credits} cr'**
  String dashboardCreditsUnit(int credits);

  /// No description provided for @dashboardAttendanceOverviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Attendance Overview'**
  String get dashboardAttendanceOverviewTitle;

  /// No description provided for @dashboardOverallRateLabel.
  ///
  /// In en, this message translates to:
  /// **'Overall Rate'**
  String get dashboardOverallRateLabel;

  /// No description provided for @dashboardAttendanceLeaveLabel.
  ///
  /// In en, this message translates to:
  /// **'Leave'**
  String get dashboardAttendanceLeaveLabel;

  /// No description provided for @dashboardFinancialSummaryTitle.
  ///
  /// In en, this message translates to:
  /// **'Financial Summary'**
  String get dashboardFinancialSummaryTitle;

  /// No description provided for @dashboardRecentActivitiesTitle.
  ///
  /// In en, this message translates to:
  /// **'Recent Activities'**
  String get dashboardRecentActivitiesTitle;

  /// No description provided for @dashboardActivitiesLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load activities.'**
  String get dashboardActivitiesLoadError;

  /// No description provided for @dashboardNoRecentActivities.
  ///
  /// In en, this message translates to:
  /// **'No recent activities.'**
  String get dashboardNoRecentActivities;

  /// No description provided for @dashboardViewAllNotifications.
  ///
  /// In en, this message translates to:
  /// **'VIEW ALL NOTIFICATIONS'**
  String get dashboardViewAllNotifications;

  /// No description provided for @dashboardFinanceLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load finance data.'**
  String get dashboardFinanceLoadError;

  /// No description provided for @dashboardTotalSemesterFee.
  ///
  /// In en, this message translates to:
  /// **'Total Semester Fee'**
  String get dashboardTotalSemesterFee;

  /// No description provided for @dashboardPaidLabel.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get dashboardPaidLabel;

  /// No description provided for @dashboardOutstandingLabel.
  ///
  /// In en, this message translates to:
  /// **'Outstanding'**
  String get dashboardOutstandingLabel;

  /// No description provided for @dashboardDueDateReminder.
  ///
  /// In en, this message translates to:
  /// **'DUE DATE REMINDER'**
  String get dashboardDueDateReminder;

  /// No description provided for @dashboardPayNow.
  ///
  /// In en, this message translates to:
  /// **'Pay Now'**
  String get dashboardPayNow;

  /// No description provided for @agendaAppBarTitle.
  ///
  /// In en, this message translates to:
  /// **'Daily Agenda'**
  String get agendaAppBarTitle;

  /// No description provided for @agendaClassCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No Classes} =1{{count} Class} other{{count} Classes}}'**
  String agendaClassCount(int count);

  /// No description provided for @agendaEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enjoy your free day!'**
  String get agendaEmptySubtitle;

  /// No description provided for @scheduleWeeklyTitle.
  ///
  /// In en, this message translates to:
  /// **'Weekly Schedule'**
  String get scheduleWeeklyTitle;

  /// No description provided for @scheduleLunchBreak.
  ///
  /// In en, this message translates to:
  /// **'LUNCH BREAK'**
  String get scheduleLunchBreak;

  /// No description provided for @courseListFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get courseListFilterAll;

  /// No description provided for @courseListFilterCurrent.
  ///
  /// In en, this message translates to:
  /// **'Current'**
  String get courseListFilterCurrent;

  /// No description provided for @courseListLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load courses'**
  String get courseListLoadError;

  /// No description provided for @courseListEmptyState.
  ///
  /// In en, this message translates to:
  /// **'No courses found.'**
  String get courseListEmptyState;

  /// No description provided for @courseListSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search courses, professors, or codes...'**
  String get courseListSearchHint;

  /// No description provided for @courseListProfessorLabel.
  ///
  /// In en, this message translates to:
  /// **'PROFESSOR'**
  String get courseListProfessorLabel;

  /// No description provided for @courseListSemesterLabel.
  ///
  /// In en, this message translates to:
  /// **'SEMESTER'**
  String get courseListSemesterLabel;

  /// No description provided for @courseListCreditsLabel.
  ///
  /// In en, this message translates to:
  /// **'CREDITS'**
  String get courseListCreditsLabel;

  /// No description provided for @courseListCreditsUnitsValue.
  ///
  /// In en, this message translates to:
  /// **'{credits} Units'**
  String courseListCreditsUnitsValue(int credits);

  /// No description provided for @courseListStatusLabel.
  ///
  /// In en, this message translates to:
  /// **'STATUS'**
  String get courseListStatusLabel;

  /// No description provided for @courseListCourseCompletionLabel.
  ///
  /// In en, this message translates to:
  /// **'Course Completion'**
  String get courseListCourseCompletionLabel;

  /// No description provided for @courseListAttendanceRateLabel.
  ///
  /// In en, this message translates to:
  /// **'Attendance Rate'**
  String get courseListAttendanceRateLabel;

  /// No description provided for @courseDetailTabOverview.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get courseDetailTabOverview;

  /// No description provided for @courseDetailTabAttendance.
  ///
  /// In en, this message translates to:
  /// **'Attendance'**
  String get courseDetailTabAttendance;

  /// No description provided for @courseDetailTabGrades.
  ///
  /// In en, this message translates to:
  /// **'Grades'**
  String get courseDetailTabGrades;

  /// No description provided for @courseDetailTabMaterials.
  ///
  /// In en, this message translates to:
  /// **'Materials'**
  String get courseDetailTabMaterials;

  /// No description provided for @courseDetailFallbackTitle.
  ///
  /// In en, this message translates to:
  /// **'Course Detail'**
  String get courseDetailFallbackTitle;

  /// No description provided for @courseDetailCreditsLabel.
  ///
  /// In en, this message translates to:
  /// **'Credits'**
  String get courseDetailCreditsLabel;

  /// No description provided for @courseDetailAcademicCreditsValue.
  ///
  /// In en, this message translates to:
  /// **'{credits} Academic Credits'**
  String courseDetailAcademicCreditsValue(int credits);

  /// No description provided for @courseDetailSemesterLabel.
  ///
  /// In en, this message translates to:
  /// **'Semester'**
  String get courseDetailSemesterLabel;

  /// No description provided for @courseDetailCurrentChip.
  ///
  /// In en, this message translates to:
  /// **'CURRENT'**
  String get courseDetailCurrentChip;

  /// No description provided for @courseDetailEnrolledChip.
  ///
  /// In en, this message translates to:
  /// **'ENROLLED'**
  String get courseDetailEnrolledChip;

  /// No description provided for @courseDetailInstructorTitle.
  ///
  /// In en, this message translates to:
  /// **'Instructor'**
  String get courseDetailInstructorTitle;

  /// No description provided for @courseDetailContactLink.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get courseDetailContactLink;

  /// No description provided for @courseDetailAttendanceRateLabel.
  ///
  /// In en, this message translates to:
  /// **'Attendance Rate'**
  String get courseDetailAttendanceRateLabel;

  /// No description provided for @courseDetailAttendanceBelowThreshold.
  ///
  /// In en, this message translates to:
  /// **'{pct}% — Below 75% threshold'**
  String courseDetailAttendanceBelowThreshold(int pct);

  /// No description provided for @courseDetailNoAttendanceRecords.
  ///
  /// In en, this message translates to:
  /// **'No attendance records yet.'**
  String get courseDetailNoAttendanceRecords;

  /// No description provided for @courseDetailSessionHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Session History'**
  String get courseDetailSessionHistoryTitle;

  /// No description provided for @courseDetailAttendanceRateAllCaps.
  ///
  /// In en, this message translates to:
  /// **'ATTENDANCE RATE'**
  String get courseDetailAttendanceRateAllCaps;

  /// No description provided for @courseDetailBelowThresholdChip.
  ///
  /// In en, this message translates to:
  /// **'Below 75%'**
  String get courseDetailBelowThresholdChip;

  /// No description provided for @courseDetailTotalLabel.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get courseDetailTotalLabel;

  /// No description provided for @courseDetailNoGradesRecorded.
  ///
  /// In en, this message translates to:
  /// **'No grades recorded yet.'**
  String get courseDetailNoGradesRecorded;

  /// No description provided for @courseDetailScoreBreakdownTitle.
  ///
  /// In en, this message translates to:
  /// **'Score Breakdown'**
  String get courseDetailScoreBreakdownTitle;

  /// No description provided for @courseDetailMidtermLabel.
  ///
  /// In en, this message translates to:
  /// **'Midterm'**
  String get courseDetailMidtermLabel;

  /// No description provided for @courseDetailAssignmentLabel.
  ///
  /// In en, this message translates to:
  /// **'Assignment'**
  String get courseDetailAssignmentLabel;

  /// No description provided for @courseDetailFinalExamLabel.
  ///
  /// In en, this message translates to:
  /// **'Final Exam'**
  String get courseDetailFinalExamLabel;

  /// No description provided for @courseDetailFinalGradeLabel.
  ///
  /// In en, this message translates to:
  /// **'FINAL GRADE'**
  String get courseDetailFinalGradeLabel;

  /// No description provided for @courseDetailGpaPointsValue.
  ///
  /// In en, this message translates to:
  /// **'{points} GPA Points'**
  String courseDetailGpaPointsValue(String points);

  /// No description provided for @courseDetailNotYetGraded.
  ///
  /// In en, this message translates to:
  /// **'Not yet graded'**
  String get courseDetailNotYetGraded;

  /// No description provided for @courseDetailGradeCreditsValue.
  ///
  /// In en, this message translates to:
  /// **'{credits} Credits'**
  String courseDetailGradeCreditsValue(int credits);

  /// No description provided for @courseDetailMaterialsLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load materials'**
  String get courseDetailMaterialsLoadError;

  /// No description provided for @courseDetailNoMaterialsUploaded.
  ///
  /// In en, this message translates to:
  /// **'No materials uploaded yet.'**
  String get courseDetailNoMaterialsUploaded;

  /// No description provided for @courseDetailMaterialsTitle.
  ///
  /// In en, this message translates to:
  /// **'Course Materials'**
  String get courseDetailMaterialsTitle;

  /// No description provided for @courseDetailFilesCountValue.
  ///
  /// In en, this message translates to:
  /// **'{count} Files'**
  String courseDetailFilesCountValue(int count);

  /// No description provided for @gradesStandingGood.
  ///
  /// In en, this message translates to:
  /// **'GOOD STANDING'**
  String get gradesStandingGood;

  /// No description provided for @gradesStandingAtRisk.
  ///
  /// In en, this message translates to:
  /// **'AT RISK'**
  String get gradesStandingAtRisk;

  /// No description provided for @gradesPageTitle.
  ///
  /// In en, this message translates to:
  /// **'Academic Performance'**
  String get gradesPageTitle;

  /// No description provided for @gradesStudentIdLabel.
  ///
  /// In en, this message translates to:
  /// **'Student ID: {code}'**
  String gradesStudentIdLabel(String code);

  /// No description provided for @gradesStudentIdWithYearLabel.
  ///
  /// In en, this message translates to:
  /// **'Student ID: {code} • Year {level}'**
  String gradesStudentIdWithYearLabel(String code, int level);

  /// No description provided for @gradesOverviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Grade Overview'**
  String get gradesOverviewTitle;

  /// No description provided for @gradesGpaLabel.
  ///
  /// In en, this message translates to:
  /// **'GPA'**
  String get gradesGpaLabel;

  /// No description provided for @gradesCurrentTermLabel.
  ///
  /// In en, this message translates to:
  /// **'Current Term'**
  String get gradesCurrentTermLabel;

  /// No description provided for @gradesCgpaLabel.
  ///
  /// In en, this message translates to:
  /// **'CGPA'**
  String get gradesCgpaLabel;

  /// No description provided for @gradesCumulativeLabel.
  ///
  /// In en, this message translates to:
  /// **'Cumulative'**
  String get gradesCumulativeLabel;

  /// No description provided for @gradesDegreeProgressTitle.
  ///
  /// In en, this message translates to:
  /// **'Degree Progress'**
  String get gradesDegreeProgressTitle;

  /// No description provided for @gradesDegreeProgramSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Bachelor\'s Degree Program'**
  String get gradesDegreeProgramSubtitle;

  /// No description provided for @gradesTotalCreditsLabel.
  ///
  /// In en, this message translates to:
  /// **'Total Credits'**
  String get gradesTotalCreditsLabel;

  /// No description provided for @gradesCreditsProgressValue.
  ///
  /// In en, this message translates to:
  /// **'{earned} / {total}'**
  String gradesCreditsProgressValue(int earned, int total);

  /// No description provided for @gradesProgressCompletedLabel.
  ///
  /// In en, this message translates to:
  /// **'{pct}% completed'**
  String gradesProgressCompletedLabel(int pct);

  /// No description provided for @gradesSemesterHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Semester History'**
  String get gradesSemesterHistoryTitle;

  /// No description provided for @gradesHonorsEligibilityTitle.
  ///
  /// In en, this message translates to:
  /// **'Honors Eligibility'**
  String get gradesHonorsEligibilityTitle;

  /// No description provided for @gradesHonorsOnTrackMessage.
  ///
  /// In en, this message translates to:
  /// **'You are on track for the Dean\'s List! Maintain a CGPA above 3.50 for the upcoming graduation.'**
  String get gradesHonorsOnTrackMessage;

  /// No description provided for @gradesHonorsNotOnTrackMessage.
  ///
  /// In en, this message translates to:
  /// **'Maintain a CGPA above 3.50 to qualify for the Dean\'s List for the upcoming graduation.'**
  String get gradesHonorsNotOnTrackMessage;

  /// No description provided for @gradesCurrentCgpaCheckmark.
  ///
  /// In en, this message translates to:
  /// **'Current CGPA: {cgpa} ✓'**
  String gradesCurrentCgpaCheckmark(String cgpa);

  /// No description provided for @gradesCurrentCgpaLabel.
  ///
  /// In en, this message translates to:
  /// **'Current CGPA: {cgpa}'**
  String gradesCurrentCgpaLabel(String cgpa);

  /// No description provided for @gradesSemesterNowLabel.
  ///
  /// In en, this message translates to:
  /// **'NOW'**
  String get gradesSemesterNowLabel;

  /// No description provided for @gradesNoGradesYetLabel.
  ///
  /// In en, this message translates to:
  /// **'No grades yet'**
  String get gradesNoGradesYetLabel;

  /// No description provided for @gradesSemesterGpaValue.
  ///
  /// In en, this message translates to:
  /// **'GPA {gpa}'**
  String gradesSemesterGpaValue(String gpa);

  /// No description provided for @semesterGradeDefaultTitle.
  ///
  /// In en, this message translates to:
  /// **'Semester Grades'**
  String get semesterGradeDefaultTitle;

  /// No description provided for @semesterGradeNotFound.
  ///
  /// In en, this message translates to:
  /// **'Semester not found.'**
  String get semesterGradeNotFound;

  /// No description provided for @semesterGradeEnrolledCoursesTitle.
  ///
  /// In en, this message translates to:
  /// **'Enrolled Courses'**
  String get semesterGradeEnrolledCoursesTitle;

  /// No description provided for @semesterGradeGpaLabel.
  ///
  /// In en, this message translates to:
  /// **'SEMESTER GPA'**
  String get semesterGradeGpaLabel;

  /// No description provided for @semesterGradeDeansListQualification.
  ///
  /// In en, this message translates to:
  /// **'Dean\'s List Qualification'**
  String get semesterGradeDeansListQualification;

  /// No description provided for @semesterGradeCreditsEarnedLabel.
  ///
  /// In en, this message translates to:
  /// **'Credits\nEarned'**
  String get semesterGradeCreditsEarnedLabel;

  /// No description provided for @semesterGradeCreditsRatio.
  ///
  /// In en, this message translates to:
  /// **'{earned} / {enrolled}'**
  String semesterGradeCreditsRatio(int earned, int enrolled);

  /// No description provided for @semesterGradeNoGradesRecorded.
  ///
  /// In en, this message translates to:
  /// **'No grades recorded yet.'**
  String get semesterGradeNoGradesRecorded;

  /// No description provided for @semesterGradeKeyTitle.
  ///
  /// In en, this message translates to:
  /// **'Grade Key'**
  String get semesterGradeKeyTitle;

  /// No description provided for @semesterGradeRangeA.
  ///
  /// In en, this message translates to:
  /// **'4.0 (90–100)'**
  String get semesterGradeRangeA;

  /// No description provided for @semesterGradeRangeB.
  ///
  /// In en, this message translates to:
  /// **'3.0 (80–89)'**
  String get semesterGradeRangeB;

  /// No description provided for @semesterGradeRangeC.
  ///
  /// In en, this message translates to:
  /// **'2.0 (70–79)'**
  String get semesterGradeRangeC;

  /// No description provided for @semesterGradeRangeF.
  ///
  /// In en, this message translates to:
  /// **'0.0 (below 60)'**
  String get semesterGradeRangeF;

  /// No description provided for @semesterGradeDegreeCompletionTitle.
  ///
  /// In en, this message translates to:
  /// **'Degree Completion'**
  String get semesterGradeDegreeCompletionTitle;

  /// No description provided for @semesterGradePercentComplete.
  ///
  /// In en, this message translates to:
  /// **'{percent}%'**
  String semesterGradePercentComplete(int percent);

  /// No description provided for @semesterGradeCreditsCompletedSummary.
  ///
  /// In en, this message translates to:
  /// **'{earned} of {required} credits completed.'**
  String semesterGradeCreditsCompletedSummary(int earned, int required);

  /// No description provided for @semesterGradeCreditsCount.
  ///
  /// In en, this message translates to:
  /// **'{credits} Credits'**
  String semesterGradeCreditsCount(int credits);

  /// No description provided for @semesterGradeGradePointsLabel.
  ///
  /// In en, this message translates to:
  /// **'GRADE POINTS'**
  String get semesterGradeGradePointsLabel;

  /// No description provided for @analyticsTitle.
  ///
  /// In en, this message translates to:
  /// **'Academic Performance'**
  String get analyticsTitle;

  /// No description provided for @analyticsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Insights and progress tracking'**
  String get analyticsSubtitle;

  /// No description provided for @analyticsCurrentCgpaLabel.
  ///
  /// In en, this message translates to:
  /// **'CURRENT CGPA'**
  String get analyticsCurrentCgpaLabel;

  /// No description provided for @analyticsGpaDeltaLabel.
  ///
  /// In en, this message translates to:
  /// **'{delta} vs last sem'**
  String analyticsGpaDeltaLabel(String delta);

  /// No description provided for @analyticsDegreeProgressTitle.
  ///
  /// In en, this message translates to:
  /// **'Degree Progress'**
  String get analyticsDegreeProgressTitle;

  /// No description provided for @analyticsPercentComplete.
  ///
  /// In en, this message translates to:
  /// **'{percent}%'**
  String analyticsPercentComplete(int percent);

  /// No description provided for @analyticsDefaultDegreeName.
  ///
  /// In en, this message translates to:
  /// **'Degree Program'**
  String get analyticsDefaultDegreeName;

  /// No description provided for @analyticsEarnedLabel.
  ///
  /// In en, this message translates to:
  /// **'Earned'**
  String get analyticsEarnedLabel;

  /// No description provided for @analyticsEarnedValue.
  ///
  /// In en, this message translates to:
  /// **'{earned} / {required}'**
  String analyticsEarnedValue(int earned, int required);

  /// No description provided for @analyticsRequiredLabel.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get analyticsRequiredLabel;

  /// No description provided for @analyticsRemainingCreditsValue.
  ///
  /// In en, this message translates to:
  /// **'{remaining} Credits'**
  String analyticsRemainingCreditsValue(int remaining);

  /// No description provided for @analyticsStatusLabel.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get analyticsStatusLabel;

  /// No description provided for @analyticsStatusOnTrack.
  ///
  /// In en, this message translates to:
  /// **'On Track'**
  String get analyticsStatusOnTrack;

  /// No description provided for @analyticsStatusInProgress.
  ///
  /// In en, this message translates to:
  /// **'In Progress'**
  String get analyticsStatusInProgress;

  /// No description provided for @analyticsGpaTrendTitle.
  ///
  /// In en, this message translates to:
  /// **'GPA Trend Analysis'**
  String get analyticsGpaTrendTitle;

  /// No description provided for @analyticsLegendTermGpa.
  ///
  /// In en, this message translates to:
  /// **'Term GPA'**
  String get analyticsLegendTermGpa;

  /// No description provided for @analyticsLegendCgpa.
  ///
  /// In en, this message translates to:
  /// **'CGPA'**
  String get analyticsLegendCgpa;

  /// No description provided for @analyticsSemesterComparisonTitle.
  ///
  /// In en, this message translates to:
  /// **'Semester Comparison'**
  String get analyticsSemesterComparisonTitle;

  /// No description provided for @analyticsSemesterComparisonSubtitle.
  ///
  /// In en, this message translates to:
  /// **'GPA per semester'**
  String get analyticsSemesterComparisonSubtitle;

  /// No description provided for @analyticsCurrentCoursesTitle.
  ///
  /// In en, this message translates to:
  /// **'Current Semester Courses'**
  String get analyticsCurrentCoursesTitle;

  /// No description provided for @analyticsNoCoursesMessage.
  ///
  /// In en, this message translates to:
  /// **'No courses enrolled this semester.'**
  String get analyticsNoCoursesMessage;

  /// No description provided for @analyticsCourseNameHeader.
  ///
  /// In en, this message translates to:
  /// **'COURSE NAME'**
  String get analyticsCourseNameHeader;

  /// No description provided for @analyticsCourseCodeHeader.
  ///
  /// In en, this message translates to:
  /// **'CODE'**
  String get analyticsCourseCodeHeader;

  /// No description provided for @attendanceDashboardTitle.
  ///
  /// In en, this message translates to:
  /// **'Attendance Overview'**
  String get attendanceDashboardTitle;

  /// No description provided for @attendanceDashboardSubtitle.
  ///
  /// In en, this message translates to:
  /// **'All recorded attendance across your enrolled courses'**
  String get attendanceDashboardSubtitle;

  /// No description provided for @attendanceDashboardTotalDaysLabel.
  ///
  /// In en, this message translates to:
  /// **'TOTAL DAYS'**
  String get attendanceDashboardTotalDaysLabel;

  /// No description provided for @attendanceDashboardLeaveLabel.
  ///
  /// In en, this message translates to:
  /// **'LEAVE'**
  String get attendanceDashboardLeaveLabel;

  /// No description provided for @attendanceDashboardRateTitle.
  ///
  /// In en, this message translates to:
  /// **'Attendance Rate'**
  String get attendanceDashboardRateTitle;

  /// No description provided for @attendanceDashboardCurrentRateLabel.
  ///
  /// In en, this message translates to:
  /// **'Current Rate'**
  String get attendanceDashboardCurrentRateLabel;

  /// No description provided for @attendanceDashboardLowAttendanceWarning.
  ///
  /// In en, this message translates to:
  /// **'Attendance below 75%. Risk of academic penalty.'**
  String get attendanceDashboardLowAttendanceWarning;

  /// No description provided for @attendanceDashboardCourseBreakdownTitle.
  ///
  /// In en, this message translates to:
  /// **'Course Breakdown'**
  String get attendanceDashboardCourseBreakdownTitle;

  /// No description provided for @attendanceDashboardRecentLogsTitle.
  ///
  /// In en, this message translates to:
  /// **'Recent Attendance Logs'**
  String get attendanceDashboardRecentLogsTitle;

  /// No description provided for @attendanceDashboardViewFullHistory.
  ///
  /// In en, this message translates to:
  /// **'View Full History'**
  String get attendanceDashboardViewFullHistory;

  /// No description provided for @attendanceDashboardNoRecords.
  ///
  /// In en, this message translates to:
  /// **'No attendance records yet.'**
  String get attendanceDashboardNoRecords;

  /// No description provided for @attendanceDashboardDateColumn.
  ///
  /// In en, this message translates to:
  /// **'DATE'**
  String get attendanceDashboardDateColumn;

  /// No description provided for @attendanceDashboardCourseColumn.
  ///
  /// In en, this message translates to:
  /// **'COURSE'**
  String get attendanceDashboardCourseColumn;

  /// No description provided for @attendanceDashboardStatusColumn.
  ///
  /// In en, this message translates to:
  /// **'STATUS'**
  String get attendanceDashboardStatusColumn;

  /// No description provided for @attendanceHistoryOverallRateLabel.
  ///
  /// In en, this message translates to:
  /// **'Attendance'**
  String get attendanceHistoryOverallRateLabel;

  /// No description provided for @attendanceHistoryCalendarTitle.
  ///
  /// In en, this message translates to:
  /// **'Attendance History'**
  String get attendanceHistoryCalendarTitle;

  /// No description provided for @attendanceHistoryNoRecordForDay.
  ///
  /// In en, this message translates to:
  /// **'No attendance recorded'**
  String get attendanceHistoryNoRecordForDay;

  /// No description provided for @attendanceHistoryExcusedAbsenceLabel.
  ///
  /// In en, this message translates to:
  /// **'Excused Absence'**
  String get attendanceHistoryExcusedAbsenceLabel;

  /// No description provided for @attendanceHistoryNoRecordLegendLabel.
  ///
  /// In en, this message translates to:
  /// **'No Record'**
  String get attendanceHistoryNoRecordLegendLabel;

  /// No description provided for @leaveDashboardNewRequestButton.
  ///
  /// In en, this message translates to:
  /// **'New Request'**
  String get leaveDashboardNewRequestButton;

  /// No description provided for @leaveDashboardLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load leave requests'**
  String get leaveDashboardLoadError;

  /// No description provided for @leaveDashboardEmptyState.
  ///
  /// In en, this message translates to:
  /// **'No leave requests yet.'**
  String get leaveDashboardEmptyState;

  /// No description provided for @leaveDashboardTitle.
  ///
  /// In en, this message translates to:
  /// **'Leave Requests'**
  String get leaveDashboardTitle;

  /// No description provided for @leaveDashboardSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage and track your absence applications.'**
  String get leaveDashboardSubtitle;

  /// No description provided for @leaveDashboardStatusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get leaveDashboardStatusPending;

  /// No description provided for @leaveDashboardStatusApproved.
  ///
  /// In en, this message translates to:
  /// **'Approved'**
  String get leaveDashboardStatusApproved;

  /// No description provided for @leaveDashboardStatusRejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get leaveDashboardStatusRejected;

  /// No description provided for @leaveDetailAppBarTitle.
  ///
  /// In en, this message translates to:
  /// **'Leave Detail'**
  String get leaveDetailAppBarTitle;

  /// No description provided for @leaveDetailLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load request'**
  String get leaveDetailLoadError;

  /// No description provided for @leaveDetailNotFound.
  ///
  /// In en, this message translates to:
  /// **'Request not found.'**
  String get leaveDetailNotFound;

  /// No description provided for @leaveDetailStatusApproved.
  ///
  /// In en, this message translates to:
  /// **'APPROVED'**
  String get leaveDetailStatusApproved;

  /// No description provided for @leaveDetailStatusRejected.
  ///
  /// In en, this message translates to:
  /// **'REJECTED'**
  String get leaveDetailStatusRejected;

  /// No description provided for @leaveDetailStatusPending.
  ///
  /// In en, this message translates to:
  /// **'PENDING'**
  String get leaveDetailStatusPending;

  /// No description provided for @leaveDetailSubmittedOn.
  ///
  /// In en, this message translates to:
  /// **'Submitted {date}'**
  String leaveDetailSubmittedOn(String date);

  /// No description provided for @leaveDetailTimelineSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Submitted'**
  String get leaveDetailTimelineSubmitted;

  /// No description provided for @leaveDetailTimelineUnderReview.
  ///
  /// In en, this message translates to:
  /// **'Under Review'**
  String get leaveDetailTimelineUnderReview;

  /// No description provided for @leaveDetailTimelineAcademicOffice.
  ///
  /// In en, this message translates to:
  /// **'Academic Office'**
  String get leaveDetailTimelineAcademicOffice;

  /// No description provided for @leaveDetailTimelineDecision.
  ///
  /// In en, this message translates to:
  /// **'Decision'**
  String get leaveDetailTimelineDecision;

  /// No description provided for @leaveDetailTimelineTitle.
  ///
  /// In en, this message translates to:
  /// **'Request Timeline'**
  String get leaveDetailTimelineTitle;

  /// No description provided for @leaveDetailRequestInfoTitle.
  ///
  /// In en, this message translates to:
  /// **'Request Information'**
  String get leaveDetailRequestInfoTitle;

  /// No description provided for @leaveDetailLeaveTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'LEAVE TYPE'**
  String get leaveDetailLeaveTypeLabel;

  /// No description provided for @leaveDetailDatesLabel.
  ///
  /// In en, this message translates to:
  /// **'DATES'**
  String get leaveDetailDatesLabel;

  /// No description provided for @leaveDetailTotalDaysLabel.
  ///
  /// In en, this message translates to:
  /// **'TOTAL DAYS'**
  String get leaveDetailTotalDaysLabel;

  /// No description provided for @leaveDetailTotalDaysValue.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} day} other{{count} days}}'**
  String leaveDetailTotalDaysValue(int count);

  /// No description provided for @leaveDetailReasonLabel.
  ///
  /// In en, this message translates to:
  /// **'REASON FOR REQUEST'**
  String get leaveDetailReasonLabel;

  /// No description provided for @leaveDetailReviewerNotesTitle.
  ///
  /// In en, this message translates to:
  /// **'Reviewer Notes'**
  String get leaveDetailReviewerNotesTitle;

  /// No description provided for @leaveDetailReviewNotesQuoted.
  ///
  /// In en, this message translates to:
  /// **'\"{notes}\"'**
  String leaveDetailReviewNotesQuoted(String notes);

  /// No description provided for @leaveDetailReviewedOn.
  ///
  /// In en, this message translates to:
  /// **'Reviewed on {date}'**
  String leaveDetailReviewedOn(String date);

  /// No description provided for @leaveDetailWithdrawButtonLabel.
  ///
  /// In en, this message translates to:
  /// **'Withdraw Request'**
  String get leaveDetailWithdrawButtonLabel;

  /// No description provided for @leaveDetailWithdrawDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Withdraw Request'**
  String get leaveDetailWithdrawDialogTitle;

  /// No description provided for @leaveDetailWithdrawConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to withdraw this leave request? This cannot be undone.'**
  String get leaveDetailWithdrawConfirmMessage;

  /// No description provided for @leaveDetailWithdrawDialogConfirm.
  ///
  /// In en, this message translates to:
  /// **'Withdraw'**
  String get leaveDetailWithdrawDialogConfirm;

  /// No description provided for @leaveDetailWithdrawError.
  ///
  /// In en, this message translates to:
  /// **'Failed to withdraw: {error}'**
  String leaveDetailWithdrawError(Object error);

  /// No description provided for @createLeaveValidationRequiredFields.
  ///
  /// In en, this message translates to:
  /// **'Please fill in all required fields.'**
  String get createLeaveValidationRequiredFields;

  /// No description provided for @createLeaveSessionExpiredError.
  ///
  /// In en, this message translates to:
  /// **'Session expired. Please log in again.'**
  String get createLeaveSessionExpiredError;

  /// No description provided for @createLeaveSubmitError.
  ///
  /// In en, this message translates to:
  /// **'Failed to submit request. Please try again.'**
  String get createLeaveSubmitError;

  /// No description provided for @createLeaveAppBarTitle.
  ///
  /// In en, this message translates to:
  /// **'New Leave Request'**
  String get createLeaveAppBarTitle;

  /// No description provided for @createLeavePolicyBannerTitle.
  ///
  /// In en, this message translates to:
  /// **'Academic Policy'**
  String get createLeavePolicyBannerTitle;

  /// No description provided for @createLeavePolicyBannerMessage.
  ///
  /// In en, this message translates to:
  /// **'Submit leave requests at least 24 hours in advance, except for medical emergencies.'**
  String get createLeavePolicyBannerMessage;

  /// No description provided for @createLeaveTypeSectionLabel.
  ///
  /// In en, this message translates to:
  /// **'LEAVE TYPE'**
  String get createLeaveTypeSectionLabel;

  /// No description provided for @createLeaveTypeMedical.
  ///
  /// In en, this message translates to:
  /// **'Medical'**
  String get createLeaveTypeMedical;

  /// No description provided for @createLeaveTypePersonal.
  ///
  /// In en, this message translates to:
  /// **'Personal'**
  String get createLeaveTypePersonal;

  /// No description provided for @createLeaveTypeFamily.
  ///
  /// In en, this message translates to:
  /// **'Family'**
  String get createLeaveTypeFamily;

  /// No description provided for @createLeaveTypeOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get createLeaveTypeOther;

  /// No description provided for @createLeaveStartDateLabel.
  ///
  /// In en, this message translates to:
  /// **'START DATE'**
  String get createLeaveStartDateLabel;

  /// No description provided for @createLeaveEndDateLabel.
  ///
  /// In en, this message translates to:
  /// **'END DATE'**
  String get createLeaveEndDateLabel;

  /// No description provided for @createLeaveDatePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'dd/mm/yyyy'**
  String get createLeaveDatePlaceholder;

  /// No description provided for @createLeaveDurationChipLabel.
  ///
  /// In en, this message translates to:
  /// **'Duration: {count, plural, one{{count} day} other{{count} days}}'**
  String createLeaveDurationChipLabel(int count);

  /// No description provided for @createLeaveReasonSectionLabel.
  ///
  /// In en, this message translates to:
  /// **'REASON FOR LEAVE'**
  String get createLeaveReasonSectionLabel;

  /// No description provided for @createLeaveReasonHint.
  ///
  /// In en, this message translates to:
  /// **'Briefly describe why you are requesting leave...'**
  String get createLeaveReasonHint;

  /// No description provided for @createLeaveCharCount.
  ///
  /// In en, this message translates to:
  /// **'{count} chars'**
  String createLeaveCharCount(int count);

  /// No description provided for @createLeaveAttachmentsSectionLabel.
  ///
  /// In en, this message translates to:
  /// **'ATTACHMENTS (OPTIONAL)'**
  String get createLeaveAttachmentsSectionLabel;

  /// No description provided for @createLeaveAttachmentsHint.
  ///
  /// In en, this message translates to:
  /// **'Tap to upload medical certificates or letters'**
  String get createLeaveAttachmentsHint;

  /// No description provided for @createLeaveSubmittingButton.
  ///
  /// In en, this message translates to:
  /// **'Submitting...'**
  String get createLeaveSubmittingButton;

  /// No description provided for @createLeaveSubmitButton.
  ///
  /// In en, this message translates to:
  /// **'Submit Request'**
  String get createLeaveSubmitButton;

  /// No description provided for @createLeaveSuccessTitle.
  ///
  /// In en, this message translates to:
  /// **'Request Submitted!'**
  String get createLeaveSuccessTitle;

  /// No description provided for @createLeaveSuccessMessage.
  ///
  /// In en, this message translates to:
  /// **'Your {type} leave request has been submitted and is pending review.'**
  String createLeaveSuccessMessage(String type);

  /// No description provided for @createLeaveBackToListButton.
  ///
  /// In en, this message translates to:
  /// **'Back to Leave Requests'**
  String get createLeaveBackToListButton;

  /// No description provided for @createLeaveSummaryTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get createLeaveSummaryTypeLabel;

  /// No description provided for @createLeaveSummaryTypeValue.
  ///
  /// In en, this message translates to:
  /// **'{type} Leave'**
  String createLeaveSummaryTypeValue(String type);

  /// No description provided for @createLeaveSummaryPeriodLabel.
  ///
  /// In en, this message translates to:
  /// **'Period'**
  String get createLeaveSummaryPeriodLabel;

  /// No description provided for @createLeaveSummaryDurationLabel.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get createLeaveSummaryDurationLabel;

  /// No description provided for @createLeaveSummaryDurationValue.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} day} other{{count} days}}'**
  String createLeaveSummaryDurationValue(int count);

  /// No description provided for @createLeaveSummaryStatusLabel.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get createLeaveSummaryStatusLabel;

  /// No description provided for @createLeaveSummaryStatusValue.
  ///
  /// In en, this message translates to:
  /// **'Pending Review'**
  String get createLeaveSummaryStatusValue;

  /// No description provided for @createLeaveNoClassOnDateError.
  ///
  /// In en, this message translates to:
  /// **'No class is scheduled on the selected date. Please choose a day you attend class.'**
  String get createLeaveNoClassOnDateError;

  /// No description provided for @createLeaveAffectedCoursesLabel.
  ///
  /// In en, this message translates to:
  /// **'COURSE(S) AFFECTED'**
  String get createLeaveAffectedCoursesLabel;

  /// No description provided for @createLeaveSummaryCoursesLabel.
  ///
  /// In en, this message translates to:
  /// **'Course(s)'**
  String get createLeaveSummaryCoursesLabel;

  /// No description provided for @financePayNowButton.
  ///
  /// In en, this message translates to:
  /// **'PAY NOW'**
  String get financePayNowButton;

  /// No description provided for @financeLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load finance data'**
  String get financeLoadError;

  /// No description provided for @financeOverviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Finance Overview'**
  String get financeOverviewTitle;

  /// No description provided for @financeOverviewSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage your tuition fees and payment history.'**
  String get financeOverviewSubtitle;

  /// No description provided for @financeTotalFeeLabel.
  ///
  /// In en, this message translates to:
  /// **'TOTAL FEE'**
  String get financeTotalFeeLabel;

  /// No description provided for @financeTotalFeeSub.
  ///
  /// In en, this message translates to:
  /// **'Total across all invoices'**
  String get financeTotalFeeSub;

  /// No description provided for @financeTotalPaidLabel.
  ///
  /// In en, this message translates to:
  /// **'TOTAL PAID'**
  String get financeTotalPaidLabel;

  /// No description provided for @financeTotalPaidSub.
  ///
  /// In en, this message translates to:
  /// **'{percent}% of total completed'**
  String financeTotalPaidSub(String percent);

  /// No description provided for @financeOutstandingLabel.
  ///
  /// In en, this message translates to:
  /// **'OUTSTANDING'**
  String get financeOutstandingLabel;

  /// No description provided for @financeActionRequired.
  ///
  /// In en, this message translates to:
  /// **'Action required'**
  String get financeActionRequired;

  /// No description provided for @financeAllFeesCleared.
  ///
  /// In en, this message translates to:
  /// **'All fees cleared'**
  String get financeAllFeesCleared;

  /// No description provided for @financeNextDueDateLabel.
  ///
  /// In en, this message translates to:
  /// **'NEXT DUE DATE'**
  String get financeNextDueDateLabel;

  /// No description provided for @financeNoPendingFees.
  ///
  /// In en, this message translates to:
  /// **'No pending fees'**
  String get financeNoPendingFees;

  /// No description provided for @financePaymentProgressTitle.
  ///
  /// In en, this message translates to:
  /// **'Payment Progress'**
  String get financePaymentProgressTitle;

  /// No description provided for @financePaidLegend.
  ///
  /// In en, this message translates to:
  /// **'Paid: {amount}'**
  String financePaidLegend(String amount);

  /// No description provided for @financeRemainingLegend.
  ///
  /// In en, this message translates to:
  /// **'Remaining: {amount}'**
  String financeRemainingLegend(String amount);

  /// No description provided for @financePaymentHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Payment History'**
  String get financePaymentHistoryTitle;

  /// No description provided for @financeNoInvoicesFound.
  ///
  /// In en, this message translates to:
  /// **'No invoices found.'**
  String get financeNoInvoicesFound;

  /// No description provided for @financeTableHeaderDescription.
  ///
  /// In en, this message translates to:
  /// **'DESCRIPTION'**
  String get financeTableHeaderDescription;

  /// No description provided for @financeTableHeaderDueDate.
  ///
  /// In en, this message translates to:
  /// **'DUE DATE'**
  String get financeTableHeaderDueDate;

  /// No description provided for @financeTableHeaderStatus.
  ///
  /// In en, this message translates to:
  /// **'STATUS'**
  String get financeTableHeaderStatus;

  /// No description provided for @financeStatusPaid.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get financeStatusPaid;

  /// No description provided for @financeStatusOverdue.
  ///
  /// In en, this message translates to:
  /// **'Overdue'**
  String get financeStatusOverdue;

  /// No description provided for @financeStatusPartial.
  ///
  /// In en, this message translates to:
  /// **'Partial'**
  String get financeStatusPartial;

  /// No description provided for @financeStatusUnpaid.
  ///
  /// In en, this message translates to:
  /// **'Unpaid'**
  String get financeStatusUnpaid;

  /// No description provided for @invoiceDetailTitle.
  ///
  /// In en, this message translates to:
  /// **'Invoice Detail'**
  String get invoiceDetailTitle;

  /// No description provided for @invoiceLoadError.
  ///
  /// In en, this message translates to:
  /// **'Failed to load invoice: {error}'**
  String invoiceLoadError(Object error);

  /// No description provided for @invoiceNotFound.
  ///
  /// In en, this message translates to:
  /// **'Invoice not found.'**
  String get invoiceNotFound;

  /// No description provided for @invoiceStatusPaid.
  ///
  /// In en, this message translates to:
  /// **'PAID'**
  String get invoiceStatusPaid;

  /// No description provided for @invoiceStatusOverdue.
  ///
  /// In en, this message translates to:
  /// **'OVERDUE'**
  String get invoiceStatusOverdue;

  /// No description provided for @invoiceStatusPartial.
  ///
  /// In en, this message translates to:
  /// **'PARTIAL'**
  String get invoiceStatusPartial;

  /// No description provided for @invoiceStatusUnpaid.
  ///
  /// In en, this message translates to:
  /// **'UNPAID'**
  String get invoiceStatusUnpaid;

  /// No description provided for @invoiceLabelBadge.
  ///
  /// In en, this message translates to:
  /// **'INVOICE'**
  String get invoiceLabelBadge;

  /// No description provided for @invoiceNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'#{id}'**
  String invoiceNumberLabel(String id);

  /// No description provided for @invoiceDueLabel.
  ///
  /// In en, this message translates to:
  /// **'Due: {date}'**
  String invoiceDueLabel(String date);

  /// No description provided for @invoicePaymentDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Payment Details'**
  String get invoicePaymentDetailsTitle;

  /// No description provided for @invoiceDescriptionRowLabel.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get invoiceDescriptionRowLabel;

  /// No description provided for @invoiceDueDateRowLabel.
  ///
  /// In en, this message translates to:
  /// **'Due Date'**
  String get invoiceDueDateRowLabel;

  /// No description provided for @invoicePaidOnRowLabel.
  ///
  /// In en, this message translates to:
  /// **'Paid On'**
  String get invoicePaidOnRowLabel;

  /// No description provided for @invoicePastDueWarning.
  ///
  /// In en, this message translates to:
  /// **'This invoice is past due.'**
  String get invoicePastDueWarning;

  /// No description provided for @invoiceTotalAmountLabel.
  ///
  /// In en, this message translates to:
  /// **'Total Amount'**
  String get invoiceTotalAmountLabel;

  /// No description provided for @paymentMethodAbaBank.
  ///
  /// In en, this message translates to:
  /// **'ABA Bank'**
  String get paymentMethodAbaBank;

  /// No description provided for @paymentMethodWing.
  ///
  /// In en, this message translates to:
  /// **'Wing'**
  String get paymentMethodWing;

  /// No description provided for @paymentMethodPiPay.
  ///
  /// In en, this message translates to:
  /// **'Pi Pay'**
  String get paymentMethodPiPay;

  /// No description provided for @paymentAmountRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter a payment amount.'**
  String get paymentAmountRequired;

  /// No description provided for @paymentAppBarTitle.
  ///
  /// In en, this message translates to:
  /// **'Online Payment'**
  String get paymentAppBarTitle;

  /// No description provided for @paymentNoOutstandingBalance.
  ///
  /// In en, this message translates to:
  /// **'No Outstanding Balance'**
  String get paymentNoOutstandingBalance;

  /// No description provided for @paymentOutstandingBalance.
  ///
  /// In en, this message translates to:
  /// **'Outstanding Balance'**
  String get paymentOutstandingBalance;

  /// No description provided for @paymentMethodSectionLabel.
  ///
  /// In en, this message translates to:
  /// **'PAYMENT METHOD'**
  String get paymentMethodSectionLabel;

  /// No description provided for @paymentAmountSectionLabel.
  ///
  /// In en, this message translates to:
  /// **'AMOUNT (USD)'**
  String get paymentAmountSectionLabel;

  /// No description provided for @paymentOrderSummaryLabel.
  ///
  /// In en, this message translates to:
  /// **'ORDER SUMMARY'**
  String get paymentOrderSummaryLabel;

  /// No description provided for @paymentStudentLabel.
  ///
  /// In en, this message translates to:
  /// **'Student'**
  String get paymentStudentLabel;

  /// No description provided for @paymentStudentIdLabel.
  ///
  /// In en, this message translates to:
  /// **'Student ID'**
  String get paymentStudentIdLabel;

  /// No description provided for @paymentMethodLabel.
  ///
  /// In en, this message translates to:
  /// **'Method'**
  String get paymentMethodLabel;

  /// No description provided for @paymentAmountLabel.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get paymentAmountLabel;

  /// No description provided for @paymentProceedButton.
  ///
  /// In en, this message translates to:
  /// **'Proceed to Pay'**
  String get paymentProceedButton;

  /// No description provided for @paymentProcessingTitle.
  ///
  /// In en, this message translates to:
  /// **'Processing Payment...'**
  String get paymentProcessingTitle;

  /// No description provided for @paymentProcessingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Please do not close this screen.'**
  String get paymentProcessingSubtitle;

  /// No description provided for @paymentSuccessTitle.
  ///
  /// In en, this message translates to:
  /// **'Payment Successful!'**
  String get paymentSuccessTitle;

  /// No description provided for @paymentSuccessSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your payment has been processed successfully.'**
  String get paymentSuccessSubtitle;

  /// No description provided for @paymentBackToFinanceButton.
  ///
  /// In en, this message translates to:
  /// **'Back to Finance'**
  String get paymentBackToFinanceButton;

  /// No description provided for @paymentReceiptNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'Receipt No.'**
  String get paymentReceiptNumberLabel;

  /// No description provided for @paymentAmountPaidLabel.
  ///
  /// In en, this message translates to:
  /// **'Amount Paid'**
  String get paymentAmountPaidLabel;

  /// No description provided for @paymentStatusLabel.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get paymentStatusLabel;

  /// No description provided for @paymentStatusPaidValue.
  ///
  /// In en, this message translates to:
  /// **'PAID'**
  String get paymentStatusPaidValue;

  /// No description provided for @paymentConfirmDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm Payment'**
  String get paymentConfirmDialogTitle;

  /// No description provided for @paymentConfirmDialogBody.
  ///
  /// In en, this message translates to:
  /// **'You are about to make the following payment:'**
  String get paymentConfirmDialogBody;

  /// No description provided for @paymentConfirmButton.
  ///
  /// In en, this message translates to:
  /// **'Confirm & Pay'**
  String get paymentConfirmButton;

  /// No description provided for @notificationsFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get notificationsFilterAll;

  /// No description provided for @notificationsFilterGrades.
  ///
  /// In en, this message translates to:
  /// **'Grades'**
  String get notificationsFilterGrades;

  /// No description provided for @notificationsFilterAttendance.
  ///
  /// In en, this message translates to:
  /// **'Attendance'**
  String get notificationsFilterAttendance;

  /// No description provided for @notificationsFilterPayment.
  ///
  /// In en, this message translates to:
  /// **'Payment'**
  String get notificationsFilterPayment;

  /// No description provided for @notificationsFilterLeave.
  ///
  /// In en, this message translates to:
  /// **'Leave'**
  String get notificationsFilterLeave;

  /// No description provided for @notificationsLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load notifications'**
  String get notificationsLoadError;

  /// No description provided for @notificationsEmptyState.
  ///
  /// In en, this message translates to:
  /// **'No notifications here.'**
  String get notificationsEmptyState;

  /// No description provided for @studentsCountLabel.
  ///
  /// In en, this message translates to:
  /// **'{count} Students'**
  String studentsCountLabel(int count);

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @loadErrorStudents.
  ///
  /// In en, this message translates to:
  /// **'Could not load students'**
  String get loadErrorStudents;

  /// No description provided for @teacherDashboardDeptLabel.
  ///
  /// In en, this message translates to:
  /// **'Dept: {dept}'**
  String teacherDashboardDeptLabel(String dept);

  /// No description provided for @teacherDashboardDefaultPosition.
  ///
  /// In en, this message translates to:
  /// **'Teacher'**
  String get teacherDashboardDefaultPosition;

  /// No description provided for @teacherDashboardStatTotalCourses.
  ///
  /// In en, this message translates to:
  /// **'Total Courses'**
  String get teacherDashboardStatTotalCourses;

  /// No description provided for @teacherDashboardStatTotalStudents.
  ///
  /// In en, this message translates to:
  /// **'Total Students'**
  String get teacherDashboardStatTotalStudents;

  /// No description provided for @teacherDashboardStatPendingLeaves.
  ///
  /// In en, this message translates to:
  /// **'Pending Leaves'**
  String get teacherDashboardStatPendingLeaves;

  /// No description provided for @teacherDashboardStatTodayClasses.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Classes'**
  String get teacherDashboardStatTodayClasses;

  /// No description provided for @teacherDashboardQuickActionMarkAttendance.
  ///
  /// In en, this message translates to:
  /// **'Mark\nAttendance'**
  String get teacherDashboardQuickActionMarkAttendance;

  /// No description provided for @teacherDashboardQuickActionAssignments.
  ///
  /// In en, this message translates to:
  /// **'Assignments'**
  String get teacherDashboardQuickActionAssignments;

  /// No description provided for @teacherDashboardQuickActionMaterials.
  ///
  /// In en, this message translates to:
  /// **'Materials'**
  String get teacherDashboardQuickActionMaterials;

  /// No description provided for @teacherDashboardQuickActionReports.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get teacherDashboardQuickActionReports;

  /// No description provided for @teacherDashboardQuickActionAnnouncements.
  ///
  /// In en, this message translates to:
  /// **'Announcements'**
  String get teacherDashboardQuickActionAnnouncements;

  /// No description provided for @teacherDashboardTodayScheduleTitle.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Schedule'**
  String get teacherDashboardTodayScheduleTitle;

  /// No description provided for @teacherDashboardFullScheduleLink.
  ///
  /// In en, this message translates to:
  /// **'Full Schedule'**
  String get teacherDashboardFullScheduleLink;

  /// No description provided for @teacherDashboardNoClassesScheduledToday.
  ///
  /// In en, this message translates to:
  /// **'No classes scheduled today'**
  String get teacherDashboardNoClassesScheduledToday;

  /// No description provided for @teacherDashboardStatusNext.
  ///
  /// In en, this message translates to:
  /// **'NEXT'**
  String get teacherDashboardStatusNext;

  /// No description provided for @teacherDashboardStatusLater.
  ///
  /// In en, this message translates to:
  /// **'LATER'**
  String get teacherDashboardStatusLater;

  /// No description provided for @teacherDashboardStatusNow.
  ///
  /// In en, this message translates to:
  /// **'NOW'**
  String get teacherDashboardStatusNow;

  /// No description provided for @teacherDashboardPendingLeaveRequestsTitle.
  ///
  /// In en, this message translates to:
  /// **'Pending Leave Requests'**
  String get teacherDashboardPendingLeaveRequestsTitle;

  /// No description provided for @teacherDashboardViewAllLink.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get teacherDashboardViewAllLink;

  /// No description provided for @teacherDashboardNoPendingRequests.
  ///
  /// In en, this message translates to:
  /// **'No pending requests'**
  String get teacherDashboardNoPendingRequests;

  /// No description provided for @teacherProfileLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load profile'**
  String get teacherProfileLoadError;

  /// No description provided for @teacherProfileNotFound.
  ///
  /// In en, this message translates to:
  /// **'Profile not found.'**
  String get teacherProfileNotFound;

  /// No description provided for @teacherProfileStatActiveCourses.
  ///
  /// In en, this message translates to:
  /// **'ACTIVE\nCOURSES'**
  String get teacherProfileStatActiveCourses;

  /// No description provided for @teacherProfileStatStudents.
  ///
  /// In en, this message translates to:
  /// **'STUDENTS'**
  String get teacherProfileStatStudents;

  /// No description provided for @teacherProfileStatCreditsPerSem.
  ///
  /// In en, this message translates to:
  /// **'CREDITS\n/ SEM'**
  String get teacherProfileStatCreditsPerSem;

  /// No description provided for @teacherProfileStatStatus.
  ///
  /// In en, this message translates to:
  /// **'STATUS'**
  String get teacherProfileStatStatus;

  /// No description provided for @teacherProfileTeachingInfoTitle.
  ///
  /// In en, this message translates to:
  /// **'Teaching Information'**
  String get teacherProfileTeachingInfoTitle;

  /// No description provided for @teacherProfileNoActiveCourses.
  ///
  /// In en, this message translates to:
  /// **'No active courses assigned.'**
  String get teacherProfileNoActiveCourses;

  /// No description provided for @teacherProfileStudentsCountLabel.
  ///
  /// In en, this message translates to:
  /// **'{count}\nStudents'**
  String teacherProfileStudentsCountLabel(int count);

  /// No description provided for @teacherProfileProfessionalInfoTitle.
  ///
  /// In en, this message translates to:
  /// **'Professional Information'**
  String get teacherProfileProfessionalInfoTitle;

  /// No description provided for @teacherProfileEmployeeIdLabel.
  ///
  /// In en, this message translates to:
  /// **'EMPLOYEE ID'**
  String get teacherProfileEmployeeIdLabel;

  /// No description provided for @teacherProfilePositionLabel.
  ///
  /// In en, this message translates to:
  /// **'POSITION'**
  String get teacherProfilePositionLabel;

  /// No description provided for @teacherProfileSpecializationLabel.
  ///
  /// In en, this message translates to:
  /// **'SPECIALIZATION'**
  String get teacherProfileSpecializationLabel;

  /// No description provided for @teacherProfileHireDateLabel.
  ///
  /// In en, this message translates to:
  /// **'HIRE DATE'**
  String get teacherProfileHireDateLabel;

  /// No description provided for @teacherProfileNotSpecified.
  ///
  /// In en, this message translates to:
  /// **'Not specified'**
  String get teacherProfileNotSpecified;

  /// No description provided for @teacherProfileDepartmentNotSet.
  ///
  /// In en, this message translates to:
  /// **'Department not set'**
  String get teacherProfileDepartmentNotSet;

  /// No description provided for @teacherScheduleTitle.
  ///
  /// In en, this message translates to:
  /// **'Academic Weekly Schedule'**
  String get teacherScheduleTitle;

  /// No description provided for @teacherScheduleNoClassesThisSemester.
  ///
  /// In en, this message translates to:
  /// **'No scheduled classes this semester.'**
  String get teacherScheduleNoClassesThisSemester;

  /// No description provided for @teacherScheduleNoScheduleData.
  ///
  /// In en, this message translates to:
  /// **'No schedule data available.'**
  String get teacherScheduleNoScheduleData;

  /// No description provided for @teacherScheduleTimeColumnHeader.
  ///
  /// In en, this message translates to:
  /// **'TIME'**
  String get teacherScheduleTimeColumnHeader;

  /// No description provided for @teacherScheduleWeeklyHoursLabel.
  ///
  /// In en, this message translates to:
  /// **'WEEKLY HOURS'**
  String get teacherScheduleWeeklyHoursLabel;

  /// No description provided for @teacherScheduleHoursValue.
  ///
  /// In en, this message translates to:
  /// **'{hours} Hours'**
  String teacherScheduleHoursValue(String hours);

  /// No description provided for @teacherScheduleTotalStudentsLabel.
  ///
  /// In en, this message translates to:
  /// **'TOTAL STUDENTS'**
  String get teacherScheduleTotalStudentsLabel;

  /// No description provided for @teacherScheduleClassesTodayLabel.
  ///
  /// In en, this message translates to:
  /// **'CLASSES TODAY'**
  String get teacherScheduleClassesTodayLabel;

  /// No description provided for @teacherScheduleClassesCountValue.
  ///
  /// In en, this message translates to:
  /// **'{count} Classes'**
  String teacherScheduleClassesCountValue(int count);

  /// No description provided for @teacherCourseListTitle.
  ///
  /// In en, this message translates to:
  /// **'My Courses'**
  String get teacherCourseListTitle;

  /// No description provided for @teacherCourseListSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage your assigned courses.'**
  String get teacherCourseListSubtitle;

  /// No description provided for @teacherCourseListSubtitleWithSemester.
  ///
  /// In en, this message translates to:
  /// **'Manage your assigned courses for {semester}.'**
  String teacherCourseListSubtitleWithSemester(String semester);

  /// No description provided for @teacherCourseListEmptyState.
  ///
  /// In en, this message translates to:
  /// **'No courses assigned yet.'**
  String get teacherCourseListEmptyState;

  /// No description provided for @teacherCourseListStudentsEnrolled.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} Student Enrolled} other{{count} Students Enrolled}}'**
  String teacherCourseListStudentsEnrolled(int count);

  /// No description provided for @teacherCourseListFilterPast.
  ///
  /// In en, this message translates to:
  /// **'Past'**
  String get teacherCourseListFilterPast;

  /// No description provided for @teacherCourseListSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search courses or codes...'**
  String get teacherCourseListSearchHint;

  /// No description provided for @teacherAnalyticsNoCurrentCourses.
  ///
  /// In en, this message translates to:
  /// **'No current courses'**
  String get teacherAnalyticsNoCurrentCourses;

  /// No description provided for @teacherAnalyticsSelectCourse.
  ///
  /// In en, this message translates to:
  /// **'Select a course'**
  String get teacherAnalyticsSelectCourse;

  /// No description provided for @teacherAnalyticsCourseNameWithCode.
  ///
  /// In en, this message translates to:
  /// **'{name} ({code})'**
  String teacherAnalyticsCourseNameWithCode(String name, String code);

  /// No description provided for @teacherAnalyticsLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load analytics'**
  String get teacherAnalyticsLoadError;

  /// No description provided for @teacherAnalyticsTitle.
  ///
  /// In en, this message translates to:
  /// **'Student Analytics'**
  String get teacherAnalyticsTitle;

  /// No description provided for @teacherAnalyticsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Performance overview for enrolled students.'**
  String get teacherAnalyticsSubtitle;

  /// No description provided for @teacherAnalyticsPerformanceRankingTitle.
  ///
  /// In en, this message translates to:
  /// **'Student Performance\nRanking'**
  String get teacherAnalyticsPerformanceRankingTitle;

  /// No description provided for @teacherAnalyticsNoGradeData.
  ///
  /// In en, this message translates to:
  /// **'No grade data yet.'**
  String get teacherAnalyticsNoGradeData;

  /// No description provided for @teacherAnalyticsGradeDistributionTitle.
  ///
  /// In en, this message translates to:
  /// **'Grade Distribution'**
  String get teacherAnalyticsGradeDistributionTitle;

  /// No description provided for @teacherAnalyticsGradeLegendLabel.
  ///
  /// In en, this message translates to:
  /// **'{grade} ({percent}%)'**
  String teacherAnalyticsGradeLegendLabel(String grade, int percent);

  /// No description provided for @teacherAnalyticsAttendanceTrendsTitle.
  ///
  /// In en, this message translates to:
  /// **'Attendance Trends'**
  String get teacherAnalyticsAttendanceTrendsTitle;

  /// No description provided for @teacherAnalyticsAveragePercentLegend.
  ///
  /// In en, this message translates to:
  /// **'Average %'**
  String get teacherAnalyticsAveragePercentLegend;

  /// No description provided for @teacherAnalyticsAtRiskStudentsTitle.
  ///
  /// In en, this message translates to:
  /// **'At-Risk Students'**
  String get teacherAnalyticsAtRiskStudentsTitle;

  /// No description provided for @teacherAnalyticsAllStudentsAboveThreshold.
  ///
  /// In en, this message translates to:
  /// **'All students are above the 75% threshold.'**
  String get teacherAnalyticsAllStudentsAboveThreshold;

  /// No description provided for @teacherAnalyticsSendAlertButton.
  ///
  /// In en, this message translates to:
  /// **'Send Alert to Guardians'**
  String get teacherAnalyticsSendAlertButton;

  /// No description provided for @teacherAnalyticsAttendancePercentLabel.
  ///
  /// In en, this message translates to:
  /// **'Attendance: {pct}%'**
  String teacherAnalyticsAttendancePercentLabel(int pct);

  /// No description provided for @markAttendanceUnmarkedWarning.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} student still unmarked.} other{{count} students still unmarked.}}'**
  String markAttendanceUnmarkedWarning(int count);

  /// No description provided for @markAttendanceSaveFailedError.
  ///
  /// In en, this message translates to:
  /// **'Failed to save attendance.'**
  String get markAttendanceSaveFailedError;

  /// No description provided for @markAttendanceEmptyState.
  ///
  /// In en, this message translates to:
  /// **'No students enrolled.'**
  String get markAttendanceEmptyState;

  /// No description provided for @markAttendanceFallbackTitle.
  ///
  /// In en, this message translates to:
  /// **'Attendance'**
  String get markAttendanceFallbackTitle;

  /// No description provided for @markAttendanceTodaySession.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Session'**
  String get markAttendanceTodaySession;

  /// No description provided for @markAttendanceInProgressLabel.
  ///
  /// In en, this message translates to:
  /// **'IN PROGRESS'**
  String get markAttendanceInProgressLabel;

  /// No description provided for @markAttendanceStudentsListLabel.
  ///
  /// In en, this message translates to:
  /// **'Students\nList'**
  String get markAttendanceStudentsListLabel;

  /// No description provided for @markAttendanceTotalCountBadge.
  ///
  /// In en, this message translates to:
  /// **'{count}\nTOTAL'**
  String markAttendanceTotalCountBadge(int count);

  /// No description provided for @markAttendanceSelectAllPresent.
  ///
  /// In en, this message translates to:
  /// **'Select All\nPresent'**
  String get markAttendanceSelectAllPresent;

  /// No description provided for @markAttendanceClearAll.
  ///
  /// In en, this message translates to:
  /// **'Clear\nAll'**
  String get markAttendanceClearAll;

  /// No description provided for @markAttendanceSavingButton.
  ///
  /// In en, this message translates to:
  /// **'Saving...'**
  String get markAttendanceSavingButton;

  /// No description provided for @markAttendanceSaveButtonLabel.
  ///
  /// In en, this message translates to:
  /// **'Save Attendance ({marked}/{total})'**
  String markAttendanceSaveButtonLabel(int marked, int total);

  /// No description provided for @markAttendanceSavedTitle.
  ///
  /// In en, this message translates to:
  /// **'Attendance Saved!'**
  String get markAttendanceSavedTitle;

  /// No description provided for @markAttendanceSessionRecordedFallback.
  ///
  /// In en, this message translates to:
  /// **'Session recorded'**
  String get markAttendanceSessionRecordedFallback;

  /// No description provided for @markAttendanceLeaveExcusedLabel.
  ///
  /// In en, this message translates to:
  /// **'Leave / Excused'**
  String get markAttendanceLeaveExcusedLabel;

  /// No description provided for @markAttendanceStudentsCountLabel.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} student} other{{count} students}}'**
  String markAttendanceStudentsCountLabel(int count);

  /// No description provided for @markAttendanceStatusLeave.
  ///
  /// In en, this message translates to:
  /// **'Leave'**
  String get markAttendanceStatusLeave;

  /// No description provided for @editAttendanceUpdatedMessage.
  ///
  /// In en, this message translates to:
  /// **'Attendance updated.'**
  String get editAttendanceUpdatedMessage;

  /// No description provided for @editAttendanceSaveFailedError.
  ///
  /// In en, this message translates to:
  /// **'Save failed: {error}'**
  String editAttendanceSaveFailedError(Object error);

  /// No description provided for @editAttendanceAppBarTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Attendance'**
  String get editAttendanceAppBarTitle;

  /// No description provided for @editAttendanceLoadingCourseName.
  ///
  /// In en, this message translates to:
  /// **'Loading…'**
  String get editAttendanceLoadingCourseName;

  /// No description provided for @editAttendanceUpdateButton.
  ///
  /// In en, this message translates to:
  /// **'Update Attendance'**
  String get editAttendanceUpdateButton;

  /// No description provided for @editAttendanceChangedBadge.
  ///
  /// In en, this message translates to:
  /// **'CHANGED'**
  String get editAttendanceChangedBadge;

  /// No description provided for @attendanceReportLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load report'**
  String get attendanceReportLoadError;

  /// No description provided for @attendanceReportTitle.
  ///
  /// In en, this message translates to:
  /// **'Attendance Report'**
  String get attendanceReportTitle;

  /// No description provided for @attendanceReportSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Analyze student participation and attendance patterns.'**
  String get attendanceReportSubtitle;

  /// No description provided for @attendanceReportExportButton.
  ///
  /// In en, this message translates to:
  /// **'Export Report'**
  String get attendanceReportExportButton;

  /// No description provided for @attendanceReportTotalSessionsLabel.
  ///
  /// In en, this message translates to:
  /// **'TOTAL SESSIONS'**
  String get attendanceReportTotalSessionsLabel;

  /// No description provided for @attendanceReportSessionsValue.
  ///
  /// In en, this message translates to:
  /// **'{count} Sessions'**
  String attendanceReportSessionsValue(int count);

  /// No description provided for @attendanceReportPresentAvgLabel.
  ///
  /// In en, this message translates to:
  /// **'PRESENT AVG'**
  String get attendanceReportPresentAvgLabel;

  /// No description provided for @attendanceReportAbsentAvgLabel.
  ///
  /// In en, this message translates to:
  /// **'ABSENT AVG'**
  String get attendanceReportAbsentAvgLabel;

  /// No description provided for @attendanceReportStudentRecordsTitle.
  ///
  /// In en, this message translates to:
  /// **'Student Records'**
  String get attendanceReportStudentRecordsTitle;

  /// No description provided for @attendanceReportNoDataMessage.
  ///
  /// In en, this message translates to:
  /// **'No attendance data yet.'**
  String get attendanceReportNoDataMessage;

  /// No description provided for @attendanceReportShowingAllLabel.
  ///
  /// In en, this message translates to:
  /// **'Showing all {count} students'**
  String attendanceReportShowingAllLabel(int count);

  /// No description provided for @attendanceReportStudentNameHeader.
  ///
  /// In en, this message translates to:
  /// **'STUDENT\nNAME'**
  String get attendanceReportStudentNameHeader;

  /// No description provided for @attendanceReportPresentHeader.
  ///
  /// In en, this message translates to:
  /// **'PRESENT'**
  String get attendanceReportPresentHeader;

  /// No description provided for @attendanceReportAbsentHeader.
  ///
  /// In en, this message translates to:
  /// **'ABSENT'**
  String get attendanceReportAbsentHeader;

  /// No description provided for @gradeManagementTitle.
  ///
  /// In en, this message translates to:
  /// **'Grade Management'**
  String get gradeManagementTitle;

  /// No description provided for @gradeManagementLoadingCourse.
  ///
  /// In en, this message translates to:
  /// **'Loading course...'**
  String get gradeManagementLoadingCourse;

  /// No description provided for @gradeManagementEmptyState.
  ///
  /// In en, this message translates to:
  /// **'No students enrolled in this course.'**
  String get gradeManagementEmptyState;

  /// No description provided for @gradeManagementSaveSuccess.
  ///
  /// In en, this message translates to:
  /// **'Grades saved successfully.'**
  String get gradeManagementSaveSuccess;

  /// No description provided for @gradeManagementSaveError.
  ///
  /// In en, this message translates to:
  /// **'Failed to save grades: {error}'**
  String gradeManagementSaveError(Object error);

  /// No description provided for @gradeManagementSaving.
  ///
  /// In en, this message translates to:
  /// **'Saving…'**
  String get gradeManagementSaving;

  /// No description provided for @gradeManagementSaveButton.
  ///
  /// In en, this message translates to:
  /// **'Save Grades'**
  String get gradeManagementSaveButton;

  /// No description provided for @gradeManagementParticipationLabel.
  ///
  /// In en, this message translates to:
  /// **'Participation'**
  String get gradeManagementParticipationLabel;

  /// No description provided for @gradeManagementStudentsEnrolledCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} Student Enrolled} other{{count} Students Enrolled}}'**
  String gradeManagementStudentsEnrolledCount(int count);

  /// No description provided for @gradeManagementMaxScoreLabel.
  ///
  /// In en, this message translates to:
  /// **'/ 100'**
  String get gradeManagementMaxScoreLabel;

  /// No description provided for @createAssessmentTitle.
  ///
  /// In en, this message translates to:
  /// **'Create Assessment'**
  String get createAssessmentTitle;

  /// No description provided for @createAssessmentValidationError.
  ///
  /// In en, this message translates to:
  /// **'Please fill in Title, Type and Max Score.'**
  String get createAssessmentValidationError;

  /// No description provided for @createAssessmentBreadcrumbNew.
  ///
  /// In en, this message translates to:
  /// **'New Assessment'**
  String get createAssessmentBreadcrumbNew;

  /// No description provided for @createAssessmentTitleFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'Assessment Title'**
  String get createAssessmentTitleFieldLabel;

  /// No description provided for @createAssessmentTitleHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Mid-term Research Paper'**
  String get createAssessmentTitleHint;

  /// No description provided for @createAssessmentTypeFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get createAssessmentTypeFieldLabel;

  /// No description provided for @createAssessmentMaxScoreFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'Max Score'**
  String get createAssessmentMaxScoreFieldLabel;

  /// No description provided for @createAssessmentDueDateFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'Due Date & Time'**
  String get createAssessmentDueDateFieldLabel;

  /// No description provided for @createAssessmentDueDatePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'mm/dd/yyyy, --:-- --'**
  String get createAssessmentDueDatePlaceholder;

  /// No description provided for @createAssessmentDescriptionFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get createAssessmentDescriptionFieldLabel;

  /// No description provided for @createAssessmentDescriptionHint.
  ///
  /// In en, this message translates to:
  /// **'Provide detailed instructions for the students...'**
  String get createAssessmentDescriptionHint;

  /// No description provided for @createAssessmentAttachmentsFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'Attachments'**
  String get createAssessmentAttachmentsFieldLabel;

  /// No description provided for @createAssessmentSelectTypeHint.
  ///
  /// In en, this message translates to:
  /// **'Select assessment type'**
  String get createAssessmentSelectTypeHint;

  /// No description provided for @createAssessmentTypeQuiz.
  ///
  /// In en, this message translates to:
  /// **'Quiz'**
  String get createAssessmentTypeQuiz;

  /// No description provided for @createAssessmentTypeLabReport.
  ///
  /// In en, this message translates to:
  /// **'Lab Report'**
  String get createAssessmentTypeLabReport;

  /// No description provided for @createAssessmentTypeProject.
  ///
  /// In en, this message translates to:
  /// **'Project'**
  String get createAssessmentTypeProject;

  /// No description provided for @createAssessmentUploadZoneTitle.
  ///
  /// In en, this message translates to:
  /// **'Click or drag and drop to upload files'**
  String get createAssessmentUploadZoneTitle;

  /// No description provided for @createAssessmentUploadZoneSubtitle.
  ///
  /// In en, this message translates to:
  /// **'PDF, DOCX, ZIP (Max 50MB)'**
  String get createAssessmentUploadZoneSubtitle;

  /// No description provided for @createAssessmentQuickTipTitle.
  ///
  /// In en, this message translates to:
  /// **'Quick Tip'**
  String get createAssessmentQuickTipTitle;

  /// No description provided for @createAssessmentQuickTipBody.
  ///
  /// In en, this message translates to:
  /// **'Scheduled assessments will automatically alert all enrolled students via push notifications.'**
  String get createAssessmentQuickTipBody;

  /// No description provided for @createAssessmentVisibilityTitle.
  ///
  /// In en, this message translates to:
  /// **'Visibility'**
  String get createAssessmentVisibilityTitle;

  /// No description provided for @createAssessmentVisibilityBody.
  ///
  /// In en, this message translates to:
  /// **'This assessment will be saved as a draft and hidden until you toggle \'Publish\'.'**
  String get createAssessmentVisibilityBody;

  /// No description provided for @createAssessmentSuccessTitle.
  ///
  /// In en, this message translates to:
  /// **'Assessment Created!'**
  String get createAssessmentSuccessTitle;

  /// No description provided for @createAssessmentSuccessMessage.
  ///
  /// In en, this message translates to:
  /// **'\"{title}\" has been saved as a draft. Students will be notified when published.'**
  String createAssessmentSuccessMessage(String title);

  /// No description provided for @createAssessmentBackToCourseButton.
  ///
  /// In en, this message translates to:
  /// **'Back to Course'**
  String get createAssessmentBackToCourseButton;

  /// No description provided for @leaveManagementSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Review and decide on absence submissions for your students.'**
  String get leaveManagementSubtitle;

  /// No description provided for @leaveManagementFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All Requests'**
  String get leaveManagementFilterAll;

  /// No description provided for @leaveManagementEmptyState.
  ///
  /// In en, this message translates to:
  /// **'No requests found'**
  String get leaveManagementEmptyState;

  /// No description provided for @leaveManagementTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Type: {type}'**
  String leaveManagementTypeLabel(String type);

  /// No description provided for @leaveManagementDatesLabel.
  ///
  /// In en, this message translates to:
  /// **'Dates: {range}'**
  String leaveManagementDatesLabel(String range);

  /// No description provided for @leaveManagementViewDetailsButton.
  ///
  /// In en, this message translates to:
  /// **'View Details'**
  String get leaveManagementViewDetailsButton;

  /// No description provided for @leaveReviewAppBarTitle.
  ///
  /// In en, this message translates to:
  /// **'Leave Request Details'**
  String get leaveReviewAppBarTitle;

  /// No description provided for @leaveReviewApproveDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Approve Leave Request'**
  String get leaveReviewApproveDialogTitle;

  /// No description provided for @leaveReviewRejectDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Reject Leave Request'**
  String get leaveReviewRejectDialogTitle;

  /// No description provided for @leaveReviewNotesHint.
  ///
  /// In en, this message translates to:
  /// **'Optional reviewer notes...'**
  String get leaveReviewNotesHint;

  /// No description provided for @leaveReviewApproveButton.
  ///
  /// In en, this message translates to:
  /// **'Approve'**
  String get leaveReviewApproveButton;

  /// No description provided for @leaveReviewRejectButton.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get leaveReviewRejectButton;

  /// No description provided for @leaveReviewApprovedSnackbar.
  ///
  /// In en, this message translates to:
  /// **'Leave request approved.'**
  String get leaveReviewApprovedSnackbar;

  /// No description provided for @leaveReviewRejectedSnackbar.
  ///
  /// In en, this message translates to:
  /// **'Leave request rejected.'**
  String get leaveReviewRejectedSnackbar;

  /// No description provided for @leaveReviewSubmitError.
  ///
  /// In en, this message translates to:
  /// **'Failed to submit decision. Please try again.'**
  String get leaveReviewSubmitError;

  /// No description provided for @leaveReviewAttendanceSummaryTitle.
  ///
  /// In en, this message translates to:
  /// **'Attendance Summary'**
  String get leaveReviewAttendanceSummaryTitle;

  /// No description provided for @leaveReviewTotalRecordsLabel.
  ///
  /// In en, this message translates to:
  /// **'Total Records (Sem)'**
  String get leaveReviewTotalRecordsLabel;

  /// No description provided for @leaveReviewSessionsCountValue.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} Session} other{{count} Sessions}}'**
  String leaveReviewSessionsCountValue(int count);

  /// No description provided for @leaveReviewCategoryLabel.
  ///
  /// In en, this message translates to:
  /// **'LEAVE CATEGORY'**
  String get leaveReviewCategoryLabel;

  /// No description provided for @leaveReviewSubmittedLabel.
  ///
  /// In en, this message translates to:
  /// **'SUBMITTED'**
  String get leaveReviewSubmittedLabel;

  /// No description provided for @leaveReviewDaysCountValue.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{{count} Day} other{{count} Days}}'**
  String leaveReviewDaysCountValue(int count);

  /// No description provided for @leaveReviewReasonTitle.
  ///
  /// In en, this message translates to:
  /// **'Reason'**
  String get leaveReviewReasonTitle;

  /// No description provided for @leaveReviewReasonQuoted.
  ///
  /// In en, this message translates to:
  /// **'\"{reason}\"'**
  String leaveReviewReasonQuoted(String reason);

  /// No description provided for @leaveReviewAttachmentTitle.
  ///
  /// In en, this message translates to:
  /// **'Attachment'**
  String get leaveReviewAttachmentTitle;

  /// No description provided for @leaveReviewDecisionTitle.
  ///
  /// In en, this message translates to:
  /// **'Decision'**
  String get leaveReviewDecisionTitle;

  /// No description provided for @leaveReviewAwaitingReviewText.
  ///
  /// In en, this message translates to:
  /// **'Awaiting your review.'**
  String get leaveReviewAwaitingReviewText;

  /// No description provided for @leaveReviewReviewerNotesLabel.
  ///
  /// In en, this message translates to:
  /// **'REVIEWER NOTES'**
  String get leaveReviewReviewerNotesLabel;

  /// No description provided for @createAnnouncementValidationError.
  ///
  /// In en, this message translates to:
  /// **'Please fill in the title and content.'**
  String get createAnnouncementValidationError;

  /// No description provided for @createAnnouncementPostError.
  ///
  /// In en, this message translates to:
  /// **'Failed to post announcement.'**
  String get createAnnouncementPostError;

  /// No description provided for @createAnnouncementDraftSavedSnackbar.
  ///
  /// In en, this message translates to:
  /// **'Saved as draft.'**
  String get createAnnouncementDraftSavedSnackbar;

  /// No description provided for @createAnnouncementTitle.
  ///
  /// In en, this message translates to:
  /// **'Create Announcement'**
  String get createAnnouncementTitle;

  /// No description provided for @createAnnouncementSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Broadcast information to students and faculty members.'**
  String get createAnnouncementSubtitle;

  /// No description provided for @createAnnouncementTitleFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'ANNOUNCEMENT TITLE'**
  String get createAnnouncementTitleFieldLabel;

  /// No description provided for @createAnnouncementTitleHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., Upcoming Midterm Examination Schedule'**
  String get createAnnouncementTitleHint;

  /// No description provided for @createAnnouncementContentLabel.
  ///
  /// In en, this message translates to:
  /// **'CONTENT'**
  String get createAnnouncementContentLabel;

  /// No description provided for @createAnnouncementContentHint.
  ///
  /// In en, this message translates to:
  /// **'Write your announcement details here...'**
  String get createAnnouncementContentHint;

  /// No description provided for @createAnnouncementAttachFilesButton.
  ///
  /// In en, this message translates to:
  /// **'Attach Files'**
  String get createAnnouncementAttachFilesButton;

  /// No description provided for @createAnnouncementScheduleButton.
  ///
  /// In en, this message translates to:
  /// **'Schedule'**
  String get createAnnouncementScheduleButton;

  /// No description provided for @createAnnouncementPublicationSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Publication Settings'**
  String get createAnnouncementPublicationSettingsTitle;

  /// No description provided for @createAnnouncementRecipientScopeLabel.
  ///
  /// In en, this message translates to:
  /// **'RECIPIENT SCOPE'**
  String get createAnnouncementRecipientScopeLabel;

  /// No description provided for @createAnnouncementSendEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Send Email Notification'**
  String get createAnnouncementSendEmailLabel;

  /// No description provided for @createAnnouncementPushNotifLabel.
  ///
  /// In en, this message translates to:
  /// **'Push Notification (App)'**
  String get createAnnouncementPushNotifLabel;

  /// No description provided for @createAnnouncementAllStudentsChip.
  ///
  /// In en, this message translates to:
  /// **'All Students'**
  String get createAnnouncementAllStudentsChip;

  /// No description provided for @createAnnouncementSpecificCourseChip.
  ///
  /// In en, this message translates to:
  /// **'Specific Course'**
  String get createAnnouncementSpecificCourseChip;

  /// No description provided for @createAnnouncementLivePreviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Live Preview'**
  String get createAnnouncementLivePreviewTitle;

  /// No description provided for @createAnnouncementLivePreviewSubtitle.
  ///
  /// In en, this message translates to:
  /// **'See how your announcement will appear to the selected audience.'**
  String get createAnnouncementLivePreviewSubtitle;

  /// No description provided for @createAnnouncementPreviewAsStudentButton.
  ///
  /// In en, this message translates to:
  /// **'Preview as Student'**
  String get createAnnouncementPreviewAsStudentButton;

  /// No description provided for @createAnnouncementPostButton.
  ///
  /// In en, this message translates to:
  /// **'Post Announcement'**
  String get createAnnouncementPostButton;

  /// No description provided for @createAnnouncementSaveDraftButton.
  ///
  /// In en, this message translates to:
  /// **'Save as Draft'**
  String get createAnnouncementSaveDraftButton;

  /// No description provided for @createAnnouncementSuccessTitle.
  ///
  /// In en, this message translates to:
  /// **'Announcement Posted!'**
  String get createAnnouncementSuccessTitle;

  /// No description provided for @createAnnouncementSuccessMessage.
  ///
  /// In en, this message translates to:
  /// **'\"{title}\" has been posted successfully.'**
  String createAnnouncementSuccessMessage(String title);

  /// No description provided for @uploadMaterialsValidationError.
  ///
  /// In en, this message translates to:
  /// **'Please enter a material title.'**
  String get uploadMaterialsValidationError;

  /// No description provided for @uploadMaterialsFilePlaceholderSnackbar.
  ///
  /// In en, this message translates to:
  /// **'\"{title}\" — select a file to upload.'**
  String uploadMaterialsFilePlaceholderSnackbar(String title);

  /// No description provided for @uploadMaterialsDropzoneText.
  ///
  /// In en, this message translates to:
  /// **'Drag and drop or tap to upload'**
  String get uploadMaterialsDropzoneText;

  /// No description provided for @uploadMaterialsSupportedFormatsText.
  ///
  /// In en, this message translates to:
  /// **'Supported formats: PDF, MP4, PPTX, DOCX\n(Max 100MB)'**
  String get uploadMaterialsSupportedFormatsText;

  /// No description provided for @uploadMaterialsTitleFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'Material Title'**
  String get uploadMaterialsTitleFieldLabel;

  /// No description provided for @uploadMaterialsTitleHint.
  ///
  /// In en, this message translates to:
  /// **'Enter title for this material...'**
  String get uploadMaterialsTitleHint;

  /// No description provided for @uploadMaterialsUploadButton.
  ///
  /// In en, this message translates to:
  /// **'Upload'**
  String get uploadMaterialsUploadButton;

  /// No description provided for @uploadMaterialsListTitle.
  ///
  /// In en, this message translates to:
  /// **'Uploaded Materials'**
  String get uploadMaterialsListTitle;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'km'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'km':
      return AppLocalizationsKm();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
