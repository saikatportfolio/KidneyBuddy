// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get welcomeTitle => 'किडनीबडी में आपका स्वागत है';

  @override
  String get welcomeDescription =>
      'यह ऐप सीकेडी रोगियों के लिए उनकी स्थिति का प्रबंधन करने और आगे बढ़ने से रोकने में मदद करके जीवन को सरल बनाने के लिए डिज़ाइन किया गया है';

  @override
  String get renalDietTitle => 'गुर्दा आहार प्रबंधन';

  @override
  String get renalDietDescription =>
      'अपने सीकेडी चरण के अनुरूप व्यक्तिगत मार्गदर्शन और पालन करने में आसान भोजन योजनाओं के साथ उचित गुर्दा आहार बनाए रखें।';

  @override
  String get connectDieticiansTitle => 'आहार विशेषज्ञों से जुड़ें';

  @override
  String get connectDieticiansDescription =>
      'अपने गुर्दे के स्वास्थ्य यात्रा का समर्थन करने के लिए व्यक्तिगत परामर्श और विशेषज्ञ सलाह के लिए सर्वश्रेष्ठ आहार विशेषज्ञों से आसानी से जुड़ें।';

  @override
  String get getStartedButton => 'शुरू करें';

  @override
  String get nextButton => 'अगला';

  @override
  String get patientDetailsTitle => 'रोगी विवरण';

  @override
  String get nameLabel => 'नाम';

  @override
  String get phoneNumberLabel => 'फ़ोन नंबर';

  @override
  String get weightLabel => 'वजन (किग्रा)';

  @override
  String get heightLabel => 'ऊंचाई (सेमी)';

  @override
  String get ckdStageLabel => 'सीकेडी चरण';

  @override
  String get saveDetailsButton => 'विवरण सहेजें';

  @override
  String get feedbackPageTitle => 'अपनी प्रतिक्रिया दें';

  @override
  String get yourNameLabel => 'आपका नाम';

  @override
  String get yourPhoneNumberLabel => 'आपका फ़ोन नंबर';

  @override
  String get yourFeedbackLabel => 'आपकी प्रतिक्रिया';

  @override
  String get writeFeedbackHint => 'अपनी प्रतिक्रिया यहाँ लिखें...';

  @override
  String get submitFeedbackButton => 'प्रतिक्रिया सबमिट करें';

  @override
  String get feedbackSubmittedSuccess => 'प्रतिक्रिया सफलतापूर्वक सबमिट की गई!';

  @override
  String get contactDieticianTitle => 'आहार विशेषज्ञ से संपर्क करें';

  @override
  String get noDieticiansFound => 'कोई आहार विशेषज्ञ नहीं मिला।';

  @override
  String errorFetchingDieticians(Object error) {
    return 'त्रुटि: $error';
  }

  @override
  String experienceLabel(Object experience) {
    return 'अनुभव: $experience';
  }

  @override
  String specialtyLabel(Object specialty) {
    return 'विशेषता: $specialty';
  }

  @override
  String educationLabel(Object education) {
    return 'शिक्षा: $education';
  }

  @override
  String get contactWhatsappButton => 'व्हाट्सएप के माध्यम से संपर्क करें';

  @override
  String get couldNotLaunchWhatsapp =>
      'व्हाट्सएप लॉन्च नहीं हो सका। सुनिश्चित करें कि यह स्थापित है।';

  @override
  String get homePageTitle => 'किडनीबडी';

  @override
  String get dietManagementCard => 'आहार प्रबंधन';

  @override
  String get dietManagementDescription =>
      'व्यक्तिगत सिफारिशों के साथ अपने आहार का प्रबंधन करें।';

  @override
  String get vitalMonitoringCard => 'महत्वपूर्ण निगरानी';

  @override
  String get vitalMonitoringDescription =>
      'अपने महत्वपूर्ण संकेतों को ट्रैक और मॉनिटर करें।';

  @override
  String get eGFRCalculatorCard => 'ईजीएफआर कैलकुलेटर';

  @override
  String get eGFRCalculatorDescription =>
      'किडनी के कार्य का आकलन करने के लिए अपने ईजीएफआर की गणना करें।';

  @override
  String get contactDieticianCard => 'आहार विशेषज्ञ से संपर्क करें';

  @override
  String get contactDieticianDescription =>
      'व्यक्तिगत सलाह के लिए विशेषज्ञ आहार विशेषज्ञों से जुड़ें।';

  @override
  String get giveYourFeedbackCard => 'अपनी प्रतिक्रिया दें';

  @override
  String get giveYourFeedbackDescription =>
      'अपने विचार साझा करें और ऐप को बेहतर बनाने में हमारी मदद करें।';

  @override
  String notYetImplemented(Object title) {
    return '$title पर नेविगेट करना (अभी तक लागू नहीं किया गया)';
  }

  @override
  String get selectLanguageTitle => 'भाषा चुनें';

  @override
  String get chooseYourLanguage => 'अपनी पसंदीदा भाषा चुनें';

  @override
  String get english => 'अंग्रेज़ी';

  @override
  String get hindi => 'हिंदी';

  @override
  String get bengali => 'बंगाली';

  @override
  String get settingsTitle => 'सेटिंग्स';

  @override
  String get languageSetting => 'भाषा';

  @override
  String get vitalTrackingPageTitle => 'महत्वपूर्ण ट्रैकिंग';

  @override
  String get bpTab => 'रक्तचाप';

  @override
  String get creatinineTab => 'क्रिएटिनिन';

  @override
  String get potassiumTab => 'पोटेशियम';

  @override
  String get noDataAvailable => 'इस श्रेणी के लिए कोई डेटा उपलब्ध नहीं है।';

  @override
  String get addBpButton => 'रक्तचाप जोड़ें';

  @override
  String get addCreatinineButton => 'क्रिएटिनिन जोड़ें';

  @override
  String get addPotassiumButton => 'पोटेशियम जोड़ें';

  @override
  String get addBpPageTitle => 'रक्तचाप रीडिंग जोड़ें';

  @override
  String get systolicLabel => 'सिस्टोलिक';

  @override
  String get diastolicLabel => 'डायस्टोलिक';

  @override
  String get addCommentLabel => 'टिप्पणी जोड़ें';

  @override
  String get selectDateLabel => 'दिनांक चुनें';

  @override
  String get selectTimeLabel => 'समय चुनें';

  @override
  String get saveButton => 'सहेजें';

  @override
  String get loginTitle => 'लॉग इन करें';

  @override
  String get signupTitle => 'साइन अप करें';

  @override
  String get emailLabel => 'ईमेल';

  @override
  String get passwordLabel => 'पासवर्ड';

  @override
  String get confirmPasswordLabel => 'पासवर्ड की पुष्टि करें';

  @override
  String get signInButton => 'साइन इन करें';

  @override
  String get signUpButton => 'साइन अप करें';

  @override
  String get noAccountPrompt => 'खाता नहीं है? साइन अप करें';

  @override
  String get haveAccountPrompt => 'पहले से ही एक खाता है? साइन इन करें';

  @override
  String get loginSuccessMessage => 'सफलतापूर्वक लॉग इन किया गया!';

  @override
  String get signupSuccessMessage =>
      'खाता सफलतापूर्वक बनाया गया! कृपया सत्यापित करने के लिए अपना ईमेल जांचें।';

  @override
  String authErrorMessage(Object error) {
    return 'प्रमाणीकरण त्रुटि: $error';
  }

  @override
  String get pdfGenerationErrorNoPatientDetails =>
      'पीडीएफ रिपोर्ट के लिए रोगी विवरण उपलब्ध नहीं है। कृपया अपनी प्रोफ़ाइल अपडेट करें।';

  @override
  String get pdfGenerationErrorNoReadings =>
      'पीडीएफ रिपोर्ट बनाने के लिए कोई रक्तचाप रीडिंग उपलब्ध नहीं है।';

  @override
  String pdfGenerationError(Object error) {
    return 'पीडीएफ रिपोर्ट बनाने में त्रुटि: $error';
  }

  @override
  String get userNotLoggedIn =>
      'उपयोगकर्ता लॉग इन नहीं है। इस सामग्री को देखने के लिए कृपया साइन इन करें।';
}
