// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get welcomeTitle => 'Welcome to KidneyBuddy';

  @override
  String get welcomeDescription =>
      'This app is designed to simplify life for CKD patients by helping them manage their condition and prevent further Progression';

  @override
  String get renalDietTitle => 'Renal Diet Management';

  @override
  String get renalDietDescription =>
      'Maintain a proper renal diet with personalized guidance and easy-to-follow meal plans tailored to your CKD stage.';

  @override
  String get vitalTrackingOnboardingTitle =>
      'Empower Your Health with Vital Tracking';

  @override
  String get vitalTrackingOnboardingDescription =>
      'Keep a close eye on key health metrics like blood pressure, weight and fluid. Understand your trends and share data with your care team for better management.';

  @override
  String get connectDieticiansTitle => 'Connect with Dieticians';

  @override
  String get connectDieticiansDescription =>
      'Easily connect with the best dieticians for personalized consultations and expert advice to support your kidney health journey.';

  @override
  String get getStartedButton => 'Get Started';

  @override
  String get nextButton => 'Next';

  @override
  String get patientDetailsTitle => 'Patient Details';

  @override
  String get nameLabel => 'Name';

  @override
  String get phoneNumberLabel => 'Phone Number';

  @override
  String get weightLabel => 'Weight (kg)';

  @override
  String get heightLabel => 'Height (cm)';

  @override
  String get ckdStageLabel => 'CKD Stage';

  @override
  String get saveDetailsButton => 'Save Details';

  @override
  String get feedbackPageTitle => 'Give Your Feedback';

  @override
  String get yourNameLabel => 'Your Name';

  @override
  String get yourPhoneNumberLabel => 'Your Phone Number';

  @override
  String get yourFeedbackLabel => 'Your Feedback';

  @override
  String get writeFeedbackHint => 'Write your feedback here...';

  @override
  String get submitFeedbackButton => 'Submit Feedback';

  @override
  String get feedbackSubmittedSuccess => 'Feedback submitted successfully!';

  @override
  String get contactDieticianTitle => 'Contact Dietician';

  @override
  String get noDieticiansFound => 'No dieticians found.';

  @override
  String errorFetchingDieticians(Object error) {
    return 'Error: $error';
  }

  @override
  String experienceLabel(Object experience) {
    return 'Experience: $experience';
  }

  @override
  String specialtyLabel(Object specialty) {
    return 'Specialty: $specialty';
  }

  @override
  String educationLabel(Object education) {
    return 'Education: $education';
  }

  @override
  String get contactWhatsappButton => 'Contact via WhatsApp';

  @override
  String get couldNotLaunchWhatsapp =>
      'Could not launch WhatsApp. Make sure it is installed.';

  @override
  String get homePageTitle => 'KidneyBuddy';

  @override
  String get dietManagementCard => 'Diet Management';

  @override
  String get dietManagementDescription =>
      'Manage your diet with personalized recommendations.';

  @override
  String get vitalMonitoringCard => 'Vital Monitoring';

  @override
  String get vitalMonitoringDescription =>
      'Track and monitor your vital signs.';

  @override
  String get eGFRCalculatorCard => 'eGFR Calculator';

  @override
  String get eGFRCalculatorDescription =>
      'Calculate your eGFR to assess kidney function.';

  @override
  String get contactDieticianCard => 'Contact Dietician';

  @override
  String get contactDieticianDescription =>
      'Connect with expert dieticians for personalized advice.';

  @override
  String get giveYourFeedbackCard => 'Give your Feedback';

  @override
  String get giveYourFeedbackDescription =>
      'Share your thoughts and help us improve the app.';

  @override
  String notYetImplemented(Object title) {
    return 'Navigating to $title (Not yet implemented)';
  }

  @override
  String get notificationsTitle => 'Notifications';

  @override
  String get noNewNotifications => 'You have no new notifications.';

  @override
  String get checkBackLater => 'Check back later for updates!';

  @override
  String get selectLanguageTitle => 'Select Language';

  @override
  String get chooseYourLanguage => 'Choose your preferred language';

  @override
  String get english => 'English';

  @override
  String get hindi => 'Hindi';

  @override
  String get bengali => 'Bengali';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get languageSetting => 'Language';

  @override
  String get vitalTrackingPageTitle => 'Vital Tracking';

  @override
  String get bpTab => 'Blood Pressure';

  @override
  String get creatinineTab => 'Creatinine';

  @override
  String get potassiumTab => 'Potassium';

  @override
  String get noDataAvailable => 'No data available for this category.';

  @override
  String get addBpButton => 'Add Blood Pressure';

  @override
  String get addCreatinineButton => 'Add Creatinine';

  @override
  String get addPotassiumButton => 'Add Potassium';

  @override
  String get addBpPageTitle => 'Add Blood Pressure Reading';

  @override
  String get systolicLabel => 'Systolic';

  @override
  String get diastolicLabel => 'Diastolic';

  @override
  String get systolic => 'Systolic';

  @override
  String get diastolic => 'Diastolic';

  @override
  String get addCommentLabel => 'Add Comment';

  @override
  String get selectDateLabel => 'Select Date';

  @override
  String get selectTimeLabel => 'Select Time';

  @override
  String get saveButton => 'Save';

  @override
  String get loginTitle => 'Login';

  @override
  String get loginSuccessMessage => 'Logged in successfully!';

  @override
  String authErrorMessage(Object error) {
    return 'Authentication Error: $error';
  }

  @override
  String get signInWithGoogleButton => 'Sign in with Google';

  @override
  String get pdfGenerationErrorNoPatientDetails =>
      'Patient details not available for PDF report. Please update your profile.';

  @override
  String get pdfGenerationErrorNoReadings =>
      'No blood pressure readings available to generate a PDF report.';

  @override
  String pdfGenerationError(Object error) {
    return 'Error generating PDF report: $error';
  }

  @override
  String get userNotLoggedIn =>
      'User not logged in. Please sign in to view this content.';

  @override
  String get signOutButton => 'Sign Out';

  @override
  String get signOutConfirmation => 'Are you sure you want to sign out?';

  @override
  String get yesButton => 'Yes';

  @override
  String get noButton => 'No';

  @override
  String get exportPdfButton => 'Export PDF';

  @override
  String get filter => 'Filter';

  @override
  String get filterLastWeek => 'Last 1 Week';

  @override
  String get filterLastMonth => 'Last 1 Month';

  @override
  String get filterLast3Months => 'Last 3 Months';

  @override
  String get filterLast6Months => 'Last 6 Months';

  @override
  String get filterAllTime => 'All Time';

  @override
  String get trend => 'Trend';

  @override
  String get bpTrend => 'BP Trend';

  @override
  String get close => 'Close';
}
