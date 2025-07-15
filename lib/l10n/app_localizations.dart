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

  /// No description provided for @signupTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signupTitle;

  /// No description provided for @emailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailLabel;

  /// No description provided for @passwordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordLabel;

  /// No description provided for @confirmPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPasswordLabel;

  /// No description provided for @signInButton.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signInButton;

  /// No description provided for @signUpButton.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUpButton;

  /// No description provided for @noAccountPrompt.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? Sign Up'**
  String get noAccountPrompt;

  /// No description provided for @haveAccountPrompt.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Sign In'**
  String get haveAccountPrompt;

  /// No description provided for @loginSuccessMessage.
  ///
  /// In en, this message translates to:
  /// **'Logged in successfully!'**
  String get loginSuccessMessage;

  /// No description provided for @signupSuccessMessage.
  ///
  /// In en, this message translates to:
  /// **'Account created successfully! Please check your email to verify.'**
  String get signupSuccessMessage;

  /// No description provided for @authErrorMessage.
  ///
  /// In en, this message translates to:
  /// **'Authentication Error: {error}'**
  String authErrorMessage(Object error);

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
