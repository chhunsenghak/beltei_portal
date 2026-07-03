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
