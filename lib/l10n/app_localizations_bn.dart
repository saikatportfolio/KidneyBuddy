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
  String get welcomeDescription => 'এই অ্যাপটি সিকেডি রোগীদের তাদের অবস্থা পরিচালনা করতে এবং আরও অগ্রগতি রোধ করতে সহায়তা করে জীবনকে সহজ করার জন্য ডিজাইন করা হয়েছে';

  @override
  String get renalDietTitle => 'রেনাল ডায়েট ম্যানেজমেন্ট';

  @override
  String get renalDietDescription => 'আপনার সিকেডি পর্যায়ের জন্য ব্যক্তিগতকৃত নির্দেশিকা এবং সহজে অনুসরণযোগ্য খাবার পরিকল্পনার সাথে একটি সঠিক রেনাল ডায়েট বজায় রাখুন।';

  @override
  String get connectDieticiansTitle => 'ডায়েটিশিয়ানদের সাথে সংযোগ করুন';

  @override
  String get connectDieticiansDescription => 'আপনার কিডনির স্বাস্থ্য যাত্রাকে সমর্থন করার জন্য ব্যক্তিগত পরামর্শ এবং বিশেষজ্ঞ পরামর্শের জন্য সেরা ডায়েটিশিয়ানদের সাথে সহজেই সংযোগ করুন।';

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
  String get couldNotLaunchWhatsapp => 'হোয়াটসঅ্যাপ চালু করা যায়নি। নিশ্চিত করুন এটি ইনস্টল করা আছে।';

  @override
  String get homePageTitle => 'কিডনিবাডি';

  @override
  String get dietManagementCard => 'ডায়েট ম্যানেজমেন্ট';

  @override
  String get bloodPressureMonitoringCard => 'রক্তচাপ পর্যবেক্ষণ';

  @override
  String get eGFRCalculatorCard => 'ইজিএফআর ক্যালকুলেটর';

  @override
  String get contactDieticianCard => 'ডায়েটিশিয়ানের সাথে যোগাযোগ করুন';

  @override
  String get giveYourFeedbackCard => 'আপনার মতামত দিন';

  @override
  String notYetImplemented(Object title) {
    return '$title এ নেভিগেট করা হচ্ছে (এখনও বাস্তবায়িত হয়নি)';
  }

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
}
