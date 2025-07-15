import 'package:flutter/widgets.dart';
import 'package:myapp/l10n/app_localizations.dart';

class LocalizationHelper {
  static String translateKey(BuildContext context, String key) {
    final localizations = AppLocalizations.of(context)!;
    switch (key) {
      case 'bpTab':
        return localizations.bpTab;
      case 'creatinineTab':
        return localizations.creatinineTab;
      case 'potassiumTab':
        return localizations.potassiumTab;
      case 'vitalTrackingPageTitle':
        return localizations.vitalTrackingPageTitle;
      case 'noDataAvailable':
        return localizations.noDataAvailable;
      case 'addBpButton':
        return localizations.addBpButton;
      case 'addCreatinineButton':
        return localizations.addCreatinineButton;
      case 'addPotassiumButton':
        return localizations.addPotassiumButton;
      case 'addBpPageTitle':
        return localizations.addBpPageTitle;
      case 'notYetImplemented':
        return localizations.notYetImplemented(''); // Pass empty string for now, or adjust notYetImplemented signature
      case 'systolicLabel':
        return localizations.systolicLabel;
      case 'diastolicLabel':
        return localizations.diastolicLabel;
      case 'addCommentLabel':
        return localizations.addCommentLabel;
      case 'selectDateLabel':
        return localizations.selectDateLabel;
      case 'selectTimeLabel':
        return localizations.selectTimeLabel;
      case 'saveButton':
        return localizations.saveButton;
      case 'loginTitle':
        return localizations.loginTitle;
      case 'signupTitle':
        return localizations.signupTitle;
      case 'emailLabel':
        return localizations.emailLabel;
      case 'passwordLabel':
        return localizations.passwordLabel;
      case 'confirmPasswordLabel':
        return localizations.confirmPasswordLabel;
      case 'signInButton':
        return localizations.signInButton;
      case 'signUpButton':
        return localizations.signUpButton;
      case 'noAccountPrompt':
        return localizations.noAccountPrompt;
      case 'haveAccountPrompt':
        return localizations.haveAccountPrompt;
      case 'loginSuccessMessage':
        return localizations.loginSuccessMessage;
      case 'signupSuccessMessage':
        return localizations.signupSuccessMessage;
      case 'authErrorMessage':
        return localizations.authErrorMessage(''); // Pass empty string for now, or adjust signature
      default:
        return key; // Fallback to key if not found
    }
  }
}
