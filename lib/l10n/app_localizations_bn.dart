// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Bengali Bangla (`bn`).
class AppLocalizationsBn extends AppLocalizations {
  AppLocalizationsBn([String locale = 'bn']) : super(locale);

  @override
  String get welcomeTitle => 'কিডনিবাডিতে স্বাগতম';

  @override
  String get welcomeDescription =>
      'এই অ্যাপটি সিকেডি রোগীদের তাদের অবস্থা পরিচালনা করতে এবং আরও অগ্রগতি রোধ করতে সহায়তা করে জীবনকে সহজ করার জন্য ডিজাইন করা হয়েছে';

  @override
  String get renalDietTitle => 'রেনাল ডায়েট ম্যানেজমেন্ট';

  @override
  String get renalDietDescription =>
      'আপনার সিকেডি পর্যায়ের জন্য ব্যক্তিগতকৃত নির্দেশিকা এবং সহজে অনুসরণযোগ্য খাবার পরিকল্পনার সাথে একটি সঠিক রেনাল ডায়েট বজায় রাখুন।';

  @override
  String get vitalTrackingOnboardingTitle =>
      'Empower Your Health with Vital Tracking';

  @override
  String get vitalTrackingOnboardingDescription =>
      'Keep a close eye on key health metrics like blood pressure, weight and fluid. Understand your trends and share data with your care team for better management.';

  @override
  String get connectDieticiansTitle => 'ডায়েটিশিয়ানদের সাথে সংযোগ করুন';

  @override
  String get connectDieticiansDescription =>
      'আপনার কিডনির স্বাস্থ্য যাত্রাকে সমর্থন করার জন্য ব্যক্তিগত পরামর্শ এবং বিশেষজ্ঞ পরামর্শের জন্য সেরা ডায়েটিশিয়ানদের সাথে সহজেই সংযোগ করুন।';

  @override
  String get getStartedButton => 'শুরু করুন';

  @override
  String get nextButton => 'পরবর্তী';

  @override
  String get patientDetailsTitle => 'রোগীর বিবরণ';

  @override
  String get nameLabel => 'নাম';

  @override
  String get phoneNumberLabel => 'ফোন নম্বর';

  @override
  String get weightLabel => 'ওজন (কেজি)';

  @override
  String get heightLabel => 'উচ্চতা (সেমি)';

  @override
  String get ckdStageLabel => 'সিকেডি পর্যায়';

  @override
  String get saveDetailsButton => 'বিস্তারিত সংরক্ষণ করুন';

  @override
  String get feedbackPageTitle => 'আপনার মতামত দিন';

  @override
  String get yourNameLabel => 'আপনার নাম';

  @override
  String get yourPhoneNumberLabel => 'আপনার ফোন নম্বর';

  @override
  String get yourFeedbackLabel => 'আপনার মতামত';

  @override
  String get writeFeedbackHint => 'আপনার মতামত এখানে লিখুন...';

  @override
  String get submitFeedbackButton => 'মতামত জমা দিন';

  @override
  String get feedbackSubmittedSuccess => 'মতামত সফলভাবে জমা দেওয়া হয়েছে!';

  @override
  String get contactDieticianTitle => 'ডায়েটিশিয়ানের সাথে যোগাযোগ করুন';

  @override
  String get noDieticiansFound => 'কোন ডায়েটিশিয়ান পাওয়া যায়নি।';

  @override
  String errorFetchingDieticians(Object error) {
    return 'ত্রুটি: $error';
  }

  @override
  String experienceLabel(Object experience) {
    return 'অভিজ্ঞতা: $experience';
  }

  @override
  String specialtyLabel(Object specialty) {
    return 'বিশেষত্ব: $specialty';
  }

  @override
  String educationLabel(Object education) {
    return 'শিক্ষা: $education';
  }

  @override
  String get contactWhatsappButton => 'হোয়াটসঅ্যাপের মাধ্যমে যোগাযোগ করুন';

  @override
  String get couldNotLaunchWhatsapp =>
      'হোয়াটসঅ্যাপ চালু করা যায়নি। নিশ্চিত করুন এটি ইনস্টল করা আছে।';

  @override
  String get homePageTitle => 'কিডনিবাডি';

  @override
  String get dietManagementCard => 'ডায়েট ম্যানেজমেন্ট';

  @override
  String get dietManagementDescription =>
      'ব্যক্তিগত সুপারিশ সহ আপনার ডায়েট পরিচালনা করুন।';

  @override
  String get vitalMonitoringCard => 'ভাইটাল মনিটরিং';

  @override
  String get vitalMonitoringDescription =>
      'আপনার গুরুত্বপূর্ণ লক্ষণগুলি ট্র্যাক এবং নিরীক্ষণ করুন।';

  @override
  String get eGFRCalculatorCard => 'ইজিএফআর ক্যালকুলেটর';

  @override
  String get eGFRCalculatorDescription =>
      'কিডনি ফাংশন মূল্যায়নের জন্য আপনার ইজিএফআর গণনা করুন।';

  @override
  String get contactDieticianCard => 'ডায়েটিশিয়ানের সাথে যোগাযোগ করুন';

  @override
  String get contactDieticianDescription =>
      'ব্যক্তিগত পরামর্শের জন্য বিশেষজ্ঞ ডায়েটিশিয়ানদের সাথে সংযোগ করুন।';

  @override
  String get giveYourFeedbackCard => 'আপনার মতামত দিন';

  @override
  String get giveYourFeedbackDescription =>
      'আপনার চিন্তা শেয়ার করুন এবং অ্যাপ উন্নত করতে আমাদের সাহায্য করুন।';

