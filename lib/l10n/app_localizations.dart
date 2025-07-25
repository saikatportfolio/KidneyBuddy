import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_bn.dart';
import 'app_localizations_en.dart';
import 'app_localizations_hi.dart';

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
    Locale('bn'),
    Locale('en'),
    Locale('hi'),
  ];

  /// No description provided for @welcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to KidneyBuddy'**
  String get welcomeTitle;

  /// No description provided for @welcomeDescription.
  ///
  /// In en, this message translates to:
  /// **'This app is designed to simplify life for CKD patients by helping them manage their condition and prevent further Progression'**
  String get welcomeDescription;

  /// No description provided for @renalDietTitle.
  ///
  /// In en, this message translates to:
  /// **'Renal Diet Management'**
  String get renalDietTitle;

  /// No description provided for @renalDietDescription.
  ///
  /// In en, this message translates to:
  /// **'Maintain a proper renal diet with personalized guidance and easy-to-follow meal plans tailored to your CKD stage.'**
  String get renalDietDescription;

  /// No description provided for @vitalTrackingOnboardingTitle.
  ///
  /// In en, this message translates to:
  /// **'Empower Your Health with Vital Tracking'**
  String get vitalTrackingOnboardingTitle;

  /// No description provided for @vitalTrackingOnboardingDescription.
  ///
  /// In en, this message translates to:
  /// **'Keep a close eye on key health metrics like blood pressure, weight and fluid. Understand your trends and share data with your care team for better management.'**
  String get vitalTrackingOnboardingDescription;

  /// No description provided for @connectDieticiansTitle.
  ///
  /// In en, this message translates to:
  /// **'Connect with Dieticians'**
  String get connectDieticiansTitle;

  /// No description provided for @connectDieticiansDescription.
  ///
  /// In en, this message translates to:
  /// **'Easily connect with the best dieticians for personalized consultations and expert advice to support your kidney health journey.'**
  String get connectDieticiansDescription;

  /// No description provided for @getStartedButton.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStartedButton;

  /// No description provided for @nextButton.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get nextButton;

  /// No description provided for @patientDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Patient Details'**
  String get patientDetailsTitle;

  /// No description provided for @nameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get nameLabel;

  /// No description provided for @phoneNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumberLabel;

  /// No description provided for @weightLabel.
  ///
  /// In en, this message translates to:
  /// **'Weight (kg)'**
  String get weightLabel;

  /// No description provided for @heightLabel.
  ///
  /// In en, this message translates to:
  /// **'Height (cm)'**
  String get heightLabel;

  /// No description provided for @ckdStageLabel.
  ///
  /// In en, this message translates to:
  /// **'CKD Stage'**
  String get ckdStageLabel;

  /// No description provided for @saveDetailsButton.
  ///
  /// In en, this message translates to:
  /// **'Save Details'**
  String get saveDetailsButton;

  /// No description provided for @feedbackPageTitle.
  ///
  /// In en, this message translates to:
  /// **'Give Your Feedback'**
  String get feedbackPageTitle;

  /// No description provided for @yourNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Your Name'**
  String get yourNameLabel;

  /// No description provided for @yourPhoneNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'Your Phone Number'**
  String get yourPhoneNumberLabel;

  /// No description provided for @yourFeedbackLabel.
  ///
  /// In en, this message translates to:
  /// **'Your Feedback'**
  String get yourFeedbackLabel;

  /// No description provided for @writeFeedbackHint.
  ///
  /// In en, this message translates to:
  /// **'Write your feedback here...'**
  String get writeFeedbackHint;

  /// No description provided for @submitFeedbackButton.
  ///
  /// In en, this message translates to:
  /// **'Submit Feedback'**
  String get submitFeedbackButton;

  /// No description provided for @feedbackSubmittedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Feedback submitted successfully!'**
  String get feedbackSubmittedSuccess;

  /// No description provided for @contactDieticianTitle.
  ///
  /// In en, this message translates to:
  /// **'Contact Dietician'**
  String get contactDieticianTitle;

  /// No description provided for @noDieticiansFound.
  ///
  /// In en, this message translates to:
  /// **'No dieticians found.'**
  String get noDieticiansFound;

  /// No description provided for @errorFetchingDieticians.
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String errorFetchingDieticians(Object error);

  /// No description provided for @experienceLabel.
  ///
  /// In en, this message translates to:
  /// **'Experience: {experience}'**
  String experienceLabel(Object experience);

  /// No description provided for @specialtyLabel.
  ///
  /// In en, this message translates to:
  /// **'Specialty: {specialty}'**
  String specialtyLabel(Object specialty);

  /// No description provided for @educationLabel.
  ///
  /// In en, this message translates to:
  /// **'Education: {education}'**
  String educationLabel(Object education);

  /// No description provided for @contactWhatsappButton.
  ///
  /// In en, this message translates to:
  /// **'Contact via WhatsApp'**
  String get contactWhatsappButton;

  /// No description provided for @couldNotLaunchWhatsapp.
  ///
  /// In en, this message translates to:
  /// **'Could not launch WhatsApp. Make sure it is installed.'**
  String get couldNotLaunchWhatsapp;

  /// No description provided for @homePageTitle.
  ///
  /// In en, this message translates to:
  /// **'KidneyBuddy'**
  String get homePageTitle;

  /// No description provided for @dietManagementCard.
  ///
  /// In en, this message translates to:
  /// **'Diet Management'**
  String get dietManagementCard;

  /// No description provided for @dietManagementDescription.
  ///
  /// In en, this message translates to:
  /// **'Manage your diet with personalized recommendations.'**
  String get dietManagementDescription;

  /// No description provided for @vitalMonitoringCard.
  ///
  /// In en, this message translates to:
  /// **'Vital Monitoring'**
  String get vitalMonitoringCard;

  /// No description provided for @vitalMonitoringDescription.
  ///
  /// In en, this message translates to:
  /// **'Track and monitor your vital signs.'**
  String get vitalMonitoringDescription;

  /// No description provided for @eGFRCalculatorCard.
  ///
  /// In en, this message translates to:
  /// **'eGFR Calculator'**
  String get eGFRCalculatorCard;

  /// No description provided for @eGFRCalculatorDescription.
  ///
  /// In en, this message translates to:
  /// **'Calculate your eGFR to assess kidney function.'**
  String get eGFRCalculatorDescription;

  /// No description provided for @contactDieticianCard.
  ///
  /// In en, this message translates to:
  /// **'Contact Dietician'**
  String get contactDieticianCard;

  /// No description provided for @contactDieticianDescription.
  ///
  /// In en, this message translates to:
  /// **'Connect with expert dieticians for personalized advice.'**
  String get contactDieticianDescription;

  /// No description provided for @giveYourFeedbackCard.
  ///
  /// In en, this message translates to:
  /// **'Give your Feedback'**
  String get giveYourFeedbackCard;

  /// No description provided for @giveYourFeedbackDescription.
  ///
  /// In en, this message translates to:
  /// **'Share your thoughts and help us improve the app.'**
  String get giveYourFeedbackDescription;

  /// No description provided for @notYetImplemented.
  ///
  /// In en, this message translates to:
  /// **'Navigating to {title} (Not yet implemented)'**
  String notYetImplemented(Object title);

  /// No description provided for @notificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsTitle;

  /// No description provided for @noNewNotifications.
  ///
  /// In en, this message translates to:
  /// **'You have no new notifications.'**
  String get noNewNotifications;

  /// No description provided for @checkBackLater.
  ///
  /// In en, this message translates to:
  /// **'Check back later for updates!'**
  String get checkBackLater;

  /// No description provided for @selectLanguageTitle.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguageTitle;

  /// No description provided for @chooseYourLanguage.
  ///
  /// In en, this message translates to:
  /// **'Choose your preferred language'**
  String get chooseYourLanguage;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @hindi.
  ///
  /// In en, this message translates to:
  /// **'Hindi'**
  String get hindi;

  /// No description provided for @bengali.
  ///
  /// In en, this message translates to:
  /// **'Bengali'**
  String get bengali;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @languageSetting.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageSetting;

  /// No description provided for @vitalTrackingPageTitle.
  ///
  /// In en, this message translates to:
  /// **'Vital Tracking'**
  String get vitalTrackingPageTitle;

  /// No description provided for @bpTab.
  ///
  /// In en, this message translates to:
  /// **'Blood Pressure'**
  String get bpTab;

  /// No description provided for @creatinineTab.
  ///
  /// In en, this message translates to:
  /// **'Creatinine'**
  String get creatinineTab;

  /// No description provided for @potassiumTab.
  ///
  /// In en, this message translates to:
  /// **'Potassium'**
  String get potassiumTab;

  /// No description provided for @noDataAvailable.
  ///
  /// In en, this message translates to:
  /// **'No data available for this category.'**
  String get noDataAvailable;

  /// No description provided for @addBpButton.
  ///
  /// In en, this message translates to:
  /// **'Add Blood Pressure'**
  String get addBpButton;

  /// No description provided for @addCreatinineButton.
  ///
  /// In en, this message translates to:
  /// **'Add Creatinine'**
  String get addCreatinineButton;

  /// No description provided for @addPotassiumButton.
  ///
  /// In en, this message translates to:
  /// **'Add Potassium'**
  String get addPotassiumButton;

  /// No description provided for @addBpPageTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Blood Pressure Reading'**
  String get addBpPageTitle;

  /// No description provided for @systolicLabel.
  ///
  /// In en, this message translates to:
  /// **'Systolic'**
  String get systolicLabel;

  /// No description provided for @diastolicLabel.
  ///
  /// In en, this message translates to:
  /// **'Diastolic'**
  String get diastolicLabel;

  /// No description provided for @systolic.
  ///
  /// In en, this message translates to:
  /// **'Systolic'**
  String get systolic;

  /// No description provided for @diastolic.
  ///
  /// In en, this message translates to:
  /// **'Diastolic'**
  String get diastolic;

  /// No description provided for @addCommentLabel.
  ///
  /// In en, this message translates to:
  /// **'Add Comment'**
  String get addCommentLabel;

  /// No description provided for @selectDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Select Date'**
  String get selectDateLabel;

  /// No description provided for @selectTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'Select Time'**
  String get selectTimeLabel;

  /// No description provided for @saveButton.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get saveButton;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get loginTitle;

  /// No description provided for @loginSuccessMessage.
  ///
  /// In en, this message translates to:
  /// **'Logged in successfully!'**
  String get loginSuccessMessage;

  /// No description provided for @authErrorMessage.
  ///
  /// In en, this message translates to:
  /// **'Authentication Error: {error}'**
  String authErrorMessage(Object error);

  /// No description provided for @signInWithGoogleButton.
  ///
  /// In en, this message translates to:
  /// **'Sign in with Google'**
  String get signInWithGoogleButton;

  /// No description provided for @authScreenNewTitle.
  ///
  /// In en, this message translates to:
  /// **'Your Partner in Kidney Health'**
  String get authScreenNewTitle;

  /// No description provided for @authScreenNewDescription.
  ///
  /// In en, this message translates to:
  /// **'Manage your CKD journey with personalized diet plans, vital tracking, and expert dietician support.'**
  String get authScreenNewDescription;

  /// No description provided for @pdfGenerationErrorNoPatientDetails.
  ///
  /// In en, this message translates to:
  /// **'Patient details not available for PDF report. Please update your profile.'**
  String get pdfGenerationErrorNoPatientDetails;

  /// No description provided for @pdfGenerationErrorNoReadings.
  ///
  /// In en, this message translates to:
  /// **'No blood pressure readings available to generate a PDF report.'**
  String get pdfGenerationErrorNoReadings;

  /// No description provided for @pdfGenerationError.
  ///
  /// In en, this message translates to:
  /// **'Error generating PDF report: {error}'**
  String pdfGenerationError(Object error);

  /// No description provided for @userNotLoggedIn.
  ///
  /// In en, this message translates to:
  /// **'User not logged in. Please sign in to view this content.'**
  String get userNotLoggedIn;

  /// No description provided for @signOutButton.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signOutButton;

  /// No description provided for @signOutConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to sign out?'**
  String get signOutConfirmation;

  /// No description provided for @yesButton.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yesButton;

  /// No description provided for @noButton.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get noButton;

  /// No description provided for @exportPdfButton.
  ///
  /// In en, this message translates to:
  /// **'Export PDF'**
  String get exportPdfButton;

  /// No description provided for @filter.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get filter;

  /// No description provided for @filterLastWeek.
  ///
  /// In en, this message translates to:
  /// **'Last 1 Week'**
  String get filterLastWeek;

  /// No description provided for @filterLastMonth.
  ///
  /// In en, this message translates to:
  /// **'Last 1 Month'**
  String get filterLastMonth;

  /// No description provided for @filterLast3Months.
  ///
  /// In en, this message translates to:
  /// **'Last 3 Months'**
  String get filterLast3Months;

  /// No description provided for @filterLast6Months.
  ///
  /// In en, this message translates to:
  /// **'Last 6 Months'**
  String get filterLast6Months;

  /// No description provided for @filterAllTime.
  ///
  /// In en, this message translates to:
  /// **'All Time'**
  String get filterAllTime;

  /// No description provided for @trend.
  ///
  /// In en, this message translates to:
  /// **'Trend'**
  String get trend;

  /// No description provided for @bpTrend.
  ///
  /// In en, this message translates to:
  /// **'BP Trend'**
  String get bpTrend;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @deleteConfirmationTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Confirmation'**
  String get deleteConfirmationTitle;

  /// No description provided for @deleteBpReadingConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Do you want to delete this BP reading?'**
  String get deleteBpReadingConfirmation;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @bpReadingDeletedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'BP reading deleted successfully!'**
  String get bpReadingDeletedSuccessfully;

  /// No description provided for @errorDeletingBpReading.
  ///
  /// In en, this message translates to:
  /// **'Error deleting BP reading: {error}'**
  String errorDeletingBpReading(Object error);

  /// No description provided for @addCreatineReading.
  ///
  /// In en, this message translates to:
  /// **'Add Creatine Reading'**
  String get addCreatineReading;

  /// No description provided for @deleteCreatineReadingConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Do you want to delete this Creatine reading?'**
  String get deleteCreatineReadingConfirmation;

  /// No description provided for @creatineReadingDeletedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Creatine reading deleted successfully!'**
  String get creatineReadingDeletedSuccessfully;

  /// No description provided for @errorDeletingCreatineReading.
  ///
  /// In en, this message translates to:
  /// **'Error deleting Creatine reading: {error}'**
  String errorDeletingCreatineReading(Object error);

  /// No description provided for @creatineSavedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Creatine reading saved successfully!'**
  String get creatineSavedSuccess;

  /// No description provided for @creatineSaveError.
  ///
  /// In en, this message translates to:
  /// **'Error saving Creatine reading: {error}'**
  String creatineSaveError(Object error);

  /// No description provided for @selectDateAndTimeError.
  ///
  /// In en, this message translates to:
  /// **'Please select a date and time'**
  String get selectDateAndTimeError;

  /// No description provided for @addYourComment.
  ///
  /// In en, this message translates to:
  /// **'Add Your Comment'**
  String get addYourComment;

  /// No description provided for @creatine.
  ///
  /// In en, this message translates to:
  /// **'Creatine'**
  String get creatine;

  /// No description provided for @sys.
  ///
  /// In en, this message translates to:
  /// **'SYS'**
  String get sys;

  /// No description provided for @dia.
  ///
  /// In en, this message translates to:
  /// **'DIA'**
  String get dia;

  /// No description provided for @selectDate.
  ///
  /// In en, this message translates to:
  /// **'Select date'**
  String get selectDate;

  /// No description provided for @selectTime.
  ///
  /// In en, this message translates to:
  /// **'Select Time'**
  String get selectTime;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @addCreatine.
  ///
  /// In en, this message translates to:
  /// **'Add Creatine'**
  String get addCreatine;
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
      <String>['bn', 'en', 'hi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'bn':
      return AppLocalizationsBn();
    case 'en':
      return AppLocalizationsEn();
    case 'hi':
      return AppLocalizationsHi();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