  @override
  String notYetImplemented(Object title) {
    return '$title এ নেভিগেট করা হচ্ছে (এখনও বাস্তবায়িত হয়নি)';
  }

  @override
  String get notificationsTitle => 'Notifications';

  @override
  String get noNewNotifications => 'You have no new notifications.';

  @override
  String get checkBackLater => 'Check back later for updates!';

  @override
  String get selectLanguageTitle => 'ভাষা নির্বাচন করুন';

  @override
  String get chooseYourLanguage => 'আপনার পছন্দের ভাষা নির্বাচন করুন';

  @override
  String get english => 'ইংরেজি';

  @override
  String get hindi => 'হিন্দি';

  @override
  String get bengali => 'বাংলা';

  @override
  String get settingsTitle => 'সেটিংস';

  @override
  String get languageSetting => 'ভাষা';

  @override
  String get vitalTrackingPageTitle => 'ভাইটাল ট্র্যাকিং';

  @override
  String get bpTab => 'রক্তচাপ';

  @override
  String get creatinineTab => 'ক্রিয়েটিনিন';

  @override
  String get potassiumTab => 'পটাশিয়াম';

  @override
  String get noDataAvailable => 'এই বিভাগের জন্য কোন ডেটা উপলব্ধ নেই।';

  @override
  String get addBpButton => 'রক্তচাপ যোগ করুন';

  @override
  String get addCreatinineButton => 'ক্রিয়েটিনিন যোগ করুন';

  @override
  String get addPotassiumButton => 'পটাশিয়াম যোগ করুন';

  @override
  String get addBpPageTitle => 'রক্তচাপ রিডিং যোগ করুন';

  @override
  String get systolicLabel => 'সিস্টোলিক';

  @override
  String get diastolicLabel => 'ডায়াস্টোলিক';

  @override
  String get systolic => 'Systolic';

  @override
  String get diastolic => 'Diastolic';

  @override
  String get addCommentLabel => 'মন্তব্য যোগ করুন';

  @override
  String get selectDateLabel => 'তারিখ নির্বাচন করুন';

  @override
  String get selectTimeLabel => 'সময় নির্বাচন করুন';

  @override
  String get saveButton => 'সংরক্ষণ করুন';

  @override
  String get loginTitle => 'লগইন';

  @override
  String get loginSuccessMessage => 'সফলভাবে লগইন করা হয়েছে!';

  @override
  String authErrorMessage(Object error) {
    return 'প্রমাণীকরণ ত্রুটি: $error';
  }

  @override
  String get signInWithGoogleButton => 'Google দিয়ে সাইন ইন করুন';

  @override
  String get authScreenNewTitle => 'Your Partner in Kidney Health';

  @override
  String get authScreenNewDescription =>
      'Manage your CKD journey with personalized diet plans, vital tracking, and expert dietician support.';

  @override
  String get pdfGenerationErrorNoPatientDetails =>
      'পিডিএফ প্রতিবেদনের জন্য রোগীর বিবরণ উপলব্ধ নেই। অনুগ্রহ করে আপনার প্রোফাইল আপডেট করুন।';

  @override
  String get pdfGenerationErrorNoReadings =>
      'পিডিএফ প্রতিবেদন তৈরি করার জন্য কোনো রক্তচাপ রিডিং উপলব্ধ নেই।';

  @override
  String pdfGenerationError(Object error) {
    return 'পিডিএফ প্রতিবেদন তৈরি করতে ত্রুটি: $error';
  }

  @override
  String get userNotLoggedIn =>
      'ব্যবহারকারী লগ ইন করেননি। এই সামগ্রী দেখতে অনুগ্রহ করে সাইন ইন করুন।';

  @override
  String get signOutButton => 'সাইন আউট করুন';

  @override
  String get signOutConfirmation =>
      'আপনি কি নিশ্চিত যে আপনি সাইন আউট করতে চান?';

  @override
  String get yesButton => 'হ্যাঁ';

  @override
  String get noButton => 'না';

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

  @override
  String get deleteConfirmationTitle => 'Delete Confirmation';

  @override
  String get deleteBpReadingConfirmation =>
      'Do you want to delete this BP reading?';

  @override
  String get no => 'No';

  @override
  String get yes => 'Yes';

  @override
  String get bpReadingDeletedSuccessfully => 'BP reading deleted successfully!';

  @override
  String errorDeletingBpReading(Object error) {
    return 'Error deleting BP reading: $error';
  }

  @override
  String get addCreatineReading => 'Add Creatine Reading';

  @override
  String get deleteCreatineReadingConfirmation =>
      'Do you want to delete this Creatine reading?';

  @override
  String get creatineReadingDeletedSuccessfully =>
      'Creatine reading deleted successfully!';

  @override
  String errorDeletingCreatineReading(Object error) {
    return 'Error deleting Creatine reading: $error';
  }

  @override
  String get creatineSavedSuccess => 'Creatine reading saved successfully!';

  @override
  String creatineSaveError(Object error) {
    return 'Error saving Creatine reading: $error';
  }

  @override
  String get selectDateAndTimeError => 'Please select a date and time';

  @override
  String get addYourComment => 'Add Your Comment';

  @override
  String get creatine => 'Creatine';

  @override
  String get sys => 'SYS';

  @override
  String get dia => 'DIA';

  @override
  String get selectDate => 'Select date';

  @override
  String get selectTime => 'Select Time';

  @override
  String get save => 'Save';

  @override
  String get addCreatine => 'Add Creatine';
}
